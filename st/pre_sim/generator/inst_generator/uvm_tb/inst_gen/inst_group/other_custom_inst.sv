// Other custom instructions. Encodings match core_ref/custom/other_custom.sv.
class task_done_gen extends base_inst;
    localparam bit [31:0] CONST_MASK = 32'h7fff_ffff;
    localparam bit [31:0] CONST_VAL  = 32'h0000_200b;

    function new(string name = "task_done_gen");
        super.new(name);
        `INST_GEN_NEW(TASK_DONE, ROB, CONST_MASK, CONST_VAL,
                      "task_done", TASK_DONE_TYPE)
    endfunction : new
    `uvm_object_param_utils(task_done_gen)

    // TS occupies bit 31. Random generation selects it from rand_imm[0].
    function bit[31:0] rand_ops_gen(ops_gen_config ops_gen_cfg);
        return {ops_gen_cfg.rand_imm[0], 31'b0};
    endfunction : rand_ops_gen

    function void asm_print();
        $fwrite(gen_file,
                ".insn 0x%08h// %8s\tTS=%0d\n",
                inst, asm_name, inst[31]);
    endfunction : asm_print
endclass : task_done_gen


class loop_gen extends b_type_inst;
    localparam bit [31:0] CONST_MASK = 32'h0000_707f;
    localparam bit [31:0] CONST_VAL  = 32'h0000_600b;

    function new(string name = "loop_gen");
        super.new(name);
        `INST_GEN_NEW(LOOP, BEU, CONST_MASK, CONST_VAL, "loop", B_TYPE)
    endfunction : new
    `uvm_object_param_utils(loop_gen)

    function void asm_print();
        $fwrite(gen_file, (`B_TYPE_ASM_STRING), `B_TYPE_ASM_VAL);
    endfunction : asm_print
endclass : loop_gen
