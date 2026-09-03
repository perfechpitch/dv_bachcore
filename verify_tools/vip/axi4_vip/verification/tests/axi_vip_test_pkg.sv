package axi_vip_test_pkg;
    timeunit 1ns;
    timeprecision 1ps;

    import uvm_pkg::*;
    import mem_model_pkg::*;
    import axi_common_pkg::*;
    import axi_master_read_pkg::*;
    import axi_master_write_pkg::*;
    import axi_slaver_read_pkg::*;
    import axi_slaver_write_pkg::*;
    import axi_vip_pkg::*;
    `include "uvm_macros.svh"
    `include "axi_vip_random_test.sv"
endpackage : axi_vip_test_pkg
