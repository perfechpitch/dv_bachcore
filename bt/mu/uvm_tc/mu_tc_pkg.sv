// ============================================================================
// Filename             : mu_tc_pkg.sv
// Author               : kippy
// Created On           : 2026-9-18 10:21
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
//
// If this is a upper level package, it should include the packages which
// construct this package as a UVC.
//
// For example:
`include "mu_env_pkg.sv"
package mu_tc_pkg;
    import  uvm_pkg::*;
    import  mu_env_pkg::*;
    
`include "uvm_macros.svh"
`include "mu_base_test.sv"
`include "mu_test.sv"

endpackage : mu_tc_pkg