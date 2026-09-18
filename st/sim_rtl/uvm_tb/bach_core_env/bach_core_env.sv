class bach_core_env extends uvm_env;
    `uvm_component_utils(bach_core_env)

    bach_core_env_cfg cfg;
    router_config router_cfg;
    rv_dsa_cfg rv_dsa_cfg_h[3];
    ts_cfg ts_cfg_h;

    router_agent router_uvc;
    rvcore2dsa_agent rvcore2dsa[3];
    rvcore_env rvcore;
    ts2rvcore_agent ts2rvcore;

    function new(string name = "bach_core_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(bach_core_env_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal("BACH_CORE_CFG", "bach_core_env_cfg was not configured")

        router_cfg = router_config::type_id::create("router_cfg");
        ts_cfg_h = ts_cfg::type_id::create("ts_cfg_h");

        router_cfg.is_active = UVM_PASSIVE;
        ts_cfg_h.is_active = (cfg.mode == BACH_CORE_TS_DUMMY) ? UVM_ACTIVE : UVM_PASSIVE;
        router_cfg.router_vif = cfg.router_vif;
        ts_cfg_h.vif = cfg.ts_vif;

        uvm_config_db#(router_config)::set(this, "router_uvc*", "router_cfg", router_cfg);
        uvm_config_db#(virtual router_if)::set(this, "router_uvc*", "router_vif", cfg.router_vif);
        uvm_config_db#(ts_cfg)::set(this, "ts2rvcore", "cfg", ts_cfg_h);

        router_uvc = router_agent::type_id::create("router_uvc", this);
        foreach (rv_dsa_cfg_h[i]) begin
            rv_dsa_cfg_h[i] = rv_dsa_cfg::type_id::create($sformatf("rv_dsa_cfg_h[%0d]", i));
            rv_dsa_cfg_h[i].is_active = (cfg.mode == BACH_CORE_RVCORE_DUMMY) ? UVM_ACTIVE : UVM_PASSIVE;
            rv_dsa_cfg_h[i].vif = cfg.rv_dsa_vif[i];
            uvm_config_db#(rv_dsa_cfg)::set(this, $sformatf("rvcore2dsa_%0d", i), "cfg", rv_dsa_cfg_h[i]);
            rvcore2dsa[i] = rvcore2dsa_agent::type_id::create($sformatf("rvcore2dsa_%0d", i), this);
        end
        rvcore = rvcore_env::type_id::create("rvcore", this);
        ts2rvcore = ts2rvcore_agent::type_id::create("ts2rvcore", this);

        `uvm_info("BACH_CORE_CFG", $sformatf(
            "mode=%s check_level=%s ts2rvcore=%s rvcore2dsa=%s",
            cfg.mode.name(), cfg.check_level.name(), ts_cfg_h.is_active.name(),
            rv_dsa_cfg_h[0].is_active.name()), UVM_LOW)
    endfunction
endclass
