`timescale 1ns/1ps
`default_nettype none

// Enable the currently available dummy implementations by default.
// Task Scheduler uses the real task_scheduler_top RTL.
`define SHAREMEM_DUMMY
`define VU_DUMMY
`define DTE_DUMMY
`define CORE_MEM_TOP_DUMMY
`define MU_MMEM_DUMMY
`define AXI2APB_DUMMY
`define CORE_STATUS_DUMMY

// =============================================================================
// Bach core structural integration scaffold.
//
// This top follows the external contract of bach_core_top_dummy_v2 and instantiates
// the currently available dummy blocks.  Every provisional or unmatched
// interface is marked with "TBD" as required by the integration convention.
// The SCP AXI data channel is fixed at 256 bits per the latest integration
// decision; DATA_WIDTH/STRB_WIDTH continue to parameterize the DMI APB port.
//
// Dummy selection macros (enable with iverilog -D<name> or +define+<name>):
//   SHAREMEM_DUMMY, VU_DUMMY, DTE_DUMMY,
//   CORE_MEM_TOP_DUMMY, MU_MMEM_DUMMY, AXI2APB_DUMMY, CORE_STATUS_DUMMY.
// The three latest rv_core_top instances are integrated unconditionally.
// =============================================================================
module bach_core_top #(
    parameter DATA_WIDTH         = 32,
    parameter ADDR_WIDTH         = 32,
    parameter ID_WIDTH           = 4,
    parameter USER_WIDTH         = 4,
    parameter STRB_WIDTH         = DATA_WIDTH/8,
    parameter UID_W              = 16,
    parameter PID_W              = 8,
    parameter PARTID_W           = 4,
    parameter CTI_WIDTH          = 4,
    parameter PACKAGE_HEAD_W     = 256,
    parameter PACKAGE_DATA_W     = 2048
) (
    input  wire                          bach_core_clk,
    input  wire                          bach_core_rstn,
    input  wire                          mem_rstn,
    input  wire                          dmi_pclk,
    input  wire                          dmi_presetn,
    input  wire                          scan_mode,
    input  wire                          scan_rstn,
    input  wire [CTI_WIDTH-1:0]          cti_i,
    output wire [CTI_WIDTH-1:0]          cti_o,

    input  wire                          scp_ctrl_aclk,
    input  wire                          scp_ctrl_arstn,
    input  wire [ID_WIDTH-1:0]           scp_ctrl_awid,
    input  wire [ADDR_WIDTH-1:0]         scp_ctrl_awaddr,
    input  wire [7:0]                    scp_ctrl_awlen,
    input  wire [2:0]                    scp_ctrl_awsize,
    input  wire [1:0]                    scp_ctrl_awburst,
    input  wire                          scp_ctrl_awlock,
    input  wire [3:0]                    scp_ctrl_awcache,
    input  wire [2:0]                    scp_ctrl_awprot,
    input  wire [3:0]                    scp_ctrl_awqos,
    input  wire [3:0]                    scp_ctrl_awregion,
    input  wire [USER_WIDTH-1:0]         scp_ctrl_awuser,
    input  wire                          scp_ctrl_awvalid,
    output wire                          scp_ctrl_awready,
    input  wire [255:0]                  scp_ctrl_wdata,
    input  wire [31:0]                   scp_ctrl_wstrb,
    input  wire                          scp_ctrl_wlast,
    input  wire [USER_WIDTH-1:0]         scp_ctrl_wuser,
    input  wire                          scp_ctrl_wvalid,
    output wire                          scp_ctrl_wready,
    output wire [ID_WIDTH-1:0]           scp_ctrl_bid,
    output wire [1:0]                    scp_ctrl_bresp,
    output wire [USER_WIDTH-1:0]         scp_ctrl_buser,
    output wire                          scp_ctrl_bvalid,
    input  wire                          scp_ctrl_bready,
    input  wire [ID_WIDTH-1:0]           scp_ctrl_arid,
    input  wire [ADDR_WIDTH-1:0]         scp_ctrl_araddr,
    input  wire [7:0]                    scp_ctrl_arlen,
    input  wire [2:0]                    scp_ctrl_arsize,
    input  wire [1:0]                    scp_ctrl_arburst,
    input  wire                          scp_ctrl_arlock,
    input  wire [3:0]                    scp_ctrl_arcache,
    input  wire [2:0]                    scp_ctrl_arprot,
    input  wire [3:0]                    scp_ctrl_arqos,
    input  wire [3:0]                    scp_ctrl_arregion,
    input  wire [USER_WIDTH-1:0]         scp_ctrl_aruser,
    input  wire                          scp_ctrl_arvalid,
    output wire                          scp_ctrl_arready,
    output wire [ID_WIDTH-1:0]           scp_ctrl_rid,
    output wire [255:0]                  scp_ctrl_rdata,
    output wire [1:0]                    scp_ctrl_rresp,
    output wire                          scp_ctrl_rlast,
    output wire [USER_WIDTH-1:0]         scp_ctrl_ruser,
    output wire                          scp_ctrl_rvalid,
    input  wire                          scp_ctrl_rready,

    input  wire [ADDR_WIDTH-1:0]         dmi_paddr,
    input  wire                          dmi_psel,
    input  wire                          dmi_penable,
    input  wire                          dmi_pwrite,
    input  wire [DATA_WIDTH-1:0]         dmi_pwdata,
    input  wire [STRB_WIDTH-1:0]         dmi_pstrb,
    input  wire [2:0]                    dmi_pprot,
    output wire [DATA_WIDTH-1:0]         dmi_prdata,
    output wire                          dmi_pready,
    output wire                          dmi_pslverr,

    input  wire [UID_W-1:0]              r2t_trigger_uid,
    input  wire [PID_W-1:0]              r2t_trigger_pid,
    input  wire                          r2t_trigger_reissue,
    input  wire                          r2t_trigger_task_exe,
    input  wire                          r2t_trigger_valid,
    output wire                          r2t_trigger_ready,
    output wire [UID_W-1:0]              t2r_credit_release_uid,
    output wire                          t2r_credit_release_valid,

    input  wire [UID_W-1:0]              r2ts_credit_e_uid,
    input  wire                          r2ts_credit_e_valid,
    input  wire [UID_W-1:0]              r2ts_credit_w_uid,
    input  wire                          r2ts_credit_w_valid,
    input  wire [UID_W-1:0]              r2ts_credit_ns_uid,
    input  wire                          r2ts_credit_ns_valid,
    input  wire [UID_W-1:0]              rmem2ts_credit_done_uid,
    input  wire                          rmem2ts_credit_done_valid,

    input  wire [PACKAGE_HEAD_W-1:0]     r2core_hflit,
    input  wire [PACKAGE_DATA_W-1:0]     r2core_pflit,
    input  wire                          r2core_head,
    input  wire                          r2core_tail,
    input  wire                          r2core_vld,
    output wire                          core2r_rdy,
    output wire [PACKAGE_HEAD_W-1:0]     core2r_hflit,
    output wire [PACKAGE_DATA_W-1:0]     core2r_pflit,
    output wire                          core2r_head,
    output wire                          core2r_tail,
    output wire                          core2r_vld,
    input  wire                          r2core_credit_vld,
    input  wire [4:0]                    r2core_credit_vcid,
    output wire                          bach_core_int
);

    // -------------------------------------------------------------------------
    // SCP AXI4 -> internal APB3 integration dummy.
    // -------------------------------------------------------------------------
    // TBD: The external AXI LEN is 8 bits while the bridge LEN is 4 bits. Only
    // the low four bits are connected until the intended maximum burst is fixed.
    // The complete upstream AXI ID/User/Lock/Cache/Prot/QoS/Region interface is
    // connected to the bridge. Downstream decode/routing remains dummy behavior.
    // AXI2APB dummy core_mem_s master channel -> core_mem_top_dummy NoC slave.
    wire [0:0]   coremem_axi_awid;
    wire [20:0]  coremem_axi_awaddr;
    wire [3:0]   coremem_axi_awlen;
    wire [2:0]   coremem_axi_awsize;
    wire [1:0]   coremem_axi_awburst;
    wire         coremem_axi_awvalid;
    wire         coremem_axi_awready;
    wire [255:0] coremem_axi_wdata;
    wire [31:0]  coremem_axi_wstrb;
    wire         coremem_axi_wlast;
    wire         coremem_axi_wvalid;
    wire         coremem_axi_wready;
    wire [0:0]   coremem_axi_bid;
    wire [1:0]   coremem_axi_bresp;
    wire         coremem_axi_bvalid;
    wire         coremem_axi_bready;
    wire [0:0]   coremem_axi_arid;
    wire [20:0]  coremem_axi_araddr;
    wire [3:0]   coremem_axi_arlen;
    wire [2:0]   coremem_axi_arsize;
    wire [1:0]   coremem_axi_arburst;
    wire         coremem_axi_arvalid;
    wire         coremem_axi_arready;
    wire [0:0]   coremem_axi_rid;
    wire [255:0] coremem_axi_rdata;
    wire [1:0]   coremem_axi_rresp;
    wire         coremem_axi_rlast;
    wire         coremem_axi_rvalid;
    wire         coremem_axi_rready;

    // AXI2APB dummy matrix_mem_s master channel -> combined MU/MMEM dummy.
    wire [0:0]   mmem_axi_awid;
    wire [25:0]  mmem_axi_awaddr;
    wire [3:0]   mmem_axi_awlen;
    wire [2:0]   mmem_axi_awsize;
    wire [1:0]   mmem_axi_awburst;
    wire         mmem_axi_awvalid;
    wire         mmem_axi_awready;
    wire [255:0] mmem_axi_wdata;
    wire [31:0]  mmem_axi_wstrb;
    wire         mmem_axi_wlast;
    wire         mmem_axi_wvalid;
    wire         mmem_axi_wready;
    wire [0:0]   mmem_axi_bid;
    wire [1:0]   mmem_axi_bresp;
    wire         mmem_axi_bvalid;
    wire         mmem_axi_bready;
    wire [0:0]   mmem_axi_arid;
    wire [25:0]  mmem_axi_araddr;
    wire [3:0]   mmem_axi_arlen;
    wire [2:0]   mmem_axi_arsize;
    wire [1:0]   mmem_axi_arburst;
    wire         mmem_axi_arvalid;
    wire         mmem_axi_arready;
    wire [0:0]   mmem_axi_rid;
    wire [255:0] mmem_axi_rdata;
    wire [1:0]   mmem_axi_rresp;
    wire         mmem_axi_rlast;
    wire         mmem_axi_rvalid;
    wire         mmem_axi_rready;

    // AXI2APB dummy share_mem_s master channel -> sharemem_dummy AXI slave.
    wire [3:0]   sharemem_axi_awid;
    wire [16:0]  sharemem_axi_awaddr;
    wire [3:0]   sharemem_axi_awlen;
    wire [2:0]   sharemem_axi_awsize;
    wire [1:0]   sharemem_axi_awburst;
    wire         sharemem_axi_awlock;
    wire [3:0]   sharemem_axi_awcache;
    wire [2:0]   sharemem_axi_awprot;
    wire [3:0]   sharemem_axi_awqos;
    wire [3:0]   sharemem_axi_awregion;
    wire         sharemem_axi_awvalid;
    wire         sharemem_axi_awready;
    wire [31:0]  sharemem_axi_wdata;
    wire [3:0]   sharemem_axi_wstrb;
    wire         sharemem_axi_wlast;
    wire         sharemem_axi_wvalid;
    wire         sharemem_axi_wready;
    wire [3:0]   sharemem_axi_bid;
    wire [1:0]   sharemem_axi_bresp;
    wire         sharemem_axi_bvalid;
    wire         sharemem_axi_bready;
    wire [3:0]   sharemem_axi_arid;
    wire [16:0]  sharemem_axi_araddr;
    wire [3:0]   sharemem_axi_arlen;
    wire [2:0]   sharemem_axi_arsize;
    wire [1:0]   sharemem_axi_arburst;
    wire         sharemem_axi_arlock;
    wire [3:0]   sharemem_axi_arcache;
    wire [2:0]   sharemem_axi_arprot;
    wire [3:0]   sharemem_axi_arqos;
    wire [3:0]   sharemem_axi_arregion;
    wire         sharemem_axi_arvalid;
    wire         sharemem_axi_arready;
    wire [3:0]   sharemem_axi_rid;
    wire [31:0]  sharemem_axi_rdata;
    wire [1:0]   sharemem_axi_rresp;
    wire         sharemem_axi_rlast;
    wire         sharemem_axi_rvalid;
    wire         sharemem_axi_rready;

    wire         bridge_apb_pclk;
    wire         bridge_apb_presetn;

    wire [14:0]  bridge_core_status_paddr;
    wire         bridge_core_status_psel;
    wire         bridge_core_status_penable;
    wire         bridge_core_status_pwrite;
    wire [31:0]  bridge_core_status_pwdata;
    wire [31:0]  bridge_core_status_prdata;
    wire         bridge_core_status_pready;
    wire         bridge_core_status_pslverr;
    wire         vu_dsa_err_irq;
    wire         coremem_scp_ecc_err;

    wire [14:0]  bridge_ts_paddr;
    wire         bridge_ts_psel;
    wire         bridge_ts_penable;
    wire         bridge_ts_pwrite;
    wire [31:0]  bridge_ts_pwdata;
    wire [31:0]  bridge_ts_prdata;
    wire         bridge_ts_pready;
    wire         bridge_ts_pslverr;

    wire [14:0]  bridge_dte_core_paddr;
    wire         bridge_dte_core_psel;
    wire         bridge_dte_core_penable;
    wire         bridge_dte_core_pwrite;
    wire [31:0]  bridge_dte_core_pwdata;
    wire [31:0]  bridge_dte_core_prdata;
    wire         bridge_dte_core_pready;
    wire         bridge_dte_core_pslverr;

    wire [14:0]  bridge_mu_core_paddr;
    wire         bridge_mu_core_psel;
    wire         bridge_mu_core_penable;
    wire         bridge_mu_core_pwrite;
    wire [31:0]  bridge_mu_core_pwdata;
    wire [31:0]  bridge_mu_core_prdata;
    wire         bridge_mu_core_pready;
    wire         bridge_mu_core_pslverr;

    wire [14:0]  bridge_vu_core_paddr;
    wire         bridge_vu_core_psel;
    wire         bridge_vu_core_penable;
    wire         bridge_vu_core_pwrite;
    wire [31:0]  bridge_vu_core_pwdata;
    wire [31:0]  bridge_vu_core_prdata;
    wire         bridge_vu_core_pready;
    wire         bridge_vu_core_pslverr;

    wire [14:0]  bridge_dte_itcm_paddr;
    wire         bridge_dte_itcm_psel;
    wire         bridge_dte_itcm_penable;
    wire         bridge_dte_itcm_pwrite;
    wire [31:0]  bridge_dte_itcm_pwdata;
    wire [31:0]  bridge_dte_itcm_prdata;
    wire         bridge_dte_itcm_pready;
    wire         bridge_dte_itcm_pslverr;

    wire [14:0]  bridge_mu_itcm_paddr;
    wire         bridge_mu_itcm_psel;
    wire         bridge_mu_itcm_penable;
    wire         bridge_mu_itcm_pwrite;
    wire [31:0]  bridge_mu_itcm_pwdata;
    wire [31:0]  bridge_mu_itcm_prdata;
    wire         bridge_mu_itcm_pready;
    wire         bridge_mu_itcm_pslverr;

    wire [14:0]  bridge_vu_itcm_paddr;
    wire         bridge_vu_itcm_psel;
    wire         bridge_vu_itcm_penable;
    wire         bridge_vu_itcm_pwrite;
    wire [31:0]  bridge_vu_itcm_pwdata;
    wire [31:0]  bridge_vu_itcm_prdata;
    wire         bridge_vu_itcm_pready;
    wire         bridge_vu_itcm_pslverr;

    wire [14:0]  bridge_dte_dtcm_paddr;
    wire         bridge_dte_dtcm_psel;
    wire         bridge_dte_dtcm_penable;
    wire         bridge_dte_dtcm_pwrite;
    wire [31:0]  bridge_dte_dtcm_pwdata;
    wire [31:0]  bridge_dte_dtcm_prdata;
    wire         bridge_dte_dtcm_pready;
    wire         bridge_dte_dtcm_pslverr;

    wire [14:0]  bridge_mu_dtcm_paddr;
    wire         bridge_mu_dtcm_psel;
    wire         bridge_mu_dtcm_penable;
    wire         bridge_mu_dtcm_pwrite;
    wire [31:0]  bridge_mu_dtcm_pwdata;
    wire [31:0]  bridge_mu_dtcm_prdata;
    wire         bridge_mu_dtcm_pready;
    wire         bridge_mu_dtcm_pslverr;

    wire [14:0]  bridge_vu_dtcm_paddr;
    wire         bridge_vu_dtcm_psel;
    wire         bridge_vu_dtcm_penable;
    wire         bridge_vu_dtcm_pwrite;
    wire [31:0]  bridge_vu_dtcm_pwdata;
    wire [31:0]  bridge_vu_dtcm_prdata;
    wire         bridge_vu_dtcm_pready;
    wire         bridge_vu_dtcm_pslverr;

    wire [14:0]  bridge_dte_dsa_paddr;
    wire         bridge_dte_dsa_psel;
    wire         bridge_dte_dsa_penable;
    wire         bridge_dte_dsa_pwrite;
    wire [31:0]  bridge_dte_dsa_pwdata;
    wire [31:0]  bridge_dte_dsa_prdata;
    wire         bridge_dte_dsa_pready;
    wire         bridge_dte_dsa_pslverr;

    wire [14:0]  bridge_mu_dsa_paddr;
    wire         bridge_mu_dsa_psel;
    wire         bridge_mu_dsa_penable;
    wire         bridge_mu_dsa_pwrite;
    wire [31:0]  bridge_mu_dsa_pwdata;
    wire [31:0]  bridge_mu_dsa_prdata;
    wire         bridge_mu_dsa_pready;
    wire         bridge_mu_dsa_pslverr;

    wire [16:0]  bridge_vu_dsa_paddr;
    wire         bridge_vu_dsa_psel;
    wire         bridge_vu_dsa_penable;
    wire         bridge_vu_dsa_pwrite;
    wire [31:0]  bridge_vu_dsa_pwdata;
    wire [31:0]  bridge_vu_dsa_prdata;
    wire         bridge_vu_dsa_pready;
    wire         bridge_vu_dsa_pslverr;

`ifdef AXI2APB_DUMMY
    axi2apb_dummy #(
        .ID_WIDTH                               (ID_WIDTH),
        .USER_WIDTH                             (USER_WIDTH)
    ) u_axi2apb_dummy (

        // Structurally connected to core_mem_top_dummy below. The current
        // axi2apb dummy still keeps these request outputs inactive.
        // Structurally connected to mu_mmem_dummy below. The current bridge
        // dummy keeps these request outputs inactive until routing is added.
        // Structurally connected to sharemem_dummy below. The current bridge
        // dummy keeps these request outputs inactive until routing is added.

    );
