// ============================================================================
// Filename             : axi_write_if.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_WRITE_IF_SV
`define AXI_WRITE_IF_SV
`include "axi_common_defines.svh"
interface axi_write_if #(
    parameter int unsigned ID_WIDTH   = 4,
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned DATA_WIDTH = 64,
    parameter int unsigned USER_WIDTH = 1
) (
    input bit clk,
    input bit reset
);
    import axi_param_rules_pkg::*;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int AXI_MASTER_WRITE_COV_SCENE_SAME_CYCLE = 0;
    localparam int AXI_MASTER_WRITE_COV_SCENE_AW_BEFORE  = 1;
    localparam int AXI_MASTER_WRITE_COV_SCENE_W_BEFORE   = 2;
    localparam bit [STRB_WIDTH-1:0] AXI_MASTER_WRITE_COV_STRB_ALL  = '1;
    localparam bit [STRB_WIDTH-1:0] AXI_MASTER_WRITE_COV_STRB_LOW  = {{(STRB_WIDTH-1){1'b0}}, 1'b1};
    localparam bit [STRB_WIDTH-1:0] AXI_MASTER_WRITE_COV_STRB_HIGH = {1'b1, {(STRB_WIDTH-1){1'b0}}};

    initial begin : validate_axi_write_if_parameters
        if (!is_valid_endpoint_shape(
                ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH)) begin
            $fatal(1,
                {"Invalid axi_write_if parameters: ID_WIDTH=%0d ",
                 "ADDR_WIDTH=%0d DATA_WIDTH=%0d USER_WIDTH=%0d"},
                ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH);
        end
    end

    // Coverage is a VIP observation switch. Keep it in the interface so tb/test
    // can control sampling without mixing it into stimulus config.
    bit coverage_enable = 1'b1;

    int unsigned cov_outstanding_depth;
    int unsigned cov_aw_w_scene;
    int unsigned cov_aw_w_delay;
    bit          cov_aw_active;
    bit          cov_w_burst_active;
    longint unsigned cov_cycle_idx;
    longint unsigned cov_aw_issue_cycle_q[$];
    longint unsigned cov_w_issue_cycle_q[$];
    longint unsigned cov_paired_aw_cycle;
    longint unsigned cov_paired_w_cycle;

    //
    // User signals declare
    //
    // reset follows the original template convention:
    // reset == 0 means reset asserted, reset == 1 means normal running.
    // Public AXI signals are resolved nets. Clocking blocks drive only the
    // private variables below, and inactive VIP roles are disconnected as Z.
    tri                      awvalid;
    tri                      awready;
    tri [ID_WIDTH-1:0]       awid;
    tri [ADDR_WIDTH-1:0]     awaddr;
    tri [7:0]                awlen;
    tri [2:0]                awsize;
    tri [1:0]                awburst;
    tri                      awlock;
    tri [3:0]                awcache;
    tri [2:0]                awprot;
    tri [3:0]                awqos;
    tri [3:0]                awregion;
    tri [USER_WIDTH-1:0]     awuser;

    tri                      wvalid;
    tri                      wready;
    tri [DATA_WIDTH-1:0]     wdata;
    tri [STRB_WIDTH-1:0]     wstrb;
    tri                      wlast;
    tri [USER_WIDTH-1:0]     wuser;

    tri                      bvalid;
    tri                      bready;
    tri [ID_WIDTH-1:0]       bid;
    tri [1:0]                bresp;
    tri [USER_WIDTH-1:0]     buser;

    bit master_driver_enable = 1'b0;
    bit slaver_driver_enable  = 1'b0;

    logic                    master_awvalid_drv = 1'b0;
    logic [ID_WIDTH-1:0]     master_awid_drv = '0;
    logic [ADDR_WIDTH-1:0]   master_awaddr_drv = '0;
    logic [7:0]              master_awlen_drv = '0;
    logic [2:0]              master_awsize_drv = '0;
    logic [1:0]              master_awburst_drv = '0;
    logic                    master_awlock_drv = 1'b0;
    logic [3:0]              master_awcache_drv = '0;
    logic [2:0]              master_awprot_drv = '0;
    logic [3:0]              master_awqos_drv = '0;
    logic [3:0]              master_awregion_drv = '0;
    logic [USER_WIDTH-1:0]   master_awuser_drv = '0;
    logic                    master_wvalid_drv = 1'b0;
    logic [DATA_WIDTH-1:0]   master_wdata_drv = '0;
    logic [STRB_WIDTH-1:0]   master_wstrb_drv = '0;
    logic                    master_wlast_drv = 1'b0;
    logic [USER_WIDTH-1:0]   master_wuser_drv = '0;
    logic                    master_bready_drv = 1'b0;

    logic                    slaver_awready_drv = 1'b0;
    logic                    slaver_wready_drv = 1'b0;
    logic                    slaver_bvalid_drv = 1'b0;
    logic [ID_WIDTH-1:0]     slaver_bid_drv = '0;
    logic [1:0]              slaver_bresp_drv = '0;
    logic [USER_WIDTH-1:0]   slaver_buser_drv = '0;

    assign awvalid  = master_driver_enable ? master_awvalid_drv  : 'z;
    assign awid     = master_driver_enable ? master_awid_drv     : 'z;
    assign awaddr   = master_driver_enable ? master_awaddr_drv   : 'z;
    assign awlen    = master_driver_enable ? master_awlen_drv    : 'z;
    assign awsize   = master_driver_enable ? master_awsize_drv   : 'z;
    assign awburst  = master_driver_enable ? master_awburst_drv  : 'z;
    assign awlock   = master_driver_enable ? master_awlock_drv   : 'z;
    assign awcache  = master_driver_enable ? master_awcache_drv  : 'z;
    assign awprot   = master_driver_enable ? master_awprot_drv   : 'z;
    assign awqos    = master_driver_enable ? master_awqos_drv    : 'z;
    assign awregion = master_driver_enable ? master_awregion_drv : 'z;
    assign awuser   = master_driver_enable ? master_awuser_drv   : 'z;
    assign wvalid   = master_driver_enable ? master_wvalid_drv   : 'z;
    assign wdata    = master_driver_enable ? master_wdata_drv    : 'z;
    assign wstrb    = master_driver_enable ? master_wstrb_drv    : 'z;
    assign wlast    = master_driver_enable ? master_wlast_drv    : 'z;
    assign wuser    = master_driver_enable ? master_wuser_drv    : 'z;
    assign bready   = master_driver_enable ? master_bready_drv   : 'z;

    assign awready = slaver_driver_enable ? slaver_awready_drv : 'z;
    assign wready  = slaver_driver_enable ? slaver_wready_drv  : 'z;
    assign bvalid  = slaver_driver_enable ? slaver_bvalid_drv  : 'z;
    assign bid     = slaver_driver_enable ? slaver_bid_drv     : 'z;
    assign bresp   = slaver_driver_enable ? slaver_bresp_drv   : 'z;
    assign buser   = slaver_driver_enable ? slaver_buser_drv   : 'z;

    function void set_master_driver_enable(bit enable);
        master_driver_enable = enable;
    endfunction : set_master_driver_enable

    function void set_slaver_driver_enable(bit enable);
        slaver_driver_enable = enable;
    endfunction : set_slaver_driver_enable

    wire cov_aw_hs    = awvalid && awready;
    wire cov_w_hs     = wvalid && wready;
    wire cov_aw_start = awvalid && !cov_aw_active;
    wire cov_w_start  = wvalid && !cov_w_burst_active;

    //
    // Clocking blocks declare
    //
    clocking master_drv_cb@(posedge clk);
        input                   reset;
        output                  awvalid = master_awvalid_drv;
        input                   awready;
        output                  awid = master_awid_drv;
        output                  awaddr = master_awaddr_drv;
        output                  awlen = master_awlen_drv;
        output                  awsize = master_awsize_drv;
        output                  awburst = master_awburst_drv;
        output                  awlock = master_awlock_drv;
        output                  awcache = master_awcache_drv;
        output                  awprot = master_awprot_drv;
        output                  awqos = master_awqos_drv;
        output                  awregion = master_awregion_drv;
        output                  awuser = master_awuser_drv;

        output                  wvalid = master_wvalid_drv;
        input                   wready;
        output                  wdata = master_wdata_drv;
        output                  wstrb = master_wstrb_drv;
        output                  wlast = master_wlast_drv;
        output                  wuser = master_wuser_drv;

        input                   bvalid;
        output                  bready = master_bready_drv;
        input                   bid;
        input                   bresp;
        input                   buser;
    endclocking

    clocking slaver_drv_cb @(posedge clk);
        input                   reset;
        input                   awvalid;
        output                  awready = slaver_awready_drv;
        input                   awid;
        input                   awaddr;
        input                   awlen;
        input                   awsize;
        input                   awburst;
        input                   awlock;
        input                   awcache;
        input                   awprot;
        input                   awqos;
        input                   awregion;
        input                   awuser;

        input                   wvalid;
        output                  wready = slaver_wready_drv;
        input                   wdata;
        input                   wstrb;
        input                   wlast;
        input                   wuser;

        output                  bvalid = slaver_bvalid_drv;
        input                   bready;
        output                  bid = slaver_bid_drv;
        output                  bresp = slaver_bresp_drv;
        output                  buser = slaver_buser_drv;
    endclocking

    clocking mon_cb@(posedge clk);
        input                   reset;
        input                   awvalid;
        input                   awready;
        input                   awid;
        input                   awaddr;
        input                   awlen;
        input                   awsize;
        input                   awburst;
        input                   awlock;
        input                   awcache;
        input                   awprot;
        input                   awqos;
        input                   awregion;
        input                   awuser;

        input                   wvalid;
        input                   wready;
        input                   wdata;
        input                   wstrb;
        input                   wlast;
        input                   wuser;

        input                   bvalid;
        input                   bready;
        input                   bid;
        input                   bresp;
        input                   buser;
    endclocking

    //----------------------------------------
    // Driver modport: needed only when this UVC is active (instantiates a
    // driver). A monitor-only UVC does not use it.
    modport MASTER_DRV(
        input   clk,
        input   reset,
        output  awvalid,
        input   awready,
        output  awid,
        output  awaddr,
        output  awlen,
        output  awsize,
        output  awburst,
        output  awlock,
        output  awcache,
        output  awprot,
        output  awqos,
        output  awregion,
        output  awuser,
        output  wvalid,
        input   wready,
        output  wdata,
        output  wstrb,
        output  wlast,
        output  wuser,
        input   bvalid,
        output  bready,
        input   bid,
        input   bresp,
        input   buser
    );
    //----------------------------------------

    modport SLAVER_DRV(
        input   clk,
        input   reset,
        input   awvalid,
        output  awready,
        input   awid,
        input   awaddr,
        input   awlen,
        input   awsize,
        input   awburst,
        input   awlock,
        input   awcache,
        input   awprot,
        input   awqos,
        input   awregion,
        input   awuser,
        input   wvalid,
        output  wready,
        input   wdata,
        input   wstrb,
        input   wlast,
        input   wuser,
        output  bvalid,
        input   bready,
        output  bid,
        output  bresp,
        output  buser
    );

    //----------------------------------------
    //always needed
    modport MON(
        input   clk,
        input   reset,
        input   awvalid,
        input   awready,
        input   awid,
        input   awaddr,
        input   awlen,
        input   awsize,
        input   awburst,
        input   awlock,
        input   awcache,
        input   awprot,
        input   awqos,
        input   awregion,
        input   awuser,
        input   wvalid,
        input   wready,
        input   wdata,
        input   wstrb,
        input   wlast,
        input   wuser,
        input   bvalid,
        input   bready,
        input   bid,
        input   bresp,
        input   buser
    );

    //----------------------------------------
    // Functional coverage
    //----------------------------------------
    function automatic bit cov_can_sample();
        return reset && coverage_enable;
    endfunction : cov_can_sample

    covergroup axi_master_write_burst_cg @(posedge clk iff (reset && coverage_enable));
        awburst_cp: coverpoint awburst iff (awvalid && awready) {
            bins fixed = {2'b00};
            bins incr  = {2'b01};
            bins wrap  = {2'b10};
            // Protocol legality is owned by axi_write_monitor and gated by
            // checks_enable.  Coverage must not emit an independent error
            // when protocol checks are intentionally disabled.
            ignore_bins reserved = {2'b11};
        }
    endgroup : axi_master_write_burst_cg

    covergroup axi_master_write_size_len_cg @(posedge clk iff (reset && coverage_enable));
        awsize_cp: coverpoint awsize iff (awvalid && awready) {
            bins size_1B   = {3'd0};
            bins size_2B   = {3'd1};
            bins size_4B   = {3'd2};
            bins size_8B   = {3'd3};
            bins size_16B  = {3'd4};
            bins size_32B  = {3'd5};
            bins size_64B  = {3'd6};
            bins size_128B = {3'd7};
        }

        awlen_cp: coverpoint awlen iff (awvalid && awready) {
            bins single    = {8'd0};
            bins short     = {[8'd1:8'd3]};
            bins mid       = {[8'd4:8'd7]};
            bins long      = {[8'd8:8'd254]};
            bins max_value = {8'd255};
        }

        awsize_x_awlen: cross awsize_cp, awlen_cp;
    endgroup : axi_master_write_size_len_cg

    covergroup axi_master_write_wstrb_cg @(posedge clk iff (reset && coverage_enable));
        wstrb_cp: coverpoint wstrb iff (wvalid && wready) {
            bins full      = {AXI_MASTER_WRITE_COV_STRB_ALL};
            bins low_byte  = {AXI_MASTER_WRITE_COV_STRB_LOW};
            bins high_byte = {AXI_MASTER_WRITE_COV_STRB_HIGH};
            bins zero      = {'0};
            bins partial   = default;
        }
    endgroup : axi_master_write_wstrb_cg

    covergroup axi_master_write_bresp_cg @(posedge clk iff (reset && coverage_enable));
        bresp_cp: coverpoint bresp iff (bvalid && bready) {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }
    endgroup : axi_master_write_bresp_cg

    covergroup axi_master_write_lock_cg @(posedge clk iff (reset && coverage_enable));
        awlock_cp: coverpoint awlock iff (awvalid && awready) {
            bins normal    = {1'b0};
            bins exclusive = {1'b1};
        }
    endgroup : axi_master_write_lock_cg

    covergroup axi_master_write_aw_w_scene_cg;
        aw_w_scene_cp: coverpoint cov_aw_w_scene {
            bins same_cycle = {AXI_MASTER_WRITE_COV_SCENE_SAME_CYCLE};
            bins aw_before  = {AXI_MASTER_WRITE_COV_SCENE_AW_BEFORE};
            bins w_before   = {AXI_MASTER_WRITE_COV_SCENE_W_BEFORE};
        }

        aw_w_delay_cp: coverpoint cov_aw_w_delay {
            bins same_cycle = {0};
            bins short      = {[1:3]};
            bins mid        = {[4:10]};
            bins long       = {[11:31]};
            bins max_value  = {[32:63]};
            bins over_max   = {[64:1024]};
        }

        aw_w_scene_x_delay: cross aw_w_scene_cp, aw_w_delay_cp {
            ignore_bins same_cycle_nonzero_gap =
                binsof(aw_w_scene_cp.same_cycle) &&
                (binsof(aw_w_delay_cp.short) ||
                 binsof(aw_w_delay_cp.mid) ||
                 binsof(aw_w_delay_cp.long) ||
                 binsof(aw_w_delay_cp.max_value) ||
                 binsof(aw_w_delay_cp.over_max));
            ignore_bins ordered_zero_gap =
                (binsof(aw_w_scene_cp.aw_before) || binsof(aw_w_scene_cp.w_before)) &&
                binsof(aw_w_delay_cp.same_cycle);
        }
    endgroup : axi_master_write_aw_w_scene_cg

    covergroup axi_master_write_outstanding_cg;
        outstanding_depth_cp: coverpoint cov_outstanding_depth {
            bins zero      = {0};
            bins one       = {1};
            bins two_three = {[2:3]};
            bins four_plus = {[4:256]};
        }
    endgroup : axi_master_write_outstanding_cg

    axi_master_write_burst_cg       axi_master_write_burst_cov;
    axi_master_write_size_len_cg    axi_master_write_size_len_cov;
    axi_master_write_wstrb_cg       axi_master_write_wstrb_cov;
    axi_master_write_bresp_cg       axi_master_write_bresp_cov;
    axi_master_write_lock_cg        axi_master_write_lock_cov;
    axi_master_write_aw_w_scene_cg  axi_master_write_aw_w_scene_cov;
    axi_master_write_outstanding_cg axi_master_write_outstanding_cov;

    initial begin
        axi_master_write_burst_cov       = new();
        axi_master_write_size_len_cov    = new();
        axi_master_write_wstrb_cov       = new();
        axi_master_write_bresp_cov       = new();
        axi_master_write_lock_cov        = new();
        axi_master_write_aw_w_scene_cov  = new();
        axi_master_write_outstanding_cov = new();
    end

    function void sample_outstanding_depth(input int unsigned sampled_depth);
        if (cov_can_sample() && axi_master_write_outstanding_cov != null) begin
            cov_outstanding_depth = sampled_depth;
            axi_master_write_outstanding_cov.sample();
        end
    endfunction : sample_outstanding_depth

    function real get_functional_coverage();
        real total;
        total = axi_master_write_burst_cov.get_coverage();
        total += axi_master_write_size_len_cov.get_coverage();
        total += axi_master_write_wstrb_cov.get_coverage();
        total += axi_master_write_bresp_cov.get_coverage();
        total += axi_master_write_lock_cov.get_coverage();
        total += axi_master_write_aw_w_scene_cov.get_coverage();
        total += axi_master_write_outstanding_cov.get_coverage();
        return total / 7.0;
    endfunction : get_functional_coverage

    always @(posedge clk) begin
        if (!reset || !coverage_enable) begin
            cov_aw_w_scene       = AXI_MASTER_WRITE_COV_SCENE_SAME_CYCLE;
            cov_aw_w_delay       = 0;
            cov_aw_active        = 1'b0;
            cov_w_burst_active   = 1'b0;
            cov_cycle_idx        = 0;
            cov_aw_issue_cycle_q.delete();
            cov_w_issue_cycle_q.delete();
        end
        else begin
            cov_cycle_idx++;
            if (cov_aw_start) begin
                cov_aw_issue_cycle_q.push_back(cov_cycle_idx);
            end
            if (cov_w_start) begin
                cov_w_issue_cycle_q.push_back(cov_cycle_idx);
            end

            // AW and first-W observations are paired by ordinal, not by one
            // shared pending bit. This remains correct when a later packet's
            // AW overlaps an earlier packet's unfinished W burst, or vice versa.
            while (cov_aw_issue_cycle_q.size() != 0 &&
                   cov_w_issue_cycle_q.size() != 0) begin
                cov_paired_aw_cycle = cov_aw_issue_cycle_q.pop_front();
                cov_paired_w_cycle  = cov_w_issue_cycle_q.pop_front();
                if (cov_paired_aw_cycle == cov_paired_w_cycle) begin
                    cov_aw_w_scene = AXI_MASTER_WRITE_COV_SCENE_SAME_CYCLE;
                    cov_aw_w_delay = 0;
                end
                else if (cov_paired_aw_cycle < cov_paired_w_cycle) begin
                    cov_aw_w_scene = AXI_MASTER_WRITE_COV_SCENE_AW_BEFORE;
                    cov_aw_w_delay = (cov_paired_w_cycle - cov_paired_aw_cycle > 1023) ?
                        1024 : cov_paired_w_cycle - cov_paired_aw_cycle;
                end
                else begin
                    cov_aw_w_scene = AXI_MASTER_WRITE_COV_SCENE_W_BEFORE;
                    cov_aw_w_delay = (cov_paired_aw_cycle - cov_paired_w_cycle > 1023) ?
                        1024 : cov_paired_aw_cycle - cov_paired_w_cycle;
                end
                if (axi_master_write_aw_w_scene_cov != null) begin
                    axi_master_write_aw_w_scene_cov.sample();
                end
            end

            if (cov_aw_start) begin
                cov_aw_active = 1'b1;
            end
            if (!awvalid || cov_aw_hs) begin
                cov_aw_active = 1'b0;
            end

            if (cov_w_start) begin
                cov_w_burst_active = 1'b1;
            end
            if (cov_w_hs && wlast) begin
                cov_w_burst_active = 1'b0;
            end
        end
    end

endinterface : axi_write_if
`endif
