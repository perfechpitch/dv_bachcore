module ts_behavior_bind (
  input wire clk,
  input wire reset_n,
  output wire [15:0] t2r_credit_release_uid,
  output wire t2r_credit_release_valid,
  output wire [15:0] dte_uid, mu_uid, vu_uid,
  output wire [5:0] dte_tid, mu_tid, vu_tid,
  output wire [3:0] dte_sid, mu_sid, vu_sid,
  output wire [7:0] dte_pid, mu_pid, vu_pid,
  output wire [1:0] dte_vcid, mu_vcid, vu_vcid,
  output wire [31:0] dte_pc, mu_pc, vu_pc,
  output wire dte_valid, mu_valid, vu_valid,
  input wire dte_ready, mu_ready, vu_ready,
  input wire [15:0] dte_done_uid, mu_done_uid, vu_done_uid,
  input wire [5:0] dte_done_tid, mu_done_tid, vu_done_tid,
  input wire [3:0] dte_done_sid, mu_done_sid, vu_done_sid,
  input wire [7:0] dte_done_pid, mu_done_pid, vu_done_pid,
  input wire dte_done_valid, mu_done_valid, vu_done_valid,
  input wire [15:0] dte_dsa_done_uid, mu_dsa_done_uid, vu_dsa_done_uid,
  input wire [5:0] dte_dsa_done_tid, mu_dsa_done_tid, vu_dsa_done_tid,
  input wire [3:0] dte_dsa_done_sid, mu_dsa_done_sid, vu_dsa_done_sid,
  input wire dte_dsa_done_valid, mu_dsa_done_valid, vu_dsa_done_valid
);
  import uvm_pkg::*;
  ts_if vif(clk, reset_n);

  assign t2r_credit_release_uid = '0;
  assign t2r_credit_release_valid = 1'b0;
  assign dte_uid = vif.behavior_enable ? vif.ts2dtecore_task_uid : '0;
  assign dte_tid = vif.behavior_enable ? vif.ts2dtecore_task_tid : '0;
  assign dte_sid = vif.behavior_enable ? vif.ts2dtecore_task_streamid : '0;
  assign dte_pid = vif.behavior_enable ? vif.ts2dtecore_task_pid : '0;
  assign dte_vcid = vif.behavior_enable ? vif.ts2dtecore_task_vcid : '0;
  assign dte_pc = vif.behavior_enable ? vif.ts2dtecore_task_pc : '0;
  assign dte_valid = vif.behavior_enable ? vif.ts2dtecore_task_valid : 1'b0;
  assign mu_uid = vif.behavior_enable ? vif.ts2mucore_task_uid : '0;
  assign mu_tid = vif.behavior_enable ? vif.ts2mucore_task_tid : '0;
  assign mu_sid = vif.behavior_enable ? vif.ts2mucore_task_streamid : '0;
  assign mu_pid = vif.behavior_enable ? vif.ts2mucore_task_pid : '0;
  assign mu_vcid = vif.behavior_enable ? vif.ts2mucore_task_vcid : '0;
  assign mu_pc = vif.behavior_enable ? vif.ts2mucore_task_pc : '0;
  assign mu_valid = vif.behavior_enable ? vif.ts2mucore_task_valid : 1'b0;
  assign vu_uid = vif.behavior_enable ? vif.ts2vucore_task_uid : '0;
  assign vu_tid = vif.behavior_enable ? vif.ts2vucore_task_tid : '0;
  assign vu_sid = vif.behavior_enable ? vif.ts2vucore_task_streamid : '0;
  assign vu_pid = vif.behavior_enable ? vif.ts2vucore_task_pid : '0;
  assign vu_vcid = vif.behavior_enable ? vif.ts2vucore_task_vcid : '0;
  assign vu_pc = vif.behavior_enable ? vif.ts2vucore_task_pc : '0;
  assign vu_valid = vif.behavior_enable ? vif.ts2vucore_task_valid : 1'b0;

  always_comb begin
    vif.dtecore2ts_task_ready = dte_ready;
    vif.mucore2ts_task_ready = mu_ready;
    vif.vucore2ts_task_ready = vu_ready;
    vif.dtecore2ts_done_uid = dte_done_uid;
    vif.mucore2ts_done_uid = mu_done_uid;
    vif.vucore2ts_done_uid = vu_done_uid;
    vif.dtecore2ts_done_tid = dte_done_tid;
    vif.mucore2ts_done_tid = mu_done_tid;
    vif.vucore2ts_done_tid = vu_done_tid;
    vif.dtecore2ts_done_sid = dte_done_sid;
    vif.mucore2ts_done_sid = mu_done_sid;
    vif.vucore2ts_done_sid = vu_done_sid;
    vif.dtecore2ts_done_pid = dte_done_pid;
    vif.mucore2ts_done_pid = mu_done_pid;
    vif.vucore2ts_done_pid = vu_done_pid;
    vif.dtecore2ts_done_valid = dte_done_valid;
    vif.mucore2ts_done_valid = mu_done_valid;
    vif.vucore2ts_done_valid = vu_done_valid;
    vif.dte2ts_done_uid = dte_dsa_done_uid;
    vif.mu2ts_done_uid = mu_dsa_done_uid;
    vif.vu2ts_done_uid = vu_dsa_done_uid;
    vif.dte2ts_done_tid = dte_dsa_done_tid;
    vif.mu2ts_done_tid = mu_dsa_done_tid;
    vif.vu2ts_done_tid = vu_dsa_done_tid;
    vif.dte2ts_done_sid = dte_dsa_done_sid;
    vif.mu2ts_done_sid = mu_dsa_done_sid;
    vif.vu2ts_done_sid = vu_dsa_done_sid;
    vif.dte2ts_done_valid = dte_dsa_done_valid;
    vif.mu2ts_done_valid = mu_dsa_done_valid;
    vif.vu2ts_done_valid = vu_dsa_done_valid;
  end

  initial uvm_config_db#(virtual ts_if)::set(null, "uvm_test_top", "ts_bind_vif", vif);
