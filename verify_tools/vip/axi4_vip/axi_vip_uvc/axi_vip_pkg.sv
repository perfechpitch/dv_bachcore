// ============================================================================
// Filename             : axi_vip_pkg.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
package axi_vip_pkg;
    import uvm_pkg::*;
    import mem_model_pkg::*;
    import axi_common_pkg::*;
    import axi_master_read_pkg::*;
    import axi_master_write_pkg::*;
    import axi_slaver_read_pkg::*;
    import axi_slaver_write_pkg::*;

    // Public umbrella API: the declaration remains owned only by Common, but
    // users importing axi_vip_pkg::* can name the shared type and literals
    // directly without an additional Common-package import.
    export axi_common_pkg::axi_ready_mode_e;
    export axi_common_pkg::AXI_ALWAYS_HIGH;
    export axi_common_pkg::AXI_AFTER_VALID;

    `include "uvm_macros.svh"

    // The reusable multi-instance environment is intentionally homogeneous
    // within each Leaf family.  These aliases make its compile-time default
    // specialization explicit; heterogeneous Project Envs declare their own
    // exact specializations instead of placing unlike types in these arrays.
    typedef axi_master_read_config #()
        axi_master_read_config_default_t;
    typedef axi_master_write_config #()
        axi_master_write_config_default_t;
    typedef axi_slaver_read_config #()
        axi_slaver_read_config_default_t;
    typedef axi_slaver_write_config #()
        axi_slaver_write_config_default_t;

    typedef axi_master_read_sequencer #()
        axi_master_read_sequencer_default_t;
    typedef axi_master_write_sequencer #()
        axi_master_write_sequencer_default_t;
    typedef axi_master_read_sequence #()
        axi_master_read_sequence_default_t;
    typedef axi_master_write_sequence #()
        axi_master_write_sequence_default_t;
    typedef axi_master_read_agent #()
        axi_master_read_agent_default_t;
    typedef axi_master_write_agent #()
        axi_master_write_agent_default_t;
    typedef axi_slaver_read_agent #()
        axi_slaver_read_agent_default_t;
    typedef axi_slaver_write_agent #()
        axi_slaver_write_agent_default_t;

    // Fixed HDL Top -> axi_multi_env resource-key convention. The Top sets
    // virtual interfaces with these keys; the multi environment gets them by
    // cfg-array index. Keeping key construction here prevents string drift.
    function automatic string axi_master_read_vif_key(int unsigned index);
        return $sformatf("axi_master_read_vif_%0d", index);
    endfunction : axi_master_read_vif_key

    function automatic string axi_master_write_vif_key(int unsigned index);
        return $sformatf("axi_master_write_vif_%0d", index);
    endfunction : axi_master_write_vif_key

    function automatic string axi_slaver_read_vif_key(int unsigned index);
        return $sformatf("axi_slaver_read_vif_%0d", index);
    endfunction : axi_slaver_read_vif_key

    function automatic string axi_slaver_write_vif_key(int unsigned index);
        return $sformatf("axi_slaver_write_vif_%0d", index);
    endfunction : axi_slaver_write_vif_key

    `include "axi_multi_env_config.sv"
    `include "axi_vip_virtual_sequencer.sv"
    `include "axi_multi_env.sv"
endpackage : axi_vip_pkg
