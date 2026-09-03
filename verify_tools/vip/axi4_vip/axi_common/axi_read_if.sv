// ============================================================================
// Filename             : axi_read_if.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_READ_IF_SV
`define AXI_READ_IF_SV
`include "axi_common_defines.svh"

interface axi_read_if #(
    parameter int unsigned ID_WIDTH   = 4,
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned DATA_WIDTH = 64,
    parameter int unsigned USER_WIDTH = 1
) (
    input bit clk,
    input bit reset
);
    import axi_param_rules_pkg::*;

    initial begin : validate_axi_read_if_parameters
        if (!is_valid_endpoint_shape(
                ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH)) begin
            $fatal(1,
                {"Invalid axi_read_if parameters: ID_WIDTH=%0d ",
                 "ADDR_WIDTH=%0d DATA_WIDTH=%0d USER_WIDTH=%0d"},
                ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH);
        end
    end

    bit coverage_enable = 1'b1;
    int unsigned cov_outstanding_depth;

    //
    // User signals declare
    //
    // reset follows the original template convention:
    // reset == 0 means reset asserted, reset == 1 means normal running.
    // Public AXI signals are resolved nets. VIP clocking blocks drive private
    // variables below; one continuous driver per role connects those variables
    // only when the owning leaf driver is active. This keeps an external DUT's
    // structural outputs separate from UVM procedural clocking-block outputs.
    tri                      arvalid;
    tri                      arready;
    tri [ID_WIDTH-1:0]       arid;
    tri [ADDR_WIDTH-1:0]     araddr;
    tri [7:0]                arlen;
    tri [2:0]                arsize;
    tri [1:0]                arburst;
    tri                      arlock;
    tri [3:0]                arcache;
    tri [2:0]                arprot;
    tri [3:0]                arqos;
    tri [3:0]                arregion;
    tri [USER_WIDTH-1:0]     aruser;

    tri                      rvalid;
    tri                      rready;
    tri [ID_WIDTH-1:0]       rid;
    tri [DATA_WIDTH-1:0]     rdata;
    tri [1:0]                rresp;
    tri                      rlast;
    tri [USER_WIDTH-1:0]     ruser;

    bit master_driver_enable = 1'b0;
    bit slaver_driver_enable  = 1'b0;

    logic                    master_arvalid_drv = 1'b0;
    logic [ID_WIDTH-1:0]     master_arid_drv = '0;
    logic [ADDR_WIDTH-1:0]   master_araddr_drv = '0;
    logic [7:0]              master_arlen_drv = '0;
    logic [2:0]              master_arsize_drv = '0;
    logic [1:0]              master_arburst_drv = '0;
    logic                    master_arlock_drv = 1'b0;
    logic [3:0]              master_arcache_drv = '0;
    logic [2:0]              master_arprot_drv = '0;
    logic [3:0]              master_arqos_drv = '0;
    logic [3:0]              master_arregion_drv = '0;
    logic [USER_WIDTH-1:0]   master_aruser_drv = '0;
    logic                    master_rready_drv = 1'b0;

    logic                    slaver_arready_drv = 1'b0;
    logic                    slaver_rvalid_drv = 1'b0;
    logic [ID_WIDTH-1:0]     slaver_rid_drv = '0;
    logic [DATA_WIDTH-1:0]   slaver_rdata_drv = '0;
    logic [1:0]              slaver_rresp_drv = '0;
    logic                    slaver_rlast_drv = 1'b0;
    logic [USER_WIDTH-1:0]   slaver_ruser_drv = '0;

    assign arvalid  = master_driver_enable ? master_arvalid_drv  : 'z;
    assign arid     = master_driver_enable ? master_arid_drv     : 'z;
    assign araddr   = master_driver_enable ? master_araddr_drv   : 'z;
    assign arlen    = master_driver_enable ? master_arlen_drv    : 'z;
    assign arsize   = master_driver_enable ? master_arsize_drv   : 'z;
    assign arburst  = master_driver_enable ? master_arburst_drv  : 'z;
    assign arlock   = master_driver_enable ? master_arlock_drv   : 'z;
    assign arcache  = master_driver_enable ? master_arcache_drv  : 'z;
    assign arprot   = master_driver_enable ? master_arprot_drv   : 'z;
    assign arqos    = master_driver_enable ? master_arqos_drv    : 'z;
    assign arregion = master_driver_enable ? master_arregion_drv : 'z;
    assign aruser   = master_driver_enable ? master_aruser_drv   : 'z;
    assign rready   = master_driver_enable ? master_rready_drv   : 'z;

    assign arready = slaver_driver_enable ? slaver_arready_drv : 'z;
    assign rvalid  = slaver_driver_enable ? slaver_rvalid_drv  : 'z;
    assign rid     = slaver_driver_enable ? slaver_rid_drv     : 'z;
    assign rdata   = slaver_driver_enable ? slaver_rdata_drv   : 'z;
    assign rresp   = slaver_driver_enable ? slaver_rresp_drv   : 'z;
    assign rlast   = slaver_driver_enable ? slaver_rlast_drv   : 'z;
    assign ruser   = slaver_driver_enable ? slaver_ruser_drv   : 'z;

    function void set_master_driver_enable(bit enable);
        master_driver_enable = enable;
    endfunction : set_master_driver_enable

    function void set_slaver_driver_enable(bit enable);
        slaver_driver_enable = enable;
    endfunction : set_slaver_driver_enable

    //
    // Clocking blocks declare
    //
    clocking master_drv_cb@(posedge clk);
        input                   reset;
        output                  arvalid = master_arvalid_drv;
        input                   arready;
        output                  arid = master_arid_drv;
        output                  araddr = master_araddr_drv;
        output                  arlen = master_arlen_drv;
        output                  arsize = master_arsize_drv;
        output                  arburst = master_arburst_drv;
        output                  arlock = master_arlock_drv;
        output                  arcache = master_arcache_drv;
        output                  arprot = master_arprot_drv;
        output                  arqos = master_arqos_drv;
        output                  arregion = master_arregion_drv;
        output                  aruser = master_aruser_drv;

        input                   rvalid;
        output                  rready = master_rready_drv;
        input                   rid;
        input                   rdata;
        input                   rresp;
        input                   rlast;
        input                   ruser;
    endclocking

    clocking slaver_drv_cb @(posedge clk);
        input                   reset;
        input                   arvalid;
        output                  arready = slaver_arready_drv;
        input                   arid;
        input                   araddr;
        input                   arlen;
        input                   arsize;
        input                   arburst;
        input                   arlock;
        input                   arcache;
        input                   arprot;
        input                   arqos;
        input                   arregion;
        input                   aruser;

        output                  rvalid = slaver_rvalid_drv;
        input                   rready;
        output                  rid = slaver_rid_drv;
        output                  rdata = slaver_rdata_drv;
        output                  rresp = slaver_rresp_drv;
        output                  rlast = slaver_rlast_drv;
        output                  ruser = slaver_ruser_drv;
    endclocking

    clocking mon_cb@(posedge clk);
        input                   reset;
        input                   arvalid;
        input                   arready;
        input                   arid;
        input                   araddr;
        input                   arlen;
        input                   arsize;
        input                   arburst;
        input                   arlock;
        input                   arcache;
        input                   arprot;
        input                   arqos;
        input                   arregion;
        input                   aruser;

        input                   rvalid;
        input                   rready;
        input                   rid;
        input                   rdata;
        input                   rresp;
        input                   rlast;
        input                   ruser;
    endclocking

    //----------------------------------------
    // Driver modport: needed only when this UVC is active (instantiates a
    // driver). A monitor-only UVC does not use it.
    modport MASTER_DRV(
        input   clk,
        input   reset,
        output  arvalid,
        input   arready,
        output  arid,
        output  araddr,
        output  arlen,
        output  arsize,
        output  arburst,
        output  arlock,
        output  arcache,
        output  arprot,
        output  arqos,
        output  arregion,
        output  aruser,
        input   rvalid,
        output  rready,
        input   rid,
        input   rdata,
        input   rresp,
        input   rlast,
        input   ruser
    );
    //----------------------------------------

    modport SLAVER_DRV(
        input   clk,
        input   reset,
        input   arvalid,
        output  arready,
        input   arid,
        input   araddr,
        input   arlen,
        input   arsize,
        input   arburst,
        input   arlock,
        input   arcache,
        input   arprot,
        input   arqos,
        input   arregion,
        input   aruser,
        output  rvalid,
        input   rready,
        output  rid,
        output  rdata,
        output  rresp,
        output  rlast,
        output  ruser
    );

    //----------------------------------------
    //always needed
    modport MON(
        input   clk,
        input   reset,
        input   arvalid,
        input   arready,
        input   arid,
        input   araddr,
        input   arlen,
        input   arsize,
        input   arburst,
        input   arlock,
        input   arcache,
        input   arprot,
        input   arqos,
        input   arregion,
        input   aruser,
        input   rvalid,
        input   rready,
        input   rid,
        input   rdata,
        input   rresp,
        input   rlast,
        input   ruser
    );

    covergroup axi_master_read_burst_cg @(posedge clk iff (reset && coverage_enable));
        arburst_cp: coverpoint arburst iff (arvalid && arready) {
            bins fixed = {2'b00};
            bins incr  = {2'b01};
            bins wrap  = {2'b10};
            // Protocol legality is owned by axi_read_monitor and gated by
            // checks_enable.  Coverage must not emit an independent error
            // when protocol checks are intentionally disabled.
            ignore_bins reserved = {2'b11};
        }
    endgroup : axi_master_read_burst_cg

    covergroup axi_master_read_size_len_cg @(posedge clk iff (reset && coverage_enable));
        arsize_cp: coverpoint arsize iff (arvalid && arready) {
            bins size_1B   = {3'd0};
            bins size_2B   = {3'd1};
            bins size_4B   = {3'd2};
            bins size_8B   = {3'd3};
            bins size_16B  = {3'd4};
            bins size_32B  = {3'd5};
            bins size_64B  = {3'd6};
            bins size_128B = {3'd7};
        }
        arlen_cp: coverpoint arlen iff (arvalid && arready) {
            bins single    = {8'd0};
            bins short     = {[8'd1:8'd3]};
            bins mid       = {[8'd4:8'd7]};
            bins long      = {[8'd8:8'd254]};
            bins max_value = {8'd255};
        }
        arsize_x_arlen: cross arsize_cp, arlen_cp;
    endgroup : axi_master_read_size_len_cg

    covergroup axi_master_read_lock_cg @(posedge clk iff (reset && coverage_enable));
        arlock_cp: coverpoint arlock iff (arvalid && arready) {
            bins normal    = {1'b0};
            bins exclusive = {1'b1};
        }
    endgroup : axi_master_read_lock_cg

    covergroup axi_master_read_rresp_cg @(posedge clk iff (reset && coverage_enable));
        rresp_cp: coverpoint rresp iff (rvalid && rready) {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }
    endgroup : axi_master_read_rresp_cg

    covergroup axi_master_read_outstanding_cg;
        outstanding_depth_cp: coverpoint cov_outstanding_depth {
            bins zero      = {0};
            bins one       = {1};
            bins two_three = {[2:3]};
            bins four_plus = {[4:256]};
        }
    endgroup : axi_master_read_outstanding_cg

    axi_master_read_burst_cg       axi_master_read_burst_cov;
    axi_master_read_size_len_cg    axi_master_read_size_len_cov;
    axi_master_read_lock_cg        axi_master_read_lock_cov;
    axi_master_read_rresp_cg       axi_master_read_rresp_cov;
    axi_master_read_outstanding_cg axi_master_read_outstanding_cov;

    initial begin
        axi_master_read_burst_cov       = new();
        axi_master_read_size_len_cov    = new();
        axi_master_read_lock_cov        = new();
        axi_master_read_rresp_cov       = new();
        axi_master_read_outstanding_cov = new();
    end

    function void sample_outstanding_depth(input int unsigned sampled_depth);
        if (reset && coverage_enable && axi_master_read_outstanding_cov != null) begin
            cov_outstanding_depth = sampled_depth;
            axi_master_read_outstanding_cov.sample();
        end
    endfunction : sample_outstanding_depth

    function real get_functional_coverage();
        real total;
        total = axi_master_read_burst_cov.get_coverage();
        total += axi_master_read_size_len_cov.get_coverage();
        total += axi_master_read_lock_cov.get_coverage();
        total += axi_master_read_rresp_cov.get_coverage();
        total += axi_master_read_outstanding_cov.get_coverage();
        return total / 5.0;
    endfunction : get_functional_coverage
endinterface : axi_read_if
`endif
