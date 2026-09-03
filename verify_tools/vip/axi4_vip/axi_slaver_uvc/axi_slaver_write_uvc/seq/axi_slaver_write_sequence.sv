// ============================================================================
// Filename             : axi_slaver_write_sequence.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : Reserved AXI write slaver extension sequence shell.
// ============================================================================
`ifndef AXI_SLAVER_WRITE_SEQUENCE_SV
`define AXI_SLAVER_WRITE_SEQUENCE_SV

class axi_slaver_write_sequence #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends axi_slaver_write_base_sequence #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH);
    typedef axi_slaver_write_sequence #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    `uvm_object_param_utils(this_type)

    function new(string name = "axi_slaver_write_sequence");
        super.new(name);
    endfunction : new

    virtual task body();
        // Intentionally empty. The reactive Slave Driver creates one response
        // per accepted AW plus complete W burst directly from cfg.
        `uvm_info(get_type_name(),
            "Slave Write automatic response is cfg-driven; no sequence item was submitted",
            UVM_HIGH)
    endtask : body
endclass : axi_slaver_write_sequence
`endif