endmodule

module rvcore_behavior_bind #(
  parameter string VIF_KEY = "rv_dsa_bind_vif"
) (
  input wire clk,
  input wire reset_n,
  output wire req,
  output wire rw,
  output wire [31:0] addr,
  output wire [31:0] wdata,
  output wire [3:0] sid,
  output wire [15:0] uid,
  output wire [5:0] tid,
  input wire ready,
  input wire resp,
  input wire [31:0] rdata
);
  import uvm_pkg::*;
  rv_dsa_if vif(clk, reset_n);
  assign req = vif.behavior_enable ? vif.req : 1'b0;
  assign rw = vif.behavior_enable ? vif.rw : 1'b0;
  assign addr = vif.behavior_enable ? vif.addr0 : '0;
  assign wdata = vif.behavior_enable ? vif.wdata0 : '0;
  assign sid = vif.behavior_enable ? vif.stream_id : '0;
  assign uid = vif.behavior_enable ? vif.user_id : '0;
  assign tid = vif.behavior_enable ? vif.task_id : '0;
  always_comb begin
    vif.ready = ready;
    vif.resp = resp;
    vif.rdata = rdata;
  end
  initial uvm_config_db#(virtual rv_dsa_if)::set(null, "uvm_test_top", VIF_KEY, vif);
endmodule

