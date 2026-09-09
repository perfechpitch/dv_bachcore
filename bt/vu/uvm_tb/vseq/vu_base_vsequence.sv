// ============================================================================
// Filename             : vu_base_vsequence.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_BASE_VSEQUENCE_SV
`define VU_BASE_VSEQUENCE_SV
class vu_base_vsequence extends uvm_sequence;
    reset_sequence          reset_seq;
    inst_gen_seq_lib        inst_gen_seq;

    `uvm_object_utils(vu_base_vsequence)
    `uvm_declare_p_sequencer(vu_vsequencer)

    function new(string name = "vu_base_vsequence");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction
endclass : vu_base_vsequence
`endif