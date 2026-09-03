// ============================================================================
// Filename             : axi_slaver_write_driver.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : Reactive AXI write slaver driver.
// ============================================================================
`ifndef AXI_SLAVER_WRITE_DRIVER_SV
`define AXI_SLAVER_WRITE_DRIVER_SV

class axi_slaver_write_driver_context #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
);
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_slaver_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;

    item_t tr;
    bit aw_seen;
    bit w_started;
    bit w_done;
    bit queued_for_b;
    bit initial_order_member;
    longint unsigned aw_seq;
    longint unsigned aw_handshake_cycle;
    longint unsigned wlast_handshake_cycle;
    longint unsigned b_ready_seq;
    longint unsigned bvalid_eligible_cycle;
    bit [DATA_WIDTH-1:0] wdata_q[$];
    bit [STRB_WIDTH-1:0] wstrb_q[$];
    bit [USER_WIDTH-1:0] wuser_q[$];

    function new(string name = "axi_slaver_write_tr");
        tr = item_t::type_id::create(name);
        aw_seen = 1'b0;
        w_started = 1'b0;
        w_done = 1'b0;
        queued_for_b = 1'b0;
        initial_order_member = 1'b0;
        aw_seq = 0;
        aw_handshake_cycle = 0;
        wlast_handshake_cycle = 0;
        b_ready_seq = 0;
        bvalid_eligible_cycle = 0;
        wdata_q.delete();
        wstrb_q.delete();
        wuser_q.delete();
    endfunction : new
endclass : axi_slaver_write_driver_context

