`define MUL_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define MUL_CONST_VAL  32'b0000001_00000_00000_000_00000_0110011

class riscv_mul extends riscv_inst;

    function new(string name = "riscv_mul");
        super.new(name);
        `INST_NEW("mul", RV32M, MDU, `MUL_CONST_MASK, `MUL_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_mul)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val, rs2_val;
        bit [63:0] product;
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);
        product = `GPR(`RTYPE_RS1) * `GPR(`RTYPE_RS2);
        `GPR(`RTYPE_RD) = product[31:0];
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_mul

`define MULH_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define MULH_CONST_VAL  32'b0000001_00000_00000_001_00000_0110011

class riscv_mulh extends riscv_inst;

    function new(string name = "riscv_mulh");
        super.new(name);
        `INST_NEW("mulh", RV32M, MDU, `MULH_CONST_MASK, `MULH_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_mulh)

    function void inst_exe(`INST_EXE_PARAS);
        bit signed [32:0] rs1_val;
        bit signed [32:0] rs2_val;
        bit signed [63:0] product;

        rs1_val = $signed(`GPR(`RTYPE_RS1));
        rs2_val = $signed(`GPR(`RTYPE_RS2));
        product = rs1_val * rs2_val;
        `GPR(`RTYPE_RD) = product[63:32];
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_mulh

`define MULHSU_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define MULHSU_CONST_VAL  32'b0000001_00000_00000_010_00000_0110011

class riscv_mulhsu extends riscv_inst;

    function new(string name = "riscv_mulhsu");
        super.new(name);
        `INST_NEW("mulhsu", RV32M, MDU, `MULHSU_CONST_MASK, `MULHSU_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_mulhsu)

    function void inst_exe(`INST_EXE_PARAS);
        bit signed [32:0] rs1_val;
        bit signed [32:0] rs2_val;
        bit signed [65:0] product;

        rs1_val = {`GPR(`RTYPE_RS1)[31], `GPR(`RTYPE_RS1)};
        rs2_val = {1'b0, `GPR(`RTYPE_RS2)};
        product = rs1_val * rs2_val;
        `GPR(`RTYPE_RD) = product[63:32];
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_mulhsu

`define MULHU_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define MULHU_CONST_VAL  32'b0000001_00000_00000_011_00000_0110011

class riscv_mulhu extends riscv_inst;

    function new(string name = "riscv_mulhu");
        super.new(name);
        `INST_NEW("mulhu", RV32M, MDU, `MULHU_CONST_MASK, `MULHU_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_mulhu)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        bit [63:0] product;
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);
        product = `GPR(`RTYPE_RS1) * `GPR(`RTYPE_RS2);
        `GPR(`RTYPE_RD) = product[63:32];
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_mulhu

`define DIV_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define DIV_CONST_VAL  32'b0000001_00000_00000_100_00000_0110011

class riscv_div extends riscv_inst;

    function new(string name = "riscv_div");
        super.new(name);
        `INST_NEW("div", RV32M, MDU, `DIV_CONST_MASK, `DIV_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_div)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);
        if(`GPR(`RTYPE_RS1) == 32'h8000_0000 && `GPR(`RTYPE_RS2) == 32'hffff_ffff)
            `GPR(`RTYPE_RD) = 32'h8000_0000;
        else if(`GPR(`RTYPE_RS2) == 32'h0)
            `GPR(`RTYPE_RD) = 32'hffff_ffff;
        else
            `GPR(`RTYPE_RD) = $signed(`GPR(`RTYPE_RS1)) / $signed(`GPR(`RTYPE_RS2));

        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_div

`define DIVU_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define DIVU_CONST_VAL  32'b0000001_00000_00000_101_00000_0110011

class riscv_divu extends riscv_inst;

    function new(string name = "riscv_divu");
        super.new(name);
        `INST_NEW("divu", RV32M, MDU, `DIVU_CONST_MASK, `DIVU_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_divu)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);
        if(`GPR(`RTYPE_RS2) == 32'h0)
            `GPR(`RTYPE_RD) = 32'hffff_ffff;
        else
            `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1) / `GPR(`RTYPE_RS2);

        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_divu

`define REM_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define REM_CONST_VAL  32'b0000001_00000_00000_110_00000_0110011

class riscv_rem extends riscv_inst;

    function new(string name = "riscv_rem");
        super.new(name);
        `INST_NEW("rem", RV32M, MDU, `REM_CONST_MASK, `REM_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_rem)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);
        if(`GPR(`RTYPE_RS1) == 32'h8000_0000 && `GPR(`RTYPE_RS2) == 32'hffff_ffff)
            `GPR(`RTYPE_RD) = 32'h0;
        else if(`GPR(`RTYPE_RS2) == 32'h0)
            `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1);
        else
            `GPR(`RTYPE_RD) = $signed(`GPR(`RTYPE_RS1)) % $signed(`GPR(`RTYPE_RS2));

        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_rem

`define REMU_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define REMU_CONST_VAL  32'b0000001_00000_00000_111_00000_0110011

class riscv_remu extends riscv_inst;

    function new(string name = "riscv_remu");
        super.new(name);
        `INST_NEW("remu", RV32M, MDU, `REMU_CONST_MASK, `REMU_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_remu)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);
        if(`GPR(`RTYPE_RS2) == 32'h0)
            `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1);
        else
            `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1) % `GPR(`RTYPE_RS2);

        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_remu