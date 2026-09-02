`define AUIPC_CONST_MASK 32'b0000000_00000_00000_000_00000_1111111
`define AUIPC_CONST_VAL  32'b0000000_00000_00000_000_00000_0010111

class riscv_auipc extends riscv_inst;

    function new(string name = "riscv_auipc");
        super.new(name);
        `INST_NEW("auipc", RV32I, ALU, `AUIPC_CONST_MASK, `AUIPC_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_auipc)

    function void inst_exe(`INST_EXE_PARAS);
        `GPR(`UTYPE_RD) = core_state.pc + `UTYPE_IMM;
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`U_TYPE_EXE_STRING), `U_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_auipc