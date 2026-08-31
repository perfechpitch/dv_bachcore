// ============================================================================
// Filename             : $(CLASSNAME)_case_config.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_CASE_CONFIG_SV
`define $(FILENAME)_CASE_CONFIG_SV
class $(CLASSNAME)_case_config extends uvm_object;
    //reset_config     reset_cfg;    
    //xxx_config       xxx_cfg;    

    //int unsigned exe_num;
    //int unsigned exp_exe_num = 10000;

    `uvm_object_utils_begin($(CLASSNAME)_case_config)
        //`uvm_field_int          (exe_num,                                   UVM_DEFAULT | UVM_DEC)
        //`uvm_field_int          (exp_exe_num,                               UVM_DEFAULT | UVM_DEC)
        //`uvm_field_object       (reset_cfg,                                 UVM_DEFAULT | UVM_DEC)
        //`uvm_field_object       (xxx_cfg  ,                                 UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "$(CLASSNAME)_case_config");
        super.new(name);
        //ALL CFGs in enviroment
        //reset_cfg     = new();
        //xxx_cfg       = new();
    endfunction : new

    function random_case();
        //ALL DRV CFGs in enviroment
        //assert(reset_cfg.randomize());
        //assert(xxx_cfg.randomize());
    endfunction

endclass
`endif