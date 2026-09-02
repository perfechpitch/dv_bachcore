class custom_inst_dsar extends riscv_inst;

    parameter CONST_MASK = 32'hfff0707f;
    parameter CONST_VAL  = 32'h0000000b;

    function new(string name="custom_inst_dsar");
        super.new(name);
        `INST_NEW("dsar", CUSTOM, LSU, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_dsar)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rdata;

        rs1_val = `GPR(inst[19:15]);
        rdata = dsa_mmio_lib.read(rs1_val);

        `GPR(inst[11:7]) = rdata;

            `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                "dsar  x%0d=%08h, dsa_io[%08h], x%0d=%08h\n",
                inst[11:7], rdata,
                rs1_val,
                inst[19:15], rs1_val);
    endfunction : inst_exe

endclass : custom_inst_dsar


class custom_inst_dsari extends riscv_inst;

    parameter CONST_MASK = 32'h8000707f;
    parameter CONST_VAL  = 32'h8000000b;

    function new(string name="custom_inst_dsari");
        super.new(name);
        `INST_NEW("dsari", CUSTOM, LSU, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_dsari)

    function void inst_exe(`INST_EXE_PARAS);
        bit [15:0] imm;
        bit [31:0] addr;
        bit [31:0] rdata;

        imm = inst[30:15];
        addr = {16'b0, imm};
        rdata = dsa_mmio_lib.read(addr);

        `GPR(inst[11:7]) = rdata;

        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                "dsari x%0d=%08h, dsa_io[%08h], imm=%04h\n",
                inst[11:7], rdata, addr, imm);
    endfunction : inst_exe

endclass : custom_inst_dsari