class ri_type_inst extends base_inst;
    `uvm_object_param_utils(ri_type_inst)
    function new (string name = "ri_type_inst");
        super.new(name); 
    endfunction : new 
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val; 
        bit[4:0] rs1,rd; 
        rd = `RAND_RD_GPR; 
        if(ops_gen_cfg.rs1_eq_rd)  rs1 = rd;
        else rs1 = `RAND_RS_GPR; 
        val = {ops_gen_cfg.rand_imm[11:0],rs1,3'b0,rd,7'b0};
        return val; 
    endfunction 
endclass 
    
`define RI_INST(A,B,C,D,E,F,G,H)\
class ``A extends ri_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void asm_print(); \
        $fwrite(gen_file,(`I_TYPE_ASM_STRING),`I_TYPE_ASM_VAL);\
    endfunction \
endclass 

`RI_INST(addi_gen, "addi_gen",  ADDI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0010011,"addi" ,ALU,I_TYPE)
`RI_INST(andi_gen, "andi_gen",  ANDI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_111_00000_0010011,"andi" ,ALU,I_TYPE)
`RI_INST(ori_gen , "ori_gen ",  ORI  ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_110_00000_0010011,"ori " ,ALU,I_TYPE)
`RI_INST(xori_gen, "xori_gen",  XORI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_100_00000_0010011,"xori" ,ALU,I_TYPE)
`RI_INST(slti_gen, "slti_gen",  SLTI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0010011,"slti" ,ALU,I_TYPE)
`RI_INST(sltiu_gen,"sltiu_gen",SLTIU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0010011,"sltiu",ALU,I_TYPE)

`define SAFE_CSR_ADDRS \
['h1:'h3],['hc00:'hc9f]
//['hf11:'hf15],['h301:304],'h306,['h340:'h34b], \
//'h30a,'h31a,['h3a0:'h3ef],

//TODO:safe csr/non exists csr has own dist
`define CSR_ADDR_DIST \
    rand_imm inside {`SAFE_CSR_ADDRS};
`define CSR_RI_INST(A,B,C,D,E,F,G,H)\
class ``A extends ri_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void ops_gen_cfg_rand(ref ops_gen_config   ops_gen_cfg); \
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,`CSR_ADDR_DIST,"Error: csr inst ops gen error")\
    endfunction \
    function void asm_print(); \
        $fwrite(gen_file,(`I_TYPE_ASM_STRING),`I_TYPE_ASM_VAL);\
    endfunction \
endclass
`CSR_RI_INST(csrrc_gen, "csrrc_gen",  CSRRC ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_1110011,"csrrc" ,ALU,I_TYPE)
`CSR_RI_INST(csrrci_gen, "csrrci_gen",  CSRRCI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_111_00000_1110011,"csrrci" ,ALU,I_TYPE)
`CSR_RI_INST(csrrs_gen, "csrrs_gen",  CSRRS ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_1110011,"csrrs" ,ALU,I_TYPE)
`CSR_RI_INST(csrrsi_gen, "csrrsi_gen",  CSRRSI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_110_00000_1110011,"csrrsi" ,ALU,I_TYPE)
`CSR_RI_INST(csrrw_gen, "csrrw_gen",  CSRRW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_1110011,"csrrw" ,ALU,I_TYPE)
`CSR_RI_INST(csrrwi_gen, "csrrwi_gen",  CSRRWI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_1110011,"csrrwi" ,ALU,I_TYPE)
`define SHIFT_RI_INST(A,B,C,D,E,F,G,H)\
class ``A extends ri_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void asm_print(); \
        $fwrite(gen_file,(`SHIFT_I_TYPE_ASM_STRING),`SHIFT_I_TYPE_ASM_VAL);\
    endfunction \
endclass

`SHIFT_RI_INST(slli_gen, "slli_gen",  SLLI ,32'b1111110_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0010011,"slli" ,ALU,I_TYPE)
`SHIFT_RI_INST(srai_gen, "srai_gen",  SRAI ,32'b1111110_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_101_00000_0010011,"srai" ,ALU,I_TYPE)
`SHIFT_RI_INST(srli_gen, "srli_gen",  SRLI ,32'b1111110_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_0010011,"srli" ,ALU,I_TYPE)
`SHIFT_RI_INST(slliw_gen, "slliw_gen",SLLIW ,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0011011,"slliw" ,ALU,I_TYPE)
`SHIFT_RI_INST(srliw_gen, "srliw_gen",SRLIW ,32'b1111111_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_0011011,"srliw" ,ALU,I_TYPE)
`SHIFT_RI_INST(sraiw_gen, "sraiw_gen",SRAIW ,32'b1111111_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_101_00000_0011011,"sraiw" ,ALU,I_TYPE)
`SHIFT_RI_INST(addiw_gen, "addiw_gen",ADDIW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0011011,"addiw" ,ALU,I_TYPE)
