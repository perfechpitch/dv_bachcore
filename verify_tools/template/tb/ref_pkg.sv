`ifndef $(FILENAME)_REF_PKG_SV
`define $(FILENAME)_REF_PKG_SV

// ============================================================================
// Filename             : $(CLASSNAME)_ref_pkg.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

package $(CLASSNAME)_ref_pkg;

    import  uvm_pkg::*;

    //
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //
    // For example:
    // import  xxxx_pkg::*;

`include "uvm_macros.svh"
`include "$(CLASSNAME)_ref.sv"

endpackage : $(CLASSNAME)_ref_pkg
`endif
