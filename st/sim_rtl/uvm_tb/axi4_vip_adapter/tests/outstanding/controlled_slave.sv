// Test-only AXI slave: address queues, ordered W, same-ID ordering, reordered
// cross-ID responses and beat-interleaved reads. No production top dependency.
module outstanding_controlled_slave #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 256,
  parameter int ID_WIDTH = 8
) (axi4_if.slave axi);
  localparam int BYTE_LANES = DATA_WIDTH / 8;
  typedef bit [ADDR_WIDTH-1:0] addr_t;
  typedef logic [DATA_WIDTH-1:0] data_t;

  class request;
    bit [ID_WIDTH-1:0] id;
    addr_t addr;
    int unsigned beats, size, transferred, serial;
  endclass
  typedef struct packed {
    data_t data;
    logic [BYTE_LANES-1:0] strb;
    logic last;
  } write_beat;

  request writes[$], reads[$];
  write_beat early_w[$];
  data_t memory[addr_t];
  request active_b, active_r;
  bit b_active, r_active;
  bit aw_was_stalled, w_was_stalled, ar_was_stalled;
  logic [ID_WIDTH+ADDR_WIDTH+8+3+2-1:0] saved_aw, saved_ar;
  logic [DATA_WIDTH+BYTE_LANES:0] saved_w;
  bit [ID_WIDTH-1:0] previous_rid;
  int unsigned serial_number, cycle;

  // Set by the test at negedge + 1ps, away from monitor sampling/driving.
  bit hold_b = 1, hold_r = 1;
  bit block_aw, block_w, block_ar;
  bit independent_stalls = 1;
  bit awready_requires_wvalid;
  bit check_write_pattern = 1;
  bit reverse_ids = 1, interleave_reads = 1;
  int unsigned read_limit = 128, write_limit = 128, total_limit = 128;
  // 1: unexpected BID; 2: unexpected RID; 3: early RLAST; 4: missing RLAST;
  // 5: B before the write data has completed.
  int unsigned fault_mode;
  logic [1:0] forced_bresp = 2'b00, forced_rresp = 2'b00;
  int response_error_beat = -1;
  bit address_bresp;

  // These counters are derived exclusively from bus handshakes, never the API.
  int unsigned aw_count, w_count, b_count, ar_count, r_count, rlast_count;
  int unsigned read_descriptor_completions;
  int unsigned live_reads, live_writes, peak_reads, peak_writes, peak_total;
  int unsigned out_of_order_b, out_of_order_r, interleaved_r;
  int unsigned aw_stall_cycles, w_stall_cycles, ar_stall_cycles;
  int unsigned w_before_aw_count;
  int unsigned reset_count;

  function automatic data_t pattern(input addr_t addr, input int unsigned beat);
    data_t result;
    for (int lane = 0; lane < BYTE_LANES; lane++)
      result[8*lane +: 8] = (addr >> ((lane % 4) * 8)) ^
                           (beat * 8'h3d) ^ (lane * 8'h17) ^ 8'ha5;
    return result;
  endfunction

  function automatic logic [BYTE_LANES-1:0] strobe_pattern(input int unsigned beat);
    logic [BYTE_LANES-1:0] result;
    for (int lane = 0; lane < BYTE_LANES; lane++)
      result[lane] = ((lane + beat) % 3 != 0);
    return result;
  endfunction

  function automatic logic [1:0] bresp_pattern(input addr_t addr);
    case ((addr >> 9) % 3)
      0: return 2'b00;
      1: return 2'b10;
      default: return 2'b11;
    endcase
  endfunction

  function automatic int choose_write();
    int chosen;
    bit eligible;
    chosen = -1;
    foreach (writes[i]) begin
      eligible = fault_mode == 5 || writes[i].transferred == writes[i].beats;
      for (int j = 0; j < i; j++)
        if (writes[j].id == writes[i].id) eligible = 0;
      if (eligible && (chosen < 0 || reverse_ids)) chosen = i;
    end
    return chosen;
  endfunction

  function automatic int choose_read();
    int chosen;
    bit eligible;
    chosen = -1;
    foreach (reads[i]) begin
      eligible = 1;
      for (int j = 0; j < i; j++)
        if (reads[j].id == reads[i].id) eligible = 0;
      if (eligible) begin
        if (chosen < 0) chosen = i;
        else if (interleave_reads && reads[chosen].id == previous_rid &&
                 reads[i].id != previous_rid) chosen = i;
        else if ((!interleave_reads || reads[i].id != previous_rid) && reverse_ids)
          chosen = i;
      end
    end
    return chosen;
  endfunction

  task clear_epoch();
    writes.delete(); reads.delete(); early_w.delete(); memory.delete();
    active_b = null; active_r = null;
    b_active = 0; r_active = 0;
    aw_was_stalled = 0; w_was_stalled = 0; ar_was_stalled = 0;
    aw_count = 0; w_count = 0; b_count = 0;
    ar_count = 0; r_count = 0; rlast_count = 0;
    read_descriptor_completions = 0;
    live_reads = 0; live_writes = 0;
    peak_reads = 0; peak_writes = 0; peak_total = 0;
    out_of_order_b = 0; out_of_order_r = 0; interleaved_r = 0;
    aw_stall_cycles = 0; w_stall_cycles = 0; ar_stall_cycles = 0;
    w_before_aw_count = 0;
    previous_rid = '0;
    serial_number = 0; cycle = 0;
  endtask

  initial begin
    clear_epoch();
    axi.awready = 0; axi.wready = 0; axi.arready = 0;
    axi.bvalid = 0; axi.bid = 0; axi.bresp = 0;
    axi.buser = '0; axi.ruser = '0;
    axi.rvalid = 0; axi.rid = 0; axi.rresp = 0;
    axi.rdata = 0; axi.rlast = 0;
  end

  always @(negedge axi.aresetn) begin
    reset_count++;
    clear_epoch();
    axi.awready = 0; axi.wready = 0; axi.arready = 0;
    axi.bvalid = 0; axi.rvalid = 0; axi.rlast = 0;
  end

  // Sample each channel exactly once at its transfer edge. Retire first so a
  // completion and replacement address on the same edge do not inflate peaks.
  always @(posedge axi.aclk) begin : sample
    request req;
    write_beat wb;
    addr_t word_addr;
    data_t old_word;
    int first_w;
    if (axi.aresetn) begin
      cycle++;
      if (aw_was_stalled && (!axi.awvalid ||
          {axi.awid, axi.awaddr, 8'(axi.awlen), axi.awsize, axi.awburst} !== saved_aw))
        $fatal(1, "SLAVE AW changed while stalled");
      if (w_was_stalled && (!axi.wvalid || {axi.wdata, axi.wstrb, axi.wlast} !== saved_w))
        $fatal(1, "SLAVE W changed while stalled");
      if (ar_was_stalled && (!axi.arvalid ||
          {axi.arid, axi.araddr, 8'(axi.arlen), axi.arsize, axi.arburst} !== saved_ar))
        $fatal(1, "SLAVE AR changed while stalled");
      aw_was_stalled = axi.awvalid && !axi.awready;
      w_was_stalled = axi.wvalid && !axi.wready;
      ar_was_stalled = axi.arvalid && !axi.arready;
      saved_aw = {axi.awid, axi.awaddr, 8'(axi.awlen), axi.awsize, axi.awburst};
      saved_w = {axi.wdata, axi.wstrb, axi.wlast};
      saved_ar = {axi.arid, axi.araddr, 8'(axi.arlen), axi.arsize, axi.arburst};
      if (axi.bvalid && axi.bready) begin
        if (!b_active || active_b == null) $fatal(1, "SLAVE B without descriptor");
        b_count++;
        if (live_writes == 0) $fatal(1, "SLAVE B underflow");
        live_writes--;
        foreach (writes[i]) if (writes[i] == active_b) begin
          if (i != 0) out_of_order_b++;
          writes.delete(i);
          break;
        end
        b_active = 0;
      end
      if (axi.rvalid && axi.rready) begin
        if (!r_active || active_r == null) $fatal(1, "SLAVE R without descriptor");
        r_count++;
        if (axi.rlast) rlast_count++;
        if (r_count > 1 && previous_rid != active_r.id && active_r.transferred > 0)
          interleaved_r++;
        previous_rid = active_r.id;
        active_r.transferred++;
        // Expected completion uses descriptor length, preserving diagnostic
        // counters when an intentional malformed RLAST is injected.
        if (active_r.transferred == active_r.beats) begin
          read_descriptor_completions++;
          if (live_reads == 0) $fatal(1, "SLAVE R underflow");
          live_reads--;
          foreach (reads[i]) if (reads[i] == active_r) begin
            if (i != 0) out_of_order_r++;
            reads.delete(i);
            break;
          end
        end
        r_active = 0;
      end
      if (axi.awvalid && !axi.awready) aw_stall_cycles++;
      if (axi.wvalid && !axi.wready) w_stall_cycles++;
      if (axi.arvalid && !axi.arready) ar_stall_cycles++;
      if (axi.awvalid && axi.awready) begin
        req = new();
        req.id = axi.awid; req.addr = axi.awaddr;
        req.beats = int'(axi.awlen) + 1; req.size = axi.awsize;
        req.serial = serial_number++;
        writes.push_back(req); aw_count++; live_writes++;
        if (axi.awburst !== 2'b01 || axi.awsize != $clog2(BYTE_LANES))
          $fatal(1, "SLAVE accepts only full-width INCR test traffic");
      end
      if (axi.arvalid && axi.arready) begin
        req = new();
        req.id = axi.arid; req.addr = axi.araddr;
        req.beats = int'(axi.arlen) + 1; req.size = axi.arsize;
        req.serial = serial_number++;
        reads.push_back(req); ar_count++; live_reads++;
        if (axi.arburst !== 2'b01 || axi.arsize != $clog2(BYTE_LANES))
          $fatal(1, "SLAVE accepts only full-width INCR test traffic");
      end
      if (axi.wvalid && axi.wready) begin
        wb.data = axi.wdata; wb.strb = axi.wstrb; wb.last = axi.wlast;
        early_w.push_back(wb); w_count++;
        first_w = -1;
        foreach (writes[i])
          if (first_w < 0 && writes[i].transferred < writes[i].beats) first_w = i;
        if (first_w < 0) w_before_aw_count++;
      end
      // AXI4 has no WID. Buffer early W and associate strictly in AW order.
      while (early_w.size() != 0) begin
        first_w = -1;
        foreach (writes[i])
          if (first_w < 0 && writes[i].transferred < writes[i].beats) first_w = i;
        if (first_w < 0) break;
        req = writes[first_w];
        wb = early_w.pop_front();
        if (wb.last !== (req.transferred == req.beats - 1))
          $fatal(1, "SLAVE WLAST mismatch addr=%h beat=%0d/%0d", req.addr, req.transferred, req.beats);
        if (check_write_pattern && (wb.data !== pattern(req.addr, req.transferred) ||
                                   wb.strb !== strobe_pattern(req.transferred)))
          $fatal(1, "SLAVE W payload/order/strobe mismatch addr=%h beat=%0d", req.addr, req.transferred);
        word_addr = req.addr + (req.transferred << req.size);
        old_word = memory.exists(word_addr) ? memory[word_addr] : '0;
        for (int lane = 0; lane < BYTE_LANES; lane++)
          if (wb.strb[lane]) old_word[8*lane +: 8] = wb.data[8*lane +: 8];
        memory[word_addr] = old_word;
        req.transferred++;
      end
      if (live_reads > read_limit || live_writes > write_limit ||
          live_reads + live_writes > total_limit)
        $fatal(1, "SLAVE actual outstanding limit exceeded R=%0d/%0d W=%0d/%0d total=%0d/%0d",
          live_reads, read_limit, live_writes, write_limit,
          live_reads + live_writes, total_limit);
      if (live_reads > peak_reads) peak_reads = live_reads;
      if (live_writes > peak_writes) peak_writes = live_writes;
      if (live_reads + live_writes > peak_total) peak_total = live_reads + live_writes;
    end
  end

  always @(negedge axi.aclk) begin : drive
    int chosen;
    addr_t word_addr;
    if (axi.aresetn) begin
      // Keep the dependency satisfied if W was accepted before this drive edge.
      axi.awready = !block_aw && (!awready_requires_wvalid || axi.wvalid || early_w.size() != 0) &&
                    (!independent_stalls || cycle % 7 != 2);
      axi.wready = !block_w && (!independent_stalls || cycle % 5 != 1);
      axi.arready = !block_ar && (!independent_stalls || cycle % 11 != 3);
      if (!b_active && !hold_b) begin
        chosen = choose_write();
        if (chosen >= 0 && (!independent_stalls || cycle % 3 != 0)) begin
          active_b = writes[chosen]; b_active = 1;
          axi.bid = fault_mode == 1 ? '1 : active_b.id;
          axi.bresp = address_bresp ? bresp_pattern(active_b.addr) : forced_bresp;
        end
      end
      axi.bvalid = b_active;
      if (!r_active && !hold_r) begin
        chosen = choose_read();
        if (chosen >= 0 && (!independent_stalls || cycle % 4 != 0)) begin
          active_r = reads[chosen]; r_active = 1;
          axi.rid = fault_mode == 2 ? '1 : active_r.id;
          word_addr = active_r.addr + (active_r.transferred << active_r.size);
          axi.rdata = memory.exists(word_addr) ? memory[word_addr] :
                      pattern(active_r.addr, active_r.transferred);
          axi.rresp = response_error_beat < 0 ||
                      active_r.transferred == response_error_beat ? forced_rresp : 2'b00;
          axi.rlast = fault_mode == 3 ? 1 :
                      fault_mode == 4 ? 0 : active_r.transferred == active_r.beats - 1;
        end
      end
      axi.rvalid = r_active;
      if (!r_active) axi.rlast = 0;
    end
  end

  task report(input string label_text);
    $display("BUS_EVIDENCE %s AW=%0d W=%0d B=%0d AR=%0d R=%0d RLAST=%0d liveR=%0d liveW=%0d peakR=%0d peakW=%0d peakTotal=%0d reorderedB=%0d reorderedR=%0d interleavedR=%0d stallsAW=%0d stallsW=%0d stallsAR=%0d earlyW=%0d expectedReadCompletions=%0d",
      label_text, aw_count, w_count, b_count, ar_count, r_count, rlast_count,
      live_reads, live_writes, peak_reads, peak_writes, peak_total,
      out_of_order_b, out_of_order_r, interleaved_r,
      aw_stall_cycles, w_stall_cycles, ar_stall_cycles, w_before_aw_count,
      read_descriptor_completions);
  endtask
endmodule