class axi_slaver_write_driver #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_driver #(axi_slaver_write_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH));
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(STRB_WIDTH);
    typedef axi_slaver_write_driver #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_write_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_slaver_write_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef axi_slaver_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;
    typedef axi_slaver_write_driver_context #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) context_t;
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;

    vif_t    axi_slaver_write_vif;
    cfg_t axi_slaver_write_cfg;

    typedef enum int unsigned {
        AXI_SLAVER_WRITE_READY_IDLE,
        AXI_SLAVER_WRITE_READY_DELAY,
        AXI_SLAVER_WRITE_READY_ASSERT
    } axi_slaver_write_ready_state_e;

    typedef enum int unsigned {
        AXI_SLAVER_WRITE_B_IDLE,
        AXI_SLAVER_WRITE_B_VALID
    } axi_slaver_write_b_state_e;

    typedef enum int unsigned {
        AXI_SLAVER_WRITE_B_STRICT_IN_ORDER,
        AXI_SLAVER_WRITE_B_ACCUMULATE,
        AXI_SLAVER_WRITE_B_INITIAL_RELEASE,
        AXI_SLAVER_WRITE_B_READY_FOREVER
    } axi_slaver_write_b_order_state_e;

    axi_slaver_write_ready_state_e awready_state;
    axi_slaver_write_ready_state_e wready_state;
    axi_slaver_write_b_state_e     b_state;
    axi_slaver_write_b_order_state_e b_order_state;

    bit awready_active;
    bit wready_active;
    bit bvalid_active;
    int unsigned awready_delay_cnt;
    int unsigned wready_delay_cnt;
    longint unsigned cycle_idx;
    longint unsigned next_aw_seq;
    longint unsigned next_b_ready_seq;

    context_t active_w_ctx;
    context_t b_ctx;
    // One entry per protocol-active write, created by whichever of AW or W
    // handshakes first and removed only by the matching B handshake.
    context_t outstanding_q[$];
    context_t b_pending_q[$];

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (axi_slaver_write_cfg == null) begin
            `uvm_fatal("NOCFG", {"axi_slaver_write_cfg must be assigned directly before build for: ",
                get_full_name()})
        end
        if (axi_slaver_write_cfg.write_outstanding_depth < 1 ||
            axi_slaver_write_cfg.write_outstanding_depth > 256) begin
            `uvm_fatal("OUTSTD", "write_outstanding_depth must be inside [1:256]")
        end
        if (axi_slaver_write_cfg.memory_model == null) begin
            `uvm_fatal("AXI_MEM_CFG",
                "BRESP and write storage require a non-null shared memory_model")
        end
        axi_slaver_write_vif = axi_slaver_write_cfg.axi_slaver_write_vif;
        if (axi_slaver_write_vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set in: ", get_full_name(), ".axi_slaver_write_cfg.axi_slaver_write_vif"})
        end
        axi_slaver_write_vif.set_slaver_driver_enable(1'b1);
    endfunction : build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    extern virtual protected task drive_one_cycle();
    extern virtual protected task sample_aw_if_hs(bit aw_hs);
    extern virtual protected task sample_w_if_hs(bit w_hs);
    extern virtual protected task finalize_ready_transactions();
    extern virtual protected task drive_awready_cycle(bit aw_hs);
    extern virtual protected task drive_wready_cycle(bit w_hs);
    extern virtual protected task drive_b_channel_cycle();
    extern virtual protected task start_b_response();
    extern virtual protected task complete_b_response();
    extern virtual protected task update_b_response_order_state();
    extern virtual protected task freeze_initial_order_set();
    extern virtual protected function bit initial_order_set_has_outstanding();
    extern virtual protected function context_t get_aw_context();
    extern virtual protected function context_t get_w_context();
    extern virtual protected function int find_outstanding_index(context_t ctx);
    extern virtual protected function bit can_accept_aw();
    extern virtual protected function bit can_accept_w();
    extern virtual protected function bit response_arbitration_ready();
    extern virtual protected function axi_response_order_e effective_response_order();
    extern virtual protected function int select_pending_response_index();
    extern virtual protected function bit is_oldest_outstanding_for_id(int index);
    extern virtual protected function int unsigned get_awready_delay();
    extern virtual protected function int unsigned get_wready_delay();
    extern virtual protected function int unsigned get_b_delay();
    extern virtual protected function int unsigned select_delay_from_dist(int unsigned delay_dist[]);
    extern virtual protected function int unsigned delay_value_from_type(axi_slaver_write_delay_type_e delay_type);
    extern virtual protected function axi_slaver_write_resp_e select_random_bresp(
        bit allow_exokay
    );
    // Legacy virtual hook name retained for derived Driver compatibility.
    // The base implementation is cfg-driven and consumes no sequence item.
    extern virtual protected task apply_response_policy(context_t ctx);
    extern virtual protected function axi_slaver_write_resp_e get_memory_bresp(
        context_t ctx
    );
    extern virtual protected function mem_resp_e get_memory_write_response(
        context_t ctx
    );
    extern virtual protected function axi_request_rule_e get_write_transaction_rule(
        context_t ctx,
        output int signed failing_beat
    );
    extern virtual protected function string get_write_rule_expectation(
        axi_request_rule_e rule
    );
    extern virtual protected function bit write_transaction_is_legal(context_t ctx);
    extern virtual protected function bit aw_addr_in_range(context_t ctx);
    extern virtual protected function bit is_supported_awburst(axi_slaver_write_burst_e awburst);
    extern virtual protected task commit_memory_write(context_t ctx);
endclass : axi_slaver_write_driver

task axi_slaver_write_driver::driver_reset();
    axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b0;
    axi_slaver_write_vif.slaver_drv_cb.wready  <= 1'b0;
    axi_slaver_write_vif.slaver_drv_cb.bvalid  <= 1'b0;
    axi_slaver_write_vif.slaver_drv_cb.bid     <= '0;
    axi_slaver_write_vif.slaver_drv_cb.bresp   <= '0;
    axi_slaver_write_vif.slaver_drv_cb.buser   <= '0;

    awready_state = AXI_SLAVER_WRITE_READY_IDLE;
    wready_state  = AXI_SLAVER_WRITE_READY_IDLE;
    b_state       = AXI_SLAVER_WRITE_B_IDLE;
    awready_active = 1'b0;
    wready_active  = 1'b0;
    bvalid_active  = 1'b0;
    awready_delay_cnt = 0;
    wready_delay_cnt = 0;
    cycle_idx = 0;
    next_aw_seq = 0;
    next_b_ready_seq = 0;
    if (axi_slaver_write_cfg.resp_order == AXI_RESP_IN_ORDER &&
        axi_slaver_write_cfg.save_req_num == 0) begin
        b_order_state = AXI_SLAVER_WRITE_B_STRICT_IN_ORDER;
    end
    else if (axi_slaver_write_cfg.resp_order == AXI_RESP_READY_ORDER) begin
        b_order_state = AXI_SLAVER_WRITE_B_READY_FOREVER;
    end
    else begin
        b_order_state = AXI_SLAVER_WRITE_B_ACCUMULATE;
    end
    active_w_ctx = null;
    b_ctx = null;
    outstanding_q.delete();
    b_pending_q.delete();

    if (axi_slaver_write_cfg.memory_clear_on_reset) begin
        axi_slaver_write_cfg.memory_model.reset_mem();
    end
endtask : driver_reset

task axi_slaver_write_driver::reset_phase(uvm_phase phase);
    driver_reset();
endtask : reset_phase

task axi_slaver_write_driver::main_phase(uvm_phase phase);
    driver_reset();
    get_and_drive();
endtask : main_phase

task axi_slaver_write_driver::get_and_drive();
    forever begin
        @(axi_slaver_write_vif.slaver_drv_cb);
        if (!axi_slaver_write_vif.slaver_drv_cb.reset) begin
            driver_reset();
        end
        else begin
            drive_one_cycle();
        end
    end
endtask : get_and_drive

task axi_slaver_write_driver::drive_one_cycle();
    bit aw_hs;
    bit w_hs;

    cycle_idx++;

    aw_hs = axi_slaver_write_vif.slaver_drv_cb.awvalid && awready_active;
    w_hs  = axi_slaver_write_vif.slaver_drv_cb.wvalid  && wready_active;

    sample_aw_if_hs(aw_hs);
    sample_w_if_hs(w_hs);
    finalize_ready_transactions();
    drive_b_channel_cycle();
    drive_awready_cycle(aw_hs);
    drive_wready_cycle(w_hs);
endtask : drive_one_cycle

task axi_slaver_write_driver::sample_aw_if_hs(bit aw_hs);
    context_t ctx;

    if (!aw_hs) begin
        return;
    end

    ctx = get_aw_context();
    if (ctx == null) begin
        `uvm_fatal("OUTSTD",
            "AW handshake has no unified write outstanding slot")
    end
    ctx.tr.awid     = axi_slaver_write_vif.slaver_drv_cb.awid;
    ctx.tr.awaddr   = axi_slaver_write_vif.slaver_drv_cb.awaddr;
    ctx.tr.awlen    = axi_slaver_write_vif.slaver_drv_cb.awlen;
    ctx.tr.awsize   = axi_slaver_write_vif.slaver_drv_cb.awsize;
    ctx.tr.awburst  = axi_slaver_write_burst_e'(axi_slaver_write_vif.slaver_drv_cb.awburst);
    ctx.tr.awlock   = axi_slaver_write_vif.slaver_drv_cb.awlock;
    ctx.tr.awcache  = axi_slaver_write_vif.slaver_drv_cb.awcache;
    ctx.tr.awprot   = axi_slaver_write_vif.slaver_drv_cb.awprot;
    ctx.tr.awqos    = axi_slaver_write_vif.slaver_drv_cb.awqos;
    ctx.tr.awregion = axi_slaver_write_vif.slaver_drv_cb.awregion;
    ctx.tr.awuser   = axi_slaver_write_vif.slaver_drv_cb.awuser;
    ctx.aw_seen = 1'b1;
    ctx.aw_seq = next_aw_seq++;
    ctx.aw_handshake_cycle = cycle_idx;

    `uvm_info("AXI_SLAVER_WRITE_DRV",
        $sformatf("Accepted AW: id=0x%0h addr=0x%0h len=%0d outstanding=%0d/%0d",
            ctx.tr.awid, ctx.tr.awaddr, ctx.tr.awlen,
            outstanding_q.size(), axi_slaver_write_cfg.write_outstanding_depth),
        UVM_HIGH)
endtask : sample_aw_if_hs

task axi_slaver_write_driver::sample_w_if_hs(bit w_hs);
    if (!w_hs) begin
        return;
    end

    if (active_w_ctx == null) begin
        active_w_ctx = get_w_context();
        if (active_w_ctx == null) begin
            `uvm_fatal("OUTSTD",
                "Leading-W handshake has no unified write outstanding slot")
        end
        active_w_ctx.w_started = 1'b1;
    end

    active_w_ctx.wdata_q.push_back(axi_slaver_write_vif.slaver_drv_cb.wdata);
    active_w_ctx.wstrb_q.push_back(axi_slaver_write_vif.slaver_drv_cb.wstrb);
    active_w_ctx.wuser_q.push_back(axi_slaver_write_vif.slaver_drv_cb.wuser);
    active_w_ctx.tr.beat_count = active_w_ctx.wdata_q.size();

    if (axi_slaver_write_vif.slaver_drv_cb.wlast) begin
        active_w_ctx.w_done = 1'b1;
        active_w_ctx.wlast_handshake_cycle = cycle_idx;
        `uvm_info("AXI_SLAVER_WRITE_DRV",
            $sformatf("Accepted W burst: beats=%0d outstanding=%0d/%0d",
                active_w_ctx.tr.beat_count, outstanding_q.size(),
                axi_slaver_write_cfg.write_outstanding_depth),
            UVM_HIGH)
        active_w_ctx = null;
    end
endtask : sample_w_if_hs

task axi_slaver_write_driver::finalize_ready_transactions();
    context_t ctx;
    context_t newly_ready_q[$];
    int selected_index;
    longint unsigned selected_aw_seq;

    foreach (outstanding_q[i]) begin
        ctx = outstanding_q[i];
        if (!ctx.aw_seen || !ctx.w_done || ctx.queued_for_b) begin
            continue;
        end

        newly_ready_q.push_back(ctx);
    end

    // A clock edge can make multiple requests B-ready. Assign their global
    // B-ready sequence in AW acceptance order so the tie is deterministic.
    while (newly_ready_q.size() > 0) begin
        selected_index = 0;
        selected_aw_seq = newly_ready_q[0].aw_seq;
        foreach (newly_ready_q[i]) begin
            if (newly_ready_q[i].aw_seq < selected_aw_seq) begin
                selected_index = i;
                selected_aw_seq = newly_ready_q[i].aw_seq;
            end
        end
        ctx = newly_ready_q[selected_index];
        newly_ready_q.delete(selected_index);

        ctx.tr.wdata = new[ctx.wdata_q.size()];
        ctx.tr.wstrb = new[ctx.wstrb_q.size()];
        ctx.tr.wuser = new[ctx.wuser_q.size()];
        for (int unsigned beat = 0; beat < ctx.wdata_q.size(); beat++) begin
            ctx.tr.wdata[beat] = ctx.wdata_q[beat];
            ctx.tr.wstrb[beat] = ctx.wstrb_q[beat];
            ctx.tr.wuser[beat] = ctx.wuser_q[beat];
        end
        ctx.tr.beat_count = ctx.wdata_q.size();
        ctx.tr.bid = ctx.tr.awid;
        apply_response_policy(ctx);
        if ((ctx.tr.bresp == AXI_SLAVER_WRITE_RESP_OKAY ||
             ctx.tr.bresp == AXI_SLAVER_WRITE_RESP_EXOKAY) &&
            write_transaction_is_legal(ctx) &&
            (!ctx.tr.awlock ||
             !axi_slaver_write_cfg.exclusive_access_enable ||
             ((!axi_slaver_write_cfg.fix_bresp_enable &&
               axi_slaver_write_cfg.use_mem_model) &&
              !axi_slaver_write_cfg.memory_model.exclusive_access_supported(
                  ctx.tr.awaddr, ctx.tr.awlen, ctx.tr.awsize,
                  ctx.tr.awburst)) ||
             ctx.tr.bresp == AXI_SLAVER_WRITE_RESP_EXOKAY)) begin
            commit_memory_write(ctx);
        end
        ctx.queued_for_b = 1'b1;
        ctx.b_ready_seq = next_b_ready_seq++;
        b_pending_q.push_back(ctx);
    end
endtask : finalize_ready_transactions

task axi_slaver_write_driver::drive_awready_cycle(bit aw_hs);
    if (axi_slaver_write_cfg.awready_mode == AXI_ALWAYS_HIGH) begin
        awready_active = can_accept_aw();
        axi_slaver_write_vif.slaver_drv_cb.awready <= awready_active;
        awready_state = AXI_SLAVER_WRITE_READY_IDLE;
        awready_delay_cnt = 0;
        return;
    end

    if (!can_accept_aw()) begin
        awready_state = AXI_SLAVER_WRITE_READY_IDLE;
        awready_active = 1'b0;
        axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b0;
        return;
    end

    case (awready_state)
        AXI_SLAVER_WRITE_READY_IDLE: begin
            axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b0;
            awready_active = 1'b0;
            if (axi_slaver_write_vif.slaver_drv_cb.awvalid) begin
                awready_delay_cnt = get_awready_delay();
                if (awready_delay_cnt == 0) begin
                    axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b1;
                    awready_active = 1'b1;
                    awready_state = AXI_SLAVER_WRITE_READY_ASSERT;
                end
                else begin
                    awready_state = AXI_SLAVER_WRITE_READY_DELAY;
                end
            end
        end

        AXI_SLAVER_WRITE_READY_DELAY: begin
            axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b0;
            awready_active = 1'b0;
            if (!axi_slaver_write_vif.slaver_drv_cb.awvalid) begin
                awready_state = AXI_SLAVER_WRITE_READY_IDLE;
                awready_delay_cnt = 0;
            end
            else if (awready_delay_cnt <= 1) begin
                axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b1;
                awready_active = 1'b1;
                awready_delay_cnt = 0;
                awready_state = AXI_SLAVER_WRITE_READY_ASSERT;
            end
            else begin
                awready_delay_cnt--;
            end
        end

        AXI_SLAVER_WRITE_READY_ASSERT: begin
            axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b1;
            awready_active = 1'b1;
            if (aw_hs) begin
                axi_slaver_write_vif.slaver_drv_cb.awready <= 1'b0;
                awready_active = 1'b0;
                awready_state = AXI_SLAVER_WRITE_READY_IDLE;
            end
        end
    endcase
endtask : drive_awready_cycle

task axi_slaver_write_driver::drive_wready_cycle(bit w_hs);
    if (axi_slaver_write_cfg.wready_mode == AXI_ALWAYS_HIGH) begin
        wready_active = can_accept_w();
        axi_slaver_write_vif.slaver_drv_cb.wready <= wready_active;
        wready_state = AXI_SLAVER_WRITE_READY_IDLE;
        wready_delay_cnt = 0;
        return;
    end

    if (!can_accept_w()) begin
        wready_state = AXI_SLAVER_WRITE_READY_IDLE;
        wready_active = 1'b0;
        axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b0;
        return;
    end

    case (wready_state)
        AXI_SLAVER_WRITE_READY_IDLE: begin
            axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b0;
            wready_active = 1'b0;
            if (axi_slaver_write_vif.slaver_drv_cb.wvalid) begin
                wready_delay_cnt = get_wready_delay();
                if (wready_delay_cnt == 0) begin
                    axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b1;
                    wready_active = 1'b1;
                    wready_state = AXI_SLAVER_WRITE_READY_ASSERT;
                end
                else begin
                    wready_state = AXI_SLAVER_WRITE_READY_DELAY;
                end
            end
        end

        AXI_SLAVER_WRITE_READY_DELAY: begin
            axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b0;
            wready_active = 1'b0;
            if (!axi_slaver_write_vif.slaver_drv_cb.wvalid) begin
                wready_state = AXI_SLAVER_WRITE_READY_IDLE;
                wready_delay_cnt = 0;
            end
            else if (wready_delay_cnt <= 1) begin
                axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b1;
                wready_active = 1'b1;
                wready_delay_cnt = 0;
                wready_state = AXI_SLAVER_WRITE_READY_ASSERT;
            end
            else begin
                wready_delay_cnt--;
            end
        end

        AXI_SLAVER_WRITE_READY_ASSERT: begin
            axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b1;
            wready_active = 1'b1;
            if (w_hs && axi_slaver_write_vif.slaver_drv_cb.wlast) begin
                axi_slaver_write_vif.slaver_drv_cb.wready <= 1'b0;
                wready_active = 1'b0;
                wready_state = AXI_SLAVER_WRITE_READY_IDLE;
            end
        end
    endcase
endtask : drive_wready_cycle

task axi_slaver_write_driver::drive_b_channel_cycle();
    int selected_index;
    axi_response_order_e selected_order;

    if (b_state == AXI_SLAVER_WRITE_B_VALID &&
        bvalid_active &&
        axi_slaver_write_vif.slaver_drv_cb.bready) begin
        complete_b_response();
    end

    case (b_state)
        AXI_SLAVER_WRITE_B_IDLE: begin
            axi_slaver_write_vif.slaver_drv_cb.bvalid <= 1'b0;
            bvalid_active = 1'b0;
            update_b_response_order_state();
            if (response_arbitration_ready()) begin
                selected_index = select_pending_response_index();
                if (selected_index >= 0 &&
                    cycle_idx >= b_pending_q[selected_index].bvalid_eligible_cycle) begin
                    selected_order = effective_response_order();
                    b_ctx = b_pending_q[selected_index];
                    b_pending_q.delete(selected_index);
                    `uvm_info("AXI_SLAVER_WRITE_ORDER",
                        $sformatf({"Selected B response: configured=%s effective=%s ",
                                   "phase=%s BID=0x%0h b_ready_seq=%0d remaining=%0d"},
                            axi_slaver_write_cfg.resp_order.name(), selected_order.name(),
                            b_order_state.name(), b_ctx.tr.bid, b_ctx.b_ready_seq,
                            b_pending_q.size()),
                        UVM_MEDIUM)
                    start_b_response();
                end
            end
        end

        AXI_SLAVER_WRITE_B_VALID: begin
            axi_slaver_write_vif.slaver_drv_cb.bvalid <= 1'b1;
            axi_slaver_write_vif.slaver_drv_cb.bid    <= b_ctx.tr.bid;
            axi_slaver_write_vif.slaver_drv_cb.bresp  <= b_ctx.tr.bresp;
            axi_slaver_write_vif.slaver_drv_cb.buser  <= b_ctx.tr.buser;
            bvalid_active = 1'b1;
        end
    endcase
