// ============================================================================
// Filename             : $(CLASSNAME)_env_config.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_ENV_CONFIG_SV
`define $(FILENAME)_ENV_CONFIG_SV
class $(CLASSNAME)_env_config extends uvm_object;
    // Switch on/off UVC
    // bit has_ci_monitor  = 1;
    // bit has_memqrs      = 1;
    // bit has_rob         = 1; 
    // bit has_cp0         = 1; 
    // bit has_alu         = 1;
    // bit has_gprfile     = 1;
    // bit has_fprfile     = 1;
    // bit has_vrfile      = 1;
    // bit has_bqu         = 1;
    // bit has_tlb         = 1;


    `uvm_object_utils_begin($(CLASSNAME)_env_config)
       // `uvm_field_int(has_ci_monitor,          UVM_DEFAULT)
       // `uvm_field_int(has_memqrs,              UVM_DEFAULT)
       // `uvm_field_int(has_rob,                 UVM_DEFAULT)
       // `uvm_field_int(has_cp0,                 UVM_DEFAULT)
       // `uvm_field_int(has_alu,                 UVM_DEFAULT)
       // `uvm_field_int(has_gprfile,             UVM_DEFAULT)
       // `uvm_field_int(has_fprfile,             UVM_DEFAULT)
       // `uvm_field_int(has_vrfile,              UVM_DEFAULT)
       // `uvm_field_int(has_bqu,                 UVM_DEFAULT)
       // `uvm_field_int(has_tlb,                 UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "$(CLASSNAME)_env_config");
        super.new(name);
    endfunction : new
endclass
`endif