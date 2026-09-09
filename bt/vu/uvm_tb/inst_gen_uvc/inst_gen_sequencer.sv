// ============================================================================
// Filename             : inst_gen_sequencer.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_SEQUENCER_SV
`define INST_GEN_SEQUENCER_SV 
class inst_gen_sequencer extends uvm_sequencer #(inst_gen_seq_item);
    inst_gen_config      inst_gen_cfg;

    `uvm_component_utils_begin(inst_gen_sequencer)
    `uvm_component_utils_end
      
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(inst_gen_config)::get(this,"","inst_gen_cfg",inst_gen_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".inst_gen_cfg"});
    endfunction : build_phase
endclass : inst_gen_sequencer
`endif