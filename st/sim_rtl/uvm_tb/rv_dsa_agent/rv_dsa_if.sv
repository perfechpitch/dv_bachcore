`ifndef RV_DSA_IF_SV
`define RV_DSA_IF_SV
interface rv_dsa_if(input bit clk, input bit reset_n);
  logic req, rw;
  logic [31:0] addr0, wdata0;
  logic [3:0] stream_id;
  logic [5:0] task_id, path_id;
  logic [15:0] user_id;
  logic [1:0] vc_id;
  logic ready, resp;
  logic [31:0] rdata;

  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    input reset_n, ready, resp, rdata;
    output req, rw, addr0, wdata0, stream_id, task_id, user_id, path_id, vc_id;
  endclocking
  clocking mon_cb @(posedge clk);
    default input #1step;
    input reset_n, req, rw, addr0, wdata0, stream_id, task_id, user_id, path_id, vc_id;
    input ready, resp, rdata;
  endclocking
  modport DRV(clocking drv_cb);
  modport MON(clocking mon_cb);

  property p_req_payload_stable;
    @(posedge clk) disable iff (!reset_n)
      req && !ready |=> req && $stable({rw,addr0,wdata0,stream_id,task_id,user_id,path_id,vc_id});
  endproperty
  a_req_payload_stable: assert property(p_req_payload_stable)
    else $error("rv_dsa request payload changed before handshake");
endinterface
`endif
