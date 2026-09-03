class ts_cfg extends uvm_object;
  `uvm_object_utils(ts_cfg)
  uvm_active_passive_enum is_active=UVM_ACTIVE; virtual ts_if vif; string sequence_file;
  function new(string name="ts_cfg"); super.new(name); endfunction
endclass
