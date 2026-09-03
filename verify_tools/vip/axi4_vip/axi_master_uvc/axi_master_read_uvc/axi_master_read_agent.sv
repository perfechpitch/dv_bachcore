// ============================================================================
// Filename             : axi_master_read_agent.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_READ_AGENT_SV
`define AXI_MASTER_READ_AGENT_SV

class axi_master_read_agent #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_agent;
    typedef axi_master_read_agent #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef axi_master_read_driver #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) driver_t;
    typedef axi_master_read_sequencer #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) sequencer_t;
    typedef axi_read_monitor #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_t;

    cfg_t       axi_master_read_cfg;
    driver_t    axi_master_read_drv;
    sequencer_t axi_master_read_sequencer;
    monitor_t   axi_master_read_mon;

    `uvm_component_param_utils(this_type)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (axi_master_read_cfg == null) begin
            `uvm_fatal("NOCFG",
                {"axi_master_read_cfg must be assigned directly before build for: ",
                 get_full_name()})
        end
        if (axi_master_read_cfg.axi_master_read_vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set for: ",
                get_full_name(), ".axi_master_read_vif"})
        end

        if (axi_master_read_cfg.monitor_cfg == null) begin
            `uvm_fatal("NOMONCFG", {"monitor_cfg must be set for: ",
                get_full_name()})
        end
        axi_master_read_cfg.monitor_cfg.vif =
            axi_master_read_cfg.axi_master_read_vif;
        axi_master_read_cfg.monitor_cfg.outstanding_depth =
            axi_master_read_cfg.read_outstanding_depth;
        if (!axi_master_read_cfg.monitor_cfg.validate(
                {get_full_name(), ".monitor_cfg"})) begin
            `uvm_fatal("MONCFG", {"Invalid monitor cfg for: ",
                get_full_name()})
        end
        axi_master_read_mon = monitor_t::type_id::create(
            "axi_master_read_mon", this);
        axi_master_read_mon.cfg = axi_master_read_cfg.monitor_cfg;

        if(axi_master_read_cfg.is_active == UVM_ACTIVE) begin
            axi_master_read_sequencer = sequencer_t::type_id::create("axi_master_read_sequencer", this);
            axi_master_read_sequencer.axi_master_read_cfg = axi_master_read_cfg;
            axi_master_read_drv = driver_t::type_id::create("axi_master_read_drv", this);
            axi_master_read_drv.axi_master_read_cfg = axi_master_read_cfg;
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(axi_master_read_cfg.is_active == UVM_ACTIVE) begin
            axi_master_read_drv.seq_item_port.connect(axi_master_read_sequencer.seq_item_export);
        end
    endfunction : connect_phase

endclass : axi_master_read_agent
`endif
