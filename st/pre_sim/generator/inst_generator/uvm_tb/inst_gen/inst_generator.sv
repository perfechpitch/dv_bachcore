class inst_generator extends uvm_component;

    bit[31:0]        inst;
    bit [31:0] branch_imm;
    int gen_file;
    int vmem_file;
    bit[31:0]           mem_file[bit[39:0]];//TODO:if RV48 TODO


    inst_gen_config inst_gen_cfg;
    base_inst       inst_gen_queue[$];
//    inst_name_generator     inst_name_gen;
    safe_inst_generator     safe_inst_gen;
    flush_inst_generator    flush_inst_gen;
    except_inst_generator   except_inst_gen;
    branch_inst_generator   branch_inst_gen;
    ls_inst_generator       ls_inst_gen;


    ops_gen_config         ops_gen_cfg;

    register_pool       reg_pool;
    addr_space_generator    addr_space_gen;
    ls_addr_generator       ls_addr_gen;
    bit[63:0]           task_start_pc;
    bit[63:0]           inst_pc_history[$];
    int unsigned         task_inst_history_start;
    bit                  core_stream_initialized;

    ri_inst_generator   ri_inst_gen;
    int queue_size;

    int       inst_cnt;
    bit[63:0] inst_addr;
    bit[39:0] inst_paddr;

 `INST_GEN_DECLARATION(c_addi4spn_gen)
 `INST_GEN_DECLARATION(c_lw_gen)
 `INST_GEN_DECLARATION(c_sw_gen)
 `INST_GEN_DECLARATION(c_nop_gen)
 `INST_GEN_DECLARATION(c_addi_gen)
 `INST_GEN_DECLARATION(c_jal_gen)
 `INST_GEN_DECLARATION(c_li_gen)
 `INST_GEN_DECLARATION(c_addi16sp_gen)
 `INST_GEN_DECLARATION(c_lui_gen)
 `INST_GEN_DECLARATION(c_srli_gen)
 `INST_GEN_DECLARATION(c_srai_gen)
 `INST_GEN_DECLARATION(c_andi_gen)
 `INST_GEN_DECLARATION(c_sub_gen)
 `INST_GEN_DECLARATION(c_xor_gen)
 `INST_GEN_DECLARATION(c_or_gen)
 `INST_GEN_DECLARATION(c_and_gen)
 `INST_GEN_DECLARATION(c_j_gen)
 `INST_GEN_DECLARATION(c_beqz_gen)
 `INST_GEN_DECLARATION(c_bnez_gen)
 `INST_GEN_DECLARATION(c_slli_gen)
 `INST_GEN_DECLARATION(c_lwsp_gen)
 `INST_GEN_DECLARATION(c_jr_gen)
 `INST_GEN_DECLARATION(c_mv_gen)
 `INST_GEN_DECLARATION(c_ebreak_gen)
 `INST_GEN_DECLARATION(c_jalr_gen)
 `INST_GEN_DECLARATION(c_add_gen)
 `INST_GEN_DECLARATION(c_swsp_gen)
 `INST_GEN_DECLARATION(dsar_gen)
 `INST_GEN_DECLARATION(dsari_gen)
 `INST_GEN_DECLARATION(dsaw_gen)
 `INST_GEN_DECLARATION(dsawi_gen)
 `INST_GEN_DECLARATION(task_done_gen)
 `INST_GEN_DECLARATION(loop_gen)
 `INST_GEN_DECLARATION(addi_gen)
    `INST_GEN_DECLARATION(slti_gen)
    `INST_GEN_DECLARATION(sltiu_gen)
    `INST_GEN_DECLARATION(xori_gen)
    //notice: pref insts decode type is similar to ori,
    //push pref insts before ori, can make sure when 
    //inst decode to be pref, will not go for ori.
    `INST_GEN_DECLARATION(invalid_pref_i_gen)
    `INST_GEN_DECLARATION(invalid_pref_r_gen)
    `INST_GEN_DECLARATION(invalid_pref_w_gen)
    `INST_GEN_DECLARATION(pref_i_gen)
    `INST_GEN_DECLARATION(pref_r_gen)
    `INST_GEN_DECLARATION(pref_w_gen)
    `INST_GEN_DECLARATION(ori_gen)
    `INST_GEN_DECLARATION(andi_gen)
    `INST_GEN_DECLARATION(slli_gen)
    `INST_GEN_DECLARATION(srli_gen)
    `INST_GEN_DECLARATION(srai_gen)
    `INST_GEN_DECLARATION(add_gen)
    `INST_GEN_DECLARATION(sub_gen)
    `INST_GEN_DECLARATION(sll_gen)
    `INST_GEN_DECLARATION(slt_gen)
    `INST_GEN_DECLARATION(sltu_gen)
    `INST_GEN_DECLARATION(xor_gen)
    `INST_GEN_DECLARATION(srl_gen)
    `INST_GEN_DECLARATION(sra_gen)
    `INST_GEN_DECLARATION(or_gen)
    `INST_GEN_DECLARATION(and_gen)
    `INST_GEN_DECLARATION(addiw_gen)
    `INST_GEN_DECLARATION(slliw_gen)
    `INST_GEN_DECLARATION(srliw_gen)
    `INST_GEN_DECLARATION(sraiw_gen)
    `INST_GEN_DECLARATION(addw_gen)
    `INST_GEN_DECLARATION(subw_gen)
    `INST_GEN_DECLARATION(sllw_gen)
`INST_GEN_DECLARATION(srlw_gen)
    `INST_GEN_DECLARATION(sraw_gen)
    `INST_GEN_DECLARATION(lui_gen)
    `INST_GEN_DECLARATION(auipc_gen)

    `INST_GEN_DECLARATION(mul_gen)
    `INST_GEN_DECLARATION(mulw_gen)
    `INST_GEN_DECLARATION(mulh_gen)
    `INST_GEN_DECLARATION(mulhsu_gen)
    `INST_GEN_DECLARATION(mulhu_gen)
    `INST_GEN_DECLARATION(div_gen)
    `INST_GEN_DECLARATION(divu_gen)
    `INST_GEN_DECLARATION(rem_gen)
    `INST_GEN_DECLARATION(remu_gen)
    `INST_GEN_DECLARATION(divw_gen)
    `INST_GEN_DECLARATION(divuw_gen)
    `INST_GEN_DECLARATION(remw_gen)
    `INST_GEN_DECLARATION(remuw_gen)

    `INST_GEN_DECLARATION(jal_gen)
    `INST_GEN_DECLARATION(jalr_gen)
    `INST_GEN_DECLARATION(beq_gen)
    `INST_GEN_DECLARATION(bne_gen)
    `INST_GEN_DECLARATION(bge_gen)
    `INST_GEN_DECLARATION(blt_gen)
    `INST_GEN_DECLARATION(bgeu_gen)
    `INST_GEN_DECLARATION(bltu_gen)

 `INST_GEN_DECLARATION(csrrc_gen)
    `INST_GEN_DECLARATION(csrrci_gen)
    `INST_GEN_DECLARATION(csrrs_gen)
    `INST_GEN_DECLARATION(csrrsi_gen)
    `INST_GEN_DECLARATION(csrrw_gen)
    `INST_GEN_DECLARATION(csrrwi_gen)

    `INST_GEN_DECLARATION(ebreak_gen)
    `INST_GEN_DECLARATION(ecall_gen)
    `INST_GEN_DECLARATION(mret_gen)
    `INST_GEN_DECLARATION(sret_gen)

    `INST_GEN_DECLARATION(lb_gen)
    `INST_GEN_DECLARATION(lh_gen)
    `INST_GEN_DECLARATION(lw_gen)
    `INST_GEN_DECLARATION(ld_gen)
    `INST_GEN_DECLARATION(lbu_gen)
    `INST_GEN_DECLARATION(lhu_gen)
    `INST_GEN_DECLARATION(lwu_gen)
    `INST_GEN_DECLARATION(sb_gen)
    `INST_GEN_DECLARATION(sh_gen)
    `INST_GEN_DECLARATION(sw_gen)
    `INST_GEN_DECLARATION(sd_gen)

    `INST_GEN_DECLARATION(invalid_amoswap_w_gen)
    `INST_GEN_DECLARATION(invalid_amoadd_w_gen)
    `INST_GEN_DECLARATION(invalid_amoxor_w_gen)
    `INST_GEN_DECLARATION(invalid_amoor_w_gen)
    `INST_GEN_DECLARATION(invalid_amoand_w_gen)
    `INST_GEN_DECLARATION(invalid_amomin_w_gen)
    `INST_GEN_DECLARATION(invalid_amomax_w_gen)
    `INST_GEN_DECLARATION(invalid_amominu_w_gen)
    `INST_GEN_DECLARATION(invalid_amomaxu_w_gen)
    `INST_GEN_DECLARATION(invalid_amoswap_d_gen)
    `INST_GEN_DECLARATION(invalid_amoadd_d_gen)
    `INST_GEN_DECLARATION(invalid_amoxor_d_gen)
    `INST_GEN_DECLARATION(invalid_amoor_d_gen)
    `INST_GEN_DECLARATION(invalid_amoand_d_gen)
    `INST_GEN_DECLARATION(invalid_amomin_d_gen)
    `INST_GEN_DECLARATION(invalid_amomax_d_gen)
    `INST_GEN_DECLARATION(invalid_amominu_d_gen)
    `INST_GEN_DECLARATION(invalid_amomaxu_d_gen)
    `INST_GEN_DECLARATION(amoswap_w_gen)
    `INST_GEN_DECLARATION(amoadd_w_gen)
    `INST_GEN_DECLARATION(amoxor_w_gen)
    `INST_GEN_DECLARATION(amoor_w_gen)
    `INST_GEN_DECLARATION(amoand_w_gen)
    `INST_GEN_DECLARATION(amomin_w_gen)
    `INST_GEN_DECLARATION(amomax_w_gen)
    `INST_GEN_DECLARATION(amominu_w_gen)
    `INST_GEN_DECLARATION(amomaxu_w_gen)
    `INST_GEN_DECLARATION(amoswap_d_gen)
    `INST_GEN_DECLARATION(amoadd_d_gen)
    `INST_GEN_DECLARATION(amoxor_d_gen)
    `INST_GEN_DECLARATION(amoor_d_gen)
    `INST_GEN_DECLARATION(amoand_d_gen)
`INST_GEN_DECLARATION(amomin_d_gen)
    `INST_GEN_DECLARATION(amomax_d_gen)
    `INST_GEN_DECLARATION(amominu_d_gen)
    `INST_GEN_DECLARATION(amomaxu_d_gen)
    `INST_GEN_DECLARATION(fence_gen)
    `INST_GEN_DECLARATION(fencei_gen)
    `INST_GEN_DECLARATION(invalid_lb_gen)
    `INST_GEN_DECLARATION(invalid_lh_gen)
    `INST_GEN_DECLARATION(invalid_lw_gen)
    `INST_GEN_DECLARATION(invalid_ld_gen)
    `INST_GEN_DECLARATION(invalid_lbu_gen)
    `INST_GEN_DECLARATION(invalid_lhu_gen)
    `INST_GEN_DECLARATION(invalid_lwu_gen)
    `INST_GEN_DECLARATION(invalid_fld_gen)
    `INST_GEN_DECLARATION(invalid_flw_gen)

    `INST_GEN_DECLARATION(misalign_jal_gen)
    `INST_GEN_DECLARATION(misalign_beq_gen)
    `INST_GEN_DECLARATION(misalign_bne_gen)
    `INST_GEN_DECLARATION(misalign_bge_gen)
    `INST_GEN_DECLARATION(misalign_blt_gen)
    `INST_GEN_DECLARATION(misalign_bgeu_gen)
    `INST_GEN_DECLARATION(misalign_bltu_gen)

    `INST_GEN_DECLARATION(invalid_sb_gen)
    `INST_GEN_DECLARATION(invalid_sh_gen)
    `INST_GEN_DECLARATION(invalid_sw_gen)
    `INST_GEN_DECLARATION(invalid_sd_gen)
    `INST_GEN_DECLARATION(invalid_fsd_gen)
    `INST_GEN_DECLARATION(invalid_fsw_gen)


 `INST_GEN_DECLARATION(fmadd_d_gen)
    `INST_GEN_DECLARATION(fmadd_s_gen)
    `INST_GEN_DECLARATION(fmsub_d_gen)
    `INST_GEN_DECLARATION(fmsub_s_gen)
    `INST_GEN_DECLARATION(fnmadd_d_gen)
    `INST_GEN_DECLARATION(fnmadd_s_gen)
    `INST_GEN_DECLARATION(fnmsub_d_gen)
    `INST_GEN_DECLARATION(fnmsub_s_gen)
    `INST_GEN_DECLARATION(fadd_d_gen)
    `INST_GEN_DECLARATION(fadd_s_gen)
    `INST_GEN_DECLARATION(fsub_d_gen)
    `INST_GEN_DECLARATION(fsub_s_gen)
    `INST_GEN_DECLARATION(fmul_d_gen)
    `INST_GEN_DECLARATION(fmul_s_gen)
    `INST_GEN_DECLARATION(feq_d_gen)
    `INST_GEN_DECLARATION(feq_s_gen)
    `INST_GEN_DECLARATION(flt_d_gen)
    `INST_GEN_DECLARATION(flt_s_gen)
    `INST_GEN_DECLARATION(fle_d_gen)
    `INST_GEN_DECLARATION(fle_s_gen)
    `INST_GEN_DECLARATION(fsgnj_d_gen)
    `INST_GEN_DECLARATION(fsgnj_s_gen)
    `INST_GEN_DECLARATION(fsgnjn_d_gen)
    `INST_GEN_DECLARATION(fsgnjn_s_gen)
    `INST_GEN_DECLARATION(fsgnjx_d_gen)
    `INST_GEN_DECLARATION(fsgnjx_s_gen)
    `INST_GEN_DECLARATION(fcvt_w_s_gen)
    `INST_GEN_DECLARATION(fcvt_wu_s_gen)
    `INST_GEN_DECLARATION(fcvt_s_w_gen)
    `INST_GEN_DECLARATION(fcvt_s_l_gen)
    `INST_GEN_DECLARATION(fcvt_l_s_gen)
    `INST_GEN_DECLARATION(fcvt_lu_s_gen)
    `INST_GEN_DECLARATION(fcvt_s_lu_gen)
    `INST_GEN_DECLARATION(fcvt_s_wu_gen)
    `INST_GEN_DECLARATION(fcvt_s_d_gen)
    `INST_GEN_DECLARATION(fcvt_d_s_gen)
    `INST_GEN_DECLARATION(fcvt_w_d_gen)
    `INST_GEN_DECLARATION(fcvt_d_w_gen)
    `INST_GEN_DECLARATION(fcvt_l_d_gen)
    `INST_GEN_DECLARATION(fcvt_d_l_gen)
    `INST_GEN_DECLARATION(fcvt_wu_d_gen)
    `INST_GEN_DECLARATION(fcvt_d_wu_gen)
    `INST_GEN_DECLARATION(fcvt_lu_d_gen)
    `INST_GEN_DECLARATION(fcvt_d_lu_gen)
    `INST_GEN_DECLARATION(fclass_d_gen)
    `INST_GEN_DECLARATION(fclass_s_gen)
  `INST_GEN_DECLARATION(fmv_x_w_gen)
    `INST_GEN_DECLARATION(fmv_w_x_gen)
    `INST_GEN_DECLARATION(fmv_x_d_gen)
    `INST_GEN_DECLARATION(fmv_d_x_gen)
    `INST_GEN_DECLARATION(fsqrt_d_gen)
    `INST_GEN_DECLARATION(fsqrt_s_gen)
    `INST_GEN_DECLARATION(fmax_d_gen)
    `INST_GEN_DECLARATION(fmax_s_gen)
    `INST_GEN_DECLARATION(fmin_d_gen)
    `INST_GEN_DECLARATION(fmin_s_gen)
    `INST_GEN_DECLARATION(fdiv_d_gen)
    `INST_GEN_DECLARATION(fdiv_s_gen)
    `INST_GEN_DECLARATION(flw_gen)
    `INST_GEN_DECLARATION(fld_gen)
    `INST_GEN_DECLARATION(fsw_gen)
    `INST_GEN_DECLARATION(fsd_gen)


    `uvm_component_utils_begin(inst_generator)
    `uvm_component_utils_end

    // new - constructor
    function new (string name = "inst_generator",uvm_component parent);
      super.new(name,parent);
      //seed=$random();
      //gen_file = $fopen(($psprintf("./%0dinst_gen.dat",seed)),"w");
      //TODO:how to get current seed
      //gen_file = $fopen(($psprintf("./inst_gen.dat")),"w");
    //  inst_name_gen = new();
       //vmem_file = $fopen(($psprintf("./test.vmem")),"w");
  safe_inst_gen   = new();
        flush_inst_gen  = new();
        except_inst_gen = new();
        branch_inst_gen = new();
        ls_inst_gen     = new();
        ops_gen_cfg = new();

        ri_inst_gen = new();
        ls_addr_gen = new();

        inst_cnt = 0;
        core_stream_initialized = 1'b0;
    endfunction : new

    task pre_main_phase(uvm_phase phase);
        gen_file  = inst_gen_cfg.gen_file;
        vmem_file = inst_gen_cfg.vmem_file;
        inst_queue_gen();
    endtask

    // Fetch PC is independent of addr_space_gen.
    // task0 starts at 'h0; later tasks continue from the current inst_addr.
    //------------------------------------------------------------------
    // fetch_space_avail
    //   判断 ITCM 线性区还能不能再铺指令。
    //   - inst_addr 在 ['h0, `ITCM_SIZE) 内：至少还要留下当前指令 + pass_quit
    //     （各 'h4 字节，合计 'h8）。不够则返回 0。
    //   - inst_addr == `ITCM_SIZE：已经铺满，返回 0。
    //   - inst_addr >  `ITCM_SIZE：BOOT/异常入口，不按 4KB 截断，返回 1。
    //------------------------------------------------------------------
    function bit fetch_space_avail();
        if(inst_addr > `ITCM_SIZE) return 1'b1;
        return (inst_addr + 'h8 <= `ITCM_SIZE);
    endfunction

    function bit fetch_space_avail_for(int unsigned inst_bytes);
        if(inst_addr > `ITCM_SIZE) return 1'b1;
        return (inst_addr + inst_bytes + 'h4 <= `ITCM_SIZE);
    endfunction

    // test.vmem stores 32-bit words at word addresses.  RVC instructions are
    // halfword-addressed, so update the corresponding halfword then emit the
    // complete word.  Re-emitting a word is intentional when its other
    // halfword is generated later; the memory loader keeps the last value.
    function void vmem_write_word(bit [39:0] byte_addr);
        bit [39:0] word_idx;
        word_idx = byte_addr >> 2;
        if(!mem_file.exists(word_idx))
            mem_file[word_idx] = '0;
        if(inst_gen_cfg.vmem_file_gen)
            $fwrite(inst_gen_cfg.vmem_file, "@%0h\n%8h\n",
                    word_idx, mem_file[word_idx]);
    endfunction

    function void vmem_write_halfword(bit [39:0] byte_addr, bit [15:0] data);
        bit [39:0] word_idx;
        word_idx = byte_addr >> 2;
        if(!mem_file.exists(word_idx))
            mem_file[word_idx] = '0;
        if(byte_addr[1])
            mem_file[word_idx][31:16] = data;
        else
            mem_file[word_idx][15:0] = data;
    endfunction

    function void vmem_write_inst(bit [31:0] data, int unsigned inst_bytes);
        bit [39:0] first_word_idx;
        bit [39:0] second_word_idx;
        first_word_idx  = inst_paddr >> 2;
        second_word_idx = (inst_paddr + 2) >> 2;

        vmem_write_halfword(inst_paddr, data[15:0]);
        if(inst_bytes == 4)
            vmem_write_halfword(inst_paddr + 2, data[31:16]);

        vmem_write_word(inst_paddr);
        if((inst_bytes == 4) && (second_word_idx != first_word_idx))
            vmem_write_word(inst_paddr + 2);
    endfunction

    //------------------------------------------------------------------
    // truncate_fetch_space
    //   ITCM 写不下「当前指令 + quit」时调用：丢掉当前指令，在当前位置
    //   写入 pass_quit（add x0,x0,x0），PC += 'h4。
    //   再进来时 inst_addr 已到 `ITCM_SIZE，直接 return，避免重复写。
    //------------------------------------------------------------------
    function void truncate_fetch_space();
        if(inst_addr >= `ITCM_SIZE) return;
        $fwrite(inst_gen_cfg.gen_file,
                ("/*PC: %16h -> %10h*/ // Warning --- ITCM 4KB full, truncate with pass_quit\n"),
                inst_addr, inst_paddr);
        vmem_write_inst(pass_quit_inst, 4);
        inst_addr  = inst_addr + 'h4;
        inst_paddr = inst_paddr + 'h4;
        inst_cnt   = 'h0;
    endfunction

    function void begin_core_stream(int new_gen_file,
                                    int new_vmem_file,
                                    tcm_hart_e core);
        gen_file                = new_gen_file;
        vmem_file               = new_vmem_file;
        inst_gen_cfg.gen_file   = new_gen_file;
        inst_gen_cfg.vmem_file  = new_vmem_file;
        ri_inst_gen.gen_file    = new_gen_file;
        mem_file.delete();
        inst_pc_history.delete();
        task_start_pc           = '0;
        task_inst_history_start = 0;
        inst_addr               = '0;
        inst_paddr              = '0;
        inst_cnt                = `ITCM_SIZE / 'h4;
        core_stream_initialized = 1'b1;
        ls_addr_gen.hart        = core;
    endfunction

    function void switch_task(int       task_id,
                              bit       use_configured_start_pc = 1'b0,
                              bit[63:0] configured_start_pc     = '0);
        if(gen_file == 0)begin
            gen_file  = inst_gen_cfg.gen_file;
            vmem_file = inst_gen_cfg.vmem_file;
        end
        if(!core_stream_initialized) begin
            inst_addr               = '0;
            inst_paddr              = '0;
            inst_cnt                = `ITCM_SIZE / 'h4;
            core_stream_initialized = 1'b1;
        end
        if(use_configured_start_pc) begin
            inst_addr  = configured_start_pc;
            inst_paddr = configured_start_pc[39:0];
        end
        task_start_pc = inst_addr;
        task_inst_history_start = inst_pc_history.size();
        // Mark every task boundary in vmem using word address (start_pc / 4).
        $fwrite(vmem_file,("@%0h\n"), inst_paddr >> 'h2);
        $fwrite(gen_file,("//========== TASK[%0d] start PC=%16h itcm_left=%0hB ==========\n"),
                task_id, task_start_pc,
                (inst_addr < `ITCM_SIZE) ? (`ITCM_SIZE - inst_addr) : 'h0);
    endfunction
    // Choose only a real instruction boundary.  Mixed 16/32-bit streams
    // cannot derive a valid PC from instruction_count * 4.
    function bit[63:0] rand_pc_in_current_task();
        int unsigned index;
        if(inst_pc_history.size() <= task_inst_history_start)
            return task_start_pc;
        index = $urandom_range(inst_pc_history.size() - 1,
                               task_inst_history_start);
        return inst_pc_history[index];
    endfunction
    function void get_specified_rand_inst(inst_e inst_name);
        bit find_inst;
        inst_addr_print();
        for(int i=0; i<queue_size; i++)begin
            if(inst_gen_queue[i].inst_match(inst_name))begin
                inst = inst_gen_queue[i].get_rand_inst(ops_gen_cfg);
                find_inst = 1'b1;
                break;
            end
        end

        if(find_inst==1'b0)begin
            ////TODO: get ri inst, but when generators done, there is no find_inst=0
            $display("ERROR: rand inst=%0s, isn't in inst gen queue!!",inst_name);
        end
        inst_print();
    endfunction
 function void get_rand_branch_inst(bit[31:0] ops);
        inst_e inst_name;
        inst_addr_print();
        `RANDOMIZE_CHECK(branch_inst_gen,"ERROR: branch inst gen error!!")
        inst_name = branch_inst_gen.inst_name;
        for(int i=0; i<queue_size; i++)begin
            if(inst_gen_queue[i].inst_match(inst_name))begin
                inst = inst_gen_queue[i].get_specified_inst(ops);
            end
        end
        inst_print();
    endfunction
    function void get_rand_ls_with_imm(ref bit[31:0] ls_imm );
        inst_e inst_name;
        inst_addr_print();
        `RANDOMIZE_CHECK(ls_inst_gen,"ERROR: ls inst gen error!!")
        inst_name = ls_inst_gen.inst_name;
        for(int i=0; i<queue_size; i++)begin
            if(inst_gen_queue[i].inst_match(inst_name))begin
                inst = inst_gen_queue[i].override_rand_inst(ops_gen_cfg,ls_imm);
                break;
            end
        end
        //$display("inst_name = %0s, inst=%0h, ls_imm = %0h", inst_name, inst,ls_imm);
        inst_print();
    endfunction
 function void get_rand_inst(inst_type_e inst_type);
        bit find_inst;
        inst_e inst_name;
        inst_addr_print();

        find_inst = 1'b0;
        //inst_name = inst_name_gen.get_rand_inst_name(inst_type);
        case(inst_type)
            SAFE_INST  :begin
                `RANDOMIZE_CHECK(safe_inst_gen,"ERROR: safe inst gen error!!")
                inst_name = safe_inst_gen.inst_name;
            end
            FLUSH_INST :begin
                `RANDOMIZE_CHECK(flush_inst_gen,"ERROR: flush inst gen error!!")
                inst_name = flush_inst_gen.inst_name;
            end
            LS_INST    :begin
                `RANDOMIZE_CHECK(ls_inst_gen,"ERROR: ls inst gen error!!")
                inst_name = ls_inst_gen.inst_name;
            end
            BRANCH_INST:begin
                `RANDOMIZE_CHECK(branch_inst_gen,"ERROR: branch inst gen error!!")
                inst_name = branch_inst_gen.inst_name;
            end
            EXCEPT_INST:begin
                `RANDOMIZE_CHECK(except_inst_gen,"ERROR: except inst gen error!!")
                inst_name = except_inst_gen.inst_name;
                //$display("except_inst_type = %0s,inst_addr = %0h, inst_name = %0s",except_inst_gen.except_inst_type,inst_addr,inst_name);
            end
        endcase

  case(inst_type)
            BRANCH_INST:begin
                for(int i=0; i<queue_size; i++)begin
                    if(inst_gen_queue[i].inst_match(inst_name))begin
                        inst = inst_gen_queue[i].override_rand_inst(ops_gen_cfg,branch_imm);
                        find_inst = 1'b1;
                        break;
                    end
                end
            end
            default:begin
                if(inst_type == EXCEPT_INST && inst_name == RI) begin
                    inst = ri_inst_gen.get_rand_inst();
                    find_inst = 1'b1;
                end
                else begin
                for(int i=0; i<queue_size; i++)begin
                    if(inst_gen_queue[i].inst_match(inst_name))begin
                        inst = inst_gen_queue[i].get_rand_inst(ops_gen_cfg);
                        find_inst = 1'b1;
                        break;
                    end
                end
                end
            end
        endcase
        //$display("inst_type = %0s,inst=%h,inst_name=%0s, gpr size = %0d",inst_type,inst,inst_name,safe_inst_gen.safe_int_ls_dist,reg_pool.gpr_gen.regs.size());
        inst_print();
 //in one instruction,reg num constraint with {rs1_eq_rs2,rs1_eq_rd,rs2_rq_rd}
        //to make it correct. after every reg used. the rand reg be disabled stated.
        //after instruction gen. all reg generator free disbaled reg
        //reg_pool.free_reg();

        //$display("inst_name=%0s, inst_type = %0s, inst = %0h",inst_name,safe_inst_gen.safe_inst_type,inst);
        if(find_inst==1'b0)begin
            $display("ERROR: rand inst=%0s, isn't in inst gen queue!!",inst_name);
        end
    endfunction
 function void get_specified_inst(inst_e inst_name, bit[4:0]rs1,bit[4:0]rs2,bit[4:0]rd,bit[31:0]imm);
        bit find_inst;
        bit [31:0] ops;

        inst_addr_print();
        find_inst = 1'b0;
        ops = 0;
        for(int i=0; i<queue_size; i++)begin
            if(inst_gen_queue[i].inst_match(inst_name))begin
            case(inst_gen_queue[i].inst_format)
                R_TYPE  : ops = {7'b0,rs2,rs1, 3'b0,rd,7'b0};
                I_TYPE  :begin
                    ops = {imm[11:0],rs1, 3'b0,rd,7'b0};
                    //$display("inst_name = %s, imm = %h, rd=%0h", inst_name,imm,rd);
                end
                S_TYPE  : ops = {imm[11:5],rs2,rs1,3'b0,imm[4:0],7'b0};
                U_TYPE  : ops = {imm[19:0],rd,7'b0};
                B_TYPE  : ops = {imm[11],imm[9:4],rs2,rs1,3'b0,imm[3:0],imm[10],7'b0};
                J_TYPE  : ops = {imm[20],imm[10:1],imm[11],imm[19:12],rd,7'b0};
                DSAR_TYPE  : ops = {12'b0,rs1,3'b0,rd,7'b0};
                DSARI_TYPE : ops = {1'b0,imm[15:0],3'b0,rd,7'b0};
                DSAW_TYPE  : ops = {7'b0,rs2,rs1,3'b0,5'b0,7'b0};
                DSAWI_TYPE : ops = {1'b0,imm[15:5],rs1,3'b0,imm[4:0],7'b0};
                TASK_DONE_TYPE : ops = {imm[0],31'b0};
            endcase
                inst = inst_gen_queue[i].get_specified_inst(ops);
                find_inst = 1'b1;
                break;
            end
        end

        //$display("inst=%h,inst_name=%0s",inst,inst_name);
        if(find_inst==1'b0)begin
            $display("ERROR: special inst_name - %0s is not in inst_queue!!",inst_name);
            $finish();
        end
        inst_print();
    endfunction


    function insert_inst(int insert_num, inst_type_e inst_type);
    if(insert_num >0)   //ls base config seq insert may random to be insert 0 inst
    $fwrite(inst_gen_cfg.gen_file,"insert %0d %0s \n",insert_num, inst_type);
        for(int i=0; i< insert_num;i++)begin
            get_rand_inst(inst_type);
        end
    endfunction
function void inst_queue_gen();
//    `INT_INST_CREATE    
    if(RVC inside inst_gen_cfg.support_inst_set)begin
        case(inst_gen_cfg.xlen)
            32: begin `RV32C_INST_CREATE end
            64: begin `RV64C_INST_CREATE end
        endcase
    end
    if(RV64CBO inside inst_gen_cfg.support_inst_set)begin
        `RV64CBO_INST_CREATE
    end
    if(RVPREF inside inst_gen_cfg.support_inst_set)begin
        `RVPREF_INST_CREATE
    end
    if(RVI inside inst_gen_cfg.support_inst_set)begin
        case(inst_gen_cfg.xlen)
		32: begin `RV32I_INST_CREATE end
		64: begin `RV64I_INST_CREATE end
        endcase
    end
    if(RVM inside inst_gen_cfg.support_inst_set)begin
        case(inst_gen_cfg.xlen)
		32: begin `RV32M_INST_CREATE end
		64: begin `RV64M_INST_CREATE end
        endcase
    end
    if(RVA inside inst_gen_cfg.support_inst_set)begin
        case(inst_gen_cfg.xlen)
		32: begin `RV32A_INST_CREATE end
		64: begin `RV64A_INST_CREATE end
        endcase
    end
    if(RV64ZICSR inside inst_gen_cfg.support_inst_set)begin
        `RV64ZICSR_INST_CREATE
    end
    if(RV64ZIFENCEI inside inst_gen_cfg.support_inst_set)begin
        `RV64ZIFENCEI_INST_CREATE
    end
    if(CUSTOM inside inst_gen_cfg.support_inst_set)begin
        `CUSTOM_INST_CREATE
        `uvm_info("CUSTOM_RANDOM_CATEGORY",
                  $sformatf("DSAR/DSARI/DSAW/DSAWI -> SAFE_CUSTOM_DSA (weight=%0d); LOOP -> BRANCH_LOOP_ONLY; TASK_DONE -> TASK_END",
                            safe_inst_gen.safe_custom_dsa_dist), UVM_LOW)
    end
    if(M_MODE inside inst_gen_cfg.support_prv_mode)begin
        `M_MODE_PRV_INST_CREATE
    end
    if(S_MODE inside inst_gen_cfg.support_prv_mode)begin
        `S_MODE_PRV_INST_CREATE
    end
    if(inst_gen_cfg.float_en && (RV64F inside inst_gen_cfg.support_inst_set))begin
        `RV64F_INST_CREATE
    end
    if(inst_gen_cfg.float_en && (RV64D inside inst_gen_cfg.support_inst_set))begin
        `RV64D_INST_CREATE
    end
    queue_size = inst_gen_queue.size();
    ri_inst_gen.gen_file = inst_gen_cfg.gen_file;
    `uvm_info("INST_QUEUE_PROFILE", $sformatf("xlen=%0d queue_size=%0d", inst_gen_cfg.xlen, queue_size), UVM_LOW)
    if($test$plusargs("debug_print")) begin
        foreach(inst_gen_cfg.support_inst_name[i])
            `uvm_info("INST_QUEUE_PROFILE", $sformatf("support_inst_name[%0d]=%0s", i, inst_gen_cfg.support_inst_name[i]), UVM_LOW)
    end
//    foreach(inst_gen_queue[i]) $display("queue [%s] valid",inst_gen_queue[i].inst_name);
endfunction
function void inst_addr_print();
    if(!fetch_space_avail()) return;
    $fwrite(inst_gen_cfg.gen_file,"/*PC: %16h -> %10h*/",inst_addr,inst_paddr);
endfunction
function void inst_print();
    addr_type_e temp_addr_type;
    addr_structure_s fetch_s;
    int unsigned inst_bytes;

    inst_bytes = (inst[1:0] == 2'b11) ? 4 : 2;
    if(!fetch_space_avail_for(inst_bytes))begin
        truncate_fetch_space();
        return;
    end

    if($test$plusargs("debug_print"))begin
        $display(" inst_cnt = %0h,inst=%0h",inst_cnt,inst);
    end

    inst_pc_history.push_back(inst_addr);
    vmem_write_inst(inst, inst_bytes);
    reg_pool.free_reg();

    inst_addr  = inst_addr  + inst_bytes;
    inst_paddr = inst_paddr + inst_bytes;
    inst_cnt = inst_cnt - 1;

    if(!fetch_space_avail())
        truncate_fetch_space();

endfunction
endclass
