`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import axi4_vip_cfg_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import axi4_vip_env_pkg::*;
  import axi4_generated_seq_pkg::*;
  import axi4_doc_test_pkg::*;

  bit aclk;
  bit aresetn;
  logic ext_irq;
  int irq_en;
  localparam int SIMPLE_BFM_SLAVE_DEPTH = 1024;

  // Default: the existing 100 MHz demo. For 1 GHz, pass
  // +AXI_CLK_PERIOD_NS=1.0 directly to simv. A 50% duty cycle requires
  // each half period to be representable at this module's 1 ps precision.
  initial begin : configure_axi_clock
    string period_arg;
    string trailing_arg;
    realtime period_ns;
    realtime half_period_ns;
    realtime quantization_error_ns;
    period_ns = 10.0;
    if ($test$plusargs("AXI_CLK_PERIOD_NS")) begin
      if (!$value$plusargs("AXI_CLK_PERIOD_NS=%s", period_arg) ||
          $sscanf(period_arg, "%f%s", period_ns, trailing_arg) != 1)
        $fatal(1, "AXI_CLK_PERIOD_NS must be a numeric period in ns");
    end
    if (!(period_ns > 0.0))
      $fatal(1, "AXI_CLK_PERIOD_NS must be positive, got %s", period_arg);
    if (!(period_ns < real'(64'hffff_ffff_ffff_ffff) * 1ps))
      $fatal(1, "AXI_CLK_PERIOD_NS exceeds the 64-bit simulation time range");
    half_period_ns = $floor(period_ns / (2.0 * 1ps) + 0.5) * 1ps;
    quantization_error_ns = half_period_ns * 2.0 - period_ns;
    // Tolerance covers floating-point representation, not a simulation tick.
    if (!(half_period_ns >= 1ps) ||
        !(quantization_error_ns >= -1.0e-9 && quantization_error_ns <= 1.0e-9))
      $fatal(1, "AXI_CLK_PERIOD_NS=%0.12f is not representable with a 50%% duty cycle at 1ps precision", period_ns);
    $display("AXI clock: period=%0.6f ns frequency=%0.6f GHz (50%% duty cycle)",
      half_period_ns * 2.0, 1.0 / (half_period_ns * 2.0));
    fork
      forever #(half_period_ns) aclk = ~aclk;
      begin : verify_generated_clock
        realtime first_edge_ns, measured_period_ns;
        @(posedge aclk);
        first_edge_ns = $realtime;
        repeat (10) @(posedge aclk);
        measured_period_ns = ($realtime - first_edge_ns) / 10.0;
        if (measured_period_ns - period_ns > 1.0e-9 ||
            period_ns - measured_period_ns > 1.0e-9)
          $fatal(1, "AXI clock measured period does not match requested period");
        $display("AXI_CLOCK_MEASURED period_ns=%0.6f samples=10", measured_period_ns);
      end
    join
  end

  axi4_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH  (AXI_ID_WIDTH),
    .LEN_WIDTH (AXI_LEN_WIDTH),
    .QOS_WIDTH (AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
    .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
    .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH),
    .BUSER_WIDTH(AXI_BUSER_WIDTH)
  ) axi_vif (
    .aclk   (aclk),
    .aresetn(aresetn)
  );
  axi4_irq_if irq_vif(.aclk(aclk), .aresetn(aresetn), .irq(ext_irq));

  `include "checker/axi4_configured_monitor.svh"

  initial begin
    if ($bits(axi_vif.awaddr) != AXI_ADDR_WIDTH ||
        $bits(axi_vif.wdata)  != AXI_DATA_WIDTH ||
        $bits(axi_vif.wstrb)  != AXI_STRB_WIDTH ||
        $bits(axi_vif.awid)   != AXI_ID_WIDTH ||
        $bits(axi_vif.arid)   != AXI_ID_WIDTH ||
        $bits(axi_vif.awlen)  != AXI_LEN_WIDTH ||
        $bits(axi_vif.arlen)  != AXI_LEN_WIDTH) begin
      $fatal(1, "AXI interface width mismatch: awaddr=%0d/%0d wdata=%0d/%0d wstrb=%0d/%0d",
        $bits(axi_vif.awaddr), AXI_ADDR_WIDTH,
        $bits(axi_vif.wdata),  AXI_DATA_WIDTH,
        $bits(axi_vif.wstrb),  AXI_STRB_WIDTH);
    end
    $display("AXI interface widths: ADDR_WIDTH=%0d DATA_WIDTH=%0d STRB_WIDTH=%0d ID_WIDTH=%0d LEN_WIDTH=%0d",
      AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_STRB_WIDTH, AXI_ID_WIDTH, AXI_LEN_WIDTH);
  end

`ifdef USE_SIMPLE_AXI4_BFM
  axi4_simple_mem_slave #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH  (AXI_ID_WIDTH),
    .DEPTH     (SIMPLE_BFM_SLAVE_DEPTH)
  ) u_mem_slave (
    .axi(axi_vif)
  );
`endif

  initial begin
    aresetn = 1'b0;
    repeat (5) @(negedge aclk);
    aresetn = 1'b1;
  end

  initial begin
    ext_irq = 1'b0;
    irq_en = 0;
    void'($value$plusargs("IRQ_EN=%d", irq_en));
    wait (aresetn === 1'b1);

    if (irq_en != 0) begin
      repeat (35) @(posedge aclk);
      ext_irq <= 1'b1;
      repeat (3) @(posedge aclk);
      ext_irq <= 1'b0;
    end
  end

  initial begin
    uvm_config_db#(axi4_vif_t)::set(
      null, "*", "axi_vif", axi_vif);
    uvm_config_db#(virtual axi4_irq_if)::set(null, "*", "irq_vif", irq_vif);
    run_test("axi4_doc_test");
  end

`ifdef DUMP_FSDB
  initial begin
    string fsdb_file;
    fsdb_file = "axi4_bfm.fsdb";
    void'($value$plusargs("FSDB_FILE=%s", fsdb_file));
    $fsdbDumpfile(fsdb_file);
    $fsdbDumpvars(0, tb_top);
    $fsdbDumpMDA();
  end
`endif
endmodule