endtask : drive_b_channel_cycle

task axi_slaver_write_driver::start_b_response();
    if (b_ctx == null) begin
        b_state = AXI_SLAVER_WRITE_B_IDLE;
        return;
    end

    axi_slaver_write_vif.slaver_drv_cb.bid    <= b_ctx.tr.bid;
    axi_slaver_write_vif.slaver_drv_cb.bresp  <= b_ctx.tr.bresp;
    axi_slaver_write_vif.slaver_drv_cb.buser  <= b_ctx.tr.buser;
    axi_slaver_write_vif.slaver_drv_cb.bvalid <= 1'b1;
    bvalid_active = 1'b1;
    b_state = AXI_SLAVER_WRITE_B_VALID;
endtask : start_b_response

task axi_slaver_write_driver::complete_b_response();
    int outstanding_idx;

    b_ctx.tr.write_done = 1'b1;

    `uvm_info("AXI_SLAVER_WRITE_DRV",
        $sformatf("Completed B response: BID=0x%0h BRESP=%s",
            b_ctx.tr.bid, b_ctx.tr.bresp.name()),
        UVM_HIGH)

    outstanding_idx = find_outstanding_index(b_ctx);
    if (outstanding_idx < 0) begin
        `uvm_error("OUTSTD",
            axi_diag::format(
                "COMPLETED_RESPONSE_CONTEXT_MISSING", "SLAVE", "B",
                "response_completion",
                $sformatf("BID=0x%0h outstanding_count=%0d",
                    b_ctx.tr.bid, outstanding_q.size()),
                "one matching unified outstanding context",
                "clear_completed_B_response_and_continue", get_full_name()))
    end
    else begin
        outstanding_q.delete(outstanding_idx);
    end

    axi_slaver_write_vif.slaver_drv_cb.bvalid <= 1'b0;
    axi_slaver_write_vif.slaver_drv_cb.bid    <= '0;
    axi_slaver_write_vif.slaver_drv_cb.bresp  <= '0;
    axi_slaver_write_vif.slaver_drv_cb.buser  <= '0;
    bvalid_active = 1'b0;
    b_ctx = null;
    b_state = AXI_SLAVER_WRITE_B_IDLE;
