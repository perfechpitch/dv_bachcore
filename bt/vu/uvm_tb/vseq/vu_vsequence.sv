// ============================================================================
// Filename             : vu_vsequence.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_VSEQUENCE_SV
`define VU_VSEQUENCE_SV
class vu_vsequence extends vu_base_vsequence;

    `uvm_object_utils(vu_vsequence)

    function new(string name = "vu_vsequence");
        super.new(name);
    endfunction

    virtual task body();
    //    fork
    //        begin
    //            wait(p_sequencer.vu_case_cfg.exp_exe_num <= p_sequencer.vu_case_cfg.vu_ref_cfg.exe_num);
    //        end
    //        begin
    //            `uvm_do_on(xxx_seq,p_sequencer.xxx_sqr)
    //        end
    //        begin
    //            `uvm_do_on(reset_seq,p_sequencer.reset_sqr)
    //        end
    //    join_any
    endtask
endclass : vu_vsequence
`endif