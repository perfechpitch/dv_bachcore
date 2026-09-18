class ts_sequence extends uvm_sequence #(ts_item);
  `uvm_object_utils(ts_sequence)
  ts_cfg cfg;
  function new(string name="ts_sequence"); super.new(name); endfunction
  task body();
    int fd,rc; string line,u,m; ts_item t; bit [15:0] uid; bit [5:0] tid,pid;
    bit [3:0] sid; bit [31:0] pc; bit [1:0] vcid;
    if(cfg==null) `uvm_fatal("TS_SEQ","cfg is null")
    fd=$fopen(cfg.sequence_file,"r"); if(!fd) `uvm_fatal("TS_SEQ",$sformatf("cannot open %s",cfg.sequence_file))
    while($fgets(line,fd)) begin
      rc=$sscanf(line,"%h %h %h %h %s %s %h %h",uid,tid,sid,pc,u,m,pid,vcid);
      if(rc==0) continue; if(rc!=8) `uvm_fatal("TS_SEQ","bad sequence line")
      t=ts_item::type_id::create("item"); t.uid=uid; t.tid=tid; t.stream_id=sid; t.pc=pc; t.pid=pid; t.vcid=vcid;
      if(u=="DTE") t.execute_unit=TS_DTE; else if(u=="MU") t.execute_unit=TS_MU;
      else if(u=="VU") t.execute_unit=TS_VU; else `uvm_fatal("TS_SEQ","invalid execute_unit")
      t.execution_mode=(m=="RVCORE_DSA")?TS_RVCORE_DSA:TS_RVCORE_ONLY;
      start_item(t); finish_item(t);
    end
    $fclose(fd);
  endtask
endclass

// Dispatches one task instance.  Task-owned fields are assigned directly;
// randomization is deliberately limited to the per-dispatch context.
class ts_dispatch_sequence extends uvm_sequence #(ts_item);
  `uvm_object_utils(ts_dispatch_sequence)
  bit [5:0] task_id;
  bit [31:0] start_pc;
  ts_execute_unit_e execute_unit;
  ts_execution_mode_e execution_mode;
  bit [7:0] pid;
  bit [1:0] vcid;
  bit random_context = 0;
  bit [15:0] directed_uid;
  bit [3:0] directed_stream_id;
  bit [15:0] dispatched_uid;
  bit [3:0] dispatched_stream_id;

  function new(string name="ts_dispatch_sequence"); super.new(name); endfunction

  task body();
    ts_item t=ts_item::type_id::create("item");
    if(random_context) begin
      if(!std::randomize(dispatched_uid,dispatched_stream_id))
        `uvm_fatal("TS_DISPATCH_SEQ","cannot randomize dispatch context")
    end else begin
      dispatched_uid=directed_uid;
      dispatched_stream_id=directed_stream_id;
    end
    t.tid=task_id;
    t.pc=start_pc;
    t.execute_unit=execute_unit;
    t.execution_mode=execution_mode;
    t.pid=pid;
    t.vcid=vcid;
    t.uid=dispatched_uid;
    t.stream_id=dispatched_stream_id;
    start_item(t);
    finish_item(t);
  endtask
endclass
