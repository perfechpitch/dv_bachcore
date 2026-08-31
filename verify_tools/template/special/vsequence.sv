// ============================================================================
// Filename             : $(CLASSNAME)_vsequence.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_VSEQUENCE_SV
`define $(FILENAME)_VSEQUENCE_SV
class $(CLASSNAME)_vsequence extends $(CLASSNAME)_base_vsequence;

    `uvm_object_utils($(CLASSNAME)_vsequence)

    function new(string name = "$(CLASSNAME)_vsequence");
        super.new(name);
    endfunction

    virtual task body();
    //    fork
    //        begin
    //            wait(p_sequencer.$(CLASSNAME)_case_cfg.exp_exe_num <= p_sequencer.$(CLASSNAME)_case_cfg.$(CLASSNAME)_ref_cfg.exe_num);
    //        end
    //        begin
    //            `uvm_do_on(xxx_seq,p_sequencer.xxx_sqr)
    //        end
    //        begin
    //            `uvm_do_on(reset_seq,p_sequencer.reset_sqr)
    //        end
    //    join_any
    endtask
endclass : $(CLASSNAME)_vsequence
`endif