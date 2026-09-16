// ============================================================================
// Filename             : router_agent.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_AGENT_SV
`define ROUTER_AGENT_SV
class router_agent extends uvm_agent;
    router_config                  router_cfg;
    router_driver                  router_drv;
    router_sequencer               router_sqr;
    router_monitor                 router_mon;
    ///////////////////////////////////////////////////////
    //open when need more than one agent
    //int                                  xxx_num;

    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(router_agent)
        `uvm_field_object(router_cfg,          UVM_DEFAULT)
    `uvm_component_utils_end

    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(router_config)::get(this,"","router_cfg",router_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});
        if(!uvm_config_db#(virtual router_if)::get(this,"","router_vif",router_cfg.router_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".router_vif"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#(router_config)::get(this,"",$sformatf("router_cfg%0d",xxx_num),router_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});
        //if(!uvm_config_db#(virtual router_if)::get(this,"",$sformatf("router_vif%0d",xxx_num),router_cfg.router_vif))
        //    `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".router_vif"});

        get_args();

        router_mon         = router_monitor::type_id::create("router_mon", this);
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //router_mon.xxx_num = xxx_num;

        if(router_cfg.is_active == UVM_ACTIVE) begin
            router_sqr         = router_sequencer::type_id::create("router_sqr", this);
            router_drv         = router_driver::type_id::create("router_drv", this);
            ///////////////////////////////////////////////////////
            //open when need more than one agent
            //router_sqr.xxx_num = xxx_num;
            //router_drv.xxx_num = xxx_num;
        end
    endfunction : build_phase

    // connect_phase
    function void connect_phase(uvm_phase phase);
        if(router_cfg.is_active == UVM_ACTIVE) begin
            router_drv.seq_item_port.connect(router_sqr.seq_item_export);
        end
    endfunction : connect_phase

    function get_args();
        //if ($value$plusargs("router_delay_0=%0d",router_cfg.delay_dist[0]))begin
        //end
        //if ($value$plusargs("router_cc_weight=%0d",router_cfg.cc_weight))begin
        //end
    endfunction : get_args
endclass : router_agent
`endif