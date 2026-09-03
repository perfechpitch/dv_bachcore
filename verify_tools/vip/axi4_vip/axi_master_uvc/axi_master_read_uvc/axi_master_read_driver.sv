// ============================================================================
// Filename             : axi_master_read_driver.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_READ_DRIVER_SV
`define AXI_MASTER_READ_DRIVER_SV

class axi_master_read_driver_context #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
);
    typedef axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;

    item_t tr;
    bit               ar_done;
    bit               read_done;
    bit [DATA_WIDTH-1:0] rdata_q[$];
    bit [1:0]         rresp_q[$];
    bit [USER_WIDTH-1:0] ruser_q[$];

    function new(item_t item = null);
        tr = item;
        ar_done = 1'b0;
        read_done = 1'b0;
        rdata_q.delete();
        rresp_q.delete();
        ruser_q.delete();
    endfunction : new
endclass : axi_master_read_driver_context

class axi_master_read_driver #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_driver #(
    axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH)
);
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(DATA_BYTES);
    localparam bit [ADDR_WIDTH-1:0] ADDR_MAX = '1;

    typedef axi_master_read_driver #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;
    typedef axi_master_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef virtual axi_read_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_master_read_driver_context #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) context_t;
    typedef axi_burst_math #(ADDR_WIDTH, DATA_BYTES) burst_math_t;

    vif_t axi_master_read_vif;
    cfg_t axi_master_read_cfg;

    typedef enum int unsigned {
        AXI_MASTER_READ_R_IDLE,
        AXI_MASTER_READ_R_DELAY,
        AXI_MASTER_READ_R_READY
    } axi_master_read_r_state_e;

    axi_master_read_r_state_e              r_state;

    bit                             r_channel_active;
    int unsigned                    rready_delay_cnt;
    longint unsigned                cycle_idx;
    bit                             first_req_pending;
    bit                             reset_first_delay_valid;
    int unsigned                    reset_first_delay;
    // Reset-edge bookkeeping is intentionally not cleared by driver_reset().
    // It distinguishes one assertion edge from a reset held low.
    bit                             reset_low_seen;
    bit                             ar_delay_gate_valid;
    longint unsigned                ar_delay_eligible_cycle;
    longint unsigned                ar_issue_eligible_cycle;

    context_t ar_ctx;

    // driver_context_q owns prefetched items. outstanding_q contains only
    // protocol-active reads, from AR handshake through final R handshake.
    // Keeping these queues separate prevents sequencer prefetch from being
    // reported as bus outstanding traffic.
    context_t driver_context_q[$];
    context_t outstanding_q[$];
    context_t ar_pending_q[$];

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new(string name ,uvm_component parent);
        super.new(name,parent);
        reset_low_seen = 1'b0;
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (axi_master_read_cfg == null) begin
            `uvm_fatal("NOCFG", {"axi_master_read_cfg must be assigned directly before build for: ",
                get_full_name()})
        end

        if (axi_master_read_cfg.read_outstanding_depth < 1 ||
            axi_master_read_cfg.read_outstanding_depth > 256) begin
            `uvm_fatal("OUTSTD", "read_outstanding_depth must be inside [1:256]")
        end

        axi_master_read_vif = axi_master_read_cfg.axi_master_read_vif;
        if (axi_master_read_vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set in: ", get_full_name(), ".axi_master_read_cfg.axi_master_read_vif"})
        end
        // An active leaf driver is the universal interface ownership point.
        axi_master_read_vif.set_master_driver_enable(1'b1);
    endfunction: build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    extern virtual protected task drive_one_cycle();
    extern virtual protected task accept_item_cycle();
    extern virtual protected function bit prepare_request(
        item_t item
    );
    extern virtual protected function bit request_timing_is_legal(
        item_t item
    );
    extern virtual protected function axi_request_rule_e request_timing_rule(
        item_t item
    );
    extern virtual protected function bit request_geometry_is_legal(
        item_t item,
        bit                     enforce_segment,
        mem_segment_s           segment
    );
    extern virtual protected function bit candidate_geometry_is_legal(
        item_t item,
        bit [ADDR_WIDTH-1:0] candidate_addr,
        bit [2:0]               candidate_size,
        bit                     enforce_segment,
        mem_segment_s           segment
    );
    extern virtual protected function axi_request_rule_e candidate_geometry_rule(
        item_t item,
        bit [ADDR_WIDTH-1:0] candidate_addr,
        bit [2:0]               candidate_size,
        bit                     enforce_segment,
        mem_segment_s           segment
    );
    extern virtual protected function axi_addr_search_status_e find_addr_in_segment_status(
        item_t item,
        mem_segment_s           segment,
        bit [2:0]               selected_size,
        bit                     select_random,
        output bit [ADDR_WIDTH-1:0] selected_addr,
        output bit [64:0]       candidate_count
    );
    extern virtual protected function bit offset_is_selected(
        item_t item,
        int unsigned             offset,
        bit [2:0]                selected_size
    );
    extern virtual protected function bit get_page_range_for_offset(
        item_t item,
        mem_segment_s           segment,
        bit [2:0]               selected_size,
        int unsigned            offset,
        output mem_addr_t       first_page,
        output mem_addr_t       last_page
    );
    extern virtual protected function bit select_segment_by_response(
        item_t item,
        output mem_segment_s     segment,
        output int signed        segment_index
    );
    extern virtual protected function bit reject_request(
        item_t item,
        axi_prepare_reason_e     reason,
        axi_request_rule_e       rule,
        string                   expected,
        string                   detail = ""
    );
    extern virtual protected function bit range_supports_size(
        mem_addr_t low_addr,
        mem_addr_t high_addr,
        bit [2:0]  size
    );
    extern virtual protected task drive_ar_payload(context_t ctx);
    extern virtual protected task complete_ar_handshake();
    extern virtual protected task launch_ar_context_cycle();
    extern virtual protected task drive_ar_channel_cycle();
    extern virtual protected task drive_r_channel_cycle();
    extern virtual protected task complete_r_beat();
    extern virtual protected function int unsigned get_rready_delay_for_rid(bit [ID_WIDTH-1:0] rid);
    extern virtual protected function int find_r_context_index(bit [ID_WIDTH-1:0] rid);
    extern virtual protected function int find_outstanding_index(context_t ctx);
    extern virtual protected function int find_driver_context_index(context_t ctx);
endclass : axi_master_read_driver

task axi_master_read_driver::driver_reset();
    int unsigned unfinished_contexts;

    // Never silently discard an accepted transaction.  Keeping this guard at
    // the reset primitive covers the sampled reset edge as well as reset-phase
    // jumps, and it runs before any signal is cleared or queue is deleted.
    unfinished_contexts = 0;
    foreach (driver_context_q[i]) begin
        if (driver_context_q[i] == null ||
            driver_context_q[i].tr == null ||
            !driver_context_q[i].read_done) begin
            unfinished_contexts++;
        end
    end
    if (driver_context_q.size() != 0 ||
        outstanding_q.size() != 0 ||
        ar_pending_q.size() != 0 ||
        ar_ctx != null ||
        axi_master_read_vif.master_arvalid_drv ||
        r_state != AXI_MASTER_READ_R_IDLE ||
        r_channel_active ||
        rready_delay_cnt != 0 ||
        unfinished_contexts != 0) begin
        `uvm_fatal("AXI_RESET_WITH_PENDING", $sformatf(
            {"Reset would discard pending Master Read work: contexts=%0d ",
             "unfinished=%0d outstanding=%0d ar_pending=%0d ar_ctx=%0b ",
             "ARVALID=%0b RREADY=%0b r_state=%s r_channel_active=%0b ",
             "rready_delay=%0d"},
            driver_context_q.size(), unfinished_contexts,
            outstanding_q.size(), ar_pending_q.size(), ar_ctx != null,
            axi_master_read_vif.master_arvalid_drv,
            axi_master_read_vif.master_rready_drv, r_state.name(),
            r_channel_active, rready_delay_cnt))
    end

    axi_master_read_vif.master_drv_cb.arvalid  <= 1'b0;
    axi_master_read_vif.master_drv_cb.arid     <= '0;
    axi_master_read_vif.master_drv_cb.araddr   <= '0;
    axi_master_read_vif.master_drv_cb.arlen    <= '0;
    axi_master_read_vif.master_drv_cb.arsize   <= '0;
    axi_master_read_vif.master_drv_cb.arburst  <= '0;
    axi_master_read_vif.master_drv_cb.arlock   <= '0;
    axi_master_read_vif.master_drv_cb.arcache  <= '0;
    axi_master_read_vif.master_drv_cb.arprot   <= '0;
    axi_master_read_vif.master_drv_cb.arqos    <= '0;
    axi_master_read_vif.master_drv_cb.arregion <= '0;
    axi_master_read_vif.master_drv_cb.aruser   <= '0;

    axi_master_read_vif.master_drv_cb.rready   <= 1'b0;

    r_state  = AXI_MASTER_READ_R_IDLE;
    r_channel_active  = 1'b0;
    rready_delay_cnt = 0;
    cycle_idx = 0;
    first_req_pending = 1'b1;
    reset_first_delay_valid = 1'b0;
    reset_first_delay = 0;
    ar_delay_gate_valid = 1'b0;
    ar_delay_eligible_cycle = 0;
    ar_issue_eligible_cycle = 0;
    ar_ctx = null;
    req = null;
    driver_context_q.delete();
    outstanding_q.delete();
    ar_pending_q.delete();
