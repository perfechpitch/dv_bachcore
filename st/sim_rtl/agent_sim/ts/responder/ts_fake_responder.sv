module ts_fake_responder(ts_if vif);
  int accepted,rv_delay,dsa_delay; bit busy; bit [1:0] unit;
  bit [15:0] uid; bit [5:0] tid; bit [3:0] sid;
  initial begin accepted=0; busy=0; end
  task clear_done();
    vif.dtecore2ts_done_valid<=0; vif.mucore2ts_done_valid<=0; vif.vucore2ts_done_valid<=0;
    vif.dte2ts_done_valid<=0; vif.mu2ts_done_valid<=0; vif.vu2ts_done_valid<=0;
  endtask
  always @(posedge vif.clk) begin
    clear_done();
    if(!vif.reset_n) begin
      vif.dtecore2ts_task_ready<=0; vif.mucore2ts_task_ready<=0; vif.vucore2ts_task_ready<=0;
      busy<=0; accepted<=0;
    end else begin
      vif.dtecore2ts_task_ready<=!busy; vif.mucore2ts_task_ready<=!busy; vif.vucore2ts_task_ready<=!busy;
      if(!busy&&vif.ts2dtecore_task_valid&&vif.dtecore2ts_task_ready) begin
        busy<=1; unit<=0; uid<=vif.ts2dtecore_task_uid; tid<=vif.ts2dtecore_task_tid; sid<=vif.ts2dtecore_task_streamid;
        rv_delay<=(accepted%2)?4:2; dsa_delay<=(accepted%2)?2:4; accepted<=accepted+1;
      end else if(!busy&&vif.ts2mucore_task_valid&&vif.mucore2ts_task_ready) begin
        busy<=1; unit<=1; uid<=vif.ts2mucore_task_uid; tid<=vif.ts2mucore_task_tid; sid<=vif.ts2mucore_task_streamid;
        rv_delay<=(accepted%2)?4:2; dsa_delay<=(accepted%2)?2:4; accepted<=accepted+1;
      end else if(!busy&&vif.ts2vucore_task_valid&&vif.vucore2ts_task_ready) begin
        busy<=1; unit<=2; uid<=vif.ts2vucore_task_uid; tid<=vif.ts2vucore_task_tid; sid<=vif.ts2vucore_task_streamid;
        rv_delay<=(accepted%2)?4:2; dsa_delay<=(accepted%2)?2:4; accepted<=accepted+1;
      end
      if(busy) begin
        if(rv_delay>0) rv_delay<=rv_delay-1;
        if(dsa_delay>0) dsa_delay<=dsa_delay-1;
        if(rv_delay==1) case(unit)
          0: begin vif.dtecore2ts_done_uid<=uid; vif.dtecore2ts_done_tid<=tid; vif.dtecore2ts_done_sid<=sid; vif.dtecore2ts_done_valid<=1; end
          1: begin vif.mucore2ts_done_uid<=uid; vif.mucore2ts_done_tid<=tid; vif.mucore2ts_done_sid<=sid; vif.mucore2ts_done_valid<=1; end
          2: begin vif.vucore2ts_done_uid<=uid; vif.vucore2ts_done_tid<=tid; vif.vucore2ts_done_sid<=sid; vif.vucore2ts_done_valid<=1; end
        endcase
        if(dsa_delay==1) case(unit)
          0: begin vif.dte2ts_done_uid<=uid; vif.dte2ts_done_tid<=tid; vif.dte2ts_done_sid<=sid; vif.dte2ts_done_valid<=1; end
          1: begin vif.mu2ts_done_uid<=uid; vif.mu2ts_done_tid<=tid; vif.mu2ts_done_sid<=sid; vif.mu2ts_done_valid<=1; end
          2: begin vif.vu2ts_done_uid<=uid; vif.vu2ts_done_tid<=tid; vif.vu2ts_done_sid<=sid; vif.vu2ts_done_valid<=1; end
        endcase
        if(rv_delay==1||rv_delay==0) if(dsa_delay==1||dsa_delay==0) busy<=0;
      end
    end
  end
endmodule
