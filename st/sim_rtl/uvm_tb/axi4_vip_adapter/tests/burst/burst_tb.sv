// Feature 02: controlled-slave functional tests, independent of production top.
// 16 beats exercise LEN4 encoding; no business burst maximum is assumed.
package burst_tb_support_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class burst_expected_reports extends uvm_report_catcher;
    string case_name;
    string fatal_id;
    string fatal_token;
    bit allow_response_errors;
    string expected_error_id;
    string expected_error_token;
    int expected_error_limit;
    int expected_error_seen;
    int fatal_error_count;
    int response_errors;
    int protocol_errors;
    int unexpected_errors;

    function new(string name = "burst_expected_reports");
      super.new(name);
    endfunction

    virtual function action_e catch();
      if (get_severity() == UVM_FATAL && fatal_id != "" && unexpected_errors == 0 &&
          expected_error_seen == fatal_error_count &&
          get_id() == fatal_id && get_message() == fatal_token) begin
        $display("EXPECTED_FATAL %s id=%s message=%s", case_name,
                 get_id(), get_message());
        return THROW; // Preserve actual fatal termination; runner checks marker.
      end
      if (get_severity() == UVM_ERROR) begin
        if (allow_response_errors && get_id() == "AXI_RESPONSE") begin
          response_errors++;
          $display("EXPECTED_ERROR %s %s", get_id(), get_message());
          return CAUGHT;
        end
        if (expected_error_seen < expected_error_limit &&
            get_id() == expected_error_id && get_message() == expected_error_token) begin
          expected_error_seen++;
          if (get_id() == "AXI_BFM_PROTOCOL") protocol_errors++;
          $display("EXPECTED_ERROR %s %s", get_id(), get_message());
          return CAUGHT;
        end
        unexpected_errors++;
      end
      return THROW;
    endfunction
  endclass
endpackage

