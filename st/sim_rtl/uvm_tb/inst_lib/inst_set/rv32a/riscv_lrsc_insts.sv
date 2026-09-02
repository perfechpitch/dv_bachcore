`define LR_INST_GEN(A,B,C,D,E) \
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
        addr_state.acc_type = LR; \
        addr_state.size = 2'd2; \
        rdata = mem_lib.read_mem(core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) begin \
            `GPR(`RTYPE_RD) = rdata; \
            core_state.lrbit = 1'b1; \
            core_state.lrsize = 2'd2; \
            core_state.lraddr = addr_state.addr[31:0]; \
            `PC_ADD \
        end \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`define SC_INST_GEN(A,B,C,D,E) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32A, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        bit [31:0] wdata; \
        addr_state_s addr_state; \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2);\
        wdata = `GPR(`RTYPE_RS2); \
        addr_state.addr = `GPR(`RTYPE_RS1); \
        addr_state.acc_type = SC; \
        addr_state.size = 2'd2; \
        if(mem_lib.addr_check(core_state, addr_state)) begin \
            if(core_state.lrbit && core_state.lrsize == 2'd2 && core_state.lraddr == addr_state.addr[31:0]) begin \
                mem_lib.write_mem(wdata, core_state, addr_state); \
                if(core_state.except == NONE_EXCEPT) begin \
                    `GPR(`RTYPE_RD) = 32'h0; \
                    `PC_ADD \
                end \
            end \
            else begin \
                `GPR(`RTYPE_RD) = 32'h1; \
                `PC_ADD \
            end \
        end \
        core_state.lrbit = 1'b0; \
        core_state.lraddr = '0; \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`LR_INST_GEN(riscv_lr_w, "riscv_lr_w", "lr_w", 32'b1111100_11111_00000_111_00000_1111111, 32'b0001000_00000_00000_010_00000_0101111)
`SC_INST_GEN(riscv_sc_w, "riscv_sc_w", "sc_w", 32'b1111100_00000_00000_111_00000_1111111, 32'b0001100_00000_00000_010_00000_0101111)