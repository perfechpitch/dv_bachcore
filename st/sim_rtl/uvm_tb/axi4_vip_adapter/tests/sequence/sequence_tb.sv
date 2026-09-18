`timescale 1ns/1ps
package sequence_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;
  import axi4_generated_seq_pkg::*;
  import axi4_interrupt_pkg::*;

  class sequence_test extends uvm_test;
    `uvm_component_utils(sequence_test)
    axi4_adapter_sequencer sqr;
    simple_axi4_bfm_adapter bfm;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      bfm = simple_axi4_bfm_adapter::type_id::create("bfm");
      uvm_config_db#(axi4_vip_adapter_base)::set(this, "sqr", "adapter", bfm);
      sqr = axi4_adapter_sequencer::type_id::create("sqr", this);
    endfunction
    task run_phase(uvm_phase phase);
      axi4_doc_plan_seq seq;
      axi4_irq_handler_seq irq;
      bit [AXI_DATA_WIDTH-1:0] irq_data;
      string test_case;
      phase.raise_objection(this);
      void'($value$plusargs("CASE=%s", test_case));
      seq = axi4_doc_plan_seq::type_id::create("seq");
      seq.start(sqr);
      if (test_case == "legacy") begin
        irq = axi4_irq_handler_seq::type_id::create("irq");
        irq.start(sqr);
        bfm.axi_read('h200, irq_data);
        if (irq_data !== AXI_DATA_WIDTH'('h69))
          `uvm_fatal("IRQ_CHECK", "Legacy generated IRQ write/readback failed")
      end
      bfm.wait_cycles(4);
      phase.drop_objection(this);
    endtask
  endclass
endpackage

module sequence_tb;
  import uvm_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import sequence_test_pkg::*;
  bit clk = 0;
  bit resetn = 0;
  bit gate_responses;
  integer release_threshold = 128;
  string test_case;
  always #0.5 clk = ~clk;

  axi4_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH),
    .LEN_WIDTH(AXI_LEN_WIDTH), .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
    .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
    .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH), .BUSER_WIDTH(AXI_BUSER_WIDTH)
  ) axi(clk, resetn);
  sequence_mem #(.ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
                 .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH)) mem(
      .axi(axi), .release_threshold(release_threshold),
      .gate_responses(gate_responses));

  task verify_counts(input string test_case);
    int expected_aw, expected_ar;
    $display("SEQUENCE_COUNTS AW=%0d W=%0d B=%0d AR=%0d R=%0d PEAK_W=%0d PEAK_R=%0d PEAK_TOTAL=%0d",
      mem.aw_count, mem.w_count, mem.b_count, mem.ar_count, mem.r_count,
      mem.write_peak, mem.read_peak, mem.total_peak);
    if (mem.total_inflight != 0 || mem.aw_count != mem.b_count)
      $fatal(1, "Sequence left unfinished transactions");
    if (test_case == "burst128") begin
      if (mem.aw_count != 192 || mem.w_count != 800 || mem.b_count != 192 ||
          mem.ar_count != 320 || mem.r_count != 928 ||
          mem.write_peak != 128 || mem.read_peak != 128 || mem.total_peak != 128)
        $fatal(1, "128 sequence handshake counts/peaks differ from expected");
    end else if (test_case == "lanes") begin
      if (mem.aw_count != 67 || mem.w_count != 67 || mem.ar_count != 37 || mem.r_count != 37)
        $fatal(1, "Byte-lane sequence count mismatch (readback may have been skipped)");
    end else if (test_case == "mixed") begin
      if (mem.aw_count != 8 || mem.w_count != 27 || mem.b_count != 8 ||
          mem.ar_count != 8 || mem.r_count != 27)
        $fatal(1, "Mixed burst sequence handshake count mismatch");
    end else if (test_case == "legacy") begin
      if (!$value$plusargs("EXPECT_AW=%d", expected_aw) ||
          !$value$plusargs("EXPECT_AR=%d", expected_ar))
        $fatal(1, "Legacy regression requires explicit expected handshake counts");
      if (mem.aw_count != expected_aw || mem.w_count != expected_aw ||
          mem.b_count != expected_aw || mem.ar_count != expected_ar || mem.r_count != expected_ar)
        $fatal(1, "Legacy sequence handshake counts differ (main sequence/readback may have been skipped)");
    end
  endtask

  initial begin
    repeat (5) @(negedge clk);
    resetn = 1;
    if (test_case == "abort") begin
      do @(posedge clk); while (!(axi.awvalid && axi.awready));
      @(negedge clk);
      resetn = 0;
    end
  end
  initial begin
    uvm_report_server server;
    void'($value$plusargs("CASE=%s", test_case));
    gate_responses = test_case == "burst128" || test_case == "abort";
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", axi);
    uvm_top.finish_on_completion = 0;
    run_test("sequence_test");
    verify_counts(test_case);
    server = uvm_report_server::get_server();
    if (server.get_severity_count(UVM_ERROR) != 0 || server.get_severity_count(UVM_FATAL) != 0)
      $fatal(1, "Sequence reported UVM errors");
    $display("SEQUENCE_TEST_PASS %s", test_case);
    $finish;
  end
  initial begin
    #200000;
    $fatal(1, "Sequence watchdog expired; possible serialized submission/deadlock");
  end
endmodule
