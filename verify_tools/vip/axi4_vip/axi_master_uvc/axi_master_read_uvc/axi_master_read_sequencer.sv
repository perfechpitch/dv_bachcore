// ============================================================================
// Filename             : axi_master_read_sequencer.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_READ_SEQUENCER_SV
`define AXI_MASTER_READ_SEQUENCER_SV

class axi_master_read_sequencer #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_sequencer #(
    axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH)
);
    typedef axi_master_read_sequencer #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;

    cfg_t axi_master_read_cfg;

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (axi_master_read_cfg == null) begin
            `uvm_fatal("NOCFG", {"axi_master_read_cfg must be assigned directly before build for: ",
                get_full_name()})
        end
    endfunction : build_phase
endclass : axi_master_read_sequencer
`endif
