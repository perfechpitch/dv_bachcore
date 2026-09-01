// ============================================================================
// Filename             : vu_enviroment.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_ENVIROMENT_SV
`define VU_ENVIROMENT_SV
class vu_environment extends uvm_env;
    //
    // Control properties
    //
    vu_case_config        vu_case_cfg;

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
    // vu_monitor                  vu_mon;
    // vu_vsequencer               vu_vsqr;

    // vu_scoreboard               vu_scb;
    // vu_reference                vu_ref;

    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(vu_environment)
      `uvm_field_object(vu_case_cfg, UVM_DEFAULT)
    `uvm_component_utils_end
    
    // new - constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(vu_case_config)::get(this, "", "vu_case_cfg", vu_case_cfg))
           `uvm_fatal("NOCFG",{"vu_case_cfg must be set for: ",get_full_name(),".vu_case_cfg"});

        //reset_agt         = reset_agent::type_id::create("reset_agt", this);
        //uvm_config_db#(reset_config)::set(this,"*","reset_cfg",vu_case_cfg.reset_cfg);

        //xxx_agt           = xxx_agent::type_id::create("xxx_agt", this);
        //uvm_config_db#(xxx_config)::set(this,"*","xxx_cfg",vu_case_cfg.xxx_cfg);

        //vu_mon  = vu_monitor::type_id::create("vu_mon", this);
        //uvm_config_db#(vu_config)::set(this,"*","vu_cfg",vu_case_cfg.vu_cfg);

        //vu_vsqr = vu_vsequencer::type_id::create("vu_vsqr",this);
        //vu_scb  = vu_scoreboard::type_id::create("vu_scb",this);
        //vu_ref  = vu_reference::type_id::create("vu_ref",this);

        
        //usage 1
        //vr_agt[0] = vr_agent::type_id::create("vr_agt[0]",this);
        //vr_agt[1] = vr_agent::type_id::create("vr_agt[1]",this);
        //void'(uvm_config_db#(int)::set(this,"vr_agt[0]","agent_id", 0));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[1]","agent_id", 1));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[0].*","agent_id", 0));
        //void'(uvm_config_db#(int)::set(this,"vr_agt[1].*","agent_id", 1));
        //usage 2
        //for(int i=0;i<vu_case_cfg.vr_agt_num;i++)begin
        //    vr_agt[i]    = vr_agent::type_id::create($sformatf("vr_agt[%0d]",i), this);
        //    vr_agt[i].id = i;
        //    uvm_config_db#(vr_config)::set(this,"*",$sformatf("vr_cfg[%0d]",i),vu_case_cfg.vr_cfg[i]);
        //end

        config_log = $fopen($sformatf("./log/vu_config.log"),"w");
        set_report_id_action("CONFIG_LOG",UVM_LOG);
        set_report_id_file("CONFIG_LOG",config_log);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        //
        // System connection.
        // Connect agent analysis port to system monitor or scoreboard
        // 
        // xxx_agt.xxx_mon.xxx_ap.connect(vu_ref.xxx_imp);
        // vr_agt[0].vr_mon.vr_ap.connect(vu_ref.vr_imp);
        // vr_agt[1].vr_mon.vr_ap.connect(vu_ref.vr_imp);
         //scb choice 1
        // vu_mon.vu_ap.connect(vu_scb.dut_fifo.analysis_export);
        // vu_ref.vu_ap.connect(vu_scb.ref_fifo.analysis_export);
        //scb choice 2
        // vu_mon.vu_ap.connect(vu_scb.dut_imp);
        // vu_ref.vu_ap.connect(vu_scb.ref_imp);

        //
        // Connect local sqr to virtual sqr.
        //
        // vu_vsqr.xxx_sqr        = xxx_agt.xxx_sqr;
        // vu_vsqr.vr_sqr[0]      = vr_agt[0].vr_sqr;
        // vu_vsqr.vr_sqr[1]      = vr_agt[1].vr_sqr;
    endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        // Do something before run_phase
        `uvm_info("CONFIG_LOG",$sformatf("\nvu_case_cfg       :\n%s",vu_case_cfg.sprint()),UVM_LOW);
    endfunction : start_of_simulation_phase
endclass : vu_environment
`endif