module burst_tb;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;
  import burst_tb_support_pkg::*;

  bit clk = 0;
  bit reset_n = 0;
  always #0.5ns clk = ~clk;

  axi4_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH),
    .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
    .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
    .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH),
    .BUSER_WIDTH(AXI_BUSER_WIDTH)
  ) axi(clk, reset_n);

  burst_test_slave #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH(AXI_ID_WIDTH)
  ) slave(axi);

  simple_axi4_bfm_adapter adapter;
  burst_expected_reports reports;
  string case_name;
  axi4_burst_request expected_write;
  axi4_burst_request expected_read;
  int expected_w_beat;
  int expected_r_beat;
  int observed_aw;
  int observed_ar;
  byte unsigned expected_mem[int unsigned];
  bit check_read_payload = 1;

  localparam int AW_PAYLOAD_BITS = AXI_ID_WIDTH + AXI_ADDR_WIDTH + AXI_LEN_WIDTH + 3 + 2 + 1;
  localparam int W_PAYLOAD_BITS = AXI_DATA_WIDTH + AXI_STRB_WIDTH + 1;
  localparam int B_PAYLOAD_BITS = AXI_ID_WIDTH + 2;
  localparam int R_PAYLOAD_BITS = AXI_ID_WIDTH + AXI_DATA_WIDTH + 2 + 1;
  bit aw_stalled, w_stalled, ar_stalled, b_stalled, r_stalled;
  logic [AW_PAYLOAD_BITS-1:0] prior_aw, prior_ar;
  logic [W_PAYLOAD_BITS-1:0] prior_w;
  logic [B_PAYLOAD_BITS-1:0] prior_b;
  logic [R_PAYLOAD_BITS-1:0] prior_r;

  task automatic require(input bit condition, input string message);
    if (!condition) $fatal(1, "TEST_CHECK_FAILED %s: %s", case_name, message);
  endtask

  // The scoreboard samples actual handshakes, independently of API return times.
  // Memory locations are bus-word base + lane; this does not reuse lane_mask().
  always @(posedge clk) begin : observe_bus
    int unsigned byte_address;
    int unsigned transfer_address;
    int unsigned bus_address;
    int unsigned lane;
    int unsigned transfer_bytes;
    byte unsigned wanted;
    if (!reset_n) begin
      aw_stalled = 0;
      w_stalled = 0;
      ar_stalled = 0;
      b_stalled = 0;
      r_stalled = 0;
    end else begin
      if (aw_stalled)
        require(axi.awvalid === 1'b1 &&
                {axi.awid,axi.awaddr,axi.awlen,axi.awsize,axi.awburst,axi.awlock} === prior_aw,
                "AW payload/VALID changed while stalled");
      if (w_stalled)
        require(axi.wvalid === 1'b1 && {axi.wdata,axi.wstrb,axi.wlast} === prior_w,
                "W payload/VALID changed while stalled");
      if (ar_stalled)
        require(axi.arvalid === 1'b1 &&
                {axi.arid,axi.araddr,axi.arlen,axi.arsize,axi.arburst,axi.arlock} === prior_ar,
                "AR payload/VALID changed while stalled");
      if (b_stalled)
        require(axi.bvalid === 1'b1 && {axi.bid,axi.bresp} === prior_b,
                "Slave B payload/VALID changed while stalled");
      if (r_stalled)
        require(axi.rvalid === 1'b1 && {axi.rid,axi.rdata,axi.rresp,axi.rlast} === prior_r,
                "Slave R payload/VALID changed while stalled");

      aw_stalled = axi.awvalid === 1'b1 && axi.awready !== 1'b1;
      w_stalled = axi.wvalid === 1'b1 && axi.wready !== 1'b1;
      ar_stalled = axi.arvalid === 1'b1 && axi.arready !== 1'b1;
      b_stalled = axi.bvalid === 1'b1 && axi.bready !== 1'b1;
      r_stalled = axi.rvalid === 1'b1 && axi.rready !== 1'b1;
      prior_aw = {axi.awid,axi.awaddr,axi.awlen,axi.awsize,axi.awburst,axi.awlock};
      prior_w = {axi.wdata,axi.wstrb,axi.wlast};
      prior_ar = {axi.arid,axi.araddr,axi.arlen,axi.arsize,axi.arburst,axi.arlock};
      prior_b = {axi.bid,axi.bresp};
      prior_r = {axi.rid,axi.rdata,axi.rresp,axi.rlast};

      if (axi.awvalid === 1'b1 && axi.awready === 1'b1) begin
        require(expected_write != null, "Unexpected AW handshake");
        observed_aw++;
        require(observed_aw == 1, "Duplicate AW handshake");
        require(axi.awid === expected_write.id && axi.awaddr === expected_write.addr &&
                axi.awlen == expected_write.beat_count - 1 &&
                axi.awsize == expected_write.size && axi.awburst == expected_write.burst &&
                axi.awlock == expected_write.lock, "Incorrect AW fields");
      end
      if (axi.wvalid === 1'b1 && axi.wready === 1'b1) begin
        require(expected_write != null, "Unexpected W handshake");
        require(expected_w_beat < expected_write.beat_count, "Extra W handshake");
        require(axi.wdata === expected_write.data[expected_w_beat], "W data mismatch, including high bits");
        require(axi.wstrb === expected_write.strb[expected_w_beat], "WSTRB mismatch");
        require(axi.wlast === (expected_w_beat == expected_write.beat_count - 1), "Incorrect WLAST");
        transfer_address = expected_write.addr + expected_w_beat * (1 << expected_write.size);
        bus_address = (transfer_address / AXI_STRB_WIDTH) * AXI_STRB_WIDTH;
        for (int j = 0; j < AXI_STRB_WIDTH; j++) begin
          if (axi.wstrb[j] === 1'b1) begin
            byte_address = bus_address + j;
            expected_mem[byte_address] = axi.wdata[8*j +: 8];
          end
        end
        expected_w_beat++;
      end
      if (axi.arvalid === 1'b1 && axi.arready === 1'b1) begin
        require(expected_read != null, "Unexpected AR handshake");
        observed_ar++;
        require(observed_ar == 1, "Duplicate AR handshake");
        require(axi.arid === expected_read.id && axi.araddr === expected_read.addr &&
                axi.arlen == expected_read.beat_count - 1 &&
                axi.arsize == expected_read.size && axi.arburst == expected_read.burst &&
                axi.arlock == expected_read.lock, "Incorrect AR fields");
      end
      if (axi.rvalid === 1'b1 && axi.rready === 1'b1) begin
        require(expected_read != null, "Unexpected R handshake");
        require(expected_r_beat < expected_read.beat_count, "Extra R handshake");
        transfer_bytes = 1 << expected_read.size;
        transfer_address = expected_read.addr + expected_r_beat * transfer_bytes;
        lane = transfer_address % AXI_STRB_WIDTH;
        if (check_read_payload) begin
          for (int j = 0; j < transfer_bytes; j++) begin
            byte_address = transfer_address + j;
            wanted = expected_mem.exists(byte_address) ? expected_mem[byte_address] : 8'h00;
            require(axi.rdata[8*(lane+j) +: 8] === wanted,
                    $sformatf("R byte mismatch addr=%08x lane=%0d expected=%02x got=%02x",
                              byte_address, lane+j, wanted, axi.rdata[8*(lane+j) +: 8]));
          end
        end
        expected_r_beat++;
      end
    end
  end

  function automatic axi4_burst_request request(
    input int unsigned address, input int unsigned beats,
    input int unsigned transfer_size = 5, input int unsigned id = 'he7
  );
    axi4_burst_request result = new("request");
    result.addr = address;
    result.id = id;
    result.beat_count = beats;
    result.size = transfer_size;
    result.burst = 1;
    result.lock = 0;
    result.check_response = 1;
    result.data = new[beats];
    result.strb = new[beats];
    foreach (result.data[k]) begin
      for (int j = 0; j < AXI_STRB_WIDTH; j++)
        result.data[k][8*j +: 8] = 8'ha5 ^ (17*k+j);
      result.strb[k] = '1;
    end
    return result;
  endfunction

  task automatic expect_write(input axi4_burst_request req);
    expected_write = req;
    expected_w_beat = 0;
    observed_aw = 0;
  endtask

  task automatic expect_read(input axi4_burst_request req);
    expected_read = req;
    expected_r_beat = 0;
    observed_ar = 0;
  endtask

  task automatic write_transaction(input axi4_burst_request req, output axi4_burst_response rsp);
    int old_aw = slave.aw_count;
    int old_w = slave.w_count;
    int old_b = slave.b_count;
    expect_write(req);
    adapter.axi_write_burst(req, rsp);
    @(negedge clk);
    require(rsp != null, "Null write response");
    require(slave.aw_count == old_aw + 1 && slave.w_count == old_w + req.beat_count &&
            slave.b_count == old_b + 1, "Write handshake count mismatch");
    require(expected_w_beat == req.beat_count && observed_aw == 1, "Write monitor count mismatch");
  endtask

  task automatic read_transaction(input axi4_burst_request req, output axi4_burst_response rsp);
    int old_ar = slave.ar_count;
    int old_r = slave.r_count;
    int unsigned transfer_address, transfer_bytes, lane, byte_address;
    byte unsigned wanted;
    expect_read(req);
    adapter.axi_read_burst(req, rsp);
    @(negedge clk);
    require(rsp != null, "Null read response");
    require(rsp.data.size() == req.beat_count && rsp.rid.size() == req.beat_count &&
            rsp.rresp.size() == req.beat_count && rsp.rlast.size() == req.beat_count,
            "Read response arrays must retain every beat");
    require(slave.ar_count == old_ar + 1 && slave.r_count == old_r + req.beat_count,
            "Read handshake count mismatch");
    require(expected_r_beat == req.beat_count && observed_ar == 1, "Read monitor count mismatch");
    // Also check API-captured data: a correct bus alone cannot prove the driver
    // did not repeat/skip a sample while assembling its returned arrays.
    transfer_bytes = 1 << req.size;
    foreach (rsp.data[k]) begin
      transfer_address = req.addr + k * transfer_bytes;
      lane = transfer_address % AXI_STRB_WIDTH;
      for (int j = 0; j < transfer_bytes; j++) begin
        byte_address = transfer_address + j;
        wanted = expected_mem.exists(byte_address) ? expected_mem[byte_address] : 8'h00;
        require(rsp.data[k][8*(lane+j) +: 8] === wanted,
                $sformatf("Returned R data mismatch beat=%0d lane=%0d", k, lane+j));
      end
    end
  endtask

  task automatic check_normal_response(input axi4_burst_request req, input axi4_burst_response rsp,
                                       input bit is_read);
    if (is_read) begin
      foreach (rsp.data[k]) begin
        require(rsp.rid[k] === req.id && rsp.rresp[k] === 2'b00,
                "Normal read ID/status not retained");
        require(rsp.rlast[k] === (k == req.beat_count-1), "Normal read LAST not retained");
      end
    end else begin
      require(rsp.bid === req.id && rsp.bresp === 2'b00, "Normal write ID/status not retained");
    end
  endtask

  task automatic clear_controls();
    @(negedge clk);
    slave.aw_delay_cycles = 0;
    slave.w_delay_cycles = 0;
    slave.w_gap_cycles = 0;
    slave.ar_delay_cycles = 0;
    slave.b_delay_cycles = 0;
    slave.r_delay_cycles = 0;
    slave.r_gap_cycles = 0;
    slave.aw_wait_wvalid = 0;
    slave.hold_address_ready = 0;
    slave.write_resp = 0;
    slave.read_resp = 0;
    slave.write_id_xor = 0;
    slave.read_id_xor = 0;
    slave.rlast_offset = 0;
    slave.invert_rlast = 0;
  endtask

  task automatic test_positive();
    int lengths[4] = '{1,2,4,16};
    axi4_burst_request req;
    axi4_burst_response rsp;
    logic [1:0] response_code;
    axi4_completion completion;
    bit [AXI_DATA_WIDTH-1:0] legacy_data;
    int before_b, before_r;

    // Three patterns exercise initially READY, low-to-high-held-high, and gaps.
    for (int pattern = 0; pattern < 3; pattern++) begin
      clear_controls();
      if (pattern > 0) begin
        slave.aw_delay_cycles = 3;
        slave.w_delay_cycles = 3;
        slave.ar_delay_cycles = 3;
        slave.b_delay_cycles = 2;
        slave.r_delay_cycles = 2;
      end
      if (pattern == 1) slave.hold_address_ready = 1;
      if (pattern == 2) begin
        slave.w_gap_cycles = 2;
        slave.r_gap_cycles = 2;
        slave.aw_wait_wvalid = 1;
      end
      foreach (lengths[n]) begin
        req = request('h1000 + pattern*'h1000 + n*'h200, lengths[n]);
        // First populate bytes, then overwrite selectively so preserving lanes is observable.
        write_transaction(req, rsp);
        check_normal_response(req, rsp, 0);
        foreach (req.strb[k]) begin
          req.data[k] = ~req.data[k];
          case (k % 4)
            0: req.strb[k] = 32'h80000001;
            1: req.strb[k] = 32'ha5a5a5a5;
            2: req.strb[k] = '0;
            3: req.strb[k] = '1;
          endcase
        end
        write_transaction(req, rsp);
        check_normal_response(req, rsp, 0);
        req.id = 'h3c;
        read_transaction(req, rsp);
        check_normal_response(req, rsp, 1);
      end
    end

    clear_controls();
    // Exactly ending on a 4KB boundary is legal, including the 16-beat encoding.
    foreach (lengths[n]) begin
      req = request('h5000 - 32*lengths[n], lengths[n]);
      require(req.validate(1) == "", "Legal exact-4KB-end transaction rejected");
      write_transaction(req, rsp);
      read_transaction(req, rsp);
      check_normal_response(req, rsp, 1);
    end

    // Narrow single transfers use physical bus lanes and are allowed with no narrow burst support.
    req = request('h6124, 1, 2, 'h91);
    req.strb[0] = 32'h000000f0;
    req.data[0] = '0;
    req.data[0][63:32] = 32'h89abcdef;
    require(req.validate(1) == "" && req.lane_mask(0) == 32'hf0, "32-bit narrow single lane validation");
    write_transaction(req, rsp);
    read_transaction(req, rsp);
    require(rsp.data[0][63:32] === 32'h89abcdef, "Narrow single read lane mismatch");
    req = request('h613f, 1, 0, 'h92);
    req.strb[0] = 32'h80000000;
    req.data[0] = '0;
    req.data[0][255:248] = 8'hd9;
    require(req.lane_mask(0) == 32'h80000000, "Top byte lane mask mismatch");
    write_transaction(req, rsp);
    read_transaction(req, rsp);
    require(rsp.data[0][255:248] === 8'hd9, "Top byte lane read mismatch");

    // Feature03 owns all channels. Submit/wait replaces the feature02 raw
    // channel primitives; caller wait latency no longer controls B/RREADY.
    req = request('h6400, 4);
    expect_write(req);
    before_b = slave.b_count;
    adapter.submit_write(req, completion);
    repeat (5) @(negedge clk);
    adapter.wait_completion(completion, rsp);
    @(negedge clk);
    require(completion.status == AXI_COMPLETION_OK && rsp.bid === req.id && rsp.bresp === 0,
            "Asynchronous B response mismatch");
    require(slave.b_count == before_b + 1, "Asynchronous B handshake count mismatch");
    expect_read(req);
    before_r = slave.r_count;
    adapter.submit_read(req, completion);
    repeat (5) @(negedge clk);
    adapter.wait_completion(completion, rsp);
    @(negedge clk);
    require(completion.status == AXI_COMPLETION_OK && rsp.data.size() == req.beat_count,
            "Asynchronous R completion mismatch");
    foreach (rsp.data[k])
      require(rsp.rid[k] === req.id && rsp.data[k] === req.data[k] && rsp.rresp[k] === 0 &&
              rsp.rlast[k] === (k == req.beat_count - 1), "Asynchronous R response mismatch");
    require(slave.r_count == before_r + req.beat_count, "Asynchronous R handshake count mismatch");

    // Original blocking API still handles a full-width single transaction.
    req = request('h6800, 1, 5, AXI_DEFAULT_ID);
    req.strb[0] = AXI_DEFAULT_STRB;
    expect_write(req);
    adapter.axi_write(req.addr, req.data[0]);
    @(negedge clk);
    require(observed_aw == 1 && expected_w_beat == 1, "Legacy write handshake mismatch");
    expect_read(req);
    adapter.axi_read(req.addr, legacy_data);
    @(negedge clk);
    require(legacy_data === req.data[0] && observed_ar == 1 && expected_r_beat == 1,
            "Legacy read data/handshake mismatch");
    req.addr = 'h6820;
    expect_write(req);
    adapter.axi_write_resp(req.addr, req.data[0], req.strb[0], response_code);
    @(negedge clk);
    require(response_code === 0 && observed_aw == 1 && expected_w_beat == 1,
            "Legacy raw write response mismatch");
  endtask

  task automatic test_responses();
    axi4_burst_request req;
    axi4_burst_response rsp;
    logic [1:0] codes[3] = '{2'b10,2'b11,2'bx1};
    logic [1:0] legacy_code;
    bit [AXI_DATA_WIDTH-1:0] legacy_data;
    int expected_errors;
    reports.allow_response_errors = 1;
    foreach (codes[n]) begin
      @(negedge clk);
      slave.write_resp = codes[n];
      slave.read_resp = codes[n];
      req = request('h1000 + n*'h100, 2);
      write_transaction(req, rsp);
      require(rsp.bresp === codes[n], "Write error response not retained");
      read_transaction(req, rsp);
      foreach (rsp.rresp[k])
        require(rsp.rresp[k] === codes[n], "Read error response not retained");
    end
    expected_errors = AXI_ENABLE_RESPONSE_CHECKS ? 9 : 0;
    require(reports.response_errors == expected_errors, "Burst response checker enable/count mismatch");

    // Explicit raw status API must support caller-expected error responses.
    req = request('h1400, 1, 5, AXI_DEFAULT_ID);
    req.strb[0] = AXI_DEFAULT_STRB;
    @(negedge clk);
    slave.write_resp = 2'b10;
    slave.read_resp = 2'b11;
    expect_write(req);
    adapter.axi_write_resp(req.addr, req.data[0], req.strb[0], legacy_code);
    @(negedge clk);
    require(legacy_code === 2'b10 && reports.response_errors == expected_errors,
            "Legacy raw response unexpectedly forced OKAY");
    expect_write(req);
    adapter.axi_write(req.addr, req.data[0], req.strb[0]);
    @(negedge clk);
    expect_read(req);
    adapter.axi_read(req.addr, legacy_data);
    @(negedge clk);
    if (AXI_ENABLE_RESPONSE_CHECKS) expected_errors += 2;
    require(reports.response_errors == expected_errors, "Legacy response checker enable/count mismatch");

    req = request('h1500, 2);
    req.check_response = 0;
    write_transaction(req, rsp);
    read_transaction(req, rsp);
    require(reports.response_errors == expected_errors && rsp.rresp[0] === 2'b11,
            "Per-request response-check suppression failed");
  endtask

  task automatic reset_after_protocol_fault();
    @(negedge clk);
    reset_n = 0;
    repeat (4) @(negedge clk);
    expected_mem.delete();
    expected_write = null;
    expected_read = null;
    reset_n = 1;
    clear_controls();
    require(!adapter.is_poisoned() && adapter.get_outstanding_total() == 0,
            "Reset failed to clear protocol quarantine");
  endtask

  task automatic test_protocol();
    axi4_burst_request req = request('h1800, 4);
    axi4_burst_response rsp;
    axi4_completion completion;
    string detail;
    // ID association and response boundaries are mandatory scheduler safety,
    // including when the optional general protocol checker is disabled.
    for (int fault = 0; fault < 3; fault++) begin
      clear_controls();
      reports.expected_error_id = "AXI_BFM_PROTOCOL";
      reports.expected_error_limit = 1;
      reports.expected_error_seen = 0;
      case (fault)
        0: begin
          slave.write_id_xor = 1;
          detail = $sformatf("Unexpected/unknown BID=%0h", req.id ^ 1);
        end
        1: begin
          slave.read_id_xor = 1;
          detail = $sformatf("Unexpected/unknown RID=%0h", req.id ^ 1);
        end
        2: begin
          slave.invert_rlast = 1;
          detail = $sformatf("RLAST mismatch RID=%0h beat=0 of %0d", req.id, req.beat_count);
        end
      endcase
      reports.expected_error_token = {detail, "; scheduler quarantined until reset"};
      if (fault == 0) begin
        expect_write(req);
        adapter.submit_write(req, completion);
      end else begin
        expect_read(req);
        adapter.submit_read(req, completion);
      end
      adapter.wait_completion(completion, rsp);
      @(negedge clk);
      require(completion.done && completion.status == AXI_COMPLETION_PROTOCOL_ERROR &&
              completion.detail == detail && adapter.is_poisoned(),
              "Malformed response was not quarantined with the expected failure status");
      require(reports.expected_error_seen == 1 && reports.protocol_errors == fault + 1,
              "Wrong/missing/duplicate mandatory protocol diagnostic");
      $display("PROTOCOL_QUARANTINE checked=%0d fault=%0d status=%0d detail=%s",
               AXI_ENABLE_PROTOCOL_CHECKS, fault, completion.status, completion.detail);
      reset_after_protocol_fault();
    end
    reports.expected_error_limit = 0;
    reports.expected_error_id = "";
    write_transaction(req, rsp);
    check_normal_response(req, rsp, 0);
    read_transaction(req, rsp);
    check_normal_response(req, rsp, 1);
    require(reports.protocol_errors == 3, "Expected three mandatory ID/LAST diagnostics");
  endtask

  task automatic test_illegal();
    axi4_burst_request req;
    int checks = 0;
    req = request('h1000, 0);
    require(req.validate(1) != "", "Zero beats accepted"); checks++;
    req = request('h1000, 17);
    require(req.validate(1) != "", "LEN4 overflow accepted"); checks++;
    req = request('h1000, 1, 6);
    require(req.validate(1) != "", "Size exceeds DATA256 accepted"); checks++;
    req = request('h0fe0, 2);
    require(req.validate(1) != "" && req.validate(0) != "", "4KB crossing accepted"); checks++;
    req = request('h1001, 1);
    require(req.validate(1) != "", "Unaligned transfer accepted"); checks++;
    req = request('h1000, 2, 2);
    req.strb[0] = 'hf;
    req.strb[1] = 'hf0;
    require(req.validate(1) != "", "Narrow burst accepted under target no-narrow profile"); checks++;
    req = request('h1124, 1, 2);
    req.strb[0] = 'h1;
    require(req.validate(1) != "", "Out-of-lane narrow single WSTRB accepted"); checks++;
    for (int burst_kind = 0; burst_kind < 4; burst_kind++) begin
      if (burst_kind == 1) continue;
      req = request('h1000, 1);
      req.burst = burst_kind;
      require(req.validate(1) != "", "Unsupported burst accepted"); checks++;
    end
    req = request('h1000, 1);
    req.lock = 1;
    require(req.validate(1) != "", "Exclusive/locked request accepted"); checks++;
    req = request('h1000, 2);
    req.data = new[1];
    require(req.validate(1) != "", "Data array size mismatch accepted"); checks++;
    req = request('h1000, 2);
    req.strb = new[1];
    require(req.validate(1) != "", "Strobe array size mismatch accepted"); checks++;
    req = request('hffffffe0, 1);
    require(req.validate(1) == "", "Legal top-address single rejected"); checks++;
    req = request('hffffffe0, 2);
    require(req.validate(1) != "", "Address wraparound/crossing accepted"); checks++;
    require(slave.aw_count == 0 && slave.w_count == 0 && slave.ar_count == 0,
            "Validation caused bus traffic");
    $display("ILLEGAL_VALIDATION_CHECKS %0d", checks);
  endtask

  task automatic test_delayed();
    axi4_burst_request req = request('h2000, 4);
    axi4_burst_response rsp;
    require(!AXI_ENABLE_TIMEOUT_CHECKS ||
            (AXI_READY_TIMEOUT_CYCLES == 0 && AXI_WRITE_TIMEOUT_CYCLES == 0 && AXI_READ_TIMEOUT_CYCLES == 0),
            "Delayed case requires disabled or zero timeout configuration");
    @(negedge clk);
    slave.aw_delay_cycles = 20;
    slave.w_delay_cycles = 20;
    slave.w_gap_cycles = 20;
    slave.ar_delay_cycles = 20;
    slave.b_delay_cycles = 20;
    slave.r_delay_cycles = 20;
    slave.r_gap_cycles = 20;
    write_transaction(req, rsp);
    check_normal_response(req, rsp, 0);
    read_transaction(req, rsp);
    check_normal_response(req, rsp, 1);
  endtask

  task automatic test_narrow_enabled();
    axi4_burst_request req = request('h118, 4, 2, 'hb6);
    axi4_burst_response rsp;
    logic [31:0] expected_masks[4] = '{32'h0f000000, 32'hf0000000,
                                      32'h0000000f, 32'h000000f0};
    require(axi4_vip_cfg_pkg::VIP_SUPPORT_NARROW_BURST,
            "Narrow-enabled case requires support.narrow_burst=true");
    foreach (req.strb[k]) begin
      req.strb[k] = expected_masks[k];
      require(req.lane_mask(k) === expected_masks[k],
              $sformatf("Narrow INCR lane mask mismatch beat=%0d", k));
    end
    require(req.validate(1) == "", "Enabled aligned narrow burst rejected");
    @(negedge clk);
    slave.aw_delay_cycles = 2;
    slave.w_delay_cycles = 2;
    slave.w_gap_cycles = 2;
    slave.ar_delay_cycles = 2;
    slave.r_gap_cycles = 2;
    write_transaction(req, rsp);
    check_normal_response(req, rsp, 0);
    read_transaction(req, rsp);
    check_normal_response(req, rsp, 1);
  endtask

  task automatic test_strobe_disabled();
    axi4_burst_request req;
    axi4_burst_response rsp;
    require(!axi4_vip_cfg_pkg::VIP_SUPPORT_BYTE_STROBE,
            "Strobe-disabled case requires support.byte_strobe=false");
    req = request('h2000, 1);
    req.strb[0] = 'h1;
    require(req.validate(1) != "", "Partial full-width strobe accepted while disabled");
    req.strb[0] = '1;
    require(req.validate(1) == "", "All-lane full-width strobe rejected");
    write_transaction(req, rsp);
    read_transaction(req, rsp);
    check_normal_response(req, rsp, 1);

    // Disabling partial strobes means all addressed lanes, not all bus lanes.
    req = request('h2124, 1, 2);
    req.strb[0] = 32'h000000f0;
    require(req.validate(1) == "", "Complete narrow-single lane mask rejected");
    req.strb[0] = 32'h00000010;
    require(req.validate(1) != "", "Partial narrow-single mask accepted while disabled");
    req.strb[0] = 32'h000000f0;
    write_transaction(req, rsp);
    check_normal_response(req, rsp, 0);
    read_transaction(req, rsp);
    check_normal_response(req, rsp, 1);
  endtask

  task automatic test_expected_fatal();
    axi4_burst_request req = request('h3000, 2);
    axi4_burst_response rsp;
    string detail;
    bit is_read;
    reports.fatal_id = "AXI_BFM_ABORT";
    reports.expected_error_id = "AXI_BFM_TIMEOUT";
    reports.expected_error_limit = 1;
    reports.fatal_error_count = 1;
    expect_write(req);
    expect_read(req);
    @(negedge clk);
    case (case_name)
      "timeout_aw": begin
        detail = "AWREADY timeout";
        slave.aw_delay_cycles = 1000;
      end
      "timeout_w": begin
        detail = "WREADY timeout";
        slave.w_delay_cycles = 1000;
      end
      "timeout_ar": begin
        detail = "ARREADY timeout";
        slave.ar_delay_cycles = 1000;
        is_read = 1;
      end
      "timeout_b": begin
        detail = $sformatf("B response timeout BID=%0h serial=1", req.id);
        slave.b_delay_cycles = 1000;
      end
      "timeout_r": begin
        detail = $sformatf("R response timeout RID=%0h serial=1", req.id);
        slave.r_delay_cycles = 1000;
        is_read = 1;
      end
      "reset": begin
        detail = "Reset interrupted transaction";
        reports.expected_error_limit = 0;
        reports.fatal_error_count = 0;
        slave.aw_delay_cycles = 1000;
      end
      "illegal_api": begin
        req.beat_count = 0;
        detail = req.validate(1);
        reports.expected_error_id = "AXI_ILLEGAL";
      end
      default: $fatal(1, "Unknown fatal case %s", case_name);
    endcase
    reports.expected_error_token = case_name == "illegal_api" ? detail :
                                   {detail, "; scheduler quarantined until reset"};
    reports.fatal_token = {is_read ? "Blocking read aborted: " : "Blocking write aborted: ", detail};
    if (case_name == "reset") begin
      fork
        adapter.axi_write_burst(req, rsp);
        begin
          repeat (3) @(negedge clk);
          reset_n = 0;
        end
      join
    end else if (is_read) adapter.axi_read_burst(req, rsp);
    else adapter.axi_write_burst(req, rsp);
    $fatal(1, "Expected fatal did not occur for %s", case_name);
  endtask

  initial begin : watchdog
    #20us;
    $fatal(1, "TEST_WATCHDOG %s", case_name);
  end

  initial begin : run
    uvm_report_server server;
    if (!$value$plusargs("CASE=%s", case_name)) case_name = "positive";
    require(AXI_ADDR_WIDTH == 32 && AXI_DATA_WIDTH == 256 && AXI_ID_WIDTH == 8 && AXI_LEN_WIDTH == 4,
            "This test requires the isolated DATA256/ADDR32/ID8/LEN4 profile");
    reports = new;
    reports.case_name = case_name;
    uvm_report_cb::add(null, reports);
    adapter = new("adapter");
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", axi);
    repeat (4) @(negedge clk);
    reset_n = 1;
    adapter.init();
    clear_controls();
    case (case_name)
      "positive": test_positive();
      "responses": test_responses();
      "protocol": test_protocol();
      "illegal": test_illegal();
      "delayed": test_delayed();
      "narrow_enabled": test_narrow_enabled();
      "strobe_disabled": test_strobe_disabled();
      "timeout_aw", "timeout_w", "timeout_ar", "timeout_b", "timeout_r", "reset", "illegal_api":
        test_expected_fatal();
      default: $fatal(1, "Unknown CASE=%s", case_name);
    endcase
    repeat (3) @(negedge clk);
    server = uvm_report_server::get_server();
    require(reports.unexpected_errors == 0 && server.get_severity_count(UVM_ERROR) == 0 &&
            server.get_severity_count(UVM_FATAL) == 0, "Unexpected UVM error/fatal report");
    $display("HANDSHAKES aw=%0d w=%0d b=%0d ar=%0d r=%0d", slave.aw_count, slave.w_count,
             slave.b_count, slave.ar_count, slave.r_count);
    $display("BURST_TEST_PASS %s", case_name);
    $finish;
  end
endmodule
