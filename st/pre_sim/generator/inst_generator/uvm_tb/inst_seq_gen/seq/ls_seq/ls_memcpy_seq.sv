/*
    memcpy structure: - copy N times from (LOAD VALID)addr to (LS VALID) addr.
    N = seq_length/2 
*/
class ls_memcpy_seq extends base_inst_sequence;
    `uvm_object_utils_begin(ls_memcpy_seq)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_memcpy_seq");
      super.new(name);
    endfunction : new
    virtual function void sub_seq_gen(ls_seq_info_item ls_seq_info,inst_generator inst_gen);
        bit [1:0]   cpy_size;
        int         cpy_times;
        bit [4:0]   src_base_reg;
        bit [4:0]   dst_base_reg;
        bit[4:0]    temp_reg;
        bit[11:0]   src_base_imm;
        bit[11:0]   dst_base_imm;
        addr_structure_s    src_base_s;
        addr_structure_s    dst_base_s;



        src_base_s.mode = ls_seq_info.inst_seq_cfg.ls_mode;
        src_base_s.addr_type = LOAD_VALID;
        dst_base_s.mode = ls_seq_info.inst_seq_cfg.ls_mode;
        dst_base_s.addr_type = LS_VALID;
        src_base_reg = inst_gen.reg_pool.get_ls_base_reg(src_base_s);
        dst_base_reg = inst_gen.reg_pool.get_ls_base_reg(dst_base_s);
        //$fwrite(inst_gen.gen_file,("//00 copy dst addr info: %0p\n"),dst_base_s);

        inst_gen.ops_gen_cfg.ls_addr_misalign = 0;
        inst_gen.ops_gen_cfg.ls_inst_unsigned = 0;
        inst_gen.ops_gen_cfg.align_bytes = 8;

        src_base_imm = inst_gen.ls_addr_gen.get_ls_imm(src_base_s, inst_gen.ops_gen_cfg);
        dst_base_imm = inst_gen.ls_addr_gen.get_ls_imm(dst_base_s, inst_gen.ops_gen_cfg);
        if(src_base_s.addr_type == AMO_VALID)begin
            src_base_imm[2:0] = 0;
        end
        if(dst_base_s.addr_type == AMO_VALID)begin
            dst_base_imm[2:0] = 0;
        end

 cpy_times = ls_seq_info.seq_length/2;
        $fwrite(inst_gen.gen_file,("// -------------- ls memcpy seq: copy %0d times\n"),cpy_times);
        $fwrite(inst_gen.gen_file,("// copy src addr info: %0p\n"),src_base_s);
        $fwrite(inst_gen.gen_file,("// copy dst addr info: %0p\n"),dst_base_s);
        for(int i=0; i<cpy_times;i++)begin
            cpy_size = $random;
            temp_reg = inst_gen.reg_pool.get_nonezero_gpr(1);    // not base, a valid gpr
            if(cpy_size == 0)begin
                `lb(temp_reg,src_base_imm + 1,src_base_reg);
                `sb(temp_reg,dst_base_imm + 1,dst_base_reg);
            end
            else if(cpy_size == 1)begin
                `lh(temp_reg,src_base_imm + 2,src_base_reg);
                `sh(temp_reg,dst_base_imm + 2,dst_base_reg);
            end
            else if(cpy_size == 2)begin
                `lh(temp_reg,src_base_imm + 4,src_base_reg);
                `sh(temp_reg,dst_base_imm + 4,dst_base_reg);
            end
            else if(cpy_size == 3)begin
                `lh(temp_reg,src_base_imm + 8,src_base_reg);
                `sh(temp_reg,dst_base_imm + 8,dst_base_reg);
            end
        end
    endfunction

/*
    memcpy structure: - copy N insts

    auipc : pc+ N*4*2 +4 //get old inst start addr
    for(int i=0; i<N; i++)begin
        read new inst;
        cover old inst;
    end
    fence.i

    memcpy_test:
    // old inst * N
//    rand inst * n
    // new inst * N
    rand inst * (n-1)
    
*/
 /*
    virtual function void sub_seq_gen(ls_seq_info_item ls_seq_info,inst_generator inst_gen);
        bit [4:0] temp0_reg;
        bit [4:0] temp1_reg;
        bit [11:0] cpy_addr_imm;
        bit [4:0] cpy_inst_num;
        temp0_reg = 0;
        temp1_reg = 0;
        cpy_inst_num = $random();
        temp0_reg = inst_gen.reg_pool.get_nonezero_gpr(1);    // not base, a valid gpr
        temp1_reg = inst_gen.reg_pool.get_nonezero_gpr(1);    // not base, a valid gpr
    //    $display("a=%0d,b=%0d",temp0_reg,temp1_reg);
        `asm_log_para(inst_gen.gen_file,"// memcpy ls seq start: cpy_inst_num = %0d\n",cpy_inst_num)

        cpy_addr_imm = cpy_inst_num *4*2 + 4;

        `auipc(temp0_reg,cpy_addr_imm);
        for(int i=0; i<cpy_inst_num; i++)begin
            `lw(temp1_reg,(i*4 ),temp0_reg);   
            `sw(temp1_reg,(i*4 ),temp0_reg);   
        end
        `fencei;
        for(int i=0; i<cpy_inst_num; i++)begin
        //    `sub(0,0,0);
        //old inst use rand inst
        gen_rand_inst(inst_gen,cpy_inst_num,ls_seq_info.ls_inst_dist,ls_seq_info.safe_inst_dist,ls_seq_info.flush_inst_dist,ls_seq_info.except_inst_dist,'d0,ls_seq_info.wfi_inst_dist);
        end
        //new inst
        gen_rand_inst(inst_gen,(cpy_inst_num-1),ls_seq_info.ls_inst_dist,ls_seq_info.safe_inst_dist,ls_seq_info.flush_inst_dist,ls_seq_info.except_inst_dist,'d0,ls_seq_info.wfi_inst_dist);
        `jal(temp0_reg,4);

        `asm_log(inst_gen.gen_file,"// memcpy ls seq end\n")
    endfunction
    */
endclass
