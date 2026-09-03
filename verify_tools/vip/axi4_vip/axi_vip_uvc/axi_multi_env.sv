// ============================================================================
// Filename             : axi_multi_env.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MULTI_ENV_SV
`define AXI_MULTI_ENV_SV

// The AXI VIP multi-instance environment has two explicit inputs:
//   1. cfg, assigned directly by the user platform environment;
//   2. VIF resources, published by the HDL top with the package key helpers.
// It creates the four leaf-UVC arrays directly from the final cfg graph.
class axi_multi_env extends uvm_env;
    axi_multi_env_config cfg;

    // Tests use these indexed leaf/FIFO handles to directly start Sequences
    // and coordinate serial or parallel traffic across Agents.
    axi_vip_virtual_sequencer virtual_sequencer;

    axi_master_read_agent_default_t  master_read_agents[];
    axi_master_write_agent_default_t master_write_agents[];
    axi_slaver_read_agent_default_t   slaver_read_agents[];
    axi_slaver_write_agent_default_t  slaver_write_agents[];

    `uvm_component_utils(axi_multi_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    protected function bit bind_virtual_interfaces();
        bind_virtual_interfaces = 1'b1;

        foreach (cfg.master_read_cfgs[i]) begin
            if (!uvm_config_db #(axi_master_read_vif_t)::get(
                    this, "", axi_master_read_vif_key(i),
                    cfg.master_read_cfgs[i].axi_master_read_vif)) begin
                `uvm_error("AXI_MULTI_ENV_VIF", axi_diag::format(
                        "MULTI_ENV_MASTER_READ_VIF_GET_FAILED",
                        "MASTER", "READ", "BUILD_BIND",
                        $sformatf(
                            {"env=%s cfg_index=%0d key=%s ",
                             "config_db_get=0 actual_vif=null"},
                            get_full_name(), i,
                            axi_master_read_vif_key(i)),
                        "config_db_get=1 and a non-null VIF at the exact key",
                        "ABORT_BUILD"))
                bind_virtual_interfaces = 1'b0;
            end
        end

        foreach (cfg.master_write_cfgs[i]) begin
            if (!uvm_config_db #(axi_master_write_vif_t)::get(
                    this, "", axi_master_write_vif_key(i),
                    cfg.master_write_cfgs[i].axi_master_write_vif)) begin
                `uvm_error("AXI_MULTI_ENV_VIF", axi_diag::format(
                        "MULTI_ENV_MASTER_WRITE_VIF_GET_FAILED",
                        "MASTER", "WRITE", "BUILD_BIND",
                        $sformatf(
                            {"env=%s cfg_index=%0d key=%s ",
                             "config_db_get=0 actual_vif=null"},
                            get_full_name(), i,
                            axi_master_write_vif_key(i)),
                        "config_db_get=1 and a non-null VIF at the exact key",
                        "ABORT_BUILD"))
                bind_virtual_interfaces = 1'b0;
            end
        end

        foreach (cfg.slaver_read_cfgs[i]) begin
            if (!uvm_config_db #(axi_slaver_read_vif_t)::get(
                    this, "", axi_slaver_read_vif_key(i),
                    cfg.slaver_read_cfgs[i].axi_slaver_read_vif)) begin
                `uvm_error("AXI_MULTI_ENV_VIF", axi_diag::format(
                        "MULTI_ENV_SLAVER_READ_VIF_GET_FAILED",
                        "SLAVER", "READ", "BUILD_BIND",
                        $sformatf(
                            {"env=%s cfg_index=%0d key=%s ",
                             "config_db_get=0 actual_vif=null"},
                            get_full_name(), i,
                            axi_slaver_read_vif_key(i)),
                        "config_db_get=1 and a non-null VIF at the exact key",
                        "ABORT_BUILD"))
                bind_virtual_interfaces = 1'b0;
            end
        end

        foreach (cfg.slaver_write_cfgs[i]) begin
            if (!uvm_config_db #(axi_slaver_write_vif_t)::get(
                    this, "", axi_slaver_write_vif_key(i),
                    cfg.slaver_write_cfgs[i].axi_slaver_write_vif)) begin
                `uvm_error("AXI_MULTI_ENV_VIF", axi_diag::format(
                        "MULTI_ENV_SLAVER_WRITE_VIF_GET_FAILED",
                        "SLAVER", "WRITE", "BUILD_BIND",
                        $sformatf(
                            {"env=%s cfg_index=%0d key=%s ",
                             "config_db_get=0 actual_vif=null"},
                            get_full_name(), i,
                            axi_slaver_write_vif_key(i)),
                        "config_db_get=1 and a non-null VIF at the exact key",
                        "ABORT_BUILD"))
                bind_virtual_interfaces = 1'b0;
            end
        end
    endfunction : bind_virtual_interfaces

    function void build_phase(uvm_phase phase);
        axi_cfg_validation_report cfg_report;

        super.build_phase(phase);

        if (cfg == null) begin
            `uvm_fatal("AXI_MULTI_ENV_NOCFG",
                {"cfg must be assigned directly before build for: ",
                 get_full_name()})
            return;
        end
        cfg_report = new();
        if (!cfg.validate_all_cfg(cfg_report,
                {get_full_name(), ".cfg"})) begin
            `uvm_fatal("AXI_CFG_INVALID", $sformatf(
                "Configuration validation failed for %s: %0d error(s), %0d warning(s)",
                get_full_name(), cfg_report.error_count,
                cfg_report.warning_count))
            return;
        end
        if (!bind_virtual_interfaces()) begin
            `uvm_fatal("AXI_MULTI_ENV_VIF",
                {"One or more Top VIF resources are missing for ",
                 get_full_name()})
            return;
        end
        if (!cfg.validate_bindings({get_full_name(), ".bindings"})) begin
            `uvm_fatal("AXI_MULTI_ENV_BIND",
                {"Invalid VIF bindings for ", get_full_name()})
            return;
        end

        master_read_agents = new[cfg.master_read_cfgs.size()];
        master_write_agents = new[cfg.master_write_cfgs.size()];
        slaver_read_agents = new[cfg.slaver_read_cfgs.size()];
        slaver_write_agents = new[cfg.slaver_write_cfgs.size()];

        virtual_sequencer = axi_vip_virtual_sequencer::type_id::create(
            "virtual_sequencer", this);
        virtual_sequencer.cfg = cfg;

        foreach (master_read_agents[i]) begin
            master_read_agents[i] =
                axi_master_read_agent_default_t::type_id::create(
                $sformatf("master_read_%0d", i), this);
            master_read_agents[i].axi_master_read_cfg =
                cfg.master_read_cfgs[i];
        end

        foreach (master_write_agents[i]) begin
            master_write_agents[i] =
                axi_master_write_agent_default_t::type_id::create(
                $sformatf("master_write_%0d", i), this);
            master_write_agents[i].axi_master_write_cfg =
                cfg.master_write_cfgs[i];
        end

        foreach (slaver_read_agents[i]) begin
            slaver_read_agents[i] =
                axi_slaver_read_agent_default_t::type_id::create(
                $sformatf("slaver_read_%0d", i), this);
            slaver_read_agents[i].axi_slaver_read_cfg =
                cfg.slaver_read_cfgs[i];
        end

        foreach (slaver_write_agents[i]) begin
            slaver_write_agents[i] =
                axi_slaver_write_agent_default_t::type_id::create(
                $sformatf("slaver_write_%0d", i), this);
            slaver_write_agents[i].axi_slaver_write_cfg =
                cfg.slaver_write_cfgs[i];
        end
    endfunction : build_phase

    // Export only active Master leaf sequencers.  Completion FIFOs are
    // created by virtual_sequencer during build; this phase only binds existing
    // components and connects each active Master monitor.
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (virtual_sequencer == null || virtual_sequencer.cfg != cfg) begin
            `uvm_fatal("AXI_MULTI_ENV_VSQR",
                "Virtual sequencer is null or has the wrong cfg handle")
        end
        if (master_read_agents.size() != cfg.master_read_cfgs.size() ||
            virtual_sequencer.master_read_sequencers.size() !=
                cfg.master_read_cfgs.size() ||
            virtual_sequencer.master_read_completion_fifos.size() !=
                cfg.master_read_cfgs.size()) begin
            `uvm_fatal("AXI_MULTI_ENV_VSQR",
                "Master Read cfg, Agent and virtual-sequencer sizes differ")
        end
        if (master_write_agents.size() != cfg.master_write_cfgs.size() ||
            virtual_sequencer.master_write_sequencers.size() !=
                cfg.master_write_cfgs.size() ||
            virtual_sequencer.master_write_completion_fifos.size() !=
                cfg.master_write_cfgs.size()) begin
            `uvm_fatal("AXI_MULTI_ENV_VSQR",
                "Master Write cfg, Agent and virtual-sequencer sizes differ")
        end

        foreach (master_read_agents[i]) begin
            axi_master_read_agent_default_t agent;

            agent = master_read_agents[i];
            if (agent == null ||
                agent.axi_master_read_cfg != cfg.master_read_cfgs[i] ||
                agent.axi_master_read_mon == null) begin
                `uvm_fatal("AXI_MULTI_ENV_VSQR", $sformatf(
                    "Master Read leaf %0d has an incomplete Agent binding", i))
            end
            if (cfg.master_read_cfgs[i].is_active == UVM_ACTIVE) begin
                if (agent.axi_master_read_sequencer == null ||
                    agent.axi_master_read_sequencer.axi_master_read_cfg !=
                        cfg.master_read_cfgs[i] ||
                    virtual_sequencer.master_read_completion_fifos[i] == null) begin
                    `uvm_fatal("AXI_MULTI_ENV_VSQR", $sformatf(
                        "Active Master Read leaf %0d cannot bind virtual_sequencer",
                        i))
                end
                virtual_sequencer.master_read_sequencers[i] =
                    agent.axi_master_read_sequencer;
                agent.axi_master_read_mon.analysis_port.connect(
                    virtual_sequencer.master_read_completion_fifos[i].
                        analysis_export);
            end else begin
                if (agent.axi_master_read_sequencer != null ||
                    virtual_sequencer.master_read_sequencers[i] != null ||
                    virtual_sequencer.master_read_completion_fifos[i] != null) begin
                    `uvm_fatal("AXI_MULTI_ENV_VSQR", $sformatf(
                        "Passive Master Read leaf %0d owns active-only state",
                        i))
                end
            end
        end

        foreach (master_write_agents[i]) begin
            axi_master_write_agent_default_t agent;

            agent = master_write_agents[i];
            if (agent == null ||
                agent.axi_master_write_cfg != cfg.master_write_cfgs[i] ||
                agent.axi_master_write_mon == null) begin
                `uvm_fatal("AXI_MULTI_ENV_VSQR", $sformatf(
                    "Master Write leaf %0d has an incomplete Agent binding", i))
            end
            if (cfg.master_write_cfgs[i].is_active == UVM_ACTIVE) begin
                if (agent.axi_master_write_sequencer == null ||
                    agent.axi_master_write_sequencer.axi_master_write_cfg !=
                        cfg.master_write_cfgs[i] ||
                    virtual_sequencer.master_write_completion_fifos[i] == null) begin
                    `uvm_fatal("AXI_MULTI_ENV_VSQR", $sformatf(
                        "Active Master Write leaf %0d cannot bind virtual_sequencer",
                        i))
                end
                virtual_sequencer.master_write_sequencers[i] =
                    agent.axi_master_write_sequencer;
                agent.axi_master_write_mon.analysis_port.connect(
                    virtual_sequencer.master_write_completion_fifos[i].
                        analysis_export);
            end else begin
                if (agent.axi_master_write_sequencer != null ||
                    virtual_sequencer.master_write_sequencers[i] != null ||
                    virtual_sequencer.master_write_completion_fifos[i] != null) begin
                    `uvm_fatal("AXI_MULTI_ENV_VSQR", $sformatf(
                        "Passive Master Write leaf %0d owns active-only state",
                        i))
                end
            end
        end
    endfunction : connect_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        `uvm_info("AXI_ENV_CONNECT", $sformatf(
            {"BEGIN env='%s' virtual_sequencer='%s' master_read=%0d master_write=%0d ",
             "slaver_read=%0d slaver_write=%0d"},
            get_full_name(), virtual_sequencer.get_full_name(),
            master_read_agents.size(),
            master_write_agents.size(), slaver_read_agents.size(),
            slaver_write_agents.size()), UVM_LOW)

        foreach (master_read_agents[i]) begin
            `uvm_info("AXI_ENV_CONNECT", $sformatf(
                "MASTER_READ[%0d] path='%s' active=%s monitor=ALWAYS vif=BOUND",
                i, master_read_agents[i].get_full_name(),
                cfg.master_read_cfgs[i].is_active == UVM_ACTIVE ?
                    "YES" : "NO"),
                UVM_LOW)
        end
        foreach (master_write_agents[i]) begin
            `uvm_info("AXI_ENV_CONNECT", $sformatf(
                "MASTER_WRITE[%0d] path='%s' active=%s monitor=ALWAYS vif=BOUND",
                i, master_write_agents[i].get_full_name(),
                cfg.master_write_cfgs[i].is_active == UVM_ACTIVE ?
                    "YES" : "NO"),
                UVM_LOW)
        end
        foreach (slaver_read_agents[i]) begin
            `uvm_info("AXI_ENV_CONNECT", $sformatf(
                "SLAVER_READ[%0d] path='%s' active=%s monitor=ALWAYS vif=BOUND",
                i, slaver_read_agents[i].get_full_name(),
                cfg.slaver_read_cfgs[i].is_active == UVM_ACTIVE ?
                    "YES" : "NO"),
                UVM_LOW)
        end
        foreach (slaver_write_agents[i]) begin
            `uvm_info("AXI_ENV_CONNECT", $sformatf(
                "SLAVER_WRITE[%0d] path='%s' active=%s monitor=ALWAYS vif=BOUND",
                i, slaver_write_agents[i].get_full_name(),
                cfg.slaver_write_cfgs[i].is_active == UVM_ACTIVE ?
                    "YES" : "NO"),
                UVM_LOW)
        end

        `uvm_info("AXI_ENV_CONNECT", $sformatf(
            "END env='%s'", get_full_name()), UVM_LOW)
    endfunction : end_of_elaboration_phase
endclass : axi_multi_env

`endif
