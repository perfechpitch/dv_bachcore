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
    vu_case_config      vu_case_cfg;

    int                 config_log;

    vu_reg_creater      vu_reg;
    reset_agent         reset_agt;
    inst_gen_agent      inst_gen_agt;

    vu_vsequencer               vu_vsqr;

    vu_reference                vu_ref;

    `uvm_component_utils_begin(vu_environment)
      `uvm_field_object(vu_case_cfg, UVM_DEFAULT)
    `uvm_component_utils_end
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(vu_case_config)::get(this, "", "vu_case_cfg", vu_case_cfg))
           `uvm_fatal("NOCFG",{"vu_case_cfg must be set for: ",get_full_name(),".vu_case_cfg"});

        vu_reg          = vu_reg_creater::type_id::create("vu_reg_creater", this);
        reset_agt       = reset_agent::type_id::create("reset_agt", this);
        uvm_config_db#(reset_config)::set(this,"*","reset_cfg",vu_case_cfg.reset_cfg);

        inst_gen_agt    = inst_gen_agent::type_id::create("inst_gen_agt", this);
        uvm_config_db#(inst_gen_config)::set(this,"*","inst_gen_cfg",vu_case_cfg.inst_gen_cfg);


        vu_vsqr = vu_vsequencer::type_id::create("vu_vsqr",this);
        uvm_config_db#(vu_case_config)::set(this,"vu_vsqr","vu_case_cfg",vu_case_cfg);
        vu_ref  = vu_reference::type_id::create("vu_ref",this);

        
        config_log = $fopen($sformatf("./log/vu_config.log"),"w");
        set_report_id_action("CONFIG_LOG",UVM_LOG);
        set_report_id_file("CONFIG_LOG",config_log);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        // Connect local sqr to virtual sqr.
        vu_vsqr.reset_sqr       = reset_agt.reset_sqr;
        vu_vsqr.inst_gen_sqr    = inst_gen_agt.inst_gen_sqr;
        vu_ref.regs = vu_reg.m_my_block;
    endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("CONFIG_LOG",$sformatf("\nvu_case_cfg       :\n%s",vu_case_cfg.sprint()),UVM_LOW);
    endfunction : start_of_simulation_phase
endclass : vu_environment
`endif
