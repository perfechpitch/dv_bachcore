// ============================================================================
// Filename             : vu_tc_pkg.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
//
// If this is a upper level package, it should include the packages which
// construct this package as a UVC.
//
// For example:
`include "vu_env_pkg.sv"
package vu_tc_pkg;
    import  uvm_pkg::*;
    import  vu_env_pkg::*;
    
`include "uvm_macros.svh"
`include "vu_base_test.sv"
`include "vu_test.sv"

endpackage : vu_tc_pkg