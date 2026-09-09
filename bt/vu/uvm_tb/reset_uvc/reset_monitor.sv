// ============================================================================
// Filename             : reset_monitor.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_MONITOR_SV
`define RESET_MONITOR_SV
class reset_monitor extends uvm_monitor;
    virtual reset_if           reset_vif;
    reset_config               reset_cfg;

    // Analysis port for delivering information from monitor to scoreboard.
    uvm_analysis_port #(reset_seq_item) reset_ap;

    protected reset_seq_item  trans_collected;
    
    
    `uvm_component_utils_begin(reset_monitor)
    `uvm_component_utils_end
    
    function new (string name, uvm_component parent);
        super.new(name, parent);

        reset_ap = new("reset_ap", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(reset_config)::get(this,"","reset_cfg",reset_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".reset_cfg"});

        reset_vif = reset_cfg.reset_vif;
        
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();

endclass : reset_monitor

task reset_monitor::reset_phase(uvm_phase phase);
endtask : reset_phase

task reset_monitor::monitor_reset();
endtask :monitor_reset 

task reset_monitor::main_phase(uvm_phase phase);
    fork
        collect_transactions();
    join
endtask : main_phase

task reset_monitor::collect_transactions();
    forever begin
    @(reset_vif.mon_cb);
        if(!reset_vif.mon_cb.reset) begin
            monitor_reset();
        end
    end
endtask : collect_transactions

`endif