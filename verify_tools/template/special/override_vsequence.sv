// ============================================================================
// Filename             : $(CLASSNAME)_override_vsequence.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef $(FILENAME)_OVERRIDE_VSEQUENCE_SV
`define $(FILENAME)_OVERRIDE_VSEQUENCE_SV


class $(CLASSNAME)_override_vsequence extends $(CLASSNAME)_base_vsequence;
    //
    // Declare user sub-sequences. 
    //
    // If this is a local virtual sequence, it should declare only one
    // sequence, and this sequence will send the declared sub-sequence by
    // sequencer, else if there are more than one sub-sequece be declared, 
    // this should be a global virtual sequence, the sub-sequences will
    // send by a virtual sequencer, using `uvm_do_on/`uvm_do_on_with macro.
    //
    // mqrs_tlb_except_seq     mqrs_tlb_seq;
    // rob_tlb_except_seq      rob_tlb_seq;

    `uvm_object_utils($(CLASSNAME)_override_vsequence)
    
    function new(string name = "$(CLASSNAME)_override_vsequence");
        super.new(name);
    endfunction

    virtual task body();
    
    //  
    // If this is a interrupt sequence,current virtual sequence will grab
    // the sequencer by a virtual sequencer(p_sequencer), when interrupt
    // event is triggered.
    //
    //     @p_sequencer.tlb_except;
    //     p_sequencer.mqrs_sqr.grab(this);
    //     p_sequencer.rob_cmt_sqr.grab(this);
    //
    // Global virtual sequence, use `uvm_do_on or `uvm_do_on_with macro
    // send virtual seq to target sequencer.If any of the sequences is 
    // finished, virtual sequence will drop_objection, and end this phase. 
    //
    //     `uvm_info(get_type_name(),$sformatf("%s virtual seq start...", get_sequence_path()), UVM_LOW);
    //
    //If interrupt sequence has forever seq with limited sqr,use choice 1
    //If interrupt sequence only has limited seq with limited sqr,use choice 2
    //choice 1:
    //     fork
    //         `uvm_do_on(mqrs_tlb_seq,p_sequencer.mqrs_sqr) //this sqr is forever sqr
    //         `uvm_do_on(rob_tlb_seq,p_sequencer.rob_sqr)   //this sqr is limited cnt sqr
    //     join_any
    //
    // If this is a interrupt sequence, then...
    //
    //     mqrs_tlb_seq.kill();    //interrupt over,kill forever sqr
    //     disable fork;
    //
    //choice 2:
    //     `uvm_do_on(mqrs_tlb_seq,p_sequencer.mqrs_sqr) //this sqr is limited sqr
    //     `uvm_do_on(rob_tlb_seq,p_sequencer.rob_sqr)   //this sqr is limited sqr
    //
    //     p_sequencer.mqrs_sqr.ungrab(this);
    //     p_sequencer.rob_cmt_sqr.ungrab(this);

    endtask

endclass : $(CLASSNAME)_override_vsequence

`endif