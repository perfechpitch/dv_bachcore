// ============================================================================
// Filename             : axi_master_write_driver.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_WRITE_DRIVER_SV
`define AXI_MASTER_WRITE_DRIVER_SV

class axi_master_write_driver_context #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
);
    typedef axi_master_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;

    // The driver owns this clone. It never keeps the sequencer request handle
    // after item_done(), so later queue processing cannot observe item reuse.
    item_t tr;
    longint unsigned         reset_epoch_id;
    longint unsigned         seq_no;
    bit                      aw_done;
    bit                      w_done;
    bit                      queued_for_b;
    bit                      outstanding_active;
    bit                      outstanding_reserved;
    bit                      aw_issued;
    bit                      w_issued;
    bit                      pkg_anchor_captured;
    bit                      next_beat_wait_valid;
    longint unsigned         first_eligible_cycle;
    longint unsigned         aw_issue_cycle;
    longint unsigned         w_issue_cycle;
    longint unsigned         aw_handshake_cycle;
    longint unsigned         wlast_handshake_cycle;
    longint unsigned         next_beat_eligible_cycle;
    longint unsigned         b_eligible_cycle;
    int unsigned             beat_idx;
    int unsigned             beat_num;

    function new(
        item_t item = null,
        longint unsigned epoch_id = 0,
        longint unsigned item_seq_no = 0
    );
        tr                       = item;
        reset_epoch_id           = epoch_id;
        seq_no                   = item_seq_no;
        aw_done                  = 1'b0;
        w_done                   = 1'b0;
        queued_for_b             = 1'b0;
        outstanding_active       = 1'b0;
        outstanding_reserved     = 1'b0;
        aw_issued                = 1'b0;
        w_issued                 = 1'b0;
        pkg_anchor_captured      = 1'b0;
        next_beat_wait_valid     = 1'b0;
        first_eligible_cycle     = 0;
        aw_issue_cycle           = 0;
        w_issue_cycle            = 0;
        aw_handshake_cycle       = 0;
        wlast_handshake_cycle    = 0;
        next_beat_eligible_cycle = 0;
        b_eligible_cycle         = 0;
        beat_idx                 = 0;
        beat_num                 = (item == null) ? 0 : item.awlen + 1;
    endfunction : new
endclass : axi_master_write_driver_context

class axi_master_write_driver #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends uvm_driver #(
    axi_master_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH)
);
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(STRB_WIDTH);
    localparam bit [ADDR_WIDTH-1:0] ADDR_MAX = '1;

    typedef axi_master_write_driver #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;
    typedef axi_master_write_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef virtual axi_write_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_master_write_driver_context #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) context_t;
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;

    vif_t axi_master_write_vif;
    cfg_t axi_master_write_cfg;

    typedef enum int unsigned {
        AXI_MASTER_WRITE_B_IDLE,
        AXI_MASTER_WRITE_B_DELAY,
        AXI_MASTER_WRITE_B_READY
    } axi_master_write_b_state_e;

    axi_master_write_b_state_e b_state;
    int unsigned               bready_delay_cnt;
    bit                        b_target_valid;
    bit [ID_WIDTH-1:0] b_target_bid;

    // AW and W preserve transaction order independently. AXI4 has no WID, so
    // a W burst remains at the head until its WLAST handshake and W bursts can
    // never interleave. The same owned context is inserted into both FIFOs.
    context_t aw_issue_q[$];
    context_t w_issue_q[$];
    context_t driver_context_q[$];
    context_t outstanding_q[$];
    context_t b_wait_q[$];

    longint unsigned cycle_idx;
    longint unsigned reset_epoch_id;
    longint unsigned next_seq_no;
    bit              reset_low_seen;
    bit              reset_first_delay_valid;
    int unsigned     reset_first_delay;

    // Previous-packet anchors are tagged. A packet may use an anchor only when
    // it belongs to seq_no-1 in the same reset epoch.
    bit              last_aw_hs_valid;
    longint unsigned last_aw_hs_epoch;
    longint unsigned last_aw_hs_seq_no;
    longint unsigned last_aw_hs_cycle;
    bit              last_wlast_hs_valid;
    longint unsigned last_wlast_hs_epoch;
    longint unsigned last_wlast_hs_seq_no;
    longint unsigned last_wlast_hs_cycle;

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cycle_idx      = 0;
        reset_epoch_id = 0;
        next_seq_no    = 0;
        reset_low_seen = 1'b0;
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (axi_master_write_cfg == null) begin
            `uvm_fatal("NOCFG", {"axi_master_write_cfg must be assigned directly before build for: ",
                get_full_name()})
        end
        if (axi_master_write_cfg.write_outstanding_depth < 1 ||
            axi_master_write_cfg.write_outstanding_depth > 256) begin
            `uvm_fatal("OUTSTD", "write_outstanding_depth must be inside [1:256]")
        end

        axi_master_write_vif = axi_master_write_cfg.axi_master_write_vif;
        if (axi_master_write_vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set in: ", get_full_name(),
                ".axi_master_write_cfg.axi_master_write_vif"})
        end
        axi_master_write_vif.set_master_driver_enable(1'b1);
    endfunction : build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    extern virtual protected task drive_one_cycle();
    extern virtual protected task accept_item_cycle();
    extern virtual protected function bit prepare_request(
        item_t item
    );
    extern virtual protected function bit request_geometry_is_legal(
        item_t item,
        bit                      enforce_segment,
        mem_segment_s            segment
    );
    extern virtual protected function bit candidate_geometry_is_legal(
        item_t item,
        bit [ADDR_WIDTH-1:0] candidate_addr,
        bit [2:0]                candidate_size,
        bit                      enforce_segment,
        mem_segment_s            segment
    );
    extern virtual protected function axi_request_rule_e candidate_geometry_rule(
        item_t item,
        bit [ADDR_WIDTH-1:0] candidate_addr,
        bit [2:0]                candidate_size,
        bit                      enforce_segment,
        mem_segment_s            segment
    );
    extern virtual protected function axi_addr_search_status_e find_addr_in_segment_status(
        item_t item,
        mem_segment_s            segment,
        bit [2:0]                selected_size,
        bit                      select_random,
        output bit [ADDR_WIDTH-1:0] selected_addr,
        output bit [64:0]        candidate_count
    );
    extern virtual protected function bit offset_is_selected(
        item_t item,
        int unsigned              offset,
        bit [2:0]                 selected_size
    );
    extern virtual protected function bit get_page_range_for_offset(
        item_t item,
        mem_segment_s            segment,
        bit [2:0]                selected_size,
        int unsigned             offset,
        output mem_addr_t        first_page,
        output mem_addr_t        last_page
    );
    extern virtual protected function bit select_segment_by_response(
        item_t item,
        output mem_segment_s      segment,
        output int signed         segment_index
    );
    extern virtual protected function bit reject_request(
        item_t item,
        axi_prepare_reason_e      reason,
        axi_request_rule_e        rule,
        string                    expected,
        string                    detail = ""
    );
    extern virtual protected function bit range_supports_size(
        mem_addr_t low_addr,
        mem_addr_t high_addr,
        bit [2:0]  size
    );
    extern virtual protected function void rebuild_derived_payload(
        item_t item
    );
    extern virtual protected function bit payload_and_timing_are_legal(
        item_t item
    );
    extern virtual protected function axi_request_rule_e payload_and_timing_rule(
        item_t item,
        output int signed         failing_index
    );
    extern virtual protected task sample_source_handshakes(
        input bit aw_hs,
        input bit w_hs,
        input bit sampled_wlast
    );
    extern virtual protected task drive_source_outputs();
    extern virtual protected task queue_b_if_ready(
        context_t ctx
    );
    extern virtual protected task drive_b_channel_cycle(
        input bit b_hs,
        input bit sampled_bvalid,
        input bit [ID_WIDTH-1:0] sampled_bid
    );
    extern virtual protected task complete_b_response(
        input bit [ID_WIDTH-1:0] sampled_bid,
        input bit [1:0] sampled_bresp,
        input bit [USER_WIDTH-1:0] sampled_buser
    );
    extern virtual protected function bit capture_pkg_anchor(
        context_t ctx
    );
    extern virtual protected function bit is_aw_head(
        context_t ctx
    );
    extern virtual protected function bit is_w_head(
        context_t ctx
    );
    extern virtual protected function int find_b_wait_index(
        bit [ID_WIDTH-1:0] bid,
        longint unsigned lookup_cycle
    );
    extern virtual protected function int find_outstanding_index(
        context_t ctx
    );
    extern virtual protected function int find_driver_context_index(
        context_t ctx
    );
    extern virtual protected function int unsigned get_reserved_outstanding_depth();
    extern virtual protected function bit can_reserve_outstanding_slot(
        context_t ctx
    );
    extern virtual protected function void reserve_outstanding_slot(
        context_t ctx
    );
    extern virtual protected function void activate_outstanding(
        context_t ctx
    );
endclass : axi_master_write_driver

task axi_master_write_driver::driver_reset();
    int unsigned unfinished_contexts;

    // Never silently discard an accepted transaction. This guard is placed
    // before both signal clearing and queue deletion so every driver_reset()
    // entry point, including a phase jump, has the same fail-fast behavior.
    unfinished_contexts = 0;
    foreach (driver_context_q[i]) begin
        if (driver_context_q[i] == null ||
            driver_context_q[i].tr == null ||
            !driver_context_q[i].tr.write_done) begin
            unfinished_contexts++;
        end
    end
    if (driver_context_q.size() != 0 ||
        outstanding_q.size() != 0 ||
        aw_issue_q.size() != 0 ||
        w_issue_q.size() != 0 ||
        b_wait_q.size() != 0 ||
        axi_master_write_vif.master_awvalid_drv ||
        axi_master_write_vif.master_wvalid_drv ||
        b_state != AXI_MASTER_WRITE_B_IDLE ||
        b_target_valid ||
        bready_delay_cnt != 0 ||
        unfinished_contexts != 0) begin
        `uvm_fatal("AXI_RESET_WITH_PENDING", $sformatf(
            {"Reset would discard pending Master Write work: contexts=%0d ",
             "unfinished=%0d outstanding=%0d aw_q=%0d w_q=%0d b_q=%0d ",
             "AWVALID=%0b WVALID=%0b BREADY=%0b b_state=%s ",
             "b_target_valid=%0b bready_delay=%0d epoch=%0d"},
            driver_context_q.size(), unfinished_contexts,
            outstanding_q.size(), aw_issue_q.size(), w_issue_q.size(),
            b_wait_q.size(), axi_master_write_vif.master_awvalid_drv,
            axi_master_write_vif.master_wvalid_drv,
            axi_master_write_vif.master_bready_drv, b_state.name(),
            b_target_valid, bready_delay_cnt, reset_epoch_id))
    end

    axi_master_write_vif.master_drv_cb.awvalid  <= 1'b0;
    axi_master_write_vif.master_drv_cb.awid     <= '0;
    axi_master_write_vif.master_drv_cb.awaddr   <= '0;
    axi_master_write_vif.master_drv_cb.awlen    <= '0;
    axi_master_write_vif.master_drv_cb.awsize   <= '0;
    axi_master_write_vif.master_drv_cb.awburst  <= '0;
    axi_master_write_vif.master_drv_cb.awlock   <= '0;
    axi_master_write_vif.master_drv_cb.awcache  <= '0;
    axi_master_write_vif.master_drv_cb.awprot   <= '0;
    axi_master_write_vif.master_drv_cb.awqos    <= '0;
    axi_master_write_vif.master_drv_cb.awregion <= '0;
    axi_master_write_vif.master_drv_cb.awuser   <= '0;
    axi_master_write_vif.master_drv_cb.wvalid   <= 1'b0;
    axi_master_write_vif.master_drv_cb.wdata    <= '0;
    axi_master_write_vif.master_drv_cb.wstrb    <= '0;
    axi_master_write_vif.master_drv_cb.wlast    <= 1'b0;
    axi_master_write_vif.master_drv_cb.wuser    <= '0;
    axi_master_write_vif.master_drv_cb.bready   <= 1'b0;

    b_state             = AXI_MASTER_WRITE_B_IDLE;
    bready_delay_cnt    = 0;
    b_target_valid      = 1'b0;
    b_target_bid        = '0;
    cycle_idx           = 0;
    next_seq_no         = 0;
    reset_first_delay_valid = 1'b0;
    reset_first_delay = 0;
    last_aw_hs_valid       = 1'b0;
    last_aw_hs_epoch       = 0;
    last_aw_hs_seq_no      = 0;
    last_aw_hs_cycle       = 0;
    last_wlast_hs_valid    = 1'b0;
    last_wlast_hs_epoch    = 0;
    last_wlast_hs_seq_no   = 0;
    last_wlast_hs_cycle    = 0;
    aw_issue_q.delete();
    w_issue_q.delete();
    driver_context_q.delete();
    outstanding_q.delete();
    b_wait_q.delete();
