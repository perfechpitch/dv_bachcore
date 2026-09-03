// ============================================================================
// Filename             : axi_master_read_base_sequence.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_READ_BASE_SEQUENCE_SV
`define AXI_MASTER_READ_BASE_SEQUENCE_SV

class axi_master_read_base_sequence #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_sequence #(
    axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH)
);
    typedef axi_master_read_base_sequence #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_read_sequencer #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) sequencer_t;

    `uvm_object_param_utils(this_type)
    `uvm_declare_p_sequencer(sequencer_t)

    function new(string name = "axi_master_read_base_sequence");
        super.new(name);
    endfunction : new
endclass : axi_master_read_base_sequence
`endif
