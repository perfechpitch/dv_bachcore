`define LOAD_INST_GEN(A,B,C,D,E,F,G) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        int rs1_val; \
        bit [31:0] rdata; \
        addr_state_s addr_state; \
        rs1_val = `GPR(`ITYPE_RS1); \
        addr_state.addr = rs1_val + `ITYPE_IMM_SIGN_EXTEND32; \
        addr_state.acc_type = LOAD; \
        addr_state.size = ``F; \
        rdata = mem_lib.read_mem( core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) begin \
            case(``F) \
                2'd0: `GPR(`ITYPE_RD) = ``G ? {{24{rdata[7]}}, rdata[7:0]} : {24'b0, rdata[7:0]}; \
                2'd1: `GPR(`ITYPE_RD) = ``G ? {{16{rdata[15]}}, rdata[15:0]} : {16'b0, rdata[15:0]}; \
                2'd2: `GPR(`ITYPE_RD) = rdata; \
            endcase \
            `PC_ADD \
        end \
        if(log_en) \
            $fwrite(inst_exe_log, (`I_TYPE_EXE_STRING), `I_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`LOAD_INST_GEN(riscv_lb,  "riscv_lb",  "lb",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_000_00000_0000011,
    2'd0, 1'b1)

`LOAD_INST_GEN(riscv_lh,  "riscv_lh",  "lh",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_001_00000_0000011,
    2'd1, 1'b1)

`LOAD_INST_GEN(riscv_lw,  "riscv_lw",  "lw",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_010_00000_0000011,
    2'd2, 1'b0)

`LOAD_INST_GEN(riscv_lbu, "riscv_lbu", "lbu",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_100_00000_0000011,
    2'd0, 1'b0)

`LOAD_INST_GEN(riscv_lhu, "riscv_lhu", "lhu",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_101_00000_0000011,
    2'd1, 1'b0)