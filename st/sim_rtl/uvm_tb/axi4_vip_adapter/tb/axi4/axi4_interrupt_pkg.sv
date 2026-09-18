package axi4_interrupt_pkg;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;

  `include "axi4_irq_handler_seq.svh"
endpackage
