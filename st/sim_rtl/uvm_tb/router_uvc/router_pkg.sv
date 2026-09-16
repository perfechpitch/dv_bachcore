// ============================================================================
// Filename             : router_pkg.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
// If this is a upper level package, it should include the packages which
// construct this package as a UVC.
// For example:
// `include "xxxx_pkg.sv"
package router_pkg;
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
`include "router_config.sv"
`include "router_seq_item.sv"
`include "router_sequencer.sv"
`include "./seq/router_base_sequence.sv"
`include "./seq/router_sequence.sv"
`include "router_driver.sv"
`include "router_monitor.sv"
`include "router_agent.sv"

endpackage : router_pkg