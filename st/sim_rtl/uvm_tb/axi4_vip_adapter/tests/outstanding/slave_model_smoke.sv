`timescale 1ns/1ps
module outstanding_slave_smoke;
  bit clk=0, rst=0;
  always #0.5 clk=~clk;
  axi4_if #(32,256,8) axi(clk,rst);
  outstanding_controlled_slave slave(axi);
  task aw(input int id, input int addr, input int beats);
    @(negedge clk); #1ps;
    axi.awid=id; axi.awaddr=addr; axi.awlen=beats-1; axi.awvalid=1;
    do @(posedge clk); while (!axi.awready);
    @(negedge clk); #1ps; axi.awvalid=0;
  endtask
  task w(input int addr, input int beats);
    for(int i=0;i<beats;i++) begin
      @(negedge clk); #1ps;
      axi.wdata=slave.pattern(addr,i); axi.wstrb=slave.strobe_pattern(i);
      axi.wlast=i==beats-1; axi.wvalid=1;
      do @(posedge clk); while (!axi.wready);
      @(negedge clk); #1ps; axi.wvalid=0;
    end
  endtask
  task ar(input int id,input int addr,input int beats);
    @(negedge clk); #1ps;
    axi.arid=id; axi.araddr=addr; axi.arlen=beats-1; axi.arvalid=1;
    do @(posedge clk); while (!axi.arready);
    @(negedge clk); #1ps; axi.arvalid=0;
  endtask
  initial begin
    axi.awid=0;axi.awaddr=0;axi.awlen=0;axi.awsize=5;axi.awburst=1;axi.awvalid=0;
    axi.wdata=0;axi.wstrb=0;axi.wlast=0;axi.wvalid=0;axi.bready=1;
    axi.arid=0;axi.araddr=0;axi.arlen=0;axi.arsize=5;axi.arburst=1;axi.arvalid=0;axi.rready=1;
    #2;rst=1;
    slave.awready_requires_wvalid=1;
    fork
      begin aw(1,'h1000,4);aw(2,'h1200,4);aw(1,'h1400,4);aw(2,'h1600,4);end
      begin w('h1000,4);w('h1200,4);w('h1400,4);w('h1600,4);end
      begin ar(1,'h2000,4);ar(2,'h2200,4);ar(1,'h2400,4);ar(2,'h2600,4);end
    join
    repeat(5) @(posedge clk);
    @(negedge clk);#1ps;slave.hold_b=0;slave.hold_r=0;
    wait(slave.b_count==4&&slave.rlast_count==4);
    @(negedge clk);#1ps;
    slave.report("SLAVE_MODEL_SMOKE");
    if(slave.aw_count!=4||slave.w_count!=16||slave.ar_count!=4||slave.r_count!=16||slave.live_reads!=0||slave.live_writes!=0||slave.out_of_order_b==0||slave.out_of_order_r==0||slave.interleaved_r==0)
      $fatal(1,"SLAVE_MODEL_SMOKE counters");
    $display("SLAVE_MODEL_SMOKE PASS");$finish;
  end
  initial begin #10000;$fatal(1,"SLAVE_MODEL_SMOKE watchdog");end
endmodule
