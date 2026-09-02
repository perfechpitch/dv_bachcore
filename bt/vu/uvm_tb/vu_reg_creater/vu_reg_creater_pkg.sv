//------------------------------------------------------------------------------
// File         : vu_reg_creater_pkg.sv
// Description  : Package wrapper for vu_reg_creater.sv
// Generator    : gen_reg_creater.py
//------------------------------------------------------------------------------
`ifndef VU_REG_CREATER_PKG_SV
`define VU_REG_CREATER_PKG_SV

package vu_reg_creater_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import reg_pkg::*;
  `include "vu_reg_creater.sv"
endpackage

`endif
