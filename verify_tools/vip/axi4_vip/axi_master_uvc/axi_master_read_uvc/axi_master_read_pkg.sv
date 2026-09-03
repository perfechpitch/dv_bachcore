// ============================================================================
// Filename             : axi_master_read_pkg.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
package axi_master_read_pkg;
    import uvm_pkg::*;
    import axi_common_pkg::*;
    import axi_param_rules_pkg::*;
    import mem_model_pkg::*;

`include "axi_common_defines.svh"

localparam int AXI_MASTER_READ_ID_WIDTH   = `AXI_MASTER_READ_ID_WIDTH;
localparam int AXI_MASTER_READ_ADDR_WIDTH = `AXI_MASTER_READ_ADDR_WIDTH;
localparam int AXI_MASTER_READ_DATA_WIDTH = `AXI_MASTER_READ_DATA_WIDTH;
localparam int AXI_MASTER_READ_USER_WIDTH = `AXI_MASTER_READ_USER_WIDTH;
localparam int AXI_MASTER_READ_MAX_BEATS  = `AXI_MASTER_READ_MAX_BEATS;

typedef virtual axi_read_if #(
    AXI_MASTER_READ_ID_WIDTH, AXI_MASTER_READ_ADDR_WIDTH,
    AXI_MASTER_READ_DATA_WIDTH, AXI_MASTER_READ_USER_WIDTH
) axi_master_read_vif_t;
typedef axi_read_transaction #(
    AXI_MASTER_READ_ID_WIDTH, AXI_MASTER_READ_ADDR_WIDTH,
    AXI_MASTER_READ_DATA_WIDTH, AXI_MASTER_READ_USER_WIDTH
) axi_master_read_transaction_t;
typedef axi_read_monitor_config #(
    AXI_MASTER_READ_ID_WIDTH, AXI_MASTER_READ_ADDR_WIDTH,
    AXI_MASTER_READ_DATA_WIDTH, AXI_MASTER_READ_USER_WIDTH
) axi_master_read_monitor_cfg_t;
typedef axi_read_monitor #(
    AXI_MASTER_READ_ID_WIDTH, AXI_MASTER_READ_ADDR_WIDTH,
    AXI_MASTER_READ_DATA_WIDTH, AXI_MASTER_READ_USER_WIDTH
) axi_master_read_monitor_t;

`include "uvm_macros.svh"
`include "axi_master_read_config.sv"
`include "axi_master_read_seq_item.sv"
`include "axi_master_read_sequencer.sv"
`include "./seq/axi_master_read_base_sequence.sv"
`include "./seq/axi_master_read_sequence.sv"

`include "axi_master_read_driver.sv"
`include "axi_master_read_agent.sv"

endpackage : axi_master_read_pkg