`endif

`ifdef CORE_STATUS_DUMMY
    core_status_dummy u_core_status_dummy (
        // TBD: MU/DTE/MMEM/TS error IRQ outputs are not present in the current
        // integrated module interfaces.
    );
`else
    // TBD: Instantiate the real core-status block here.
    assign bridge_core_status_prdata  = 32'b0;
    assign bridge_core_status_pready  = 1'b1;
    assign bridge_core_status_pslverr = 1'b0;
    assign bach_core_int              = 1'b0;
`endif

    // TBD: CTI/DFT connectivity is not represented by the current child dummies.
    assign cti_o = {CTI_WIDTH{1'b0}};

    // The top-level DMI interface currently has no receiving module.
    // Confirmed temporary behavior: keep every DMI response output at zero.
    assign dmi_prdata  = {DATA_WIDTH{1'b0}};
    assign dmi_pready  = 1'b0;
    assign dmi_pslverr = 1'b0;

    // -------------------------------------------------------------------------
    // Task Scheduler nets.
    // -------------------------------------------------------------------------
    wire [15:0] ts_dte_uid;
    wire [5:0]  ts_dte_tid;
    wire [3:0]  ts_dte_sid;
    wire [7:0]  ts_dte_pid;
    wire [1:0]  ts_dte_vcid;
    wire [31:0] ts_dte_pc;
    wire        ts_dte_valid;
    wire [15:0] ts_mu_uid;
    wire [5:0]  ts_mu_tid;
    wire [3:0]  ts_mu_sid;
    wire [7:0]  ts_mu_pid;
    wire [1:0]  ts_mu_vcid;
    wire [31:0] ts_mu_pc;
    wire        ts_mu_valid;
    wire [15:0] ts_vu_uid;
    wire [5:0]  ts_vu_tid;
    wire [3:0]  ts_vu_sid;
    wire [7:0]  ts_vu_pid;
    wire [1:0]  ts_vu_vcid;
    wire [31:0] ts_vu_pc;
    wire        ts_vu_valid;
    wire        dte_core_fifo_full;
    wire        mu_core_fifo_full;
    wire        vu_core_fifo_full;
    wire        dte_core_done;
    wire [5:0]  dte_core_csr_tid;
    wire [15:0] dte_core_csr_uid;
    wire [3:0]  dte_core_csr_sid;
    wire [7:0]  dte_core_csr_pid;
    wire        mu_core_done;

    wire [5:0]  mu_core_csr_tid;
    wire [15:0] mu_core_csr_uid;
    wire [3:0]  mu_core_csr_sid;
    wire [7:0]  mu_core_csr_pid;
    wire        vu_core_done;

    wire [5:0]  vu_core_csr_tid;
    wire [15:0] vu_core_csr_uid;
    wire [3:0]  vu_core_csr_sid;
    wire [7:0]  vu_core_csr_pid;

    // TBD: The latest FE interface exposes task_done but no separate valid.
    // Until FE adds a valid qualifier, task_done is also used as done_valid.

    wire [15:0] dte_dsa_done_uid;
    wire [5:0]  dte_dsa_done_tid;
    wire [3:0]  dte_dsa_done_sid;
    wire        dte_dsa_done_valid;
    wire        vu_dsa_evt_valid;
    wire [3:0]  vu_dsa_evt_id;
    wire [15:0] mu_dsa_done_uid;
    wire [5:0]  mu_dsa_done_tid;
    wire [3:0]  mu_dsa_done_sid;
    wire        mu_dsa_done_valid;

    task_scheduler_top u_ts (
        // TBD: Bridge APB runs from scp_ctrl_aclk while TS runs on
        // bach_core_clk; add CDC if these clocks are not synchronous.
        .r2t_trigger_uid                         (r2t_trigger_uid),
        .r2t_trigger_pid                         (r2t_trigger_pid),
        .r2t_trigger_reissue                     (r2t_trigger_reissue),
        // Confirmed by task_scheduler_top: compatibility input is ignored.
        .r2t_trigger_dataout_tid                 (6'b0),
        .r2t_trigger_valid                       (r2t_trigger_valid),
        .r2t_trigger_ready                       (r2t_trigger_ready),
        .t2r_credit_release_uid                  (t2r_credit_release_uid),
        .t2r_credit_release_valid                (t2r_credit_release_valid),
        .r2ts_credit_e_uid                      (r2ts_credit_e_uid),
        .r2ts_credit_e_valid                    (r2ts_credit_e_valid),
        .r2ts_credit_w_uid                      (r2ts_credit_w_uid),
        .r2ts_credit_w_valid                    (r2ts_credit_w_valid),
        .r2ts_credit_ns_uid                     (r2ts_credit_ns_uid),
        .r2ts_credit_ns_valid                   (r2ts_credit_ns_valid),
        .rmem2ts_credit_done_uid                 (rmem2ts_credit_done_uid),
        .rmem2ts_credit_done_valid               (rmem2ts_credit_done_valid),
        .ts2dtecore_task_uid                     (ts_dte_uid),
        .ts2dtecore_task_tid                     (ts_dte_tid),
        .ts2dtecore_task_streamid                (ts_dte_sid),
        .ts2dtecore_task_pid                     (ts_dte_pid),
        .ts2dtecore_task_pc                      (ts_dte_pc),
        .ts2dtecore_task_vcid                    (ts_dte_vcid),
        .ts2dtecore_task_valid                   (ts_dte_valid),
        .dtecore2ts_task_ready                   (~dte_core_fifo_full),

        .dtecore2ts_done_uid                     (dte_core_csr_uid),
        .dtecore2ts_done_tid                     (dte_core_csr_tid),
        .dtecore2ts_done_sid                     (dte_core_csr_sid),
        .dtecore2ts_done_pid                     (dte_core_csr_pid),
        .dtecore2ts_done_valid                   (dte_core_done),

        .dte2ts_done_uid                         (dte_dsa_done_uid),
        .dte2ts_done_tid                         (dte_dsa_done_tid),
        .dte2ts_done_sid                         (dte_dsa_done_sid),
        .dte2ts_done_valid                       (dte_dsa_done_valid),

        .ts2mucore_task_uid                      (ts_mu_uid),
        .ts2mucore_task_tid                      (ts_mu_tid),
        .ts2mucore_task_streamid                 (ts_mu_sid),
        .ts2mucore_task_pid                      (ts_mu_pid),
        .ts2mucore_task_pc                       (ts_mu_pc),
        .ts2mucore_task_vcid                     (ts_mu_vcid),
        .ts2mucore_task_valid                    (ts_mu_valid),
        .mucore2ts_task_ready                    (~mu_core_fifo_full),

        .mucore2ts_done_uid                      (mu_core_csr_uid),
        .mucore2ts_done_tid                      (mu_core_csr_tid),
        .mucore2ts_done_sid                      (mu_core_csr_sid),
        .mucore2ts_done_pid                      (mu_core_csr_pid),
        .mucore2ts_done_valid                    (mu_core_done),
        .mu2ts_done_uid                          (mu_dsa_done_uid),
        .mu2ts_done_tid                          (mu_dsa_done_tid),
        .mu2ts_done_sid                          (mu_dsa_done_sid),
        .mu2ts_done_valid                        (mu_dsa_done_valid),

        .ts2vucore_task_uid                      (ts_vu_uid),
        .ts2vucore_task_tid                      (ts_vu_tid),
        .ts2vucore_task_streamid                 (ts_vu_sid),
        .ts2vucore_task_pid                      (ts_vu_pid),
        .ts2vucore_task_pc                       (ts_vu_pc),
        .ts2vucore_task_vcid                     (ts_vu_vcid),
        .ts2vucore_task_valid                    (ts_vu_valid),
        .vucore2ts_task_ready                    (~vu_core_fifo_full),
        .vucore2ts_done_uid                      (vu_core_csr_uid),
        .vucore2ts_done_tid                      (vu_core_csr_tid),
        .vucore2ts_done_sid                      (vu_core_csr_sid),
        .vucore2ts_done_pid                      (vu_core_csr_pid),
        .vucore2ts_done_valid                    (vu_core_done),
        // Confirmed: VU DSA completion carries SID only; UID/TID remain zero.
        .vu2ts_done_uid                          (16'b0),
        .vu2ts_done_tid                          (6'b0),
        .vu2ts_done_sid                          (vu_dsa_evt_id),
        .vu2ts_done_valid                        (vu_dsa_evt_valid)
    );

    // -------------------------------------------------------------------------
    // Shared-memory interconnect for the three RV cores.
    // -------------------------------------------------------------------------
    wire        mu_sm_req_vld, mu_sm_req_rdy, mu_sm_type;
    wire [31:0] mu_sm_addr, mu_sm_wr_data, mu_sm_rd_data;
    wire [3:0]  mu_sm_amo_type, mu_sm_byte_en, mu_sm_req_id, mu_sm_rsp_id;
    wire        mu_sm_rsp_vld, mu_sm_rsp_rdy, mu_sm_ecc_err;
    wire        vu_sm_req_vld, vu_sm_req_rdy, vu_sm_type;
    wire [31:0] vu_sm_addr, vu_sm_wr_data, vu_sm_rd_data;
    wire [3:0]  vu_sm_amo_type, vu_sm_byte_en, vu_sm_req_id, vu_sm_rsp_id;
    wire        vu_sm_rsp_vld, vu_sm_rsp_rdy, vu_sm_ecc_err;
    wire        dtec_sm_req_vld, dtec_sm_req_rdy, dtec_sm_type;
    wire [31:0] dtec_sm_addr, dtec_sm_wr_data, dtec_sm_rd_data;
    wire [3:0]  dtec_sm_amo_type, dtec_sm_byte_en, dtec_sm_req_id, dtec_sm_rsp_id;
    wire        dtec_sm_rsp_vld, dtec_sm_rsp_rdy, dtec_sm_ecc_err;

    // DTE DSA -> ShareMem channel.
    wire        dte_sm_wr_vld, dte_sm_wr_rdy;
    wire [31:0] dte_sm_wr_addr, dte_sm_wr_data;
    wire [3:0]  dte_sm_wr_bmask;
    wire        dte_sm_wr_bresp, dte_sm_ecc_err;

`ifdef SHAREMEM_DUMMY
    sharemem_dummy u_sharemem (

        .mucore2sm_rw_req_vld_i                  (mu_sm_req_vld),
        .sm2mucore_rw_req_rdy_o                  (mu_sm_req_rdy),
        .mucore2sm_rw_type_i                     (mu_sm_type),
        .mucore2sm_rw_addr_i                     (mu_sm_addr),
        .mucore2sm_wr_data_i                     (mu_sm_wr_data),
        .mucore2sm_amo_type_i                    (mu_sm_amo_type),
        .mucore2sm_wr_byte_en_i                  (mu_sm_byte_en),
        .mucore2sm_rw_id_i                       (mu_sm_req_id),
        .sm2mucore_rw_rsp_vld_o                  (mu_sm_rsp_vld),
        .sm2mucore_rsp_id_o                      (mu_sm_rsp_id),
        .mucore2sm_rw_rsp_rdy_i                  (mu_sm_rsp_rdy),
        .sm2mucore_rd_data_o                     (mu_sm_rd_data),
        .sm2mucore_rd_ecc_err_o                  (mu_sm_ecc_err),
        .vucore2sm_rw_req_vld_i                  (vu_sm_req_vld),
        .sm2vucore_rw_req_rdy_o                  (vu_sm_req_rdy),
        .vucore2sm_rw_type_i                     (vu_sm_type),
        .vucore2sm_rw_addr_i                     (vu_sm_addr),
        .vucore2sm_wr_data_i                     (vu_sm_wr_data),
        .vucore2sm_amo_type_i                    (vu_sm_amo_type),
        .vucore2sm_wr_byte_en_i                  (vu_sm_byte_en),
        .vucore2sm_rw_id_i                       (vu_sm_req_id),
        .sm2vucore_rw_rsp_vld_o                  (vu_sm_rsp_vld),
        .sm2vucore_rsp_id_o                      (vu_sm_rsp_id),
        .vucore2sm_rw_rsp_rdy_i                  (vu_sm_rsp_rdy),
        .sm2vucore_rd_data_o                     (vu_sm_rd_data),
        .sm2vucore_rd_ecc_err_o                  (vu_sm_ecc_err),
        .dtecore2sm_rw_req_vld_i                 (dtec_sm_req_vld),
        .sm2dtecore_rw_req_rdy_o                 (dtec_sm_req_rdy),
        .dtecore2sm_rw_type_i                    (dtec_sm_type),
        .dtecore2sm_rw_addr_i                    (dtec_sm_addr),
        .dtecore2sm_wr_data_i                    (dtec_sm_wr_data),
        .dtecore2sm_amo_type_i                   (dtec_sm_amo_type),
        .dtecore2sm_wr_byte_en_i                 (dtec_sm_byte_en),
        .dtecore2sm_rw_id_i                      (dtec_sm_req_id),
        .sm2dtecore_rw_rsp_vld_o                 (dtec_sm_rsp_vld),
        .sm2dtecore_rsp_id_o                     (dtec_sm_rsp_id),
        .dtecore2sm_rw_rsp_rdy_i                 (dtec_sm_rsp_rdy),
        .sm2dtecore_rd_data_o                    (dtec_sm_rd_data),
        .sm2dtecore_rd_ecc_err_o                 (dtec_sm_ecc_err),

        .dte2sm_wr_vld                           (dte_sm_wr_vld),
        .dte2sm_wr_rdy                           (dte_sm_wr_rdy),
        .dte2sm_wr_addr                          (dte_sm_wr_addr),
        .dte2sm_wr_bmask                         (dte_sm_wr_bmask),
        .dte2sm_wr_data                          (dte_sm_wr_data),
        .sm2dte_wr_bresp                         (dte_sm_wr_bresp),
        .sm2dte_wr_ecc_err                       (dte_sm_ecc_err),

        // ShareMem AXI ID and attribute sidebands are structurally connected.
        // The current bridge dummy drives them to zero while routing is idle.
        // TBD: Bridge AXI uses scp_ctrl_aclk while ShareMem uses bach_core_clk.
        .sm2ctrl_noc_AWREADY                     (sharemem_axi_awready),
        .sm2ctrl_noc_WREADY                      (sharemem_axi_wready),
        .sm2ctrl_noc_BID                         (sharemem_axi_bid),
        .sm2ctrl_noc_BRESP                       (sharemem_axi_bresp),
        .sm2ctrl_noc_BVALID                      (sharemem_axi_bvalid),
        .sm2ctrl_noc_ARREADY                     (sharemem_axi_arready),
        .sm2ctrl_noc_RID                         (sharemem_axi_rid),
        .sm2ctrl_noc_RDATA                       (sharemem_axi_rdata),
        .sm2ctrl_noc_RRESP                       (sharemem_axi_rresp),
        .sm2ctrl_noc_RLAST                       (sharemem_axi_rlast),
        .sm2ctrl_noc_RVALID                      (sharemem_axi_rvalid)
    );
`else
    // TBD: instantiate the real ShareMem module here.
`endif

    // -------------------------------------------------------------------------
    // RV core DSA channels.
    // -------------------------------------------------------------------------
    wire        dtec_dsa_vld, dtec_dsa_rdy;
    wire        dtec_dsa_type;
    wire [31:0] dtec_dsa_addr, dtec_dsa_wdata, dtec_dsa_rdata;
    wire [3:0]  dtec_dsa_sid;
    wire [15:0] dtec_dsa_uid;
    wire [5:0]  dtec_dsa_tid;
    wire [7:0]  dtec_dsa_pid;
    wire [1:0]  dtec_dsa_vcid;
    wire        dtec_dsa_rsp;
    wire        vu_dsa_vld, vu_dsa_rdy;
    wire        vu_dsa_type;
    wire [31:0] vu_dsa_addr, vu_dsa_wdata, vu_dsa_rdata;
    wire [3:0]  vu_dsa_sid;
    wire [15:0] vu_dsa_uid;
    wire [5:0]  vu_dsa_tid;
    wire [7:0]  vu_dsa_pid;
    wire [1:0]  vu_dsa_vcid;
    wire        vu_dsa_rsp;
    wire        mu_dsa_vld, mu_dsa_rdy, mu_dsa_rsp;
    wire        mu_dsa_type;
    wire [31:0] mu_dsa_addr, mu_dsa_wdata, mu_dsa_rdata;
    wire [3:0]  mu_dsa_sid;
    wire [15:0] mu_dsa_uid;
    wire [5:0]  mu_dsa_tid;

    // Per-core CSR/ITCM/DTCM APB paths are connected below. The new FE GPR APB
    // path still has no separate target in the current AXI2APB address map.

    rv_core_top u_dte_rv_core (
        .clk_i                                   (bach_core_clk),
        // TBD: Provisional boot PC value is zero until its configuration source exists.
        .dsa_rw_req_vld_o                        (dtec_dsa_vld),
        .dsa_rw_req_rdy_i                        (dtec_dsa_rdy),
        .dsa_rw_type_o                           (dtec_dsa_type),
        .dsa_rw_addr_o                           (dtec_dsa_addr),
        .dsa_wr_data_o                           (dtec_dsa_wdata),
        .dsa_sid_o                               (dtec_dsa_sid),
        .dsa_uid_o                               (dtec_dsa_uid),
        .dsa_tid_o                               (dtec_dsa_tid),
        .dsa_rd_rsp_i                            (dtec_dsa_rsp),
        .dsa_rd_data_i                           (dtec_dsa_rdata),
        .sm_rw_req_vld_o                         (dtec_sm_req_vld),
        .sm_rw_req_rdy_i                         (dtec_sm_req_rdy),
        .sm_rw_type_o                            (dtec_sm_type),
        .sm_rw_addr_o                            (dtec_sm_addr),
        .sm_wr_data_o                            (dtec_sm_wr_data),
        .sm_amo_type_o                           (dtec_sm_amo_type),
        .sm_wr_byte_en_o                         (dtec_sm_byte_en),
        .sm_rw_id_o                              (dtec_sm_req_id),
        .sm_rw_rsp_vld_i                         (dtec_sm_rsp_vld),
        .sm_rsp_id_i                             (dtec_sm_rsp_id),
        .sm_rw_rsp_rdy_o                         (dtec_sm_rsp_rdy),
        .sm_rd_data_i                            (dtec_sm_rd_data),
        .sm_rd_ecc_err_i                         (dtec_sm_ecc_err),
        // The latest RV wrapper splits this APB window into CSR/GPR internally.
        .ctrl_noc_rv_paddr_i                     ({17'b0, bridge_dte_core_paddr}),
        .ctrl_noc_rv_psel_i                      (bridge_dte_core_psel),
        .ctrl_noc_rv_penable_i                   (bridge_dte_core_penable),
        .ctrl_noc_rv_pwrite_i                    (bridge_dte_core_pwrite),
        .ctrl_noc_rv_pwdata_i                    (bridge_dte_core_pwdata),
        .ctrl_noc_rv_prdata_o                    (bridge_dte_core_prdata),
        .ctrl_noc_rv_pready_o                    (bridge_dte_core_pready),
        .ctrl_noc_rv_pslverr_o                   (bridge_dte_core_pslverr),
        .ctrl_noc_itcm_paddr_i                   ({17'b0, bridge_dte_itcm_paddr}),
        .ctrl_noc_itcm_psel_i                    (bridge_dte_itcm_psel),
        .ctrl_noc_itcm_penable_i                 (bridge_dte_itcm_penable),
        .ctrl_noc_itcm_pwrite_i                  (bridge_dte_itcm_pwrite),
        .ctrl_noc_itcm_pwdata_i                  (bridge_dte_itcm_pwdata),
        .ctrl_noc_itcm_prdata_o                  (bridge_dte_itcm_prdata),
        .ctrl_noc_itcm_pready_o                  (bridge_dte_itcm_pready),
        .ctrl_noc_itcm_pslverr_o                 (bridge_dte_itcm_pslverr),
        // TBD: APB clock is scp_ctrl_aclk; add CDC if it is asynchronous to clk_i.
        .ctrl_noc_dtcm_psel_i                    (bridge_dte_dtcm_psel),
        .ctrl_noc_dtcm_penable_i                 (bridge_dte_dtcm_penable),
        .ctrl_noc_dtcm_pwrite_i                  (bridge_dte_dtcm_pwrite),
        .ctrl_noc_dtcm_paddr_i                   (bridge_dte_dtcm_paddr),
        .ctrl_noc_dtcm_pwdata_i                  (bridge_dte_dtcm_pwdata),
        .ctrl_noc_dtcm_prdata_o                  (bridge_dte_dtcm_prdata),
        .ctrl_noc_dtcm_pready_o                  (bridge_dte_dtcm_pready),
        .ctrl_noc_dtcm_pslverr_o                 (bridge_dte_dtcm_pslverr)
    );

    rv_core_top u_vu_rv_core (
        .clk_i                                   (bach_core_clk),
        .dsa_rw_req_vld_o                        (vu_dsa_vld),
        .dsa_rw_req_rdy_i                        (vu_dsa_rdy),
        .dsa_rw_type_o                           (vu_dsa_type),
        .dsa_rw_addr_o                           (vu_dsa_addr),
        .dsa_wr_data_o                           (vu_dsa_wdata),
        .dsa_sid_o                               (vu_dsa_sid),
        .dsa_uid_o                               (vu_dsa_uid),
        .dsa_tid_o                               (vu_dsa_tid),
        .dsa_rd_rsp_i                            (vu_dsa_rsp),
        .dsa_rd_data_i                           (vu_dsa_rdata),
        .sm_rw_req_vld_o                         (vu_sm_req_vld),
        .sm_rw_req_rdy_i                         (vu_sm_req_rdy),
        .sm_rw_type_o                            (vu_sm_type),
        .sm_rw_addr_o                            (vu_sm_addr),
        .sm_wr_data_o                            (vu_sm_wr_data),
        .sm_amo_type_o                           (vu_sm_amo_type),
        .sm_wr_byte_en_o                         (vu_sm_byte_en),
        .sm_rw_id_o                              (vu_sm_req_id),
        .sm_rw_rsp_vld_i                         (vu_sm_rsp_vld),
        .sm_rsp_id_i                             (vu_sm_rsp_id),
        .sm_rw_rsp_rdy_o                         (vu_sm_rsp_rdy),
        .sm_rd_data_i                            (vu_sm_rd_data),
        .sm_rd_ecc_err_i                         (vu_sm_ecc_err),
        // The latest RV wrapper splits this APB window into CSR/GPR internally.
        .ctrl_noc_rv_paddr_i                     ({17'b0, bridge_vu_core_paddr}),
        .ctrl_noc_rv_psel_i                      (bridge_vu_core_psel),
        .ctrl_noc_rv_penable_i                   (bridge_vu_core_penable),
        .ctrl_noc_rv_pwrite_i                    (bridge_vu_core_pwrite),
        .ctrl_noc_rv_pwdata_i                    (bridge_vu_core_pwdata),
        .ctrl_noc_rv_prdata_o                    (bridge_vu_core_prdata),
        .ctrl_noc_rv_pready_o                    (bridge_vu_core_pready),
        .ctrl_noc_rv_pslverr_o                   (bridge_vu_core_pslverr),
        .ctrl_noc_itcm_paddr_i                   ({17'b0, bridge_vu_itcm_paddr}),
        .ctrl_noc_itcm_psel_i                    (bridge_vu_itcm_psel),
        .ctrl_noc_itcm_penable_i                 (bridge_vu_itcm_penable),
        .ctrl_noc_itcm_pwrite_i                  (bridge_vu_itcm_pwrite),
        .ctrl_noc_itcm_pwdata_i                  (bridge_vu_itcm_pwdata),
        .ctrl_noc_itcm_prdata_o                  (bridge_vu_itcm_prdata),
        .ctrl_noc_itcm_pready_o                  (bridge_vu_itcm_pready),
        .ctrl_noc_itcm_pslverr_o                 (bridge_vu_itcm_pslverr),
        // TBD: APB clock is scp_ctrl_aclk; add CDC if it is asynchronous to clk_i.
        .ctrl_noc_dtcm_psel_i                    (bridge_vu_dtcm_psel),
        .ctrl_noc_dtcm_penable_i                 (bridge_vu_dtcm_penable),
        .ctrl_noc_dtcm_pwrite_i                  (bridge_vu_dtcm_pwrite),
        .ctrl_noc_dtcm_paddr_i                   (bridge_vu_dtcm_paddr),
        .ctrl_noc_dtcm_pwdata_i                  (bridge_vu_dtcm_pwdata),
        .ctrl_noc_dtcm_prdata_o                  (bridge_vu_dtcm_prdata),
        .ctrl_noc_dtcm_pready_o                  (bridge_vu_dtcm_pready),
        .ctrl_noc_dtcm_pslverr_o                 (bridge_vu_dtcm_pslverr)
    );

    rv_core_top u_mu_rv_core (
        .clk_i                                   (bach_core_clk),
        .dsa_rw_req_vld_o                        (mu_dsa_vld),
        .dsa_rw_req_rdy_i                        (mu_dsa_rdy),
        .dsa_rw_type_o                           (mu_dsa_type),
        .dsa_rw_addr_o                           (mu_dsa_addr),
        .dsa_wr_data_o                           (mu_dsa_wdata),
        .dsa_sid_o                               (mu_dsa_sid),
        .dsa_uid_o                               (mu_dsa_uid),
        .dsa_tid_o                               (mu_dsa_tid),
        // Confirmed: MU DSA does not use PID or VCID.
        .dsa_rd_rsp_i                            (mu_dsa_rsp),
        .dsa_rd_data_i                           (mu_dsa_rdata),
        .sm_rw_req_vld_o                         (mu_sm_req_vld),
        .sm_rw_req_rdy_i                         (mu_sm_req_rdy),
        .sm_rw_type_o                            (mu_sm_type),
        .sm_rw_addr_o                            (mu_sm_addr),
        .sm_wr_data_o                            (mu_sm_wr_data),
        .sm_amo_type_o                           (mu_sm_amo_type),
        .sm_wr_byte_en_o                         (mu_sm_byte_en),
        .sm_rw_id_o                              (mu_sm_req_id),
        .sm_rw_rsp_vld_i                         (mu_sm_rsp_vld),
        .sm_rsp_id_i                             (mu_sm_rsp_id),
        .sm_rw_rsp_rdy_o                         (mu_sm_rsp_rdy),
        .sm_rd_data_i                            (mu_sm_rd_data),
        .sm_rd_ecc_err_i                         (mu_sm_ecc_err),
        // The latest RV wrapper splits this APB window into CSR/GPR internally.
        .ctrl_noc_rv_paddr_i                     ({17'b0, bridge_mu_core_paddr}),
        .ctrl_noc_rv_psel_i                      (bridge_mu_core_psel),
        .ctrl_noc_rv_penable_i                   (bridge_mu_core_penable),
        .ctrl_noc_rv_pwrite_i                    (bridge_mu_core_pwrite),
        .ctrl_noc_rv_pwdata_i                    (bridge_mu_core_pwdata),
        .ctrl_noc_rv_prdata_o                    (bridge_mu_core_prdata),
        .ctrl_noc_rv_pready_o                    (bridge_mu_core_pready),
        .ctrl_noc_rv_pslverr_o                   (bridge_mu_core_pslverr),
        .ctrl_noc_itcm_paddr_i                   ({17'b0, bridge_mu_itcm_paddr}),
        .ctrl_noc_itcm_psel_i                    (bridge_mu_itcm_psel),
        .ctrl_noc_itcm_penable_i                 (bridge_mu_itcm_penable),
        .ctrl_noc_itcm_pwrite_i                  (bridge_mu_itcm_pwrite),
        .ctrl_noc_itcm_pwdata_i                  (bridge_mu_itcm_pwdata),
        .ctrl_noc_itcm_prdata_o                  (bridge_mu_itcm_prdata),
        .ctrl_noc_itcm_pready_o                  (bridge_mu_itcm_pready),
        .ctrl_noc_itcm_pslverr_o                 (bridge_mu_itcm_pslverr),
        // TBD: APB clock is scp_ctrl_aclk; add CDC if it is asynchronous to clk_i.
        .ctrl_noc_dtcm_psel_i                    (bridge_mu_dtcm_psel),
        .ctrl_noc_dtcm_penable_i                 (bridge_mu_dtcm_penable),
        .ctrl_noc_dtcm_pwrite_i                  (bridge_mu_dtcm_pwrite),
        .ctrl_noc_dtcm_paddr_i                   (bridge_mu_dtcm_paddr),
        .ctrl_noc_dtcm_pwdata_i                  (bridge_mu_dtcm_pwdata),
        .ctrl_noc_dtcm_prdata_o                  (bridge_mu_dtcm_prdata),
        .ctrl_noc_dtcm_pready_o                  (bridge_mu_dtcm_pready),
        .ctrl_noc_dtcm_pslverr_o                 (bridge_mu_dtcm_pslverr)
    );

    // -------------------------------------------------------------------------
    // VU DSA and VU <-> CMEM adapter.
    // -------------------------------------------------------------------------
    wire        vu_cm_rd_vld, vu_cm_rd_rdy, vu_cm_rd_rsp_vld, vu_cm_rd_rsp_rdy;
    wire [31:0] vu_cm_rd_addr;
    wire [1055:0] vu_cm_rd_data;
    wire        vu_cm_rd_err;
    wire        vu_cm_wr_vld, vu_cm_wr_rdy, vu_cm_wr_rsp_vld, vu_cm_wr_rsp_rdy;
    wire [31:0] vu_cm_wr_addr;
    wire [1055:0] vu_cm_wr_data;
    wire [131:0] vu_cm_wr_be;
    wire cm_vu_rd_ecc_err;
`ifdef VU_DUMMY
    vu_dummy u_vu_dsa (
        .rvcore2vu_rw_valid                      (vu_dsa_vld),
        .rvcore2vu_rw_ready                      (vu_dsa_rdy),
        .rvcore2vu_rw_write                      (vu_dsa_type),
        .rvcore2vu_rw_addr                       (vu_dsa_addr),
        .rvcore2vu_rw_wdata                      (vu_dsa_wdata),
        .rvcore2vu_rw_stream_id                  (vu_dsa_sid),
        .vu2rvcore_rw_valid                      (vu_dsa_rsp),
        // Confirmed: RV Core has no response ready; always accept the VU response.
        .vu2rvcore_rw_ready                      (1'b1),
        .vu2rvcore_rw_rdata                      (vu_dsa_rdata),
        // TBD: Add an APB CDC bridge if scp_ctrl_aclk and bach_core_clk are asynchronous.

        .vu2cm_rd_req_valid                         (vu_cm_rd_vld),
        .vu2cm_rd_req_ready                         (vu_cm_rd_rdy),
        .vu2cm_rd_req_addr                          (vu_cm_rd_addr),
        .cm2vu_rd_rsp_valid                         (vu_cm_rd_rsp_vld),
        .cm2vu_rd_rsp_ready                         (vu_cm_rd_rsp_rdy),
        .cm2vu_rd_rsp_data                          (vu_cm_rd_data),
        .cm2vu_rd_rsp_err                           (vu_cm_rd_err),
        .vu2cm_wt_req_valid                         (vu_cm_wr_vld),
        .vu2cm_wt_req_ready                         (vu_cm_wr_rdy),
        .vu2cm_wt_req_addr                          (vu_cm_wr_addr),
        .vu2cm_wt_req_data                          (vu_cm_wr_data),
        .vu2cm_wt_req_be                            (vu_cm_wr_be),
        .cm2vu_wt_rsp_valid                         (vu_cm_wr_rsp_vld),
        .cm2vu_wt_rsp_ready                         (vu_cm_wr_rsp_rdy)
    );
`else
    // TBD: instantiate the real VU DSA module here.
`endif
    // -------------------------------------------------------------------------
    // DTE DSA and external Router data mapping.
    // -------------------------------------------------------------------------
    wire [1:0] dte_cm_rd_vld, dte_cm_rd_rdy;
    wire [1:0] dte_cm_rd_bvld, dte_cm_rd_rsp_rdy;
    wire [27:0] dte_cm_rd_addr;
    wire [2047:0] dte_cm_rd_data;
    wire dte_cm_rd_ecc;
    wire [1:0] dte_cm_wr_vld, dte_cm_wr_rdy;
    wire [1:0] dte_cm_wr_bvld, dte_cm_wr_rsp_rdy;
    wire [27:0] dte_cm_wr_addr;
    wire [255:0] dte_cm_wr_bmask;
    wire [2047:0] dte_cm_wr_data;
    wire [1:0] dte_mm_rd_vld, dte_mm_rd_rdy;
    wire [1:0] dte_mm_rd_bvld, dte_mm_rd_rsp_rdy;
    wire [37:0] dte_mm_rd_addr;
    wire [2047:0] dte_mm_rd_data;
    wire dte_mm_rd_ecc;
    wire [1:0] dte_mm_wr_vld, dte_mm_wr_rdy;
    wire [1:0] dte_mm_wr_bvld, dte_mm_wr_brdy;
    wire [37:0] dte_mm_wr_addr;
    wire [255:0] dte_mm_wr_mask;
    wire [2047:0] dte_mm_wr_data;
    wire dte_mu_wr_vld, dte_mu_rd_vld;
    wire [3:0] dte_mu_wr_addr, dte_mu_rd_addr;
    wire [2047:0] dte_mu_wr_data;
    wire mu_dte_wr_rdy, mu_dte_wr_bvld, dte_mu_wr_brdy;
    wire mu_dte_rd_rdy, mu_dte_rd_bvld, dte_mu_rd_brdy;
    wire [2047:0] mu_dte_rd_data;

`ifdef DTE_DUMMY
    dte_dummy u_dte_dsa (
        .rvcore2dte_rw_req_vld                   (dtec_dsa_vld),
        // TBD: Latest RV BE exposes 1-bit R/W type; DTE DSA retains 2 bits.
        .rvcore2dte_rw_type                      ({1'b0, dtec_dsa_type}),
        .dte2rvcore_rw_req_rdy                   (dtec_dsa_rdy),
        .rvcore2dte_rw_addr                      (dtec_dsa_addr),
        .rvcore2dte_wr_data                      (dtec_dsa_wdata),
        .dte2rvcore_rd_rsp                       (dtec_dsa_rsp),
        .dte2rvcore_rd_data                      (dtec_dsa_rdata),
        .rvcore2dte_sid                          (dtec_dsa_sid),
        .rvcore2dte_tid                          (dtec_dsa_tid),
        .rvcore2dte_uid                          (dtec_dsa_uid),
        .rvcore2dte_pid                          (dtec_dsa_pid),
        .rvcore2dte_vcid                         (dtec_dsa_vcid),
        .dte2ts_done_uid                         (dte_dsa_done_uid),
        .dte2ts_done_tid                         (dte_dsa_done_tid),
        .dte2ts_done_sid                         (dte_dsa_done_sid),
        .dte2ts_done_valid                       (dte_dsa_done_valid),
        // TBD: Router VC ID is 5 bits while DTE accepts 2 bits.
        .dte2cm_rd_vld                           (dte_cm_rd_vld),
        .cm2dte_rd_rdy                           (dte_cm_rd_rdy),
        .dte2cm_rd_addr                          (dte_cm_rd_addr),
        .cm2dte_rd_bvld                          (dte_cm_rd_bvld),
        .dte2cm_rd_rdy                           (dte_cm_rd_rsp_rdy),
        .cm2dte_rd_data                          (dte_cm_rd_data),
        .cm2dte_rd_ecc_err                       (dte_cm_rd_ecc),
        .dte2cm_wr_vld                           (dte_cm_wr_vld),
        .cm2dte_wr_rdy                           (dte_cm_wr_rdy),
        .dte2cm_wr_addr                          (dte_cm_wr_addr),
        .dte2cm_wr_bmask_en                      (dte_cm_wr_bmask),
        .dte2cm_wr_data                          (dte_cm_wr_data),
        .cm2dte_wr_bvld                          (dte_cm_wr_bvld),
        .dte2cm_wr_rdy                           (dte_cm_wr_rsp_rdy),

        .dte2mm_rd_vld                           (dte_mm_rd_vld),
        .mm2dte_rd_rdy                           (dte_mm_rd_rdy),
        .dte2mm_rd_addr                          (dte_mm_rd_addr),
        .mm2dte_rd_bvld                          (dte_mm_rd_bvld),
        .dte2mm_rd_rdy                           (dte_mm_rd_rsp_rdy),
        .mm2dte_rd_data                          (dte_mm_rd_data),
        .mm2dte_rd_ecc_err                       (dte_mm_rd_ecc),
        .dte2mm_wr_vld                           (dte_mm_wr_vld),
        .mm2dte_wr_rdy                           (dte_mm_wr_rdy),
        .dte2mm_wr_addr                          (dte_mm_wr_addr),
        .dte2mm_wr_mask                          (dte_mm_wr_mask),
        .dte2mm_wr_data                          (dte_mm_wr_data),
        .mm2dte_wr_bvld                          (dte_mm_wr_bvld),
        .dte2mm_wr_brdy                          (dte_mm_wr_brdy),

        .dte2sm_wr_vld                           (dte_sm_wr_vld),
        .dte2sm_wr_rdy                           (dte_sm_wr_rdy),
        .dte2sm_wr_addr                          (dte_sm_wr_addr),
        .dte2sm_wr_bmask                         (dte_sm_wr_bmask),
        .dte2sm_wr_data                          (dte_sm_wr_data),
        .sm2dte_wr_bresp                         (dte_sm_wr_bresp),
        .sm2dte_wr_ecc_err                       (dte_sm_ecc_err),

        .dte2mu_wr_vld                           (dte_mu_wr_vld),
        .dte2mu_wr_rdy                           (mu_dte_wr_rdy),
        .dte2mu_wr_addr                          (dte_mu_wr_addr),
        .dte2mu_wr_data                          (dte_mu_wr_data),
        .mu2dte_wr_bvld                          (mu_dte_wr_bvld),
        .mu2dte_wr_brdy                          (dte_mu_wr_brdy),
        .dte2mu_rd_vld                           (dte_mu_rd_vld),
        .dte2mu_rd_rdy                           (mu_dte_rd_rdy),
        .dte2mu_rd_addr                          (dte_mu_rd_addr),
        .dte2mu_rd_data                          (mu_dte_rd_data),
        .mu2dte_rd_bvld                          (mu_dte_rd_bvld),
        .mu2dte_rd_brdy                          (dte_mu_rd_brdy)
    );
`else
    // TBD: instantiate the real DTE DSA module here.
`endif

    // -------------------------------------------------------------------------
    // Core memory. core_mem_top_dummy replaces the former cmem_dummy.
    // -------------------------------------------------------------------------
    wire [1:0]    mu_cm_rd_vld, mu_cm_rd_rdy, mu_cm_rd_scale_en;
    wire [1:0]    mu_cm_rd_bvld;
    wire [25:0]   mu_cm_rd_addr;
    wire [2111:0] mu_cm_rd_data;
    wire          mu_cm_rd_ecc_err;
    wire [1:0]    mu_cm_wr_vld;
    wire [25:0]   mu_cm_wr_addr;
    wire [255:0]  mu_cm_wr_bmask;
    wire [2047:0] mu_cm_wr_data;

    // core_mem_top_dummy uses unpacked lane arrays while DTE exposes packed
    // vectors. Lane 0 occupies the least-significant packed slice.
    wire [13:0]   coremem_dte_rd_addr [1:0];
    wire [1023:0] coremem_dte_rd_data [1:0];
    wire [13:0]   coremem_dte_wr_addr [1:0];
    wire [127:0]  coremem_dte_wr_mask [1:0];
    wire [1023:0] coremem_dte_wr_data [1:0];

    wire [12:0]   coremem_mu_rd_addr [1:0];
    wire [1055:0] coremem_mu_rd_data [1:0];
    wire [12:0]   coremem_mu_wr_addr [1:0];
    wire [127:0]  coremem_mu_wr_mask [1:0];
    wire [1023:0] coremem_mu_wr_data [1:0];

    assign coremem_dte_rd_addr[0]  = dte_cm_rd_addr[13:0];
    assign coremem_dte_rd_addr[1]  = dte_cm_rd_addr[27:14];
    assign dte_cm_rd_data          = {coremem_dte_rd_data[1], coremem_dte_rd_data[0]};
    assign coremem_dte_wr_addr[0]  = dte_cm_wr_addr[13:0];
    assign coremem_dte_wr_addr[1]  = dte_cm_wr_addr[27:14];
    assign coremem_dte_wr_mask[0]  = dte_cm_wr_bmask[127:0];
    assign coremem_dte_wr_mask[1]  = dte_cm_wr_bmask[255:128];
    assign coremem_dte_wr_data[0]  = dte_cm_wr_data[1023:0];
    assign coremem_dte_wr_data[1]  = dte_cm_wr_data[2047:1024];

    assign coremem_mu_rd_addr[0]   = mu_cm_rd_addr[12:0];
    assign coremem_mu_rd_addr[1]   = mu_cm_rd_addr[25:13];
    assign mu_cm_rd_data           = {coremem_mu_rd_data[1], coremem_mu_rd_data[0]};
    assign coremem_mu_wr_addr[0]   = mu_cm_wr_addr[12:0];
    assign coremem_mu_wr_addr[1]   = mu_cm_wr_addr[25:13];
    assign coremem_mu_wr_mask[0]   = mu_cm_wr_bmask[127:0];
    assign coremem_mu_wr_mask[1]   = mu_cm_wr_bmask[255:128];
    assign coremem_mu_wr_data[0]   = mu_cm_wr_data[1023:0];
    assign coremem_mu_wr_data[1]   = mu_cm_wr_data[2047:1024];

    // Confirmed: VU and CMEM both use one read-error bit.
    assign vu_cm_rd_err     = cm_vu_rd_ecc_err;

`ifdef CORE_MEM_TOP_DUMMY
    core_mem_top_dummy u_core_mem (
        .cm2scp_ecc_err                          (coremem_scp_ecc_err),

        // Confirmed: core_mem_top consumes the high 19 bits of the 21-bit
        // core_mem_s address; low address bits [1:0] are discarded.
        // TBD: bridge LEN is 4 bits but core_mem_top accepts only 2 bits.
        // TBD: This AXI path is clocked by scp_ctrl_aclk in the bridge while
        // core_mem_top uses bach_core_clk; add CDC if the clocks differ.
        .noc2cm_rd_arid                          (coremem_axi_arid),
        .noc2cm_rd_araddr                        (coremem_axi_araddr[20:2]),
        .noc2cm_rd_arlen                         (coremem_axi_arlen[1:0]),
        .noc2cm_rd_arsize                        (coremem_axi_arsize),
        .noc2cm_rd_arburst                       (coremem_axi_arburst),
        .noc2cm_rd_arvalid                       (coremem_axi_arvalid),
        .noc2cm_rd_arready                       (coremem_axi_arready),
        .cm2noc_rd_rid                           (coremem_axi_rid),
        .cm2noc_rd_rdata                         (coremem_axi_rdata),
        .cm2noc_rd_rresp                         (coremem_axi_rresp),
        .cm2noc_rd_rlast                         (coremem_axi_rlast),
        .cm2noc_rd_rvalid                        (coremem_axi_rvalid),
        .cm2noc_rd_rready                        (coremem_axi_rready),
        .noc2cm_wr_awid                          (coremem_axi_awid),
        .noc2cm_wr_awaddr                        (coremem_axi_awaddr[20:2]),
        .noc2cm_wr_awlen                         (coremem_axi_awlen[1:0]),
        .noc2cm_wr_awsize                        (coremem_axi_awsize),
        .noc2cm_wr_awburst                       (coremem_axi_awburst),
        .noc2cm_wr_awvalid                       (coremem_axi_awvalid),
        .noc2cm_wr_awready                       (coremem_axi_awready),
        // TBD: WID is an AXI3/legacy CMEM extension; AXI4 has no WID. CMEM
        // supports only ID 0, so reuse the fixed AWID value.
        .noc2cm_wr_wid                           (coremem_axi_awid),
        .noc2cm_wr_wdata                         (coremem_axi_wdata),
        .noc2cm_wr_wstrb                         (coremem_axi_wstrb),
        .noc2cm_wr_wlast                         (coremem_axi_wlast),
        .noc2cm_wr_wvalid                        (coremem_axi_wvalid),
        .noc2cm_wr_wready                        (coremem_axi_wready),
        .cm2noc_resp_bid                         (coremem_axi_bid),
        .cm2noc_resp_bresp                       (coremem_axi_bresp),
        .cm2noc_resp_bvalid                      (coremem_axi_bvalid),
        .cm2noc_resp_bready                      (coremem_axi_bready),

        .vu2cm_rd_vld                            (vu_cm_rd_vld),
        .cm2vu_rd_rdy                            (vu_cm_rd_rdy),
        // Confirmed: VU CMEM reads always enable the scale-data path.
        .vu2cm_rd_scale_en                       (1'b1),
        // TBD: Provisional [19:7] mapping approved; confirm against final CM map.
        // VU uses a 32-bit byte address; CMEM uses a 13-bit 128B index.
        .vu2cm_rd_addr                           (vu_cm_rd_addr[12:0]),
        .cm2vu_rd_bvld                           (vu_cm_rd_rsp_vld),
        .vu2cm_rd_brdy                           (vu_cm_rd_rsp_rdy),
        .cm2vu_rd_data                           (vu_cm_rd_data),
        .cm2vu_rd_ecc_err                        (cm_vu_rd_ecc_err),
        .vu2cm_wr_vld                            (vu_cm_wr_vld),
        .cm2vu_wr_rdy                            (vu_cm_wr_rdy),
        .vu2cm_wr_addr                           (vu_cm_wr_addr[12:0]),
        .vu2cm_wr_bmask_en                       (vu_cm_wr_be),
        .vu2cm_wr_data                           (vu_cm_wr_data),
        .cm2vu_wr_bvld                           (vu_cm_wr_rsp_vld),
        .vu2cm_wr_brdy                           (vu_cm_wr_rsp_rdy),

        .mu2cm_rd_vld                            (mu_cm_rd_vld),
        .cm2mu_rd_rdy                            (mu_cm_rd_rdy),
        .mu2cm_rd_scale_en                       (mu_cm_rd_scale_en),
        .mu2cm_rd_addr                           (coremem_mu_rd_addr),
        .cm2mu_rd_bvld                           (mu_cm_rd_bvld),
        .cm2mu_rd_data                           (coremem_mu_rd_data),
        .cm2mu_rd_ecc_err                        (mu_cm_rd_ecc_err),
        .mu2cm_wr_vld                            (mu_cm_wr_vld),
        .mu2cm_wr_addr                           (coremem_mu_wr_addr),
        .mu2cm_wr_bmask_en                       (coremem_mu_wr_mask),
        .mu2cm_wr_data                           (coremem_mu_wr_data),

        .dte2cm_rd_vld                           (dte_cm_rd_vld),
        .cm2dte_rd_rdy                           (dte_cm_rd_rdy),
        .dte2cm_rd_addr                          (coremem_dte_rd_addr),
        .cm2dte_rd_bvld                          (dte_cm_rd_bvld),
        .dte2cm_rd_brdy                          (dte_cm_rd_rsp_rdy),
        .cm2dte_rd_data                          (coremem_dte_rd_data),
        .cm2dte_rd_ecc_err                       (dte_cm_rd_ecc),
        .dte2cm_wr_vld                           (dte_cm_wr_vld),
        .cm2dte_wr_rdy                           (dte_cm_wr_rdy),
        .dte2cm_wr_addr                          (coremem_dte_wr_addr),
        .dte2cm_wr_bmask_en                      (coremem_dte_wr_mask),
        .dte2cm_wr_data                          (coremem_dte_wr_data),
        .cm2dte_wr_bvld                          (dte_cm_wr_bvld),
        .dte2cm_wr_brdy                          (dte_cm_wr_rsp_rdy)
    );
`else
    // TBD: instantiate the real core memory module here.
`endif

    // -------------------------------------------------------------------------
    // Combined MU DSA + MMEM dummy.
    // -------------------------------------------------------------------------
`ifdef MU_MMEM_DUMMY
    mu_mmem_dummy u_mu_mmem (
        // TBD: APB is clocked by scp_ctrl_aclk; add CDC if asynchronous to clk.
        .rvcore2mu_rw_req_vld                    (mu_dsa_vld),
        // TBD: Latest RV BE exposes 1-bit R/W type; MU DSA retains 2 bits.
        .rvcore2mu_rw_type                       ({1'b0, mu_dsa_type}),
        .mu2rvcore_rw_req_rdy                    (mu_dsa_rdy),
        .rvcore2mu_rw_addr                       (mu_dsa_addr),
        .rvcore2mu_wr_data                       (mu_dsa_wdata),
        .mu2rvcore_rd_rsp                        (mu_dsa_rsp),
        .mu2rvcore_rd_data                       (mu_dsa_rdata),
        .rvcore2mu_sid                           (mu_dsa_sid),
        .rvcore2mu_tid                           (mu_dsa_tid),
        .rvcore2mu_uid                           (mu_dsa_uid),
        .mu2ts_done_uid                          (mu_dsa_done_uid),
        .mu2ts_done_tid                          (mu_dsa_done_tid),
        .mu2ts_done_sid                          (mu_dsa_done_sid),
        .mu2ts_done_valid                        (mu_dsa_done_valid),
        .mu2cm_rd_vld                            (mu_cm_rd_vld),
        .cm2mu_rd_rdy                            (mu_cm_rd_rdy),
        .mu2cm_rd_scale_en                       (mu_cm_rd_scale_en),
        .mu2cm_rd_addr                           (mu_cm_rd_addr),
        .cm2mu_rd_bvld                           (mu_cm_rd_bvld),
        .cm2mu_rd_data                           (mu_cm_rd_data),
        .cm2mu_rd_ecc_err                        (mu_cm_rd_ecc_err),
        .mu2cm_wr_vld                            (mu_cm_wr_vld),
        .mu2cm_wr_addr                           (mu_cm_wr_addr),
        .mu2cm_wr_bmask_en                       (mu_cm_wr_bmask),
        .mu2cm_wr_data                           (mu_cm_wr_data),
        .dte2mu_wr_vld                           (dte_mu_wr_vld),
        .dte2mu_wr_rdy                           (mu_dte_wr_rdy),
        .dte2mu_wr_addr                          (dte_mu_wr_addr),
        .dte2mu_wr_data                          (dte_mu_wr_data),
        .mu2dte_wr_bvld                          (mu_dte_wr_bvld),
        .mu2dte_wr_brdy                          (dte_mu_wr_brdy),
        .dte2mu_rd_vld                           (dte_mu_rd_vld),
        .dte2mu_rd_rdy                           (mu_dte_rd_rdy),
        .dte2mu_rd_addr                          (dte_mu_rd_addr),
        .dte2mu_rd_data                          (mu_dte_rd_data),
        .mu2dte_rd_bvld                          (mu_dte_rd_bvld),
        .mu2dte_rd_brdy                          (dte_mu_rd_brdy),
        .dte2mm_rd_vld                          (dte_mm_rd_vld),
        .mm2dte_rd_rdy                          (dte_mm_rd_rdy),
        .dte2mm_rd_addr                         (dte_mm_rd_addr),
        .mm2dte_rd_bvld                         (dte_mm_rd_bvld),
        .dte2mm_rd_brdy                         (dte_mm_rd_rsp_rdy),
        .mm2dte_rd_data                         (dte_mm_rd_data),
        .mm2dte_rd_ecc_err                      (dte_mm_rd_ecc),
        .dte2mm_wr_vld                          (dte_mm_wr_vld),
        .mm2dte_wr_rdy                          (dte_mm_wr_rdy),
        .dte2mm_wr_addr                         (dte_mm_wr_addr),
        .dte2mm_wr_mask                         (dte_mm_wr_mask),
        .dte2mm_wr_data                         (dte_mm_wr_data),
        .mm2dte_wr_bvld                         (dte_mm_wr_bvld),
        .dte2mm_wr_brdy                         (dte_mm_wr_brdy),
        // TBD: matrix_mem_s is a 26-bit byte address; MMEM consumes the high
        // 24 bits as a 4-byte-aligned address.
        // TBD: Bridge AXI uses scp_ctrl_aclk while MU/MMEM uses bach_core_clk.
        .noc2mm_rd_arid                          (mmem_axi_arid),
        .noc2mm_rd_araddr                        (mmem_axi_araddr[25:2]),
        .noc2mm_rd_arlen                         (mmem_axi_arlen[1:0]),
        .noc2mm_rd_arsize                        (mmem_axi_arsize),
        .noc2mm_rd_arburst                       (mmem_axi_arburst),
        .noc2mm_rd_arvalid                       (mmem_axi_arvalid),
        .noc2mm_rd_arready                       (mmem_axi_arready),
        .mm2noc_rd_rid                           (mmem_axi_rid),
        .mm2noc_rd_rdata                         (mmem_axi_rdata),
        .mm2noc_rd_rresp                         (mmem_axi_rresp),
        .mm2noc_rd_rlast                         (mmem_axi_rlast),
        .mm2noc_rd_rvalid                        (mmem_axi_rvalid),
        .mm2noc_rd_rready                        (mmem_axi_rready),
        .noc2mm_wr_awid                          (mmem_axi_awid),
        .noc2mm_wr_awaddr                        (mmem_axi_awaddr[25:2]),
        .noc2mm_wr_awlen                         (mmem_axi_awlen[1:0]),
        .noc2mm_wr_awsize                        (mmem_axi_awsize),
        .noc2mm_wr_awburst                       (mmem_axi_awburst),
        .noc2mm_wr_awvalid                       (mmem_axi_awvalid),
        .noc2mm_wr_awready                       (mmem_axi_awready),
        // WID is a legacy AXI3-style field; reuse the fixed 1-bit AWID.
        .noc2mm_wr_wid                           (mmem_axi_awid),
        .noc2mm_wr_wdata                         (mmem_axi_wdata),
        .noc2mm_wr_wstrb                         (mmem_axi_wstrb),
        .noc2mm_wr_wlast                         (mmem_axi_wlast),
        .noc2mm_wr_wvalid                        (mmem_axi_wvalid),
        .noc2mm_wr_wready                        (mmem_axi_wready),
        .mm2noc_resp_bid                         (mmem_axi_bid),
        .mm2noc_resp_bresp                       (mmem_axi_bresp),
        .mm2noc_resp_bvalid                      (mmem_axi_bvalid),
        .mm2noc_resp_bready                      (mmem_axi_bready)
    );
`else
    // TBD: instantiate the real combined MU/MMEM module here.
`endif

    // Signals below are intentionally unconsumed by the current integration.
    // Keep this list aligned with the active TBD items above.
    wire _unused_ok = &{1'b0,
        // TBD: DMI, scan and CTI have no current child-module consumers.
        dmi_pclk, dmi_presetn, dmi_paddr, dmi_psel, dmi_penable, dmi_pwrite,
        dmi_pwdata, dmi_pstrb, dmi_pprot, scan_mode, scan_rstn, cti_i,
        // TBD: task-execute qualifier is not represented by the current TS interface.
        r2t_trigger_task_exe,
        // TBD: The current VU DSA configuration interface consumes SID but
        // does not expose UID/TID/PID/VCID inputs.
        vu_dsa_uid, vu_dsa_tid, vu_dsa_pid, vu_dsa_vcid};

endmodule

`default_nettype wire
