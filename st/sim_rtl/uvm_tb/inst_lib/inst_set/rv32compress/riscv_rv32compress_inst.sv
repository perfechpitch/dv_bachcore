// RV32C arithmetic instructions:
// c.addi4spn, c.nop, c.addi, c.li, c.addi16sp, c.lui
// c.srli, c.srai, c.andi, c.sub, c.xor, c.or, c.and
// c.slli, c.mv, c.add

class riscv_c_addi4spn extends riscv_inst;
    function new(string name = "riscv_c_addi4spn");
        super.new(name);
        `INST_NEW("c_addi4spn", RV32C, ALU,
                  16'b111_00000000_000_11,
                  16'b000_00000000_000_00)
    endfunction : new

    `uvm_object_utils(riscv_c_addi4spn)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] imm;
        bit [31:0] rs1_val;

        rs1_val = `GPR(5'd2);
        imm = {22'b0, inst[10:7], inst[12:11], inst[5], inst[6], 2'b00};

        if(imm != 0) begin
            `GPR({2'b01, inst[4:2]}) = rs1_val + imm;
            `C_PC_ADD
        end
        else
            core_state.except = ILLEGAL_INST;

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], imm=0x%08h\n",
                    inst_name,
                    {2'b01, inst[4:2]}, `GPR({2'b01, inst[4:2]}),
                    5'd2, rs1_val,
                    imm);
    endfunction : inst_exe
endclass : riscv_c_addi4spn

class riscv_c_nop extends riscv_inst;
    function new(string name = "riscv_c_nop");
        super.new(name);
        `INST_NEW("c_nop", RV32C, ALU, 16'hffff, 16'h0001)
    endfunction : new

    `uvm_object_utils(riscv_c_nop)

    function void inst_exe(`INST_EXE_PARAS);
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, "%8s\n", inst_name);
    endfunction : inst_exe
endclass : riscv_c_nop

class riscv_c_addi extends riscv_inst;
    function new(string name = "riscv_c_addi");
        super.new(name);
        `INST_NEW("c_addi", RV32C, ALU,
                  16'b111_0_00000_00000_11,
                  16'b000_0_00000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_addi)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] imm;
        bit [31:0] rs1_val;

        rs1_val = `GPR(inst[11:7]);
        imm = {{26{inst[12]}}, inst[12], inst[6:2]};

        if(inst[11:7] != 0)
            `GPR(inst[11:7]) = rs1_val + imm;

        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], imm=0x%08h\n",
                    inst_name,
                    inst[11:7], `GPR(inst[11:7]),
                    inst[11:7], rs1_val,
                    imm);
    endfunction : inst_exe
endclass : riscv_c_addi

class riscv_c_li extends riscv_inst;
    function new(string name = "riscv_c_li");
        super.new(name);
        `INST_NEW("c_li", RV32C, ALU,
                  16'b111_0_00000_00000_11,
                  16'b010_0_00000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_li)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] imm;

        imm = {{26{inst[12]}}, inst[12], inst[6:2]};

        if(inst[11:7] != 0)
            `GPR(inst[11:7]) = imm;

        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], imm=0x%08h\n",
                    inst_name,
                    inst[11:7], `GPR(inst[11:7]),
                    imm);
    endfunction : inst_exe
endclass : riscv_c_li

class riscv_c_addi16sp extends riscv_inst;
    function new(string name = "riscv_c_addi16sp");
        super.new(name);
        `INST_NEW("c_addi16sp", RV32C, ALU,
                  16'b111_0_11111_00000_11,
                  16'b011_0_00010_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_addi16sp)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] imm;
        bit [31:0] rs1_val;

        rs1_val = `GPR(5'd2);
        imm = {{22{inst[12]}}, inst[12], inst[4:3], inst[5], inst[2], inst[6], 4'b0};

        if(imm == 0)
            core_state.except = ILLEGAL_INST;
        else begin
            `GPR(5'd2) = rs1_val + imm;
            `C_PC_ADD
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x2[0x%08h], rs1:x2[0x%08h], imm=0x%08h\n",
                    inst_name,
                    `GPR(5'd2),
                    rs1_val,
                    imm);
    endfunction : inst_exe
endclass : riscv_c_addi16sp

class riscv_c_lui extends riscv_inst;
    function new(string name = "riscv_c_lui");
        super.new(name);
        `INST_NEW("c_lui", RV32C, ALU,
                  16'b111_0_00000_00000_11,
                  16'b011_0_00000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_lui)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] imm;

        imm = {{14{inst[12]}}, inst[12], inst[6:2], 12'b0};

        if(inst[11:7] == 0 || inst[11:7] == 5'd2 || imm == 0)
            core_state.except = ILLEGAL_INST;
        else begin
            `GPR(inst[11:7]) = imm;
            `C_PC_ADD
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], imm=0x%08h\n",
                    inst_name,
                    inst[11:7], `GPR(inst[11:7]),
                    imm);
    endfunction : inst_exe
endclass : riscv_c_lui

class riscv_c_andi extends riscv_inst;
    function new(string name = "riscv_c_andi");
        super.new(name);
        `INST_NEW("c_andi", RV32C, ALU,
                  16'b111_0_11_000_00000_11,
                  16'b100_0_10_000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_andi)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] imm;
        bit [31:0] rs1_val;
        bit [4:0] rd_idx;

        rd_idx = {2'b01, inst[9:7]};
        rs1_val = `GPR(rd_idx);
        imm = {{26{inst[12]}}, inst[12], inst[6:2]};

        `GPR(rd_idx) = rs1_val & imm;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], imm=0x%08h\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    imm);
    endfunction : inst_exe
endclass : riscv_c_andi

class riscv_c_sub extends riscv_inst;
    function new(string name = "riscv_c_sub");
        super.new(name);
        `INST_NEW("c_sub", RV32C, ALU,
                  16'b111_1_11_000_11_000_11,
                  16'b100_0_11_000_00_000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_sub)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        bit [4:0] rd_idx;
        bit [4:0] rs2_idx;

        rd_idx = {2'b01, inst[9:7]};
        rs2_idx = {2'b01, inst[4:2]};
        rs1_val = `GPR(rd_idx);
        rs2_val = `GPR(rs2_idx);

        `GPR(rd_idx) = rs1_val - rs2_val;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], rs2:x%0d[0x%08h]\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    rs2_idx, rs2_val);
    endfunction : inst_exe
endclass : riscv_c_sub

class riscv_c_xor extends riscv_inst;
    function new(string name = "riscv_c_xor");
        super.new(name);
        `INST_NEW("c_xor", RV32C, ALU,
                  16'b111_1_11_000_11_000_11,
                  16'b100_0_11_000_01_000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_xor)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        bit [4:0] rd_idx;
        bit [4:0] rs2_idx;

        rd_idx = {2'b01, inst[9:7]};
        rs2_idx = {2'b01, inst[4:2]};
        rs1_val = `GPR(rd_idx);
        rs2_val = `GPR(rs2_idx);

        `GPR(rd_idx) = rs1_val ^ rs2_val;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], rs2:x%0d[0x%08h]\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    rs2_idx, rs2_val);
    endfunction : inst_exe
endclass : riscv_c_xor

class riscv_c_or extends riscv_inst;
    function new(string name = "riscv_c_or");
        super.new(name);
        `INST_NEW("c_or", RV32C, ALU,
                  16'b111_1_11_000_11_000_11,
                  16'b100_0_11_000_10_000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_or)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        bit [4:0] rd_idx;
        bit [4:0] rs2_idx;

        rd_idx = {2'b01, inst[9:7]};
        rs2_idx = {2'b01, inst[4:2]};
        rs1_val = `GPR(rd_idx);
        rs2_val = `GPR(rs2_idx);

        `GPR(rd_idx) = rs1_val | rs2_val;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], rs2:x%0d[0x%08h]\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    rs2_idx, rs2_val);
    endfunction : inst_exe
endclass : riscv_c_or

class riscv_c_and extends riscv_inst;
    function new(string name = "riscv_c_and");
        super.new(name);
        `INST_NEW("c_and", RV32C, ALU,
                  16'b111_1_11_000_11_000_11,
                  16'b100_0_11_000_11_000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_and)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        bit [4:0] rd_idx;
        bit [4:0] rs2_idx;

        rd_idx = {2'b01, inst[9:7]};
        rs2_idx = {2'b01, inst[4:2]};
        rs1_val = `GPR(rd_idx);
        rs2_val = `GPR(rs2_idx);

        `GPR(rd_idx) = rs1_val & rs2_val;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], rs2:x%0d[0x%08h]\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    rs2_idx, rs2_val);
    endfunction : inst_exe
