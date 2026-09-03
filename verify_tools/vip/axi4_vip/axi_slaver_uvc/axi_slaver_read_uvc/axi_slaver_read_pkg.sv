// ============================================================================
// Filename             : axi_slaver_read_pkg.sv
// Author               : kippy xyz
// Created On           : 2026-07-08
// Last Modified        :
// Update Count         :
// Description          : AXI read slaver UVC package.
// ============================================================================
package axi_slaver_read_pkg;
    import uvm_pkg::*;
    import mem_model_pkg::*;
    import axi_common_pkg::*;
    import axi_param_rules_pkg::*;

`include "axi_common_defines.svh"

// Default homogeneous profile used when a specialization is omitted. Explicit
// leaf specializations carry their exact shape through local class typedefs.
localparam int AXI_SLAVER_READ_ID_WIDTH   = `AXI_SLAVER_READ_ID_WIDTH;
localparam int AXI_SLAVER_READ_ADDR_WIDTH = `AXI_SLAVER_READ_ADDR_WIDTH;
localparam int AXI_SLAVER_READ_DATA_WIDTH = `AXI_SLAVER_READ_DATA_WIDTH;
localparam int AXI_SLAVER_READ_USER_WIDTH = `AXI_SLAVER_READ_USER_WIDTH;
localparam int AXI_SLAVER_READ_MAX_BEATS  = `AXI_SLAVER_READ_MAX_BEATS;

// Default-profile aliases used by the existing homogeneous multi-instance env.
typedef virtual axi_read_if #(
    AXI_SLAVER_READ_ID_WIDTH, AXI_SLAVER_READ_ADDR_WIDTH,
    AXI_SLAVER_READ_DATA_WIDTH, AXI_SLAVER_READ_USER_WIDTH
) axi_slaver_read_vif_t;
typedef axi_read_transaction #(
    AXI_SLAVER_READ_ID_WIDTH, AXI_SLAVER_READ_ADDR_WIDTH,
    AXI_SLAVER_READ_DATA_WIDTH, AXI_SLAVER_READ_USER_WIDTH
) axi_slaver_read_transaction_t;
typedef axi_read_monitor_config #(
    AXI_SLAVER_READ_ID_WIDTH, AXI_SLAVER_READ_ADDR_WIDTH,
    AXI_SLAVER_READ_DATA_WIDTH, AXI_SLAVER_READ_USER_WIDTH
) axi_slaver_read_monitor_cfg_t;
typedef axi_read_monitor #(
    AXI_SLAVER_READ_ID_WIDTH, AXI_SLAVER_READ_ADDR_WIDTH,
    AXI_SLAVER_READ_DATA_WIDTH, AXI_SLAVER_READ_USER_WIDTH
) axi_slaver_read_monitor_t;

`include "uvm_macros.svh"
`include "axi_slaver_read_config.sv"
`include "axi_slaver_read_seq_item.sv"
`include "axi_slaver_read_sequencer.sv"
`include "./seq/axi_slaver_read_base_sequence.sv"
`include "./seq/axi_slaver_read_sequence.sv"
`include "axi_slaver_read_driver.sv"
`include "axi_slaver_read_agent.sv"

endpackage : axi_slaver_read_pkg
