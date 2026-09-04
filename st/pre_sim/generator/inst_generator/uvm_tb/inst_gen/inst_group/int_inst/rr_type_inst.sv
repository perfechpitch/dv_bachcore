class rr_type_inst extends base_inst;
    `uvm_object_param_utils(rr_type_inst)
    function new (string name = "rr_type_inst");
        super.new(name); 
    endfunction : new
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val; 
        bit[4:0] rs1,rs2,rd; 
        rd = `RAND_RD_GPR; 
        if(ops_gen_cfg.rs1_eq_rd)  rs1 = rd; 
        else if(ops_gen_cfg.rs2_eq_rd) rs2 = rd; 

        if(!ops_gen_cfg.rs1_eq_rd) rs1 = `RAND_RS_GPR;

        if(ops_gen_cfg.rs1_eq_rs2) rs2 = rs1;
        else rs2 = `RAND_RS_GPR;
        val = {7'b0,rs2,rs1, 3'b0,rd,7'b0};
        if((inst_name == SUB || inst_name == ADD) && val == 0) begin
            rs1 = `RAND_RS_GPR ;//quit code hit
            val = {7'b0,rs2,rs1, 3'b0,rd,7'b0};
        end
        return val;
    endfunction 
    function void asm_print(); 
        $fwrite(gen_file,(`R_TYPE_ASM_STRING),`R_TYPE_ASM_VAL);
    endfunction 
endclass 

`define RR_INST(A,B,C,D,E,F,G,H)\
class ``A extends rr_type_inst;\ 
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
endclass 
`RR_INST(add_gen, "add_gen", ADD,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0110011, "add", ALU, R_TYPE)
`RR_INST(and_gen, "and_gen", AND,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_111_00000_0110011, "and", ALU, R_TYPE)
`RR_INST(sub_gen, "sub_gen", SUB,32'b1111111_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_000_00000_0110011, "sub", ALU, R_TYPE)
`RR_INST(xor_gen, "xor_gen", XOR,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_100_00000_0110011, "xor", ALU, R_TYPE)
`RR_INST(or_gen , "or_gen",  OR, 32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_110_00000_0110011, "or",  ALU, R_TYPE)
`RR_INST(sll_gen, "sll_gen", SLL,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0110011, "sll", ALU, R_TYPE)
`RR_INST(sra_gen, "sra_gen", SRA,32'b1111111_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_101_00000_0110011, "sra", ALU, R_TYPE)
`RR_INST(srl_gen, "srl_gen", SRL,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_0110011, "srl", ALU, R_TYPE)
`RR_INST(slt_gen, "slt_gen", SLT,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0110011, "slt", ALU, R_TYPE)
`RR_INST(sltu_gen, "sltu_gen", SLTU,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0110011, "sltu", ALU, R_TYPE)
`RR_INST(addw_gen, "addw_gen", ADDW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0111011, "addw", ALU, R_TYPE)
`RR_INST(subw_gen, "subw_gen", SUBW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_000_00000_0111011, "subw", ALU, R_TYPE)
`RR_INST(sllw_gen, "sllw_gen", SLLW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0111011, "sllw", ALU, R_TYPE)
`RR_INST(srlw_gen, "srlw_gen", SRLW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_0111011, "srlw", ALU, R_TYPE)
`RR_INST(sraw_gen, "sraw_gen", SRAW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0111011, "sraw", ALU, R_TYPE)
`RR_INST(mul_gen, "mul_gen", MUL,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_000_00000_0110011, "mul", ALU, R_TYPE)
`RR_INST(mulw_gen, "mulw_gen", MULW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_000_00000_0111011, "mulw", ALU, R_TYPE)
`RR_INST(mulh_gen, "mulh_gen", MULH,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_001_00000_0110011, "mulh", ALU, R_TYPE)
`RR_INST(mulhsu_gen, "mulhsu_gen", MULHSU,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_010_00000_0110011, "mulhsu", ALU, R_TYPE)
`RR_INST(mulhu_gen, "mulhu_gen", MULHU,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_011_00000_0110011, "mulhu", ALU, R_TYPE)
`RR_INST(div_gen, "div_gen", DIV,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_100_00000_0110011, "div", ALU, R_TYPE)
`RR_INST(divu_gen, "divu_gen", DIVU,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_101_00000_0110011, "divu", ALU, R_TYPE)
`RR_INST(divuw_gen, "divuw_gen", DIVUW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_101_00000_0111011, "divuw", ALU, R_TYPE)
`RR_INST(divw_gen, "divw_gen", DIVW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_100_00000_0111011, "divw", ALU, R_TYPE)
`RR_INST(rem_gen, "rem_gen", REM,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_110_00000_0110011, "rem", ALU, R_TYPE)
`RR_INST(remu_gen, "remu_gen", REMU,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_111_00000_0110011, "remu", ALU, R_TYPE)
`RR_INST(remuw_gen, "remuw_gen", REMUW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_111_00000_0111011, "remuw", ALU, R_TYPE)
`RR_INST(remw_gen, "remw_gen", REMW,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000001_00000_00000_110_00000_0111011, "remw", ALU, R_TYPE)
