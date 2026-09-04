class ui_type_inst extends base_inst;
    `uvm_object_param_utils(ui_type_inst)
    function new (string name = "ui_type_inst");
        super.new(name);
    endfunction : new 
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val; 
        bit[4:0] rd; 
        rd = `RAND_RD_GPR; 
        val = {ops_gen_cfg.u_type_imm,rd,7'b0}; 
        return val;
    endfunction 
endclass 

`define UI_INST(A,B,C,D,E,F,G,H)\
class ``A extends ui_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void asm_print(); \
        $fwrite(gen_file,(`U_TYPE_ASM_STRING),`U_TYPE_ASM_VAL);\
    endfunction \
endclass 
`UI_INST(lui_gen, "lui_gen", LUI,32'b0000000_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_0110111, "lui", ALU, U_TYPE)
`UI_INST(auipc_gen, "auipc_gen", AUIPC,32'b0000000_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_0010111, "auipc", ALU, U_TYPE)