endtask : complete_b_response

function bit axi_slaver_write_driver::can_accept_aw();
    // At full depth, AW can still complete a transaction that leading W
    // already activated; only a brand-new transaction must be throttled.
    foreach (outstanding_q[i]) begin
        if (!outstanding_q[i].aw_seen) begin
            return 1'b1;
        end
    end
    return outstanding_q.size() <
        axi_slaver_write_cfg.write_outstanding_depth;
endfunction : can_accept_aw

function bit axi_slaver_write_driver::can_accept_w();
    if (active_w_ctx != null) begin
        return 1'b1;
    end
    // At full depth, W can still complete an AW-leading transaction. Starting
    // a new leading-W transaction requires a free unified slot.
    foreach (outstanding_q[i]) begin
        if (!outstanding_q[i].w_started) begin
            return 1'b1;
        end
    end
    return outstanding_q.size() <
        axi_slaver_write_cfg.write_outstanding_depth;
endfunction : can_accept_w

function axi_slaver_write_driver::context_t axi_slaver_write_driver::get_aw_context();
    context_t ctx;

    foreach (outstanding_q[i]) begin
        if (!outstanding_q[i].aw_seen) begin
            return outstanding_q[i];
        end
    end
    if (outstanding_q.size() >=
        axi_slaver_write_cfg.write_outstanding_depth) begin
        return null;
    end

    ctx = new("axi_slaver_write_ctx");
    outstanding_q.push_back(ctx);
    return ctx;
endfunction : get_aw_context

function axi_slaver_write_driver::context_t axi_slaver_write_driver::get_w_context();
    context_t ctx;

    if (active_w_ctx != null) begin
        return active_w_ctx;
    end
    foreach (outstanding_q[i]) begin
        if (!outstanding_q[i].w_started) begin
            return outstanding_q[i];
        end
    end
    if (outstanding_q.size() >=
        axi_slaver_write_cfg.write_outstanding_depth) begin
        return null;
    end

    ctx = new("axi_slaver_write_ctx");
    outstanding_q.push_back(ctx);
    return ctx;
endfunction : get_w_context

function int axi_slaver_write_driver::find_outstanding_index(
    context_t ctx
);
    foreach (outstanding_q[i]) begin
        if (outstanding_q[i] == ctx) begin
            return i;
        end
    end
    return -1;
endfunction : find_outstanding_index

function bit axi_slaver_write_driver::response_arbitration_ready();
    if (b_pending_q.size() == 0) begin
        return 1'b0;
    end

    if (b_order_state == AXI_SLAVER_WRITE_B_ACCUMULATE) begin
        return 1'b0;
    end

    return select_pending_response_index() >= 0;
endfunction : response_arbitration_ready

function axi_response_order_e axi_slaver_write_driver::effective_response_order();
    if (b_order_state == AXI_SLAVER_WRITE_B_STRICT_IN_ORDER) begin
        return AXI_RESP_IN_ORDER;
    end
    if (b_order_state == AXI_SLAVER_WRITE_B_READY_FOREVER) begin
        return AXI_RESP_READY_ORDER;
    end
    return axi_slaver_write_cfg.resp_order;
endfunction : effective_response_order

