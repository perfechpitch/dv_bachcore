typedef struct packed {
    bit [63:0] val;
} mcause_field_s;

class riscv_mcause extends riscv_csr;

    mcause_field_s csr;

    `uvm_object_utils(riscv_mcause)

    function new(string name="riscv_mcause");
        super.new(name);
        `CSR_NEW("mcause", 'h342, WR, 64'h0, 64'h0)
    endfunction : new

    function void set_val(bit [63:0] wdata);
        // mcause can only be updated by exception handling.
    endfunction : set_val

    function void except_update(exception_type_e except);
        case(except)
            INST_ADDR_MISALIGN      : val = 32'd0;
            INST_ACCESS_FAULT       : val = 32'd1;
            ILLEGAL_INST            : val = 32'd2;
            LOAD_ADDR_MISALIGN      : val = 32'd4;
            LOAD_ACCESS_FAULT       : val = 32'd5;
            STORE_AMO_ADDR_MISALIGN : val = 32'd6;
            STORE_AMO_ACCESS_FAULT  : val = 32'd7;
            M_ECALL                 : val = 32'd11;
            default                 : val = 32'h0;
        endcase

        csr = val;
    endfunction : except_update

endclass : riscv_mcause