endtask : driver_reset

task axi_master_read_driver::reset_phase(uvm_phase phase);
    driver_reset();
endtask : reset_phase

task axi_master_read_driver::main_phase(uvm_phase phase);
    driver_reset();
    get_and_drive();
endtask : main_phase

task axi_master_read_driver::get_and_drive();
    forever begin
        @(axi_master_read_vif.master_drv_cb);
        if (!axi_master_read_vif.master_drv_cb.reset) begin
            if (!reset_low_seen) begin
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

task axi_master_read_driver::drive_one_cycle();
    bit ar_hs;

    if (!reset_first_delay_valid) begin
        if (!axi_master_read_cfg.select_first_delay(reset_first_delay)) begin
            `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
                "Failed to select reset-to-first-ARVALID delay")
        end
        reset_first_delay_valid = 1'b1;
        `uvm_info("AXI_MASTER_READ_FIRST_DELAY",
            $sformatf("Selected first_delay=%0d for this reset epoch",
                reset_first_delay),
            UVM_HIGH)
    end

    cycle_idx++;
    ar_hs = axi_master_read_vif.master_arvalid_drv &&
            axi_master_read_vif.master_drv_cb.arready;

    if (ar_hs) begin
        complete_ar_handshake();
    end
    accept_item_cycle();
    launch_ar_context_cycle();
    drive_ar_channel_cycle();
    drive_r_channel_cycle();