task axi_slaver_write_driver::update_b_response_order_state();
    int unsigned root_count;
    int unsigned member_count;
    axi_response_order_e logged_effective_order;

    case (b_order_state)
        AXI_SLAVER_WRITE_B_STRICT_IN_ORDER: begin
            // No save_req_num gate is used. The global B-ready queue head is
            // the only candidate for the lifetime of this reset interval.
        end

        AXI_SLAVER_WRITE_B_ACCUMULATE: begin
            if (b_pending_q.size() >= axi_slaver_write_cfg.save_req_num) begin
                root_count = b_pending_q.size();
                freeze_initial_order_set();
                member_count = 0;
                foreach (outstanding_q[i]) begin
                    if (outstanding_q[i].initial_order_member) begin
                        member_count++;
                    end
                end
                b_order_state = AXI_SLAVER_WRITE_B_INITIAL_RELEASE;
                logged_effective_order = effective_response_order();
                `uvm_info("AXI_SLAVER_WRITE_ORDER",
                    $sformatf({"Initial B order set frozen: configured=%s ",
                               "effective=%s phase=%s threshold=%0d roots=%0d ",
                               "members_with_predecessors=%0d"},
                        axi_slaver_write_cfg.resp_order.name(),
                        logged_effective_order.name(), b_order_state.name(),
                        axi_slaver_write_cfg.save_req_num, root_count, member_count),
                    UVM_MEDIUM)
            end
        end

        AXI_SLAVER_WRITE_B_INITIAL_RELEASE: begin
            if (!initial_order_set_has_outstanding()) begin
                b_order_state = AXI_SLAVER_WRITE_B_READY_FOREVER;
                logged_effective_order = effective_response_order();
                `uvm_info("AXI_SLAVER_WRITE_ORDER",
                    $sformatf({"Initial B order set completed: configured=%s ",
                               "effective=%s phase=%s pending=%0d"},
                        axi_slaver_write_cfg.resp_order.name(),
                        logged_effective_order.name(), b_order_state.name(),
                        b_pending_q.size()),
                    UVM_MEDIUM)
            end
        end

        AXI_SLAVER_WRITE_B_READY_FOREVER: begin
            // The initial save_req_num gate is permanently disarmed until reset.
        end

        default: begin
            `uvm_error("AXI_SLAVER_WRITE_ORDER",
                axi_diag::format(
                    "UNSUPPORTED_RESPONSE_ORDER_PHASE", "SLAVE", "B",
                    "response_arbitration",
                    $sformatf("phase=%0d configured=%0d pending=%0d",
                        int'(b_order_state), int'(axi_slaver_write_cfg.resp_order),
                        b_pending_q.size()),
                    {"phase inside {STRICT_IN_ORDER,ACCUMULATE,",
                     "INITIAL_RELEASE,READY_FOREVER}"},
                    "fallback_to_READY_FOREVER", get_full_name()))
            b_order_state = AXI_SLAVER_WRITE_B_READY_FOREVER;
        end
    endcase
endtask : update_b_response_order_state

task axi_slaver_write_driver::freeze_initial_order_set();
    foreach (outstanding_q[i]) begin
        outstanding_q[i].initial_order_member = 1'b0;
    end

    foreach (b_pending_q[i]) begin
        b_pending_q[i].initial_order_member = 1'b1;
    end

    // Form the finite same-BID predecessor closure at the snapshot boundary.
    // All older AWs are included in one pass; later AW handshakes cannot grow
    // this initial set. A marked predecessor keeps membership if it becomes
    // B-ready after the snapshot.
    foreach (outstanding_q[i]) begin
        if (!outstanding_q[i].aw_seen) begin
            continue;
        end
        foreach (b_pending_q[j]) begin
            if (b_pending_q[j].initial_order_member &&
                outstanding_q[i].tr.awid == b_pending_q[j].tr.awid &&
                outstanding_q[i].aw_seq < b_pending_q[j].aw_seq) begin
                outstanding_q[i].initial_order_member = 1'b1;
            end
        end
    end
endtask : freeze_initial_order_set

function bit axi_slaver_write_driver::initial_order_set_has_outstanding();
    foreach (outstanding_q[i]) begin
        if (outstanding_q[i].initial_order_member) begin
            return 1'b1;
        end
    end
    return 1'b0;
endfunction : initial_order_set_has_outstanding

function int axi_slaver_write_driver::select_pending_response_index();
    int selected_index;
    axi_response_order_e selected_order;

    if (b_pending_q.size() == 0) begin
        return -1;
    end

    selected_index = -1;

    // Strict IN_ORDER implements true head-of-line arbitration. Select the
    // globally earliest complete write before checking either same-BID
    // eligibility or delay. If that one request is blocked, no later request
    // may bypass it.
    if (b_order_state == AXI_SLAVER_WRITE_B_STRICT_IN_ORDER) begin
        foreach (b_pending_q[i]) begin
            if (selected_index < 0 ||
                b_pending_q[i].b_ready_seq <
                    b_pending_q[selected_index].b_ready_seq) begin
                selected_index = i;
            end
        end
        if (selected_index < 0 ||
            !is_oldest_outstanding_for_id(selected_index) ||
            cycle_idx < b_pending_q[selected_index].bvalid_eligible_cycle) begin
            return -1;
        end
        return selected_index;
    end

    selected_order = effective_response_order();
    case (selected_order)
        AXI_RESP_IN_ORDER: begin
            foreach (b_pending_q[i]) begin
                if (b_pending_q[i].initial_order_member &&
                    is_oldest_outstanding_for_id(i) &&
                    (selected_index < 0 ||
                     b_pending_q[i].b_ready_seq <
                        b_pending_q[selected_index].b_ready_seq)) begin
                    selected_index = i;
                end
            end
            return selected_index;
        end

        AXI_RESP_REVERSE_ORDER: begin
            foreach (b_pending_q[i]) begin
                if (b_pending_q[i].initial_order_member &&
                    is_oldest_outstanding_for_id(i) &&
                    (selected_index < 0 ||
                     b_pending_q[i].b_ready_seq >
                        b_pending_q[selected_index].b_ready_seq)) begin
                    selected_index = i;
                end
            end
            return selected_index;
        end

        AXI_RESP_READY_ORDER: begin
            foreach (b_pending_q[i]) begin
                if (cycle_idx >= b_pending_q[i].bvalid_eligible_cycle &&
                    is_oldest_outstanding_for_id(i)) begin
                    return i;
                end
            end
        end

        default: begin
            `uvm_error("AXI_SLAVER_WRITE_ORDER",
                axi_diag::format(
                    "UNSUPPORTED_RESPONSE_ORDER", "SLAVE", "B",
                    "response_arbitration",
                    $sformatf({"configured=%0d effective=%0d phase=%0d ",
                               "pending=%0d"},
                        int'(axi_slaver_write_cfg.resp_order), int'(selected_order),
                        int'(b_order_state), b_pending_q.size()),
                    "resp_order inside {IN_ORDER,REVERSE_ORDER,READY_ORDER}",
                    "fallback_to_IN_ORDER", get_full_name()))
            return 0;
        end
    endcase

    return -1;
endfunction : select_pending_response_index

function bit axi_slaver_write_driver::is_oldest_outstanding_for_id(int index);
    if (index < 0 || index >= b_pending_q.size()) begin
        return 1'b0;
    end

    foreach (outstanding_q[i]) begin
        if (outstanding_q[i] != b_pending_q[index] &&
            outstanding_q[i].aw_seen &&
            outstanding_q[i].tr.awid == b_pending_q[index].tr.awid &&
            outstanding_q[i].aw_seq < b_pending_q[index].aw_seq) begin
            return 1'b0;
        end
    end
    return 1'b1;
endfunction : is_oldest_outstanding_for_id

function int unsigned axi_slaver_write_driver::get_awready_delay();
    if (axi_slaver_write_cfg.awready_mode == AXI_ALWAYS_HIGH) begin
        return 0;
    end
    if (axi_slaver_write_cfg.fix_awready_delay_enable) begin
        return axi_slaver_write_cfg.awready_delay;
    end

    return select_delay_from_dist(axi_slaver_write_cfg.awready_delay_type_dist);
endfunction : get_awready_delay

function int unsigned axi_slaver_write_driver::get_wready_delay();
    if (axi_slaver_write_cfg.wready_mode == AXI_ALWAYS_HIGH) begin
        return 0;
    end
    if (axi_slaver_write_cfg.fix_wready_delay_enable) begin
        return axi_slaver_write_cfg.wready_delay;
    end

    return select_delay_from_dist(axi_slaver_write_cfg.wready_delay_type_dist);
endfunction : get_wready_delay

function int unsigned axi_slaver_write_driver::get_b_delay();
    if (axi_slaver_write_cfg.fix_b_delay_enable) begin
        return axi_slaver_write_cfg.b_delay;
    end

    return select_delay_from_dist(axi_slaver_write_cfg.b_delay_dist);
endfunction : get_b_delay

function int unsigned axi_slaver_write_driver::select_delay_from_dist(int unsigned delay_dist[]);
    int unsigned total;
    int unsigned pick;
    int unsigned acc;

    total = 0;
    foreach (delay_dist[i]) begin
        total += delay_dist[i];
    end

    if (total == 0) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            "Slaver Write delay distribution has no positive-weight candidate")
        return 0;
    end

    pick = $urandom_range(total - 1, 0);
    acc = 0;
    foreach (delay_dist[i]) begin
        acc += delay_dist[i];
        if (pick < acc) begin
            return delay_value_from_type(axi_slaver_write_delay_type_e'(i));
        end
    end

    return 0;
endfunction : select_delay_from_dist

function int unsigned axi_slaver_write_driver::delay_value_from_type(axi_slaver_write_delay_type_e delay_type);
    case (delay_type)
        AXI_SLAVER_WRITE_DELAY_ZERO:      return 0;
        AXI_SLAVER_WRITE_DELAY_SHORT:     return $urandom_range(3, 1);
        AXI_SLAVER_WRITE_DELAY_MID:       return $urandom_range(10, 4);
        AXI_SLAVER_WRITE_DELAY_LONG:      return $urandom_range(31, 11);
        AXI_SLAVER_WRITE_DELAY_MAX_VALUE: return $urandom_range(63, 32);
        default:                         return 0;
    endcase
endfunction : delay_value_from_type

function axi_slaver_write_resp_e axi_slaver_write_driver::select_random_bresp(
    bit allow_exokay
);
    int unsigned okay_weight;
    int unsigned exokay_weight;
    int unsigned slverr_weight;
    int unsigned decerr_weight;
    int unsigned total_weight;
    int unsigned selection;

    if (axi_slaver_write_cfg.bresp_dist.size() !=
        AXI_SLAVER_WRITE_RESP_DIST_NUM) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            $sformatf("bresp_dist size=%0d, expected=%0d",
                axi_slaver_write_cfg.bresp_dist.size(),
                AXI_SLAVER_WRITE_RESP_DIST_NUM))
        return AXI_SLAVER_WRITE_RESP_OKAY;
    end

    // A Slave that does not implement Exclusive access ignores AWLOCK and
    // returns OKAY. Only expose the EXOKAY weight when support is enabled.
    okay_weight = axi_slaver_write_cfg.bresp_dist[0] +
        (allow_exokay ? 0 : axi_slaver_write_cfg.bresp_dist[1]);
    exokay_weight = allow_exokay ? axi_slaver_write_cfg.bresp_dist[1] : 0;
    slverr_weight = axi_slaver_write_cfg.bresp_dist[2];
    decerr_weight = axi_slaver_write_cfg.bresp_dist[3];
    total_weight = okay_weight + exokay_weight + slverr_weight + decerr_weight;
    if (total_weight == 0) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            "All effective Slaver Write BRESP weights are zero")
        return AXI_SLAVER_WRITE_RESP_OKAY;
    end

    selection = $urandom_range(total_weight - 1, 0);
    if (selection < okay_weight) begin
        return AXI_SLAVER_WRITE_RESP_OKAY;
    end
    selection -= okay_weight;
    if (selection < exokay_weight) begin
        return AXI_SLAVER_WRITE_RESP_EXOKAY;
    end
    selection -= exokay_weight;
    if (selection < slverr_weight) begin
        return AXI_SLAVER_WRITE_RESP_SLVERR;
    end
    return AXI_SLAVER_WRITE_RESP_DECERR;
