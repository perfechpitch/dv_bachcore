`ifndef VU_VSEQUENCE_SV
`define VU_VSEQUENCE_SV
class vu_vsequence extends vu_base_vsequence;

    `uvm_object_utils(vu_vsequence)

    function new(string name = "vu_vsequence");
        super.new(name);
    endfunction

    virtual task body();
        fork
            begin
                `uvm_do_on(inst_gen_seq, p_sequencer.inst_gen_sqr)
            end
            begin
                `uvm_do_on(reset_seq, p_sequencer.reset_sqr)
            end
        join_any
    endtask
endclass : vu_vsequence
`endif
