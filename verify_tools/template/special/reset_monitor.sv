// ============================================================================
// Filename             : $(CLASSNAME)_reset_monitor.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef $(FILENAME)_RESET_MONITOR_SV
`define $(FILENAME)_RESET_MONITOR_SV

class $(CLASSNAME)_reset_monitor extends uvm_reset_monitor;
    // 
    // This property is the virtual interfaced needed for this component to drive
    // and view HDL signals.
    //
    virtual $(CLASSNAME)_reset_if           $(CLASSNAME)_reset_vif;
    $(CLASSNAME)_reset_config               $(CLASSNAME)_reset_cfg;
    // add for mul_core evironment,this environment will be  may times  which are equal to core_num
    // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
    //xxx_config                          xxx_cfg;

    //$(CLASSNAME)_reference         $(CLASSNAME)_ref;
    //$(CLASSNAME)_scoreboard        //$(CLASSNAME)_scb;

    // Opitional variable.
    //
    // Declare variable as file handle.
    //
    // For example:
    // int      $(CLASSNAME)_reset_mon_log;
   
    // User covergroup.
    // 
    // User can implement covergroups at here.
    //
    
    //covergroup cov_trans;
    //    option.per_instance = 1;
    //    trans_start_addr : coverpoint $(CLASSNAME)_tr.addr {
    //        option.auto_bin_max = 16; 
    //    }
    //    trans_dir  : coverpoint $(CLASSNAME)_tr.read_write;
    //    trans_size : coverpoint $(CLASSNAME)_tr.size {
    //        bins sizes[] = {1, 2, 4, 8};
    //        illegal_bins invalid_sizes = default; 
    //    }
    //    trans_addrXdir : cross trans_start_addr, trans_dir;
    //    trans_dirXsize : cross trans_dir, trans_size;
    //endgroup : cov_trans
    
    `uvm_component_utils_begin($(CLASSNAME)_reset_monitor)
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        //
        // Instance user coverage groups.
        // Setting a unique instance name for new coverage group.
        //
        // For example:
        // cov_trans = new();
        // cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //
        // Retrieve the configuration and the virtual interface.
        //
        if(!uvm_config_db#($(CLASSNAME)_reset_config)::get(this,"","$(CLASSNAME)_reset_cfg",$(CLASSNAME)_reset_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_reset_cfg"});

        // add for mul_core evironment,this environment will be  may times  which are equal to core_num
        // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
        // if(!uvm_config_db#(xxx_config)::get(this,"","xxx_cfg",xxx_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".xxx_cfg"});

        $(CLASSNAME)_reset_vif = $(CLASSNAME)_reset_cfg.$(CLASSNAME)_reset_vif;
        
        // Specify uvm_info tag "$(FILENAME)_reset_mon" with an action ,
        // which argument can take the value UVM_LOG. The uvm_info with 
        // tag "$(FILENAME)_reset_mon" will print messages to a file pointed by  
        // the filehandle $(CLASSNAME)_reset_mon_log.
        // 
        // two choice for log_name
        // 1: for one_core evironment
        // $(CLASSNAME)_reset_mon_log = $fopen("./log/$(CLASSNAME).mon.log","w");
        //
        // 2: for mul_core evironment,this environment will be  may times  which are equal to core_num
        //    to avoild log confusedly in mul_core environment,we should split logs to one log per core
        // $(CLASSNAME)_reset_mon_log = $fopen($sformatf("./log/core%0d_$(CLASSNAME).mon.log",xxx_cfg.core_num),"w");
        //
        // set_report_id_action("$(FILENAME)_reset_mon",UVM_LOG);
        // set_report_id_file("$(FILENAME)_reset_mon",$(CLASSNAME)_reset_mon_log);
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();
    //extern virtual protected task collect_xxxx_phase();
    //extern virtual function void perform_transfer_checks();
    //extern virtual protected function void perform_transfer_coverage();
    //extern virtual function void report_phase(uvm_phase phase);

endclass : $(CLASSNAME)_reset_monitor

task $(CLASSNAME)_reset_monitor::reset_phase(uvm_phase phase);
    //
    // Reset all output signals
    //
    monitor_reset();
endtask : reset_phase

task $(CLASSNAME)_reset_monitor::monitor_reset();
    //
    // User define task.
    //
    // This task is prepared for testbench random reset.
    //
    // User should reset all output signals and internal variables.
    //
    // ToDo
    //reset ref & scb & notiming class
    //$(CLASSNAME)_ref.reset_ref();
    //$(CLASSNAME)_scb.reset_scb();
endtask :monitor_reset 

// main phase
task $(CLASSNAME)_reset_monitor::main_phase(uvm_phase phase);
    fork
        collect_transactions();
    join
endtask : main_phase

task $(CLASSNAME)_reset_monitor::collect_transactions();
    forever begin
    @($(CLASSNAME)_reset_vif.mon_cb);
        if(!$(CLASSNAME)_reset_vif.mon_cb.reset) begin
            monitor_reset();
        end
    end
endtask : collect_transactions

//task $(CLASSNAME)_reset_monitor::collect_xxxx_phase();
//endtask : collect_xxxx_phase

//
//Assertion implement 
//
//function void $(CLASSNAME)_reset_monitor::perform_transfer_checks();
//    assert_transfer_size : assert($(CLASSNAME)_tr.size == 1 || 
//        $(CLASSNAME)_tr.size == 2 || $(CLASSNAME)_tr.size == 4 || 
//        $(CLASSNAME)_tr.size == 8) 
//        else begin
//            `uvm_error(get_type_name(),"Invalid transfer size!")
//        end
//endfunction : perform_transfer_checks

//
//Coverage sample
//
//function void $(CLASSNAME)_reset_monitor::perform_transfer_coverage();
//    cov_trans.sample();
//endfunction : perform_transfer_coverage

//
// Report_phase will report some information which like coverage score at 
// the end of test.
//
//function void $(CLASSNAME)_reset_monitor::report_phase(uvm_phase phase);
//    `uvm_info(get_full_name(),$sformatf("Covergroup 'cov_trans' coverage: %2f",cov_trans.get_inst_coverage()),UVM_LOW)
//endfunction
`endif