endfunction : select_random_bresp

task axi_slaver_write_driver::apply_response_policy(context_t ctx);
    int unsigned selected_b_delay;
    axi_slaver_write_resp_e selected_bresp;
    longint unsigned response_anchor_cycle;

    selected_b_delay = get_b_delay();
    if (selected_b_delay > 63) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
            "Slaver Write b_delay=%0d exceeds [0:63]", selected_b_delay))
        return;
    end
    if (axi_slaver_write_cfg.fix_bresp_enable) begin
        selected_bresp = axi_slaver_write_cfg.bresp;
    end
    else if (axi_slaver_write_cfg.use_mem_model) begin
        selected_bresp = get_memory_bresp(ctx);
    end
    else begin
        selected_bresp = select_random_bresp(
            ctx.tr.awlock && axi_slaver_write_cfg.exclusive_access_enable);
    end
    if (selected_bresp == AXI_SLAVER_WRITE_RESP_EXOKAY &&
        (!ctx.tr.awlock || !axi_slaver_write_cfg.exclusive_access_enable)) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
            {"Slaver Write selected EXOKAY without an enabled Exclusive ",
             "request AWID=0x%0h AWLOCK=%0b exclusive_access_enable=%0b"},
            ctx.tr.awid, ctx.tr.awlock,
            axi_slaver_write_cfg.exclusive_access_enable))
        return;
    end

    ctx.tr.bresp = selected_bresp;
    ctx.tr.buser = axi_slaver_write_cfg.fix_buser_enable ?
        axi_slaver_write_cfg.buser : '0;
    ctx.tr.b_delay = selected_b_delay;
    ctx.tr.bid = ctx.tr.awid;
    // Anchor BVALID timing to the later of the actual AW and WLAST
    // handshakes. Arbitration can make the response later, but never reapplies
    // this per-transaction delay.
    response_anchor_cycle = (ctx.aw_handshake_cycle >
        ctx.wlast_handshake_cycle) ? ctx.aw_handshake_cycle :
        ctx.wlast_handshake_cycle;
    ctx.bvalid_eligible_cycle = response_anchor_cycle + selected_b_delay;
endtask : apply_response_policy

