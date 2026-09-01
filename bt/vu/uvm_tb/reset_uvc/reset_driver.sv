// ============================================================================
// Filename             : reset_driver.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_DRIVER_SV
`define RESET_DRIVER_SV
class reset_driver extends uvm_driver #(reset_seq_item);
    virtual reset_if             reset_vif;
    reset_config                 reset_cfg;

    // int      reset_drv_log;

    `uvm_component_utils_begin(reset_driver)
    `uvm_component_utils_end

    function new(string name ,uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(reset_config)::get(this,"","reset_cfg",reset_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".reset_cfg"});

        reset_vif = reset_cfg.reset_vif;

        // reset_drv_log = $fopen("./log/reset.drv.log","w");
        // set_report_id_action("RESET_DRV",UVM_LOG);
        // set_report_id_file("RESET_DRV",reset_drv_log);
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    extern virtual protected task drive_tr();
endclass : reset_driver

task reset_driver::reset_phase(uvm_phase phase);
    driver_reset();
endtask : reset_phase

task reset_driver::main_phase(uvm_phase phase);
    while(1) begin
        fork
            get_and_drive();
        join_any
        disable fork;
        if(req!=null) begin
            if(req.is_active())
                this.end_tr(req);
        end
    end    
endtask : main_phase

task reset_driver::driver_reset();
    reset_vif.reset <= 1'b0;
endtask :driver_reset 

task reset_driver::get_and_drive();
    forever begin
    @(reset_vif.drv_cb);
        drive_tr();
    end
endtask : get_and_drive

task reset_driver::drive_tr();
    seq_item_port.get_next_item(req);
    seq_item_port.item_done();

    repeat(req.delay)begin
        @(negedge reset_vif.clk);
        @(reset_vif.drv_cb);
    end
    reset_vif.reset <= 1'b1;

    repeat(req.next_reset_delay)begin
        @(negedge reset_vif.clk);
        @(reset_vif.drv_cb);
    end

    if(reset_cfg.reset_type == RESET_RANDOM)begin
        reset_vif.reset <= 1'b0;
    end
    @(negedge reset_vif.clk);
endtask : drive_tr
`endif    