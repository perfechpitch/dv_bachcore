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

  always #5 aclk = ~aclk;

  axi4_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH  (AXI_ID_WIDTH)
  ) axi_vif (
    .aclk   (aclk),
    .aresetn(aresetn)
  );
  axi4_irq_if irq_vif(.aclk(aclk), .aresetn(aresetn), .irq(ext_irq));

  initial begin
    if ($bits(axi_vif.awaddr) != AXI_ADDR_WIDTH ||
        $bits(axi_vif.wdata)  != AXI_DATA_WIDTH ||
        $bits(axi_vif.wstrb)  != AXI_STRB_WIDTH) begin
      $fatal(1, "AXI interface width mismatch: awaddr=%0d/%0d wdata=%0d/%0d wstrb=%0d/%0d",
        $bits(axi_vif.awaddr), AXI_ADDR_WIDTH,
        $bits(axi_vif.wdata),  AXI_DATA_WIDTH,
        $bits(axi_vif.wstrb),  AXI_STRB_WIDTH);
    end
    $display("AXI interface widths: ADDR_WIDTH=%0d DATA_WIDTH=%0d STRB_WIDTH=%0d ID_WIDTH=%0d",
      AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_STRB_WIDTH, AXI_ID_WIDTH);
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
    repeat (5) @(posedge aclk);
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
    uvm_config_db#(virtual axi4_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH))::set(
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
