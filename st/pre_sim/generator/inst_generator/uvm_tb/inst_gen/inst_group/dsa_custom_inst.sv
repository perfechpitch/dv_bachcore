// DSA custom instructions. The encodings match core_ref/custom/dsar.sv and
// core_ref/custom/dsaw.sv.
class dsa_custom_inst extends base_inst;
    `uvm_object_param_utils(dsa_custom_inst)

    function new(string name = "dsa_custom_inst");
        super.new(name);
    endfunction : new

    function bit[31:0] rand_ops_gen(ops_gen_config ops_gen_cfg);
        bit [4:0]  rs1;
        bit [4:0]  rs2;
        bit [4:0]  rd;
        bit [15:0] imm;

        imm = ops_gen_cfg.rand_imm[15:0];

        case(inst_format)
            DSAR_TYPE: begin
                rs1 = `RAND_RS_GPR;
                rd  = `RAND_RD_GPR;
                return {12'b0, rs1, 3'b0, rd, 7'b0};
            end
            DSARI_TYPE: begin
                rd = `RAND_RD_GPR;
                return {1'b0, imm, 3'b0, rd, 7'b0};
            end
            DSAW_TYPE: begin
                rs1 = `RAND_RS_GPR;
                rs2 = `RAND_RS_GPR;
                return {7'b0, rs2, rs1, 3'b0, 5'b0, 7'b0};
            end
            DSAWI_TYPE: begin
                rs1 = `RAND_RS_GPR;
                return {1'b0, imm[15:5], rs1, 3'b0, imm[4:0], 7'b0};
            end
            default   : return '0;
        endcase
    endfunction : rand_ops_gen

    function void asm_print();
        case(inst_name)
            DSAR: begin
                $fwrite(gen_file,
                        ".insn 0x%08h// %8s\tx%0d, x%0d\n",
                        inst, asm_name, inst[11:7], inst[19:15]);
            end
            DSARI: begin
                $fwrite(gen_file,
                        ".insn 0x%08h// %8s\tx%0d, 0x%0h\n",
                        inst, asm_name, inst[11:7], inst[30:15]);
            end
            DSAW: begin
                $fwrite(gen_file,
                        ".insn 0x%08h// %8s\tx%0d, x%0d\n",
                        inst, asm_name, inst[19:15], inst[24:20]);
            end
            DSAWI: begin
                $fwrite(gen_file,
                        ".insn 0x%08h// %8s\tx%0d, 0x%0h\n",
                        inst, asm_name, inst[19:15],
                        {inst[30:20],inst[11:7]});
            end
        endcase
    endfunction : asm_print
endclass : dsa_custom_inst

class dsar_gen extends dsa_custom_inst;
    localparam bit [31:0] CONST_MASK = 32'hfff0_707f;
    localparam bit [31:0] CONST_VAL  = 32'h0000_000b;

    function new(string name = "dsar_gen");
        super.new(name);
        `INST_GEN_NEW(DSAR, LSU, CONST_MASK, CONST_VAL, "dsar", DSAR_TYPE)
    endfunction : new
    `uvm_object_param_utils(dsar_gen)
endclass : dsar_gen

class dsari_gen extends dsa_custom_inst;
    localparam bit [31:0] CONST_MASK = 32'h8000_707f;
    localparam bit [31:0] CONST_VAL  = 32'h8000_000b;

    function new(string name = "dsari_gen");
        super.new(name);
        `INST_GEN_NEW(DSARI, LSU, CONST_MASK, CONST_VAL, "dsari", DSARI_TYPE)
    endfunction : new
    `uvm_object_param_utils(dsari_gen)
endclass : dsari_gen

class dsaw_gen extends dsa_custom_inst;
    localparam bit [31:0] CONST_MASK = 32'hfe00_7fff;
    localparam bit [31:0] CONST_VAL  = 32'h0000_100b;

    function new(string name = "dsaw_gen");
        super.new(name);
        `INST_GEN_NEW(DSAW, LSU, CONST_MASK, CONST_VAL, "dsaw", DSAW_TYPE)
    endfunction : new
    `uvm_object_param_utils(dsaw_gen)
endclass : dsaw_gen

class dsawi_gen extends dsa_custom_inst;
    localparam bit [31:0] CONST_MASK = 32'h8000_707f;
    localparam bit [31:0] CONST_VAL  = 32'h8000_100b;

    function new(string name = "dsawi_gen");
        super.new(name);
        `INST_GEN_NEW(DSAWI, LSU, CONST_MASK, CONST_VAL, "dsawi", DSAWI_TYPE)
    endfunction : new
    `uvm_object_param_utils(dsawi_gen)
endclass : dsawi_gen
