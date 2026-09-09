// ============================================================================
// Filename             : reset_base_sequence.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_BASE_SEQUENCE_SV
`define RESET_BASE_SEQUENCE_SV


class reset_base_sequence extends uvm_sequence#(reset_seq_item);

    
    `uvm_object_utils(reset_base_sequence)
    // Only the root sequence could get p_sequencer.
    `uvm_declare_p_sequencer(reset_sequencer)
    
    function new(string name = "reset_base_sequence");
        super.new(name);
    endfunction


endclass : reset_base_sequence

`endif