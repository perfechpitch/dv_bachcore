// ============================================================================
// Filename             : mu_enviroment.sv
// Author               : kippy
// Created On           : 2026-9-18 10:21
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef MU_ENVIROMENT_SV
`define MU_ENVIROMENT_SV
class mu_environment extends uvm_env;
    //
    // Control properties
    //
    mu_case_config        mu_case_cfg;

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
    // mu_monitor                  mu_mon;
    // mu_vsequencer               mu_vsqr;

    // mu_scoreboard               mu_scb;
    // mu_reference                mu_ref;

    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(mu_environment)
      `uvm_field_object(mu_case_cfg, UVM_DEFAULT)
    `uvm_component_utils_end
    
    // new - constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(mu_case_config)::get(this, "", "mu_case_cfg", mu_case_cfg))
           `uvm_fatal("NOCFG",{"mu_case_cfg must be set for: ",get_full_name(),".mu_case_cfg"});

        //reset_agt         = reset_agent::type_id::create("reset_agt", this);
        //uvm_config_db#(reset_config)::set(this,"*","reset_cfg",mu_case_cfg.reset_cfg);

        //xxx_agt           = xxx_agent::type_id::create("xxx_agt", this);
        //uvm_config_db#(xxx_config)::set(this,"*","xxx_cfg",mu_case_cfg.xxx_cfg);

        //mu_mon  = mu_monitor::type_id::create("mu_mon", this);
        //uvm_config_db#(mu_config)::set(this,"*","mu_cfg",mu_case_cfg.mu_cfg);

        //mu_vsqr = mu_vsequencer::type_id::create("mu_vsqr",this);
        //mu_scb  = mu_scoreboard::type_id::create("mu_scb",this);
        //mu_ref  = mu_reference::type_id::create("mu_ref",this);

        
        //usage 1
        //vr_agt[0] = vr_agent::type_id::create("vr_agt[0]",this);
        //vr_agt[1] = vr_agent::type_id::create("vr_agt[1]",this);
        //void'(uvm_config_db#(int)::set(this,"vr_agt[0]","agent_id", 0));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[1]","agent_id", 1));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[0].*","agent_id", 0));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[1].*","agent_id", 1));
        //usage 2
        //for(int i=0;i<mu_case_cfg.vr_agt_num;i++)begin
        //    vr_agt[i]    = vr_agent::type_id::create($sformatf("vr_agt[%0d]",i), this);
        //    vr_agt[i].id = i;
        //    uvm_config_db#(vr_config)::set(this,"*",$sformatf("vr_cfg[%0d]",i),mu_case_cfg.vr_cfg[i]);
        //end

        config_log = $fopen($sformatf("./log/mu_config.log"),"w");
        set_report_id_action("CONFIG_LOG",UVM_LOG);
        set_report_id_file("CONFIG_LOG",config_log);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        //
        // System connection.
        // Connect agent analysis port to system monitor or scoreboard
        // 
        // xxx_agt.xxx_mon.xxx_ap.connect(mu_ref.xxx_imp);
        // vr_agt[0].vr_mon.vr_ap.connect(mu_ref.vr_imp);
        // vr_agt[1].vr_mon.vr_ap.connect(mu_ref.vr_imp);
         //scb choice 1
        // mu_mon.mu_ap.connect(mu_scb.dut_fifo.analysis_export);
        // mu_ref.mu_ap.connect(mu_scb.ref_fifo.analysis_export);
        //scb choice 2
        // mu_mon.mu_ap.connect(mu_scb.dut_imp);
        // mu_ref.mu_ap.connect(mu_scb.ref_imp);

        //
        // Connect local sqr to virtual sqr.
        //
        // mu_vsqr.xxx_sqr        = xxx_agt.xxx_sqr;
        // mu_vsqr.vr_sqr[0]      = vr_agt[0].vr_sqr;
        // mu_vsqr.vr_sqr[1]      = vr_agt[1].vr_sqr;
    endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        // Do something before run_phase
        `uvm_info("CONFIG_LOG",$sformatf("\nmu_case_cfg       :\n%s",mu_case_cfg.sprint()),UVM_LOW);
    endfunction : start_of_simulation_phase
endclass : mu_environment
`endif