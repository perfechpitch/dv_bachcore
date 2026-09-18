class bach_core_base_test extends uvm_test;
    `uvm_component_utils(bach_core_base_test)

    bach_core_env_cfg cfg;
    bach_core_env env;

    function new(string name = "bach_core_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(bach_core_env_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal("BACH_CORE_CFG", "bach_core_env_cfg was not configured by tb_top")
        cfg.apply_plusargs();
        if (!uvm_config_db#(virtual ts_if)::get(this, "", "ts_bind_vif", cfg.ts_vif))
            `uvm_fatal("BACH_CORE_BIND", "ts bind wrapper did not register ts_bind_vif")
        if (!uvm_config_db#(virtual rv_dsa_if)::get(this, "", "vu_rv_dsa_bind_vif", cfg.rv_dsa_vif[0]))
            `uvm_fatal("BACH_CORE_BIND", "VU RV Core bind wrapper did not register its interface")
        if (!uvm_config_db#(virtual rv_dsa_if)::get(this, "", "mu_rv_dsa_bind_vif", cfg.rv_dsa_vif[1]))
            `uvm_fatal("BACH_CORE_BIND", "MU RV Core bind wrapper did not register its interface")
        if (!uvm_config_db#(virtual rv_dsa_if)::get(this, "", "dte_rv_dsa_bind_vif", cfg.rv_dsa_vif[2]))
            `uvm_fatal("BACH_CORE_BIND", "DTE RV Core bind wrapper did not register its interface")
        cfg.ts_vif.behavior_enable = (cfg.mode == BACH_CORE_TS_DUMMY);
        foreach (cfg.rv_dsa_vif[i])
            cfg.rv_dsa_vif[i].behavior_enable = (cfg.mode == BACH_CORE_RVCORE_DUMMY);
        uvm_config_db#(bach_core_env_cfg)::set(this, "env", "cfg", cfg);
        env = bach_core_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Bach Core smoke test started", UVM_LOW)
        #500ns;
        `uvm_info(get_type_name(), "Bach Core smoke test completed", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