endclass : riscv_c_and

class riscv_c_srli extends riscv_inst;
    function new(string name = "riscv_c_srli");
        super.new(name);
        `INST_NEW("c_srli", RV32C, ALU,
                  16'b111_1_11_000_00000_11,
                  16'b100_0_00_000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_srli)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [4:0] rd_idx;
        bit [4:0] shamt;

        rd_idx = {2'b01, inst[9:7]};
        shamt = inst[6:2];
        rs1_val = `GPR(rd_idx);

        `GPR(rd_idx) = rs1_val >> shamt;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], shamt=0x%02h\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    shamt);
    endfunction : inst_exe
endclass : riscv_c_srli

class riscv_c_srai extends riscv_inst;
    function new(string name = "riscv_c_srai");
        super.new(name);
        `INST_NEW("c_srai", RV32C, ALU,
                  16'b111_1_11_000_00000_11,
                  16'b100_0_01_000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_srai)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [4:0] rd_idx;
        bit [4:0] shamt;

        rd_idx = {2'b01, inst[9:7]};
        shamt = inst[6:2];
        rs1_val = `GPR(rd_idx);

        `GPR(rd_idx) = $signed(rs1_val) >>> shamt;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], shamt=0x%02h\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    shamt);
    endfunction : inst_exe
endclass : riscv_c_srai

