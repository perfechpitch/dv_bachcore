// Controlled AXI4 performance endpoint; testbench model, not synthesizable RTL.
//
// Writes are a sink (including legal partial WSTRB); reads return the pattern
// byte(addr, lane) = XOR of the four bytes of (addr + lane), XOR 8'ha5.
// Address high bits distinguish both halves of a 512-byte burst. This is
// not a memory model: read-after-write data retention is outside its purpose.
// AW and AR have independent FIFOs. W follows AW order, B follows completed
// W order, and R follows AR order, including requests that reuse an ID.
//
// throttle_period == 0 disables throttling. Otherwise, WREADY and production
// of new R beats are enabled for throttle_open cycles per throttle_period.
// throttle_open >= throttle_period means fully open. A presented R beat is
// held regardless of throttle changes until RREADY completes its handshake.
// The phase is reset to zero by reset; the R production slot is registered,
// so its handshake is one edge after the slot when RREADY remains asserted.
//
// Counters record actual VALID && READY handshakes, not queued API calls.
// The performance monitor must independently count strobed W bytes and full
// R bytes in its own measurement window. Reset discards all in-flight work.
module axi4_perf_slave #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 256,
  parameter int ID_WIDTH = 8,
  parameter int QUEUE_DEPTH = 512,
  parameter bit CHECK_WRITE_PATTERN = 0
) (
  axi4_if.slave axi,
  input int unsigned throttle_period,
  input int unsigned throttle_open,
  output longint unsigned aw_bursts,
  output longint unsigned ar_bursts,
  output longint unsigned w_beats,
  output longint unsigned r_beats,
  output longint unsigned b_responses
);
  localparam int BYTE_LANES = DATA_WIDTH / 8;
  localparam int FULL_SIZE = $clog2(BYTE_LANES);

  typedef struct packed {
    logic [ID_WIDTH-1:0] id;
    logic [ADDR_WIDTH-1:0] addr;
    int unsigned beats;
  } request_t;

  request_t writes [QUEUE_DEPTH];
  request_t reads [QUEUE_DEPTH];
  logic [ID_WIDTH-1:0] responses [QUEUE_DEPTH];
  int unsigned wr_head, wr_tail, wr_count, wr_beat;
  int unsigned rd_head, rd_tail, rd_count, rd_beat;
  int unsigned b_head, b_tail, b_count;
  longint unsigned cycle_count;

  function automatic int unsigned advance(input int unsigned ptr);
    return (ptr + 1 == QUEUE_DEPTH) ? 0 : ptr + 1;
  endfunction

  function automatic bit slot_open(input longint unsigned cycle);
    if (throttle_period == 0)
      return 1'b1;
    return (cycle % throttle_period) < throttle_open;
  endfunction

  function automatic logic [DATA_WIDTH-1:0] read_pattern(
    input logic [ADDR_WIDTH-1:0] addr
  );
    logic [DATA_WIDTH-1:0] value;
    logic [ADDR_WIDTH-1:0] byte_addr;
    for (int lane = 0; lane < BYTE_LANES; lane++) begin
      byte_addr = addr + lane;
      value[8*lane +: 8] = byte_addr ^ (byte_addr >> 8) ^
                           (byte_addr >> 16) ^ (byte_addr >> 24) ^ 8'ha5;
    end
    return value;
  endfunction

  task automatic check_request(
    input string channel,
    input logic [ADDR_WIDTH-1:0] addr,
    input int unsigned beats,
    input logic [2:0] size,
    input logic [1:0] burst
  );
    int unsigned page_offset;
    if ($isunknown({addr, size, burst}))
      $fatal(1, "PERF_SLAVE %s request contains X/Z", channel);
    if (burst !== 2'b01 || size != FULL_SIZE)
      $fatal(1, "PERF_SLAVE %s requires INCR full-width transfers", channel);
    if (addr % BYTE_LANES != 0)
      $fatal(1, "PERF_SLAVE %s unaligned addr=%h", channel, addr);
    page_offset = addr & 12'hfff;
    if (page_offset + beats * BYTE_LANES > 4096)
      $fatal(1, "PERF_SLAVE %s crosses 4KB: addr=%h beats=%0d",
             channel, addr, beats);
  endtask

  initial begin
    if (DATA_WIDTH < 8 || DATA_WIDTH % 8 != 0 ||
        (BYTE_LANES & (BYTE_LANES - 1)) != 0 || FULL_SIZE > 7)
      $fatal(1, "PERF_SLAVE invalid DATA_WIDTH=%0d", DATA_WIDTH);
    if (QUEUE_DEPTH < 256)
      $fatal(1, "PERF_SLAVE QUEUE_DEPTH must be at least 256");
    if ($bits(axi.awaddr) != ADDR_WIDTH || $bits(axi.araddr) != ADDR_WIDTH ||
        $bits(axi.wdata) != DATA_WIDTH || $bits(axi.rdata) != DATA_WIDTH ||
        $bits(axi.awid) != ID_WIDTH || $bits(axi.arid) != ID_WIDTH)
      $fatal(1, "PERF_SLAVE parameters do not match axi4_if");
  end

  assign axi.bresp = 2'b00;
  assign axi.buser = '0;
  assign axi.rresp = 2'b00;
  assign axi.ruser = '0;

  // Behavioral queues use blocking state updates inside this single owner.
  // Capture every handshake before updating queue state; all changing bus
  // outputs use NBA updates and remain stable through the sampling edge.
  always @(posedge axi.aclk or negedge axi.aresetn) begin : service
    bit aw_fire, w_fire, b_fire, ar_fire, r_fire, produce_r;
    if (!axi.aresetn) begin
      wr_head = 0; wr_tail = 0; wr_count = 0; wr_beat = 0;
      rd_head = 0; rd_tail = 0; rd_count = 0; rd_beat = 0;
      b_head = 0; b_tail = 0; b_count = 0;
      cycle_count = 0;
      aw_bursts = 0; ar_bursts = 0;
      w_beats = 0; r_beats = 0; b_responses = 0;
      axi.awready <= 1'b0;
      axi.arready <= 1'b0;
      axi.wready <= 1'b0;
      axi.bvalid <= 1'b0;
      axi.bid <= '0;
      axi.rvalid <= 1'b0;
      axi.rid <= '0;
      axi.rdata <= '0;
      axi.rlast <= 1'b0;
    end else begin
      aw_fire = axi.awvalid && axi.awready;
      w_fire = axi.wvalid && axi.wready;
      b_fire = axi.bvalid && axi.bready;
      ar_fire = axi.arvalid && axi.arready;
      r_fire = axi.rvalid && axi.rready;
      produce_r = slot_open(cycle_count);

      if (b_fire) begin
        b_head = advance(b_head);
        b_count--;
        b_responses++;
      end

      if (w_fire) begin
        if ($isunknown(axi.wstrb))
          $fatal(1, "PERF_SLAVE WSTRB contains X/Z");
        if (axi.wlast !== (wr_beat + 1 == writes[wr_head].beats))
          $fatal(1, "PERF_SLAVE WLAST mismatch beat=%0d beats=%0d",
                 wr_beat, writes[wr_head].beats);
        if (CHECK_WRITE_PATTERN) begin
          logic [DATA_WIDTH-1:0] expected_data;
          expected_data = read_pattern(writes[wr_head].addr + wr_beat * BYTE_LANES);
          for (int lane = 0; lane < BYTE_LANES; lane++)
            if (axi.wstrb[lane] && axi.wdata[8*lane +: 8] !== expected_data[8*lane +: 8])
              $fatal(1, "PERF_SLAVE write pattern mismatch beat=%0d lane=%0d", wr_beat, lane);
        end
        w_beats++;
        if (wr_beat + 1 == writes[wr_head].beats) begin
          responses[b_tail] = writes[wr_head].id;
          b_tail = advance(b_tail);
          b_count++;
          wr_head = advance(wr_head);
          wr_count--;
          wr_beat = 0;
        end else begin
          wr_beat++;
        end
      end

      if (aw_fire) begin
        if ($isunknown({axi.awid, axi.awlen}))
          $fatal(1, "PERF_SLAVE AWID/AWLEN contains X/Z");
        check_request("AW", axi.awaddr, int'(axi.awlen) + 1,
                      axi.awsize, axi.awburst);
        writes[wr_tail].id = axi.awid;
        writes[wr_tail].addr = axi.awaddr;
        writes[wr_tail].beats = int'(axi.awlen) + 1;
        wr_tail = advance(wr_tail);
        wr_count++;
        aw_bursts++;
      end

      if (r_fire) begin
        r_beats++;
        if (rd_beat + 1 == reads[rd_head].beats) begin
          rd_head = advance(rd_head);
          rd_count--;
          rd_beat = 0;
        end else begin
          rd_beat++;
        end
      end

      if (ar_fire) begin
        if ($isunknown({axi.arid, axi.arlen}))
          $fatal(1, "PERF_SLAVE ARID/ARLEN contains X/Z");
        check_request("AR", axi.araddr, int'(axi.arlen) + 1,
                      axi.arsize, axi.arburst);
        reads[rd_tail].id = axi.arid;
        reads[rd_tail].addr = axi.araddr;
        reads[rd_tail].beats = int'(axi.arlen) + 1;
        rd_tail = advance(rd_tail);
        rd_count++;
        ar_bursts++;
      end

      if (!axi.rvalid || r_fire) begin
        if (rd_count != 0 && produce_r) begin
          axi.rvalid <= 1'b1;
          axi.rid <= reads[rd_head].id;
          axi.rdata <= read_pattern(reads[rd_head].addr + rd_beat * BYTE_LANES);
          axi.rlast <= (rd_beat + 1 == reads[rd_head].beats);
        end else begin
          axi.rvalid <= 1'b0;
          axi.rlast <= 1'b0;
        end
      end
      cycle_count++;
      axi.awready <= (wr_count < QUEUE_DEPTH);
      axi.arready <= (rd_count < QUEUE_DEPTH);
      // Reserve response capacity before accepting W. Applying this to all
      // beats simplifies the model without affecting its open-mode rate.
      axi.wready <= (wr_count != 0 && b_count < QUEUE_DEPTH &&
                     slot_open(cycle_count));
      axi.bvalid <= (b_count != 0);
      axi.bid <= (b_count != 0) ? responses[b_head] : '0;
    end
  end
endmodule
