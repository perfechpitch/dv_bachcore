class jal_gen extends base_inst;
    parameter CONST_MASK = 32'b0000000_00000_00000_000_00000_1111111;
    parameter CONST_VAL  = 32'b0000000_00000_00000_000_00000_1101111;
    // new - constructor 
    function new (string name = "jal_gen");
        super.new(name); 
        `INST_GEN_NEW(JAL,ALU,CONST_MASK,CONST_VAL,"jal",J_TYPE);
    endfunction : new 
    `uvm_object_param_utils(jal_gen) 
    function void ops_gen_cfg_rand(ref ops_gen_config   ops_gen_cfg);
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,rand_imm == 4;,"Error: jal inst ops gen error")
    endfunction
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val;
        bit[20:0] imm;
        bit[4:0] rd;
        rd = `RAND_RD_GPR;
        imm = ops_gen_cfg.rand_imm;
        val = {imm[20],imm[10:1],imm[11],imm[19:12],rd,7'b0};
        //$display("imm = %0h, val = %0h",imm,val);
        return val; 
    endfunction
    function bit [31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg,ref bit[31:0] imm);
        bit[31:0] rand_ops; 
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,rand_imm == imm;,"Error: jal inst ops gen error")
        rand_ops = rand_ops_gen(ops_gen_cfg); 
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & rand_ops;
     //   $display("inst = %0h",inst);
        asm_print(); 
        return inst;
    endfunction 
    function void asm_print(); 
        $fwrite(gen_file,(`J_TYPE_ASM_STRING),`J_TYPE_ASM_VAL);
    endfunction
endclass 
class misalign_jal_gen extends base_inst;       
    parameter CONST_MASK = 32'b0000000_00000_00000_000_00000_1111111;
    parameter CONST_VAL  = 32'b0000000_00000_00000_000_00000_1101111;
    // new - constructor 
    function new (string name = "misalign_jal_gen");
        super.new(name); 
        `INST_GEN_NEW(MISALIGN_JAL,ALU,CONST_MASK,CONST_VAL,"jal",J_TYPE);
    endfunction : new 
    `uvm_object_param_utils(misalign_jal_gen)
    function void ops_gen_cfg_rand(ref ops_gen_config   ops_gen_cfg);
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,rand_imm[1:0] != 0 ;,"Error: jal inst ops gen error")
    endfunction
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val;
        bit[20:0] imm;
        bit[4:0] rd;
        rd = `RAND_RD_GPR;
        imm = ops_gen_cfg.rand_imm;
        val = {imm[20],imm[10:1],imm[11],imm[19:12],rd,7'b0};
        return val;
    endfunction
    function bit [31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg,ref bit[31:0] imm);
        bit[31:0] rand_ops;
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,rand_imm == imm;,"Error: jal inst ops gen error")
        rand_ops = rand_ops_gen(ops_gen_cfg);
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & rand_ops;
        asm_print();
        return inst;
    endfunction
    function void asm_print();
        $fwrite(gen_file,(`J_TYPE_ASM_STRING),`J_TYPE_ASM_VAL);
    endfunction
endclass
class jalr_gen extends base_inst;
    parameter CONST_MASK = 32'b0000000_00000_00000_111_00000_1111111;
    parameter CONST_VAL  = 32'b0000000_00000_00000_000_00000_1100111;
    // new - constructor 
    function new (string name = "jalr_gen");
        super.new(name);
        `INST_GEN_NEW(JALR,ALU,CONST_MASK,CONST_VAL,"jalr",I_TYPE);
    endfunction : new
    `uvm_object_param_utils(jalr_gen)
    function void asm_print();
        $fwrite(gen_file,(`I_TYPE_ASM_STRING),`I_TYPE_ASM_VAL);
    endfunction
endclass
