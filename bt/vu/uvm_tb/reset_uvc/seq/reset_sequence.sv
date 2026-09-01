// ============================================================================
// Filename             : reset_sequence.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef RESET_SEQUENCE_SV
`define RESET_SEQUENCE_SV


class reset_sequence extends reset_base_sequence; 

    `uvm_object_utils(reset_sequence)
    
    function new(string name = "reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        forever begin
            `uvm_create(req)
            req.reset_cfg = p_sequencer.reset_cfg;
            `uvm_rand_send(req)
        end
    endtask


endclass : reset_sequence

`endif