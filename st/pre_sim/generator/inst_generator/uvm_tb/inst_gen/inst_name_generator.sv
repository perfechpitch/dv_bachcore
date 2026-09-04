class inst_name_generator extends uvm_object;
    inst_gen_config inst_gen_cfg;
    rand inst_e inst_name;
    `uvm_object_utils_begin(inst_name_generator)

    `uvm_object_utils_end
    function new (string name = "inst_name_generator");
      super.new(name);
    endfunction : new

    constraint base_c{
        inst_name inside {inst_gen_cfg.support_inst_name};
    }
endclass 
class safe_inst_generator extends inst_name_generator;
//safe branch, safe ls
typedef enum {SAFE_INT_CAL,SAFE_FLOAT_CAL,SAFE_VECTOR_INT,SAFE_VECTOR_FLOAT,SAFE_BRANCH,SAFE_INT_LS} safe_inst_type_e;
//    inst_gen_config 
    csr_config      csr_cfg;
    rand safe_inst_type_e   safe_inst_type;

    int unsigned safe_int_cal_dist = 1;
    int unsigned safe_float_cal_dist = 1;
    int unsigned safe_branch_dist=1;
    int unsigned safe_int_ls_dist=1;
    `uvm_object_utils_begin(safe_inst_generator)
        `uvm_field_int(safe_int_cal_dist,   UVM_DEFAULT)
        `uvm_field_int(safe_float_cal_dist,   UVM_DEFAULT)
        `uvm_field_int(safe_branch_dist,   UVM_DEFAULT)
        `uvm_field_int(safe_int_ls_dist,   UVM_DEFAULT)
        `uvm_field_enum(inst_e,inst_name,               UVM_DEFAULT)
        `uvm_field_enum(safe_inst_type_e,safe_inst_type,UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "safe_inst_generator");
      super.new(name);
    endfunction : new
/*--debug print
    function void post_randomize();
        $display("2:%0h" ,csr_cfg.fs == 0 || !inst_gen_cfg.float_en);
        $display("type :%0s",safe_inst_type);
    endfunction
    */
    constraint safe_inst_type_c{
        safe_inst_type dist{
        SAFE_INT_CAL    := safe_int_cal_dist,
        SAFE_FLOAT_CAL  := ((csr_cfg.fs == 0 || !inst_gen_cfg.float_en) ? 0:safe_float_cal_dist),
        SAFE_INT_LS     := safe_int_ls_dist,
        SAFE_BRANCH     := safe_branch_dist
        };
    }
    constraint solve_c{
        solve safe_inst_type before inst_name;
    }
    constraint safe_inst_name_c{
        (safe_inst_type == SAFE_INT_CAL)-> inst_name inside{
        ADDI,SLTI,SLTIU,XORI,ORI,ANDI,
        SLLI,SRLI,SRAI,ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA,OR,AND,ADDIW,SLLIW,
        SRLIW,SRAIW,ADDW,SUBW,SLLW,SRLW,SRAW,LUI,
        AUIPC,
        MUL,MULH,MULHSU,MULHU,DIV,DIVU,REM,REMU,MULW,
        DIVW,DIVUW,REMW,REMUW
        };
        (safe_inst_type == SAFE_INT_LS)-> inst_name inside{
        INVALID_PREF_I,INVALID_PREF_R,INVALID_PREF_W,//pref no sync except
        PREF_I,PREF_R,PREF_W
        };
        (safe_inst_type == SAFE_BRANCH)-> inst_name inside{
 //branch inst with imm=4 is safe
        JAL,//JALR,
        BEQ,
        BNE,BLT,BGE,BLTU,BGEU
        };

        (safe_inst_type == SAFE_FLOAT_CAL)-> inst_name inside{
        FMADD_D,FMADD_S,FMSUB_D,FMSUB_S,FNMADD_D,FNMADD_S,
        FNMSUB_D,FNMSUB_S,FADD_D,FADD_S,FSUB_D,FSUB_S,FMUL_D,FMUL_S,
        FEQ_D,FEQ_S,FLT_D,FLT_S,FLE_D,FLE_S,FSGNJ_D,FSGNJ_S,FSGNJN_D,FSGNJN_S,FSGNJX_D,FSGNJX_S,
        FCVT_W_S,FCVT_WU_S,FCVT_S_W,FCVT_S_L,FCVT_L_S,FCVT_LU_S,FCVT_S_LU,FCVT_S_WU,FCVT_S_D,
        FCVT_D_S,FCVT_W_D,FCVT_D_W,FCVT_L_D,FCVT_D_L,FCVT_WU_D,FCVT_D_WU,FCVT_LU_D,FCVT_D_LU,
        FCLASS_D,FCLASS_S,FMV_X_W,FMV_W_X,FMV_X_D,FMV_D_X,FSQRT_D,FSQRT_S,FMAX_D,FMAX_S,FMIN_D,FMIN_S,FDIV_D,FDIV_S};

    }
endclass
class branch_inst_generator extends inst_name_generator;
    //branch_seq_config       branch_seq_cfg;
    bit branch_is_jump;
    `uvm_object_utils_begin(branch_inst_generator)
        `uvm_field_enum(inst_e,inst_name,               UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "branch_inst_generator");
      super.new(name);
    endfunction : new
    constraint branch_inst_name_c{
        (branch_is_jump == 0) -> inst_name inside{BEQ,BNE,BLT,BGE,BLTU,BGEU};
        (branch_is_jump == 1) -> inst_name inside{JAL};
        //jalr is special inst. use special reg with special inst seq
    }
endclass
class ls_inst_generator extends inst_name_generator;
typedef enum {LS_LOAD,LS_STORE,LS_AMO,LS_PREF,LS_FENCE,
              LS_FP_LOAD,LS_FP_STORE,LS_VECTOR_LOAD,LS_VECTOR_STORE} ls_inst_type_e;
    csr_config      csr_cfg;
    rand ls_inst_type_e ls_inst_type;
    int unsigned pref_dist = 1;
    int unsigned load_dist = 1;
    int unsigned store_dist = 1;
    int unsigned amo_dist = 1;
    int unsigned fence_dist= 1;
    int unsigned fp_load_dist= 1;
    int unsigned fp_store_dist= 1;
    `uvm_object_utils_begin(ls_inst_generator)
        `uvm_field_enum(ls_inst_type_e,ls_inst_type,    UVM_DEFAULT)
        `uvm_field_enum(inst_e,inst_name,               UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_inst_generator");
      super.new(name);
    endfunction : new
    constraint ls_inst_type_c{
        ls_inst_type dist{
        LS_PREF := pref_dist,
        LS_LOAD := load_dist,
        LS_STORE:= store_dist,
        LS_FP_LOAD := ((csr_cfg.fs == 0 || !inst_gen_cfg.float_en ) ? 0:fp_load_dist),
        LS_FP_STORE:= ((csr_cfg.fs == 0 || !inst_gen_cfg.float_en ) ? 0:fp_store_dist),
        LS_AMO  := ((RV64A inside inst_gen_cfg.support_inst_set)?amo_dist:0),
        LS_FENCE:= fence_dist
        };
    }
 constraint ls_inst_name_c{
        (ls_inst_type == LS_PREF) -> inst_name inside{PREF_I,PREF_R,PREF_W,INVALID_PREF_I,INVALID_PREF_R,INVALID_PREF_W};
        (ls_inst_type == LS_LOAD) -> inst_name inside{LB,LH,LW,LD,LBU,LHU,LWU};
        (ls_inst_type == LS_STORE) -> inst_name inside{SB,SH,SW,SD};
        (ls_inst_type == LS_FP_LOAD ) -> inst_name inside{FLW,FLD};
        (ls_inst_type == LS_FP_STORE) -> inst_name inside{FSW,FSD};
        (ls_inst_type == LS_AMO) -> inst_name inside{LR_W,LR_D,SC_W,SC_D,
                                                     AMOSWAP_W,AMOADD_W,AMOXOR_W,
                                                     AMOOR_W,AMOAND_W,AMOMIN_W,
                                                     AMOMAX_W,AMOMINU_W,AMOMAXU_W,
                                                     AMOSWAP_D,AMOADD_D,AMOXOR_D,
                                                     AMOOR_D,AMOAND_D,
                                                     AMOMIN_D,AMOMAX_D,
                                                     AMOMINU_D,AMOMAXU_D};
        (ls_inst_type == LS_FENCE) -> inst_name inside{FENCE};
        }
endclass
//TODO: special inst dist add special inst name
class flush_inst_generator extends inst_name_generator;
    typedef enum {CSR_INST,MRET_INST,FENCEI_INST}flush_inst_type_e;

    rand flush_inst_type_e  flush_inst_type;

    `uvm_object_utils_begin(flush_inst_generator)
        `uvm_field_enum (inst_e, inst_name, UVM_DEFAULT)
        `uvm_field_enum (flush_inst_type_e, flush_inst_type, UVM_DEFAULT)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "flush_inst_generator");
      super.new(name);
    endfunction : new

    constraint inst_name_c{
        inst_name inside{CSRRC,CSRRCI,CSRRS,CSRRSI,CSRRW,CSRRWI,MRET,FENCEI};
    };
endclass
//TODO: special inst dist add special inst name
class except_inst_generator extends inst_name_generator;
    typedef enum {EBREAK_INST,ECALL_INST,DRET_INST,
                  BRANCH_MISALIGN, JUMP_MISALIGN,
                  LS_EXCEPT_INST,RI_INST}except_inst_type_e;

    rand except_inst_type_e except_inst_type;
    int unsigned ebreak_inst_dist     = 1;
    int unsigned ecall_inst_dist      = 1;
    int unsigned dret_inst_dist       = 1;
    int unsigned branch_misalign_dist = 1;
    int unsigned ls_except_inst_dist  = 1;
    int unsigned ri_inst_dist         = 1;

    // special inst dist add special inst name
    `uvm_object_utils_begin(except_inst_generator)
        `uvm_field_enum (inst_e, inst_name, UVM_DEFAULT)
        `uvm_field_enum (except_inst_type_e, except_inst_type, UVM_DEFAULT)
        `uvm_field_int  (ebreak_inst_dist     , UVM_DEFAULT)
        `uvm_field_int  (ecall_inst_dist      , UVM_DEFAULT)
        `uvm_field_int  (dret_inst_dist       , UVM_DEFAULT)
        `uvm_field_int  (branch_misalign_dist , UVM_DEFAULT)
        `uvm_field_int  (ls_except_inst_dist  , UVM_DEFAULT)
        `uvm_field_int  (ri_inst_dist         , UVM_DEFAULT)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "except_inst_generator");
      super.new(name);
    endfunction : new

 //TODO: gen except_inst_type first
    constraint inst_type_c{
        except_inst_type dist{
            EBREAK_INST     := ebreak_inst_dist     ,
            ECALL_INST      := ecall_inst_dist      ,
            DRET_INST       := dret_inst_dist       ,
            BRANCH_MISALIGN := branch_misalign_dist ,
            LS_EXCEPT_INST  := ls_except_inst_dist  ,
            RI_INST         := ri_inst_dist
            //EBREAK_INST     := ebreak_dist,
            //ECALL_DIST      := ecall_dist,
            //DRET_DIST       := dret_dist,
            //BRANCH_MISALIGN := branch_misalign_dist,
            //LS_EXCEPT_INST  := ls_except_dist,
            //RI_INST         := ri_dist
        };
    }
    constraint inst_name_c{
        except_inst_type == EBREAK_INST -> inst_name == EBREAK;
        except_inst_type == ECALL_INST -> inst_name == ECALL;
        except_inst_type == DRET_INST -> inst_name == DRET;
        except_inst_type == BRANCH_MISALIGN -> inst_name inside{MISALIGN_BEQ,MISALIGN_BNE,MISALIGN_BGE,MISALIGN_BLT,MISALIGN_BLTU,MISALIGN_BGEU};
        except_inst_type == LS_EXCEPT_INST       -> inst_name inside{INVALID_LB,INVALID_LH,INVALID_LW,INVALID_LD,INVALID_LBU,INVALID_LHU,INVALID_LWU,INVALID_FLW,INVALID_FLD,    // invalid_load
                                                                INVALID_FSW,INVALID_FSD,INVALID_SB ,INVALID_SH ,INVALID_SW ,INVALID_SD, //invalid_store
                                                                INVALID_LR_W,INVALID_SC_W,INVALID_LR_D,INVALID_SC_D, // invalid lrsc
                                                                INVALID_AMOSWAP_W,INVALID_AMOADD_W,INVALID_AMOXOR_W,
                                                                INVALID_AMOOR_W,INVALID_AMOAND_W,INVALID_AMOMIN_W,
                                                                INVALID_AMOMAX_W,INVALID_AMOMINU_W,INVALID_AMOMAXU_W,
                                                                INVALID_AMOSWAP_D,INVALID_AMOADD_D,INVALID_AMOXOR_D,
                                                                INVALID_AMOOR_D,INVALID_AMOAND_D,
                                                                INVALID_AMOMIN_D,INVALID_AMOMAX_D,
                                                                INVALID_AMOMINU_D,INVALID_AMOMAXU_D // invalid amo
        };
//except_inst_type == RI_INST ->inst_name inside{'d0};//TODO
        except_inst_type == RI_INST ->inst_name ==RI;//TODO
    }
endclass
