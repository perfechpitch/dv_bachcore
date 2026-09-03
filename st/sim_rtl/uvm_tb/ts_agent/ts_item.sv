typedef enum bit [1:0] {TS_DTE=0,TS_MU=1,TS_VU=2} ts_execute_unit_e;
typedef enum bit {TS_RVCORE_ONLY=0,TS_RVCORE_DSA=1} ts_execution_mode_e;
class ts_item extends uvm_sequence_item;
  rand bit [15:0] uid; rand bit [5:0] tid; rand bit [3:0] stream_id; rand bit [31:0] pc;
  rand ts_execute_unit_e execute_unit; rand ts_execution_mode_e execution_mode;
  rand bit [5:0] pid; rand bit [1:0] vcid;
  `uvm_object_utils_begin(ts_item)
    `uvm_field_int(uid,UVM_HEX) `uvm_field_int(tid,UVM_HEX) `uvm_field_int(stream_id,UVM_HEX)
    `uvm_field_int(pc,UVM_HEX) `uvm_field_enum(ts_execute_unit_e,execute_unit,UVM_DEFAULT)
    `uvm_field_enum(ts_execution_mode_e,execution_mode,UVM_DEFAULT)
    `uvm_field_int(pid,UVM_HEX) `uvm_field_int(vcid,UVM_HEX)
  `uvm_object_utils_end
  function new(string name="ts_item"); super.new(name); endfunction
endclass
