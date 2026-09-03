// ============================================================================
// Filename             : axi_slaver_read_sequence.sv
// Author               : kippy xyz
// Created On           : 2026-07-08
// Last Modified        :
// Update Count         :
// Description          : Reserved AXI read slaver extension sequence shell.
// ============================================================================
`ifndef AXI_SLAVER_READ_SEQUENCE_SV
`define AXI_SLAVER_READ_SEQUENCE_SV

class axi_slaver_read_sequence #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends axi_slaver_read_base_sequence #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH);
    typedef axi_slaver_read_sequence #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    `uvm_object_param_utils(this_type)

    function new(string name = "axi_slaver_read_sequence");
        super.new(name);
    endfunction : new

    virtual task body();
        // Intentionally empty. The reactive Slave Driver creates one response
        // per accepted AR directly from cfg; no Slave sequence is required.
        `uvm_info(get_type_name(),
            "Slave Read automatic response is cfg-driven; no sequence item was submitted",
            UVM_HIGH)
    endtask : body
endclass : axi_slaver_read_sequence
`endif
