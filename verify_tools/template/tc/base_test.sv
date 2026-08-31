// ============================================================================
// Filename             : $(CLASSNAME)_base_test.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_BASE_TEST_SV
`define $(FILENAME)_BASE_TEST_SV
class $(CLASSNAME)_base_test extends uvm_test;
    `uvm_component_utils($(CLASSNAME)_base_test)

    $(CLASSNAME)_environment      $(CLASSNAME)_env;
    $(CLASSNAME)_case_config      $(CLASSNAME)_case_cfg;
    uvm_table_printer             printer;

    function new(string name="", uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        //`uvm_info("build_phase", "Entered...", UVM_LOW);
        super.build_phase(phase);
        // Create the tb
        $(CLASSNAME)_env = $(CLASSNAME)_environment::type_id::create("$(CLASSNAME)_env", this);

        // Create a specific depth printer for printing the created topology
        printer = new();
        printer.knobs.depth = 3;

        set_report_max_quit_count(1);
        uvm_default_printer.knobs.begin_elements = -1;//print all elements of arrays and queues
        //uvm_top.set_timeout(100s,0);

        set_config_params();
        set_config_random();
        set_config_special_random();

        //`uvm_info("build_phase", "Exited...", UVM_LOW);
    endfunction : build_phase

    function set_config_params();
        if($(CLASSNAME)_case_cfg==null)begin
            $(CLASSNAME)_case_cfg = $(CLASSNAME)_case_config::type_id::create("$(CLASSNAME)_case_cfg",this);
            uvm_config_db#($(CLASSNAME)_case_config)::set(this,"$(CLASSNAME)_env*","$(CLASSNAME)_case_cfg",this.$(CLASSNAME)_case_cfg);
        end
    endfunction

    virtual function set_config_random();
        assert($(CLASSNAME)_case_cfg.randomize());
    endfunction

    virtual function void set_config_special_random();
        $(CLASSNAME)_case_cfg.random_case();
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        // Do something before run_phase
        `uvm_info(get_type_name(),$sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
    endfunction : start_of_simulation_phase

    task run_phase(uvm_phase phase);
        //`uvm_info("run_phase", "Entered...", UVM_LOW);
        //set a drain-time for the environment if desired
        //phase.phase_done.set_drain_time(this, 50ns);
        //`uvm_info("run_phase", "Exited...", UVM_LOW);
    endtask : run_phase

    function void extract_phase(uvm_phase phase);
    endfunction // void

    function void report_phase(uvm_phase phase);
        //`uvm_info(get_type_name(), "** UVM TEST PASS **", UVM_NONE)
        `uvm_info(get_type_name(), "\n\033[1m \033[40;32m ** UVM TEST PASS ** \033[0m", UVM_NONE)
    endfunction
endclass : $(CLASSNAME)_base_test
`endif