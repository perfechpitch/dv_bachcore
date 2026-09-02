// dsa_mmio_lib_pkg.sv
// DSA MMIO reference model (try-run) -- package + fixed include order.
//
// Include order (do not reorder):
//   1. uvm_pkg / uvm_macros          base class + macros for all mmio_set classes
//   2. dsa_mmio_define.svh           dsa_mmio_type_e selector enum (single source)
//   3. vu_mmio_set.sv                VU modeled: VALU0_OP
//   4. mu_mmio_set.sv                MU empty shell
//   5. dte_mmio_set.sv               DTE empty shell
//   6. dsa_mmio_library.sv           selector + forwarding, top entry
package dsa_mmio_lib_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "dsa_mmio_define.svh"
  `include "vu_mmio_set.sv"
  `include "mu_mmio_set.sv"
  `include "dte_mmio_set.sv"
  `include "dsa_mmio_library.sv"
endpackage
