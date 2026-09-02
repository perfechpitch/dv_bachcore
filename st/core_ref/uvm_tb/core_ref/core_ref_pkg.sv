package core_ref_pkg;

    import  uvm_pkg::*;
    import  public_typedef_pkg::*;

    import inst_lib_pkg::*;
    import csr_lib_pkg::*;
    import mem_lib_pkg::*;
    import dsa_mem_lib_pkg::*;
    import vu_inst_lib_pkg::*;
    import mu_inst_lib_pkg::*;
    import dte_inst_lib_pkg::*;
    import  dsa_mmio_lib_pkg::*;
    //
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //
    // For example:
    // import  xxxx_pkg::*;

`include "uvm_macros.svh"
`include "core_ref_config.sv"
`include "core_ref.sv"
// `include "core_ref_bk.sv"

endpackage : core_ref_pkg
