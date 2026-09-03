// ============================================================================
// Filename             : axi_common_pkg.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
package axi_common_pkg;
    import uvm_pkg::*;
    import axi_param_rules_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_protocol_utils.sv"
    `include "axi_cfg_validation.sv"
    `include "axi_cfg_plusarg_utils.sv"
    `include "axi_transaction.sv"
    `include "axi_monitor_config.sv"
    `include "axi_read_monitor.sv"
    `include "axi_write_monitor.sv"
endpackage : axi_common_pkg
