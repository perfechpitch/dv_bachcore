// ============================================================================
// Filename             : $(CLASSNAME)_base_sequence.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_BASE_SEQUENCE_SV
`define $(FILENAME)_BASE_SEQUENCE_SV
class $(CLASSNAME)_base_sequence extends uvm_sequence#($(CLASSNAME)_seq_item);
    `uvm_object_utils($(CLASSNAME)_base_sequence)
    //
    // Only the root sequence could get p_sequencer.
    //
    `uvm_declare_p_sequencer($(CLASSNAME)_sequencer)
    
    function new(string name = "$(CLASSNAME)_base_sequence");
        super.new(name);
    endfunction

    // Raise in pre_body so the objection is only raised for root sequences.
    // There is no need to raise for sub-sequences since the root sequence
    // will encapsulate the sub-sequence.
    //
    // For example:
    // virtual task pre_body();
    //     if(this.starting_phase != null) begin
    //         `uvm_info(get_type_name(),
    //             $sformatf("%s pre_body() raising %s objection",
    //                 get_sequence_path(),
    //                 starting_phase.get_name()), UVM_MEDIUM);
    //         starting_phase.raise_objection(this);
    //     end
    // endtask


    // Drop the objection in the post_body so the objection is removed when
    // the root sequence is complete. 
    //
    // For example:
    // virtual task post_body();
    //     if(this.starting_phase != null) begin
    //         `uvm_info(get_type_name(),
    //             $sformatf("%s post_body() dropping %s objection",
    //                 get_sequence_path(),
    //                 starting_phase.get_name()), UVM_MEDIUM);
    //         starting_phase.drop_objection(this);
    //     end
    // endtask
endclass : $(CLASSNAME)_base_sequence
`endif