endtask : driver_reset

task axi_master_write_driver::reset_phase(uvm_phase phase);
    driver_reset();
endtask : reset_phase

task axi_master_write_driver::main_phase(uvm_phase phase);
    driver_reset();
    get_and_drive();
endtask : main_phase

task axi_master_write_driver::get_and_drive();
    forever begin
        @(axi_master_write_vif.master_drv_cb);
        if (!axi_master_write_vif.master_drv_cb.reset) begin
            if (!reset_low_seen) begin
                reset_epoch_id++;
                reset_low_seen = 1'b1;
                driver_reset();
            end
        end
        else begin
            reset_low_seen = 1'b0;
            drive_one_cycle();
        end
    end
endtask : get_and_drive

task axi_master_write_driver::drive_one_cycle();
    bit aw_hs;
    bit w_hs;
    bit b_hs;
    bit sampled_wlast;
    bit sampled_bvalid;
    bit [ID_WIDTH-1:0] sampled_bid;
    bit [1:0] sampled_bresp;
    bit [USER_WIDTH-1:0] sampled_buser;

    if (!reset_first_delay_valid) begin
        if (!axi_master_write_cfg.select_first_delay(
                reset_first_delay)) begin
            `uvm_fatal("AXI_DRIVER_CONFIG",
                "Failed to select reset-to-first-write-source-VALID delay")
        end
        reset_first_delay_valid = 1'b1;
        `uvm_info("AXI_MASTER_WRITE_FIRST_START_DELAY",
            $sformatf("Selected first_delay=%0d for reset epoch %0d",
                reset_first_delay, reset_epoch_id),
            UVM_HIGH)
    end

    cycle_idx++;

    // One edge has a strict order: sample old handshakes, release B capacity,
    // update/pop AW and W heads, enqueue newly B-eligible requests, accept one
    // owned request clone, schedule new heads, reserve capacity, then commit.
    aw_hs          = axi_master_write_vif.master_awvalid_drv &&
                     axi_master_write_vif.master_drv_cb.awready;
    w_hs           = axi_master_write_vif.master_wvalid_drv &&
                     axi_master_write_vif.master_drv_cb.wready;
    b_hs           = axi_master_write_vif.master_drv_cb.bvalid &&
                     axi_master_write_vif.master_bready_drv;
    sampled_wlast  = axi_master_write_vif.master_wlast_drv;
    sampled_bvalid = axi_master_write_vif.master_drv_cb.bvalid;
    sampled_bid    = axi_master_write_vif.master_drv_cb.bid;
    sampled_bresp  = axi_master_write_vif.master_drv_cb.bresp;
    sampled_buser  = axi_master_write_vif.master_drv_cb.buser;

    if (b_hs) begin
        complete_b_response(sampled_bid, sampled_bresp, sampled_buser);
    end
    sample_source_handshakes(aw_hs, w_hs, sampled_wlast);
    accept_item_cycle();
    drive_source_outputs();
    drive_b_channel_cycle(b_hs, sampled_bvalid, sampled_bid);
endtask : drive_one_cycle

