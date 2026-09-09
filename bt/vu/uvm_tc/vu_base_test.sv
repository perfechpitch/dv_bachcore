// ============================================================================
// Filename             : vu_base_test.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_BASE_TEST_SV
`define VU_BASE_TEST_SV
class vu_base_test extends uvm_test;
    `uvm_component_utils(vu_base_test)

    vu_environment      vu_env;
    vu_case_config      vu_case_cfg;
    uvm_table_printer             printer;

    function new(string name="", uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        vu_env = vu_environment::type_id::create("vu_env", this);

        // Create a specific depth printer for printing the created topology
        printer = new();
        printer.knobs.depth = 3;

        set_report_max_quit_count(1);
        uvm_default_printer.knobs.begin_elements = -1;//print all elements of arrays and queues

        set_config_params();
        set_config_random();
        set_config_special_random();

    endfunction : build_phase

    function set_config_params();
        if(vu_case_cfg==null)begin
            vu_case_cfg = vu_case_config::type_id::create("vu_case_cfg",this);
            uvm_config_db#(vu_case_config)::set(this,"vu_env*","vu_case_cfg",this.vu_case_cfg);
        end
    endfunction

    virtual function set_config_random();
        assert(vu_case_cfg.randomize());
    endfunction

    virtual function void set_config_special_random();
        vu_case_cfg.random_case();
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),$sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
    endfunction : start_of_simulation_phase

    task run_phase(uvm_phase phase);
    endtask : run_phase

    function void extract_phase(uvm_phase phase);
    endfunction // void

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "\n\033[1m \033[40;32m ** UVM TEST PASS ** \033[0m", UVM_NONE)
    endfunction
endclass : vu_base_test
`endif