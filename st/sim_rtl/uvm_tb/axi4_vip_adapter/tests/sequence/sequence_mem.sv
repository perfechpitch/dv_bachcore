// Test-only controlled AXI memory. Addresses are synthetic test addresses,
// not a claimed NoC map. Sparse byte storage deliberately has no modulo alias.
module sequence_mem #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 256,
  parameter int ID_WIDTH = 8,
  parameter int LEN_WIDTH = 4,
  parameter int QUEUE_DEPTH = 512,
  parameter bit BACKPRESSURE = 1'b1
) (
  axi4_if.slave axi,
  input integer release_threshold,
  input bit gate_responses
);
  localparam int BUS_BYTES = DATA_WIDTH / 8;
  localparam int FULL_SIZE = $clog2(BUS_BYTES);

  typedef struct {
    logic [ID_WIDTH-1:0] id;
    longint unsigned addr;
    int unsigned beats;
    int unsigned size;
    int unsigned next_beat;
  } request_t;

  request_t aw_queue[$];
  request_t ar_queue[$];
  logic [ID_WIDTH-1:0] b_queue[$];
  logic [7:0] memory[longint unsigned];

  // Public counters for testbench assertions. R/W count individual beats;
  // AW/AR/B count transactions. Read completion is an accepted RLAST.
  integer unsigned aw_count, ar_count, w_count, b_count, r_count;
  integer unsigned write_inflight, read_inflight, total_inflight;
  integer unsigned write_peak, read_peak, total_peak;
  integer unsigned cycle_count;
  bit responses_open;
  bit previous_gate;

  initial begin
    if (ADDR_WIDTH > 32 || DATA_WIDTH < 8 ||
        DATA_WIDTH % 8 != 0 || (BUS_BYTES & (BUS_BYTES - 1)) != 0 ||
        QUEUE_DEPTH < 1)
      $fatal(1, "sequence_mem: invalid test memory parameters");
    if ($bits(axi.awaddr) != ADDR_WIDTH || $bits(axi.wdata) != DATA_WIDTH ||
        $bits(axi.awid) != ID_WIDTH || $bits(axi.awlen) != LEN_WIDTH)
      $fatal(1, "sequence_mem: interface parameter mismatch");
  end

  task automatic check_request(
    input longint unsigned addr,
    input int unsigned beats,
    input int unsigned size,
    input logic [1:0] burst
  );
    longint unsigned last_addr;
    if (burst !== 2'b01)
      $fatal(1, "sequence_mem: only INCR requests are supported");
    if (size > FULL_SIZE || (addr % (64'd1 << size)) != 0)
      $fatal(1, "sequence_mem: invalid/alignment request addr=%h size=%0d", addr, size);
    last_addr = addr + (longint'(beats) << size) - 1;
    if (last_addr >= (64'd1 << ADDR_WIDTH) || (addr >> 12) != (last_addr >> 12))
      $fatal(1, "sequence_mem: request overflows address width or crosses 4KB");
  endtask

  function automatic logic [DATA_WIDTH-1:0] read_beat(input request_t req);
    logic [DATA_WIDTH-1:0] result;
    longint unsigned addr, bus_base;
    int unsigned first_lane, transfer_bytes;
    addr = req.addr + (longint'(req.next_beat) << req.size);
    bus_base = (addr / BUS_BYTES) * BUS_BYTES;
    first_lane = addr % BUS_BYTES;
    transfer_bytes = 1 << req.size;
    // Deliberately poison unused lanes with ones: narrow-read checking must
    // extract the SIZE-selected bytes, not compare the whole RDATA vector.
    result = '1;
    for (int lane = 0; lane < BUS_BYTES; lane++) begin
      if (lane >= first_lane && lane < first_lane + transfer_bytes)
        result[8*lane +: 8] = memory.exists(bus_base + lane) ? memory[bus_base + lane] : 8'h00;
    end
    return result;
  endfunction

  // One process owns queues/storage/counters. Interface outputs are registered
  // with nonblocking assignments so the old VALID/READY values are sampled once.
  always @(posedge axi.aclk or negedge axi.aresetn) begin : memory_process
    request_t req;
    longint unsigned addr, bus_base;
    int unsigned first_lane, transfer_bytes;
    if (!axi.aresetn) begin
      aw_queue.delete();
      ar_queue.delete();
      b_queue.delete();
      memory.delete();
      aw_count = 0;
      ar_count = 0;
      w_count = 0;
      b_count = 0;
      r_count = 0;
      write_inflight = 0;
      read_inflight = 0;
      total_inflight = 0;
      write_peak = 0;
      read_peak = 0;
      total_peak = 0;
      cycle_count = 0;
      responses_open = 0;
      previous_gate = 0;
      axi.awready <= 0;
      axi.wready <= 0;
      axi.arready <= 0;
      axi.bvalid <= 0;
      axi.bid <= '0;
      axi.bresp <= 2'b00;
      axi.buser <= '0;
      axi.rvalid <= 0;
      axi.rid <= '0;
      axi.rdata <= '0;
      axi.rresp <= 2'b00;
      axi.ruser <= '0;
      axi.rlast <= 0;
    end else begin
      cycle_count++;

      if (axi.bvalid && axi.bready) begin
        if (write_inflight == 0)
          $fatal(1, "sequence_mem: unexpected B completion");
        b_count++;
        write_inflight--;
      end
      if (axi.rvalid && axi.rready) begin
        r_count++;
        if (axi.rlast) begin
          if (read_inflight == 0)
            $fatal(1, "sequence_mem: unexpected R completion");
          read_inflight--;
        end
      end

      if (axi.awvalid && axi.awready) begin
        req.id = axi.awid;
        req.addr = axi.awaddr;
        req.beats = int'(axi.awlen) + 1;
        req.size = int'(axi.awsize);
        req.next_beat = 0;
        check_request(req.addr, req.beats, req.size, axi.awburst);
        aw_queue.push_back(req);
        aw_count++;
        write_inflight++;
      end
      if (axi.arvalid && axi.arready) begin
        req.id = axi.arid;
        req.addr = axi.araddr;
        req.beats = int'(axi.arlen) + 1;
        req.size = int'(axi.arsize);
        req.next_beat = 0;
        check_request(req.addr, req.beats, req.size, axi.arburst);
        ar_queue.push_back(req);
        ar_count++;
        read_inflight++;
      end

      if (axi.wvalid && axi.wready) begin
        if (aw_queue.size() == 0)
          $fatal(1, "sequence_mem: accepted W without AW");
        req = aw_queue.pop_front();
        addr = req.addr + (longint'(req.next_beat) << req.size);
        bus_base = (addr / BUS_BYTES) * BUS_BYTES;
        first_lane = addr % BUS_BYTES;
        transfer_bytes = 1 << req.size;
        if (axi.wlast !== (req.next_beat == req.beats - 1))
          $fatal(1, "sequence_mem: WLAST mismatch beat=%0d beats=%0d", req.next_beat, req.beats);
        for (int lane = 0; lane < BUS_BYTES; lane++) begin
          if (axi.wstrb[lane] === 1'b1) begin
            if (lane < first_lane || lane >= first_lane + transfer_bytes)
              $fatal(1, "sequence_mem: WSTRB outside transfer lanes addr=%h lane=%0d", addr, lane);
            memory[bus_base + lane] = axi.wdata[8*lane +: 8];
          end else if (axi.wstrb[lane] !== 1'b0)
            $fatal(1, "sequence_mem: unknown WSTRB");
        end
        w_count++;
        req.next_beat++;
        if (req.next_beat == req.beats)
          b_queue.push_back(req.id);
        else
          aw_queue.push_front(req);
      end

      total_inflight = write_inflight + read_inflight;
      if (write_inflight > write_peak) write_peak = write_inflight;
      if (read_inflight > read_peak) read_peak = read_inflight;
      if (total_inflight > total_peak) total_peak = total_inflight;

      if (!gate_responses)
        responses_open = 1;
      else begin
        if (release_threshold < 1)
          $fatal(1, "sequence_mem: release_threshold must be positive while gating");
        if (!previous_gate)
          responses_open = (total_inflight >= release_threshold);
        else if (total_inflight == 0)
          responses_open = 0;
        else if (total_inflight >= release_threshold)
          responses_open = 1;
      end
      previous_gate = gate_responses;

      // Changing gate controls never withdraws a response already presented.
      if (!axi.bvalid || axi.bready) begin
        axi.bvalid <= 0;
        if (responses_open && b_queue.size() != 0 &&
            (!BACKPRESSURE || cycle_count % 5 != 1)) begin
          axi.bid <= b_queue.pop_front();
          axi.bresp <= 2'b00;
          axi.bvalid <= 1;
        end
      end
      if (!axi.rvalid || axi.rready) begin
        axi.rvalid <= 0;
        axi.rlast <= 0;
        if (responses_open && ar_queue.size() != 0 &&
            (!BACKPRESSURE || cycle_count % 7 != 2)) begin
          req = ar_queue.pop_front();
          axi.rid <= req.id;
          axi.rdata <= read_beat(req);
          axi.rresp <= 2'b00;
          axi.rlast <= (req.next_beat == req.beats - 1);
          axi.rvalid <= 1;
          req.next_beat++;
          if (req.next_beat < req.beats)
            ar_queue.push_front(req);
        end
      end

      axi.awready <= write_inflight < QUEUE_DEPTH &&
                     (!BACKPRESSURE || cycle_count % 7 != 0);
      axi.arready <= read_inflight < QUEUE_DEPTH &&
                     (!BACKPRESSURE || cycle_count % 5 != 0);
      axi.wready <= aw_queue.size() != 0 &&
                    (!BACKPRESSURE || cycle_count % 4 != 1);
    end
  end
endmodule