function axi_slaver_write_resp_e axi_slaver_write_driver::get_memory_bresp(
    context_t ctx
);
    bit exclusive_success;
    mem_resp_e memory_response;
    int unsigned request_bytes;
    axi_request_rule_e request_rule;
    int signed failing_beat;
    string observed;

    request_rule = get_write_transaction_rule(ctx, failing_beat);
    if (request_rule != AXI_REQUEST_RULE_OK) begin
        if (ctx == null || ctx.tr == null) begin
            observed = "ctx_or_transaction=null";
        end
        else begin
            observed = $sformatf(
                {"AWID=0x%0h AWADDR=0x%0h AWLEN=%0d beats=%0d ",
                 "AWSIZE=%0d AWBURST=%0d(%s) AWLOCK=%0b ",
                 "wdata_count=%0d wstrb_count=%0d wuser_count=%0d"},
                ctx.tr.awid, ctx.tr.awaddr, ctx.tr.awlen,
                int'(ctx.tr.awlen) + 1, ctx.tr.awsize,
                int'(ctx.tr.awburst), ctx.tr.awburst.name(), ctx.tr.awlock,
                ctx.tr.wdata.size(), ctx.tr.wstrb.size(),
                ctx.tr.wuser.size());
            if (request_rule == AXI_REQUEST_RULE_WSTRB_LANE &&
                failing_beat >= 0 && failing_beat < ctx.tr.wstrb.size()) begin
                observed = {observed, $sformatf(
                    " failing_beat=%0d WSTRB=0x%0h legal_mask=0x%0h",
                    failing_beat, ctx.tr.wstrb[failing_beat],
                    ctx.tr.get_beat_wstrb_mask(failing_beat))};
            end
        end
        `uvm_error("AXI_SLAVER_WRITE_PROTOCOL",
            axi_diag::format(
                request_rule.name(), "SLAVE", "AW/W",
                "transaction_validation", observed,
                get_write_rule_expectation(request_rule),
                "respond_SLVERR_without_memory_commit", get_full_name()))
        return AXI_SLAVER_WRITE_RESP_SLVERR;
    end

    if (!aw_addr_in_range(ctx)) begin
        `uvm_error("AXI_SLAVER_WRITE_ADDR_RANGE",
            axi_diag::format(
                "REQUEST_OUTSIDE_CONFIGURED_RANGE", "SLAVE", "AW/W",
                "address_range_policy",
                $sformatf(
                    {"AWID=0x%0h AWADDR=0x%0h AWLEN=%0d AWSIZE=%0d ",
                     "AWBURST=%s"},
                    ctx.tr.awid, ctx.tr.awaddr, ctx.tr.awlen,
                    ctx.tr.awsize, ctx.tr.awburst.name()),
                $sformatf("complete nominal footprint inside [0x%0h:0x%0h]",
                    axi_slaver_write_cfg.write_addr_min,
                    axi_slaver_write_cfg.write_addr_max),
                "continue_memory_response_policy", get_full_name()))
    end

    memory_response = get_memory_write_response(ctx);
    if (memory_response inside {MEM_RESP_SLVERR, MEM_RESP_DECERR}) begin
        request_bytes = (int'(ctx.tr.awlen) + 1) * (1 << ctx.tr.awsize);
        axi_slaver_write_cfg.memory_model.record_access_exception(
            MEM_OP_WRITE, ctx.tr.awaddr, request_bytes, memory_response,
            "AXI write rejected by memory segment policy");
        if (ctx.tr.awlock && axi_slaver_write_cfg.exclusive_access_enable) begin
            axi_slaver_write_cfg.memory_model.complete_exclusive_write(
                ctx.tr.awid, 1'b0);
        end
        return axi_slaver_write_resp_e'(memory_response);
    end

    if (ctx.tr.awlock && axi_slaver_write_cfg.exclusive_access_enable) begin
        exclusive_success = axi_slaver_write_cfg.memory_model.exclusive_write_matches(
            ctx.tr.awid,
            ctx.tr.awaddr,
            ctx.tr.awlen,
            ctx.tr.awsize,
            ctx.tr.awburst,
            ctx.tr.awcache,
            ctx.tr.awprot,
            ctx.tr.awregion);
        axi_slaver_write_cfg.memory_model.complete_exclusive_write(
            ctx.tr.awid, exclusive_success);
        if (exclusive_success) begin
            return AXI_SLAVER_WRITE_RESP_EXOKAY;
        end
        return AXI_SLAVER_WRITE_RESP_OKAY;
    end

    return AXI_SLAVER_WRITE_RESP_OKAY;
endfunction : get_memory_bresp

function mem_resp_e axi_slaver_write_driver::get_memory_write_response(
    context_t ctx
);
    mem_resp_e response;
    mem_resp_e byte_response;
    int unsigned beats;
    bit [STRB_WIDTH-1:0] legal_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    mem_segment_s segment;
    bit segment_valid;

    if (ctx == null || axi_slaver_write_cfg.memory_model == null ||
        ctx.tr.awsize > BUS_SIZE) begin
        return MEM_RESP_DECERR;
    end

    response = MEM_RESP_OKAY;
    beats = int'(ctx.tr.awlen) + 1;
    for (int unsigned beat = 0; beat < beats; beat++) begin
        beat_addr = ctx.tr.get_beat_addr(beat);
        bus_base = (beat_addr / STRB_WIDTH) * STRB_WIDTH;
        legal_mask = ctx.tr.get_beat_wstrb_mask(beat);
        for (int unsigned lane = 0; lane < STRB_WIDTH; lane++) begin
            if (legal_mask[lane]) begin
                segment_valid = axi_slaver_write_cfg.memory_model.find_segment_by_addr(
                    mem_addr_t'(bus_base + lane), segment);
                byte_response = axi_slaver_write_cfg.memory_model.predict_write_exception(
                    1, bus_base + lane);
                if (byte_response == MEM_RESP_DECERR) begin
                    return MEM_RESP_DECERR;
                end
                if (byte_response == MEM_RESP_SLVERR) begin
                    response = MEM_RESP_SLVERR;
                end
                if (segment_valid &&
                    !segment.supported_size_mask[ctx.tr.awsize]) begin
                    response = MEM_RESP_SLVERR;
                end
            end
        end
    end
    return response;
endfunction : get_memory_write_response

function axi_request_rule_e axi_slaver_write_driver::get_write_transaction_rule(
    context_t ctx,
    output int signed failing_beat
);
    int unsigned expected_beats;
    axi_request_rule_e rule;
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;

    failing_beat = -1;
    if (ctx == null || ctx.tr == null) begin
        return AXI_REQUEST_RULE_NULL_CONTEXT;
    end

    rule = burst_math_t::get_address_independent_rule(
        ctx.tr.awlen, ctx.tr.awsize, axi_burst_e'(ctx.tr.awburst),
        AXI_SLAVER_WRITE_MAX_BEATS, ctx.tr.awlock);
    if (rule != AXI_REQUEST_RULE_OK) begin
        return rule;
    end

    expected_beats = int'(ctx.tr.awlen) + 1;
    if (ctx.tr.wdata.size() != expected_beats) begin
        return AXI_REQUEST_RULE_WDATA_COUNT;
    end
    if (ctx.tr.wstrb.size() != expected_beats) begin
        return AXI_REQUEST_RULE_WSTRB_COUNT;
    end
    if (ctx.tr.wuser.size() != expected_beats) begin
        return AXI_REQUEST_RULE_WUSER_COUNT;
    end

    // A Slave validates every received AXI request, including the 4KB rule.
    // The helper remains silent so get_memory_bresp() owns one protocol report.
    rule = burst_math_t::get_request_geometry_rule(
        ctx.tr.awaddr, ctx.tr.awlen, ctx.tr.awsize,
        axi_burst_e'(ctx.tr.awburst), AXI_SLAVER_WRITE_MAX_BEATS,
        ctx.tr.awlock, 1'b1, low_addr, high_addr);
    if (rule != AXI_REQUEST_RULE_OK) begin
        return rule;
    end

    for (int unsigned beat = 0; beat < expected_beats; beat++) begin
        if ((ctx.tr.wstrb[beat] & ~ctx.tr.get_beat_wstrb_mask(beat)) != '0) begin
            failing_beat = beat;
            return AXI_REQUEST_RULE_WSTRB_LANE;
        end
    end

    return AXI_REQUEST_RULE_OK;
endfunction : get_write_transaction_rule

function string axi_slaver_write_driver::get_write_rule_expectation(
    axi_request_rule_e rule
);
    case (rule)
        AXI_REQUEST_RULE_NULL_CONTEXT:
            return "non-null request context and transaction";
        AXI_REQUEST_RULE_UNSUPPORTED_BURST:
            return "AWBURST inside {FIXED,INCR,WRAP}";
        AXI_REQUEST_RULE_LEN_EXCEEDS_MAX:
            return $sformatf("AWLEN+1 <= %0d", AXI_SLAVER_WRITE_MAX_BEATS);
        AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS:
            return $sformatf("AWSIZE <= %0d", BUS_SIZE);
        AXI_REQUEST_RULE_FIXED_TOO_LONG:
            return "FIXED burst has AWLEN+1 <= 16";
        AXI_REQUEST_RULE_WRAP_LENGTH:
            return "WRAP burst has AWLEN+1 inside {2,4,8,16}";
        AXI_REQUEST_RULE_WRAP_ALIGNMENT:
            return "WRAP AWADDR aligned to 2**AWSIZE bytes";
        AXI_REQUEST_RULE_ADDRESS_OVERFLOW:
            return "complete write footprint is representable in ADDR_WIDTH";
        AXI_REQUEST_RULE_CROSSES_4KB:
            return "complete write footprint remains within one 4KB region";
        AXI_REQUEST_RULE_EXCLUSIVE_BEATS:
            return "Exclusive AWLEN+1 inside {1,2,4,8,16}";
        AXI_REQUEST_RULE_EXCLUSIVE_BYTES:
            return "Exclusive total transfer bytes <= 128";
        AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT:
            return "Exclusive AWADDR aligned to total transfer bytes";
        AXI_REQUEST_RULE_WDATA_COUNT:
            return "wdata.size() == AWLEN+1";
        AXI_REQUEST_RULE_WSTRB_COUNT:
            return "wstrb.size() == AWLEN+1";
        AXI_REQUEST_RULE_WUSER_COUNT:
            return "wuser.size() == AWLEN+1";
        AXI_REQUEST_RULE_WSTRB_LANE:
            return "each WSTRB has no bit outside the AWSIZE address-lane mask";
        default:
            return "transaction satisfies the reported AXI write rule";
    endcase
endfunction : get_write_rule_expectation

function bit axi_slaver_write_driver::write_transaction_is_legal(
    context_t ctx
);
    int signed failing_beat;

    return get_write_transaction_rule(ctx, failing_beat) ==
        AXI_REQUEST_RULE_OK;
endfunction : write_transaction_is_legal

function bit axi_slaver_write_driver::aw_addr_in_range(
    context_t ctx
);
    int unsigned beats;
    bit [STRB_WIDTH-1:0] byte_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    bit [ADDR_WIDTH:0] byte_addr;
    bit [ADDR_WIDTH:0] min_addr;
    bit [ADDR_WIDTH:0] max_addr;

    aw_addr_in_range = 1'b1;
    if (!axi_slaver_write_cfg.addr_range_check_enable) begin
        return aw_addr_in_range;
    end

    aw_addr_in_range = 1'b0;
    if (ctx == null || ctx.tr.awsize > BUS_SIZE ||
        !is_supported_awburst(ctx.tr.awburst)) begin
        return aw_addr_in_range;
    end

    beats = int'(ctx.tr.awlen) + 1;
    min_addr = {1'b0, axi_slaver_write_cfg.write_addr_min};
    max_addr = {1'b0, axi_slaver_write_cfg.write_addr_max};
    for (int unsigned beat = 0; beat < beats; beat++) begin
        byte_mask = ctx.tr.get_beat_wstrb_mask(beat);
        beat_addr = ctx.tr.get_beat_addr(beat);
        bus_base = (beat_addr / STRB_WIDTH) * STRB_WIDTH;
        for (int unsigned lane = 0; lane < STRB_WIDTH; lane++) begin
            if (byte_mask[lane]) begin
                byte_addr = {1'b0, bus_base} + lane;
                if (byte_addr < min_addr || byte_addr > max_addr) begin
                    return aw_addr_in_range;
                end
            end
        end
    end

    aw_addr_in_range = 1'b1;
endfunction : aw_addr_in_range

function bit axi_slaver_write_driver::is_supported_awburst(
    axi_slaver_write_burst_e awburst
);
    return burst_math_t::is_supported_burst(
        axi_burst_e'(awburst));
endfunction : is_supported_awburst

task axi_slaver_write_driver::commit_memory_write(context_t ctx);
    int unsigned expected_beats;
    int unsigned committed_bytes;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    bit [STRB_WIDTH-1:0] legal_mask;
    mem_resp_e byte_response;

    expected_beats = int'(ctx.tr.awlen) + 1;
    if (ctx.tr.awsize > BUS_SIZE ||
        ctx.tr.wdata.size() != expected_beats ||
        ctx.tr.wstrb.size() != expected_beats) begin
        `uvm_error("AXI_MEM_WRITE",
            axi_diag::format(
                "MALFORMED_WRITE_COMMIT", "SLAVE", "AW/W",
                "memory_commit",
                $sformatf(
                    {"AWID=0x%0h AWSIZE=%0d expected_beats=%0d ",
                     "wdata_count=%0d wstrb_count=%0d"},
                    ctx.tr.awid, ctx.tr.awsize, expected_beats,
                    ctx.tr.wdata.size(), ctx.tr.wstrb.size()),
                $sformatf(
                    "AWSIZE<=%0d and both payload counts equal expected_beats",
                    BUS_SIZE),
                "skip_entire_memory_commit", get_full_name()))
        return;
    end

    committed_bytes = 0;
    for (int unsigned beat = 0; beat < expected_beats; beat++) begin
        beat_addr = ctx.tr.get_beat_addr(beat);
        bus_base = (beat_addr / STRB_WIDTH) * STRB_WIDTH;
        legal_mask = ctx.tr.get_beat_wstrb_mask(beat);

        if ((ctx.tr.wstrb[beat] & ~legal_mask) != '0) begin
            `uvm_error("AXI_MEM_WRITE",
                axi_diag::format(
                    "WSTRB_OUTSIDE_LEGAL_LANES", "SLAVE", "W",
                    "memory_commit",
                    $sformatf(
                        {"AWID=0x%0h beat=%0d beat_addr=0x%0h ",
                         "WSTRB=0x%0h legal_mask=0x%0h"},
                        ctx.tr.awid, beat, beat_addr,
                        ctx.tr.wstrb[beat], legal_mask),
                    "(WSTRB & ~legal_mask) == 0",
                    "ignore_illegal_lanes_and_continue_legal_lanes",
                    get_full_name()))
        end

        for (int unsigned lane = 0; lane < STRB_WIDTH; lane++) begin
            if (ctx.tr.wstrb[beat][lane] && legal_mask[lane]) begin
                byte_response = axi_slaver_write_cfg.memory_model.write_byte(
                    bus_base + lane,
                    ctx.tr.wdata[beat][lane*8 +: 8]);
                if (byte_response inside {MEM_RESP_OKAY, MEM_RESP_EXOKAY}) begin
                    committed_bytes++;
                end
                else begin
                    `uvm_error("AXI_MEM_WRITE_POLICY",
                        axi_diag::format(
                            "BYTE_REJECTED_AFTER_BRESP_SELECTION", "SLAVE", "W",
                            "memory_commit",
                            $sformatf(
                                {"AWID=0x%0h beat=%0d lane=%0d ",
                                 "byte_addr=0x%0h response=%s"},
                                ctx.tr.awid, beat, lane, bus_base + lane,
                                byte_response.name()),
                            "selected byte remains writable after BRESP policy",
                            "skip_rejected_byte_and_continue_commit",
                            get_full_name()))
                end
            end
        end
    end

    `uvm_info("AXI_MEM_WRITE",
        $sformatf("Committed write: AWID=0x%0h addr=0x%0h beats=%0d bytes=%0d initialized_bytes=%0d",
            ctx.tr.awid, ctx.tr.awaddr, expected_beats, committed_bytes,
            axi_slaver_write_cfg.memory_model.initialized_byte_count()),
        UVM_MEDIUM)
endtask : commit_memory_write

`endif
