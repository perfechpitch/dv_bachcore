// ============================================================================
// Filename             : router_if.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_INTERFACE_SV
`define ROUTER_INTERFACE_SV
interface router_if #(
    parameter UID_W          = 16,
    parameter PID_W          = 8,
    parameter PACKAGE_HEAD_W = 256,
    parameter PACKAGE_DATA_W = 2048
)(
    input logic clk,
    input logic rst_n
);

    // ============================================================
    // Router -> TS : task trigger
    // ============================================================
    logic [UID_W-1:0] r2t_trigger_uid;
    logic [PID_W-1:0] r2t_trigger_pid;
    logic             r2t_trigger_reissue;
    logic             r2t_trigger_task_exe;
    logic             r2t_trigger_valid;
    logic             r2t_trigger_ready;

    // ============================================================
    // TS -> Router : credit release
    // ============================================================
    logic [UID_W-1:0] t2r_credit_release_uid;
    logic             t2r_credit_release_valid;

    // ============================================================
    // MSG IN : Router -> DTE
    // ============================================================
    logic [PACKAGE_HEAD_W-1:0] r2core_hflit;
    logic [PACKAGE_DATA_W-1:0] r2core_pflit;
    logic                      r2core_head;
    logic                      r2core_tail;
    logic                      r2core_vld;

    // Backpressure from DTE
    logic                      core2r_rdy;

    // ============================================================
    // MSG OUT : DTE -> Router
    // ============================================================
    logic [PACKAGE_HEAD_W-1:0] core2r_hflit;
    logic [PACKAGE_DATA_W-1:0] core2r_pflit;
    logic                      core2r_head;
    logic                      core2r_tail;
    logic                      core2r_vld;

    // Return credit from Router
    logic                      r2core_credit_vld;
    logic [4:0]                r2core_credit_vcid;

    // ============================================================
    // Router -> DTE : credit
    // ============================================================
    logic [UID_W-1:0] r2dte_credit_e_uid;
    logic             r2dte_credit_e_valid;

    logic [UID_W-1:0] r2dte_credit_w_uid;
    logic             r2dte_credit_w_valid;

    logic [UID_W-1:0] r2dte_credit_ns_uid;
    logic             r2dte_credit_ns_valid;

    // ============================================================
    // Router Memory -> TS : credit done
    // ============================================================
    logic [UID_W-1:0] rmem2ts_credit_done_uid;
    logic             rmem2ts_credit_done_valid;

endinterface
`endif