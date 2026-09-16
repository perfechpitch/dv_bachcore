// ============================================================================
// Filename             : router_driver.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_DRIVER_SV
`define ROUTER_DRIVER_SV
class router_driver extends uvm_driver #(router_seq_item);
    virtual router_if             router_vif;
    router_config                 router_cfg;
    ///////////////////////////////////////////////////////
    //open when need more than one agent
    //int                                  xxx_num;

    // add for mul_core evironment,this environment will be  may times  which are equal to core_num
    // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
    //xxx_config                          xxx_cfg;

    // Opitional variable.
    //
    // Declare variable as file handle.
    //
    // For example:
    // int      router_drv_log;

    `uvm_component_utils_begin(router_driver)
    `uvm_component_utils_end

    function new(string name ,uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //
        // Retrieve the configuration and the virtual interface.
        //
        if(!uvm_config_db#(router_config)::get(this,"","router_cfg",router_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#(router_config)::get(this,"",$sformatf("router_cfg%0d",xxx_num),router_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});

        // add for mul_core evironment,this environment will be  may times  which are equal to core_num
        // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
        // if(!uvm_config_db#(xxx_config)::get(this,"","xxx_cfg",xxx_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".xxx_cfg"});

        router_vif = router_cfg.router_vif;

        // Specify uvm_info tag "ROUTER_DRV" with an action ,
        //
        // which argument can take the value UVM_LOG. The uvm_info with
        //
        // tag "ROUTER_DRV" will print messages to a file pointed by
        //
        // the filehandle router_drv_log.
        //
        // two choice for log_name
        // 1: for one_core evironment
        // router_drv_log = $fopen("./log/router.drv.log","w");
        //
        // 2: for mul_core evironment,this environment will be  may times  which are equal to core_num
        //    to avoild log confusedly in mul_core environment,we should split logs to one log per core
        // router_drv_log = $fopen($sformatf("./log/core%0d_router.drv.log",xxx_cfg.core_num),"w");
        //
        // set_report_id_action("ROUTER_DRV",UVM_LOG);
        // set_report_id_file("ROUTER_DRV",router_drv_log);
    endfunction: build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    //
    // Add usr tasks && functions
    //
    // ToDo
endclass : router_driver

task router_driver::driver_reset();
    //
    // User define task.
    //
    // This task is prepared for testbench random reset.
    //
    // User should reset all output signals and internal variables.
    //
    // ToDo
endtask :driver_reset

task router_driver::reset_phase(uvm_phase phase);
    //
    // Reset all output signals
    //
    driver_reset();
endtask : reset_phase

task router_driver::main_phase(uvm_phase phase);
    while(1) begin
        driver_reset();
        fork
            begin
                @(negedge router_vif.drv_cb.reset);
                `uvm_info(get_type_name(),"DRV RESET",UVM_HIGH)
            end
            get_and_drive();
        join_any
        disable fork;
        if(req!=null) begin
            if(req.is_active())   // this is active when you use get_next_item,but you do not use item_done
                this.end_tr(req); // this is equal with item_done
        end
    end
endtask : main_phase

task router_driver::get_and_drive();
    forever begin
        @(router_vif.drv_cb);
        if(router_vif.drv_cb.reset) begin
            seq_item_port.get_next_item(req);
            //$cast(rsp, req.clone());
            //rsp.set_id_info(req);
            seq_item_port.item_done();
            //seq_item_port.put_response(rsp);
            //
            // User define task.
            //
            //
            // Implement a task to drive signals
            //
            // following the information in seq_item.
            //
            // For example:
            // drive_transfer(req);

        end
    end
endtask : get_and_drive
`endif