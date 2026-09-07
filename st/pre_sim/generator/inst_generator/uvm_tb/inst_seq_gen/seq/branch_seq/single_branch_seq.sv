/*
    single branch structure:
    branch inst
    ... other insts
*/
class single_branch_sequence extends base_inst_sequence;
    branch_seq_info_item  branch_seq_info;
    `uvm_object_utils_begin(single_branch_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "single_branch_sequence");
      super.new(name);
      branch_seq_info = new();
    endfunction : new

    virtual function inst_seq_info_item sub_seq_gen(branch_seq_config   branch_seq_cfg,inst_generator inst_gen);
        bit [63:0] branch_target_pc;
        bit [31:0] branch_delta;

        branch_seq_info.inst_seq_cfg = branch_seq_cfg;
        branch_seq_info.branch_seq_type = SINGLE_BRANCH_SEQ;
        assert(branch_seq_info.randomize()with{
            branch_forward == 1'b0;
        });
        $fwrite(inst_gen.gen_file,("//--- single branch seq start   : \n"));
        // Generate the target block first, then place a backward branch whose
        // immediate is the measured byte distance.  This works for 16/32-bit
        // mixed instruction streams without output fixups.
        branch_target_pc = inst_gen.inst_addr;
        gen_rand_inst(inst_gen,branch_seq_info.target_inst_num,branch_seq_info.ls_inst_dist,branch_seq_info.safe_inst_dist,branch_seq_info.flush_inst_dist,branch_seq_info.except_inst_dist,'d0,branch_seq_info.wfi_inst_dist);
        branch_delta = branch_target_pc - inst_gen.inst_addr;
        inst_gen.branch_imm = branch_delta;
        inst_gen.branch_inst_gen.branch_is_jump = branch_seq_info.branch_is_jump;
        inst_gen.branch_inst_gen.branch_delta   = branch_delta;
        inst_gen.get_rand_inst(BRANCH_INST);
        $fwrite(inst_gen.gen_file,("//--- single branch seq end   : \n"));
        return branch_seq_info;
    endfunction
endclass 
