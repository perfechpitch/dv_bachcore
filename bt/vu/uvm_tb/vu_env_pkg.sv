`ifndef VU_ENV_PKG_SV
`define VU_ENV_PKG_SV

//`include "vu_enum_pkg.sv"
//`include "xxx_pkg.sv"
//`include "vu_ref_pkg.sv"
//`include "vu_mon_pkg.sv"
//`include "vu_scb_pkg.sv"
//`include "reset_pkg.sv"

package vu_env_pkg;

    import  uvm_pkg::*;
    //import  vu_enum_pkg::*;
    //import  xxx_pkg::*;
    //import  vu_ref_pkg::*;
    //import  vu_scb_pkg::*;
    //import  reset_pkg::*;
    
`include "uvm_macros.svh"
`include "vu_case_config.sv"
`include "vu_vsequencer.sv"
`include "./vseq/vu_base_vsequence.sv"
`include "./vseq/vu_vsequence.sv"
`include "vu_environment.sv"
endpackage : vu_env_pkg
`endif