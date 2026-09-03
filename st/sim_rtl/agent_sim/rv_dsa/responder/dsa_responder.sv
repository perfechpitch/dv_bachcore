module dsa_responder(rv_dsa_if vif);
  typedef struct {logic [31:0] data; int unsigned delay;} rsp_s;
  rsp_s rsp_q[$]; int ready_stall, response_latency, stall_count;
  initial begin
    if(!$value$plusargs("READY_STALL=%d",ready_stall)) ready_stall=0;
    if(!$value$plusargs("RESP_LATENCY=%d",response_latency)) response_latency=1;
    stall_count=ready_stall; vif.ready=0; vif.resp=0; vif.rdata=0;
  end
  always @(posedge vif.clk) begin
    vif.resp <= 0;
    if(!vif.reset_n) begin vif.ready<=0; rsp_q.delete(); stall_count=ready_stall; end
    else begin
      if(stall_count>0) begin vif.ready<=0; stall_count--; end else vif.ready<=1;
      foreach(rsp_q[i]) if(rsp_q[i].delay>0) rsp_q[i].delay--;
      if(rsp_q.size() && rsp_q[0].delay==0) begin
        vif.resp<=1; vif.rdata<=rsp_q[0].data; rsp_q.pop_front();
      end
      if(vif.req && vif.ready) begin
        stall_count=ready_stall;
        if(!vif.rw) rsp_q.push_back('{vif.addr0 ^ 32'hd5a00000,response_latency});
      end
    end
  end
endmodule
