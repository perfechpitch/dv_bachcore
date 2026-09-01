// ============================================================================
// Filename             : reset_agent.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_AGENT_SV
`define RESET_AGENT_SV
class reset_agent extends uvm_agent;
    reset_config                  reset_cfg;    
    reset_driver                  reset_drv;
    reset_sequencer               reset_sqr;
    reset_monitor                 reset_mon;
    
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(reset_agent)
        `uvm_field_object(reset_cfg,          UVM_DEFAULT)    
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(reset_config)::get(this,"","reset_cfg",reset_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".reset_cfg"});
        if(!uvm_config_db#(virtual reset_if)::get(this,"","reset_vif",reset_cfg.reset_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reset_vif"});

        reset_mon = reset_monitor::type_id::create("reset_mon", this);
    
        if(reset_cfg.is_active == UVM_ACTIVE) begin
          reset_sqr = reset_sequencer::type_id::create("reset_sqr", this);
          reset_drv = reset_driver::type_id::create("reset_drv", this);
        end
    endfunction : build_phase
    
    // connect_phase
    function void connect_phase(uvm_phase phase);
        if(reset_cfg.is_active == UVM_ACTIVE) begin
            reset_drv.seq_item_port.connect(reset_sqr.seq_item_export);
        end
    endfunction : connect_phase
endclass : reset_agent
`endif