// ============================================================================
// Filename             : $(CLASSNAME)_monitor.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_MONITOR_SV
`define $(FILENAME)_MONITOR_SV
class $(CLASSNAME)_monitor extends uvm_monitor;
    // 
    // This property is the virtual interfaced needed for this component to drive
    // and view HDL signals.
    //
    virtual $(CLASSNAME)_if           $(CLASSNAME)_vif;
    $(CLASSNAME)_config               $(CLASSNAME)_cfg;
    ///////////////////////////////////////////////////////
    //open when need more than one agent
    //int                                xxx_num;

    // add for mul_core evironment,this environment will be  may times  which are equal to core_num
    // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
    //xxx_config                          xxx_cfg;

    // Opitional variable.
    //
    // Declare variable as file handle.
    //
    // For example:
    // int      $(CLASSNAME)_mon_log;
   
    //
    // Analysis port for delivering information from monitor to scoreboard.
    //
    uvm_analysis_port #($(CLASSNAME)_base_seq_item) $(CLASSNAME)_ap;

    // Transfer package
    protected $(CLASSNAME)_base_seq_item  $(CLASSNAME)_tr;
    
    //
    // User covergroup.
    // 
    // User can implement covergroups at here.
    //
    //keep interface cross in monitor,other covergroup in scb
    //`ifndef $(CLASSNAME)_MON_COV_DISABLE
    //covergroup cov_trans;
    //    option.per_instance = 1;
    //    trans_rdy_valid: coverpoint {$(CLASSNAME)_tr.valid,$(CLASSNAME)_tr.rdy}; 
    //    trans_if1 : coverpoint $(CLASSNAME)_tr.if1 {
    //        bins if1s[] = {1, 2, 4, 8};
    //        illegal_bins invalid_if1s = default; 
    //    }
    //    trans_if0Xif1 : cross trans_if0, trans_if1;
    //endgroup : cov_trans
    //`endif
    
    `uvm_component_utils_begin($(CLASSNAME)_monitor)
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        //
        // Instance user coverage groups.
        // Setting a unique instance name for new coverage group.
        //
        // For example:
        // if ($(CLASSNAME)_cfg.coverage_enable)begin
        //`ifndef $(CLASSNAME)_MON_COV_DISABLE
        //     cov_trans = new();
        //     cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
        //`endif

        //
        // Instance analysis port
        //
        $(CLASSNAME)_ap = new("$(CLASSNAME)_ap", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //
        // Retrieve the configuration and the virtual interface.
        //
        //get vif mode 1
        if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"","$(CLASSNAME)_cfg",$(CLASSNAME)_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"",$sformatf("$(CLASSNAME)_cfg%0d",xxx_num),$(CLASSNAME)_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});
        $(CLASSNAME)_vif = $(CLASSNAME)_cfg.$(CLASSNAME)_vif;

        //get vif mode 2
        //if this uvc has not agent,you should open this part to get if by yourself
        //if(!uvm_config_db#(virtual $(CLASSNAME)_if)::get(this,"","$(CLASSNAME)_vif",$(CLASSNAME)_vif))
        //    `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".$(CLASSNAME)_vif"});

        // add for mul_core evironment,this environment will be  may times  which are equal to core_num
        // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
        // if(!uvm_config_db#(xxx_config)::get(this,"","xxx_cfg",xxx_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".xxx_cfg"});
        
        // Specify uvm_info tag "$(FILENAME)_MON" with an action ,
        // which argument can take the value UVM_LOG. The uvm_info with 
        // tag "$(FILENAME)_MON" will print messages to a file pointed by  
        // the filehandle $(CLASSNAME)_mon_log.
        // 
        // two choice for log_name
        // 1: for one_core evironment
        // $(CLASSNAME)_mon_log = $fopen("./log/$(CLASSNAME).mon.log","w");
        //
        // 2: for mul_core evironment,this environment will be  may times  which are equal to core_num
        //    to avoild log confusedly in mul_core environment,we should split logs to one log per core
        // $(CLASSNAME)_mon_log = $fopen($sformatf("./log/core%0d_$(CLASSNAME).mon.log",xxx_cfg.core_num),"w");
        //
        // set_report_id_action("$(FILENAME)_MON",UVM_LOG);
        // set_report_id_file("$(FILENAME)_MON",$(CLASSNAME)_mon_log);
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();
    //extern virtual protected task collect_xxxx_phase();
    //extern virtual function void perform_transfer_checks();
    //extern virtual protected function void perform_transfer_coverage();
    //extern virtual function void report_phase(uvm_phase phase);

endclass : $(CLASSNAME)_monitor

task $(CLASSNAME)_monitor::reset_phase(uvm_phase phase);
    //
    // Reset all output signals
    //
    monitor_reset();
endtask : reset_phase

task $(CLASSNAME)_monitor::monitor_reset();
    //
    // User define task.
    //
    // This task is prepared for testbench random reset.
    //
    // User should reset all output signals and internal variables.
    //
    // ToDo
endtask :monitor_reset 

// main phase
task $(CLASSNAME)_monitor::main_phase(uvm_phase phase);
    fork
        collect_transactions();
    join
endtask : main_phase

task $(CLASSNAME)_monitor::collect_transactions();
    forever begin
    @($(CLASSNAME)_vif.mon_cb);
        if(!$(CLASSNAME)_vif.mon_cb.reset) begin
            monitor_reset();
        end
        else begin
            //
            // User define trigger.
            //
            // When condition meet,collect tranfer from bus.
/*
            if($(CLASSNAME)_vif.mon_cb.xxxxx) begin
                $(CLASSNAME)_tr = new();
                //
                // User define task.
                // 
                // Collect address/data information in the task. 
                // 
                // For example:
                // collect_xxxx_phase();
                //`uvm_info("$(FILENAME)_MON",$sformatf("Transfer collected :\n%s",$(CLASSNAME)_tr.sprint()), UVM_FULL)
                $(CLASSNAME)_ap.write($(CLASSNAME)_tr);

                // 
                // User define task.
                //
                // Task contains assertion checking the correctness of the
                // transfer.It can be switched on/off by a variable named
                // 'checks_enable' in config_class.
                //
                // For example:
                // if ($(CLASSNAME)_cfg.checks_enable)
                //   perform_transfer_checks();

                // 
                // User define task.
                //
                // Coverage sample task implement.This task can be switched
                // on/off by a variable named 'coverage_enable' in config_class.
                //
                // For example:
                // perform_transfer_coverage();
            end
*/
        end
    end
endtask : collect_transactions

//task $(CLASSNAME)_monitor::collect_xxxx_phase();
//endtask : collect_xxxx_phase

//
//Assertion implement 
//
//function void $(CLASSNAME)_monitor::perform_transfer_checks();
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
//function void $(CLASSNAME)_monitor::perform_transfer_coverage();
//    `ifndef $(CLASSNAME)_MON_COV_DISABLE
//        cov_trans.sample();
//    `endif
//endfunction : perform_transfer_coverage

//
// Report_phase will report some information which like coverage score at 
// the end of test.
//
//function void $(CLASSNAME)_monitor::report_phase(uvm_phase phase);
//    `uvm_info(get_full_name(),$sformatf("Covergroup 'cov_trans' coverage: %2f",cov_trans.get_inst_coverage()),UVM_LOW)
//endfunction
`endif