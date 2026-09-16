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
