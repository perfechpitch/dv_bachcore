typedef struct packed {
    bit [63:2] base;
    bit [1:0]  mode;
} mtvec_field_s;

class riscv_mtvec extends riscv_csr;

    mtvec_field_s csr;

    `uvm_object_utils(riscv_mtvec)

    function new(string name="riscv_mtvec");
        super.new(name);
        `CSR_NEW("mtvec", 'h305, WR, 64'hffffffffbfc000e4, 64'hffffffffffffffff)
    endfunction : new

    function bit [63:0] except_entry_gen();
        return {csr.base, 2'b00};
    endfunction : except_entry_gen

    function void set_val(bit [63:0] wdata);
        val = (val & ~write_en) | (wdata & write_en);

        // Interrupt vector mode is not supported.
        // mtvec.MODE is fixed to Direct mode.
        val[1:0] = 2'b00;

        csr = val;
    endfunction : set_val

endclass : riscv_mtvec