endtask : drive_one_cycle

task axi_master_read_driver::accept_item_cycle();
    uvm_object clone_obj;
    item_t owned_req;
    context_t new_ctx;

    req = null;
    // One extra prefetched context keeps AR back-to-back after an RLAST frees
    // a protocol slot. It is not counted as outstanding until AR handshakes.
    if (driver_context_q.size() >=
        axi_master_read_cfg.read_outstanding_depth + 1) begin
        return;
    end

    seq_item_port.try_next_item(req);
    if (req == null) begin
        return;
    end

    if (!prepare_request(req)) begin
        req.prepare_status = AXI_PREPARE_NO_CANDIDATE;
        seq_item_port.item_done();
        req = null;
        return;
    end

    clone_obj = req.clone();
    if (!$cast(owned_req, clone_obj) || owned_req == null) begin
        req.prepare_status = AXI_PREPARE_NO_CANDIDATE;
        req.prepare_reason = AXI_PREPARE_REASON_INTERNAL;
        seq_item_port.item_done();
        req = null;
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            "reason=PREPARED_CLONE_FAILED role=MASTER_READ channel=AR stage=QUEUE observed={clone cast failed or returned null} expected={prepared request clone is axi_master_read_seq_item specialization} action=STOP_SIMULATION")
        return;
    end
    new_ctx = new(owned_req);
    driver_context_q.push_back(new_ctx);
    ar_pending_q.push_back(new_ctx);

    `uvm_info("AXI_MASTER_READ_DRV",
        $sformatf({"Prefetched AXI read item, buffered=%0d active_outstanding=%0d/%0d ",
                   "ar_delay=%0d:\n%s"},
            driver_context_q.size(), outstanding_q.size(),
            axi_master_read_cfg.read_outstanding_depth,
            owned_req.ar_delay, owned_req.sprint()),
        UVM_HIGH)

    seq_item_port.item_done();
    req = null;
endtask : accept_item_cycle

function bit axi_master_read_driver::request_timing_is_legal(
    item_t item
);
    return request_timing_rule(item) == AXI_REQUEST_RULE_OK;
endfunction : request_timing_is_legal

function axi_request_rule_e axi_master_read_driver::request_timing_rule(
    item_t item
);
    if (item == null) begin
        return AXI_REQUEST_RULE_NULL_CONTEXT;
    end
    if (item.ar_delay > 100) begin
        return AXI_REQUEST_RULE_AR_DELAY_RANGE;
    end
    if (item.rready_delay > 63) begin
        return AXI_REQUEST_RULE_RREADY_DELAY_RANGE;
    end
    if (axi_master_read_cfg.rready_mode ==
            AXI_MASTER_READ_RREADY_ALWAYS_HIGH &&
        item.rready_delay != 0) begin
        return AXI_REQUEST_RULE_RREADY_MODE_CONFLICT;
    end
    return AXI_REQUEST_RULE_OK;
endfunction : request_timing_rule

function bit axi_master_read_driver::request_geometry_is_legal(
    item_t item,
    bit                     enforce_segment,
    mem_segment_s           segment
);
    if (item == null) begin
        return 1'b0;
    end
    return candidate_geometry_is_legal(
        item, item.araddr, item.arsize, enforce_segment, segment);
endfunction : request_geometry_is_legal

function bit axi_master_read_driver::candidate_geometry_is_legal(
    item_t item,
    bit [ADDR_WIDTH-1:0] candidate_addr,
    bit [2:0]               candidate_size,
    bit                     enforce_segment,
    mem_segment_s           segment
);
    return candidate_geometry_rule(
        item, candidate_addr, candidate_size,
        enforce_segment, segment) == AXI_REQUEST_RULE_OK;
endfunction : candidate_geometry_is_legal

function axi_request_rule_e axi_master_read_driver::candidate_geometry_rule(
    item_t item,
    bit [ADDR_WIDTH-1:0] candidate_addr,
    bit [2:0]               candidate_size,
    bit                     enforce_segment,
    mem_segment_s           segment
);
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;
    axi_request_rule_e rule;

    if (item == null) begin
        return AXI_REQUEST_RULE_NULL_CONTEXT;
    end
    rule = burst_math_t::get_request_geometry_rule(
        candidate_addr, item.arlen, candidate_size,
        axi_burst_e'(item.arburst), AXI_MASTER_READ_MAX_BEATS,
        item.arlock, axi_master_read_cfg.addr_4k_protect_enable,
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

function axi_addr_search_status_e axi_master_read_driver::find_addr_in_segment_status(
    item_t item,
    mem_segment_s           segment,
    bit [2:0]               selected_size,
    bit                     select_random,
    output bit [ADDR_WIDTH-1:0] selected_addr,
    output bit [64:0]       candidate_count
);
    mem_addr_t first_page;
    mem_addr_t last_page;
    mem_addr_t candidate;
    bit [64:0] slot_count;
    bit [64:0] total_slots;
    bit [64:0] selected_slot;
    bit [64:0] random_rank;
    bit [64:0] acceptance_limit;
    bit [64:0] full_domain;
    mem_addr_t random_value;

    selected_addr = '0;
    candidate_count = '0;
    total_slots = 0;
    full_domain = {1'b1, {64{1'b0}}};
    for (int unsigned offset = 0; offset < 4096; offset++) begin
        if (!offset_is_selected(item, offset, selected_size) ||
            !get_page_range_for_offset(item, segment, selected_size,
                offset, first_page, last_page)) begin
            continue;
        end
        slot_count = ({1'b0, (last_page - first_page)} / 4096) + 1;
        if (slot_count > full_domain ||
            total_slots > full_domain - slot_count) begin
            candidate_count = total_slots;
            return AXI_ADDR_SEARCH_COUNT_OVERFLOW;
        end
        total_slots += slot_count;
    end
    candidate_count = total_slots;
    if (total_slots == 0) begin
        return AXI_ADDR_SEARCH_EMPTY;
    end
    if (!select_random) begin
        selected_slot = '0;
    end
    else if (total_slots == full_domain) begin
        // The complete 2^64 domain needs no modulo operation.
        random_value = {$urandom(), $urandom()};
        selected_slot = {1'b0, random_value};
    end
    else begin
        // Rejection sampling keeps every remaining slot equiprobable; a raw
        // modulo would bias low ranks whenever total_slots does not divide
        // 2^64.
        acceptance_limit = full_domain - (full_domain % total_slots);
        do begin
            random_value = {$urandom(), $urandom()};
            random_rank = {1'b0, random_value};
        end while (random_rank >= acceptance_limit);
        selected_slot = random_rank % total_slots;
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

function bit axi_master_read_driver::offset_is_selected(
    item_t item,
    int unsigned             offset,
    bit [2:0]                selected_size
);
    int unsigned raw_min;
    int unsigned raw_max;
    int unsigned beat_bytes;

    case (item.araddr_offset_type)
        AXI_MASTER_READ_ADDR_OFFSET_ZERO: begin
            raw_min = 12'h000; raw_max = 12'h000;
        end
        AXI_MASTER_READ_ADDR_OFFSET_LOW: begin
            raw_min = 12'h001; raw_max = 12'h0ff;
        end
        AXI_MASTER_READ_ADDR_OFFSET_NORMAL: begin
            raw_min = 12'h100; raw_max = 12'hfef;
        end
        AXI_MASTER_READ_ADDR_OFFSET_HIGH: begin
            raw_min = 12'hff0; raw_max = 12'hffe;
        end
        AXI_MASTER_READ_ADDR_OFFSET_MAX_VALUE: begin
            raw_min = 12'hfff; raw_max = 12'hfff;
        end
        default: return 1'b0;
    endcase
    if (!axi_master_read_cfg.align_size) begin
        return offset >= raw_min && offset <= raw_max;
    end
    beat_bytes = 1 << selected_size;
    return (offset % beat_bytes) == 0 && offset <= raw_max &&
        (offset + beat_bytes - 1) >= raw_min;
endfunction : offset_is_selected

function bit axi_master_read_driver::get_page_range_for_offset(
    item_t item,
    mem_segment_s           segment,
    bit [2:0]               selected_size,
    int unsigned            offset,
    output mem_addr_t       first_page,
    output mem_addr_t       last_page
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
            item.arlen, selected_size, axi_burst_e'(item.arburst)) + 4095) /
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

function bit axi_master_read_driver::select_segment_by_response(
    item_t item,
    output mem_segment_s     segment,
    output int signed        segment_index
);
    int unsigned eligible[$];
    mem_segment_s candidate_segment;
    int unsigned selected;

    segment = '{default: '0};
    segment_index = -1;
    for (int unsigned i = 0;
         i < axi_master_read_cfg.memory_model.segment_count(); i++) begin
        if (!axi_master_read_cfg.memory_model.get_segment(
                i, candidate_segment)) begin
            continue;
        end
        if (axi_master_read_cfg.memory_model.predict_read_exception(
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
    return axi_master_read_cfg.memory_model.get_segment(selected, segment);
endfunction : select_segment_by_response

function bit axi_master_read_driver::reject_request(
    item_t item,
    axi_prepare_reason_e     reason,
    axi_request_rule_e       rule,
    string                   expected,
    string                   detail
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
            {"ARID=0x%0h ARADDR=0x%0h ARLEN=%0d ARSIZE=%0d ",
             "ARBURST=%0d ARLOCK=%0b ARCACHE=0x%0h ",
             "ar_delay=%0d rready_delay=%0d ",
             "desired_response=%s response_intent_valid=%0b ",
             "expect_size_error=%0b size_intent_valid=%0b"},
            item.arid, item.araddr, item.arlen, item.arsize,
            item.arburst, item.arlock, item.arcache, item.ar_delay,
            item.rready_delay, item.desired_mem_response.name(),
            item.desired_mem_response_valid, item.expect_size_error,
            item.size_intent_valid);
    end
    full_detail = $sformatf("rule=%s %s", rule.name(), detail);
    `uvm_error("AXI_REQUEST_PREPARE_FAILED",
        axi_diag::format(reason.name(), "MASTER_READ", "AR",
            "REQUEST_PREPARE", observed, expected,
            "REJECT_BEFORE_ARVALID", full_detail))
    return 1'b0;
