// ============================================================================
// Filename             : axi_slaver_write_pkg.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : AXI write slaver UVC package.
// ============================================================================
package axi_slaver_write_pkg;
    import  uvm_pkg::*;
    import  mem_model_pkg::*;
    import  axi_common_pkg::*;
    import  axi_param_rules_pkg::*;

`include "axi_common_defines.svh"

// Default homogeneous profile used when a specialization is omitted. Explicit
// leaf specializations carry their exact shape through local class typedefs.
localparam int AXI_SLAVER_WRITE_ID_WIDTH   = `AXI_SLAVER_WRITE_ID_WIDTH;
localparam int AXI_SLAVER_WRITE_ADDR_WIDTH = `AXI_SLAVER_WRITE_ADDR_WIDTH;
localparam int AXI_SLAVER_WRITE_DATA_WIDTH = `AXI_SLAVER_WRITE_DATA_WIDTH;
localparam int AXI_SLAVER_WRITE_USER_WIDTH = `AXI_SLAVER_WRITE_USER_WIDTH;
localparam int AXI_SLAVER_WRITE_MAX_BEATS  = `AXI_SLAVER_WRITE_MAX_BEATS;

// Default-profile aliases used by the existing homogeneous multi-instance env.
typedef virtual axi_write_if #(
    AXI_SLAVER_WRITE_ID_WIDTH, AXI_SLAVER_WRITE_ADDR_WIDTH,
    AXI_SLAVER_WRITE_DATA_WIDTH, AXI_SLAVER_WRITE_USER_WIDTH
) axi_slaver_write_vif_t;
typedef axi_write_transaction #(
    AXI_SLAVER_WRITE_ID_WIDTH, AXI_SLAVER_WRITE_ADDR_WIDTH,
    AXI_SLAVER_WRITE_DATA_WIDTH, AXI_SLAVER_WRITE_USER_WIDTH
) axi_slaver_write_transaction_t;
typedef axi_write_monitor_config #(
    AXI_SLAVER_WRITE_ID_WIDTH, AXI_SLAVER_WRITE_ADDR_WIDTH,
    AXI_SLAVER_WRITE_DATA_WIDTH, AXI_SLAVER_WRITE_USER_WIDTH
) axi_slaver_write_monitor_cfg_t;
typedef axi_write_monitor #(
    AXI_SLAVER_WRITE_ID_WIDTH, AXI_SLAVER_WRITE_ADDR_WIDTH,
    AXI_SLAVER_WRITE_DATA_WIDTH, AXI_SLAVER_WRITE_USER_WIDTH
) axi_slaver_write_monitor_t;

`include "uvm_macros.svh"
`include "axi_slaver_write_config.sv"
`include "axi_slaver_write_seq_item.sv"
`include "axi_slaver_write_sequencer.sv"
`include "./seq/axi_slaver_write_base_sequence.sv"
`include "./seq/axi_slaver_write_sequence.sv"
`include "axi_slaver_write_driver.sv"
`include "axi_slaver_write_agent.sv"

endpackage : axi_slaver_write_pkg
