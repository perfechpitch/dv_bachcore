class rv_dsa_item extends uvm_sequence_item;
  rand bit rw;
  rand bit [31:0] addr, wdata;
  rand bit [3:0] stream_id;
  rand bit [5:0] task_id, path_id;
  rand bit [15:0] user_id;
  rand bit [1:0] vc_id;
  bit [31:0] rdata;
  int unsigned seq_idx;
  `uvm_object_utils_begin(rv_dsa_item)
    `uvm_field_int(rw,UVM_DEFAULT) `uvm_field_int(addr,UVM_HEX)
    `uvm_field_int(wdata,UVM_HEX) `uvm_field_int(stream_id,UVM_DEFAULT)
    `uvm_field_int(task_id,UVM_HEX) `uvm_field_int(user_id,UVM_HEX)
    `uvm_field_int(path_id,UVM_HEX) `uvm_field_int(vc_id,UVM_DEFAULT)
    `uvm_field_int(rdata,UVM_HEX) `uvm_field_int(seq_idx,UVM_DEFAULT)
  `uvm_object_utils_end
  function new(string name="rv_dsa_item"); super.new(name); endfunction
endclass
