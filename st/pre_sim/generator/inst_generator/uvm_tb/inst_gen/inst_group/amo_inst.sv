
`define SC_INST(A,B,C,D,E,F,G,H,J)\
class ``A extends rr_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg); \
        bit[31:0] val;  \
        bit[4:0] rs1,rs2,rd; \ 
        addr_structure_s ls_s; \
        ls_s.addr_type = ``J; \
        rd = `RAND_RD_GPR; \
        rs1 = `RAND_LS_BASE_REG(ls_s); \
        if(ops_gen_cfg.rs1_eq_rs2) rs2 = rs1;\
        else rs2 = `RAND_RS_GPR; \
        if(const_ops_val[12] && ls_s.vaddr[2:0] == 'd4)/*amo.d get a bit[2:0] ==4 base*/ begin\
            const_ops_val[12] = 'd0; \
            val = {7'b0,rs2,rs1, 3'b0,rd,7'b0}; \
            case(asm_name)\
                "sc_d":  asm_name = "sc_w";\
            endcase\
            return val; \
            const_ops_val[12] = 'd1; \
            case(asm_name)\
                "sc_w":  asm_name = "sc_d";\
            endcase\
        end \
        else begin\
            val = {7'b0,rs2,rs1, 3'b0,rd,7'b0}; \
            return val;\
        end\
    endfunction \
endclass 

`SC_INST(sc_w_gen, "sc_w_gen",  SC_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0001100_00000_00000_010_00000_0101111,"sc_w" ,ALU,R_TYPE,AMO_VALID)
`SC_INST(sc_d_gen, "sc_d_gen",  SC_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0001100_00000_00000_011_00000_0101111,"sc_d" ,ALU,R_TYPE,AMO_VALID)
`SC_INST(invalid_sc_w_gen, "invalid_sc_w_gen",  INVALID_SC_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0001100_00000_00000_010_00000_0101111,"invalid_sc_w" ,ALU,R_TYPE,AMO_INVALID)
`SC_INST(invalid_sc_d_gen, "invalid_sc_d_gen",  INVALID_SC_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0001100_00000_00000_011_00000_0101111,"invalid_sc_d" ,ALU,R_TYPE,AMO_INVALID)

`define LR_INST(A,B,C,D,E,F,G,H,J)\
class ``A extends rr_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg); \
        bit[31:0] val;  \
        bit[4:0] rs1,rd; \
        addr_structure_s ls_s; \
        ls_s.addr_type = ``J; \
        rd = `RAND_RD_GPR; \
        rs1 = `RAND_LS_BASE_REG(ls_s); \
        if(const_ops_val[12] && ls_s.vaddr[2:0] == 'd4)/*amo.d get a bit[2:0] ==4 base*/ begin\
            const_ops_val[12] = 'd0; \
            val = {7'b0,5'b0,rs1, 3'b0,rd,7'b0}; \
            case(asm_name)\
                "lr_d":  asm_name = "lr_w";\
            endcase\
            return val; \
            const_ops_val[12] = 'd1; \
            case(asm_name)\
                "lr_w":  asm_name = "lr_d";\
            endcase\
        end \
        else begin\
            val = {7'b0,5'b0,rs1, 3'b0,rd,7'b0}; \
            return val;\
        end\
    endfunction \
endclass
`LR_INST(lr_w_gen, "lr_w_gen",  LR_W ,32'b1111100_11111_00000_111_00000_1111111 ,32'b0001000_00000_00000_010_00000_0101111,"invalid_lr_w" ,ALU,R_TYPE,AMO_VALID)
`LR_INST(lr_d_gen, "lr_d_gen",  LR_D ,32'b1111100_11111_00000_111_00000_1111111 ,32'b0001000_00000_00000_011_00000_0101111,"invalid_lr_d" ,ALU,R_TYPE,AMO_VALID)
`LR_INST(invalid_lr_w_gen, "invalid_lr_w_gen",  INVALID_LR_W ,32'b1111100_11111_00000_111_00000_1111111 ,32'b0001000_00000_00000_010_00000_0101111,"invalid_lr_w" ,ALU,R_TYPE,AMO_INVALID)
`LR_INST(invalid_lr_d_gen, "invalid_lr_d_gen",  INVALID_LR_D ,32'b1111100_11111_00000_111_00000_1111111 ,32'b0001000_00000_00000_011_00000_0101111,"invalid_lr_d" ,ALU,R_TYPE,AMO_INVALID)

`define AMO_RR_INST(A,B,C,D,E,F,G,H,J)\
class ``A extends rr_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);\
        bit[31:0] val; \
        bit[11:0] imm; \
        bit[4:0] rd,rs2,base;\
        addr_structure_s ls_s; \
        ls_s.addr_type = ``J; \
        rd = `RAND_RD_GPR; \
        base = `RAND_LS_BASE_REG(ls_s); \
        //$display("inst_name = %0s, base=%0h. ls_s = %0p",inst_name, base,ls_s);\
        if(ops_gen_cfg.rs2_eq_rd) rs2 = rd;\
        else rs2 = `RAND_RS_GPR;\
        if(const_ops_val[12] && ls_s.vaddr[2:0] == 'd4)/*amo.d get a bit[2:0] ==4 base*/ begin\
            const_ops_val[12] = 'd0; \
            val = {ops_gen_cfg.rand_imm,rs2,base,3'b0,rd,7'b0}; \
            case(asm_name)\
                "amoor_d":  asm_name = "amoor_w";\
                "amoadd_d":  asm_name = "amoadd_w";\
                "amoxor_d":  asm_name = "amoxor_w";\
                "amoand_d":  asm_name = "amoand_w";\
                "amomin_d":  asm_name = "amomin_w";\
                "amomax_d":  asm_name = "amomax_w";\
                "amominu_d":  asm_name = "amominu_w";\
                "amomaxu_d":  asm_name = "amomaxu_w";\
                "amoswap_d":  asm_name = "amoswap_w";\
            endcase\
            return val; \
            const_ops_val[12] = 'd1; \
 case(asm_name)\
                "amoor_w":  asm_name = "amoor_d";\
                "amoadd_w":  asm_name = "amoadd_d";\
                "amoxor_w":  asm_name = "amoxor_d";\
                "amoand_w":  asm_name = "amoand_d";\
                "amomin_w":  asm_name = "amomin_d";\
                "amomax_w":  asm_name = "amomax_d";\
                "amominu_w":  asm_name = "amominu_d";\
                "amomaxu_w":  asm_name = "amomaxu_d";\
                "amoswap_w":  asm_name = "amoswap_d";\
            endcase\
        end \
        else begin\
            val = {ops_gen_cfg.rand_imm,rs2,base,3'b0,rd,7'b0}; \
            return val; \
        end\
    endfunction \
endclass

`AMO_RR_INST(amoor_w_gen, "amoor_w_gen",  AMOOR_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_010_00000_0101111,"amoor_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoadd_w_gen, "amoadd_w_gen",  AMOADD_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0101111,"amoadd_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoxor_w_gen, "amoxor_w_gen",  AMOXOR_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_010_00000_0101111,"amoxor_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoand_w_gen, "amoand_w_gen",  AMOAND_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0110000_00000_00000_010_00000_0101111,"amoand_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amomin_w_gen, "amomin_w_gen",  AMOMIN_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1000000_00000_00000_010_00000_0101111,"amomin_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amomax_w_gen, "amomax_w_gen",  AMOMAX_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_010_00000_0101111,"amomax_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amominu_w_gen, "amominu_w_gen",  AMOMINU_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1100000_00000_00000_010_00000_0101111,"amominu_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amomaxu_w_gen, "amomaxu_w_gen",  AMOMAXU_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1110000_00000_00000_010_00000_0101111,"amomaxu_w" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoswap_w_gen, "amoswap_w_gen",  AMOSWAP_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000100_00000_00000_010_00000_0101111,"amoswap_w" ,ALU,R_TYPE,AMO_VALID)


`AMO_RR_INST(amoor_d_gen, "amoor_d_gen",  AMOOR_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_011_00000_0101111,"amoor_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoadd_d_gen, "amoadd_d_gen",  AMOADD_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0101111,"amoadd_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoxor_d_gen, "amoxor_d_gen",  AMOXOR_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_011_00000_0101111,"amoxor_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoand_d_gen, "amoand_d_gen",  AMOAND_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0110000_00000_00000_011_00000_0101111,"amoand_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amomin_d_gen, "amomin_d_gen",  AMOMIN_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1000000_00000_00000_011_00000_0101111,"amomin_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amomax_d_gen, "amomax_d_gen",  AMOMAX_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_011_00000_0101111,"amomax_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amominu_d_gen, "amominu_d_gen",  AMOMINU_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1100000_00000_00000_011_00000_0101111,"amominu_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amomaxu_d_gen, "amomaxu_d_gen",  AMOMAXU_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1110000_00000_00000_011_00000_0101111,"amomaxu_d" ,ALU,R_TYPE,AMO_VALID)
`AMO_RR_INST(amoswap_d_gen, "amoswap_d_gen",  AMOSWAP_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000100_00000_00000_011_00000_0101111,"amoswap_d" ,ALU,R_TYPE,AMO_VALID)

`AMO_RR_INST(invalid_amoor_w_gen, "invalid_amoor_w_gen",  INVALID_AMOOR_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_010_00000_0101111,"invalid_amoor_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoadd_w_gen, "invalid_amoadd_w_gen",  INVALID_AMOADD_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0101111,"invalid_amoadd_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoxor_w_gen, "invalid_amoxor_w_gen",  INVALID_AMOXOR_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_010_00000_0101111,"invalid_amoxor_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoand_w_gen, "invalid_amoand_w_gen",  INVALID_AMOAND_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0110000_00000_00000_010_00000_0101111,"invalid_amoand_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amomin_w_gen, "invalid_amomin_w_gen",  INVALID_AMOMIN_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1000000_00000_00000_010_00000_0101111,"invalid_amomin_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amomax_w_gen, "invalid_amomax_w_gen",  INVALID_AMOMAX_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_010_00000_0101111,"invalid_amomax_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amominu_w_gen, "invalid_amominu_w_gen",  INVALID_AMOMINU_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1100000_00000_00000_010_00000_0101111,"invalid_amominu_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amomaxu_w_gen, "invalid_amomaxu_w_gen",  INVALID_AMOMAXU_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1110000_00000_00000_010_00000_0101111,"invalid_amomaxu_w" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoswap_w_gen, "invalid_amoswap_w_gen",  INVALID_AMOSWAP_W ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000100_00000_00000_010_00000_0101111,"invalid_amoswap_w" ,ALU,R_TYPE,AMO_INVALID)


`AMO_RR_INST(invalid_amoor_d_gen, "invalid_amoor_d_gen",  INVALID_AMOOR_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0100000_00000_00000_011_00000_0101111,"invalid_amoor_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoadd_d_gen, "invalid_amoadd_d_gen",  INVALID_AMOADD_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0101111,"invalid_amoadd_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoxor_d_gen, "invalid_amoxor_d_gen",  INVALID_AMOXOR_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_011_00000_0101111,"invalid_amoxor_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoand_d_gen, "invalid_amoand_d_gen",  INVALID_AMOAND_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0110000_00000_00000_011_00000_0101111,"invalid_amoand_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amomin_d_gen, "invalid_amomin_d_gen",  INVALID_AMOMIN_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1000000_00000_00000_011_00000_0101111,"invalid_amomin_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amomax_d_gen, "invalid_amomax_d_gen",  INVALID_AMOMAX_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_011_00000_0101111,"invalid_amomax_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amominu_d_gen, "invalid_amominu_d_gen",  INVALID_AMOMINU_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1100000_00000_00000_011_00000_0101111,"invalid_amominu_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amomaxu_d_gen, "invalid_amomaxu_d_gen",  INVALID_AMOMAXU_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b1110000_00000_00000_011_00000_0101111,"invalid_amomaxu_d" ,ALU,R_TYPE,AMO_INVALID)
`AMO_RR_INST(invalid_amoswap_d_gen, "invalid_amoswap_d_gen",  INVALID_AMOSWAP_D ,32'b1111100_00000_00000_111_00000_1111111 ,32'b0000100_00000_00000_011_00000_0101111,"invalid_amoswap_d" ,ALU,R_TYPE,AMO_INVALID)