task axi_master_write_driver::accept_item_cycle();
    uvm_object clone_obj;
    item_t owned_req;
    item_t next_req;
    context_t new_ctx;

    // Bound prefetching while still keeping enough queued work to expose AW/W
    // overlap. Active/reserved requests remain in driver_context_q until B.
    if (driver_context_q.size() >=
        axi_master_write_cfg.write_outstanding_depth + 2) begin
        return;
    end

    next_req = null;
    seq_item_port.try_next_item(next_req);
    if (next_req == null) begin
        return;
    end

    if (!prepare_request(next_req)) begin
        next_req.prepare_status = AXI_PREPARE_NO_CANDIDATE;
        seq_item_port.item_done();
        next_req = null;
        return;
    end

    clone_obj = next_req.clone();
    if (!$cast(owned_req, clone_obj) || owned_req == null) begin
        next_req.prepare_status = AXI_PREPARE_NO_CANDIDATE;
        next_req.prepare_reason = AXI_PREPARE_REASON_INTERNAL;
        seq_item_port.item_done();
        next_req = null;
        `uvm_fatal("AXI_DRIVER_INTERNAL",
            "reason=PREPARED_CLONE_FAILED role=MASTER_WRITE channel=AW_W stage=QUEUE observed={clone cast failed or returned null} expected={prepared request clone is axi_master_write_seq_item specialization} action=STOP_SIMULATION")
        return;
    end

    new_ctx = new(owned_req, reset_epoch_id, next_seq_no);
    next_seq_no++;
    driver_context_q.push_back(new_ctx);
    aw_issue_q.push_back(new_ctx);
    w_issue_q.push_back(new_ctx);

    `uvm_info("AXI_MASTER_WRITE_DRV",
        $sformatf({"Accepted owned AXI write clone epoch=%0d seq=%0d buffered=%0d ",
                   "outstanding=%0d/%0d order=%s aw_w_delay=%0d ",
                   "pkg_delay=%0d w_delay=%p:\n%s"},
            new_ctx.reset_epoch_id, new_ctx.seq_no,
            driver_context_q.size(), outstanding_q.size(),
            axi_master_write_cfg.write_outstanding_depth,
            owned_req.aw_w_order.name(), owned_req.aw_w_delay,
            owned_req.pkg_delay, owned_req.w_delay, owned_req.sprint()),
        UVM_HIGH)

    seq_item_port.item_done();
endtask : accept_item_cycle

function bit axi_master_write_driver::request_geometry_is_legal(
    item_t item,
    bit                      enforce_segment,
    mem_segment_s            segment
);
    if (item == null) begin
        return 1'b0;
    end
    return candidate_geometry_is_legal(
        item, item.awaddr, item.awsize, enforce_segment, segment);
endfunction : request_geometry_is_legal

function bit axi_master_write_driver::candidate_geometry_is_legal(
    item_t item,
    bit [ADDR_WIDTH-1:0] candidate_addr,
    bit [2:0]                candidate_size,
    bit                      enforce_segment,
    mem_segment_s            segment
);
    return candidate_geometry_rule(
        item, candidate_addr, candidate_size,
        enforce_segment, segment) == AXI_REQUEST_RULE_OK;
endfunction : candidate_geometry_is_legal

