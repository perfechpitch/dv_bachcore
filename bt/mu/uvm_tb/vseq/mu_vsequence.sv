// ============================================================================
// Filename             : mu_vsequence.sv
// Author               : kippy
// Created On           : 2026-9-18 10:21
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef MU_VSEQUENCE_SV
`define MU_VSEQUENCE_SV
class mu_vsequence extends mu_base_vsequence;

    `uvm_object_utils(mu_vsequence)

    function new(string name = "mu_vsequence");
        super.new(name);
    endfunction

    virtual task body();
    //    fork
    //        begin
    //            wait(p_sequencer.mu_case_cfg.exp_exe_num <= p_sequencer.mu_case_cfg.mu_ref_cfg.exe_num);
    //        end
    //        begin
    //            `uvm_do_on(xxx_seq,p_sequencer.xxx_sqr)
    //        end
    //        begin
    //            `uvm_do_on(reset_seq,p_sequencer.reset_sqr)
    //        end
    //    join_any
    endtask
endclass : mu_vsequence
`endif