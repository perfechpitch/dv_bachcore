class c_inst_sequence extends base_inst_sequence;
    safe_seq_config     c_seq_cfg;
    inst_seq_info_item  inst_seq_info;
    inst_generator      inst_gen;
    inst_e              c_inst_set[$];

    `uvm_object_utils(c_inst_sequence)

    function new(string name = "c_inst_sequence");
        super.new(name);
        inst_seq_info = new();
        c_inst_set = '{
            C_ADDI4SPN, C_LW, C_SW,
            C_NOP, C_ADDI, C_LI, C_ADDI16SP, C_LUI,
            C_SRLI, C_SRAI, C_ANDI, C_SUB, C_XOR, C_OR, C_AND,
            C_SLLI, C_LWSP, C_MV, C_ADD, C_SWSP
        };
    endfunction : new

    virtual function inst_seq_info_item seq_gen();
        int          seq_length;
        int unsigned generated_num;
        inst_e       inst_name;

        if(!(RVC inside inst_gen.inst_gen_cfg.support_inst_set))
            `uvm_fatal("C_INST_SEQ", "RVC is not enabled in support_inst_set")

        inst_seq_info.inst_seq_cfg = c_seq_cfg;
        if(!inst_seq_info.randomize())
            `uvm_fatal("C_INST_SEQ", "inst_seq_info randomize failed")
        seq_length = inst_seq_info.seq_length;

        $fwrite(inst_gen.gen_file,
                "// -------------- C INST SEQ with %0d compressed insts\n",
                seq_length);
        generated_num = 0;
        for(int i = 0; i < seq_length; i++) begin
            if(!inst_gen.fetch_space_avail())
                break;
            inst_name = c_inst_set[$urandom_range(c_inst_set.size()-1)];
            inst_gen.get_specified_rand_inst(inst_name);
            generated_num++;
        end
        $fwrite(inst_gen.gen_file,
                "// -------------- C INST SEQ end generated=%0d\n",
                generated_num);
        return inst_seq_info;
    endfunction
endclass
