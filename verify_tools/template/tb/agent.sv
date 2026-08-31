// ============================================================================
// Filename             : $(CLASSNAME)_agent.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_AGENT_SV
`define $(FILENAME)_AGENT_SV
class $(CLASSNAME)_agent extends uvm_agent;
    $(CLASSNAME)_config                  $(CLASSNAME)_cfg;    
    $(CLASSNAME)_driver                  $(CLASSNAME)_drv;
    $(CLASSNAME)_sequencer               $(CLASSNAME)_sqr;
    $(CLASSNAME)_monitor                 $(CLASSNAME)_mon;
    ///////////////////////////////////////////////////////
    //open when need more than one agent
    //int                                  xxx_num;
    
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin($(CLASSNAME)_agent)
        `uvm_field_object($(CLASSNAME)_cfg,          UVM_DEFAULT)    
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"","$(CLASSNAME)_cfg",$(CLASSNAME)_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});
        if(!uvm_config_db#(virtual $(CLASSNAME)_if)::get(this,"","$(CLASSNAME)_vif",$(CLASSNAME)_cfg.$(CLASSNAME)_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".$(CLASSNAME)_vif"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"",$sformatf("$(CLASSNAME)_cfg%0d",xxx_num),$(CLASSNAME)_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});
        //if(!uvm_config_db#(virtual $(CLASSNAME)_if)::get(this,"",$sformatf("$(CLASSNAME)_vif%0d",xxx_num),$(CLASSNAME)_cfg.$(CLASSNAME)_vif))
        //    `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".$(CLASSNAME)_vif"});

        get_args();

        $(CLASSNAME)_mon         = $(CLASSNAME)_monitor::type_id::create("$(CLASSNAME)_mon", this);
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //$(CLASSNAME)_mon.xxx_num = xxx_num;
    
        if($(CLASSNAME)_cfg.is_active == UVM_ACTIVE) begin
            $(CLASSNAME)_sqr         = $(CLASSNAME)_sequencer::type_id::create("$(CLASSNAME)_sqr", this);
            $(CLASSNAME)_drv         = $(CLASSNAME)_driver::type_id::create("$(CLASSNAME)_drv", this);
            ///////////////////////////////////////////////////////
            //open when need more than one agent
            //$(CLASSNAME)_sqr.xxx_num = xxx_num;
            //$(CLASSNAME)_drv.xxx_num = xxx_num;
        end
    endfunction : build_phase
    
    // connect_phase
    function void connect_phase(uvm_phase phase);
        if($(CLASSNAME)_cfg.is_active == UVM_ACTIVE) begin
            $(CLASSNAME)_drv.seq_item_port.connect($(CLASSNAME)_sqr.seq_item_export);
        end
    endfunction : connect_phase

    function get_args();
        //if ($value$plusargs("$(CLASSNAME)_delay_0=%0d",$(CLASSNAME)_cfg.delay_dist[0]))begin
        //end
        //if ($value$plusargs("$(CLASSNAME)_cc_weight=%0d",$(CLASSNAME)_cfg.cc_weight))begin
        //end
    endfunction : get_args
endclass : $(CLASSNAME)_agent
`endif