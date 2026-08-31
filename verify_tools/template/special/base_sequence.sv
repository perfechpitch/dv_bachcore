// ============================================================================
// Filename             : $(CLASSNAME)_base_vsequence.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_BASE_VSEQUENCE_SV
`define $(FILENAME)_BASE_VSEQUENCE_SV
class $(CLASSNAME)_base_vsequence extends uvm_sequence;
    //
    // Declare user sub-sequences. 
    //
    // If this is a local virtual sequence, it should declare only one
    // sequence, and this sequence will send the declared sub-sequence by
    // sequencer, else if there are more than one sub-sequece be declared, 
    // this should be a global virtual sequence, the sub-sequences will
    // send by a virtual sequencer, using `uvm_do_on/`uvm_do_on_with macro.
    //
    // xxx_sequence     xxx_seq;
    // reset_sequence   reset_seq;

    `uvm_object_utils($(CLASSNAME)_base_vsequence)
    `uvm_declare_p_sequencer($(CLASSNAME)_vsequencer)


    function new(string name = "$(CLASSNAME)_base_vsequence");
        super.new(name);
        //If uvm version is 1.2 or upper, use set_automatic_phase_objection instead of starting_phase
        set_automatic_phase_objection(1);
    endfunction

    // Raise in pre_body so the objection is only raised for root sequences.
    // There is no need to raise for sub-sequences since the root sequence
    // will encapsulate the sub-sequence.
    // starting_phase only used in uvm_version under 1.1
    //
    // For example:
    // virtual task pre_body();
    //     this.xxx_cfg = p_sequencer.xxx_sqr.xxx_cfg;
    //     if(uvm_version is under or equal 1.1) begin
    //     if(this.starting_phase != null) begin
    //         `uvm_info(get_type_name(),
    //             $sformatf("%s pre_body() raising %s objection",
    //                 get_sequence_path(),
    //                 starting_phase.get_name()), UVM_MEDIUM);
    //         starting_phase.raise_objection(this);
    //     end
    //     end
    // endtask

    // Drop the objection in the post_body so the objection is removed when
    // the root sequence is complete. 
    //
    // For example:
    // virtual task post_body();
    //     if (uvm_version under or equal 1.1) begin
    //     if(this.starting_phase != null) begin
    //         `uvm_info(get_type_name(),
    //             $sformatf("%s post_body() dropping %s objection",
    //                 get_sequence_path(),
    //                 starting_phase.get_name()), UVM_MEDIUM);
    //         starting_phase.drop_objection(this);
    //     end
    //     end
    // endtask

    //
    // User define variable && constraint
    //
    // rand bit [15:0] start_addr;
    // int unsigned transmit_del = 0;
    // constraint transmit_del_ct { (transmit_del <= 10); }
endclass : $(CLASSNAME)_base_vsequence
`endif