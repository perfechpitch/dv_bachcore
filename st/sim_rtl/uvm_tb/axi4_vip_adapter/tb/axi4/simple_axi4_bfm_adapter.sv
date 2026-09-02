package simple_axi4_bfm_adapter_pkg;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;

  class simple_axi4_bfm_adapter extends axi4_vip_adapter_base;
    `uvm_object_utils(simple_axi4_bfm_adapter)

    virtual axi4_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH) vif;
    bit initialized;

    function new(string name = "simple_axi4_bfm_adapter");
      super.new(name);
    endfunction

    virtual task init();
      if (initialized) begin
        return;
      end

      if (!uvm_config_db#(virtual axi4_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH))::get(
            null, "*", "axi_vif", vif)) begin
        `uvm_fatal(get_type_name(), "Missing config_db entry: axi_vif")
      end

      vif.awid    <= '0;
      vif.awaddr  <= '0;
      vif.awlen   <= '0;
      vif.awsize  <= $clog2(AXI_STRB_WIDTH);
      vif.awburst <= 2'b01;
      vif.awvalid <= 1'b0;
      vif.wdata   <= '0;
      vif.wstrb   <= '0;
      vif.wlast   <= 1'b0;
      vif.wvalid  <= 1'b0;
      vif.bready  <= 1'b0;
      vif.arid    <= '0;
      vif.araddr  <= '0;
      vif.arlen   <= '0;
      vif.arsize  <= $clog2(AXI_STRB_WIDTH);
      vif.arburst <= 2'b01;
      vif.arvalid <= 1'b0;
      vif.rready  <= 1'b0;

      wait (vif.aresetn === 1'b1);
      initialized = 1'b1;
      `uvm_info(get_type_name(), "Simple AXI4 BFM adapter initialized", UVM_LOW)
    endtask

    virtual task axi_write_resp(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      input  bit [AXI_DATA_WIDTH-1:0] data,
      input  bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB,
      output logic [1:0]              bresp
    );
      int unsigned timeout_count;

      init();
      bresp = 'x;
      `uvm_info(get_type_name(), $sformatf(
        "BFM write addr=0x%0h data=0x%0h strb=0x%0h", addr, data, strb), UVM_MEDIUM)

      @(posedge vif.aclk);
      vif.awaddr  <= addr;
      vif.awlen   <= 8'd0;
      vif.awsize  <= $clog2(AXI_STRB_WIDTH);
      vif.awburst <= 2'b01;
      vif.awvalid <= 1'b1;
      timeout_count = 0;
      while (!vif.awready) begin
        if (AXI_WRITE_TIMEOUT_CYCLES != 0 && timeout_count++ >= AXI_WRITE_TIMEOUT_CYCLES) begin
          `uvm_fatal(get_type_name(), "Timed out waiting for AWREADY")
        end
        @(posedge vif.aclk);
      end
      @(posedge vif.aclk);
      vif.awvalid <= 1'b0;

      vif.wdata  <= data;
      vif.wstrb  <= strb;
      vif.wlast  <= 1'b1;
      vif.wvalid <= 1'b1;
      timeout_count = 0;
      while (!vif.wready) begin
        if (AXI_WRITE_TIMEOUT_CYCLES != 0 && timeout_count++ >= AXI_WRITE_TIMEOUT_CYCLES) begin
          `uvm_fatal(get_type_name(), "Timed out waiting for WREADY")
        end
        @(posedge vif.aclk);
      end
      @(posedge vif.aclk);
      vif.wvalid <= 1'b0;
      vif.wlast  <= 1'b0;

      vif.bready <= 1'b1;
      timeout_count = 0;
      while (!vif.bvalid) begin
        if (AXI_WRITE_TIMEOUT_CYCLES != 0 && timeout_count++ >= AXI_WRITE_TIMEOUT_CYCLES) begin
          `uvm_fatal(get_type_name(), "Timed out waiting for BVALID")
        end
        @(posedge vif.aclk);
      end
      bresp = vif.bresp;
      @(posedge vif.aclk);
      vif.bready <= 1'b0;
      `uvm_info(get_type_name(), $sformatf(
        "BFM write response addr=0x%0h bresp=%s(0x%0h)",
        addr, axi_resp_name(bresp), bresp), UVM_MEDIUM)
    endtask

    virtual task axi_read(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      output bit [AXI_DATA_WIDTH-1:0] data
    );
      int unsigned timeout_count;

      init();
      `uvm_info(get_type_name(), $sformatf("BFM read addr=0x%0h", addr), UVM_MEDIUM)

      @(posedge vif.aclk);
      vif.araddr  <= addr;
      vif.arlen   <= 8'd0;
      vif.arsize  <= $clog2(AXI_STRB_WIDTH);
      vif.arburst <= 2'b01;
      vif.arvalid <= 1'b1;
      timeout_count = 0;
      while (!vif.arready) begin
        if (AXI_READ_TIMEOUT_CYCLES != 0 && timeout_count++ >= AXI_READ_TIMEOUT_CYCLES) begin
          `uvm_fatal(get_type_name(), "Timed out waiting for ARREADY")
        end
        @(posedge vif.aclk);
      end
      @(posedge vif.aclk);
      vif.arvalid <= 1'b0;

      vif.rready <= 1'b1;
      timeout_count = 0;
      while (!vif.rvalid) begin
        if (AXI_READ_TIMEOUT_CYCLES != 0 && timeout_count++ >= AXI_READ_TIMEOUT_CYCLES) begin
          `uvm_fatal(get_type_name(), "Timed out waiting for RVALID")
        end
        @(posedge vif.aclk);
      end
      data = vif.rdata;
      if (vif.rresp != 2'b00) begin
        `uvm_error(get_type_name(), $sformatf("AXI read response error: rresp=0x%0h", vif.rresp))
      end
      @(posedge vif.aclk);
      vif.rready <= 1'b0;

      `uvm_info(get_type_name(), $sformatf(
        "BFM read complete addr=0x%0h data=0x%0h", addr, data), UVM_MEDIUM)
    endtask

    virtual task wait_cycles(input int unsigned cycles);
      init();
      repeat (cycles) @(posedge vif.aclk);
    endtask
  endclass
endpackage
