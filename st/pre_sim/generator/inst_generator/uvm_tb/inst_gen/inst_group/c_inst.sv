class c_base_inst extends base_inst;
    bit [15:0] c_bits;
    int unsigned inst_len;
    `uvm_object_utils_begin(c_base_inst)
        `uvm_field_int(c_bits, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(inst_len, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    function new (string name = "c_base_inst");
        super.new(name);
        c_bits = '0;
        inst_len = 2;
    endfunction
endclass

`define C_RAW_INST_CREATE(A, B, C, MASK, FIXED, VALID) \
class A extends c_base_inst; \
    `uvm_object_utils(A) \
    function new (string name = "c_inst"); \
        super.new(name); \
        inst_name = C; \
        asm_name = B; \
    endfunction \
    virtual function bit [31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg); \
        do begin c_bits = ($urandom & MASK) | FIXED; end while (!(VALID)); \
        inst = {16'b0, c_bits}; \
        asm_print(); \
        return inst; \
    endfunction \
    virtual function void asm_print(); \
        $fwrite(gen_file, ".2byte 0x%04h // %s\n", c_bits, asm_name); \
    endfunction \
endclass

class c_addi4spn_gen extends c_base_inst;
    bit[4:0] rd;
    bit[9:0] uimm;
    `uvm_object_utils(c_addi4spn_gen)
    function new (string name = "c_addi4spn_gen");
        super.new(name);
        inst_name = C_ADDI4SPN;
        asm_name = "c.addi4spn";
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        bit[4:0] legal_rd[$];
        `RANDOMIZE_CHECK(ops_gen_cfg, "Error: c.addi4spn ops gen error")
        for(int r = 8; r <= 15; r++)
            if(!reg_pool.is_ls_base_reg(r[4:0]))
                legal_rd.push_back(r[4:0]);
        if(legal_rd.size() == 0) begin
            `uvm_error(`gfn, "C.ADDI4SPN has no non-base x8..x15 destination")
            rd = 5'd8;
        end
        else
            rd = legal_rd[$urandom_range(legal_rd.size()-1)];
        uimm = $urandom_range(255, 1) * 4;
        c_bits = '0;
        c_bits[12:11] = uimm[5:4];
        c_bits[10:7]  = uimm[9:6];
        c_bits[6]     = uimm[2];
        c_bits[5]     = uimm[3];
        c_bits[4:2]   = rd - 5'd8;
        c_bits[1:0]   = 2'b00;
        inst = {16'b0, c_bits};
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // c.addi4spn x%0d, 0x%0h(x2)\n",
                c_bits, rd, uimm);
    endfunction
endclass
class c_lw_gen extends c_base_inst;
    addr_structure_s ls_s;
    `uvm_object_utils(c_lw_gen)
    function new (string name = "c_lw_gen");
        super.new(name);
        inst_name = C_LW;
        asm_name = "c.lw";
    endfunction
    function bit[31:0] build_inst(ref ops_gen_config ops_gen_cfg, input bit use_fixed_imm, input bit[31:0] fixed_imm);
        bit[4:0] rs1, rd;
        bit[6:0] imm;
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg, ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 4;, "Error: c.lw ops gen error")
        ls_s.addr_type = LOAD_VALID;
        rs1 = reg_pool.get_ls_c_base_reg(ls_s);
        do rd = 5'd8 + $urandom_range(7);
        while(reg_pool.is_ls_base_reg(rd));
        if(use_fixed_imm &&
           ls_addr_gen.ls_c_word_imm_fix(fixed_imm, 'h7c, ls_s))
            imm = fixed_imm[6:0];
        else
            imm = ls_addr_gen.get_ls_c_word_imm(ls_s);
        c_bits = '0;
        c_bits[15:13] = 3'b010;
        c_bits[12:10] = imm[5:3];
        c_bits[9:7]   = rs1 - 5'd8;
        c_bits[6]     = imm[2];
        c_bits[5]     = imm[6];
        c_bits[4:2]   = rd - 5'd8;
        c_bits[1:0]   = 2'b00;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        inst = build_inst(ops_gen_cfg, 1'b0, '0);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg, ref bit[31:0] imm);
        inst = build_inst(ops_gen_cfg, 1'b1, imm);
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // c.lw x%0d, 0x%0h(x%0d)\n", c_bits, c_bits[4:2]+8, {c_bits[5],c_bits[12:10],c_bits[6],2'b00}, c_bits[9:7]+8);
    endfunction
endclass

class c_sw_gen extends c_base_inst;
    addr_structure_s ls_s;
    `uvm_object_utils(c_sw_gen)
    function new (string name = "c_sw_gen");
        super.new(name);
        inst_name = C_SW;
        asm_name = "c.sw";
    endfunction
    function bit[31:0] build_inst(ref ops_gen_config ops_gen_cfg, input bit use_fixed_imm, input bit[31:0] fixed_imm);
        bit[4:0] rs1, rs2;
        bit[6:0] imm;
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg, ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 4;, "Error: c.sw ops gen error")
        ls_s.addr_type = LS_VALID;
        rs1 = reg_pool.get_ls_c_base_reg(ls_s);
        rs2 = 5'd8 + $urandom_range(7);
        if(use_fixed_imm && fixed_imm[31:7] == '0 && ls_addr_gen.ls_imm_fix(fixed_imm, ls_s))
            imm = fixed_imm[6:0];
        else
            imm = ls_addr_gen.get_ls_c_word_imm(ls_s);
        c_bits = '0;
        c_bits[15:13] = 3'b110;
        c_bits[12:10] = imm[5:3];
        c_bits[9:7]   = rs1 - 5'd8;
        c_bits[6]     = imm[2];
        c_bits[5]     = imm[6];
        c_bits[4:2]   = rs2 - 5'd8;
        c_bits[1:0]   = 2'b00;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        inst = build_inst(ops_gen_cfg, 1'b0, '0);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg, ref bit[31:0] imm);
        inst = build_inst(ops_gen_cfg, 1'b1, imm);
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // c.sw x%0d, 0x%0h(x%0d)\n", c_bits, c_bits[4:2]+8, {c_bits[5],c_bits[12:10],c_bits[6],2'b00}, c_bits[9:7]+8);
    endfunction
endclass
`C_RAW_INST_CREATE(c_nop_gen,"c.nop",C_NOP,16'h0000,16'h0001,1'b1)
`C_RAW_INST_CREATE(c_addi_gen,"c.addi",C_ADDI,16'h1ffc,16'h0001,((c_bits[11:7] != '0) && (c_bits[11:7] != 5'd2) && !reg_pool.is_ls_base_reg(c_bits[11:7]) && ({c_bits[12],c_bits[6:2]} != '0)))
`C_RAW_INST_CREATE(c_li_gen,"c.li",C_LI,16'h1ffc,16'h4001,((c_bits[11:7] != '0) && (c_bits[11:7] != 5'd2) && !reg_pool.is_ls_base_reg(c_bits[11:7])))
class c_addi16sp_gen extends c_base_inst;
    bit signed [9:0] stack_imm;
    `uvm_object_utils(c_addi16sp_gen)
    function new (string name = "c_addi16sp_gen");
        super.new(name);
        inst_name = C_ADDI16SP;
        asm_name = "c.addi16sp";
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        addr_structure_s sp_s;
        `RANDOMIZE_CHECK(ops_gen_cfg, "Error: c.addi16sp ops gen error")
        void'(reg_pool.get_ls_sp_base(sp_s));
        stack_imm = ls_addr_gen.get_c_addi16sp_imm(sp_s);
        reg_pool.set_ls_sp_base(sp_s);
        c_bits = '0;
        c_bits[15:13] = 3'b011;
        c_bits[12]    = stack_imm[9];
        c_bits[11:7]  = 5'd2;
        c_bits[6]     = stack_imm[4];
        c_bits[5]     = stack_imm[6];
        c_bits[4:3]   = stack_imm[8:7];
        c_bits[2]     = stack_imm[5];
        c_bits[1:0]   = 2'b01;
        inst = {16'b0, c_bits};
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // c.addi16sp x2, %0d\n",
                c_bits, $signed(stack_imm));
    endfunction
endclass
`C_RAW_INST_CREATE(c_lui_gen,"c.lui",C_LUI,16'h1ffc,16'h6001,((c_bits[11:7] != '0) && (c_bits[11:7] != 5'd2) && !reg_pool.is_ls_base_reg(c_bits[11:7]) && ({c_bits[12],c_bits[6:2]} != '0)))
`C_RAW_INST_CREATE(c_srli_gen,"c.srli",C_SRLI,16'h03fc,16'h8001,((c_bits[6:2] != '0) && !reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]})))
`C_RAW_INST_CREATE(c_srai_gen,"c.srai",C_SRAI,16'h03fc,16'h8401,((c_bits[6:2] != '0) && !reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]})))
`C_RAW_INST_CREATE(c_andi_gen,"c.andi",C_ANDI,16'h13fc,16'h8801,!reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]}))
`C_RAW_INST_CREATE(c_sub_gen,"c.sub",C_SUB,16'h039c,16'h8c01,!reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]}))
`C_RAW_INST_CREATE(c_xor_gen,"c.xor",C_XOR,16'h039c,16'h8c21,!reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]}))
`C_RAW_INST_CREATE(c_or_gen,"c.or",C_OR,16'h039c,16'h8c41,!reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]}))
`C_RAW_INST_CREATE(c_and_gen,"c.and",C_AND,16'h039c,16'h8c61,!reg_pool.is_ls_base_reg({2'b01,c_bits[9:7]}))
class c_j_gen extends c_base_inst;
    bit signed [31:0] branch_delta;
    `uvm_object_utils(c_j_gen)
    bit link;
    function new (string name = "c_j_gen");
        super.new(name);
        inst_name = C_J;
        asm_name = "c.j";
        link = 1'b0;
    endfunction
    function bit[31:0] build_inst(ref ops_gen_config ops_gen_cfg, input bit signed [31:0] delta);
        `RANDOMIZE_CHECK(ops_gen_cfg, "Error: c.j ops gen error")
        branch_delta = delta;
        c_bits = '0;
        c_bits[15:13] = link ? 3'b001 : 3'b101;
        c_bits[12]    = delta[11];
        c_bits[11]    = delta[4];
        c_bits[10:9]  = delta[9:8];
        c_bits[8]     = delta[10];
        c_bits[7]     = delta[6];
        c_bits[6]     = delta[7];
        c_bits[5:3]   = delta[3:1];
        c_bits[2]     = delta[5];
        c_bits[1:0]   = 2'b01;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        inst = build_inst(ops_gen_cfg, -2);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg, ref bit[31:0] imm);
        inst = build_inst(ops_gen_cfg, $signed(imm));
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // %s %0d\n",
                c_bits, asm_name, branch_delta);
    endfunction
endclass

class c_jal_gen extends c_j_gen;
    `uvm_object_utils(c_jal_gen)
    function new (string name = "c_jal_gen");
        super.new(name);
        inst_name = C_JAL;
        asm_name = "c.jal";
        link = 1'b1;
    endfunction
endclass

class c_cb_gen extends c_base_inst;
    bit is_bnez;
    bit signed [31:0] branch_delta;
    function new (string name = "c_cb_gen");
        super.new(name);
        is_bnez = 1'b0;
    endfunction
    function bit[31:0] build_inst(ref ops_gen_config ops_gen_cfg, input bit signed [31:0] delta);
        bit[4:0] rs1;
        `RANDOMIZE_CHECK(ops_gen_cfg, "Error: c.b* ops gen error")
        branch_delta = delta;
        rs1 = 5'd8 + $urandom_range(7);
        c_bits = '0;
        c_bits[15:13] = is_bnez ? 3'b111 : 3'b110;
        c_bits[12]    = delta[8];
        c_bits[11:10] = delta[4:3];
        c_bits[9:7]   = rs1 - 5'd8;
        c_bits[6:5]   = delta[7:6];
        c_bits[4:3]   = delta[2:1];
        c_bits[2]     = delta[5];
        c_bits[1:0]   = 2'b01;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        inst = build_inst(ops_gen_cfg, -2);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg, ref bit[31:0] imm);
        inst = build_inst(ops_gen_cfg, $signed(imm));
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // %s x%0d, %0d\n", c_bits, asm_name, c_bits[9:7]+8, branch_delta);
    endfunction
endclass

class c_beqz_gen extends c_cb_gen;
    `uvm_object_utils(c_beqz_gen)
    function new (string name = "c_beqz_gen");
        super.new(name);
        inst_name = C_BEQZ;
        asm_name = "c.beqz";
        is_bnez = 1'b0;
    endfunction
endclass

class c_bnez_gen extends c_cb_gen;
    `uvm_object_utils(c_bnez_gen)
    function new (string name = "c_bnez_gen");
        super.new(name);
        inst_name = C_BNEZ;
        asm_name = "c.bnez";
        is_bnez = 1'b1;
    endfunction
endclass
`C_RAW_INST_CREATE(c_slli_gen,"c.slli",C_SLLI,16'h0ffc,16'h0002,((c_bits[11:7] != '0) && (c_bits[11:7] != 5'd2) && !reg_pool.is_ls_base_reg(c_bits[11:7]) && (c_bits[6:2] != '0)))
class c_lwsp_gen extends c_base_inst;
    addr_structure_s ls_s;
    `uvm_object_utils(c_lwsp_gen)
    function new (string name = "c_lwsp_gen");
        super.new(name);
        inst_name = C_LWSP;
        asm_name = "c.lwsp";
    endfunction
    function bit[31:0] build_inst(ref ops_gen_config ops_gen_cfg,
                                  input bit use_fixed_imm,
                                  input bit[31:0] fixed_imm);
        bit[4:0] rs1, rd;
        bit[7:0] imm;
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,
            ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 4;,
            "Error: c.lwsp ops gen error")
        ls_s.addr_type = LOAD_VALID;
        rs1 = reg_pool.get_ls_sp_base(ls_s);
        rd = reg_pool.get_nonezero_gpr(1'b1);
        if(use_fixed_imm &&
           ls_addr_gen.ls_c_word_imm_fix(fixed_imm, 'hfc, ls_s))
            imm = fixed_imm[7:0];
        else
            imm = ls_addr_gen.get_ls_c_sp_word_imm(ls_s);
        c_bits = '0;
        c_bits[15:13] = 3'b010;
        c_bits[12]    = imm[5];
        c_bits[11:7]  = rd;
        c_bits[6:4]   = imm[4:2];
        c_bits[3:2]   = imm[7:6];
        c_bits[1:0]   = 2'b10;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        inst = build_inst(ops_gen_cfg, 1'b0, '0);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] override_rand_inst(
        ref ops_gen_config ops_gen_cfg, ref bit[31:0] imm);
        inst = build_inst(ops_gen_cfg, 1'b1, imm);
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file,
                ".2byte 0x%04h // c.lwsp x%0d, 0x%0h(x2)\n",
                c_bits, c_bits[11:7],
                {c_bits[3:2],c_bits[12],c_bits[6:4],2'b00});
    endfunction
endclass

class c_jr_base_gen extends c_base_inst;
    bit link;
    bit[4:0] target_reg;
    function new (string name = "c_jr_base_gen");
        super.new(name);
        inst_format = I_TYPE;
        link = 1'b0;
    endfunction
    function bit[31:0] build_inst(input bit[4:0] rs1);
        target_reg = rs1;
        if(rs1 == 0)
            `uvm_error(`gfn, "C.JR/C.JALR target register cannot be x0")
        c_bits = '0;
        c_bits[15:12] = link ? 4'b1001 : 4'b1000;
        c_bits[11:7]  = rs1;
        c_bits[6:2]   = 5'b0;
        c_bits[1:0]   = 2'b10;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        bit[4:0] rs1;
        `RANDOMIZE_CHECK(ops_gen_cfg, "Error: c.jr/c.jalr ops gen error")
        rs1 = reg_pool.get_nonezero_gpr(1'b0);
        inst = build_inst(rs1);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] get_specified_inst(bit[31:0] specified_ops);
        inst = build_inst(specified_ops[19:15]);
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file, ".2byte 0x%04h // %s x%0d\n",
                c_bits, asm_name, target_reg);
    endfunction
endclass

class c_jr_gen extends c_jr_base_gen;
    `uvm_object_utils(c_jr_gen)
    function new (string name = "c_jr_gen");
        super.new(name);
        inst_name = C_JR;
        asm_name = "c.jr";
        link = 1'b0;
    endfunction
endclass

`C_RAW_INST_CREATE(c_mv_gen,"c.mv",C_MV,16'h0ffc,16'h8002,((c_bits[11:7] != '0) && (c_bits[11:7] != 5'd2) && !reg_pool.is_ls_base_reg(c_bits[11:7]) && (c_bits[6:2] != '0)))
`C_RAW_INST_CREATE(c_ebreak_gen,"c.ebreak",C_EBREAK,16'h0000,16'h9002,1'b1)

class c_jalr_gen extends c_jr_base_gen;
    `uvm_object_utils(c_jalr_gen)
    function new (string name = "c_jalr_gen");
        super.new(name);
        inst_name = C_JALR;
        asm_name = "c.jalr";
        link = 1'b1;
    endfunction
endclass

`C_RAW_INST_CREATE(c_add_gen,"c.add",C_ADD,16'h0ffc,16'h9002,((c_bits[11:7] != '0) && (c_bits[11:7] != 5'd2) && !reg_pool.is_ls_base_reg(c_bits[11:7]) && (c_bits[6:2] != '0)))

class c_swsp_gen extends c_base_inst;
    addr_structure_s ls_s;
    `uvm_object_utils(c_swsp_gen)
    function new (string name = "c_swsp_gen");
        super.new(name);
        inst_name = C_SWSP;
        asm_name = "c.swsp";
    endfunction
    function bit[31:0] build_inst(ref ops_gen_config ops_gen_cfg,
                                  input bit use_fixed_imm,
                                  input bit[31:0] fixed_imm);
        bit[4:0] rs1, rs2;
        bit[7:0] imm;
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,
            ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 4;,
            "Error: c.swsp ops gen error")
        ls_s.addr_type = LS_VALID;
        rs1 = reg_pool.get_ls_sp_base(ls_s);
        rs2 = reg_pool.get_gpr(1'b0);
        if(use_fixed_imm &&
           ls_addr_gen.ls_c_word_imm_fix(fixed_imm, 'hfc, ls_s))
            imm = fixed_imm[7:0];
        else
            imm = ls_addr_gen.get_ls_c_sp_word_imm(ls_s);
        c_bits = '0;
        c_bits[15:13] = 3'b110;
        c_bits[12:9]  = imm[5:2];
        c_bits[8:7]   = imm[7:6];
        c_bits[6:2]   = rs2;
        c_bits[1:0]   = 2'b10;
        inst = {16'b0, c_bits};
        return inst;
    endfunction
    virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        inst = build_inst(ops_gen_cfg, 1'b0, '0);
        asm_print();
        return inst;
    endfunction
    virtual function bit[31:0] override_rand_inst(
        ref ops_gen_config ops_gen_cfg, ref bit[31:0] imm);
        inst = build_inst(ops_gen_cfg, 1'b1, imm);
        asm_print();
        return inst;
    endfunction
    virtual function void asm_print();
        $fwrite(gen_file,
                ".2byte 0x%04h // c.swsp x%0d, 0x%0h(x2)\n",
                c_bits, c_bits[6:2],
                {c_bits[8:7],c_bits[12:9],2'b00});
    endfunction
endclass

`define C_COMMON_INST_CREATE \
    `INST_GEN_CREATE(c_addi4spn_gen) \
    `INST_GEN_CREATE(c_lw_gen) \
    `INST_GEN_CREATE(c_sw_gen) \
    `INST_GEN_CREATE(c_nop_gen) \
    `INST_GEN_CREATE(c_addi_gen) \
    `INST_GEN_CREATE(c_li_gen) \
    `INST_GEN_CREATE(c_addi16sp_gen) \
    `INST_GEN_CREATE(c_lui_gen) \
    `INST_GEN_CREATE(c_srli_gen) \
    `INST_GEN_CREATE(c_srai_gen) \
    `INST_GEN_CREATE(c_andi_gen) \
    `INST_GEN_CREATE(c_sub_gen) \
    `INST_GEN_CREATE(c_xor_gen) \
    `INST_GEN_CREATE(c_or_gen) \
    `INST_GEN_CREATE(c_and_gen) \
    `INST_GEN_CREATE(c_j_gen) \
    `INST_GEN_CREATE(c_beqz_gen) \
    `INST_GEN_CREATE(c_bnez_gen) \
    `INST_GEN_CREATE(c_slli_gen) \
    `INST_GEN_CREATE(c_lwsp_gen) \
    `INST_GEN_CREATE(c_jr_gen) \
    `INST_GEN_CREATE(c_mv_gen) \
    `INST_GEN_CREATE(c_ebreak_gen) \
    `INST_GEN_CREATE(c_jalr_gen) \
    `INST_GEN_CREATE(c_add_gen) \
    `INST_GEN_CREATE(c_swsp_gen)
`define C_RV32_ONLY_INST_CREATE \
    `INST_GEN_CREATE(c_jal_gen)
`define C_RV64_ONLY_INST_CREATE
`define RV32C_INST_CREATE \
    `C_COMMON_INST_CREATE \
    `C_RV32_ONLY_INST_CREATE
`define RV64C_INST_CREATE \
    `C_COMMON_INST_CREATE \
    `C_RV64_ONLY_INST_CREATE