endfunction : reject_request

function bit axi_master_read_driver::range_supports_size(
    mem_addr_t low_addr,
    mem_addr_t high_addr,
    bit [2:0]  size
);
    mem_segment_s segment;

    for (int unsigned i = 0;
         i < axi_master_read_cfg.memory_model.segment_count(); i++) begin
        if (axi_master_read_cfg.memory_model.get_segment(i, segment) &&
            low_addr <= segment.end_addr && high_addr >= segment.start_addr &&
            !segment.supported_size_mask[size]) begin
            return 1'b0;
        end
    end
    return 1'b1;
endfunction : range_supports_size

function bit axi_master_read_driver::prepare_request(
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
    mem_resp_e address_response;
    axi_request_rule_e rule;
    axi_addr_search_status_e search_status;

    if (item == null) begin
        return reject_request(item, AXI_PREPARE_REASON_NULL_ITEM,
            AXI_REQUEST_RULE_NULL_CONTEXT,
            "non-null axi_master_read_seq_item specialization",
            "Driver received a null request handle");
    end
    item.prepare_status = AXI_PREPARE_NOT_RUN;
    item.prepare_reason = AXI_PREPARE_REASON_NONE;
    item.predicted_mem_response = MEM_RESP_OKAY;
    item.predicted_mem_response_valid = 1'b0;
    item.predicted_mem_access_bytes = 0;

    if (!axi_cache_is_legal(item.arcache)) begin
        return reject_request(item, AXI_PREPARE_REASON_CACHE_RESERVED,
            AXI_REQUEST_RULE_CACHE_RESERVED,
            AXI_CACHE_LEGAL_EXPECTED,
            $sformatf({"ARCACHE=0x%0h is an AXI4 reserved encoding; ",
                       "the Driver does not rewrite or retry fixed fields"},
                item.arcache));
    end

    rule = request_timing_rule(item);
    if (rule != AXI_REQUEST_RULE_OK) begin
        return reject_request(item, AXI_PREPARE_REASON_TIMING, rule,
            {"ar_delay inside [0:100], rready_delay inside [0:63], ",
             "and ALWAYS_HIGH requires rready_delay=0"},
            "Read timing configuration is inconsistent");
    end

    if (!axi_master_read_cfg.use_mem_model) begin
        rule = candidate_geometry_rule(
            item, item.araddr, item.arsize, 1'b0, segment);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
                rule, "legal AXI read geometry before ARVALID",
                $sformatf("addr_4k_protect_enable=%0b",
                    axi_master_read_cfg.addr_4k_protect_enable));
        end
        item.prepare_status = AXI_PREPARE_OK;
        item.prepare_reason = AXI_PREPARE_REASON_NONE;
        return 1'b1;
    end

    if (axi_master_read_cfg.memory_model == null) begin
        return reject_request(item, AXI_PREPARE_REASON_MODEL_NULL,
            AXI_REQUEST_RULE_NULL_CONTEXT,
            "use_mem_model=1 requires memory_model!=null",
            "axi_master_read_cfg.memory_model is null");
    end

    // A fixed address is an explicit user target.  Mem Model mode predicts
    // the final complete range but never remaps its ADDR or SIZE and does not
    // require the range to be contained by one explicit Segment.
    if (axi_master_read_cfg.fix_araddr_enable) begin
        rule = candidate_geometry_rule(
            item, item.araddr, item.arsize, 1'b0, segment);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
                rule, "fixed ARADDR and selected ARSIZE form legal geometry",
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
        if (axi_master_read_cfg.memory_model.segment_count() == 0) begin
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
                $sformatf("a Segment whose read response is %s",
                    item.desired_mem_response.name()),
                $sformatf("segment_count=%0d; Segment selection never filters by SIZE or geometry",
                    axi_master_read_cfg.memory_model.segment_count()));
        end

        if (axi_master_read_cfg.fix_arsize_enable) begin
            if (item.size_intent_valid) begin
                return reject_request(item, AXI_PREPARE_REASON_INTERNAL,
                    AXI_REQUEST_RULE_INTERNAL,
                    "fixed ARSIZE bypasses supported/unsupported size intent",
                    "size_intent_valid=1 while fix_arsize_enable=1");
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
                    $sformatf("at least one %s ARSIZE in [0:%0d]",
                        item.expect_size_error ? "unsupported" : "supported",
                        BUS_SIZE),
                    $sformatf({"segment_index=%0d range=[0x%0h:0x%0h] ",
                               "supported_size_mask=0x%02h"},
                        segment_index, segment.start_addr, segment.end_addr,
                        segment.supported_size_mask));
            end
            selected = $urandom_range(size_candidates.size() - 1, 0);
            item.arsize = size_candidates[selected];
        end

        rule = burst_math_t::get_address_independent_rule(
            item.arlen, item.arsize, axi_burst_e'(item.arburst),
            AXI_MASTER_READ_MAX_BEATS, item.arlock);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_BASE_GEOMETRY,
                rule, "BURST/LEN/SIZE/LOCK geometry legal before address search",
                $sformatf("segment_index=%0d selected_SIZE=%0d",
                    segment_index, item.arsize));
        end

        search_status = find_addr_in_segment_status(
            item, segment, item.arsize, 1'b1,
            candidate_addr, candidate_count);
        if (search_status == AXI_ADDR_SEARCH_COUNT_OVERFLOW) begin
            return reject_request(item,
                AXI_PREPARE_REASON_ADDR_COUNT_OVERFLOW,
                AXI_REQUEST_RULE_ADDRESS_OVERFLOW,
                "address candidate count fits in the 2^64 Mem address domain",
                $sformatf({"segment_index=%0d range=[0x%0h:0x%0h] ",
                           "selected_SIZE=%0d partial_candidate_count=%0d"},
                    segment_index, segment.start_addr, segment.end_addr,
                    item.arsize, candidate_count));
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
                    item.arsize, item.araddr_offset_type.name(),
                    axi_master_read_cfg.align_size,
                    axi_master_read_cfg.addr_4k_protect_enable));
        end
        item.araddr = candidate_addr;
        item.araddr_offset = item.araddr[11:0];
        rule = candidate_geometry_rule(
            item, item.araddr, item.arsize, 1'b1, segment);
        if (rule != AXI_REQUEST_RULE_OK) begin
            return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
                rule, "final Mem address remains inside selected Segment and legal AXI geometry",
                $sformatf("segment_index=%0d range=[0x%0h:0x%0h]",
                    segment_index, segment.start_addr, segment.end_addr));
        end
    end

    if (!burst_math_t::get_access_range(
            item.araddr, item.arlen, item.arsize,
            axi_burst_e'(item.arburst), low_addr, high_addr)) begin
        return reject_request(item, AXI_PREPARE_REASON_FINAL_GEOMETRY,
            AXI_REQUEST_RULE_ADDRESS_OVERFLOW,
            "final read footprint is representable in configured ADDR_WIDTH",
            "get_access_range returned false after final geometry check");
    end
    address_response = axi_master_read_cfg.memory_model.predict_read_exception(
        int'(high_addr - low_addr) + 1, mem_addr_t'(low_addr));
    item.predicted_mem_response = address_response;
    if (address_response != MEM_RESP_DECERR &&
        !range_supports_size(mem_addr_t'(low_addr),
            mem_addr_t'(high_addr), item.arsize)) begin
        item.predicted_mem_response = MEM_RESP_SLVERR;
    end
    item.predicted_mem_response_valid = 1'b1;
    item.predicted_mem_access_bytes = int'(high_addr - low_addr) + 1;
    item.prepare_status = AXI_PREPARE_OK;
    item.prepare_reason = AXI_PREPARE_REASON_NONE;
    return 1'b1;
endfunction : prepare_request

task axi_master_read_driver::drive_ar_payload(context_t ctx);
    axi_master_read_vif.master_drv_cb.arid     <= ctx.tr.arid;
    axi_master_read_vif.master_drv_cb.araddr   <= ctx.tr.araddr;
    axi_master_read_vif.master_drv_cb.arlen    <= ctx.tr.arlen;
    axi_master_read_vif.master_drv_cb.arsize   <= ctx.tr.arsize;
    axi_master_read_vif.master_drv_cb.arburst  <= ctx.tr.arburst;
    axi_master_read_vif.master_drv_cb.arlock   <= ctx.tr.arlock;
    axi_master_read_vif.master_drv_cb.arcache  <= ctx.tr.arcache;
    axi_master_read_vif.master_drv_cb.arprot   <= ctx.tr.arprot;
    axi_master_read_vif.master_drv_cb.arqos    <= ctx.tr.arqos;
    axi_master_read_vif.master_drv_cb.arregion <= ctx.tr.arregion;
    axi_master_read_vif.master_drv_cb.aruser   <= ctx.tr.aruser;
    axi_master_read_vif.master_drv_cb.arvalid  <= 1'b1;
endtask : drive_ar_payload

task axi_master_read_driver::complete_ar_handshake();
    if (ar_ctx == null) begin
        `uvm_fatal("AXI_AR_CTX", "Observed AR handshake without an active AR context")
    end
    if (outstanding_q.size() >= axi_master_read_cfg.read_outstanding_depth) begin
        `uvm_fatal("OUTSTD", "AR handshake would exceed read_outstanding_depth")
    end

    ar_ctx.ar_done = 1'b1;
    outstanding_q.push_back(ar_ctx);

    // ar_delay=0 permits the next request to be committed on this handshake
    // edge. A positive value inserts exactly that many ARVALID-low cycles.
    ar_delay_gate_valid = 1'b1;
    ar_delay_eligible_cycle = cycle_idx + ar_ctx.tr.ar_delay;

    `uvm_info("AXI_MASTER_READ_DRV",
        $sformatf("AR handshake ARID=0x%0h cycle=%0d ar_delay=%0d",
            ar_ctx.tr.arid, cycle_idx, ar_ctx.tr.ar_delay),
        UVM_HIGH)

    ar_ctx = null;
endtask : complete_ar_handshake

task axi_master_read_driver::launch_ar_context_cycle();
    if (ar_ctx != null || ar_pending_q.size() == 0) begin
        return;
    end
    if (outstanding_q.size() >= axi_master_read_cfg.read_outstanding_depth) begin
        return;
    end

    if (first_req_pending) begin
        ar_ctx = ar_pending_q.pop_front();
        first_req_pending = 1'b0;
        // cycle_idx==1 is the first active clock after reset release.  The
        // first-request deadline is therefore anchored to reset release, not
        // to the cycle in which the sequence item reaches the driver.  If the
        // item arrives after the deadline, it is eligible immediately.
        ar_issue_eligible_cycle = reset_first_delay + 1;

        `uvm_info("AXI_MASTER_READ_DRV",
            $sformatf({"Launch first AR request ARID=0x%0h cycle=%0d ",
                       "first_delay=%0d eligible_cycle=%0d"},
                ar_ctx.tr.arid, cycle_idx, reset_first_delay,
                ar_issue_eligible_cycle),
            UVM_HIGH)
        return;
    end

    // The post-handshake gap runs even while no next item is queued. Once its
    // deadline has passed, a later item may issue immediately.
    if (ar_delay_gate_valid && cycle_idx < ar_delay_eligible_cycle) begin
        return;
    end

    ar_ctx = ar_pending_q.pop_front();
    ar_delay_gate_valid = 1'b0;
    ar_issue_eligible_cycle = cycle_idx;

    `uvm_info("AXI_MASTER_READ_DRV",
        $sformatf("Launch AR request ARID=0x%0h cycle=%0d",
            ar_ctx.tr.arid, cycle_idx),
        UVM_HIGH)
endtask : launch_ar_context_cycle

task axi_master_read_driver::drive_ar_channel_cycle();
    if (ar_ctx != null && cycle_idx >= ar_issue_eligible_cycle) begin
        drive_ar_payload(ar_ctx);
    end
    else begin
        axi_master_read_vif.master_drv_cb.arvalid <= 1'b0;
    end
endtask : drive_ar_channel_cycle

task axi_master_read_driver::drive_r_channel_cycle();
    int unsigned rready_delay;

    if (axi_master_read_cfg.rready_mode == AXI_MASTER_READ_RREADY_ALWAYS_HIGH) begin
        axi_master_read_vif.master_drv_cb.rready <= 1'b1;
        r_state = AXI_MASTER_READ_R_IDLE;
        if (r_channel_active && axi_master_read_vif.master_drv_cb.rvalid) begin
            complete_r_beat();
        end
        r_channel_active = 1'b1;
        rready_delay_cnt = 0;
        return;
    end

    case (r_state)
        AXI_MASTER_READ_R_IDLE: begin
            axi_master_read_vif.master_drv_cb.rready <= 1'b0;
            r_channel_active = 1'b0;
            if (axi_master_read_vif.master_drv_cb.rvalid) begin
                rready_delay = get_rready_delay_for_rid(axi_master_read_vif.master_drv_cb.rid);
                if (rready_delay == 0) begin
                    axi_master_read_vif.master_drv_cb.rready <= 1'b1;
                    r_channel_active = 1'b1;
                    r_state = AXI_MASTER_READ_R_READY;
                end
                else begin
                    rready_delay_cnt = rready_delay;
                    r_state = AXI_MASTER_READ_R_DELAY;
                end
            end
        end

        AXI_MASTER_READ_R_DELAY: begin
            axi_master_read_vif.master_drv_cb.rready <= 1'b0;
            r_channel_active = 1'b0;
            if (!axi_master_read_vif.master_drv_cb.rvalid) begin
                r_state = AXI_MASTER_READ_R_IDLE;
            end
            else if (rready_delay_cnt <= 1) begin
                axi_master_read_vif.master_drv_cb.rready <= 1'b1;
                r_channel_active = 1'b1;
                rready_delay_cnt = 0;
                r_state = AXI_MASTER_READ_R_READY;
            end
            else begin
                rready_delay_cnt--;
            end
        end

        AXI_MASTER_READ_R_READY: begin
            axi_master_read_vif.master_drv_cb.rready <= 1'b1;
            if (r_channel_active && axi_master_read_vif.master_drv_cb.rvalid) begin
                complete_r_beat();
                if (axi_master_read_vif.master_drv_cb.rlast) begin
                    r_channel_active = 1'b0;
                    axi_master_read_vif.master_drv_cb.rready <= 1'b0;
                    rready_delay_cnt = 0;
                    r_state = AXI_MASTER_READ_R_IDLE;
                end
            end
            else begin
                r_channel_active = 1'b1;
            end
        end
    endcase
endtask : drive_r_channel_cycle

task axi_master_read_driver::complete_r_beat();
    int ctx_idx;
    int outstanding_idx;
    int driver_context_idx;
    context_t done_ctx;
    bit [ID_WIDTH-1:0] rid;
    int unsigned beat_count;

    rid = axi_master_read_vif.master_drv_cb.rid;
    ctx_idx = find_r_context_index(rid);
    if (ctx_idx < 0) begin
        // Protocol RID checking is handled by the monitor/checker. The driver
        // only protects its internal queues when an unmatched response appears.
        `uvm_info("AXI_MASTER_READ_DRV",
            $sformatf("Ignore unmatched RID 0x%0h in driver response queue", rid),
            UVM_LOW)
        return;
    end

    done_ctx = outstanding_q[ctx_idx];
    done_ctx.rdata_q.push_back(axi_master_read_vif.master_drv_cb.rdata);
    done_ctx.rresp_q.push_back(axi_master_read_vif.master_drv_cb.rresp);
    done_ctx.ruser_q.push_back(axi_master_read_vif.master_drv_cb.ruser);

    if (axi_master_read_vif.master_drv_cb.rlast) begin
        beat_count = done_ctx.rdata_q.size();
        done_ctx.tr.rid = rid;
        done_ctx.tr.rdata = new[beat_count];
        done_ctx.tr.rresp = new[beat_count];
        done_ctx.tr.ruser = new[beat_count];
        for (int unsigned i = 0; i < beat_count; i++) begin
            done_ctx.tr.rdata[i] = done_ctx.rdata_q[i];
            done_ctx.tr.rresp[i] = done_ctx.rresp_q[i];
            done_ctx.tr.ruser[i] = done_ctx.ruser_q[i];
        end
        done_ctx.tr.beat_count = beat_count;
        done_ctx.tr.read_done = 1'b1;
        done_ctx.read_done = 1'b1;

        outstanding_idx = find_outstanding_index(done_ctx);
        if (outstanding_idx >= 0) begin
            outstanding_q.delete(outstanding_idx);
        end
        driver_context_idx = find_driver_context_index(done_ctx);
        if (driver_context_idx >= 0) begin
            driver_context_q.delete(driver_context_idx);
        end

        `uvm_info("AXI_MASTER_READ_DRV",
            $sformatf("Completed AXI read response RID=0x%0h, outstanding=%0d/%0d",
                rid, outstanding_q.size(), axi_master_read_cfg.read_outstanding_depth),
            UVM_HIGH)
    end
endtask : complete_r_beat

function int unsigned axi_master_read_driver::get_rready_delay_for_rid(bit [ID_WIDTH-1:0] rid);
    int ctx_idx;

    ctx_idx = find_r_context_index(rid);
    if (ctx_idx < 0) begin
        // Keep RREADY generation alive; monitor/checker reports the RID error.
        `uvm_info("AXI_MASTER_READ_DRV",
            $sformatf("Use zero RREADY delay for unmatched RID 0x%0h", rid),
            UVM_LOW)
        return 0;
    end

    return outstanding_q[ctx_idx].tr.rready_delay;
endfunction : get_rready_delay_for_rid

function int axi_master_read_driver::find_r_context_index(bit [ID_WIDTH-1:0] rid);
    // Match the oldest accepted AR with this ID. Same-ID read responses must
    // retire in AR order; different IDs may return in any order.
    for (int i = 0; i < outstanding_q.size(); i++) begin
        if (outstanding_q[i].tr.arid == rid) begin
            if (!outstanding_q[i].ar_done || outstanding_q[i].read_done) begin
                return -1;
            end
            return i;
        end
    end

    return -1;
endfunction : find_r_context_index

function int axi_master_read_driver::find_outstanding_index(context_t ctx);
    for (int i = 0; i < outstanding_q.size(); i++) begin
        if (outstanding_q[i] == ctx) begin
            return i;
        end
    end
    return -1;
endfunction : find_outstanding_index

function int axi_master_read_driver::find_driver_context_index(
    context_t ctx
);
    for (int i = 0; i < driver_context_q.size(); i++) begin
        if (driver_context_q[i] == ctx) begin
            return i;
        end
    end
    return -1;
endfunction : find_driver_context_index

`endif
