// These instructions are present in ISA描述.xlsx under "其他自定义指令".
// The workbook defines their encodings but does not define architectural
// side effects. Keep their reference behavior map-only until that contract is
// available: recognize the instruction, log it, and advance the PC.

class custom_inst_task_done extends riscv_inst;

    // TS is inst[31]; all remaining bits are fixed by the workbook encoding.
    parameter CONST_MASK = 32'h7fffffff;
    parameter CONST_VAL  = 32'h0000200b;

    function new(string name="custom_inst_task_done");
        super.new(name);
        `INST_NEW("task_done", CUSTOM, ROB, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_task_done)

    function void inst_exe(`INST_EXE_PARAS);
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, "task_done ts=%0d\n", inst[31]);
    endfunction : inst_exe

endclass : custom_inst_task_done


class custom_inst_flag_check extends riscv_inst;

    // funct7=7'b0000001, funct3=3'b010, opcode=custom-0.
    parameter CONST_MASK = 32'hfe00707f;
    parameter CONST_VAL  = 32'h0200200b;

    function new(string name="custom_inst_flag_check");
        super.new(name);
        `INST_NEW("flag_check", CUSTOM, ALU, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_flag_check)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;

        rs1_val = `GPR(`RTYPE_RS1);
        rs2_val = `GPR(`RTYPE_RS2);

        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                "flag_check x%0d=%08h, x%0d=%08h, x%0d unchanged=%08h\n",
                `RTYPE_RS1, rs1_val,
                `RTYPE_RS2, rs2_val,
                `RTYPE_RD, `GPR(`RTYPE_RD));
    endfunction : inst_exe

endclass : custom_inst_flag_check


class custom_inst_loop extends riscv_inst;

    // B-type immediate/operands, funct3=3'b110, opcode=custom-0.
    parameter CONST_MASK = 32'h0000707f;
    parameter CONST_VAL  = 32'h0000600b;

    function new(string name="custom_inst_loop");
        super.new(name);
        `INST_NEW("loop", CUSTOM, BEU, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_loop)

    function void inst_exe(`INST_EXE_PARAS);
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                "loop x%0d=%08h, x%0d=%08h, imm=%08h (map-only)\n",
                `BTYPE_RS1, `GPR(`BTYPE_RS1),
                `BTYPE_RS2, `GPR(`BTYPE_RS2),
                `BTYPE_IMM_SIGN_EXTEND32);
    endfunction : inst_exe

endclass : custom_inst_loop
