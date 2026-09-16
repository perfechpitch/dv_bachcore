    `timescale 1ns/1ps

`include "uvm_macros.svh"
`include "svt_axi_if.svi"
`include "svt_apb_if.svi"

module tb_top;

    import uvm_pkg::*;
    import svt_uvm_pkg::*;
    import svt_axi_uvm_pkg::*;
    import svt_apb_uvm_pkg::*;

    // ============================================================
    // Clock / Reset
    // ============================================================

    logic bach_core_clk;
    logic scp_ctrl_aclk;
    logic dmi_pclk;

    logic bach_core_rstn;
    logic mem_rstn;
    logic scp_ctrl_arstn;
    logic dmi_presetn;
    logic scan_rstn;

    logic scan_mode;


    // ============================================================
    // CTI / Interrupt
    // ============================================================

    logic [CTI_WIDTH-1:0] cti_i;
    logic [CTI_WIDTH-1:0] cti_o;
    logic                 bach_core_int;


    // ============================================================
    // Clock Generator
    // ============================================================

    clk_gen u_clk_gen (
        .bach_core_clk (bach_core_clk),
        .scp_ctrl_aclk (scp_ctrl_aclk),
        .dmi_pclk      (dmi_pclk)
    );


    // ============================================================
    // Reset Generator
    // ============================================================

    rst_gen u_rst_gen (
        .bach_core_rstn (bach_core_rstn),
        .mem_rstn       (mem_rstn),
        .scp_ctrl_arstn (scp_ctrl_arstn),
        .dmi_presetn    (dmi_presetn),
        .scan_rstn      (scan_rstn)
    );


    // ============================================================
    // Router Interface
    // ============================================================

    router_if router_if_i (
        .clk   (bach_core_clk),
        .rst_n (bach_core_rstn)
    );


    // ============================================================
    // Synopsys VIP Interfaces
    // ============================================================

    svt_axi_if scp_ctrl_axi_if();
    svt_apb_if dmi_apb_if();


    assign scp_ctrl_axi_if.common_aclk =
        scp_ctrl_aclk;

    assign scp_ctrl_axi_if.master_if[0].aresetn =
        scp_ctrl_arstn;


    // APB clock/reset exact member names:
    // connect according to installed SVT APB VIP version.


    // ============================================================
    // Static Input
    // ============================================================

    initial begin
        scan_mode = 1'b0;
        cti_i     = '0;
    end


    // ============================================================
    // DUT
    // ============================================================

    bach_core_top #(
        .DATA_WIDTH        (DATA_WIDTH),
        .ADDR_WIDTH        (ADDR_WIDTH),
        .ID_WIDTH          (ID_WIDTH),
        .USER_WIDTH        (USER_WIDTH),
        .STRB_WIDTH        (STRB_WIDTH),
        .UID_W             (UID_W),
        .PID_W             (PID_W),
        .PARTID_W          (PARTID_W),
        .CTI_WIDTH         (CTI_WIDTH),
        .PACKAGE_HEAD_W    (PACKAGE_HEAD_W),
        .PACKAGE_DATA_W    (PACKAGE_DATA_W)
    ) u_bach_core (
    // ============================================================
    // Clock / Reset
    // ============================================================

    .bach_core_clk              (bach_core_clk),
    .bach_core_rstn             (bach_core_rstn),
    .mem_rstn                   (mem_rstn),

    .scp_ctrl_aclk              (scp_ctrl_aclk),
    .scp_ctrl_arstn             (scp_ctrl_arstn),

    .dmi_pclk                   (dmi_pclk),
    .dmi_presetn                (dmi_presetn),

    .scan_mode                  (scan_mode),
    .scan_rstn                  (scan_rstn),


    // ============================================================
    // CTI / Interrupt
    // ============================================================

    .cti_i                      (cti_i),
    .cti_o                      (cti_o),
    .bach_core_int              (bach_core_int),


    // ============================================================
    // Router -> TS
    // ============================================================

    .r2t_trigger_uid            (router_if_i.r2t_trigger_uid),
    .r2t_trigger_pid            (router_if_i.r2t_trigger_pid),
    .r2t_trigger_reissue        (router_if_i.r2t_trigger_reissue),
    .r2t_trigger_task_exe       (router_if_i.r2t_trigger_task_exe),
    .r2t_trigger_valid          (router_if_i.r2t_trigger_valid),
    .r2t_trigger_ready          (router_if_i.r2t_trigger_ready),

    .t2r_credit_release_uid     (router_if_i.t2r_credit_release_uid),
    .t2r_credit_release_valid   (router_if_i.t2r_credit_release_valid),


    // ============================================================
    // Router -> DTE Credit
    // ============================================================

    .r2dte_credit_e_uid         (router_if_i.r2dte_credit_e_uid),
    .r2dte_credit_e_valid       (router_if_i.r2dte_credit_e_valid),

    .r2dte_credit_w_uid         (router_if_i.r2dte_credit_w_uid),
    .r2dte_credit_w_valid       (router_if_i.r2dte_credit_w_valid),

    .r2dte_credit_ns_uid        (router_if_i.r2dte_credit_ns_uid),
    .r2dte_credit_ns_valid      (router_if_i.r2dte_credit_ns_valid),

    .rmem2ts_credit_done_uid    (router_if_i.rmem2ts_credit_done_uid),
    .rmem2ts_credit_done_valid  (router_if_i.rmem2ts_credit_done_valid),


    // ============================================================
    // MSG IN : Router -> DTE
    // ============================================================

    .r2core_hflit               (router_if_i.r2core_hflit),
    .r2core_pflit               (router_if_i.r2core_pflit),
    .r2core_head                (router_if_i.r2core_head),
    .r2core_tail                (router_if_i.r2core_tail),
    .r2core_vld                 (router_if_i.r2core_vld),
    .core2r_rdy                 (router_if_i.core2r_rdy),


    // ============================================================
    // MSG OUT : DTE -> Router
    // ============================================================

    .core2r_hflit               (router_if_i.core2r_hflit),
    .core2r_pflit               (router_if_i.core2r_pflit),
    .core2r_head                (router_if_i.core2r_head),
    .core2r_tail                (router_if_i.core2r_tail),
    .core2r_vld                 (router_if_i.core2r_vld),

    .r2core_credit_vld          (router_if_i.r2core_credit_vld),
    .r2core_credit_vcid         (router_if_i.r2core_credit_vcid),


    // ============================================================
    // SCP CTRL AXI
    // ============================================================

    .scp_ctrl_awid              (scp_ctrl_axi_if.master_if[0].awid),
    .scp_ctrl_awaddr            (scp_ctrl_axi_if.master_if[0].awaddr),
    .scp_ctrl_awlen             (scp_ctrl_axi_if.master_if[0].awlen),
    .scp_ctrl_awsize            (scp_ctrl_axi_if.master_if[0].awsize),
    .scp_ctrl_awburst           (scp_ctrl_axi_if.master_if[0].awburst),
    .scp_ctrl_awvalid           (scp_ctrl_axi_if.master_if[0].awvalid),
    .scp_ctrl_awready           (scp_ctrl_axi_if.master_if[0].awready),

    .scp_ctrl_wdata             (scp_ctrl_axi_if.master_if[0].wdata),
    .scp_ctrl_wstrb             (scp_ctrl_axi_if.master_if[0].wstrb),
    .scp_ctrl_wlast             (scp_ctrl_axi_if.master_if[0].wlast),
    .scp_ctrl_wvalid            (scp_ctrl_axi_if.master_if[0].wvalid),
    .scp_ctrl_wready            (scp_ctrl_axi_if.master_if[0].wready),

    .scp_ctrl_bid               (scp_ctrl_axi_if.master_if[0].bid),
    .scp_ctrl_bresp             (scp_ctrl_axi_if.master_if[0].bresp),
    .scp_ctrl_bvalid            (scp_ctrl_axi_if.master_if[0].bvalid),
    .scp_ctrl_bready            (scp_ctrl_axi_if.master_if[0].bready),

    .scp_ctrl_arid              (scp_ctrl_axi_if.master_if[0].arid),
    .scp_ctrl_araddr            (scp_ctrl_axi_if.master_if[0].araddr),
    .scp_ctrl_arlen             (scp_ctrl_axi_if.master_if[0].arlen),
    .scp_ctrl_arsize            (scp_ctrl_axi_if.master_if[0].arsize),
    .scp_ctrl_arburst           (scp_ctrl_axi_if.master_if[0].arburst),
    .scp_ctrl_arvalid           (scp_ctrl_axi_if.master_if[0].arvalid),
    .scp_ctrl_arready           (scp_ctrl_axi_if.master_if[0].arready),

    .scp_ctrl_rid               (scp_ctrl_axi_if.master_if[0].rid),
    .scp_ctrl_rdata             (scp_ctrl_axi_if.master_if[0].rdata),
    .scp_ctrl_rresp             (scp_ctrl_axi_if.master_if[0].rresp),
    .scp_ctrl_rlast             (scp_ctrl_axi_if.master_if[0].rlast),
    .scp_ctrl_rvalid            (scp_ctrl_axi_if.master_if[0].rvalid),
    .scp_ctrl_rready            (scp_ctrl_axi_if.master_if[0].rready),


    // ============================================================
    // DMI APB
    // ============================================================

    .dmi_paddr                  (dmi_apb_if.master_if[0].paddr),
    .dmi_psel                   (dmi_apb_if.master_if[0].psel),
    .dmi_penable                (dmi_apb_if.master_if[0].penable),
    .dmi_pwrite                 (dmi_apb_if.master_if[0].pwrite),
    .dmi_pwdata                 (dmi_apb_if.master_if[0].pwdata),
    .dmi_pstrb                  (dmi_apb_if.master_if[0].pstrb),
    .dmi_pprot                  (dmi_apb_if.master_if[0].pprot),

    .dmi_prdata                 (dmi_apb_if.master_if[0].prdata),
    .dmi_pready                 (dmi_apb_if.master_if[0].pready),
    .dmi_pslverr                (dmi_apb_if.master_if[0].pslverr)
    );

    // Verification-only internal DUT connections
    `include "dut_connect.svh"
    // ============================================================
    // UVM
    // ============================================================

    initial begin
        uvm_config_db#(virtual router_if)::set(
            null,
            "*",
            "vif",
            router_if_i
        );

        run_test();
    end

endmodule