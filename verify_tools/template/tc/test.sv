// ============================================================================
// Filename             : $(CLASSNAME)_test.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef $(FILENAME)_TEST_SV
`define $(FILENAME)_TEST_SV 
class $(CLASSNAME)_test extends $(CLASSNAME)_base_test;
    `uvm_component_utils($(CLASSNAME)_test)

    function new(string name="", uvm_component parent=null);
        super.new(name,parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        //`uvm_info("build_phase", "Entered...", UVM_LOW);
        set_config_params();

        // 
        // Set default sequence. 
        //
        uvm_config_db#(uvm_object_wrapper)::set(this,"$(CLASSNAME)_env.$(CLASSNAME)_vsqr.main_phase", "default_sequence",$(CLASSNAME)_vsequence::type_id::get());

        // Create the tb
        super.build_phase(phase);

        //`uvm_info("build_phase", "Exited...", UVM_LOW);
    endfunction : build_phase

    //extern function void set_config_special_random();
endclass : $(CLASSNAME)_test

//function void $(CLASSNAME)_test::set_config_params(); 
//    $(CLASSNAME)_case_cfg.xxx_case();
//endfunction
`endif