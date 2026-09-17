// Controlled, single-transaction-per-direction slave for the burst regression.
// This is a test fixture, not the production slave or an outstanding model.
// Change the public controls below on a negedge while the relevant direction
// is idle. Delays count complete stalled clock edges; zero permits the first
// available handshake. AW/AR delay starts when VALID is observed. W delay
// starts after AW, and W/R gap is inserted after each accepted non-final beat.
// B/R have one registered preparation cycle in addition to their delay.
module burst_test_slave #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 256,
  parameter int ID_WIDTH = 8,
  parameter int MEM_BYTES = 65536
) (
  axi4_if.slave axi
);
  localparam int BUS_BYTES = DATA_WIDTH / 8;
  localparam int FULL_SIZE = $clog2(BUS_BYTES);
  localparam int AW_PAYLOAD_WIDTH = ID_WIDTH + ADDR_WIDTH +
                                      $bits(axi.awlen) + 3 + 2;
  localparam int AR_PAYLOAD_WIDTH = ID_WIDTH + ADDR_WIDTH +
                                      $bits(axi.arlen) + 3 + 2;

  // Public testbench controls. Defaults are a correct, unstalled slave.
  int unsigned aw_delay_cycles = 0;
  int unsigned w_delay_cycles = 0;
  int unsigned w_gap_cycles = 0;
  int unsigned ar_delay_cycles = 0;
  int unsigned b_delay_cycles = 0;
  int unsigned r_delay_cycles = 0;
  int unsigned r_gap_cycles = 0;
  bit aw_wait_wvalid = 0;
  // Deliberately model extra acceptance capacity: keep address READY high for
  // one extra accepting edge after AW/AR and WREADY after the final W beat.
  // Repeated address VALID is counted without replacing the transaction;
  // an extra W handshake is fatal. This exposes a driver advancing too late.
  bit hold_address_ready = 0;
  logic [1:0] write_resp = 2'b00;
  logic [1:0] read_resp = 2'b00;
  logic [ID_WIDTH-1:0] write_id_xor = '0;
  logic [ID_WIDTH-1:0] read_id_xor = '0;
  // Move both RLAST and the end of the response by this many beats.
  // -1: early RLAST (requires at least two requested beats); +1: late RLAST.
  int rlast_offset = 0;
  // Invert every RLAST value without changing the number of returned beats.
  bit invert_rlast = 0;

  // Public counters count ONLY VALID && READY at a positive clock edge.
  int unsigned aw_count, w_count, b_count, ar_count, r_count;
  byte unsigned mem [0:MEM_BYTES-1];

  bit wr_busy, have_aw, b_pending, rd_active;
  bit rd_invert_last;
  bit aw_extra_ready, ar_extra_ready, w_extra_ready;
  logic [ADDR_WIDTH-1:0] wr_addr, rd_addr;
  logic [ID_WIDTH-1:0] wr_response_id, rd_response_id;
  logic [1:0] wr_response, rd_response;
  int unsigned wr_beats, wr_index, wr_step;
  int unsigned rd_send_beats, rd_index, rd_step;
  int unsigned aw_wait, ar_wait, w_wait, b_wait, r_wait;
  int unsigned wr_gap, rd_gap;

  bit aw_stalled, w_stalled, ar_stalled;
  logic [AW_PAYLOAD_WIDTH-1:0] held_aw;
  logic [DATA_WIDTH+BUS_BYTES:0] held_w;
  logic [AR_PAYLOAD_WIDTH-1:0] held_ar;

  assign axi.awready = axi.aresetn && (aw_extra_ready ||
                       (!wr_busy && (aw_wait >= aw_delay_cycles) &&
                        (!aw_wait_wvalid || axi.wvalid)));
  assign axi.wready = axi.aresetn &&
                      (w_extra_ready || (have_aw && (w_wait == 0)));
  assign axi.arready = axi.aresetn && (ar_extra_ready ||
                       (!rd_active && (ar_wait >= ar_delay_cycles)));

  // The entire bus word is returned. A narrow single transfer uses the
  // addressed byte lanes, matching AXI lane placement rather than shifting
  // narrow data down into lane zero. The memory deliberately aliases modulo
  // MEM_BYTES; tests should stay within its range unless testing addresses.
  function automatic logic [DATA_WIDTH-1:0] read_bus(
      input logic [ADDR_WIDTH-1:0] addr);
    logic [ADDR_WIDTH-1:0] base;
    base = (addr >> FULL_SIZE) << FULL_SIZE;
    for (int lane = 0; lane < BUS_BYTES; lane++)
      read_bus[lane*8 +: 8] = mem[(base + lane) % MEM_BYTES];
  endfunction

  task automatic check_address(
      input logic [ADDR_WIDTH-1:0] addr,
      input int unsigned len,
      input logic [2:0] size,
      input logic [1:0] burst,
      input string channel_name);
    int unsigned transfer_bytes;
    if ($isunknown({addr, size, burst}))
      $fatal(1, "SLAVE %s address payload contains X/Z", channel_name);
    if (burst != 2'b01 || len > 15 || size > FULL_SIZE)
      $fatal(1, "SLAVE %s unsupported burst/length/size", channel_name);
    transfer_bytes = 1 << size;
    if ((addr % transfer_bytes) != 0)
      $fatal(1, "SLAVE %s unaligned address", channel_name);
    if (((addr % 4096) + (len + 1) * transfer_bytes) > 4096)
      $fatal(1, "SLAVE %s crosses 4KB boundary", channel_name);
  endtask

  initial begin
    if (DATA_WIDTH < 8 || (DATA_WIDTH % 8) != 0 ||
        (BUS_BYTES & (BUS_BYTES - 1)) != 0 || MEM_BYTES < BUS_BYTES)
      $fatal(1, "SLAVE invalid data/memory width");
    if ($bits(axi.awaddr) != ADDR_WIDTH ||
        $bits(axi.wdata) != DATA_WIDTH || $bits(axi.awid) != ID_WIDTH)
      $fatal(1, "SLAVE parameters do not match AXI interface");
  end

  always @(posedge axi.aclk or negedge axi.aresetn) begin : slave_state
    if (!axi.aresetn) begin
      wr_busy <= 0;
      have_aw <= 0;
      b_pending <= 0;
      rd_active <= 0;
      rd_invert_last <= 0;
      aw_extra_ready <= 0;
      ar_extra_ready <= 0;
      w_extra_ready <= 0;
      wr_addr <= '0;
      rd_addr <= '0;
      wr_response_id <= '0;
      rd_response_id <= '0;
      wr_response <= '0;
      rd_response <= '0;
      wr_beats <= 0;
      wr_index <= 0;
      wr_step <= 0;
      rd_send_beats <= 0;
      rd_index <= 0;
      rd_step <= 0;
      aw_wait <= 0;
      ar_wait <= 0;
      w_wait <= 0;
      b_wait <= 0;
      r_wait <= 0;
      wr_gap <= 0;
      rd_gap <= 0;
      aw_count <= 0;
      w_count <= 0;
      b_count <= 0;
      ar_count <= 0;
      r_count <= 0;
      axi.bvalid <= 0;
      axi.bid <= '0;
      axi.bresp <= '0;
      axi.rvalid <= 0;
      axi.rid <= '0;
      axi.rdata <= '0;
      axi.rresp <= '0;
      axi.rlast <= 0;
      aw_stalled <= 0;
      w_stalled <= 0;
      ar_stalled <= 0;
      held_aw <= '0;
      held_w <= '0;
      held_ar <= '0;
      for (int i = 0; i < MEM_BYTES; i++) mem[i] <= 0;
    end else begin
      aw_extra_ready <= 0;
      ar_extra_ready <= 0;
      w_extra_ready <= 0;
      // A previously stalled payload must survive the accepting edge too.
      if (aw_stalled && (!axi.awvalid ||
          {axi.awid, axi.awaddr, axi.awlen, axi.awsize, axi.awburst} !== held_aw))
        $fatal(1, "SLAVE AW payload/VALID changed under backpressure");
      if (w_stalled && (!axi.wvalid ||
          {axi.wdata, axi.wstrb, axi.wlast} !== held_w))
        $fatal(1, "SLAVE W payload/VALID changed under backpressure");
      if (ar_stalled && (!axi.arvalid ||
          {axi.arid, axi.araddr, axi.arlen, axi.arsize, axi.arburst} !== held_ar))
        $fatal(1, "SLAVE AR payload/VALID changed under backpressure");
      aw_stalled <= axi.awvalid && !axi.awready;
      w_stalled <= axi.wvalid && !axi.wready;
      ar_stalled <= axi.arvalid && !axi.arready;
      held_aw <= {axi.awid, axi.awaddr, axi.awlen, axi.awsize, axi.awburst};
      held_w <= {axi.wdata, axi.wstrb, axi.wlast};
      held_ar <= {axi.arid, axi.araddr, axi.arlen, axi.arsize, axi.arburst};

      if (!wr_busy && axi.awvalid && !axi.awready) aw_wait <= aw_wait + 1;
      if (!axi.awvalid) aw_wait <= 0;
      if (!rd_active && axi.arvalid && !axi.arready) ar_wait <= ar_wait + 1;
      if (!axi.arvalid) ar_wait <= 0;

      if (axi.awvalid && axi.awready) begin
        aw_count <= aw_count + 1;
        if (!wr_busy) begin
          check_address(axi.awaddr, int'(axi.awlen), axi.awsize, axi.awburst, "AW");
          aw_extra_ready <= hold_address_ready;
          aw_wait <= 0;
          wr_busy <= 1;
          have_aw <= 1;
          wr_addr <= axi.awaddr;
          wr_beats <= int'(axi.awlen) + 1;
          wr_index <= 0;
          wr_step <= 1 << axi.awsize;
          wr_response_id <= axi.awid ^ write_id_xor;
          wr_response <= write_resp;
          wr_gap <= w_gap_cycles;
          w_wait <= w_delay_cycles;
        end
      end

      if (have_aw && w_wait != 0) w_wait <= w_wait - 1;
      if (axi.wvalid && axi.wready) begin : write_beat
        logic [ADDR_WIDTH-1:0] base;
        int unsigned first_lane;
        if (!have_aw)
          $fatal(1, "SLAVE extra W handshake after the final accepted W beat");
        if (axi.wlast !== (wr_index == wr_beats - 1))
          $fatal(1, "SLAVE WLAST mismatch beat=%0d expected_beats=%0d", wr_index, wr_beats);
        first_lane = wr_addr % BUS_BYTES;
        base = (wr_addr >> FULL_SIZE) << FULL_SIZE;
        for (int lane = 0; lane < BUS_BYTES; lane++) begin
          if (axi.wstrb[lane]) begin
            if (lane < first_lane || lane >= first_lane + wr_step)
              $fatal(1, "SLAVE WSTRB outside transfer byte lanes");
            mem[(base + lane) % MEM_BYTES] <= axi.wdata[lane*8 +: 8];
          end
        end
        w_count <= w_count + 1;
        if (wr_index == wr_beats - 1) begin
          have_aw <= 0;
          w_extra_ready <= hold_address_ready;
          b_pending <= 1;
          b_wait <= b_delay_cycles;
        end else begin
          wr_index <= wr_index + 1;
          wr_addr <= wr_addr + wr_step;
          w_wait <= wr_gap;
        end
      end

      if (b_pending && !axi.bvalid) begin
        if (b_wait != 0) b_wait <= b_wait - 1;
        else begin
          axi.bvalid <= 1;
          axi.bid <= wr_response_id;
          axi.bresp <= wr_response;
          b_pending <= 0;
        end
      end
      if (axi.bvalid && axi.bready) begin
        b_count <= b_count + 1;
        axi.bvalid <= 0;
        wr_busy <= 0;
      end

      if (axi.arvalid && axi.arready) begin
        ar_count <= ar_count + 1;
        if (!rd_active) begin
          check_address(axi.araddr, int'(axi.arlen), axi.arsize, axi.arburst, "AR");
          if ((int'(axi.arlen) + 1 + rlast_offset) < 1)
            $fatal(1, "SLAVE rlast_offset would produce an empty response");
          ar_extra_ready <= hold_address_ready;
          ar_wait <= 0;
          rd_active <= 1;
          rd_addr <= axi.araddr;
          rd_send_beats <= int'(axi.arlen) + 1 + rlast_offset;
          rd_invert_last <= invert_rlast;
          rd_index <= 0;
          rd_step <= 1 << axi.arsize;
          rd_response_id <= axi.arid ^ read_id_xor;
          rd_response <= read_resp;
          rd_gap <= r_gap_cycles;
          r_wait <= r_delay_cycles;
        end
      end

      if (rd_active && !axi.rvalid) begin
        if (r_wait != 0) r_wait <= r_wait - 1;
        else begin
          axi.rvalid <= 1;
          axi.rid <= rd_response_id;
          axi.rresp <= rd_response;
          axi.rdata <= read_bus(rd_addr);
          axi.rlast <= (rd_index == rd_send_beats - 1) ^ rd_invert_last;
        end
      end
      if (axi.rvalid && axi.rready) begin
        r_count <= r_count + 1;
        if (rd_index == rd_send_beats - 1) begin
          axi.rvalid <= 0;
          rd_active <= 0;
        end else begin
          rd_index <= rd_index + 1;
          rd_addr <= rd_addr + rd_step;
          if (rd_gap == 0) begin
            // Continuous VALID exercises back-to-back accepted beats.
            axi.rdata <= read_bus(rd_addr + rd_step);
            axi.rlast <= (rd_index + 1 == rd_send_beats - 1) ^ rd_invert_last;
          end else begin
            axi.rvalid <= 0;
            r_wait <= rd_gap - 1;
          end
        end
      end
    end
  end
endmodule
