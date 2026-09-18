`ifndef MU_ENV_PKG_SV
`define MU_ENV_PKG_SV

//`include "mu_enum_pkg.sv"
//`include "xxx_pkg.sv"
`include "mu_ref_pkg.sv"
//`include "mu_mon_pkg.sv"
//`include "mu_scb_pkg.sv"
//`include "reset_pkg.sv"

package mu_env_pkg;

    import  uvm_pkg::*;
    //import  mu_enum_pkg::*;
    //import  xxx_pkg::*;
    import  mu_ref_pkg::*;
    //import  mu_scb_pkg::*;
    //import  reset_pkg::*;
    
`include "uvm_macros.svh"
`include "mu_case_config.sv"
`include "mu_vsequencer.sv"
`include "./vseq/mu_base_vsequence.sv"
`include "./vseq/mu_vsequence.sv"
`include "mu_environment.sv"
endpackage : mu_env_pkg
`endif