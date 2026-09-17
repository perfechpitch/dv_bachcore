`timescale 1ns/1ps

// This tests the default demonstration RAM, not the separate 128-outstanding
// controlled slaves. No generated config/package or workbook is involved.
module simple_mem_top;
`ifdef SIMPLE_MEM_LEGACY
  localparam int DATA_WIDTH = 32;
  localparam int ID_WIDTH = 4;
  localparam int LEN_WIDTH = 8;
`else
  localparam int DATA_WIDTH = 256;
  localparam int ID_WIDTH = 8;
  localparam int LEN_WIDTH = 4;
`endif
  localparam int BYTES = DATA_WIDTH / 8;
  localparam int FULL_SIZE = $clog2(BYTES);
  localparam int DEPTH = 1024;
  bit clk = 0;
  bit rst_n = 0;
  always #0.5 clk = ~clk;
  axi4_if #(.DATA_WIDTH(DATA_WIDTH), .ID_WIDTH(ID_WIDTH), .LEN_WIDTH(LEN_WIDTH)) axi(clk, rst_n);
  axi4_simple_mem_slave #(.DATA_WIDTH(DATA_WIDTH), .ID_WIDTH(ID_WIDTH), .DEPTH(DEPTH)) dut(axi);
  byte unsigned reference_mem[DEPTH*BYTES];
  int aw_count, w_count, b_count, ar_count, r_count, last_count;
  int expected_writes, expected_wbeats, expected_reads, expected_rbeats;
  bit b_stalled, r_stalled;
  logic [ID_WIDTH+2:0] previous_b;
  logic [DATA_WIDTH+ID_WIDTH+3:0] previous_r;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      aw_count = 0; w_count = 0; b_count = 0;
      ar_count = 0; r_count = 0; last_count = 0;
      b_stalled <= 0; r_stalled <= 0;
    end else begin
      if (b_stalled && {axi.bvalid, axi.bid, axi.bresp} !== previous_b)
        $fatal(1, "B payload/valid changed under backpressure");
      if (r_stalled && {axi.rvalid, axi.rid, axi.rdata, axi.rresp, axi.rlast} !== previous_r)
        $fatal(1, "R payload/valid changed under backpressure");
      b_stalled <= axi.bvalid && !axi.bready;
      r_stalled <= axi.rvalid && !axi.rready;
      previous_b <= {axi.bvalid, axi.bid, axi.bresp};
      previous_r <= {axi.rvalid, axi.rid, axi.rdata, axi.rresp, axi.rlast};
      if (axi.awvalid && axi.awready) aw_count++;
      if (axi.wvalid && axi.wready) w_count++;
      if (axi.bvalid && axi.bready) b_count++;
      if (axi.arvalid && axi.arready) ar_count++;
      if (axi.rvalid && axi.rready) begin
        r_count++;
        if (axi.rlast) last_count++;
      end
      if (aw_count - b_count > 1 || ar_count - last_count > 1)
        $fatal(1, "demo accepted more than one outstanding per direction");
      if (axi.buser !== '0 || axi.ruser !== '0) $fatal(1, "response USER not tied off");
    end
  end

  function automatic logic [DATA_WIDTH-1:0] payload(input int seed, input int beat);
    logic [DATA_WIDTH-1:0] value;
    for (int lane = 0; lane < BYTES; lane++) value[8*lane +: 8] = (seed + beat*37 + lane*13) & 255;
    return value;
  endfunction

  function automatic logic [BYTES-1:0] strobes(input int address, input int size, input bit partial);
    logic [BYTES-1:0] mask = '0;
    for (int lane = 0; lane < BYTES; lane++)
      if (lane >= address%BYTES && lane < address%BYTES+(1<<size))
        mask[lane] = !partial || lane%2 == 0;
    return mask;
  endfunction

  function automatic logic [DATA_WIDTH-1:0] reference_word(input int address);
    logic [DATA_WIDTH-1:0] value;
    int base = (address / BYTES * BYTES) % (DEPTH*BYTES);
    for (int lane = 0; lane < BYTES; lane++) value[8*lane +: 8] = reference_mem[base+lane];
    return value;
  endfunction

  task automatic send_aw(input int address, input int beats, input int size, input int id,
                         input int burst = 1);
    @(negedge clk);
    axi.awaddr = address; axi.awlen = beats-1; axi.awsize = size;
    axi.awid = id; axi.awburst = burst; axi.awvalid = 1;
    do @(posedge clk); while (!axi.awready);
    @(negedge clk); axi.awvalid = 0;
  endtask

  task automatic send_ar(input int address, input int beats, input int size, input int id,
                         input int burst = 1);
    @(negedge clk);
    axi.araddr = address; axi.arlen = beats-1; axi.arsize = size;
    axi.arid = id; axi.arburst = burst; axi.arvalid = 1;
    do @(posedge clk); while (!axi.arready);
    @(negedge clk); axi.arvalid = 0;
  endtask

  task automatic send_wbeat(input logic [DATA_WIDTH-1:0] data,
                            input logic [BYTES-1:0] mask, input bit last);
    @(negedge clk); axi.wdata = data; axi.wstrb = mask; axi.wlast = last; axi.wvalid = 1;
    do @(posedge clk); while (!axi.wready);
    @(negedge clk); axi.wvalid = 0;
  endtask

  task automatic write_tx(input int address, input int beats, input int size, input int id,
                          input int seed, input bit partial = 0,
                          input int burst = 1, input bit expect_error = 0,
                          input bit bad_last = 0, input bit bad_strobe = 0);
    fork
      begin
        // Present W before AW: the slave must hold WREADY low until AW is captured.
        repeat (3) @(negedge clk);
        send_aw(address, beats, size, id, burst);
      end
      begin
        for (int beat = 0; beat < beats; beat++) begin
          automatic int current = address + beat*(1<<size);
          automatic logic [DATA_WIDTH-1:0] data = payload(seed, beat);
          automatic logic [BYTES-1:0] mask = strobes(current, size, partial);
          if (bad_strobe) mask = '1;
          send_wbeat(data, mask, bad_last ? 0 : beat == beats-1);
          if (!expect_error) begin
            for (int lane = 0; lane < BYTES; lane++)
              if (mask[lane]) reference_mem[(current/BYTES*BYTES + lane) % (DEPTH*BYTES)] = data[8*lane +: 8];
          end
          if (beat%3 == 1) repeat (2) @(negedge clk);
        end
      end
    join
    wait (axi.bvalid);
    repeat (5) @(posedge clk);
    if (axi.bid !== ID_WIDTH'(id) || axi.bresp !== (expect_error ? 2'b10 : 2'b00))
      $fatal(1, "B mismatch id=%h/%h resp=%b expected_error=%0d", axi.bid, ID_WIDTH'(id), axi.bresp, expect_error);
    if (axi.awready) $fatal(1, "AWREADY high while B response is held");
    @(negedge clk); axi.bready = 1;
    do @(posedge clk); while (!axi.bvalid);
    @(negedge clk); axi.bready = 0;
    expected_writes++; expected_wbeats += beats;
  endtask

  task automatic read_tx(input int address, input int beats, input int size, input int id,
                         input int burst = 1, input bit expect_error = 0);
    send_ar(address, beats, size, id, burst);
    for (int beat = 0; beat < beats; beat++) begin
      // Stall every beat for different lengths, including LAST.
      repeat (1 + beat%4) @(negedge clk);
      axi.rready = 1;
      do @(posedge clk); while (!axi.rvalid);
      if (axi.rid !== ID_WIDTH'(id) || axi.rlast !== (beat == beats-1) ||
          axi.rresp !== (expect_error ? 2'b10 : 2'b00) ||
          axi.rdata !== (expect_error ? DATA_WIDTH'(0) : reference_word(address + beat*(1<<size))))
        $fatal(1, "R mismatch beat=%0d id=%h/%h last=%b data=%h expected=%h resp=%b", beat, axi.rid, ID_WIDTH'(id), axi.rlast, axi.rdata, reference_word(address + beat*(1<<size)), axi.rresp);
      @(negedge clk); axi.rready = 0;
    end
    expected_reads++; expected_rbeats += beats;
  endtask

  task automatic continuous_burst(input int address, input int seed);
    int aw_before, w_before, b_before, ar_before, r_before, last_before;
    logic [DATA_WIDTH-1:0] data;
    @(negedge clk);
    aw_before = aw_count; w_before = w_count; b_before = b_count;
    ar_before = ar_count; r_before = r_count; last_before = last_count;
    send_aw(address, 16, FULL_SIZE, 'hab);
    // WVALID remains high for all sixteen adjacent sampling edges. Payload
    // changes only after a handshake, at the following falling edge.
    axi.wvalid = 1;
    axi.wstrb = '1;
    for (int beat = 0; beat < 16; beat++) begin
      data = payload(seed, beat);
      axi.wdata = data;
      axi.wlast = beat == 15;
      @(posedge clk);
      if (!axi.wready) $fatal(1, "continuous W burst unexpectedly stalled");
      for (int lane = 0; lane < BYTES; lane++)
        reference_mem[(address + beat*BYTES + lane) % (DEPTH*BYTES)] = data[8*lane +: 8];
      @(negedge clk);
      if (beat < 15 && axi.bvalid) $fatal(1, "continuous W burst produced early B");
    end
    axi.wvalid = 0;
    if (w_count - w_before != 16 || !axi.bvalid || axi.bid !== ID_WIDTH'('hab) || axi.bresp !== 2'b00)
      $fatal(1, "continuous W burst count/B mismatch");
    axi.bready = 1;
    @(posedge clk);
    @(negedge clk); axi.bready = 0;
    expected_writes++; expected_wbeats += 16;

    // READY is already high before AR and stays high through the LAST beat.
    axi.rready = 1;
    send_ar(address, 16, FULL_SIZE, 'hbc);
    for (int beat = 0; beat < 16; beat++) begin
      @(posedge clk);
      if (!axi.rvalid || axi.rid !== ID_WIDTH'('hbc) || axi.rresp !== 2'b00 ||
          axi.rlast !== (beat == 15) || axi.rdata !== reference_word(address + beat*BYTES))
        $fatal(1, "continuous R burst mismatch at beat %0d", beat);
      @(negedge clk);
    end
    axi.rready = 0;
    expected_reads++; expected_rbeats += 16;
    if (axi.rvalid || aw_count-aw_before != 1 || b_count-b_before != 1 ||
        ar_count-ar_before != 1 || r_count-r_before != 16 || last_count-last_before != 1)
      $fatal(1, "continuous burst extra/missing handshake");
    $display("SIMPLE_MEM_CONTINUOUS_PASS DATA=%0d W=16 R=16", DATA_WIDTH);
  endtask

  task automatic early_last_tx(input int address);
    int aw_before, w_before, b_before;
    @(negedge clk);
    aw_before = aw_count; w_before = w_count; b_before = b_count;
    send_aw(address, 4, FULL_SIZE, 'had);
    for (int beat = 0; beat < 4; beat++) begin
      send_wbeat(payload(233, beat), '1, beat == 0 || beat == 3);
      if (beat < 3) begin
        if (axi.bvalid || !axi.wready)
          $fatal(1, "early WLAST completed burst before all four W handshakes");
        repeat (2) begin
          @(posedge clk);
          if (axi.bvalid) $fatal(1, "early WLAST produced B while waiting for later W");
        end
      end
    end
    if (!axi.bvalid || axi.bid !== ID_WIDTH'('had) || axi.bresp !== 2'b10 || w_count-w_before != 4)
      $fatal(1, "early WLAST did not drain four beats then return SLVERR");
    repeat (3) @(posedge clk);
    @(negedge clk); axi.bready = 1;
    @(posedge clk);
    @(negedge clk); axi.bready = 0;
    expected_writes++; expected_wbeats += 4;
    if (aw_count-aw_before != 1 || b_count-b_before != 1)
      $fatal(1, "early WLAST caused duplicate address/response handshake");
    $display("SIMPLE_MEM_EARLY_LAST_PASS DATA=%0d drained=4 response=SLVERR", DATA_WIDTH);
  endtask

  task automatic check_counts;
    @(negedge clk);
    if (aw_count != expected_writes || b_count != expected_writes || w_count != expected_wbeats ||
        ar_count != expected_reads || last_count != expected_reads || r_count != expected_rbeats)
      $fatal(1, "handshake counts AW/W/B=%0d/%0d/%0d AR/R/LAST=%0d/%0d/%0d expected write=%0d/%0d read=%0d/%0d", aw_count, w_count, b_count, ar_count, r_count, last_count, expected_writes, expected_wbeats, expected_reads, expected_rbeats);
    $display("SIMPLE_MEM_COUNTS DATA=%0d AW=%0d W=%0d B=%0d AR=%0d R=%0d LAST=%0d", DATA_WIDTH, aw_count, w_count, b_count, ar_count, r_count, last_count);
  endtask

  initial begin
    axi.awvalid = 0; axi.awid = 0; axi.awaddr = 0; axi.awlen = 0; axi.awsize = 0;
    axi.awburst = 1; axi.awlock = 0; axi.awcache = 0; axi.awprot = 0;
    axi.awqos = 0; axi.awregion = 0; axi.awuser = 0;
    axi.wvalid = 0; axi.wdata = 0; axi.wstrb = 0; axi.wlast = 0; axi.wuser = 0; axi.bready = 0;
    axi.arvalid = 0; axi.arid = 0; axi.araddr = 0; axi.arlen = 0; axi.arsize = 0;
    axi.arburst = 1; axi.arlock = 0; axi.arcache = 0; axi.arprot = 0;
    axi.arqos = 0; axi.arregion = 0; axi.aruser = 0; axi.rready = 0;
    expected_writes = 0; expected_wbeats = 0; expected_reads = 0; expected_rbeats = 0;
    foreach (reference_mem[i]) reference_mem[i] = 0;
    repeat (3) @(negedge clk); rst_n = 1;
    for (int beats = 1; beats <= 16; beats *= 2) begin
      write_tx('h200, beats, FULL_SIZE, 'ha5, beats+17);
      read_tx('h200, beats, FULL_SIZE, 'h37);
      write_tx('h200, beats, FULL_SIZE, 'h5a, beats+39, 1);
      read_tx('h200, beats, FULL_SIZE, 'h93);
    end
    write_tx(0, 1<<LEN_WIDTH, FULL_SIZE, 'hef, 71);
    read_tx(0, 1<<LEN_WIDTH, FULL_SIZE, 'hcd);
    continuous_burst('h400, 203);
    // Nonzero byte lane and aligned word within a 256-bit line.
    write_tx('h800 + BYTES-1, 1, 0, 'h12, 95);
    read_tx('h800 + BYTES-1, 1, 0, 'h23);
    write_tx('h800 + BYTES-4, 1, 2, 'h34, 113, 1);
    read_tx('h800, 1, FULL_SIZE, 'h45);
    // Independent read/write engines, distinct addresses avoid RAM collision semantics.
    fork
      write_tx('hc00, 16, FULL_SIZE, 'h56, 131);
      read_tx('h200, 16, FULL_SIZE, 'h67);
    join
    read_tx('hc00, 16, FULL_SIZE, 'h78);
    // Invalid requests finish with SLVERR and cannot change memory.
    write_tx('h800, 1, FULL_SIZE, 'h81, 151, 0, 0, 1); // FIXED
    read_tx('h800, 1, FULL_SIZE, 'h82, 0, 1);
    write_tx('h800, 1, FULL_SIZE+1, 'h83, 157, 0, 1, 1); // oversize
    read_tx('h800, 1, FULL_SIZE+1, 'h84, 1, 1);
    write_tx('h801, 1, FULL_SIZE, 'h85, 163, 0, 1, 1); // unaligned
    read_tx('h801, 1, FULL_SIZE, 'h86, 1, 1);
    write_tx('h800, 2, 0, 'h87, 167, 0, 1, 1); // narrow burst
    read_tx('h800, 2, 0, 'h88, 1, 1);
    // Seed both affected lines with distinct data before attempting the
    // prohibited crossing; SLVERR alone would not prove memory preservation.
    write_tx('h1000-BYTES, 1, FULL_SIZE, 'h96, 211);
    write_tx('h1000, 1, FULL_SIZE, 'h97, 223);
    write_tx('h1000-BYTES, 2, FULL_SIZE, 'h89, 173, 0, 1, 1); // 4KB crossing
    read_tx('h1000-BYTES, 2, FULL_SIZE, 'h8a, 1, 1);
    read_tx('h1000-BYTES, 1, FULL_SIZE, 'h98);
    read_tx('h1000, 1, FULL_SIZE, 'h99);
    $display("SIMPLE_MEM_4KB_PRESERVED_PASS DATA=%0d checked_lines=2", DATA_WIDTH);
    write_tx('h800, 1, FULL_SIZE, 'h8b, 179, 0, 1, 1, 1); // absent WLAST
    write_tx('h801, 1, 0, 'h8c, 181, 0, 1, 1, 0, 1); // lanes outside narrow transfer
    read_tx('h800, 1, FULL_SIZE, 'h8d);
    write_tx('ha00, 4, FULL_SIZE, 'ha1, 227);
    early_last_tx('ha00);
    read_tx('ha00, 4, FULL_SIZE, 'ha2);
    check_counts();

    // Reset aborts both an incomplete W burst and a held B response, together
    // with a stalled R response. RAM clears and all channels can be reused.
    for (int pending_b = 0; pending_b < 2; pending_b++) begin
      send_aw('h800, pending_b ? 1 : 4, FULL_SIZE, 'h91);
      send_wbeat('1, '1, pending_b != 0);
      if (pending_b && !axi.bvalid) $fatal(1, "missing pending B for reset test");
      send_ar('h800, 4, FULL_SIZE, 'h92);
      wait (axi.rvalid);
      @(negedge clk); rst_n = 0;
      #0.01;
      if (axi.bvalid || axi.rvalid || axi.awready || axi.wready || axi.arready)
        $fatal(1, "reset did not clear/gate slave channels");
      repeat (3) @(negedge clk);
      foreach (reference_mem[i]) reference_mem[i] = 0;
      expected_writes = 0; expected_wbeats = 0; expected_reads = 0; expected_rbeats = 0;
      rst_n = 1;
    end
    read_tx('h800, 4, FULL_SIZE, 'h93);
    write_tx('h800, 4, FULL_SIZE, 'h94, 199);
    read_tx('h800, 4, FULL_SIZE, 'h95);
    check_counts();
    $display("SIMPLE_MEM_PASS DATA=%0d ID=%0d LEN=%0d max_beats=%0d", DATA_WIDTH, ID_WIDTH, LEN_WIDTH, 1<<LEN_WIDTH);
    $finish;
  end

  initial begin
    #200000;
    $fatal(1, "simple memory test timeout");
  end
endmodule
