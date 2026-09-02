class custom_inst_dsaw extends riscv_inst;

    parameter CONST_MASK = 32'hfe007fff;
    parameter CONST_VAL  = 32'h0000100b;

    function new(string name="custom_inst_dsaw");
        super.new(name);
        `INST_NEW("dsaw", CUSTOM, LSU, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_dsaw)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [31:0] rs2_val;
        dsa_req_s req;

        rs1_val = `GPR(inst[19:15]);
        rs2_val = `GPR(inst[24:20]);

        dsa_mmio_lib.write(rs1_val, rs2_val);
        req = '{1'b1, rs1_val, rs2_val,
            csr_lib.stream_id.val[3:0], csr_lib.task_id.val[5:0],
            csr_lib.user_id.val[15:0], csr_lib.path_id.val[5:0],
            csr_lib.vc_id.val[1:0]};
        dsa_mmio_lib.trace_req(req);

        `PC_ADD
        if(log_en)
            $fwrite(inst_exe_log,
                "dsaw  dsa_io[%08h]=%08h, x%0d=%08h, x%0d=%08h\n",
                rs1_val, rs2_val,
                inst[19:15], rs1_val,
                inst[24:20], rs2_val);
    endfunction : inst_exe

endclass : custom_inst_dsaw
class custom_inst_dsawi extends riscv_inst;

    parameter CONST_MASK = 32'h8000707f;
    parameter CONST_VAL  = 32'h8000100b;

    function new(string name="custom_inst_dsawi");
        super.new(name);
        `INST_NEW("dsawi", CUSTOM, LSU, CONST_MASK, CONST_VAL)
    endfunction : new

    `uvm_object_utils(custom_inst_dsawi)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_val;
        bit [15:0] imm;
        dsa_req_s req;

        rs1_val = `GPR(inst[19:15]);
        imm = {inst[30:20], inst[11:7]};

        dsa_mmio_lib.write(rs1_val, {16'b0, imm});
        req = '{1'b1, rs1_val, {16'b0, imm},
            csr_lib.stream_id.val[3:0], csr_lib.task_id.val[5:0],
            csr_lib.user_id.val[15:0], csr_lib.path_id.val[5:0],
            csr_lib.vc_id.val[1:0]};
        dsa_mmio_lib.trace_req(req);

            `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log,
                "dsawi dsa_io[%08h]=%08h, x%0d=%08h, imm=%04h\n",
                rs1_val, {16'b0, imm},
                inst[19:15], rs1_val, imm);
    endfunction : inst_exe

endclass : custom_inst_dsawi