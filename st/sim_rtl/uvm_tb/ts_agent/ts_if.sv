interface ts_if(input bit clk,input bit reset_n);
  logic [15:0] ts2dtecore_task_uid,ts2mucore_task_uid,ts2vucore_task_uid;
  logic [5:0] ts2dtecore_task_tid,ts2mucore_task_tid,ts2vucore_task_tid;
  logic [3:0] ts2dtecore_task_streamid,ts2mucore_task_streamid,ts2vucore_task_streamid;
  logic [5:0] ts2dtecore_task_pid; logic [1:0] ts2dtecore_task_vcid;
  logic [31:0] ts2dtecore_task_pc,ts2mucore_task_pc,ts2vucore_task_pc;
  logic ts2dtecore_task_valid,ts2mucore_task_valid,ts2vucore_task_valid;
  logic dtecore2ts_task_ready,mucore2ts_task_ready,vucore2ts_task_ready;
  logic [15:0] dtecore2ts_done_uid,mucore2ts_done_uid,vucore2ts_done_uid;
  logic [5:0] dtecore2ts_done_tid,mucore2ts_done_tid,vucore2ts_done_tid;
  logic [3:0] dtecore2ts_done_sid,mucore2ts_done_sid,vucore2ts_done_sid;
  logic dtecore2ts_done_valid,mucore2ts_done_valid,vucore2ts_done_valid;
  logic ts2dtecore_ready,ts2mucore_ready,ts2vucore_ready;
  logic [15:0] dte2ts_done_uid,mu2ts_done_uid,vu2ts_done_uid;
  logic [5:0] dte2ts_done_tid,mu2ts_done_tid,vu2ts_done_tid;
  logic [3:0] dte2ts_done_sid,mu2ts_done_sid,vu2ts_done_sid;
  logic dte2ts_done_valid,mu2ts_done_valid,vu2ts_done_valid;
  logic ts2dte_ready,ts2mu_ready,ts2vu_ready;
  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    input reset_n,dtecore2ts_task_ready,mucore2ts_task_ready,vucore2ts_task_ready;
    input dtecore2ts_done_valid,mucore2ts_done_valid,vucore2ts_done_valid;
    input dte2ts_done_valid,mu2ts_done_valid,vu2ts_done_valid;
    output ts2dtecore_task_uid,ts2mucore_task_uid,ts2vucore_task_uid;
    output ts2dtecore_task_tid,ts2mucore_task_tid,ts2vucore_task_tid;
    output ts2dtecore_task_streamid,ts2mucore_task_streamid,ts2vucore_task_streamid;
    output ts2dtecore_task_pid,ts2dtecore_task_vcid;
    output ts2dtecore_task_pc,ts2mucore_task_pc,ts2vucore_task_pc;
    output ts2dtecore_task_valid,ts2mucore_task_valid,ts2vucore_task_valid;
    output ts2dtecore_ready,ts2mucore_ready,ts2vucore_ready,ts2dte_ready,ts2mu_ready,ts2vu_ready;
  endclocking
  clocking mon_cb @(posedge clk);
    default input #1step;
    input reset_n,ts2dtecore_task_uid,ts2mucore_task_uid,ts2vucore_task_uid;
    input ts2dtecore_task_tid,ts2mucore_task_tid,ts2vucore_task_tid;
    input ts2dtecore_task_streamid,ts2mucore_task_streamid,ts2vucore_task_streamid;
    input ts2dtecore_task_pid,ts2dtecore_task_vcid;
    input ts2dtecore_task_pc,ts2mucore_task_pc,ts2vucore_task_pc;
    input ts2dtecore_task_valid,ts2mucore_task_valid,ts2vucore_task_valid;
    input dtecore2ts_task_ready,mucore2ts_task_ready,vucore2ts_task_ready;
  endclocking
  property p_vu_stable; @(posedge clk) disable iff(!reset_n)
    ts2vucore_task_valid&&!vucore2ts_task_ready |=> ts2vucore_task_valid&&$stable({ts2vucore_task_uid,ts2vucore_task_tid,ts2vucore_task_streamid,ts2vucore_task_pc}); endproperty
  a_vu_stable: assert property(p_vu_stable);
  property p_mu_stable; @(posedge clk) disable iff(!reset_n)
    ts2mucore_task_valid&&!mucore2ts_task_ready |=> ts2mucore_task_valid&&$stable({ts2mucore_task_uid,ts2mucore_task_tid,ts2mucore_task_streamid,ts2mucore_task_pc}); endproperty
  a_mu_stable: assert property(p_mu_stable);
  property p_dte_stable; @(posedge clk) disable iff(!reset_n)
    ts2dtecore_task_valid&&!dtecore2ts_task_ready |=> ts2dtecore_task_valid&&$stable({ts2dtecore_task_uid,ts2dtecore_task_tid,ts2dtecore_task_streamid,ts2dtecore_task_pid,ts2dtecore_task_vcid,ts2dtecore_task_pc}); endproperty
  a_dte_stable: assert property(p_dte_stable);
endinterface
