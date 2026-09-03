// ============================================================================
// Filename             : axi_multi_env_config.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MULTI_ENV_CONFIG_SV
`define AXI_MULTI_ENV_CONFIG_SV

// One platform-level object owns the final configuration object for every
// leaf UVC instance. Array sizes are the only instance-count truth.
class axi_multi_env_config extends uvm_object;
    axi_master_read_config_default_t  master_read_cfgs[];
    axi_master_write_config_default_t master_write_cfgs[];
    axi_slaver_read_config_default_t   slaver_read_cfgs[];
    axi_slaver_write_config_default_t  slaver_write_cfgs[];

    // Slaver Read/Write entries with the same index represent one logical
    // endpoint and share this byte-addressable model by default. Unpaired
    // Read-only or Write-only entries own the model at their own index.
    mem_model slaver_mem_models[];

    // Logical scenario seal.  Leaf fields remain public for source
    // compatibility, while this guard prevents the cfg graph from being
    // rebuilt or prepared by a second scenario after pre-build validation.
    // Framework-owned VIF binding during Env build remains legal.
    local bit cfg_frozen;
    // Command-line policy is a single pre-freeze pass. Reapplying it could
    // make duplicate handling and Test-vs-command-line priority ambiguous.
    local bit args_applied;

    `uvm_object_utils_begin(axi_multi_env_config)
        `uvm_field_array_object(master_read_cfgs,  UVM_DEFAULT)
        `uvm_field_array_object(master_write_cfgs, UVM_DEFAULT)
        `uvm_field_array_object(slaver_read_cfgs,   UVM_DEFAULT)
        `uvm_field_array_object(slaver_write_cfgs,  UVM_DEFAULT)
        `uvm_field_array_object(slaver_mem_models,  UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axi_multi_env_config");
        super.new(name);
        master_read_cfgs = new[0];
        master_write_cfgs = new[0];
        slaver_read_cfgs = new[0];
        slaver_write_cfgs = new[0];
        slaver_mem_models = new[0];
        cfg_frozen = 1'b0;
        args_applied = 1'b0;
    endfunction : new

    // Create a fresh final cfg graph. Calling this function again intentionally
    // replaces every previous leaf cfg and memory-model handle.
    function void set_instance_counts(
        int unsigned master_read_num,
        int unsigned master_write_num,
        int unsigned slaver_read_num,
        int unsigned slaver_write_num
    );
        int unsigned slaver_mem_num;

        if (cfg_frozen || args_applied) begin
            `uvm_fatal("AXI_MULTI_ENV_CFG_FROZEN",
                {"set_instance_counts() cannot rebuild a cfg graph after ",
                 "command-line overrides were applied or the graph was frozen"})
            return;
        end

        master_read_cfgs = new[master_read_num];
        master_write_cfgs = new[master_write_num];
        slaver_read_cfgs = new[slaver_read_num];
        slaver_write_cfgs = new[slaver_write_num];

        slaver_mem_num = (slaver_read_num > slaver_write_num) ?
            slaver_read_num : slaver_write_num;
        slaver_mem_models = new[slaver_mem_num];

        foreach (master_read_cfgs[i]) begin
            master_read_cfgs[i] =
                axi_master_read_config_default_t::type_id::create(
                $sformatf("master_read_cfg_%0d", i));
            if (master_read_cfgs[i] == null ||
                !master_read_cfgs[i].randomize_fixed_value_defaults()) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to initialize Master Read cfg %0d", i))
            end
        end

        foreach (master_write_cfgs[i]) begin
            master_write_cfgs[i] =
                axi_master_write_config_default_t::type_id::create(
                $sformatf("master_write_cfg_%0d", i));
            if (master_write_cfgs[i] == null ||
                !master_write_cfgs[i].randomize_fixed_value_defaults()) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to initialize Master Write cfg %0d", i))
            end
        end

        foreach (slaver_mem_models[i]) begin
            slaver_mem_models[i] = mem_model::type_id::create(
                $sformatf("slaver_mem_model_%0d", i));
            if (slaver_mem_models[i] == null) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to create Slaver memory model %0d", i))
            end
        end

        foreach (slaver_read_cfgs[i]) begin
            slaver_read_cfgs[i] =
                axi_slaver_read_config_default_t::type_id::create(
                $sformatf("slaver_read_cfg_%0d", i));
            if (slaver_read_cfgs[i] == null) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to create Slaver Read cfg %0d", i))
            end
            // Install the shared model before generating fixed candidates.
            slaver_read_cfgs[i].memory_model = slaver_mem_models[i];
            if (!slaver_read_cfgs[i].randomize_fixed_value_defaults()) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to initialize Slaver Read cfg %0d", i))
            end
        end

        foreach (slaver_write_cfgs[i]) begin
            slaver_write_cfgs[i] =
                axi_slaver_write_config_default_t::type_id::create(
                $sformatf("slaver_write_cfg_%0d", i));
            if (slaver_write_cfgs[i] == null) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to create Slaver Write cfg %0d", i))
            end
            // Read and Write cfgs at the same index intentionally share the
            // same model.
            slaver_write_cfgs[i].memory_model = slaver_mem_models[i];
            if (!slaver_write_cfgs[i].randomize_fixed_value_defaults()) begin
                `uvm_fatal("AXI_MULTI_ENV_CFG", $sformatf(
                    "Failed to initialize Slaver Write cfg %0d", i))
            end
        end
    endfunction : set_instance_counts

    // Apply exact role/index command-line keys once, after the Test has made
    // its source-level assignments and before recursive validation/freeze.
    // Command-line fields therefore have deterministic highest policy
    // priority; malformed, duplicate and unknown names accumulate in report.
    function bit get_args(
        axi_cfg_validation_report report,
        string                    scope = "axi_multi_env_config"
    );
        axi_cfg_plusarg_parser parser;
        int unsigned           errors_before;
        string                 prefix;

        if (report == null) begin
            `uvm_error("AXI_MULTI_ENV_CFG_PLUSARG",
                "get_args() requires a non-null validation report")
            return 1'b0;
        end
        errors_before = report.error_count;

        if (cfg_frozen) begin
            report.invalid(scope,
                "get_args() called after validate_and_freeze()",
                "MULTI_ENV_PLUSARG_AFTER_FREEZE");
            return 1'b0;
        end
        if (args_applied) begin
            report.invalid(scope,
                "get_args() called more than once for one cfg graph",
                "MULTI_ENV_PLUSARG_REPEATED");
            return 1'b0;
        end
        args_applied = 1'b1;

        parser = axi_cfg_plusarg_parser::type_id::create(
            "axi_cfg_plusarg_parser");
        if (parser == null) begin
            report.invalid(scope,
                "actual_plusarg_parser=null expected=non-null",
                "MULTI_ENV_PLUSARG_PARSER_CREATE");
            return 1'b0;
        end

        foreach (master_write_cfgs[i]) begin
            if (master_write_cfgs[i] == null) begin
                continue;
            end
            prefix = $sformatf("MW_%0d", i);
            void'(master_write_cfgs[i].get_args(prefix, parser, report));
        end
        foreach (master_read_cfgs[i]) begin
            if (master_read_cfgs[i] == null) begin
                continue;
            end
            prefix = $sformatf("MR_%0d", i);
            void'(master_read_cfgs[i].get_args(prefix, parser, report));
        end
        foreach (slaver_write_cfgs[i]) begin
            if (slaver_write_cfgs[i] == null) begin
                continue;
            end
            prefix = $sformatf("SW_%0d", i);
            void'(slaver_write_cfgs[i].get_args(prefix, parser, report));
        end
        foreach (slaver_read_cfgs[i]) begin
            if (slaver_read_cfgs[i] == null) begin
                continue;
            end
            prefix = $sformatf("SR_%0d", i);
            void'(slaver_read_cfgs[i].get_args(prefix, parser, report));
        end

        parser.finish(scope, report);
        return report.error_count == errors_before;
    endfunction : get_args

    function bit validate_structure(
        axi_cfg_validation_report report,
        string                    scope
    );
        int unsigned reset_owner_count;

        validate_structure = 1'b1;

        foreach (master_read_cfgs[i]) begin
            if (master_read_cfgs[i] == null) begin
                report.invalid(scope, $sformatf(
                    "index=%0d actual_master_read_cfg=null expected=non-null",
                    i), "MULTI_ENV_MASTER_READ_CFG_NULL");
                validate_structure = 1'b0;
                continue;
            end
            if (master_read_cfgs[i].monitor_cfg == null) begin
                report.invalid(scope, $sformatf(
                    {"index=%0d actual_master_read_monitor_cfg=null ",
                     "expected=non-null"}, i),
                    "MULTI_ENV_MASTER_READ_MONITOR_CFG_NULL");
                validate_structure = 1'b0;
            end
        end
        foreach (master_write_cfgs[i]) begin
            if (master_write_cfgs[i] == null) begin
                report.invalid(scope, $sformatf(
                    "index=%0d actual_master_write_cfg=null expected=non-null",
                    i), "MULTI_ENV_MASTER_WRITE_CFG_NULL");
                validate_structure = 1'b0;
                continue;
            end
            if (master_write_cfgs[i].monitor_cfg == null) begin
                report.invalid(scope, $sformatf(
                    {"index=%0d actual_master_write_monitor_cfg=null ",
                     "expected=non-null"}, i),
                    "MULTI_ENV_MASTER_WRITE_MONITOR_CFG_NULL");
                validate_structure = 1'b0;
            end
        end
        foreach (slaver_read_cfgs[i]) begin
            if (slaver_read_cfgs[i] == null) begin
                report.invalid(scope, $sformatf(
                    "index=%0d actual_slaver_read_cfg=null expected=non-null",
                    i), "MULTI_ENV_SLAVER_READ_CFG_NULL");
                validate_structure = 1'b0;
                continue;
            end
            if (slaver_read_cfgs[i].monitor_cfg == null) begin
                report.invalid(scope, $sformatf(
                    {"index=%0d actual_slaver_read_monitor_cfg=null ",
                     "expected=non-null"}, i),
                    "MULTI_ENV_SLAVER_READ_MONITOR_CFG_NULL");
                validate_structure = 1'b0;
            end
            if (slaver_read_cfgs[i].is_active == UVM_ACTIVE &&
                slaver_read_cfgs[i].memory_model == null) begin
                report.invalid(scope, $sformatf(
                    {"index=%0d is_active=UVM_ACTIVE ",
                     "actual_memory_model=null expected=non-null"}, i),
                    "MULTI_ENV_SLAVER_READ_MEM_MODEL_NULL");
                validate_structure = 1'b0;
            end
        end
        foreach (slaver_write_cfgs[i]) begin
            if (slaver_write_cfgs[i] == null) begin
                report.invalid(scope, $sformatf(
                    "index=%0d actual_slaver_write_cfg=null expected=non-null",
                    i), "MULTI_ENV_SLAVER_WRITE_CFG_NULL");
                validate_structure = 1'b0;
                continue;
            end
            if (slaver_write_cfgs[i].monitor_cfg == null) begin
                report.invalid(scope, $sformatf(
                    {"index=%0d actual_slaver_write_monitor_cfg=null ",
                     "expected=non-null"}, i),
                    "MULTI_ENV_SLAVER_WRITE_MONITOR_CFG_NULL");
                validate_structure = 1'b0;
            end
            if (slaver_write_cfgs[i].is_active == UVM_ACTIVE &&
                slaver_write_cfgs[i].memory_model == null) begin
                report.invalid(scope, $sformatf(
                    {"index=%0d is_active=UVM_ACTIVE ",
                     "actual_memory_model=null expected=non-null"}, i),
                    "MULTI_ENV_SLAVER_WRITE_MEM_MODEL_NULL");
                validate_structure = 1'b0;
            end
        end

        foreach (slaver_mem_models[i]) begin
            if (slaver_mem_models[i] == null) begin
                report.invalid(scope, $sformatf(
                    "index=%0d actual_slaver_mem_model=null expected=non-null",
                    i), "MULTI_ENV_SLAVER_MEM_MODEL_NULL");
                validate_structure = 1'b0;
                continue;
            end

            reset_owner_count = 0;
            foreach (slaver_write_cfgs[w]) begin
                if (slaver_write_cfgs[w] != null &&
                    slaver_write_cfgs[w].memory_model == slaver_mem_models[i] &&
                    slaver_write_cfgs[w].is_active == UVM_ACTIVE &&
                    slaver_write_cfgs[w].memory_clear_on_reset) begin
                    reset_owner_count++;
                end
            end
            if (reset_owner_count > 1) begin
                report.conflict(scope, $sformatf(
                    {"model_index=%0d actual_active_reset_owner_count=%0d ",
                     "expected_max=1"}, i, reset_owner_count),
                    "MULTI_ENV_MEM_RESET_OWNER_CONFLICT");
                validate_structure = 1'b0;
            end
        end
    endfunction : validate_structure

    // Authoritative recursive validation entry. Every leaf reports all of its
    // findings into one shared report; the caller decides whether to fatal.
    function bit validate_all_cfg(
        axi_cfg_validation_report report,
        string                    scope
    );
        bit leaf_ok;

        validate_all_cfg = validate_structure(report, scope);
        foreach (master_read_cfgs[i]) begin
            if (master_read_cfgs[i] == null) continue;
            leaf_ok = master_read_cfgs[i].validate_cfg(report,
                $sformatf("%s.master_read_cfgs[%0d]", scope, i));
            validate_all_cfg &= leaf_ok;
            if (master_read_cfgs[i].monitor_cfg != null) begin
                leaf_ok = master_read_cfgs[i].monitor_cfg.validate_cfg(report,
                    $sformatf("%s.master_read_cfgs[%0d].monitor_cfg",
                        scope, i));
                validate_all_cfg &= leaf_ok;
            end
        end
        foreach (master_write_cfgs[i]) begin
            if (master_write_cfgs[i] == null) continue;
            leaf_ok = master_write_cfgs[i].validate_cfg(report,
                $sformatf("%s.master_write_cfgs[%0d]", scope, i));
            validate_all_cfg &= leaf_ok;
            if (master_write_cfgs[i].monitor_cfg != null) begin
                leaf_ok = master_write_cfgs[i].monitor_cfg.validate_cfg(report,
                    $sformatf("%s.master_write_cfgs[%0d].monitor_cfg",
                        scope, i));
                validate_all_cfg &= leaf_ok;
            end
        end
        foreach (slaver_read_cfgs[i]) begin
            if (slaver_read_cfgs[i] == null) continue;
            leaf_ok = slaver_read_cfgs[i].validate_cfg(report,
                $sformatf("%s.slaver_read_cfgs[%0d]", scope, i));
            validate_all_cfg &= leaf_ok;
            if (slaver_read_cfgs[i].monitor_cfg != null) begin
                leaf_ok = slaver_read_cfgs[i].monitor_cfg.validate_cfg(report,
                    $sformatf("%s.slaver_read_cfgs[%0d].monitor_cfg",
                        scope, i));
                validate_all_cfg &= leaf_ok;
            end
        end
        foreach (slaver_write_cfgs[i]) begin
            if (slaver_write_cfgs[i] == null) continue;
            leaf_ok = slaver_write_cfgs[i].validate_cfg(report,
                $sformatf("%s.slaver_write_cfgs[%0d]", scope, i));
            validate_all_cfg &= leaf_ok;
            if (slaver_write_cfgs[i].monitor_cfg != null) begin
                leaf_ok = slaver_write_cfgs[i].monitor_cfg.validate_cfg(report,
                    $sformatf("%s.slaver_write_cfgs[%0d].monitor_cfg",
                        scope, i));
                validate_all_cfg &= leaf_ok;
            end
        end
        validate_all_cfg &= report.ok();
    endfunction : validate_all_cfg

    // Validate all Test-owned behavioral cfg before any Env/Agent is built,
    // then seal the graph. This is a lifecycle contract, not physical
    // constness of the source-compatible public leaf fields.
    function bit validate_and_freeze(
        axi_cfg_validation_report report,
        string                    scope
    );
        if (cfg_frozen) begin
            `uvm_error("AXI_MULTI_ENV_CFG_FROZEN", $sformatf(
                "Configuration %s was already validated and frozen", scope))
            return 1'b0;
        end

        validate_and_freeze = validate_all_cfg(report, scope);
        if (validate_and_freeze) begin
            cfg_frozen = 1'b1;
        end
    endfunction : validate_and_freeze

    function bit is_frozen();
        return cfg_frozen;
    endfunction : is_frozen

    function bit validate_bindings(
        string report_id = "AXI_MULTI_ENV_BIND"
    );
        validate_bindings = 1'b1;

        foreach (master_read_cfgs[i]) begin
            if (master_read_cfgs[i].axi_master_read_vif == null) begin
                `uvm_error(report_id, axi_diag::format(
                    "MULTI_ENV_MASTER_READ_VIF_MISSING", "MASTER", "READ",
                    "BIND", $sformatf(
                        "cfg_index=%0d key=%s actual_vif=null", i,
                        axi_master_read_vif_key(i)),
                    "one non-null VIF bound to the indexed config_db key",
                    "ABORT_BUILD"))
                validate_bindings = 1'b0;
            end
            for (int j = i + 1; j < master_read_cfgs.size(); j++) begin
                if (master_read_cfgs[i].is_active == UVM_ACTIVE &&
                    master_read_cfgs[j].is_active == UVM_ACTIVE &&
                    master_read_cfgs[i].axi_master_read_vif ==
                        master_read_cfgs[j].axi_master_read_vif) begin
                    `uvm_error(report_id, axi_diag::format(
                        "MULTI_ENV_MASTER_READ_VIF_REUSE", "MASTER", "READ",
                        "BIND", $sformatf(
                            {"cfg_indices=[%0d,%0d] keys=[%s,%s] ",
                             "actual_vif_handle=same"}, i, j,
                            axi_master_read_vif_key(i),
                            axi_master_read_vif_key(j)),
                        "distinct VIF handles for distinct active endpoints",
                        "ABORT_BUILD"))
                    validate_bindings = 1'b0;
                end
            end
        end

        foreach (master_write_cfgs[i]) begin
            if (master_write_cfgs[i].axi_master_write_vif == null) begin
                `uvm_error(report_id, axi_diag::format(
                    "MULTI_ENV_MASTER_WRITE_VIF_MISSING", "MASTER", "WRITE",
                    "BIND", $sformatf(
                        "cfg_index=%0d key=%s actual_vif=null", i,
                        axi_master_write_vif_key(i)),
                    "one non-null VIF bound to the indexed config_db key",
                    "ABORT_BUILD"))
                validate_bindings = 1'b0;
            end
            for (int j = i + 1; j < master_write_cfgs.size(); j++) begin
                if (master_write_cfgs[i].is_active == UVM_ACTIVE &&
                    master_write_cfgs[j].is_active == UVM_ACTIVE &&
                    master_write_cfgs[i].axi_master_write_vif ==
                        master_write_cfgs[j].axi_master_write_vif) begin
                    `uvm_error(report_id, axi_diag::format(
                        "MULTI_ENV_MASTER_WRITE_VIF_REUSE", "MASTER", "WRITE",
                        "BIND", $sformatf(
                            {"cfg_indices=[%0d,%0d] keys=[%s,%s] ",
                             "actual_vif_handle=same"}, i, j,
                            axi_master_write_vif_key(i),
                            axi_master_write_vif_key(j)),
                        "distinct VIF handles for distinct active endpoints",
                        "ABORT_BUILD"))
                    validate_bindings = 1'b0;
                end
            end
        end

        foreach (slaver_read_cfgs[i]) begin
            if (slaver_read_cfgs[i].axi_slaver_read_vif == null) begin
                `uvm_error(report_id, axi_diag::format(
                    "MULTI_ENV_SLAVER_READ_VIF_MISSING", "SLAVER", "READ",
                    "BIND", $sformatf(
                        "cfg_index=%0d key=%s actual_vif=null", i,
                        axi_slaver_read_vif_key(i)),
                    "one non-null VIF bound to the indexed config_db key",
                    "ABORT_BUILD"))
                validate_bindings = 1'b0;
            end
            for (int j = i + 1; j < slaver_read_cfgs.size(); j++) begin
                if (slaver_read_cfgs[i].is_active == UVM_ACTIVE &&
                    slaver_read_cfgs[j].is_active == UVM_ACTIVE &&
                    slaver_read_cfgs[i].axi_slaver_read_vif ==
                        slaver_read_cfgs[j].axi_slaver_read_vif) begin
                    `uvm_error(report_id, axi_diag::format(
                        "MULTI_ENV_SLAVER_READ_VIF_REUSE", "SLAVER", "READ",
                        "BIND", $sformatf(
                            {"cfg_indices=[%0d,%0d] keys=[%s,%s] ",
                             "actual_vif_handle=same"}, i, j,
                            axi_slaver_read_vif_key(i),
                            axi_slaver_read_vif_key(j)),
                        "distinct VIF handles for distinct active endpoints",
                        "ABORT_BUILD"))
                    validate_bindings = 1'b0;
                end
            end
        end

        foreach (slaver_write_cfgs[i]) begin
            if (slaver_write_cfgs[i].axi_slaver_write_vif == null) begin
                `uvm_error(report_id, axi_diag::format(
                    "MULTI_ENV_SLAVER_WRITE_VIF_MISSING", "SLAVER", "WRITE",
                    "BIND", $sformatf(
                        "cfg_index=%0d key=%s actual_vif=null", i,
                        axi_slaver_write_vif_key(i)),
                    "one non-null VIF bound to the indexed config_db key",
                    "ABORT_BUILD"))
                validate_bindings = 1'b0;
            end
            for (int j = i + 1; j < slaver_write_cfgs.size(); j++) begin
                if (slaver_write_cfgs[i].is_active == UVM_ACTIVE &&
                    slaver_write_cfgs[j].is_active == UVM_ACTIVE &&
                    slaver_write_cfgs[i].axi_slaver_write_vif ==
                        slaver_write_cfgs[j].axi_slaver_write_vif) begin
                    `uvm_error(report_id, axi_diag::format(
                        "MULTI_ENV_SLAVER_WRITE_VIF_REUSE", "SLAVER", "WRITE",
                        "BIND", $sformatf(
                            {"cfg_indices=[%0d,%0d] keys=[%s,%s] ",
                             "actual_vif_handle=same"}, i, j,
                            axi_slaver_write_vif_key(i),
                            axi_slaver_write_vif_key(j)),
                        "distinct VIF handles for distinct active endpoints",
                        "ABORT_BUILD"))
                    validate_bindings = 1'b0;
                end
            end
        end
    endfunction : validate_bindings
endclass : axi_multi_env_config

`endif
