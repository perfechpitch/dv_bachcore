class branch_inst_sequence extends base_inst_sequence;
    branch_seq_config       branch_seq_cfg;
    branch_seq_type_item    branch_seq_type_info;
    loop_sequence           loop_seq;
    single_branch_sequence  single_branch_seq;
    jalr_sequence           jalr_seq;

    inst_generator          inst_gen;
    addr_space_generator    addr_space_gen;
    `uvm_object_utils_begin(branch_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "branch_inst_sequence");
      super.new(name);
      branch_seq_type_info = new();
      loop_seq = new();
      single_branch_seq = new();
      jalr_seq = new();
    endfunction : new

    virtual function inst_seq_info_item seq_gen();
        inst_seq_info_item  branch_seq_info;
        branch_seq_type_e   branch_seq_type;
        branch_seq_type_info.inst_seq_cfg = branch_seq_cfg;

        assert(branch_seq_type_info.randomize());
        branch_seq_type = branch_seq_type_info.branch_seq_type;
        case(branch_seq_type)
            SINGLE_BRANCH_SEQ   : begin
                branch_seq_info = single_branch_seq.sub_seq_gen(branch_seq_cfg, inst_gen);
            end
            LOOP_SEQ            : begin
                branch_seq_info = loop_seq.sub_seq_gen(branch_seq_cfg, inst_gen);
            end
            JALR_SEQ            :begin
                branch_seq_info = jalr_seq.sub_seq_gen(branch_seq_cfg, inst_gen, addr_space_gen, FETCH_VALID);
            end
        endcase
        //if($test$plusargs("debug_print"))begin
        //branch_seq_info.print();
        //end
        return branch_seq_info;
    endfunction

endclass 
