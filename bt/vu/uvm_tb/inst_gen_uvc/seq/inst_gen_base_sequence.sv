// ============================================================================
// Filename             : inst_gen_base_sequence.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_BASE_SEQUENCE_SV
`define INST_GEN_BASE_SEQUENCE_SV
class inst_gen_base_sequence extends uvm_sequence#(inst_gen_seq_item);
    `uvm_object_utils(inst_gen_base_sequence)
    `uvm_declare_p_sequencer(inst_gen_sequencer)
    
    function new(string name = "inst_gen_base_sequence");
        super.new(name);
    endfunction
endclass : inst_gen_base_sequence
`endif