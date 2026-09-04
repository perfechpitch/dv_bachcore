class asm_gen_vsequence extends uvm_sequence;
    base_asm_sequence   base_asm_seq;
    `uvm_object_utils(asm_gen_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "asm_gen_vsequence");
        super.new(name);
    endfunction 
    virtual task body();
        base_asm_seq = new();
        base_asm_seq.seq_gen(p_sequencer.inst_gen);
    endtask

endclass : asm_gen_vsequence