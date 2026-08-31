// ============================================================================
// Filename             : $(CLASSNAME)_enviroment.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_ENVIROMENT_SV
`define $(FILENAME)_ENVIROMENT_SV
class $(CLASSNAME)_environment extends uvm_env;
    //
    // Control properties
    //
    $(CLASSNAME)_case_config        $(CLASSNAME)_case_cfg;

    int                             config_log;

    //
    // UVC components of the environment
    //
    // reset_agent                 reset_agt;
    // xxx_agent                   xxx_agt;

    //
    // System components like: system_monitor,virtual sequencer,
    // scoreboard.
    //
    // $(CLASSNAME)_monitor                  $(CLASSNAME)_mon;
    // $(CLASSNAME)_vsequencer               $(CLASSNAME)_vsqr;

    // $(CLASSNAME)_scoreboard               $(CLASSNAME)_scb;
    // $(CLASSNAME)_reference                $(CLASSNAME)_ref;

    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin($(CLASSNAME)_environment)
      `uvm_field_object($(CLASSNAME)_case_cfg, UVM_DEFAULT)
    `uvm_component_utils_end
    
    // new - constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#($(CLASSNAME)_case_config)::get(this, "", "$(CLASSNAME)_case_cfg", $(CLASSNAME)_case_cfg))
           `uvm_fatal("NOCFG",{"$(CLASSNAME)_case_cfg must be set for: ",get_full_name(),".$(CLASSNAME)_case_cfg"});

        //reset_agt         = reset_agent::type_id::create("reset_agt", this);
        //uvm_config_db#(reset_config)::set(this,"*","reset_cfg",$(CLASSNAME)_case_cfg.reset_cfg);

        //xxx_agt           = xxx_agent::type_id::create("xxx_agt", this);
        //uvm_config_db#(xxx_config)::set(this,"*","xxx_cfg",$(CLASSNAME)_case_cfg.xxx_cfg);

        //$(CLASSNAME)_mon  = $(CLASSNAME)_monitor::type_id::create("$(CLASSNAME)_mon", this);
        //uvm_config_db#($(CLASSNAME)_config)::set(this,"*","$(CLASSNAME)_cfg",$(CLASSNAME)_case_cfg.$(CLASSNAME)_cfg);

        //$(CLASSNAME)_vsqr = $(CLASSNAME)_vsequencer::type_id::create("$(CLASSNAME)_vsqr",this);
        //$(CLASSNAME)_scb  = $(CLASSNAME)_scoreboard::type_id::create("$(CLASSNAME)_scb",this);
        //$(CLASSNAME)_ref  = $(CLASSNAME)_reference::type_id::create("$(CLASSNAME)_ref",this);

        
        //usage 1
        //vr_agt[0] = vr_agent::type_id::create("vr_agt[0]",this);
        //vr_agt[1] = vr_agent::type_id::create("vr_agt[1]",this);
        //void'(uvm_config_db#(int)::set(this,"vr_agt[0]","agent_id", 0));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[1]","agent_id", 1));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[0].*","agent_id", 0));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[1].*","agent_id", 1));
        //usage 2
        //for(int i=0;i<$(CLASSNAME)_case_cfg.vr_agt_num;i++)begin
        //    vr_agt[i]    = vr_agent::type_id::create($sformatf("vr_agt[%0d]",i), this);
        //    vr_agt[i].id = i;
        //    uvm_config_db#(vr_config)::set(this,"*",$sformatf("vr_cfg[%0d]",i),$(CLASSNAME)_case_cfg.vr_cfg[i]);
        //end

        config_log = $fopen($sformatf("./log/$(CLASSNAME)_config.log"),"w");
        set_report_id_action("CONFIG_LOG",UVM_LOG);
        set_report_id_file("CONFIG_LOG",config_log);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        //
        // System connection.
        // Connect agent analysis port to system monitor or scoreboard
        // 
        // xxx_agt.xxx_mon.xxx_ap.connect($(CLASSNAME)_ref.xxx_imp);
        // vr_agt[0].vr_mon.vr_ap.connect($(CLASSNAME)_ref.vr_imp);
        // vr_agt[1].vr_mon.vr_ap.connect($(CLASSNAME)_ref.vr_imp);
         //scb choice 1
        // $(CLASSNAME)_mon.$(CLASSNAME)_ap.connect($(CLASSNAME)_scb.dut_fifo.analysis_export);
        // $(CLASSNAME)_ref.$(CLASSNAME)_ap.connect($(CLASSNAME)_scb.ref_fifo.analysis_export);
        //scb choice 2
        // $(CLASSNAME)_mon.$(CLASSNAME)_ap.connect($(CLASSNAME)_scb.dut_imp);
        // $(CLASSNAME)_ref.$(CLASSNAME)_ap.connect($(CLASSNAME)_scb.ref_imp);

        //
        // Connect local sqr to virtual sqr.
        //
        // $(CLASSNAME)_vsqr.xxx_sqr        = xxx_agt.xxx_sqr;
        // $(CLASSNAME)_vsqr.vr_sqr[0]      = vr_agt[0].vr_sqr;
        // $(CLASSNAME)_vsqr.vr_sqr[1]      = vr_agt[1].vr_sqr;
    endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        // Do something before run_phase
        `uvm_info("CONFIG_LOG",$sformatf("\n$(CLASSNAME)_case_cfg       :\n%s",$(CLASSNAME)_case_cfg.sprint()),UVM_LOW);
    endfunction : start_of_simulation_phase
endclass : $(CLASSNAME)_environment
`endif