function axi_request_rule_e axi_master_write_driver::candidate_geometry_rule(
    item_t item,
    bit [ADDR_WIDTH-1:0] candidate_addr,
    bit [2:0]                candidate_size,
    bit                      enforce_segment,
    mem_segment_s            segment
);
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;
    axi_request_rule_e rule;

    if (item == null) begin
        return AXI_REQUEST_RULE_NULL_CONTEXT;
    end
    rule = burst_math_t::get_request_geometry_rule(
        candidate_addr, item.awlen, candidate_size,
        axi_burst_e'(item.awburst), AXI_MASTER_WRITE_MAX_BEATS,
        item.awlock, axi_master_write_cfg.addr_4k_protect_enable,
        low_addr, high_addr);
    if (rule != AXI_REQUEST_RULE_OK) begin
        return rule;
    end
    if (enforce_segment &&
        (mem_addr_t'(low_addr) < segment.start_addr ||
         mem_addr_t'(high_addr) > segment.end_addr)) begin
        return AXI_REQUEST_RULE_OUTSIDE_SEGMENT;
    end
    return AXI_REQUEST_RULE_OK;
endfunction : candidate_geometry_rule

function axi_addr_search_status_e axi_master_write_driver::find_addr_in_segment_status(
    item_t item,
    mem_segment_s            segment,
    bit [2:0]                selected_size,
    bit                      select_random,
    output bit [ADDR_WIDTH-1:0] selected_addr,
    output bit [64:0]        candidate_count
);
    mem_addr_t first_page;
    mem_addr_t last_page;
    mem_addr_t candidate;
    bit [64:0] slot_count;
    bit [64:0] total_slots;
    bit [64:0] selected_slot;
    bit [64:0] random_domain;
    bit [64:0] accept_limit;
    bit [63:0] random_value;

    selected_addr = '0;
    candidate_count = '0;
    total_slots = 0;
    for (int unsigned offset = 0; offset < 4096; offset++) begin
        if (!offset_is_selected(item, offset, selected_size) ||
            !get_page_range_for_offset(item, segment, selected_size,
                offset, first_page, last_page)) begin
            continue;
        end
        slot_count = ({1'b0, (last_page - first_page)} / 4096) + 1;
        if (slot_count > {1'b1, {64{1'b0}}} ||
            total_slots > {1'b1, {64{1'b0}}} - slot_count) begin
            candidate_count = total_slots;
            return AXI_ADDR_SEARCH_COUNT_OVERFLOW;
        end
        total_slots += slot_count;
    end
    candidate_count = total_slots;
    if (total_slots == 0) begin
        return AXI_ADDR_SEARCH_EMPTY;
    end
    random_domain = {1'b1, {64{1'b0}}};
    if (!select_random) begin
        selected_slot = '0;
    end
    else if (total_slots == random_domain) begin
        random_value = {$urandom(), $urandom()};
        selected_slot = {1'b0, random_value};
    end
    else begin
        // Rejection sampling keeps every slot exactly equiprobable; a direct
        // 64-bit modulo would bias the low slots unless total_slots divided
        // the complete 2^64 random domain.
        accept_limit = (random_domain / total_slots) * total_slots;
        do begin
            random_value = {$urandom(), $urandom()};
        end while ({1'b0, random_value} >= accept_limit);
        selected_slot = {1'b0, random_value} % total_slots;
    end
    for (int unsigned offset = 0; offset < 4096; offset++) begin
        if (!offset_is_selected(item, offset, selected_size) ||
            !get_page_range_for_offset(item, segment, selected_size,
                offset, first_page, last_page)) begin
            continue;
        end
        slot_count = ({1'b0, (last_page - first_page)} / 4096) + 1;
        if (selected_slot < slot_count) begin
            candidate = first_page + selected_slot[63:0] * 4096 + offset;
            selected_addr = candidate;
            return AXI_ADDR_SEARCH_FOUND;
        end
        selected_slot -= slot_count;
    end
    return AXI_ADDR_SEARCH_EMPTY;
endfunction : find_addr_in_segment_status

function bit axi_master_write_driver::offset_is_selected(
    item_t item,
    int unsigned              offset,
    bit [2:0]                 selected_size
);
    int unsigned raw_min;
    int unsigned raw_max;
    int unsigned beat_bytes;

    case (item.awaddr_offset_type)
        AXI_MASTER_WRITE_ADDR_OFFSET_ZERO: begin
            raw_min = 12'h000; raw_max = 12'h000;
        end
        AXI_MASTER_WRITE_ADDR_OFFSET_LOW: begin
            raw_min = 12'h001; raw_max = 12'h0ff;
        end
        AXI_MASTER_WRITE_ADDR_OFFSET_NORMAL: begin
            raw_min = 12'h100; raw_max = 12'hfef;
        end
        AXI_MASTER_WRITE_ADDR_OFFSET_HIGH: begin
            raw_min = 12'hff0; raw_max = 12'hffe;
        end
        AXI_MASTER_WRITE_ADDR_OFFSET_MAX_VALUE: begin
            raw_min = 12'hfff; raw_max = 12'hfff;
        end
        default: return 1'b0;
    endcase
    if (!axi_master_write_cfg.align_size) begin
        return offset >= raw_min && offset <= raw_max;
    end
    beat_bytes = 1 << selected_size;
    return (offset % beat_bytes) == 0 && offset <= raw_max &&
        (offset + beat_bytes - 1) >= raw_min;
endfunction : offset_is_selected

function bit axi_master_write_driver::get_page_range_for_offset(
    item_t item,
    mem_segment_s            segment,
    bit [2:0]                selected_size,
    int unsigned             offset,
    output mem_addr_t        first_page,
    output mem_addr_t        last_page
);
    mem_addr_t effective_end;
    mem_addr_t page_base;
    mem_addr_t candidate;
    int unsigned max_page_steps;
    int unsigned page_steps;

    first_page = '0;
    last_page = '0;
    if (segment.start_addr > ADDR_MAX) begin
        return 1'b0;
    end
    effective_end = (segment.end_addr > ADDR_MAX) ?
        ADDR_MAX : segment.end_addr;
    max_page_steps =
        (burst_math_t::get_access_bytes(
            item.awlen, selected_size, axi_burst_e'(item.awburst)) + 4095) /
        4096 + 1;

    page_base = (segment.start_addr / 4096) * 4096;
    candidate = page_base + offset;
    if (candidate > effective_end ||
        !candidate_geometry_is_legal(item,
            candidate, selected_size,
            1'b0, segment)) begin
        return 1'b0;
    end
    page_steps = 0;
    while (candidate <= effective_end &&
           !candidate_geometry_is_legal(item,
               candidate, selected_size,
               1'b1, segment) &&
           page_steps < max_page_steps) begin
        if (page_base > effective_end ||
            (effective_end - page_base) < 4096) begin
            break;
        end
        page_base += 4096;
        page_steps++;
        candidate = page_base + offset;
    end
    if (candidate > effective_end ||
        !candidate_geometry_is_legal(item,
            candidate, selected_size,
            1'b1, segment)) begin
        return 1'b0;
    end
    first_page = page_base;

    page_base = (effective_end / 4096) * 4096;
    candidate = page_base + offset;
    page_steps = 0;
    while (page_base >= first_page &&
           (candidate > effective_end ||
            !candidate_geometry_is_legal(item,
                candidate, selected_size,
                1'b1, segment)) &&
           page_steps < max_page_steps) begin
        if (page_base < 4096) break;
        page_base -= 4096;
        page_steps++;
        candidate = page_base + offset;
    end
    if (page_base < first_page || candidate > effective_end ||
        !candidate_geometry_is_legal(item,
            candidate, selected_size,
            1'b1, segment)) begin
        return 1'b0;
    end
    last_page = page_base;
    return 1'b1;
endfunction : get_page_range_for_offset

function bit axi_master_write_driver::select_segment_by_response(
    item_t item,
    output mem_segment_s      segment,
    output int signed         segment_index
);
    int unsigned eligible[$];
    mem_segment_s candidate_segment;
    int unsigned selected;

    segment = '{default: '0};
    segment_index = -1;
    for (int unsigned i = 0;
         i < axi_master_write_cfg.memory_model.segment_count(); i++) begin
        if (!axi_master_write_cfg.memory_model.get_segment(
                i, candidate_segment)) begin
            continue;
        end
        if (axi_master_write_cfg.memory_model.predict_write_exception(
                1, candidate_segment.start_addr) ==
            item.desired_mem_response) begin
            eligible.push_back(i);
        end
    end
    if (eligible.size() == 0) begin
        return 1'b0;
    end
    selected = eligible[$urandom_range(eligible.size() - 1, 0)];
    segment_index = int'(selected);
    return axi_master_write_cfg.memory_model.get_segment(selected, segment);
endfunction : select_segment_by_response

function bit axi_master_write_driver::reject_request(
    item_t item,
    axi_prepare_reason_e      reason,
    axi_request_rule_e        rule,
    string                    expected,
    string                    detail
);
    string observed;
    string full_detail;

    if (item == null) begin
        observed = "item=null";
    end
    else begin
        item.prepare_status = AXI_PREPARE_NO_CANDIDATE;
        item.prepare_reason = reason;
        observed = $sformatf(
            {"AWID=0x%0h AWADDR=0x%0h AWLEN=%0d AWSIZE=%0d ",
             "AWBURST=%0d AWLOCK=%0b AWCACHE=0x%0h ",
             "order=%0d aw_w_delay=%0d ",
             "pkg_delay=%0d bready_delay=%0d desired_response=%s ",
             "response_intent_valid=%0b expect_size_error=%0b ",
             "size_intent_valid=%0b"},
            item.awid, item.awaddr, item.awlen, item.awsize,
            item.awburst, item.awlock, item.awcache, item.aw_w_order,
            item.aw_w_delay, item.pkg_delay, item.bready_delay,
            item.desired_mem_response.name(),
            item.desired_mem_response_valid, item.expect_size_error,
            item.size_intent_valid);
    end
    full_detail = $sformatf("rule=%s %s", rule.name(), detail);
    `uvm_error("AXI_REQUEST_PREPARE_FAILED",
        axi_diag::format(reason.name(), "MASTER_WRITE", "AW_W",
            "REQUEST_PREPARE", observed, expected,
            "REJECT_BEFORE_AWVALID_OR_WVALID", full_detail))
    return 1'b0;
endfunction : reject_request

function bit axi_master_write_driver::range_supports_size(
    mem_addr_t low_addr,
    mem_addr_t high_addr,
    bit [2:0]  size
);
    mem_segment_s segment;

    for (int unsigned i = 0;
         i < axi_master_write_cfg.memory_model.segment_count(); i++) begin
        if (axi_master_write_cfg.memory_model.get_segment(i, segment) &&
            low_addr <= segment.end_addr && high_addr >= segment.start_addr &&
            !segment.supported_size_mask[size]) begin
            return 1'b0;
        end
    end
    return 1'b1;
endfunction : range_supports_size

function void axi_master_write_driver::rebuild_derived_payload(
    item_t item
);
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [DATA_WIDTH-1:0] beat_data;

    if (!axi_master_write_cfg.fix_wstrb_enable &&
        !axi_master_write_cfg.fix_wstrb_array_enable) begin
        foreach (item.wstrb[i]) begin
            // Preserve the per-beat random subset selected by the item while
            // removing lanes that are illegal for the final Mem geometry.
            item.wstrb[i] &= burst_math_t::get_byte_lane_mask(
                item.awaddr, item.awlen, item.awsize,
                axi_burst_e'(item.awburst), i);
        end
    end
    if (!axi_master_write_cfg.fix_wdata_enable &&
        !axi_master_write_cfg.fix_wdata_array_enable) begin
        if (item.wdata_type == AXI_MASTER_WRITE_DATA_ADDR_BASED) begin
            foreach (item.wdata[i]) begin
                beat_addr = burst_math_t::get_beat_addr(
                    item.awaddr, item.awlen, item.awsize,
                    axi_burst_e'(item.awburst), i);
                beat_data = '0;
                beat_data = beat_addr;
                item.wdata[i] = beat_data;
            end
        end
    end
endfunction : rebuild_derived_payload

function bit axi_master_write_driver::payload_and_timing_are_legal(
    item_t item
);
    int signed failing_index;

    return payload_and_timing_rule(item, failing_index) ==
        AXI_REQUEST_RULE_OK;
endfunction : payload_and_timing_are_legal

function axi_request_rule_e axi_master_write_driver::payload_and_timing_rule(
    item_t item,
    output int signed         failing_index
);
    int unsigned expected_beats;
    bit [STRB_WIDTH-1:0] legal_mask;

    failing_index = -1;
    if (item == null) begin
        return AXI_REQUEST_RULE_NULL_CONTEXT;
    end

    expected_beats = int'(item.awlen) + 1;
    if (item.wdata.size() != expected_beats) begin
        return AXI_REQUEST_RULE_WDATA_COUNT;
    end
    if (item.wstrb.size() != expected_beats) begin
        return AXI_REQUEST_RULE_WSTRB_COUNT;
    end
    if (item.wuser.size() != expected_beats) begin
        return AXI_REQUEST_RULE_WUSER_COUNT;
    end
    if (item.w_delay.size() != item.awlen) begin
        return AXI_REQUEST_RULE_WDELAY_COUNT;
    end
    if (!(item.wdata_type inside {
            AXI_MASTER_WRITE_DATA_RANDOM,
            AXI_MASTER_WRITE_DATA_INCREMENT,
            AXI_MASTER_WRITE_DATA_ADDR_BASED})) begin
        return AXI_REQUEST_RULE_WDATA_TYPE;
    end

    if (item.aw_w_order == AXI_MASTER_WRITE_AW_W_SAME) begin
        if (item.aw_w_delay != 0) begin
            return AXI_REQUEST_RULE_AW_W_DELAY;
        end
    end
    else if (item.aw_w_order inside {
            AXI_MASTER_WRITE_AW_FIRST,
            AXI_MASTER_WRITE_W_FIRST}) begin
        if (!(item.aw_w_delay inside {[1:63]})) begin
            return AXI_REQUEST_RULE_AW_W_DELAY;
        end
    end
    else begin
        return AXI_REQUEST_RULE_AW_W_ORDER;
    end

    if (item.pkg_delay > 63 || item.bready_delay > 63) begin
        return AXI_REQUEST_RULE_WRITE_DELAY_RANGE;
    end
    if (axi_master_write_cfg.bready_mode ==
            AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH &&
        item.bready_delay != 0) begin
        return AXI_REQUEST_RULE_BREADY_MODE_CONFLICT;
    end
    foreach (item.w_delay[i]) begin
        if (item.w_delay[i] > 63) begin
            failing_index = int'(i);
            return AXI_REQUEST_RULE_WRITE_DELAY_RANGE;
        end
    end

    foreach (item.wstrb[i]) begin
        legal_mask = burst_math_t::get_byte_lane_mask(
            item.awaddr, item.awlen, item.awsize,
            axi_burst_e'(item.awburst), i);
        if ((item.wstrb[i] & ~legal_mask) != '0) begin
            failing_index = int'(i);
            return AXI_REQUEST_RULE_WSTRB_LANE;
        end
    end

    return AXI_REQUEST_RULE_OK;
endfunction : payload_and_timing_rule

function bit axi_master_write_driver::prepare_request(
    item_t item
);
    mem_segment_s segment;
    bit [2:0] size_candidates[$];
    bit [ADDR_WIDTH-1:0] candidate_addr;
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;
    bit [64:0] candidate_count;
    int unsigned selected;
    int signed segment_index;
    int signed failing_index;
    mem_resp_e address_response;
    axi_request_rule_e rule;
    axi_addr_search_status_e search_status;
    bit random_mem_address;

    if (item == null) begin
        return reject_request(item, AXI_PREPARE_REASON_NULL_ITEM,
            AXI_REQUEST_RULE_NULL_CONTEXT,
            "non-null axi_master_write_seq_item specialization",
            "Driver received a null request handle");
    end

    item.prepare_status = AXI_PREPARE_NOT_RUN;
    item.prepare_reason = AXI_PREPARE_REASON_NONE;
    item.predicted_mem_response = MEM_RESP_OKAY;
    item.predicted_mem_response_valid = 1'b0;
    item.predicted_mem_access_bytes = 0;
    random_mem_address = axi_master_write_cfg.use_mem_model &&
        !axi_master_write_cfg.fix_awaddr_enable;

    if (!axi_cache_is_legal(item.awcache)) begin
        return reject_request(item, AXI_PREPARE_REASON_CACHE_RESERVED,
            AXI_REQUEST_RULE_CACHE_RESERVED,
            AXI_CACHE_LEGAL_EXPECTED,
            $sformatf({"AWCACHE=0x%0h is an AXI4 reserved encoding; ",
                       "the Driver does not rewrite or retry fixed fields"},
                item.awcache));
    end

    if (!axi_master_write_cfg.use_mem_model) begin
        rule = candidate_geometry_rule(
            item, item.awaddr, item.awsize, 1'b0, segment);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
                rule, "legal AXI write geometry before source VALID",
                $sformatf("addr_4k_protect_enable=%0b",
                    axi_master_write_cfg.addr_4k_protect_enable));
        end
        rule = payload_and_timing_rule(item, failing_index);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item,
                AXI_PREPARE_REASON_PAYLOAD_TIMING, rule,
                {"WDATA/WSTRB/WUSER count=AWLEN+1, W delay count=AWLEN, ",
                 "legal timing/order/data type and WSTRB lanes"},
                $sformatf("WDATA=%0d WSTRB=%0d WUSER=%0d W_DELAY=%0d failing_index=%0d w_delay=%p",
                    item.wdata.size(), item.wstrb.size(), item.wuser.size(),
                    item.w_delay.size(), failing_index, item.w_delay));
        end
        item.prepare_status = AXI_PREPARE_OK;
        item.prepare_reason = AXI_PREPARE_REASON_NONE;
        return 1'b1;
    end

    if (axi_master_write_cfg.memory_model == null) begin
        return reject_request(item, AXI_PREPARE_REASON_MODEL_NULL,
            AXI_REQUEST_RULE_NULL_CONTEXT,
            "use_mem_model=1 requires memory_model!=null",
            "axi_master_write_cfg.memory_model is null");
    end

    // A fixed address is authoritative.  SIZE is likewise already final: it
    // is either cfg-fixed or selected from the ordinary SIZE distribution by
    // the sequence item.  Do not require one containing Segment and do not
    // rewrite either field; predict the complete final byte range instead.
    if (axi_master_write_cfg.fix_awaddr_enable) begin
        rule = candidate_geometry_rule(
            item, item.awaddr, item.awsize, 1'b0, segment);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
                rule, "fixed AWADDR and selected AWSIZE form legal geometry",
                "Fixed address and SIZE are authoritative and are not modified");
        end
    end
    else begin
        if (!item.desired_mem_response_valid) begin
            return reject_request(item, AXI_PREPARE_REASON_INTERNAL,
                AXI_REQUEST_RULE_INTERNAL,
                "random-address Mem request has a valid response intent",
                "desired_mem_response_valid=0");
        end
        if (axi_master_write_cfg.memory_model.segment_count() == 0) begin
            return reject_request(item,
                AXI_PREPARE_REASON_SEGMENT_MAP_EMPTY,
                AXI_REQUEST_RULE_INTERNAL,
                "at least one Segment for random-address Mem materialization",
                "memory_model.segment_count()=0");
        end
        if (!select_segment_by_response(item, segment, segment_index)) begin
            return reject_request(item,
                AXI_PREPARE_REASON_RESPONSE_TARGET_EMPTY,
                AXI_REQUEST_RULE_INTERNAL,
                $sformatf("a Segment whose write response is %s",
                    item.desired_mem_response.name()),
                $sformatf("segment_count=%0d; Segment selection never filters by SIZE or geometry",
                    axi_master_write_cfg.memory_model.segment_count()));
        end

        if (axi_master_write_cfg.fix_awsize_enable) begin
            if (item.size_intent_valid) begin
                return reject_request(item, AXI_PREPARE_REASON_INTERNAL,
                    AXI_REQUEST_RULE_INTERNAL,
                    "fixed AWSIZE bypasses supported/unsupported size intent",
                    "size_intent_valid=1 while fix_awsize_enable=1");
            end
        end
        else begin
            if (!item.size_intent_valid) begin
                return reject_request(item, AXI_PREPARE_REASON_INTERNAL,
                    AXI_REQUEST_RULE_INTERNAL,
                    "unfixed SIZE in random-address Mem mode has size intent",
                    "size_intent_valid=0");
            end
            for (int unsigned size = 0;
                 size <= BUS_SIZE; size++) begin
                if (segment.supported_size_mask[size] ==
                    !item.expect_size_error) begin
                    size_candidates.push_back(size[2:0]);
                end
            end
            if (size_candidates.size() == 0) begin
                return reject_request(item,
                    AXI_PREPARE_REASON_SIZE_TARGET_EMPTY,
                    AXI_REQUEST_RULE_INTERNAL,
                    $sformatf("at least one %s AWSIZE in [0:%0d]",
                        item.expect_size_error ? "unsupported" : "supported",
                        BUS_SIZE),
                    $sformatf({"segment_index=%0d range=[0x%0h:0x%0h] ",
                               "supported_size_mask=0x%02h"},
                        segment_index, segment.start_addr, segment.end_addr,
                        segment.supported_size_mask));
            end
            selected = $urandom_range(size_candidates.size() - 1, 0);
            item.awsize = size_candidates[selected];
        end

        rule = burst_math_t::get_address_independent_rule(
            item.awlen, item.awsize, axi_burst_e'(item.awburst),
            AXI_MASTER_WRITE_MAX_BEATS, item.awlock);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_BASE_GEOMETRY,
                rule, "BURST/LEN/SIZE/LOCK geometry legal before address search",
                $sformatf("segment_index=%0d selected_SIZE=%0d",
                    segment_index, item.awsize));
        end

        search_status = find_addr_in_segment_status(
            item, segment, item.awsize, 1'b1,
            candidate_addr, candidate_count);
        if (search_status == AXI_ADDR_SEARCH_COUNT_OVERFLOW) begin
            return reject_request(item,
                AXI_PREPARE_REASON_ADDR_COUNT_OVERFLOW,
                AXI_REQUEST_RULE_ADDRESS_OVERFLOW,
                "address candidate count fits in the 2^64 Mem address domain",
                $sformatf({"segment_index=%0d range=[0x%0h:0x%0h] ",
                           "selected_SIZE=%0d partial_candidate_count=%0d"},
                    segment_index, segment.start_addr, segment.end_addr,
                    item.awsize, candidate_count));
        end
        if (search_status != AXI_ADDR_SEARCH_FOUND) begin
            return reject_request(item,
                AXI_PREPARE_REASON_ADDR_TARGET_EMPTY,
                AXI_REQUEST_RULE_INTERNAL,
                "at least one final address for the already selected Segment and SIZE",
                $sformatf({"segment_index=%0d range=[0x%0h:0x%0h] ",
                           "selected_SIZE=%0d offset_type=%s align_size=%0b ",
                           "addr_4k_protect_enable=%0b"},
                    segment_index, segment.start_addr, segment.end_addr,
                    item.awsize, item.awaddr_offset_type.name(),
                    axi_master_write_cfg.align_size,
                    axi_master_write_cfg.addr_4k_protect_enable));
        end
        item.awaddr = candidate_addr;
        item.awaddr_offset = item.awaddr[11:0];
        rule = candidate_geometry_rule(
            item, item.awaddr, item.awsize, 1'b1, segment);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
                rule, "final Mem address remains inside selected Segment and legal AXI geometry",
                $sformatf("segment_index=%0d range=[0x%0h:0x%0h]",
                    segment_index, segment.start_addr, segment.end_addr));
        end
    end

    if (!burst_math_t::get_access_range(
            item.awaddr, item.awlen, item.awsize,
            axi_burst_e'(item.awburst), low_addr, high_addr)) begin
        return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
            AXI_REQUEST_RULE_ADDRESS_OVERFLOW,
            "final write footprint is representable in configured ADDR_WIDTH",
            "get_access_range returned false after final geometry check");
    end
    address_response = axi_master_write_cfg.memory_model.predict_write_exception(
        int'(high_addr - low_addr) + 1, mem_addr_t'(low_addr));
    item.predicted_mem_response = address_response;
    if (address_response != MEM_RESP_DECERR &&
        !range_supports_size(mem_addr_t'(low_addr),
            mem_addr_t'(high_addr), item.awsize)) begin
        item.predicted_mem_response = MEM_RESP_SLVERR;
    end
    item.predicted_mem_response_valid = 1'b1;
    item.predicted_mem_access_bytes = int'(high_addr - low_addr) + 1;
    if (random_mem_address) begin
        // Automatic WSTRB and ADDR_BASED WDATA were intentionally deferred by
        // post_randomize(); construct them once from the final Mem geometry.
        rebuild_derived_payload(item);
    end
    rule = payload_and_timing_rule(item, failing_index);
    if (rule != AXI_REQUEST_RULE_OK) begin
        return reject_request(item,
            AXI_PREPARE_REASON_PAYLOAD_TIMING, rule,
            {"WDATA/WSTRB/WUSER count=AWLEN+1, W delay count=AWLEN, ",
             "legal timing/order/data type and WSTRB lanes"},
            $sformatf("WDATA=%0d WSTRB=%0d WUSER=%0d W_DELAY=%0d failing_index=%0d w_delay=%p",
                item.wdata.size(), item.wstrb.size(), item.wuser.size(),
                item.w_delay.size(), failing_index, item.w_delay));
    end
    item.prepare_status = AXI_PREPARE_OK;
    item.prepare_reason = AXI_PREPARE_REASON_NONE;
    return 1'b1;
endfunction : prepare_request

task axi_master_write_driver::sample_source_handshakes(
    input bit aw_hs,
    input bit w_hs,
    input bit sampled_wlast
);
    context_t aw_ctx;
    context_t w_ctx;
    context_t popped_ctx;

    aw_ctx = (aw_issue_q.size() == 0) ? null : aw_issue_q[0];
    w_ctx  = (w_issue_q.size() == 0) ? null : w_issue_q[0];

    if (aw_hs) begin
        if (aw_ctx == null || !aw_ctx.aw_issued || aw_ctx.aw_done) begin
            `uvm_fatal("AWFIFO", "AW handshake has no matching issued AW FIFO head")
        end
        aw_ctx.aw_done            = 1'b1;
        aw_ctx.aw_handshake_cycle = cycle_idx;
        popped_ctx = aw_issue_q.pop_front();
        if (popped_ctx != aw_ctx) begin
            `uvm_fatal("AWFIFO", "AW FIFO pop changed transaction ownership")
        end
        last_aw_hs_valid  = 1'b1;
        last_aw_hs_epoch  = aw_ctx.reset_epoch_id;
        last_aw_hs_seq_no = aw_ctx.seq_no;
        last_aw_hs_cycle  = cycle_idx;
        activate_outstanding(aw_ctx);
    end

    if (w_hs) begin
        if (w_ctx == null || !w_ctx.w_issued || w_ctx.w_done) begin
            `uvm_fatal("WFIFO", "W handshake has no matching issued W FIFO head")
        end
        activate_outstanding(w_ctx);
        if (sampled_wlast) begin
            if (w_ctx.beat_idx != w_ctx.beat_num - 1) begin
                `uvm_fatal("WLAST", "Driven WLAST does not match the final W beat")
            end
            w_ctx.w_done                   = 1'b1;
            w_ctx.wlast_handshake_cycle    = cycle_idx;
            w_ctx.next_beat_wait_valid     = 1'b0;
            popped_ctx = w_issue_q.pop_front();
            if (popped_ctx != w_ctx) begin
                `uvm_fatal("WFIFO", "W FIFO pop changed transaction ownership")
            end
            last_wlast_hs_valid  = 1'b1;
            last_wlast_hs_epoch  = w_ctx.reset_epoch_id;
            last_wlast_hs_seq_no = w_ctx.seq_no;
            last_wlast_hs_cycle  = cycle_idx;
        end
        else begin
            if (w_ctx.beat_idx >= w_ctx.beat_num - 1) begin
                `uvm_fatal("WLAST", "Final W beat handshook without WLAST")
            end
            if (w_ctx.beat_idx >= w_ctx.tr.w_delay.size()) begin
                `uvm_fatal("WDELAY", $sformatf(
                    "Missing W delay for beat gap %0d; delay_count=%0d",
                    w_ctx.beat_idx, w_ctx.tr.w_delay.size()))
            end
            w_ctx.next_beat_wait_valid     = 1'b1;
            w_ctx.next_beat_eligible_cycle =
                cycle_idx + w_ctx.tr.w_delay[w_ctx.beat_idx];
            w_ctx.beat_idx++;
        end
    end

    queue_b_if_ready(aw_ctx);
    if (w_ctx != aw_ctx) begin
        queue_b_if_ready(w_ctx);
    end
endtask : sample_source_handshakes

function bit axi_master_write_driver::capture_pkg_anchor(
    context_t ctx
);
    longint unsigned anchor_cycle;

    if (ctx == null) begin
        return 1'b0;
    end
    if (ctx.pkg_anchor_captured) begin
        return 1'b1;
    end

    if (ctx.seq_no == 0) begin
        // cycle 1 is the first active edge after reset release. A late request
        // observes an already-expired deadline and can issue immediately.
        ctx.first_eligible_cycle = reset_first_delay + 1;
        ctx.pkg_anchor_captured  = 1'b1;
        return 1'b1;
    end

    case (ctx.tr.aw_w_order)
        AXI_MASTER_WRITE_AW_FIRST: begin
            if (!last_aw_hs_valid ||
                last_aw_hs_epoch != ctx.reset_epoch_id ||
                last_aw_hs_seq_no + 1 != ctx.seq_no) begin
                return 1'b0;
            end
            anchor_cycle = last_aw_hs_cycle;
        end

        AXI_MASTER_WRITE_W_FIRST: begin
            if (!last_wlast_hs_valid ||
                last_wlast_hs_epoch != ctx.reset_epoch_id ||
                last_wlast_hs_seq_no + 1 != ctx.seq_no) begin
                return 1'b0;
            end
            anchor_cycle = last_wlast_hs_cycle;
        end

        AXI_MASTER_WRITE_AW_W_SAME: begin
            if (!last_aw_hs_valid || !last_wlast_hs_valid ||
                last_aw_hs_epoch != ctx.reset_epoch_id ||
                last_wlast_hs_epoch != ctx.reset_epoch_id ||
                last_aw_hs_seq_no + 1 != ctx.seq_no ||
                last_wlast_hs_seq_no + 1 != ctx.seq_no) begin
                return 1'b0;
            end
            anchor_cycle = (last_aw_hs_cycle >= last_wlast_hs_cycle) ?
                last_aw_hs_cycle : last_wlast_hs_cycle;
        end

        default: begin
            `uvm_fatal("AWWORDER", "Unsupported aw_w_order in driver context")
            return 1'b0;
        end
    endcase

    ctx.first_eligible_cycle = anchor_cycle + ctx.tr.pkg_delay;
    ctx.pkg_anchor_captured  = 1'b1;
    return 1'b1;
endfunction : capture_pkg_anchor

function bit axi_master_write_driver::is_aw_head(
    context_t ctx
);
    return ctx != null && aw_issue_q.size() != 0 && aw_issue_q[0] == ctx;
endfunction : is_aw_head

function bit axi_master_write_driver::is_w_head(
    context_t ctx
);
    return ctx != null && w_issue_q.size() != 0 && w_issue_q[0] == ctx;
endfunction : is_w_head

task axi_master_write_driver::drive_source_outputs();
    context_t aw_ctx;
    context_t w_ctx;
    bit next_awvalid;
    bit [ID_WIDTH-1:0] next_awid;
    bit [ADDR_WIDTH-1:0] next_awaddr;
    bit [7:0] next_awlen;
    bit [2:0] next_awsize;
    bit [1:0] next_awburst;
    bit next_awlock;
    bit [3:0] next_awcache;
    bit [2:0] next_awprot;
    bit [3:0] next_awqos;
    bit [3:0] next_awregion;
    bit [USER_WIDTH-1:0] next_awuser;
    bit next_wvalid;
    bit [DATA_WIDTH-1:0] next_wdata;
    bit [STRB_WIDTH-1:0] next_wstrb;
    bit next_wlast;
    bit [USER_WIDTH-1:0] next_wuser;

    aw_ctx = (aw_issue_q.size() == 0) ? null : aw_issue_q[0];
    w_ctx  = (w_issue_q.size() == 0) ? null : w_issue_q[0];

    // A SAME packet starts atomically and only while it owns both FIFO heads.
    if (aw_ctx != null && aw_ctx == w_ctx &&
        aw_ctx.tr.aw_w_order == AXI_MASTER_WRITE_AW_W_SAME &&
        !aw_ctx.aw_issued && !aw_ctx.w_issued &&
        capture_pkg_anchor(aw_ctx) &&
        cycle_idx >= aw_ctx.first_eligible_cycle &&
        can_reserve_outstanding_slot(aw_ctx)) begin
        reserve_outstanding_slot(aw_ctx);
        aw_ctx.aw_issued      = 1'b1;
        aw_ctx.w_issued       = 1'b1;
        aw_ctx.aw_issue_cycle = cycle_idx;
        aw_ctx.w_issue_cycle  = cycle_idx;
    end

    // AW lead or AW trailing W. A trailing channel uses an earliest deadline;
    // waiting for its FIFO head concurrently consumes the configured delay.
    if (aw_ctx != null && !aw_ctx.aw_issued) begin
        if (aw_ctx.tr.aw_w_order == AXI_MASTER_WRITE_AW_FIRST &&
            capture_pkg_anchor(aw_ctx) &&
            cycle_idx >= aw_ctx.first_eligible_cycle &&
            can_reserve_outstanding_slot(aw_ctx)) begin
            reserve_outstanding_slot(aw_ctx);
            aw_ctx.aw_issued      = 1'b1;
            aw_ctx.aw_issue_cycle = cycle_idx;
        end
        else if (aw_ctx.tr.aw_w_order == AXI_MASTER_WRITE_W_FIRST &&
                 aw_ctx.w_issued &&
                 cycle_idx >= aw_ctx.w_issue_cycle + aw_ctx.tr.aw_w_delay) begin
            if (!aw_ctx.outstanding_reserved && !aw_ctx.outstanding_active) begin
                `uvm_fatal("OUTSTD", "W-first trailing AW has no reserved outstanding slot")
            end
            aw_ctx.aw_issued      = 1'b1;
            aw_ctx.aw_issue_cycle = cycle_idx;
        end
    end

    if (w_ctx != null && w_ctx.next_beat_wait_valid &&
        cycle_idx >= w_ctx.next_beat_eligible_cycle) begin
        w_ctx.next_beat_wait_valid = 1'b0;
    end

    if (w_ctx != null && !w_ctx.w_issued) begin
        if (w_ctx.tr.aw_w_order == AXI_MASTER_WRITE_W_FIRST &&
            capture_pkg_anchor(w_ctx) &&
            cycle_idx >= w_ctx.first_eligible_cycle &&
            can_reserve_outstanding_slot(w_ctx)) begin
            reserve_outstanding_slot(w_ctx);
            w_ctx.w_issued      = 1'b1;
            w_ctx.w_issue_cycle = cycle_idx;
        end
        else if (w_ctx.tr.aw_w_order == AXI_MASTER_WRITE_AW_FIRST &&
                 w_ctx.aw_issued &&
                 cycle_idx >= w_ctx.aw_issue_cycle + w_ctx.tr.aw_w_delay) begin
            if (!w_ctx.outstanding_reserved && !w_ctx.outstanding_active) begin
                `uvm_fatal("OUTSTD", "AW-first trailing W has no reserved outstanding slot")
            end
            w_ctx.w_issued      = 1'b1;
            w_ctx.w_issue_cycle = cycle_idx;
        end
    end

    next_awvalid  = 1'b0;
    next_awid     = '0;
    next_awaddr   = '0;
    next_awlen    = '0;
    next_awsize   = '0;
    next_awburst  = '0;
    next_awlock   = '0;
    next_awcache  = '0;
    next_awprot   = '0;
    next_awqos    = '0;
    next_awregion = '0;
    next_awuser   = '0;
    next_wvalid   = 1'b0;
    next_wdata    = '0;
    next_wstrb    = '0;
    next_wlast    = 1'b0;
    next_wuser    = '0;

    if (aw_ctx != null && aw_ctx.aw_issued && !aw_ctx.aw_done) begin
        next_awvalid  = 1'b1;
        next_awid     = aw_ctx.tr.awid;
        next_awaddr   = aw_ctx.tr.awaddr;
        next_awlen    = aw_ctx.tr.awlen;
        next_awsize   = aw_ctx.tr.awsize;
        next_awburst  = aw_ctx.tr.awburst;
        next_awlock   = aw_ctx.tr.awlock;
        next_awcache  = aw_ctx.tr.awcache;
        next_awprot   = aw_ctx.tr.awprot;
        next_awqos    = aw_ctx.tr.awqos;
        next_awregion = aw_ctx.tr.awregion;
        next_awuser   = aw_ctx.tr.awuser;
    end

    if (w_ctx != null && w_ctx.w_issued && !w_ctx.w_done &&
        !w_ctx.next_beat_wait_valid) begin
        next_wvalid = 1'b1;
        next_wdata  = w_ctx.tr.wdata[w_ctx.beat_idx];
        next_wstrb  = w_ctx.tr.wstrb[w_ctx.beat_idx];
        next_wlast  = (w_ctx.beat_idx == w_ctx.beat_num - 1);
        next_wuser  = w_ctx.tr.wuser[w_ctx.beat_idx];
    end

    // Single commit point. Held VALID and payload always come from the current
    // FIFO head, so neither channel can change before its handshake.
    axi_master_write_vif.master_drv_cb.awvalid  <= next_awvalid;
    axi_master_write_vif.master_drv_cb.awid     <= next_awid;
    axi_master_write_vif.master_drv_cb.awaddr   <= next_awaddr;
    axi_master_write_vif.master_drv_cb.awlen    <= next_awlen;
    axi_master_write_vif.master_drv_cb.awsize   <= next_awsize;
    axi_master_write_vif.master_drv_cb.awburst  <= next_awburst;
    axi_master_write_vif.master_drv_cb.awlock   <= next_awlock;
    axi_master_write_vif.master_drv_cb.awcache  <= next_awcache;
    axi_master_write_vif.master_drv_cb.awprot   <= next_awprot;
    axi_master_write_vif.master_drv_cb.awqos    <= next_awqos;
    axi_master_write_vif.master_drv_cb.awregion <= next_awregion;
    axi_master_write_vif.master_drv_cb.awuser   <= next_awuser;
    axi_master_write_vif.master_drv_cb.wvalid   <= next_wvalid;
    axi_master_write_vif.master_drv_cb.wdata    <= next_wdata;
    axi_master_write_vif.master_drv_cb.wstrb    <= next_wstrb;
    axi_master_write_vif.master_drv_cb.wlast    <= next_wlast;
    axi_master_write_vif.master_drv_cb.wuser    <= next_wuser;
endtask : drive_source_outputs

task axi_master_write_driver::queue_b_if_ready(
    context_t ctx
);
    if (ctx != null && ctx.aw_done && ctx.w_done && !ctx.queued_for_b) begin
        ctx.queued_for_b = 1'b1;
        // A B sampled on the same edge as the final request handshake cannot
        // retire this newly completed write.
        ctx.b_eligible_cycle = cycle_idx + 1;
        b_wait_q.push_back(ctx);
    end
endtask : queue_b_if_ready

task axi_master_write_driver::drive_b_channel_cycle(
    input bit b_hs,
    input bit sampled_bvalid,
    input bit [ID_WIDTH-1:0] sampled_bid
);
    bit next_bready;
    int b_idx;
    int unsigned selected_delay;

    next_bready = 1'b0;

    if (axi_master_write_cfg.bready_mode ==
        AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH) begin
        next_bready       = 1'b1;
        b_state           = AXI_MASTER_WRITE_B_IDLE;
        bready_delay_cnt  = 0;
        b_target_valid    = 1'b0;
        b_target_bid      = '0;
    end
    else if (b_hs) begin
        // B is a single-beat response. Every completed handshake drops BREADY;
        // the next response runs a new detect-delay-accept decision.
        b_state           = AXI_MASTER_WRITE_B_IDLE;
        bready_delay_cnt  = 0;
        b_target_valid    = 1'b0;
        b_target_bid      = '0;
    end
    else begin
        case (b_state)
            AXI_MASTER_WRITE_B_IDLE: begin
                if (sampled_bvalid) begin
                    b_idx = find_b_wait_index(sampled_bid, cycle_idx);
                    if (b_idx >= 0) begin
                        selected_delay = b_wait_q[b_idx].tr.bready_delay;
                        b_target_valid = 1'b1;
                        b_target_bid = sampled_bid;
                        if (selected_delay == 0) begin
                            next_bready = 1'b1;
                            b_state = AXI_MASTER_WRITE_B_READY;
                        end
                        else begin
                            bready_delay_cnt = selected_delay;
                            b_state = AXI_MASTER_WRITE_B_DELAY;
                        end
                    end
                end
            end

            AXI_MASTER_WRITE_B_DELAY: begin
                if (!sampled_bvalid || !b_target_valid ||
                    sampled_bid != b_target_bid) begin
                    b_state          = AXI_MASTER_WRITE_B_IDLE;
                    bready_delay_cnt = 0;
                    b_target_valid   = 1'b0;
                    b_target_bid     = '0;
                end
                else if (bready_delay_cnt <= 1) begin
                    next_bready      = 1'b1;
                    bready_delay_cnt = 0;
                    b_state          = AXI_MASTER_WRITE_B_READY;
                end
                else begin
                    bready_delay_cnt--;
                end
            end

            AXI_MASTER_WRITE_B_READY: begin
                if (sampled_bvalid && b_target_valid &&
                    sampled_bid == b_target_bid) begin
                    next_bready = 1'b1;
                end
                else begin
                    b_state          = AXI_MASTER_WRITE_B_IDLE;
                    bready_delay_cnt = 0;
                    b_target_valid   = 1'b0;
                    b_target_bid     = '0;
                end
            end

            default: begin
                b_state          = AXI_MASTER_WRITE_B_IDLE;
                bready_delay_cnt = 0;
                b_target_valid   = 1'b0;
                b_target_bid     = '0;
            end
        endcase
    end

    axi_master_write_vif.master_drv_cb.bready <= next_bready;
endtask : drive_b_channel_cycle

task axi_master_write_driver::complete_b_response(
    input bit [ID_WIDTH-1:0] sampled_bid,
    input bit [1:0] sampled_bresp,
    input bit [USER_WIDTH-1:0] sampled_buser
);
    int b_idx;
    int outstanding_idx;
    int driver_context_idx;
    context_t done_ctx;

    b_idx = find_b_wait_index(sampled_bid, cycle_idx);
    if (b_idx < 0) begin
        // The monitor/checker owns protocol error reporting. The driver only
        // protects its queues from an unmatched or too-early response.
        `uvm_info("AXI_MASTER_WRITE_DRV",
            $sformatf("Ignore unmatched/early BID 0x%0h in driver response queue",
                sampled_bid),
            UVM_LOW)
        return;
    end

    done_ctx = b_wait_q[b_idx];
    b_wait_q.delete(b_idx);
    done_ctx.tr.bid        = sampled_bid;
    done_ctx.tr.bresp      = axi_master_write_resp_e'(sampled_bresp);
    done_ctx.tr.buser      = sampled_buser;
    done_ctx.tr.write_done = 1'b1;

    outstanding_idx = find_outstanding_index(done_ctx);
    if (outstanding_idx < 0) begin
        `uvm_fatal("OUTSTD", "Matched B response has no active outstanding context")
    end
    outstanding_q.delete(outstanding_idx);
    done_ctx.outstanding_active   = 1'b0;
    done_ctx.outstanding_reserved = 1'b0;

    driver_context_idx = find_driver_context_index(done_ctx);
    if (driver_context_idx >= 0) begin
        driver_context_q.delete(driver_context_idx);
    end

    `uvm_info("AXI_MASTER_WRITE_DRV",
        $sformatf("Completed BID=0x%0h epoch=%0d seq=%0d outstanding=%0d/%0d",
            sampled_bid, done_ctx.reset_epoch_id, done_ctx.seq_no,
            outstanding_q.size(), axi_master_write_cfg.write_outstanding_depth),
        UVM_HIGH)
endtask : complete_b_response

function int axi_master_write_driver::find_b_wait_index(
    bit [ID_WIDTH-1:0] bid,
    longint unsigned lookup_cycle
);
    // Same-ID writes retire in activation/source order. A different BID may
    // select its own oldest eligible context and therefore return out of order.
    for (int outstanding_idx = 0;
         outstanding_idx < outstanding_q.size(); outstanding_idx++) begin
        if (outstanding_q[outstanding_idx].tr.awid == bid) begin
            if (!outstanding_q[outstanding_idx].queued_for_b ||
                outstanding_q[outstanding_idx].b_eligible_cycle > lookup_cycle) begin
                return -1;
            end

            for (int b_idx = 0; b_idx < b_wait_q.size(); b_idx++) begin
                if (b_wait_q[b_idx] == outstanding_q[outstanding_idx]) begin
                    return b_idx;
                end
            end
            return -1;
        end
    end
    return -1;
endfunction : find_b_wait_index

function int axi_master_write_driver::find_outstanding_index(
    context_t ctx
);
    for (int i = 0; i < outstanding_q.size(); i++) begin
        if (outstanding_q[i] == ctx) begin
            return i;
        end
    end
    return -1;
endfunction : find_outstanding_index

function int axi_master_write_driver::find_driver_context_index(
    context_t ctx
);
    for (int i = 0; i < driver_context_q.size(); i++) begin
        if (driver_context_q[i] == ctx) begin
            return i;
        end
    end
    return -1;
endfunction : find_driver_context_index

function int unsigned axi_master_write_driver::get_reserved_outstanding_depth();
    int unsigned depth;

    depth = 0;
    foreach (driver_context_q[i]) begin
        if (driver_context_q[i].outstanding_reserved &&
            !driver_context_q[i].outstanding_active) begin
            depth++;
        end
    end
    return depth;
endfunction : get_reserved_outstanding_depth

function bit axi_master_write_driver::can_reserve_outstanding_slot(
    context_t ctx
);
    if (ctx == null) begin
        return 1'b0;
    end
    if (ctx.outstanding_active || ctx.outstanding_reserved) begin
        return 1'b1;
    end
    return outstanding_q.size() + get_reserved_outstanding_depth() <
        axi_master_write_cfg.write_outstanding_depth;
endfunction : can_reserve_outstanding_slot

function void axi_master_write_driver::reserve_outstanding_slot(
    context_t ctx
);
    if (ctx == null || ctx.outstanding_active || ctx.outstanding_reserved) begin
        return;
    end
    if (!can_reserve_outstanding_slot(ctx)) begin
        `uvm_fatal("OUTSTD",
            "Write packet start would over-reserve write_outstanding_depth")
    end
    ctx.outstanding_reserved = 1'b1;
endfunction : reserve_outstanding_slot

function void axi_master_write_driver::activate_outstanding(
    context_t ctx
);
    if (ctx == null || ctx.outstanding_active) begin
        return;
    end
    if (!ctx.outstanding_reserved) begin
        `uvm_fatal("OUTSTD", "Source handshake occurred without prior reservation")
    end
    if (outstanding_q.size() >=
        axi_master_write_cfg.write_outstanding_depth) begin
        `uvm_fatal("OUTSTD",
            "AW/leading-W handshake would exceed write_outstanding_depth")
    end
    if (outstanding_q.size() != 0 &&
        outstanding_q[outstanding_q.size()-1].seq_no > ctx.seq_no) begin
        `uvm_fatal("OUTSTD", "Outstanding activation violated transaction order")
    end

    ctx.outstanding_reserved = 1'b0;
    ctx.outstanding_active   = 1'b1;
    outstanding_q.push_back(ctx);
    `uvm_info("AXI_MASTER_WRITE_DRV",
        $sformatf("Activated epoch=%0d seq=%0d outstanding=%0d/%0d",
            ctx.reset_epoch_id, ctx.seq_no, outstanding_q.size(),
            axi_master_write_cfg.write_outstanding_depth),
        UVM_HIGH)
endfunction : activate_outstanding

`endif
