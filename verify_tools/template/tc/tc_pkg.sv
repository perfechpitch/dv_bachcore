// ============================================================================
// Filename             : $(CLASSNAME)_tc_pkg.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
//
// If this is a upper level package, it should include the packages which
// construct this package as a UVC.
//
// For example:
`include "$(CLASSNAME)_env_pkg.sv"
package $(CLASSNAME)_tc_pkg;
    import  uvm_pkg::*;
    import  $(CLASSNAME)_env_pkg::*;
    
`include "uvm_macros.svh"
`include "$(CLASSNAME)_base_test.sv"
`include "$(CLASSNAME)_test.sv"

endpackage : $(CLASSNAME)_tc_pkg