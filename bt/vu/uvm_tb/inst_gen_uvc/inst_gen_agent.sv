// ============================================================================
// Filename             : inst_gen_agent.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_AGENT_SV
`define INST_GEN_AGENT_SV
class inst_gen_agent extends uvm_agent;
    inst_gen_config                  inst_gen_cfg;    
    inst_gen_driver                  inst_gen_drv;
    inst_gen_sequencer               inst_gen_sqr;
    inst_gen_monitor                 inst_gen_mon;

    `uvm_component_utils_begin(inst_gen_agent)
        `uvm_field_object(inst_gen_cfg,          UVM_DEFAULT)    
    `uvm_component_utils_end
 
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(inst_gen_config)::get(this,"","inst_gen_cfg",inst_gen_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".inst_gen_cfg"});
        if(!uvm_config_db#(virtual inst_gen_if)::get(this,"","inst_gen_vif",inst_gen_cfg.inst_gen_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".inst_gen_vif"});

        get_args();
        inst_gen_mon         = inst_gen_monitor::type_id::create("inst_gen_mon", this);
    
        if(inst_gen_cfg.is_active == UVM_ACTIVE) begin
            inst_gen_sqr         = inst_gen_sequencer::type_id::create("inst_gen_sqr", this);
            inst_gen_drv         = inst_gen_driver::type_id::create("inst_gen_drv", this);
        end
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        if(inst_gen_cfg.is_active == UVM_ACTIVE) begin
            inst_gen_drv.seq_item_port.connect(inst_gen_sqr.seq_item_export);
        end
    endfunction : connect_phase

    function get_args();
    endfunction : get_args
endclass : inst_gen_agent
`endif