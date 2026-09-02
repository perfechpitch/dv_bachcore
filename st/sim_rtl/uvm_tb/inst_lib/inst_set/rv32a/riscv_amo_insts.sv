`define AMO_W_INST_GEN(A,B,C,D,E,H) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32A, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        bit [31:0] rdata; \
        bit [31:0] wdata; \
        addr_state_s addr_state; \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);\
        addr_state.addr = `GPR(`RTYPE_RS1); \
        addr_state.acc_type = AMO; \
        addr_state.size = 2'd2; \
        mem_lib.fence_exe(); \
        rdata = mem_lib.read_mem(core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) begin \
            wdata = `GPR(`RTYPE_RS2) ``H rdata; \
            mem_lib.write_mem(wdata, core_state, addr_state); \
            if(core_state.except == NONE_EXCEPT) begin \
                `GPR(`RTYPE_RD) = rdata; \
                `PC_ADD \
            end \
        end \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`define AMO_COMP_W_INST_GEN(A,B,C,D,E,H) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32A, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        bit [31:0] rdata; \
        bit [31:0] wdata; \
        addr_state_s addr_state; \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);\
        addr_state.addr = `GPR(`RTYPE_RS1); \
        addr_state.acc_type = AMO; \
        addr_state.size = 2'd2; \
        mem_lib.fence_exe(); \
        rdata = mem_lib.read_mem(core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) begin \
            wdata = $signed(`GPR(`RTYPE_RS2)) ``H $signed(rdata) ? `GPR(`RTYPE_RS2) : rdata; \
            mem_lib.write_mem(wdata, core_state, addr_state); \
            if(core_state.except == NONE_EXCEPT) begin \
                `GPR(`RTYPE_RD) = rdata; \
                `PC_ADD \
            end \
        end \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`define AMO_COMP_U_W_INST_GEN(A,B,C,D,E,H) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32A, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        bit [31:0] rdata; \
        bit [31:0] wdata; \
        addr_state_s addr_state; \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);\
        addr_state.addr = `GPR(`RTYPE_RS1); \
        addr_state.acc_type = AMO; \
        addr_state.size = 2'd2; \
        mem_lib.fence_exe(); \
        rdata = mem_lib.read_mem(core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) begin \
            wdata = `GPR(`RTYPE_RS2) ``H rdata ? `GPR(`RTYPE_RS2) : rdata; \
            mem_lib.write_mem(wdata, core_state, addr_state); \
            if(core_state.except == NONE_EXCEPT) begin \
                `GPR(`RTYPE_RD) = rdata; \
                `PC_ADD \
            end \
        end \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`define AMO_SWAP_W_INST_GEN(A,B,C,D,E) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32A, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        bit [31:0] rdata; \
        addr_state_s addr_state; \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);\
        addr_state.addr = `GPR(`RTYPE_RS1); \
        addr_state.acc_type = AMO; \
        addr_state.size = 2'd2; \
        mem_lib.fence_exe(); \
        rdata = mem_lib.read_mem(core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) begin \
            mem_lib.write_mem(`GPR(`RTYPE_RS2), core_state, addr_state); \
            if(core_state.except == NONE_EXCEPT) begin \
                `GPR(`RTYPE_RD) = rdata; \
                `PC_ADD \
            end \
        end \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`AMO_W_INST_GEN(riscv_amoadd_w, "riscv_amoadd_w", "amoadd_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_010_00000_0101111, +)
`AMO_W_INST_GEN(riscv_amoand_w, "riscv_amoand_w", "amoand_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b0110000_00000_00000_010_00000_0101111, &)
`AMO_W_INST_GEN(riscv_amoor_w, "riscv_amoor_w", "amoor_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b0100000_00000_00000_010_00000_0101111, |)
`AMO_W_INST_GEN(riscv_amoxor_w, "riscv_amoxor_w", "amoxor_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b0010000_00000_00000_010_00000_0101111, ^)

`AMO_COMP_W_INST_GEN(riscv_amomin_w, "riscv_amomin_w", "amomin_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b1000000_00000_00000_010_00000_0101111, <)
`AMO_COMP_W_INST_GEN(riscv_amomax_w, "riscv_amomax_w", "amomax_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b1010000_00000_00000_010_00000_0101111, >)

`AMO_COMP_U_W_INST_GEN(riscv_amominu_w, "riscv_amominu_w", "amominu_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b1100000_00000_00000_010_00000_0101111, <)
`AMO_COMP_U_W_INST_GEN(riscv_amomaxu_w, "riscv_amomaxu_w", "amomaxu_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b1110000_00000_00000_010_00000_0101111, >)

`AMO_SWAP_W_INST_GEN(riscv_amoswap_w, "riscv_amoswap_w", "amoswap_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b0000100_00000_00000_010_00000_0101111)