package inst_lib_pkg;

    import  uvm_pkg::*;
    //
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //
    // For example:
    import  public_typedef_pkg::*;
    import  csr_lib_pkg::*;
    import  mem_lib_pkg::*;
    import  dsa_mmio_lib_pkg::*;
`include "uvm_macros.svh"
`include "inst_lib_define.svh"

`include "inst_set/riscv_inst.sv"
`include "inst_set/rv32i/riscv_auipc.sv"
`include "inst_set/rv32i/riscv_arithmetic_insts.sv"
`include "inst_set/rv32i/riscv_branch_insts.sv"
`include "inst_set/rv32i/riscv_shift_insts.sv"
`include "inst_set/rv32i/riscv_load_insts.sv"
`include "inst_set/rv32i/riscv_store_insts.sv"
`include "inst_set/rv32i/riscv_jal.sv"
`include "inst_set/rv32i/riscv_i_others.sv"

`include "inst_set/rv32m/riscv_m_inst.sv"



`include "inst_set/rv32a/riscv_amo_insts.sv"
`include "inst_set/rv32a/riscv_lrsc_insts.sv"

`include "inst_set/rv32compress/riscv_rv32compress_inst.sv"

`include "inst_set/custom/dsaw.sv"
`include "inst_set/custom/dsar.sv"


`include "inst_library.sv"

endpackage : inst_lib_pkg
