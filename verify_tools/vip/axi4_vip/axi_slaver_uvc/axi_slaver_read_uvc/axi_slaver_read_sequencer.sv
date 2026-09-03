// ============================================================================
// Filename             : axi_slaver_read_sequencer.sv
// Author               : kippy xyz
// Created On           : 2026-07-08
// Last Modified        :
// Update Count         :
// Description          : Reserved AXI read slaver sequencer extension shell.
// ============================================================================
`ifndef AXI_SLAVER_READ_SEQUENCER_SV
`define AXI_SLAVER_READ_SEQUENCER_SV

class axi_slaver_read_sequencer #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends uvm_sequencer #(axi_slaver_read_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH));
    typedef axi_slaver_read_sequencer #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_slaver_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;

    cfg_t axi_slaver_read_cfg;

    // Automatic Slave response does not consume sequence items. This handle
    // remains only to preserve the conventional UVC shape and future subclass
    // extension point. Item-producing sequences fail fast in wait_for_grant()
    // instead of waiting forever for the reactive Driver.

    `uvm_component_param_utils(this_type)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (axi_slaver_read_cfg == null) begin
            `uvm_fatal("NOCFG", {"axi_slaver_read_cfg must be assigned directly before build for: ",
                get_full_name()})
        end
    endfunction : build_phase

    virtual task wait_for_grant(
        uvm_sequence_base sequence_ptr,
        int item_priority = -1,
        bit lock_request = 0
    );
        `uvm_fatal("AXI_SLAVER_SEQUENCE_DISABLED", axi_diag::format(
            "SLAVE_READ_SEQUENCE_ITEM_UNSUPPORTED", "SLAVE", "R",
            "sequence_submission",
            $sformatf("sequence=%s priority=%0d lock_request=%0b",
                (sequence_ptr == null) ? "null" : sequence_ptr.get_full_name(),
                item_priority, lock_request),
            "configure axi_slaver_read_cfg and let the reactive Driver respond to accepted AR",
            "reject_sequence_item_without_waiting", get_full_name()))
    endtask : wait_for_grant
endclass : axi_slaver_read_sequencer
`endif
