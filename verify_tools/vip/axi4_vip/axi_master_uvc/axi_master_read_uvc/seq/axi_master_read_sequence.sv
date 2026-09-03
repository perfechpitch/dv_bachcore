// ============================================================================
// Filename             : axi_master_read_sequence.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          : Cfg-counted random AXI read sequence.
// ============================================================================
`ifndef AXI_MASTER_READ_SEQUENCE_SV
`define AXI_MASTER_READ_SEQUENCE_SV

class axi_master_read_sequence #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends axi_master_read_base_sequence #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH
);
    typedef axi_master_read_sequence #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;

    // generated_item remains the most recent attempt for source compatibility.
    item_t generated_item;

    // Submission results only. A successful submission means the Driver
    // accepted a prepared request; it does not mean that RLAST handshook.
    int unsigned attempted_count;
    int unsigned submitted_count;
    int unsigned failed_count;

    // Optional ID override remains sequence-local, so callers never mutate the
    // shared cfg while requests are protocol-active. It applies to every burst
    // in this cfg-counted start and remains subject to normal item constraints.
    bit                arid_override_enable = 1'b0;
    bit [ID_WIDTH-1:0] arid_override    = '0;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(arid_override_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(arid_override,    UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(attempted_count, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(submitted_count, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(failed_count,    UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_master_read_sequence");
        super.new(name);
        attempted_count = 0;
        submitted_count = 0;
        failed_count    = 0;
    endfunction : new

    task rand_send_tr();
        bit randomize_ok;

        generated_item = null;
        `uvm_create(req)
        req.axi_master_read_cfg = p_sequencer.axi_master_read_cfg;
        req.prepare_status = AXI_PREPARE_NOT_RUN;
        req.desired_mem_response_valid =
            p_sequencer.axi_master_read_cfg.use_mem_model &&
            !p_sequencer.axi_master_read_cfg.fix_araddr_enable;
        req.predicted_mem_response_valid = 1'b0;
        req.predicted_mem_access_bytes = 0;
        if (arid_override_enable) begin
            randomize_ok = req.randomize() with {
                arid == local::arid_override;
            };
        end
        else begin
            randomize_ok = req.randomize();
        end
        if (!randomize_ok) begin
            req.prepare_status = AXI_PREPARE_NO_CANDIDATE;
            if (!$cast(generated_item, req.clone()) ||
                generated_item == null) begin
                generated_item = null;
                `uvm_fatal("AXI_RANDOMIZE_FAILED",
                    "Failed to clone rejected AXI Master Read request")
            end
            `uvm_error("AXI_RANDOMIZE_FAILED",
                axi_diag::format(
                    "RANDOMIZE_CONSTRAINT_UNSATISFIED",
                    "MASTER", "READ", "SEQUENCE_RANDOMIZE",
                    $sformatf({"use_mem_model=%0b fix_addr=%0b fix_len=%0b ",
                               "fix_size=%0b fix_burst=%0b fix_lock=%0b ",
                               "len=%0d size=%0d burst=%s lock=%0b"},
                        p_sequencer.axi_master_read_cfg.use_mem_model,
                        p_sequencer.axi_master_read_cfg.fix_araddr_enable,
                        p_sequencer.axi_master_read_cfg.fix_arlen_enable,
                        p_sequencer.axi_master_read_cfg.fix_arsize_enable,
                        p_sequencer.axi_master_read_cfg.fix_arburst_enable,
                        p_sequencer.axi_master_read_cfg.fix_arlock_enable,
                        p_sequencer.axi_master_read_cfg.arlen,
                        p_sequencer.axi_master_read_cfg.arsize,
                        p_sequencer.axi_master_read_cfg.arburst.name(),
                        p_sequencer.axi_master_read_cfg.arlock),
                    {"all enabled distributions have nonzero legal choices; ",
                     "fixed fields and any inline constraints are mutually satisfiable"},
                    "REJECT_BEFORE_START_ITEM",
                    {"The SystemVerilog constraint solver returned failure. ",
                     "No ARVALID is driven for this attempt."}))
            return;
        end
        start_item(req);
        finish_item(req);

        if (!$cast(generated_item, req.clone()) || generated_item == null) begin
            generated_item = null;
            `uvm_fatal("AXI_RANDOMIZE_FAILED",
                "Failed to clone generated AXI Master Read request")
            return;
        end

        `uvm_info(get_type_name(),
            $sformatf("Generated one AXI read transaction:\n%s", req.sprint()),
            UVM_HIGH)
    endtask : rand_send_tr

    virtual task body();
        int unsigned burst_count;

        attempted_count = 0;
        submitted_count = 0;
        failed_count    = 0;
        generated_item  = null;

        if (p_sequencer == null ||
            p_sequencer.axi_master_read_cfg == null) begin
            `uvm_fatal("AXI_MASTER_READ_SEQUENCE_CFG",
                "Sequence requires a configured Master Read sequencer")
            return;
        end

        // The leaf cfg is the only burst-count source. Snapshot it once so one
        // start() always represents one stable, cfg-selected submission run.
        burst_count = p_sequencer.axi_master_read_cfg.read_burst_count;
        if (!(burst_count inside {
                [AXI_MASTER_READ_BURST_COUNT_MIN:
                    AXI_MASTER_READ_BURST_COUNT_MAX]})) begin
            `uvm_fatal("AXI_MASTER_READ_SEQUENCE_COUNT", $sformatf(
                "read_burst_count=%0d expected [%0d:%0d]",
                burst_count, AXI_MASTER_READ_BURST_COUNT_MIN,
                AXI_MASTER_READ_BURST_COUNT_MAX))
            return;
        end
        for (int unsigned n = 0; n < burst_count; n++) begin
            attempted_count++;
            rand_send_tr();
            if (generated_item != null &&
                generated_item.prepare_status == AXI_PREPARE_OK) begin
                submitted_count++;
            end
            else begin
                failed_count++;
            end
        end

        `uvm_info(get_type_name(), $sformatf(
            {"Master Read sequence requested=%0d attempted=%0d ",
             "submitted=%0d failed=%0d; protocol completion is not awaited"},
            burst_count, attempted_count, submitted_count, failed_count),
            UVM_LOW)
    endtask : body
endclass : axi_master_read_sequence
`endif