class riscv_c_slli extends riscv_inst;
    function new(string name = "riscv_c_slli");
        super.new(name);
        `INST_NEW("c_slli", RV32C, ALU,
                  16'b111_1_00000_00000_11,
                  16'b000_0_00000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_slli)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [4:0] rd_idx;
        bit [4:0] shamt;

        rd_idx = inst[11:7];
        shamt = inst[6:2];
        rs1_val = `GPR(rd_idx);

        `GPR(rd_idx) = rs1_val << shamt;
        `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], shamt=0x%02h\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    rd_idx, rs1_val,
                    shamt);
    endfunction : inst_exe
endclass : riscv_c_slli

class riscv_c_mv extends riscv_inst;
    function new(string name = "riscv_c_mv");
        super.new(name);
        `INST_NEW("c_mv", RV32C, ALU,
                  16'b111_1_00000_00000_11,
                  16'b100_0_00000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_mv)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs2_val;

        rs2_val = `GPR(inst[6:2]);

        if(inst[11:7] == 0 || inst[6:2] == 0)
            core_state.except = ILLEGAL_INST;
        else begin
            `GPR(inst[11:7]) = rs2_val;
            `C_PC_ADD
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs2:x%0d[0x%08h]\n",
                    inst_name,
                    inst[11:7], `GPR(inst[11:7]),
                    inst[6:2], rs2_val);
    endfunction : inst_exe
endclass : riscv_c_mv

class riscv_c_add extends riscv_inst;
    function new(string name = "riscv_c_add");
        super.new(name);
        `INST_NEW("c_add", RV32C, ALU,
                  16'b111_1_00000_00000_11,
                  16'b100_1_00000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_add)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;

        rs1_val = `GPR(inst[11:7]);
        rs2_val = `GPR(inst[6:2]);

        if(inst[11:7] == 0 || inst[6:2] == 0)
            core_state.except = ILLEGAL_INST;
        else begin
            `GPR(inst[11:7]) = rs1_val + rs2_val;
            `C_PC_ADD
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], rs1:x%0d[0x%08h], rs2:x%0d[0x%08h]\n",
                    inst_name,
                    inst[11:7], `GPR(inst[11:7]),
                    inst[11:7], rs1_val,
                    inst[6:2], rs2_val);
    endfunction : inst_exe
endclass : riscv_c_add

// c.beqz
class riscv_c_beqz extends riscv_inst;
    function new(string name = "riscv_c_beqz");
        super.new(name);
        `INST_NEW("c_beqz", RV32C, BEU,
                  16'b111_000_000_00000_11,
                  16'b110_000_000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_beqz)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] target_pc;
        bit taken;
        bit [4:0] rs1_idx;

        rs1_idx = {2'b01, inst[9:7]};
        rs1_val = `GPR(rs1_idx);
        target_pc = core_state.pc +
                    {{23{inst[12]}}, inst[12], inst[6:5], inst[2],
                     inst[11:10], inst[4:3], 1'b0};
        taken = (rs1_val == 32'h0);

        if(taken)
            core_state.pc = target_pc;
        else
            `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trs1:x%0d[0x%08h], target=0x%08h, taken=%0d\n",
                    inst_name, rs1_idx, rs1_val, target_pc, taken);
    endfunction : inst_exe
endclass : riscv_c_beqz

// c.bnez
class riscv_c_bnez extends riscv_inst;
    function new(string name = "riscv_c_bnez");
        super.new(name);
        `INST_NEW("c_bnez", RV32C, BEU,
                  16'b111_000_000_00000_11,
                  16'b111_000_000_00000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_bnez)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] target_pc;
        bit taken;
        bit [4:0] rs1_idx;

        rs1_idx = {2'b01, inst[9:7]};
        rs1_val = `GPR(rs1_idx);
        target_pc = core_state.pc +
                    {{23{inst[12]}}, inst[12], inst[6:5], inst[2],
                     inst[11:10], inst[4:3], 1'b0};
        taken = (rs1_val != 32'h0);

        if(taken)
            core_state.pc = target_pc;
        else
            `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trs1:x%0d[0x%08h], target=0x%08h, taken=%0d\n",
                    inst_name, rs1_idx, rs1_val, target_pc, taken);
    endfunction : inst_exe
endclass : riscv_c_bnez

// c.lw
class riscv_c_lw extends riscv_inst;
    function new(string name = "riscv_c_lw");
        super.new(name);
        `INST_NEW("c_lw", RV32C, LSU,
                  16'b111_000_000_00_000_11,
                  16'b010_000_000_00_000_00)
    endfunction : new

    `uvm_object_utils(riscv_c_lw)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rdata;
        bit [31:0] rs1_val;
        bit [31:0] imm;
        bit [4:0] rd_idx;
        bit [4:0] rs1_idx;
        addr_state_s addr_state;

        rd_idx = {2'b01, inst[4:2]};
        rs1_idx = {2'b01, inst[9:7]};
        rs1_val = `GPR(rs1_idx);
        imm = {25'b0, inst[5], inst[12:10], inst[6], 2'b00};

        addr_state.addr = rs1_val + imm;
        addr_state.acc_type = LOAD;
        addr_state.size = 2'd2;
        rdata = mem_lib.read_mem(core_state, addr_state);

        if(core_state.except == NONE_EXCEPT) begin
            `GPR(rd_idx) = rdata;
            `C_PC_ADD
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], addr=0x%08h\n",
                    inst_name,
                    rd_idx, `GPR(rd_idx),
                    addr_state.addr);
    endfunction : inst_exe
endclass : riscv_c_lw

// c.lwsp
class riscv_c_lwsp extends riscv_inst;
    function new(string name = "riscv_c_lwsp");
        super.new(name);
        `INST_NEW("c_lwsp", RV32C, LSU,
                  16'b111_0_00000_00000_11,
                  16'b010_0_00000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_lwsp)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rdata;
        bit [31:0] rs1_val;
        bit [31:0] imm;
        addr_state_s addr_state;

        if(inst[11:7] == 0) begin
            core_state.except = ILLEGAL_INST;
            return;
        end

        rs1_val = `GPR(5'd2);
        imm = {24'b0, inst[3:2], inst[12], inst[6:4], 2'b00};

        addr_state.addr = rs1_val + imm;
        addr_state.acc_type = LOAD;
        addr_state.size = 2'd2;
        rdata = mem_lib.read_mem(core_state, addr_state);

        if(core_state.except == NONE_EXCEPT) begin
            `GPR(inst[11:7]) = rdata;
            `C_PC_ADD
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x%0d[0x%08h], addr=0x%08h\n",
                    inst_name,
                    inst[11:7], `GPR(inst[11:7]),
                    addr_state.addr);
    endfunction : inst_exe
endclass : riscv_c_lwsp

// c.sw
class riscv_c_sw extends riscv_inst;
    function new(string name = "riscv_c_sw");
        super.new(name);
        `INST_NEW("c_sw", RV32C, LSU,
                  16'b111_000_000_00_000_11,
                  16'b110_000_000_00_000_00)
    endfunction : new

    `uvm_object_utils(riscv_c_sw)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        bit [31:0] imm;
        bit [4:0] rs1_idx;
        bit [4:0] rs2_idx;
        addr_state_s addr_state;

        rs1_idx = {2'b01, inst[9:7]};
        rs2_idx = {2'b01, inst[4:2]};
        rs1_val = `GPR(rs1_idx);
        rs2_val = `GPR(rs2_idx);
        imm = {25'b0, inst[5], inst[12:10], inst[6], 2'b00};

        addr_state.addr = rs1_val + imm;
        addr_state.acc_type = STORE;
        addr_state.size = 2'd2;
        mem_lib.write_mem(rs2_val, core_state, addr_state);

        if(core_state.except == NONE_EXCEPT)
            `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trs2:x%0d[0x%08h], addr=0x%08h\n",
                    inst_name,
                    rs2_idx, rs2_val,
                    addr_state.addr);
    endfunction : inst_exe
endclass : riscv_c_sw

// c.swsp
class riscv_c_swsp extends riscv_inst;
    function new(string name = "riscv_c_swsp");
        super.new(name);
        `INST_NEW("c_swsp", RV32C, LSU,
                  16'b111_000000_00000_11,
                  16'b110_000000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_swsp)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        bit [31:0] imm;
        addr_state_s addr_state;

        rs1_val = `GPR(5'd2);
        rs2_val = `GPR(inst[6:2]);
        imm = {24'b0, inst[8:7], inst[12:9], 2'b00};

        addr_state.addr = rs1_val + imm;
        addr_state.acc_type = STORE;
        addr_state.size = 2'd2;
        mem_lib.write_mem(rs2_val, core_state, addr_state);

        if(core_state.except == NONE_EXCEPT)
            `C_PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trs2:x%0d[0x%08h], addr=0x%08h\n",
                    inst_name,
                    inst[6:2], rs2_val,
                    addr_state.addr);
    endfunction : inst_exe
endclass : riscv_c_swsp

// c.j
class riscv_c_j extends riscv_inst;
    function new(string name = "riscv_c_j");
        super.new(name);
        `INST_NEW("c_j", RV32C, BEU,
                  16'b111_00000000000_11,
                  16'b101_00000000000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_j)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] target_pc;

        target_pc = core_state.pc +
                    {{20{inst[12]}}, inst[12], inst[8], inst[10:9],
                     inst[6], inst[7], inst[2], inst[11],
                     inst[5:3], 1'b0};
        core_state.pc = target_pc;

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\ttarget=0x%08h\n",
                    inst_name, target_pc);
    endfunction : inst_exe
endclass : riscv_c_j

// c.jal
class riscv_c_jal extends riscv_inst;
    function new(string name = "riscv_c_jal");
        super.new(name);
        `INST_NEW("c_jal", RV32C, BEU,
                  16'b111_00000000000_11,
                  16'b001_00000000000_01)
    endfunction : new

    `uvm_object_utils(riscv_c_jal)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] next_pc;
        bit [31:0] target_pc;

        next_pc = core_state.pc + 32'd2;
        target_pc = core_state.pc +
                    {{20{inst[12]}}, inst[12], inst[8], inst[10:9],
                     inst[6], inst[7], inst[2], inst[11],
                     inst[5:3], 1'b0};

        `GPR(5'd1) = next_pc;
        core_state.pc = target_pc;

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x1[0x%08h], target=0x%08h\n",
                    inst_name, `GPR(5'd1), target_pc);
    endfunction : inst_exe
endclass : riscv_c_jal

// c.jr
class riscv_c_jr extends riscv_inst;
    function new(string name = "riscv_c_jr");
        super.new(name);
        `INST_NEW("c_jr", RV32C, BEU,
                  16'b111_1_00000_11111_11,
                  16'b100_0_00000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_jr)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] target_pc;

        rs1_val = `GPR(inst[11:7]);
        target_pc = rs1_val & 32'hffff_fffe;

        if(inst[11:7] == 0)
            core_state.except = ILLEGAL_INST;
        else
            core_state.pc = target_pc;

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trs1:x%0d[0x%08h], target=0x%08h\n",
                    inst_name,
                    inst[11:7], rs1_val,
                    target_pc);
    endfunction : inst_exe
endclass : riscv_c_jr

// c.jalr
class riscv_c_jalr extends riscv_inst;
    function new(string name = "riscv_c_jalr");
        super.new(name);
        `INST_NEW("c_jalr", RV32C, BEU,
                  16'b111_1_00000_11111_11,
                  16'b100_1_00000_00000_10)
    endfunction : new

    `uvm_object_utils(riscv_c_jalr)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] target_pc;
        bit [31:0] next_pc;

        rs1_val = `GPR(inst[11:7]);
        target_pc = rs1_val & 32'hffff_fffe;
        next_pc = core_state.pc + 32'd2;

        if(inst[11:7] == 0)
            core_state.except = ILLEGAL_INST;
        else begin
            `GPR(5'd1) = next_pc;
            core_state.pc = target_pc;
        end

        if(log_en)
            $fwrite(inst_exe_log,
                    "%8s\trd:x1[0x%08h], rs1:x%0d[0x%08h], target=0x%08h\n",
                    inst_name,
                    `GPR(5'd1),
                    inst[11:7], rs1_val,
                    target_pc);
    endfunction : inst_exe
endclass : riscv_c_jalr

// c.ebreak
class riscv_c_ebreak extends riscv_inst;
    function new(string name = "riscv_c_ebreak");
        super.new(name);
        `INST_NEW("c_ebreak", RV32C, ROB, 16'hffff, 16'h9002)
    endfunction : new

    `uvm_object_utils(riscv_c_ebreak)

    function void inst_exe(`INST_EXE_PARAS);
        core_state.except = BREAKPOINT;

        if(log_en)
            $fwrite(inst_exe_log, "%8s\n", inst_name);
    endfunction : inst_exe
endclass : riscv_c_ebreak