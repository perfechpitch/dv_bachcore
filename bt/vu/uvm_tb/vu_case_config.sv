// ============================================================================
// Filename             : vu_case_config.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_CASE_CONFIG_SV
`define VU_CASE_CONFIG_SV
class vu_case_config extends uvm_object;
    reset_config     reset_cfg;    

    //int unsigned exe_num;
    //int unsigned exp_exe_num = 10000;

    `uvm_object_utils_begin(vu_case_config)
        //`uvm_field_int          (exe_num,                                   UVM_DEFAULT | UVM_DEC)
        //`uvm_field_int          (exp_exe_num,                               UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (reset_cfg,                                 UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "vu_case_config");
        super.new(name);
        reset_cfg     = new();
    endfunction : new

    function random_case();
        assert(reset_cfg.randomize());
    endfunction

endclass
`endif
