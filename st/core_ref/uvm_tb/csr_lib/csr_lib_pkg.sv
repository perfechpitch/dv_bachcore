package csr_lib_pkg;

    import uvm_pkg::*;
    import public_typedef_pkg::*;

    `include "uvm_macros.svh"
    `include "csr_lib_define.svh"
    `include "riscv_csr.sv"

    `include "csr_group/m_csr/riscv_m_easy_csr.sv"
    `include "csr_group/m_csr/riscv_mcause.sv"
    `include "csr_group/m_csr/riscv_mtvec.sv"

    `include "csr_library.sv"

endpackage : csr_lib_pkg