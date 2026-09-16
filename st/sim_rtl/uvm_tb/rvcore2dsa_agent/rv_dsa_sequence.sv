class rv_dsa_sequence extends uvm_sequence #(rv_dsa_item);
  `uvm_object_utils(rv_dsa_sequence)
  rv_dsa_cfg cfg;
  function new(string name="rv_dsa_sequence"); super.new(name); endfunction
  task body();
    int fd, rc, idx;
    string line, op;
    bit [31:0] addr, wdata;
    bit [3:0] stream_id;
    bit [5:0] task_id, path_id;
    bit [15:0] user_id;
    bit [1:0] vc_id;
    rv_dsa_item item;
    if(cfg == null) `uvm_fatal("RV_DSA_SEQ","cfg is null")
    fd = $fopen(cfg.req_log_file, "r");
    if(!fd) `uvm_fatal("RV_DSA_SEQ", $sformatf("cannot open request log: %s",cfg.req_log_file))
    idx = 0;
    while($fgets(line,fd)) begin
      rc=$sscanf(line,"%s %h %h %h %h %h %h %h",op,addr,wdata,stream_id,task_id,user_id,path_id,vc_id);
      if(rc == 0) continue;
      if(rc != 8 || !(op=="R" || op=="W"))
        `uvm_fatal("RV_DSA_SEQ",$sformatf("bad request log line: %s",line))
      item=rv_dsa_item::type_id::create($sformatf("item_%0d",idx));
      item.rw=(op=="W"); item.addr=addr; item.wdata=wdata;
      item.stream_id=stream_id; item.task_id=task_id; item.user_id=user_id;
      item.path_id=path_id; item.vc_id=vc_id; item.seq_idx=idx++;
      start_item(item); finish_item(item);
    end
    $fclose(fd);
  endtask
endclass
