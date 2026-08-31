// ============================================================================
// Filename             : $(CLASSNAME)_pkg.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
// If this is a upper level package, it should include the packages which
// construct this package as a UVC.
// For example:
// `include "xxxx_pkg.sv"
package $(CLASSNAME)_pkg;
    import  uvm_pkg::*;
    //
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //
    // For example:
    // import  xxxx_enum_pkg::*;
    // import  xxxx_pkg::*;
    
`include "uvm_macros.svh"
`include "$(CLASSNAME)_config.sv"
`include "$(CLASSNAME)_seq_item.sv"
`include "$(CLASSNAME)_sequencer.sv"
`include "./seq/$(CLASSNAME)_base_sequence.sv"
`include "./seq/$(CLASSNAME)_sequence.sv"
`include "$(CLASSNAME)_driver.sv"
`include "$(CLASSNAME)_monitor.sv"
`include "$(CLASSNAME)_agent.sv"

endpackage : $(CLASSNAME)_pkg