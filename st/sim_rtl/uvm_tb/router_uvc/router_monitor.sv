// ============================================================================
// Filename             : router_monitor.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_MONITOR_SV
`define ROUTER_MONITOR_SV
class router_monitor extends uvm_monitor;
    //
    // This property is the virtual interfaced needed for this component to drive
    // and view HDL signals.
    //
    virtual router_if           router_vif;
    router_config               router_cfg;
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
    // int      router_mon_log;

    //
    // Analysis port for delivering information from monitor to scoreboard.
    //
    uvm_analysis_port #(router_base_seq_item) router_ap;

    // Transfer package
    protected router_base_seq_item  router_tr;

    //
    // User covergroup.
    //
    // User can implement covergroups at here.
    //
    //keep interface cross in monitor,other covergroup in scb
    //`ifndef router_MON_COV_DISABLE
    //covergroup cov_trans;
    //    option.per_instance = 1;
    //    trans_rdy_valid: coverpoint {router_tr.valid,router_tr.rdy};
    //    trans_if1 : coverpoint router_tr.if1 {
    //        bins if1s[] = {1, 2, 4, 8};
    //        illegal_bins invalid_if1s = default;
    //    }
    //    trans_if0Xif1 : cross trans_if0, trans_if1;
    //endgroup : cov_trans
    //`endif

    `uvm_component_utils_begin(router_monitor)
    `uvm_component_utils_end

    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        //
        // Instance user coverage groups.
        // Setting a unique instance name for new coverage group.
        //
        // For example:
        // if (router_cfg.coverage_enable)begin
        //`ifndef router_MON_COV_DISABLE
        //     cov_trans = new();
        //     cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
        //`endif

        //
        // Instance analysis port
        //
        router_ap = new("router_ap", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //
        // Retrieve the configuration and the virtual interface.
        //
        //get vif mode 1
        if(!uvm_config_db#(router_config)::get(this,"","router_cfg",router_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#(router_config)::get(this,"",$sformatf("router_cfg%0d",xxx_num),router_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});
        router_vif = router_cfg.router_vif;

        //get vif mode 2
        //if this uvc has not agent,you should open this part to get if by yourself
        //if(!uvm_config_db#(virtual router_if)::get(this,"","router_vif",router_vif))
        //    `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".router_vif"});

        // add for mul_core evironment,this environment will be  may times  which are equal to core_num
        // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
        // if(!uvm_config_db#(xxx_config)::get(this,"","xxx_cfg",xxx_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".xxx_cfg"});

        // Specify uvm_info tag "ROUTER_MON" with an action ,
        // which argument can take the value UVM_LOG. The uvm_info with
        // tag "ROUTER_MON" will print messages to a file pointed by
        // the filehandle router_mon_log.
        //
        // two choice for log_name
        // 1: for one_core evironment
        // router_mon_log = $fopen("./log/router.mon.log","w");
        //
        // 2: for mul_core evironment,this environment will be  may times  which are equal to core_num
        //    to avoild log confusedly in mul_core environment,we should split logs to one log per core
        // router_mon_log = $fopen($sformatf("./log/core%0d_router.mon.log",xxx_cfg.core_num),"w");
        //
        // set_report_id_action("ROUTER_MON",UVM_LOG);
        // set_report_id_file("ROUTER_MON",router_mon_log);
    endfunction: build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();
    //extern virtual protected task collect_xxxx_phase();
    //extern virtual function void perform_transfer_checks();
    //extern virtual protected function void perform_transfer_coverage();
    //extern virtual function void report_phase(uvm_phase phase);

endclass : router_monitor

task router_monitor::reset_phase(uvm_phase phase);
    //
    // Reset all output signals
    //
    monitor_reset();
endtask : reset_phase

task router_monitor::monitor_reset();
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
task router_monitor::main_phase(uvm_phase phase);
    fork
        collect_transactions();
    join
endtask : main_phase

task router_monitor::collect_transactions();
    forever begin
    @(router_vif.mon_cb);
        if(!router_vif.mon_cb.reset) begin
            monitor_reset();
        end
        else begin
            //
            // User define trigger.
            //
            // When condition meet,collect tranfer from bus.
/*
            if(router_vif.mon_cb.xxxxx) begin
                router_tr = new();
                //
                // User define task.
                //
                // Collect address/data information in the task.
                //
                // For example:
                // collect_xxxx_phase();
                //`uvm_info("ROUTER_MON",$sformatf("Transfer collected :\n%s",router_tr.sprint()), UVM_FULL)
                router_ap.write(router_tr);

                //
                // User define task.
                //
                // Task contains assertion checking the correctness of the
                // transfer.It can be switched on/off by a variable named
                // 'checks_enable' in config_class.
                //
                // For example:
                // if (router_cfg.checks_enable)
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

//task router_monitor::collect_xxxx_phase();
//endtask : collect_xxxx_phase

//
//Assertion implement
//
//function void router_monitor::perform_transfer_checks();
//    assert_transfer_size : assert(router_tr.size == 1 ||
//        router_tr.size == 2 || router_tr.size == 4 ||
//        router_tr.size == 8)
//        else begin
//            `uvm_error(get_type_name(),"Invalid transfer size!")
//        end
//endfunction : perform_transfer_checks

//
//Coverage sample
//
//function void router_monitor::perform_transfer_coverage();
//    `ifndef router_MON_COV_DISABLE
//        cov_trans.sample();
//    `endif
//endfunction : perform_transfer_coverage

//
// Report_phase will report some information which like coverage score at
// the end of test.
//
//function void router_monitor::report_phase(uvm_phase phase);
//    `uvm_info(get_full_name(),$sformatf("Covergroup 'cov_trans' coverage: %2f",cov_trans.get_inst_coverage()),UVM_LOW)
//endfunction
`endif