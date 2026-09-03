// ============================================================================
// Filename             : axi_slaver_write_base_sequence.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : Base AXI write slaver extension sequence shell.
// ============================================================================
`ifndef AXI_SLAVER_WRITE_BASE_SEQUENCE_SV
`define AXI_SLAVER_WRITE_BASE_SEQUENCE_SV

class axi_slaver_write_base_sequence #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_sequence #(axi_slaver_write_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH));
    typedef axi_slaver_write_base_sequence #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_slaver_write_sequencer #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) sequencer_t;

    `uvm_object_param_utils(this_type)
    `uvm_declare_p_sequencer(sequencer_t)

    function new(string name = "axi_slaver_write_base_sequence");
        super.new(name);
    endfunction : new

    // The built-in reactive Driver is cfg-driven and does not consume items.
    // Derived sequences are reserved for a future Driver extension contract.
endclass : axi_slaver_write_base_sequence
`endif
