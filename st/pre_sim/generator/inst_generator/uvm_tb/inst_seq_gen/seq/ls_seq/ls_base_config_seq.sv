class ls_base_config_sequence extends uvm_object;
    ls_base_info_item   ls_base_info;
    li_sequence         li_seq;
    `uvm_object_utils_begin(ls_base_config_sequence)
    `uvm_object_utils_end
    function new (string name = "ls_base_config_sequence");
      super.new(name);
      ls_base_info = new();
      li_seq = new();
    endfunction : new

    virtual function void seq_gen(ls_seq_config ls_seq_cfg,inst_generator   inst_gen,addr_space_generator addr_space_gen);
        ls_base_info.inst_seq_cfg = ls_seq_cfg;
        inst_gen.ls_addr_gen.share_layout = ls_seq_cfg.share_layout;
        inst_gen.ls_addr_gen.hart         = ls_seq_cfg.hart;
        inst_gen.ls_addr_gen.dtcm_base    = ls_seq_cfg.dtcm_base;
        inst_gen.ls_addr_gen.share_base   = ls_seq_cfg.share_base;
        assert(ls_base_info.randomize());
        get_base_reg(ls_seq_cfg,inst_gen);
    endfunction

    virtual function void get_base_reg(ls_seq_config ls_seq_cfg,inst_generator inst_gen);
        addr_structure_s    ls_s[$];
        ls_addr_s           ls_a[$];
        int unsigned        align;

        inst_gen.ls_addr_gen.reset_bases();
        for(int i=0; i<ls_base_info.base_num; i++)begin
            align = 'h8;
            ls_a[i] = inst_gen.ls_addr_gen.get_ls_addr(ls_base_info.base_addr_type[i], align, align);
            ls_s[i].addr_type = ls_base_info.base_addr_type[i];
            ls_s[i].mode      = ls_seq_cfg.ls_mode;
            ls_s[i].vaddr     = ls_a[i].base_val;
            ls_s[i].paddr     = ls_a[i].base_val[39:0];
        end

        ls_base_info.base_num = inst_gen.reg_pool.base_reg_get(ls_base_info.base_num,ls_s);
        for(int i=0; i<ls_base_info.base_num; i++)
            inst_gen.ls_addr_gen.bind_base(ls_a[i]);
        $fwrite(inst_gen.gen_file,("//--- get %0d ls base reg   :\n"),ls_base_info.base_num);
        for(int i=0; i<ls_base_info.base_num;i++)begin
            $fwrite(inst_gen.gen_file,("//[gpr : x%0d]\tls base ea=%0h base_val=%0h imm=%0h mem=%0s win=[%0h,%0h)\n"),
                    inst_gen.reg_pool.base_regs[i], ls_a[i].ea, ls_a[i].base_val, ls_a[i].imm,
                    ls_a[i].mem_type.name(), ls_a[i].win_lo, ls_a[i].win_hi);
        end

        gen_ls_base_cfg_seq(inst_gen, ls_a);
    endfunction

    // 写 base_val 到 GPR：保留原来的 gen_type，不再 ld link 表
    function void gen_ls_base_cfg_seq(inst_generator inst_gen, ls_addr_s ls_a[$]);
        bit [4:0] base_num;
        bit [4:0] base_reg;
        bit [4:0] temp_reg;
        bit [3:0] insert_num[$];
        base_gen_type_e gen_type[$];
        bit[63:0] val;

        base_num   = ls_base_info.base_num;
        gen_type   = ls_base_info.gen_type;
        insert_num = ls_base_info.insert_num;

        for(int i=0; i<base_num; i++)begin
            base_reg = inst_gen.reg_pool.base_regs[i];
            val      = ls_a[i].base_val;
            $fwrite(inst_gen.gen_file,("//--- write ls base x%0d = %0h (%0s)\n"),
                    base_reg, val, gen_type[i].name());
            case(gen_type[i])
                LOAD_BASE:begin
                    inst_gen.insert_inst(insert_num[i],SAFE_INST);
                    li_seq.seq_gen(inst_gen, val, base_reg);
                end
                ALU_LOAD_BASE:begin
                    li_seq.seq_gen(inst_gen, val, base_reg);
                    inst_gen.insert_inst(insert_num[i],SAFE_INST);
                end
                ALU_DIV_LOAD_BASE:begin
                    li_seq.seq_gen(inst_gen, val, base_reg);
                    if(val != 'h0)begin
                        temp_reg = inst_gen.reg_pool.get_nonezero_gpr(1);
                        `div(temp_reg,base_reg,base_reg);
                        `mul(base_reg,base_reg,temp_reg);
                    end
                    inst_gen.insert_inst(insert_num[i],SAFE_INST);
                end
                MDU_LOAD_BASE:begin
                    li_seq.seq_gen(inst_gen, val, base_reg);
                    if(val != 'h0)begin
                        temp_reg = inst_gen.reg_pool.get_nonezero_gpr(1);
                        `div(temp_reg,base_reg,base_reg);
                        `mul(base_reg,base_reg,temp_reg);
                    end
                    inst_gen.insert_inst(insert_num[i],SAFE_INST);
                end
            endcase
        end
    endfunction
endclass
