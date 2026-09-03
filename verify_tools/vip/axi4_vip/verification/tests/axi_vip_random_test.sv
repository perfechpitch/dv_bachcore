`ifndef AXI_VIP_RANDOM_TEST_SV
`define AXI_VIP_RANDOM_TEST_SV

class axi_vip_random_test extends uvm_test;
    localparam time TEST_TIMEOUT = 5ms;

    axi_multi_env_config axi_cfg;
    axi_multi_env        env;

    `uvm_component_utils(axi_vip_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    protected function void configure_memory();
        int unsigned max_bus_size;
        bit [7:0] supported_size_mask;

        max_bus_size = (AXI_MASTER_READ_BUS_SIZE > AXI_WRITE_BUS_SIZE) ?
            AXI_MASTER_READ_BUS_SIZE : AXI_WRITE_BUS_SIZE;
        supported_size_mask = 8'hff >> (7 - max_bus_size);

        if (!axi_cfg.slaver_mem_models[0].create_seg(
                64'h0000_0000, 64'hffff_ffff, MEM_OK, 1'b0,
                supported_size_mask)) begin
            `uvm_fatal("AXI_RANDOM_MEM",
                "Failed to create the shared 32-bit memory segment")
        end

        axi_cfg.master_read_cfgs[0].memory_model =
            axi_cfg.slaver_mem_models[0];
        axi_cfg.master_write_cfgs[0].memory_model =
            axi_cfg.slaver_mem_models[0];
    endfunction : configure_memory

    protected function void configure_random_traffic();
        axi_master_read_config_default_t  master_read_cfg;
        axi_master_write_config_default_t master_write_cfg;
        axi_slaver_read_config_default_t  slaver_read_cfg;
        axi_slaver_write_config_default_t slaver_write_cfg;

        master_read_cfg  = axi_cfg.master_read_cfgs[0];
        master_write_cfg = axi_cfg.master_write_cfgs[0];
        slaver_read_cfg  = axi_cfg.slaver_read_cfgs[0];
        slaver_write_cfg = axi_cfg.slaver_write_cfgs[0];

        master_write_cfg.write_burst_count = 32;
        master_write_cfg.write_outstanding_depth = 4;
        master_write_cfg.use_mem_model = 1'b1;
        master_write_cfg.resp_dist = '{100, 0, 0};
        master_write_cfg.fix_awaddr_enable = 1'b0;
        master_write_cfg.fix_awlen_enable = 1'b0;
        master_write_cfg.fix_awsize_enable = 1'b0;
        master_write_cfg.fix_awburst_enable = 1'b0;
        master_write_cfg.fix_wdata_type_enable = 1'b0;
        master_write_cfg.fix_wstrb_enable = 1'b0;
        master_write_cfg.fix_wuser_enable = 1'b0;
        master_write_cfg.fix_first_delay_enable = 1'b0;
        master_write_cfg.fix_aw_w_order_enable = 1'b0;
        master_write_cfg.fix_aw_w_delay_enable = 1'b0;
        master_write_cfg.fix_pkg_delay_enable = 1'b0;
        master_write_cfg.fix_w_delay_enable = 1'b0;
        master_write_cfg.bready_mode =
            AXI_MASTER_WRITE_BREADY_AFTER_BVALID;
        master_write_cfg.fix_bready_delay_enable = 1'b0;
        master_write_cfg.bready_delay_type_dist = '{10, 30, 30, 20, 10};

        master_read_cfg.read_burst_count = 32;
        master_read_cfg.read_outstanding_depth = 4;
        master_read_cfg.use_mem_model = 1'b1;
        master_read_cfg.resp_dist = '{100, 0, 0};
        master_read_cfg.fix_araddr_enable = 1'b0;
        master_read_cfg.fix_arlen_enable = 1'b0;
        master_read_cfg.fix_arsize_enable = 1'b0;
        master_read_cfg.fix_arburst_enable = 1'b0;
        master_read_cfg.fix_first_delay_enable = 1'b0;
        master_read_cfg.fix_ar_delay_enable = 1'b0;
        master_read_cfg.rready_mode =
            AXI_MASTER_READ_RREADY_AFTER_RVALID;
        master_read_cfg.fix_rready_delay_enable = 1'b0;
        master_read_cfg.rready_delay_type_dist = '{10, 30, 30, 20, 10};

        slaver_write_cfg.write_outstanding_depth = 4;
        slaver_write_cfg.resp_order = AXI_RESP_READY_ORDER;
        slaver_write_cfg.save_req_num = 0;
        slaver_write_cfg.use_mem_model = 1'b1;
        slaver_write_cfg.fix_bresp_enable = 1'b0;
        slaver_write_cfg.awready_mode = AXI_AFTER_VALID;
        slaver_write_cfg.wready_mode = AXI_AFTER_VALID;
        slaver_write_cfg.fix_awready_delay_enable = 1'b0;
        slaver_write_cfg.fix_wready_delay_enable = 1'b0;
        slaver_write_cfg.fix_b_delay_enable = 1'b0;
        slaver_write_cfg.awready_delay_type_dist = '{10, 30, 30, 20, 10};
        slaver_write_cfg.wready_delay_type_dist = '{10, 30, 30, 20, 10};
        slaver_write_cfg.b_delay_dist = '{10, 30, 30, 20, 10};

        slaver_read_cfg.read_outstanding_depth = 4;
        slaver_read_cfg.resp_order = AXI_RESP_READY_ORDER;
        slaver_read_cfg.save_req_num = 0;
        slaver_read_cfg.arready_mode = AXI_AFTER_VALID;
        slaver_read_cfg.fix_arready_delay_enable = 1'b0;
        slaver_read_cfg.fix_ar_r_delay_enable = 1'b0;
        slaver_read_cfg.fix_r_delay_enable = 1'b0;
        slaver_read_cfg.arready_delay_type_dist = '{10, 30, 30, 20, 10};
        slaver_read_cfg.ar_r_delay_dist = '{10, 30, 30, 20, 10};
        slaver_read_cfg.r_delay_dist = '{10, 30, 30, 20, 10};
        slaver_read_cfg.memory_error_on_uninitialized_read = 1'b0;
        slaver_read_cfg.fix_rdata_enable = 1'b0;
        slaver_read_cfg.rdata_from_aruser_enable = 1'b0;
        slaver_read_cfg.use_mem_model = 1'b1;
        slaver_read_cfg.fix_rresp_enable = 1'b0;
    endfunction : configure_random_traffic

    function void build_phase(uvm_phase phase);
        axi_cfg_validation_report cfg_report;

        super.build_phase(phase);
        uvm_root::get().set_timeout(TEST_TIMEOUT, 1'b0);

        axi_cfg = axi_multi_env_config::type_id::create("axi_cfg");
        axi_cfg.set_instance_counts(1, 1, 1, 1);
        configure_memory();
        configure_random_traffic();

        cfg_report = new();
        void'(axi_cfg.get_args(cfg_report,
            {get_full_name(), ".axi_cfg.plusargs"}));
        if (!axi_cfg.validate_and_freeze(
                cfg_report, {get_full_name(), ".axi_cfg"})) begin
            `uvm_fatal("AXI_RANDOM_CFG", $sformatf(
                "Configuration failed: errors=%0d warnings=%0d",
                cfg_report.error_count, cfg_report.warning_count))
        end

        env = axi_multi_env::type_id::create("env", this);
        env.cfg = axi_cfg;
    endfunction : build_phase

    protected task start_master_write(
        output int unsigned submitted_count
    );
        axi_master_write_sequence_default_t seq;

        seq = axi_master_write_sequence_default_t::type_id::create(
            "master_write_seq", null,
            env.virtual_sequencer.master_write_sequencers[0].get_full_name());
        if (seq == null) begin
            `uvm_fatal("AXI_RANDOM_WRITE_SEQ", "Factory returned null")
        end

        seq.start(env.virtual_sequencer.master_write_sequencers[0]);
        if (seq.failed_count != 0 ||
            seq.attempted_count != axi_cfg.master_write_cfgs[0].write_burst_count ||
            seq.submitted_count != seq.attempted_count) begin
            `uvm_fatal("AXI_RANDOM_WRITE_SUBMIT", $sformatf(
                "expected=%0d attempted=%0d submitted=%0d failed=%0d",
                axi_cfg.master_write_cfgs[0].write_burst_count,
                seq.attempted_count, seq.submitted_count, seq.failed_count))
        end

        submitted_count = seq.submitted_count;
    endtask : start_master_write

    protected task wait_master_write(int unsigned completion_count);
        axi_master_write_transaction_t completed;

        repeat (completion_count) begin
            env.virtual_sequencer.master_write_completion_fifos[0].get(
                completed);
            if (completed == null) begin
                `uvm_fatal("AXI_RANDOM_WRITE_COMPLETE",
                    "Completion FIFO returned a null write transaction")
            end
            if (!completed.write_done ||
                completed.beat_count != completed.awlen + 1 ||
                completed.wdata.size() != completed.awlen + 1 ||
                completed.wstrb.size() != completed.awlen + 1 ||
                completed.wuser.size() != completed.awlen + 1 ||
                !(completed.bresp inside {AXI_RESP_OKAY, AXI_RESP_EXOKAY})) begin
                `uvm_fatal("AXI_RANDOM_WRITE_COMPLETE",
                    "Malformed or unsuccessful completed write transaction")
            end
        end
    endtask : wait_master_write

    protected task start_master_read(
        output int unsigned submitted_count
    );
        axi_master_read_sequence_default_t seq;

        seq = axi_master_read_sequence_default_t::type_id::create(
            "master_read_seq", null,
            env.virtual_sequencer.master_read_sequencers[0].get_full_name());
        if (seq == null) begin
            `uvm_fatal("AXI_RANDOM_READ_SEQ", "Factory returned null")
        end

        seq.start(env.virtual_sequencer.master_read_sequencers[0]);
        if (seq.failed_count != 0 ||
            seq.attempted_count != axi_cfg.master_read_cfgs[0].read_burst_count ||
            seq.submitted_count != seq.attempted_count) begin
            `uvm_fatal("AXI_RANDOM_READ_SUBMIT", $sformatf(
                "expected=%0d attempted=%0d submitted=%0d failed=%0d",
                axi_cfg.master_read_cfgs[0].read_burst_count,
                seq.attempted_count, seq.submitted_count, seq.failed_count))
        end

        submitted_count = seq.submitted_count;
    endtask : start_master_read

    protected task wait_master_read(int unsigned completion_count);
        axi_master_read_transaction_t completed;

        repeat (completion_count) begin
            env.virtual_sequencer.master_read_completion_fifos[0].get(
                completed);
            if (completed == null) begin
                `uvm_fatal("AXI_RANDOM_READ_COMPLETE",
                    "Completion FIFO returned a null read transaction")
            end
            if (!completed.read_done ||
                completed.beat_count != completed.arlen + 1 ||
                completed.rdata.size() != completed.arlen + 1 ||
                completed.rresp.size() != completed.arlen + 1 ||
                completed.ruser.size() != completed.arlen + 1) begin
                `uvm_fatal("AXI_RANDOM_READ_COMPLETE",
                    "Malformed completed read transaction")
            end
            foreach (completed.rresp[beat]) begin
                if (!(completed.rresp[beat] inside {
                        AXI_RESP_OKAY, AXI_RESP_EXOKAY})) begin
                    `uvm_fatal("AXI_RANDOM_READ_RESP", $sformatf(
                        "beat=%0d rresp=0x%0h", beat,
                        completed.rresp[beat]))
                end
            end
        end
    endtask : wait_master_read

    task main_phase(uvm_phase phase);
        int unsigned write_submitted_count;
        int unsigned read_submitted_count;

        phase.raise_objection(this);

        if (env == null) begin
            `uvm_fatal("AXI_RANDOM_ENV", "The AXI environment is null")
        end
        if (env.master_read_agents.size() != 1 ||
            env.master_write_agents.size() != 1 ||
            env.slaver_read_agents.size() != 1 ||
            env.slaver_write_agents.size() != 1) begin
            `uvm_fatal("AXI_RANDOM_ENV",
                "Expected exactly one Agent for each AXI role")
        end
        if (
            env.master_read_agents[0] == null ||
            env.master_write_agents[0] == null ||
            env.slaver_read_agents[0] == null ||
            env.slaver_write_agents[0] == null) begin
            `uvm_fatal("AXI_RANDOM_ENV",
                "Expected exactly one non-null Agent for each AXI role")
        end
        if (env.virtual_sequencer == null) begin
            `uvm_fatal("AXI_RANDOM_ENV", "The leaf handle registry is null")
        end
        if (
            env.virtual_sequencer.master_read_sequencers.size() != 1 ||
            env.virtual_sequencer.master_write_sequencers.size() != 1 ||
            env.virtual_sequencer.master_read_completion_fifos.size() != 1 ||
            env.virtual_sequencer.master_write_completion_fifos.size() != 1) begin
            `uvm_fatal("AXI_RANDOM_ENV",
                "The Master sequencer or completion array size is wrong")
        end
        if (
            env.virtual_sequencer.master_read_sequencers[0] == null ||
            env.virtual_sequencer.master_write_sequencers[0] == null ||
            env.virtual_sequencer.master_read_completion_fifos[0] == null ||
            env.virtual_sequencer.master_write_completion_fifos[0] == null) begin
            `uvm_fatal("AXI_RANDOM_ENV",
                "The Master sequencer or completion path is incomplete")
        end

        fork
            start_master_write(write_submitted_count);
            start_master_read(read_submitted_count);
        join

        fork
            wait_master_write(write_submitted_count);
            wait_master_read(read_submitted_count);
        join

        `uvm_info("AXI_VIP_RANDOM_PASS", $sformatf(
            "Completed %0d writes and %0d reads with four active Agents",
            write_submitted_count, read_submitted_count), UVM_LOW)
        phase.drop_objection(this);
    endtask : main_phase
endclass : axi_vip_random_test

`endif
