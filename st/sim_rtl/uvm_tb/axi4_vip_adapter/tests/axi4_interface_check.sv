`timescale 1ns/1ps
// Connection fixture only: combinational echo deliberately is not an AXI slave.
module axi4_sideband_echo(axi4_if.slave axi);
  assign axi.awready = axi.awvalid;
  assign axi.wready = axi.wvalid;
  assign axi.arready = axi.arvalid;
  assign axi.bid = axi.awid;
  assign axi.bresp = 2'b10;
  assign axi.buser = (axi.BUSER_WIDTH == 0) ? '0 : '1;
  assign axi.bvalid = axi.bready;
  assign axi.rid = axi.arid;
  assign axi.rdata = axi.wdata;
  assign axi.rresp = 2'b11;
  assign axi.rlast = axi.wlast;
  assign axi.ruser = (axi.RUSER_WIDTH == 0) ? '0 : '1;
  assign axi.rvalid = axi.rready;
endmodule

module axi4_interface_check;
  import uvm_pkg::*;
  import axi4_vip_cfg_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;
  bit clk = 0;
  bit rstn = 0;
  always #0.5 clk = ~clk;
  axi4_if #(32, 32, 4) legacy(clk, rstn);
  virtual axi4_if #(32, 32, 4) legacy_vif;
  axi4_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH),
    .LEN_WIDTH(AXI_LEN_WIDTH), .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
    .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
    .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH), .BUSER_WIDTH(AXI_BUSER_WIDTH)
  ) bus(clk, rstn);
  axi4_sideband_echo fixture(bus);
  axi4_vif_t got_vif;
  simple_axi4_bfm_adapter adapter;

  initial begin
    #100;
    $fatal(1, "interface check watchdog");
  end

  initial begin
    legacy_vif = legacy;
    if ($bits(legacy_vif.awlen) != 8 || $bits(legacy_vif.wdata) != 32)
      $fatal(1, "legacy three-parameter interface changed");
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", bus);
    if (!uvm_config_db#(axi4_vif_t)::get(null, "*", "axi_vif", got_vif))
      $fatal(1, "canonical virtual interface config_db mismatch");
    adapter = new("adapter");
    #1 rstn = 1;
    adapter.init();
    #0.01;
    if ($bits(bus.awaddr) != AXI_ADDR_WIDTH || $bits(bus.wdata) != AXI_DATA_WIDTH ||
        $bits(bus.wstrb) != AXI_STRB_WIDTH || $bits(bus.awid) != AXI_ID_WIDTH ||
        $bits(bus.arid) != AXI_ID_WIDTH || $bits(bus.bid) != AXI_ID_WIDTH ||
        $bits(bus.rid) != AXI_ID_WIDTH || $bits(bus.awlen) != AXI_LEN_WIDTH ||
        $bits(bus.arlen) != AXI_LEN_WIDTH || $bits(bus.awqos) != ((AXI_QOS_WIDTH>0)?AXI_QOS_WIDTH:1) ||
        $bits(bus.awregion) != ((AXI_REGION_WIDTH>0)?AXI_REGION_WIDTH:1) ||
        $bits(bus.awuser) != ((AXI_AWUSER_WIDTH>0)?AXI_AWUSER_WIDTH:1) ||
        $bits(bus.aruser) != ((AXI_ARUSER_WIDTH>0)?AXI_ARUSER_WIDTH:1) ||
        $bits(bus.wuser) != ((AXI_WUSER_WIDTH>0)?AXI_WUSER_WIDTH:1) ||
        $bits(bus.buser) != ((AXI_BUSER_WIDTH>0)?AXI_BUSER_WIDTH:1) ||
        $bits(bus.ruser) != ((AXI_RUSER_WIDTH>0)?AXI_RUSER_WIDTH:1))
      $fatal(1, "configured interface dimensions mismatch");
    if (bus.awid !== AXI_DEFAULT_ID || bus.arid !== AXI_DEFAULT_ID ||
        bus.awlock !== 1'b0 || bus.arlock !== 1'b0 ||
        bus.awcache !== AXI_DEFAULT_CACHE || bus.arcache !== AXI_DEFAULT_CACHE ||
        bus.awprot !== AXI_DEFAULT_PROT || bus.arprot !== AXI_DEFAULT_PROT ||
        bus.awqos !== AXI_DEFAULT_QOS || bus.arqos !== AXI_DEFAULT_QOS ||
        bus.awregion !== AXI_DEFAULT_REGION || bus.arregion !== AXI_DEFAULT_REGION ||
        bus.awuser !== AXI_DEFAULT_AWUSER || bus.aruser !== AXI_DEFAULT_ARUSER ||
        bus.wuser !== AXI_DEFAULT_WUSER)
      $fatal(1, "BFM sideband defaults mismatch");
    if ($isunknown({bus.awlock, bus.awcache, bus.awprot, bus.awqos, bus.awregion,
                    bus.awuser, bus.aruser, bus.wuser, bus.buser, bus.ruser}))
      $fatal(1, "sideband X after BFM init");
    got_vif.awid = '1;
    got_vif.arid = '1;
    got_vif.awlen = '1;
    got_vif.arlen = '1;
    got_vif.wdata = '1;
    got_vif.wstrb = '1;
    got_vif.wlast = 1;
    got_vif.awvalid = 1;
    got_vif.wvalid = 1;
    got_vif.arvalid = 1;
    got_vif.bready = 1;
    got_vif.rready = 1;
    #0.01;
    if (bus.bid !== {AXI_ID_WIDTH{1'b1}} || bus.rid !== {AXI_ID_WIDTH{1'b1}} ||
        bus.rdata !== {AXI_DATA_WIDTH{1'b1}} || bus.awlen !== {AXI_LEN_WIDTH{1'b1}} ||
        bus.arlen !== {AXI_LEN_WIDTH{1'b1}} || bus.wstrb !== {AXI_STRB_WIDTH{1'b1}} ||
        !bus.awready || !bus.wready || !bus.arready || !bus.bvalid || !bus.rvalid ||
        !bus.rlast || bus.bresp != 2'b10 || bus.rresp != 2'b11)
      $fatal(1, "modport/virtual-interface connection truncated signals");
    if ((AXI_BUSER_WIDTH == 0 && bus.buser !== '0) ||
        (AXI_BUSER_WIDTH > 0 && bus.buser !== '1) ||
        (AXI_RUSER_WIDTH == 0 && bus.ruser !== '0) ||
        (AXI_RUSER_WIDTH > 0 && bus.ruser !== '1))
      $fatal(1, "response USER connection mismatch");
    $display("INTERFACE_CHECK_PASS DATA=%0d ADDR=%0d ID=%0d LEN=%0d QOS=%0d AWUSER=%0d",
             AXI_DATA_WIDTH, AXI_ADDR_WIDTH, AXI_ID_WIDTH, AXI_LEN_WIDTH, AXI_QOS_WIDTH, AXI_AWUSER_WIDTH);
    $finish;
  end
endmodule
