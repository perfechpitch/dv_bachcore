package mem_lib_pkg;

    import uvm_pkg::*;
    import public_typedef_pkg::*;

    `include "uvm_macros.svh"

    // mem_lib static configuration and internal access type.
    `include "mem_lib_define.svh"

    // Base SRAM model with REF/DUT operation matching.
    `include "base_mem.sv"

    // Core-level memory library.
    `include "mem_library.sv"

endpackage : mem_lib_pkg