// ============================================================================
// Filename             : inst_gen_pkg.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
package inst_gen_pkg;
    import  uvm_pkg::*;
    
`include "uvm_macros.svh"
`include "inst_gen_enum.sv"
`include "inst_gen_config.sv"
`include "inst_gen_seq_item.sv"
`include "vu_seq_item/vu_inst_seq_item.sv"
//----- AUTO cross seq_item includes begin -----
`include "vu_seq_item/cross_src_reg_seq_item.sv"
`include "vu_seq_item/cross_src_bypass_seq_item.sv"
`include "vu_seq_item/cross_1_gen_seq_item.sv"
`include "vu_seq_item/cross_2_gen_seq_item.sv"
`include "vu_seq_item/cross_3_gen_seq_item.sv"
`include "vu_seq_item/cross_4_gen_seq_item.sv"
`include "vu_seq_item/cross_5_gen_seq_item.sv"
`include "vu_seq_item/cross_6_gen_seq_item.sv"
`include "vu_seq_item/cross_7_gen_seq_item.sv"
`include "vu_seq_item/cross_8_gen_seq_item.sv"
`include "vu_seq_item/cross_9_gen_seq_item.sv"
`include "vu_seq_item/cross_10_gen_seq_item.sv"
`include "vu_seq_item/cross_11_gen_seq_item.sv"
//----- AUTO cross seq_item includes end -----
`include "inst_gen_sequencer.sv"
`include "./seq/inst_gen_base_sequence.sv"
`include "./seq/inst_gen_seq_lib.sv"
`include "./seq/inst_gen_sequence.sv"
`include "inst_gen_driver.sv"
`include "inst_gen_monitor.sv"
`include "inst_gen_agent.sv"
endpackage : inst_gen_pkg