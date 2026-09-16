typedef enum {REQ_GAP_FIXED, REQ_GAP_RANDOM} rv_dsa_req_gap_mode_e;
class rv_dsa_cfg extends uvm_object;
  `uvm_object_utils(rv_dsa_cfg)
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  rv_dsa_req_gap_mode_e req_gap_mode = REQ_GAP_FIXED;
  int unsigned req_gap = 0;
  int unsigned req_gap_min = 0;
  int unsigned req_gap_max = 0;
  string req_log_file;
  virtual rv_dsa_if vif;
  function new(string name="rv_dsa_cfg"); super.new(name); endfunction
endclass
