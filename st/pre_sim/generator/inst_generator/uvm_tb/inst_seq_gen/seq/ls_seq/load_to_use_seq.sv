//----------------------------------------------------------------------
// load_to_use_sequence
//
// 生成最小的 Load-to-Use 数据依赖指令流：
//
//     LW producer -> gap[0..N] -> random RV32I ALU consumer
//
// producer 的 rd 是依赖寄存器。consumer 必须读取这个寄存器，gap 内的
// 指令不能提前读取或覆盖它。当前支持 RV32I R/I 型整数 ALU consumer。
//
// 本类有两个入口：
//   1. sub_seq_gen()：随机 LS 流入口。LOAD_TO_USE 与 RAND_LS、
//      LINEAR_LS、MEMCPY_LS 同级，由 ls_inst_sequence 选择。
//   2. gen_load_to_use()：单个 block 入口。随机路径和 directed scenario
//      共用；request 中未显式指定的字段由 constrained-random 补全。
//----------------------------------------------------------------------
class load_to_use_sequence extends base_inst_sequence;
    `uvm_object_utils(load_to_use_sequence)
    safe_inst_sequence safe_inst_seq;

    load_to_use_config load_to_use_cfg;
    function new(string name = "load_to_use_sequence");
        super.new(name);
    endfunction

    // 随机 LS 子序列入口。
    //
    // ls_seq_info.seq_length 是本次 LS 子序列的指令预算。一个完整 block
    // 占用：1 条 LW + gap 条独立指令 + 1 条 consumer，即 gap + 2 条。
    // 本函数使用若干完整 block 填充预算，不生成残缺的 producer 或
    // 缺少 consumer 的依赖链。
    virtual function void sub_seq_gen(ls_seq_info_item   ls_seq_info,
                                      inst_generator     inst_gen,
                                      data_init_generator data_init_gen);
        int unsigned remaining_inst_num;
        int unsigned block_inst_num;
        load_to_use_request request;

        // 剩余预算始终以“指令条数”计数，与指令编码是 16/32 bit 无关。
        remaining_inst_num = ls_seq_info.seq_length;
        $fwrite(inst_gen.gen_file,
                "//--- load-to-use seq start : seq_length = %0d\n",
                remaining_inst_num);
        while(remaining_inst_num >= 2) begin
            // cfg defines the random policy; the per-block request stores the
            // resolved consumer, operand dependency, gap, data and immediate.
            request = new($sformatf("random_l2u_%0d", remaining_inst_num));
            request.cfg = load_to_use_cfg;
            request.gap_budget_max = remaining_inst_num - 2;
            gen_load_to_use(request, inst_gen, data_init_gen);
            block_inst_num = request.gap + 2;
            remaining_inst_num -= block_inst_num;
        end
        $fwrite(inst_gen.gen_file, "//--- load-to-use seq end\n");
    endfunction

    // 生成一个完整的 Load-to-Use block。
    //
    // request 可由两类调用者提供：
    //   - 随机子序列：通常只固定 gap，其余字段随机；
    //   - directed scenario：可固定 consumer、gap、load_data。
    //
    // 数据流：
    //   request randomize
    //     -> pin producer rd
    //     -> 生成最终 Load EA/imm
    //     -> 根据 EA 写 Data Init word
    //     -> 输出 LW/gap/consumer
    //     -> unpin producer rd
    virtual function void gen_load_to_use(load_to_use_request request,
                                          inst_generator      inst_gen,
                                          data_init_generator data_init_gen);
        addr_structure_s ls_s;
        ops_gen_config   access_cfg;
        ls_addr_s        access;
        bit[4:0]         producer_rd;
        bit[4:0]         producer_base;
        bit[4:0]         consumer_rd;
        bit[4:0]         consumer_other_rs;
        bit[31:0]        resolved_data;

        if(request == null || data_init_gen == null)
            `uvm_fatal("LOAD_TO_USE", "request/data_init_generator is null")
        if(load_to_use_cfg == null)
            `uvm_fatal("LOAD_TO_USE", "load_to_use_config is null")
        if(request.cfg == null)
            request.cfg = load_to_use_cfg;
        // valid 标志对应的 request 字段保持调用者指定值；其他字段随机。
        if(!request.randomize())
            `uvm_fatal("LOAD_TO_USE", "load_to_use_request randomize failed")

        // producer rd 在整个 block 期间从普通随机 GPR pool 中移除。
        // 这样 gap 指令既不会覆盖 Load 结果，也不会提前消费该结果。
        producer_rd = inst_gen.reg_pool.pin_gpr();

        // 选择一个已经配置好的 LS base register。get_ls_access() 返回
        // 完整的最终访问结果，而不只是 imm：
        //   EA = base_value + sext(imm12)
        // Data Init 必须使用这个最终 EA，才能与实际 LW 访问同一地址。
        ls_s = '0;
        ls_s.addr_type = LOAD_VALID;
        producer_base = inst_gen.reg_pool.get_ls_base_reg(ls_s);
        access_cfg = new("load_to_use_access_cfg");
        access_cfg.align_bytes       = 4;
        access_cfg.ls_inst_unsigned  = 1'b0;
        access_cfg.ls_addr_misalign  = 1'b0;
        access = inst_gen.ls_addr_gen.get_ls_access(ls_s, access_cfg);
        // 将 LW 需要读取的32-bit数据写到独立 data_init.vmem。
        // 如果 directed request 固定了 load_data，冲突初始化会报错；
        // 随机请求复用同一地址时则沿用该地址已经存在的数据。
        resolved_data = data_init_gen.init_word(access, request.load_data,
                                                request.load_data_valid);

        $fwrite(inst_gen.gen_file,
                "//--- load_to_use start producer=LW consumer=%s gap=%0d rd=x%0d ea=0x%08h data=0x%08h\n",
                request.consumer_inst.name(), request.gap, producer_rd,
                access.ea[31:0], resolved_data);
        inst_gen.get_specified_inst(request.producer_inst, producer_base, '0, producer_rd,
                                    access.imm);

        // gap 表示 producer 与 consumer 之间的“指令条数”。复用现有
        // safe_inst_sequence，只允许 SAFE_INT_CAL；分支、访存、浮点和
        // custom SAFE 子类均关闭。producer_rd 仍处于 pin 状态，因此
        // gap 指令不会读写它。
        if(request.gap > 0) begin
            if(safe_inst_seq == null)
                `uvm_fatal("LOAD_TO_USE", "safe_inst_sequence is null")
            safe_inst_seq.gen_int_cal_seq(request.gap);
        end

        // Encode the resolved request. I-type consumers always use rs1;
        // R-type consumers use the operand selected by dependency_operand.
        consumer_rd = inst_gen.reg_pool.get_nonezero_gpr(1'b1);
        case(request.consumer_type)
            L2U_CONSUMER_ALU_R: begin
                consumer_other_rs = inst_gen.reg_pool.get_nonezero_gpr(1'b0);
                if(request.dependency_operand == L2U_USE_RS1)
                    inst_gen.get_specified_inst(request.consumer_inst,
                                                producer_rd, consumer_other_rs,
                                                consumer_rd, '0);
                else
                    inst_gen.get_specified_inst(request.consumer_inst,
                                                consumer_other_rs, producer_rd,
                                                consumer_rd, '0);
            end
            L2U_CONSUMER_ALU_I: begin
                inst_gen.get_specified_inst(request.consumer_inst,
                                            producer_rd, '0, consumer_rd,
                                            request.consumer_imm);
            end
        endcase
        // consumer 已经输出，依赖区间结束，将 producer rd 放回随机池。
        inst_gen.reg_pool.unpin_gpr(producer_rd);
        $fwrite(inst_gen.gen_file, "//--- load_to_use end\n");
        `uvm_info("LOAD_TO_USE",
                  $sformatf("LW x%0d,0x%0h(x%0d) -> gap=%0d -> %s data=0x%08h",
                            producer_rd, access.imm, producer_base, request.gap,
                            request.consumer_inst.name(), resolved_data), UVM_LOW)
    endfunction
endclass