bind bach_core_top ts_behavior_bind u_ts_behavior_bind (
  .clk(bach_core_clk), .reset_n(bach_core_rstn),
  .t2r_credit_release_uid(t2r_credit_release_uid),
  .t2r_credit_release_valid(t2r_credit_release_valid),
  .dte_uid(ts_dte_uid), .mu_uid(ts_mu_uid), .vu_uid(ts_vu_uid),
  .dte_tid(ts_dte_tid), .mu_tid(ts_mu_tid), .vu_tid(ts_vu_tid),
  .dte_sid(ts_dte_sid), .mu_sid(ts_mu_sid), .vu_sid(ts_vu_sid),
  .dte_pid(ts_dte_pid), .mu_pid(ts_mu_pid), .vu_pid(ts_vu_pid),
  .dte_vcid(ts_dte_vcid), .mu_vcid(ts_mu_vcid), .vu_vcid(ts_vu_vcid),
  .dte_pc(ts_dte_pc), .mu_pc(ts_mu_pc), .vu_pc(ts_vu_pc),
  .dte_valid(ts_dte_valid), .mu_valid(ts_mu_valid), .vu_valid(ts_vu_valid),
  .dte_ready(~dte_core_fifo_full), .mu_ready(~mu_core_fifo_full), .vu_ready(~vu_core_fifo_full),
  .dte_done_uid(dte_core_csr_uid), .mu_done_uid(mu_core_csr_uid), .vu_done_uid(vu_core_csr_uid),
  .dte_done_tid(dte_core_csr_tid), .mu_done_tid(mu_core_csr_tid), .vu_done_tid(vu_core_csr_tid),
  .dte_done_sid(dte_core_csr_sid), .mu_done_sid(mu_core_csr_sid), .vu_done_sid(vu_core_csr_sid),
  .dte_done_pid(dte_core_csr_pid), .mu_done_pid(mu_core_csr_pid), .vu_done_pid(vu_core_csr_pid),
  .dte_done_valid(dte_core_done), .mu_done_valid(mu_core_done), .vu_done_valid(vu_core_done),
  .dte_dsa_done_uid(dte_dsa_done_uid), .mu_dsa_done_uid(mu_dsa_done_uid), .vu_dsa_done_uid(16'b0),
  .dte_dsa_done_tid(dte_dsa_done_tid), .mu_dsa_done_tid(mu_dsa_done_tid), .vu_dsa_done_tid(6'b0),
  .dte_dsa_done_sid(dte_dsa_done_sid), .mu_dsa_done_sid(mu_dsa_done_sid), .vu_dsa_done_sid(vu_dsa_evt_id),
  .dte_dsa_done_valid(dte_dsa_done_valid), .mu_dsa_done_valid(mu_dsa_done_valid), .vu_dsa_done_valid(vu_dsa_evt_valid)
);

bind bach_core_top rvcore_behavior_bind #(.VIF_KEY("dte_rv_dsa_bind_vif")) u_dte_rv_bind (
  .clk(bach_core_clk), .reset_n(bach_core_rstn), .req(dtec_dsa_vld), .rw(dtec_dsa_type),
  .addr(dtec_dsa_addr), .wdata(dtec_dsa_wdata), .sid(dtec_dsa_sid), .uid(dtec_dsa_uid), .tid(dtec_dsa_tid),
  .ready(dtec_dsa_rdy), .resp(dtec_dsa_rsp), .rdata(dtec_dsa_rdata));
bind bach_core_top rvcore_behavior_bind #(.VIF_KEY("vu_rv_dsa_bind_vif")) u_vu_rv_bind (
  .clk(bach_core_clk), .reset_n(bach_core_rstn), .req(vu_dsa_vld), .rw(vu_dsa_type),
  .addr(vu_dsa_addr), .wdata(vu_dsa_wdata), .sid(vu_dsa_sid), .uid(vu_dsa_uid), .tid(vu_dsa_tid),
  .ready(vu_dsa_rdy), .resp(vu_dsa_rsp), .rdata(vu_dsa_rdata));
bind bach_core_top rvcore_behavior_bind #(.VIF_KEY("mu_rv_dsa_bind_vif")) u_mu_rv_bind (
  .clk(bach_core_clk), .reset_n(bach_core_rstn), .req(mu_dsa_vld), .rw(mu_dsa_type),
  .addr(mu_dsa_addr), .wdata(mu_dsa_wdata), .sid(mu_dsa_sid), .uid(mu_dsa_uid), .tid(mu_dsa_tid),
  .ready(mu_dsa_rdy), .resp(mu_dsa_rsp), .rdata(mu_dsa_rdata));
