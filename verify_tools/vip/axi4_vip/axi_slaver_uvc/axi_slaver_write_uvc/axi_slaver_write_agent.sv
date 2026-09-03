// ============================================================================
// Filename             : axi_slaver_write_agent.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : AXI write slaver UVM agent.
// ============================================================================
`ifndef AXI_SLAVER_WRITE_AGENT_SV
`define AXI_SLAVER_WRITE_AGENT_SV

class axi_slaver_write_agent #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_agent;
    typedef axi_slaver_write_agent #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_slaver_write_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef axi_slaver_write_driver #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) driver_t;
    typedef axi_slaver_write_sequencer #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) sequencer_t;
    typedef axi_write_monitor #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_t;

    cfg_t    axi_slaver_write_cfg;
    driver_t    axi_slaver_write_drv;
    sequencer_t axi_slaver_write_sequencer;
    monitor_t   axi_slaver_write_mon;

    `uvm_component_param_utils(this_type)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (axi_slaver_write_cfg == null) begin
            `uvm_fatal("NOCFG",
                {"axi_slaver_write_cfg must be assigned directly before build for: ",
                 get_full_name()})
        end
        if (axi_slaver_write_cfg.axi_slaver_write_vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set for: ",
                get_full_name(), ".axi_slaver_write_vif"})
        end

        if (axi_slaver_write_cfg.monitor_cfg == null) begin
            `uvm_fatal("NOMONCFG", {"monitor_cfg must be set for: ",
                get_full_name()})
        end
        axi_slaver_write_cfg.monitor_cfg.vif =
            axi_slaver_write_cfg.axi_slaver_write_vif;
        axi_slaver_write_cfg.monitor_cfg.outstanding_depth =
            axi_slaver_write_cfg.write_outstanding_depth;
        if (!axi_slaver_write_cfg.monitor_cfg.validate(
                {get_full_name(), ".monitor_cfg"})) begin
            `uvm_fatal("MONCFG", {"Invalid monitor cfg for: ",
                get_full_name()})
        end
        axi_slaver_write_mon = monitor_t::type_id::create(
            "axi_slaver_write_mon", this);
        axi_slaver_write_mon.cfg = axi_slaver_write_cfg.monitor_cfg;

        if (axi_slaver_write_cfg.is_active == UVM_ACTIVE) begin
            // Keep the conventional UVC sequencer component as a reserved
            // extension point. The reactive Driver does not poll it; normal
            // Slave operation is driven only by observed AW/W and cfg.
            axi_slaver_write_sequencer = sequencer_t::type_id::create("axi_slaver_write_sequencer", this);
            axi_slaver_write_sequencer.axi_slaver_write_cfg = axi_slaver_write_cfg;
            axi_slaver_write_drv = driver_t::type_id::create("axi_slaver_write_drv", this);
            axi_slaver_write_drv.axi_slaver_write_cfg = axi_slaver_write_cfg;
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (axi_slaver_write_cfg.is_active == UVM_ACTIVE) begin
            // Preserve the traditional Agent topology. The current Driver
            // intentionally never reads seq_item_port, so automatic response
            // neither requires nor consumes a Slave sequence.
            axi_slaver_write_drv.seq_item_port.connect(axi_slaver_write_sequencer.seq_item_export);
        end
    endfunction : connect_phase
endclass : axi_slaver_write_agent
`endif
