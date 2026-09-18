`timescale 1ns/1ps
// Self-check of the controlled endpoint using direct signal drivers. This
// test never instantiates a VIP adapter and is NOT evidence of VIP bandwidth.
// Open: continuous W/R for 256 measured cycles, 64 bursts of 16 beats.
// Stress: 2/4 W/R production slots, one RREADY stall in seven cycles, and
// BREADY withheld through cycle 99. All queued responses must still retire.
module slave_unit_top;
  bit clk = 0;
  bit rstn = 0;
  always #0.5 clk = !clk;
  axi4_if #(
    .ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4),
    .QOS_WIDTH(0), .REGION_WIDTH(0)
  ) axi(clk, rstn);
  int unsigned period = 0, open_slots = 0;
  longint unsigned awc, arc, wc, rc, bc;
  axi4_perf_slave dut(axi, period, open_slots, awc, arc, wc, rc, bc);
  int rb = 0, bb = 0, cyc = 0, window_w = 0, window_r = 0;
  int b_stalls = 0, r_stalls = 0;
  bit stress;
  bit old_b_stall = 0, old_r_stall = 0;
  logic [7:0] old_bid, old_rid;
  logic [255:0] old_rdata;
  bit old_rlast;
  logic [255:0] expected;
  realtime last_clk = 0.0;

  initial begin
    stress = $test$plusargs("STRESS");
    if (stress) begin period = 4; open_slots = 2; end
    axi.awvalid = 0; axi.wvalid = 0; axi.arvalid = 0;
    axi.awid = 0; axi.awaddr = 0; axi.awlen = 15;
    axi.awsize = 5; axi.awburst = 1;
    axi.awlock = 0; axi.awcache = 0; axi.awprot = 0;
    axi.awqos = 0; axi.awregion = 0; axi.awuser = 0;
    axi.wdata = 0; axi.wstrb = '1; axi.wlast = 0; axi.wuser = 0;
    axi.arid = 0; axi.araddr = 0; axi.arlen = 15;
    axi.arsize = 5; axi.arburst = 1;
    axi.arlock = 0; axi.arcache = 0; axi.arprot = 0;
    axi.arqos = 0; axi.arregion = 0; axi.aruser = 0;
    axi.bready = 0; axi.rready = 0;
    repeat (4) @(negedge clk);
    rstn = 1;
    fork
      begin
        for (int a = 0; a < 64; a++) begin
          @(negedge clk);
          axi.awvalid = 1; axi.awid = a; axi.awaddr = 'h1000 + a*512;
          do @(posedge clk); while (!axi.awready);
        end
        @(negedge clk); axi.awvalid = 0;
      end
      begin
        for (int a = 0; a < 1024; a++) begin
          @(negedge clk);
          axi.wvalid = 1; axi.wlast = (a%16 == 15); axi.wdata = a;
          do @(posedge clk); while (!axi.wready);
        end
        @(negedge clk); axi.wvalid = 0;
      end
      begin
        for (int a = 0; a < 64; a++) begin
          @(negedge clk);
          axi.arvalid = 1; axi.arid = a; axi.araddr = 'h20000 + a*512;
          do @(posedge clk); while (!axi.arready);
        end
        @(negedge clk); axi.arvalid = 0;
      end
    join
    wait (rb == 1024 && bb == 64);
    @(negedge clk);
    if (awc != 64 || arc != 64 || wc != 1024 || rc != 1024 || bc != 64)
      $fatal(1, "SLAVE_UNIT counter mismatch aw=%0d ar=%0d w=%0d r=%0d b=%0d",
             awc, arc, wc, rc, bc);
    if (!stress && (window_w != 256 || window_r != 256))
      $fatal(1, "SLAVE_UNIT not saturated w=%0d r=%0d", window_w, window_r);
    if (stress && (window_w != 128 || window_r >= 128 || window_r < 85))
      $fatal(1, "SLAVE_UNIT bad throttle w=%0d r=%0d", window_w, window_r);
    if (stress && (b_stalls == 0 || r_stalls == 0))
      $fatal(1, "SLAVE_UNIT response backpressure was not exercised");
    $display("PERF_SLAVE_UNIT_PASS vip_api_used=0 stress=%0d period_ns=1.000 window_cycles=256 W=%0d R=%0d aw=%0d ar=%0d w=%0d r=%0d b=%0d b_stalls=%0d r_stalls=%0d",
             stress, window_w, window_r, awc, arc, wc, rc, bc, b_stalls, r_stalls);
    $finish;
  end

  always @(negedge clk) if (rstn) begin
    axi.bready = (!stress || cyc >= 100);
    axi.rready = (!stress || cyc%7 != 0);
  end

  always @(posedge clk) if (rstn) begin
    if (last_clk != 0.0 && $realtime - last_clk != 1.0)
      $fatal(1, "SLAVE_UNIT clock period");
    last_clk = $realtime;
    if (old_b_stall && (axi.bvalid !== 1 || axi.bid !== old_bid))
      $fatal(1, "SLAVE_UNIT B hold");
    if (old_r_stall && (axi.rvalid !== 1 || axi.rid !== old_rid ||
        axi.rdata !== old_rdata || axi.rlast !== old_rlast))
      $fatal(1, "SLAVE_UNIT R hold");
    old_b_stall = axi.bvalid && !axi.bready;
    old_r_stall = axi.rvalid && !axi.rready;
    if (old_b_stall) b_stalls++;
    if (old_r_stall) r_stalls++;
    old_bid = axi.bid; old_rid = axi.rid;
    old_rdata = axi.rdata; old_rlast = axi.rlast;
    if (axi.rvalid && axi.rready) begin
      for (int lane = 0; lane < 32; lane++) begin
        int unsigned byte_addr;
        byte_addr = 'h20000 + rb*32 + lane;
        expected[8*lane +: 8] = byte_addr[7:0] ^ byte_addr[15:8] ^
                               byte_addr[23:16] ^ byte_addr[31:24] ^ 8'ha5;
      end
      if (axi.rid !== (rb/16) || axi.rlast !== (rb%16 == 15) ||
          axi.rdata !== expected || axi.rresp !== 0 || axi.ruser !== 0)
        $fatal(1, "SLAVE_UNIT R payload rb=%0d rid=%0d rlast=%0d",
               rb, axi.rid, axi.rlast);
      rb++;
    end
    if (axi.bvalid && axi.bready) begin
      if (axi.bid !== bb || axi.bresp !== 0 || axi.buser !== 0)
        $fatal(1, "SLAVE_UNIT B payload expected_id=%0d got_id=%0d", bb, axi.bid);
      bb++;
    end
    if (cyc >= 200 && cyc < 456) begin
      if (axi.wvalid && axi.wready) window_w++;
      if (axi.rvalid && axi.rready) window_r++;
    end
    cyc++;
  end

  initial begin #10000; $fatal(1, "SLAVE_UNIT timeout"); end
endmodule
