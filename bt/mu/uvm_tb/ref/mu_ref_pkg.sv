`ifndef MU_REF_PKG_SV
`define MU_REF_PKG_SV

// ============================================================================
// Filename             : mu_ref_pkg.sv
// Author               : kippy
// Created On           : 2026-9-18 10:21
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

package mu_ref_pkg;

    import  uvm_pkg::*;

    //
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //
    // For example:
    // import  xxxx_pkg::*;

`include "uvm_macros.svh"
`include "mu_ref.sv"

endpackage : mu_ref_pkg
`endif
