// ============================================================================
// Filename             : axi_slaver_read_driver.sv
// Author               : kippy xyz
// Created On           : 2026-07-08
// Last Modified        :
// Update Count         :
// Description          : Reactive AXI read slaver driver.
// ============================================================================
`ifndef AXI_SLAVER_READ_DRIVER_SV
`define AXI_SLAVER_READ_DRIVER_SV

class axi_slaver_read_driver_context #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
);
    typedef axi_slaver_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;

    item_t             tr;
    int unsigned       beat_index;
    longint unsigned   request_seq;
    longint unsigned   rvalid_eligible_cycle;
    longint unsigned   beat_eligible_cycle;
    int unsigned       r_delay_q[$];

    function new(string name = "axi_slaver_read_tr");
        tr = item_t::type_id::create(name);
        beat_index = 0;
        request_seq = 0;
        rvalid_eligible_cycle = 0;
        beat_eligible_cycle = 0;
        r_delay_q.delete();
    endfunction : new
endclass : axi_slaver_read_driver_context

class axi_slaver_read_driver #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends uvm_driver #(axi_slaver_read_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH));
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(DATA_BYTES);
    typedef axi_slaver_read_driver #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_read_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_slaver_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef axi_slaver_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) item_t;
    typedef axi_slaver_read_driver_context #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) context_t;
    typedef axi_burst_math #(ADDR_WIDTH, DATA_BYTES) burst_math_t;
    typedef bit [DATA_WIDTH-1:0] data_t;

    vif_t    axi_slaver_read_vif;
    cfg_t axi_slaver_read_cfg;

    typedef enum int unsigned {
        AXI_SLAVER_READ_READY_IDLE,
        AXI_SLAVER_READ_READY_DELAY,
        AXI_SLAVER_READ_READY_ASSERT
    } axi_slaver_read_ready_state_e;

    typedef enum int unsigned {
        AXI_SLAVER_READ_R_IDLE,
        AXI_SLAVER_READ_R_FIRST_DELAY,
        AXI_SLAVER_READ_R_VALID,
        AXI_SLAVER_READ_R_BEAT_DELAY
    } axi_slaver_read_r_state_e;

    typedef enum int unsigned {
        AXI_SLAVER_READ_ORDER_ACCUMULATE,
        AXI_SLAVER_READ_ORDER_INITIAL_RELEASE,
        AXI_SLAVER_READ_ORDER_STRICT_IN_ORDER,
        AXI_SLAVER_READ_ORDER_READY_FOREVER
    } axi_slaver_read_order_phase_e;

    axi_slaver_read_ready_state_e arready_state;
    axi_slaver_read_r_state_e     r_state;
    axi_slaver_read_order_phase_e response_order_phase;

    bit arready_active;
    bit rvalid_active;
    int unsigned arready_delay_cnt;
    longint unsigned cycle_idx;
    longint unsigned next_request_seq;
    longint unsigned initial_release_cutoff;

    context_t r_ctx;
    context_t r_pending_q[$];

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (axi_slaver_read_cfg == null) begin
            `uvm_fatal("NOCFG", {"axi_slaver_read_cfg must be assigned directly before build for: ",
                get_full_name()})
        end
        if (axi_slaver_read_cfg.read_outstanding_depth < 1 ||
            axi_slaver_read_cfg.read_outstanding_depth > 256) begin
            `uvm_fatal("OUTSTD", "read_outstanding_depth must be inside [1:256]")
        end
        if (axi_slaver_read_cfg.memory_model == null) begin
            `uvm_fatal("AXI_MEM_CFG", "RDATA requires a non-null shared memory_model")
        end
        axi_slaver_read_vif = axi_slaver_read_cfg.axi_slaver_read_vif;
        if (axi_slaver_read_vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set in: ", get_full_name(), ".axi_slaver_read_cfg.axi_slaver_read_vif"})
        end
        axi_slaver_read_vif.set_slaver_driver_enable(1'b1);
    endfunction : build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    extern virtual protected task drive_one_cycle();
    extern virtual protected task sample_ar_if_hs(bit ar_hs);
    extern virtual protected task drive_arready_cycle(bit ar_hs);
    extern virtual protected task drive_r_channel_cycle(bit r_hs);
    extern virtual protected task start_r_response();
    extern virtual protected task drive_r_payload();
    extern virtual protected task complete_r_beat();
    // Legacy virtual hook name retained for derived Driver compatibility.
    // The base implementation is cfg-driven and consumes no sequence item.
    extern virtual protected task apply_response_policy(context_t ctx);
    extern virtual protected function bit can_accept_ar();
    extern virtual protected function bit response_arbitration_ready();
    extern virtual protected task update_response_order_phase();
    extern virtual protected function axi_response_order_e effective_response_order();
    extern virtual protected function bit initial_release_has_pending();
    extern virtual protected function longint unsigned newest_pending_request_seq();
    extern virtual protected function int select_pending_response_index();
    extern virtual protected function bit is_oldest_pending_for_id(int index);
    extern virtual protected function int unsigned get_arready_delay();
    extern virtual protected function int unsigned get_ar_r_delay();
    extern virtual protected function int unsigned get_r_delay();
    extern virtual protected function int unsigned select_delay_from_dist(int unsigned delay_dist[]);
    extern virtual protected function int unsigned delay_value_from_type(axi_slaver_read_delay_type_e delay_type);
    extern virtual protected function axi_slaver_read_resp_e select_random_rresp(
        bit allow_exokay
    );
    extern virtual protected function axi_slaver_read_resp_e get_memory_rresp(
        context_t ctx
    );
    extern virtual protected function mem_resp_e get_memory_read_response(
        context_t ctx
    );
    extern virtual protected function data_t get_response_rdata(
        context_t ctx,
        int unsigned beat_idx
    );
    extern virtual protected function data_t get_aruser_rdata(context_t ctx);
    extern virtual protected function data_t select_random_rdata();
    extern virtual protected function bit memory_byte_address_mappable(
        bit [ADDR_WIDTH:0] axi_byte_addr,
        output mem_addr_t  memory_addr
    );
    extern virtual protected function bit memory_request_addresses_mappable(
        context_t ctx
    );
    extern virtual protected function bit memory_request_initialized(context_t ctx);
    extern virtual protected function axi_request_rule_e get_ar_request_rule(
        context_t ctx
    );
    extern virtual protected function string get_ar_rule_expectation(
        axi_request_rule_e rule
    );
    extern virtual protected function bit ar_addr_in_range(context_t ctx);
    extern virtual protected function bit is_supported_arburst(axi_slaver_read_burst_e arburst);
endclass : axi_slaver_read_driver

task axi_slaver_read_driver::driver_reset();
    axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b0;
    axi_slaver_read_vif.slaver_drv_cb.rvalid  <= 1'b0;
    axi_slaver_read_vif.slaver_drv_cb.rid     <= '0;
    axi_slaver_read_vif.slaver_drv_cb.rdata   <= '0;
    axi_slaver_read_vif.slaver_drv_cb.rresp   <= '0;
    axi_slaver_read_vif.slaver_drv_cb.rlast   <= 1'b0;
    axi_slaver_read_vif.slaver_drv_cb.ruser   <= '0;

    arready_state = AXI_SLAVER_READ_READY_IDLE;
    r_state = AXI_SLAVER_READ_R_IDLE;
    if (axi_slaver_read_cfg.resp_order == AXI_RESP_READY_ORDER) begin
        response_order_phase = AXI_SLAVER_READ_ORDER_READY_FOREVER;
    end
    else if (axi_slaver_read_cfg.resp_order == AXI_RESP_IN_ORDER &&
             axi_slaver_read_cfg.save_req_num == 0) begin
        response_order_phase = AXI_SLAVER_READ_ORDER_STRICT_IN_ORDER;
    end
    else begin
        response_order_phase = AXI_SLAVER_READ_ORDER_ACCUMULATE;
    end
    arready_active = 1'b0;
    rvalid_active = 1'b0;
    arready_delay_cnt = 0;
    cycle_idx = 0;
    next_request_seq = 0;
    initial_release_cutoff = 0;
    r_ctx = null;
    r_pending_q.delete();
endtask : driver_reset

task axi_slaver_read_driver::reset_phase(uvm_phase phase);
    driver_reset();
endtask : reset_phase

task axi_slaver_read_driver::main_phase(uvm_phase phase);
    driver_reset();
    get_and_drive();
endtask : main_phase

task axi_slaver_read_driver::get_and_drive();
    forever begin
        @(axi_slaver_read_vif.slaver_drv_cb);
        if (!axi_slaver_read_vif.slaver_drv_cb.reset) begin
            driver_reset();
        end
        else begin
            drive_one_cycle();
        end
    end
endtask : get_and_drive

task axi_slaver_read_driver::drive_one_cycle();
    bit ar_hs;
    bit r_hs;

    cycle_idx++;

    ar_hs = axi_slaver_read_vif.slaver_drv_cb.arvalid && arready_active;
    r_hs  = rvalid_active && axi_slaver_read_vif.slaver_drv_cb.rready;

    sample_ar_if_hs(ar_hs);
    drive_r_channel_cycle(r_hs);
    drive_arready_cycle(ar_hs);
endtask : drive_one_cycle

task axi_slaver_read_driver::sample_ar_if_hs(bit ar_hs);
    context_t ctx;

    if (!ar_hs) begin
        return;
    end

    ctx = new("axi_slaver_read_ar_ctx");
    ctx.tr.arid     = axi_slaver_read_vif.slaver_drv_cb.arid;
    ctx.tr.araddr   = axi_slaver_read_vif.slaver_drv_cb.araddr;
    ctx.tr.arlen    = axi_slaver_read_vif.slaver_drv_cb.arlen;
    ctx.tr.arsize   = axi_slaver_read_vif.slaver_drv_cb.arsize;
    ctx.tr.arburst  = axi_slaver_read_burst_e'(axi_slaver_read_vif.slaver_drv_cb.arburst);
    ctx.tr.arlock   = axi_slaver_read_vif.slaver_drv_cb.arlock;
    ctx.tr.arcache  = axi_slaver_read_vif.slaver_drv_cb.arcache;
    ctx.tr.arprot   = axi_slaver_read_vif.slaver_drv_cb.arprot;
    ctx.tr.arqos    = axi_slaver_read_vif.slaver_drv_cb.arqos;
    ctx.tr.arregion = axi_slaver_read_vif.slaver_drv_cb.arregion;
    ctx.tr.aruser   = axi_slaver_read_vif.slaver_drv_cb.aruser;
    ctx.request_seq = next_request_seq++;

    apply_response_policy(ctx);
    r_pending_q.push_back(ctx);

    `uvm_info("AXI_SLAVER_READ_DRV",
        $sformatf("Accepted AR: id=0x%0h addr=0x%0h len=%0d",
            ctx.tr.arid, ctx.tr.araddr, ctx.tr.arlen),
        UVM_HIGH)
endtask : sample_ar_if_hs

task axi_slaver_read_driver::drive_arready_cycle(bit ar_hs);
    if (axi_slaver_read_cfg.arready_mode == AXI_ALWAYS_HIGH) begin
        arready_active = can_accept_ar();
        axi_slaver_read_vif.slaver_drv_cb.arready <= arready_active;
        arready_state = AXI_SLAVER_READ_READY_IDLE;
        arready_delay_cnt = 0;
        return;
    end

    if (!can_accept_ar()) begin
        arready_state = AXI_SLAVER_READ_READY_IDLE;
        arready_active = 1'b0;
        arready_delay_cnt = 0;
        axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b0;
        return;
    end

    case (arready_state)
        AXI_SLAVER_READ_READY_IDLE: begin
            axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b0;
            arready_active = 1'b0;
            if (axi_slaver_read_vif.slaver_drv_cb.arvalid) begin
                arready_delay_cnt = get_arready_delay();
                if (arready_delay_cnt == 0) begin
                    axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b1;
                    arready_active = 1'b1;
                    arready_state = AXI_SLAVER_READ_READY_ASSERT;
                end
                else begin
                    arready_state = AXI_SLAVER_READ_READY_DELAY;
                end
            end
        end

        AXI_SLAVER_READ_READY_DELAY: begin
            axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b0;
            arready_active = 1'b0;
            if (!axi_slaver_read_vif.slaver_drv_cb.arvalid) begin
                arready_state = AXI_SLAVER_READ_READY_IDLE;
                arready_delay_cnt = 0;
            end
            else if (arready_delay_cnt <= 1) begin
                axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b1;
                arready_active = 1'b1;
                arready_delay_cnt = 0;
                arready_state = AXI_SLAVER_READ_READY_ASSERT;
            end
            else begin
                arready_delay_cnt--;
            end
        end

        AXI_SLAVER_READ_READY_ASSERT: begin
            axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b1;
            arready_active = 1'b1;
            if (ar_hs) begin
                axi_slaver_read_vif.slaver_drv_cb.arready <= 1'b0;
                arready_active = 1'b0;
                arready_state = AXI_SLAVER_READ_READY_IDLE;
            end
        end
    endcase
endtask : drive_arready_cycle

task axi_slaver_read_driver::drive_r_channel_cycle(bit r_hs);
    int selected_index;
    axi_response_order_e effective_order;

    if (r_hs) begin
        complete_r_beat();
    end

    case (r_state)
        AXI_SLAVER_READ_R_IDLE: begin
            axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
            rvalid_active = 1'b0;
            update_response_order_phase();
            if (response_arbitration_ready()) begin
                selected_index = select_pending_response_index();
                if (selected_index >= 0) begin
                    r_ctx = r_pending_q[selected_index];
                    r_pending_q.delete(selected_index);
                    r_ctx.beat_index = 0;
                    effective_order = effective_response_order();
                    `uvm_info("AXI_SLAVER_READ_ORDER",
                        $sformatf({"Selected R response: configured=%s ",
                                   "effective=%s phase=%s RID=0x%0h ",
                                   "request_seq=%0d remaining=%0d"},
                            axi_slaver_read_cfg.resp_order.name(),
                            effective_order.name(),
                            response_order_phase.name(),
                            r_ctx.tr.rid, r_ctx.request_seq, r_pending_q.size()),
                        UVM_HIGH)
                    if (cycle_idx >= r_ctx.rvalid_eligible_cycle) begin
                        start_r_response();
                    end
                    else begin
                        r_state = AXI_SLAVER_READ_R_FIRST_DELAY;
                    end
                end
            end
        end

        AXI_SLAVER_READ_R_FIRST_DELAY: begin
            axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
            rvalid_active = 1'b0;
            if (r_ctx == null) begin
                r_state = AXI_SLAVER_READ_R_IDLE;
            end
            else if (cycle_idx >= r_ctx.rvalid_eligible_cycle) begin
                start_r_response();
            end
        end

        AXI_SLAVER_READ_R_VALID: begin
            drive_r_payload();
        end

        AXI_SLAVER_READ_R_BEAT_DELAY: begin
            axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
            rvalid_active = 1'b0;
            if (r_ctx == null) begin
                r_state = AXI_SLAVER_READ_R_IDLE;
            end
            else if (cycle_idx >= r_ctx.beat_eligible_cycle) begin
                start_r_response();
            end
        end
    endcase
endtask : drive_r_channel_cycle

task axi_slaver_read_driver::start_r_response();
    if (r_ctx == null) begin
        r_state = AXI_SLAVER_READ_R_IDLE;
        return;
    end

    drive_r_payload();
    r_state = AXI_SLAVER_READ_R_VALID;
endtask : start_r_response

task axi_slaver_read_driver::drive_r_payload();
    if (r_ctx == null) begin
        axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
        rvalid_active = 1'b0;
        r_state = AXI_SLAVER_READ_R_IDLE;
        return;
    end

    if (r_ctx.beat_index >= r_ctx.tr.rdata.size() ||
        r_ctx.beat_index >= r_ctx.tr.rresp.size() ||
        r_ctx.beat_index >= r_ctx.tr.ruser.size()) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
            {"Slaver Read response arrays are too short before RVALID: ",
             "beat=%0d rdata=%0d rresp=%0d ruser=%0d"},
            r_ctx.beat_index, r_ctx.tr.rdata.size(), r_ctx.tr.rresp.size(),
            r_ctx.tr.ruser.size()))
        return;
    end

    axi_slaver_read_vif.slaver_drv_cb.rid    <= r_ctx.tr.rid;
    axi_slaver_read_vif.slaver_drv_cb.rdata  <= r_ctx.tr.rdata[r_ctx.beat_index];
    axi_slaver_read_vif.slaver_drv_cb.rresp  <= r_ctx.tr.rresp[r_ctx.beat_index];
    axi_slaver_read_vif.slaver_drv_cb.rlast  <= (r_ctx.beat_index == r_ctx.tr.arlen);
    axi_slaver_read_vif.slaver_drv_cb.ruser  <= r_ctx.tr.ruser[r_ctx.beat_index];
    axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b1;
    rvalid_active = 1'b1;
endtask : drive_r_payload

task axi_slaver_read_driver::complete_r_beat();
    if (r_ctx == null) begin
        axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
        rvalid_active = 1'b0;
        r_state = AXI_SLAVER_READ_R_IDLE;
        return;
    end

    if (r_ctx.beat_index >= r_ctx.tr.arlen) begin
        r_ctx.tr.read_done = 1'b1;
        `uvm_info("AXI_SLAVER_READ_DRV",
            $sformatf("Completed R response: RID=0x%0h beats=%0d",
                r_ctx.tr.rid, r_ctx.tr.arlen + 1),
            UVM_HIGH)
        axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
        axi_slaver_read_vif.slaver_drv_cb.rid    <= '0;
        axi_slaver_read_vif.slaver_drv_cb.rdata  <= '0;
        axi_slaver_read_vif.slaver_drv_cb.rresp  <= '0;
        axi_slaver_read_vif.slaver_drv_cb.rlast  <= 1'b0;
        axi_slaver_read_vif.slaver_drv_cb.ruser  <= '0;
        rvalid_active = 1'b0;
        r_ctx = null;
        r_state = AXI_SLAVER_READ_R_IDLE;
    end
    else begin
        int unsigned beat_delay;

        if (r_ctx.beat_index >= r_ctx.r_delay_q.size()) begin
            `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
                "Missing Slaver Read inter-beat delay for beat %0d (count=%0d)",
                r_ctx.beat_index, r_ctx.r_delay_q.size()))
            return;
        end
        beat_delay = r_ctx.r_delay_q[r_ctx.beat_index];
        r_ctx.beat_index++;
        if (beat_delay == 0) begin
            drive_r_payload();
            r_state = AXI_SLAVER_READ_R_VALID;
        end
        else begin
            axi_slaver_read_vif.slaver_drv_cb.rvalid <= 1'b0;
            rvalid_active = 1'b0;
            r_ctx.beat_eligible_cycle = cycle_idx + beat_delay;
            r_state = AXI_SLAVER_READ_R_BEAT_DELAY;
        end
    end
endtask : complete_r_beat

task axi_slaver_read_driver::apply_response_policy(context_t ctx);
    int unsigned beats;
    int unsigned selected_ar_r_delay;
    axi_slaver_read_resp_e selected_rresp;
    axi_request_rule_e request_rule;
    string observed;

    if (ctx == null || ctx.tr == null) begin
        `uvm_fatal("AXI_RDATA_CONTEXT_NULL",
            {"Cannot prepare a Slaver Read response because the accepted AR ",
             "request context or captured transaction is null"})
        return;
    end
    selected_ar_r_delay = get_ar_r_delay();
    if (selected_ar_r_delay > 63) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
            "Slaver Read ar_r_delay=%0d exceeds [0:63]", selected_ar_r_delay))
        return;
    end
    beats = ctx.tr.arlen + 1;
    request_rule = get_ar_request_rule(ctx);
    if (request_rule != AXI_REQUEST_RULE_OK) begin
        observed = $sformatf(
            {"ARID=0x%0h ARADDR=0x%0h ARLEN=%0d beats=%0d ",
             "ARSIZE=%0d ARBURST=%0d(%s) ARLOCK=%0b"},
            ctx.tr.arid, ctx.tr.araddr, ctx.tr.arlen,
            int'(ctx.tr.arlen) + 1, ctx.tr.arsize,
            int'(ctx.tr.arburst), ctx.tr.arburst.name(), ctx.tr.arlock);
        `uvm_error("AXI_SLAVER_READ_PROTOCOL",
            axi_diag::format(
                request_rule.name(), "SLAVE", "AR",
                "request_validation", observed,
                get_ar_rule_expectation(request_rule),
                "respond_SLVERR_without_memory_access", get_full_name()))
        selected_rresp = AXI_SLAVER_READ_RESP_SLVERR;
    end
    else if (axi_slaver_read_cfg.fix_rresp_enable) begin
        selected_rresp = axi_slaver_read_cfg.rresp;
    end
    else if (axi_slaver_read_cfg.use_mem_model) begin
        selected_rresp = get_memory_rresp(ctx);
    end
    else begin
        selected_rresp = select_random_rresp(
            ctx.tr.arlock && axi_slaver_read_cfg.exclusive_access_enable);
    end
    if (selected_rresp == AXI_SLAVER_READ_RESP_EXOKAY &&
        (!ctx.tr.arlock || !axi_slaver_read_cfg.exclusive_access_enable)) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
            {"Slaver Read selected EXOKAY without an enabled Exclusive ",
             "request ARID=0x%0h ARLOCK=%0b exclusive_access_enable=%0b"},
            ctx.tr.arid, ctx.tr.arlock,
            axi_slaver_read_cfg.exclusive_access_enable))
        return;
    end

    ctx.tr.rid = ctx.tr.arid;
    ctx.tr.rdata = new[beats];
    ctx.tr.rresp = new[beats];
    ctx.tr.ruser = new[beats];

    for (int unsigned i = 0; i < beats; i++) begin
        if (selected_rresp inside {AXI_SLAVER_READ_RESP_SLVERR,
                                   AXI_SLAVER_READ_RESP_DECERR}) begin
            ctx.tr.rdata[i] = '0;
        end
        else begin
            ctx.tr.rdata[i] = get_response_rdata(ctx, i);
        end
        ctx.tr.rresp[i] = selected_rresp;
        ctx.tr.ruser[i] = axi_slaver_read_cfg.fix_ruser_enable ? axi_slaver_read_cfg.ruser : '0;
    end

    ctx.tr.beat_count = beats;
    ctx.tr.ar_r_delay = selected_ar_r_delay;
    // ar_r_delay is anchored to this AR handshake. If arbitration or an
    // earlier R burst holds the response beyond this deadline, it may start
    // immediately when selected instead of applying the delay again.
    ctx.rvalid_eligible_cycle = cycle_idx + selected_ar_r_delay;
    ctx.r_delay_q.delete();
    for (int unsigned beat = 0; beat < ctx.tr.arlen; beat++) begin
        int unsigned selected_delay;
        selected_delay = get_r_delay();
        if (selected_delay > 63) begin
            `uvm_fatal("AXI_REQUEST_PREPARE_FAILED", $sformatf(
                "Slaver Read r_delay=%0d exceeds [0:63]", selected_delay))
            return;
        end
        ctx.r_delay_q.push_back(selected_delay);
    end

    `uvm_info("AXI_MEM_READ",
        $sformatf("Prepared read: ARID=0x%0h addr=0x%0h beats=%0d bytes/beat=%0d initialized=%0b",
            ctx.tr.arid, ctx.tr.araddr, beats, 1 << ctx.tr.arsize,
            memory_request_initialized(ctx)),
        UVM_MEDIUM)
endtask : apply_response_policy

function bit axi_slaver_read_driver::can_accept_ar();
    int unsigned depth;

    depth = r_pending_q.size();
    if (r_ctx != null) begin
        depth++;
    end

    return depth < axi_slaver_read_cfg.read_outstanding_depth;
endfunction : can_accept_ar

function bit axi_slaver_read_driver::response_arbitration_ready();
    if (r_pending_q.size() == 0) begin
        return 1'b0;
    end

    case (response_order_phase)
        AXI_SLAVER_READ_ORDER_ACCUMULATE: begin
            return 1'b0;
        end

        AXI_SLAVER_READ_ORDER_INITIAL_RELEASE,
        AXI_SLAVER_READ_ORDER_STRICT_IN_ORDER,
        AXI_SLAVER_READ_ORDER_READY_FOREVER: begin
            return select_pending_response_index() >= 0;
        end
    endcase

    return 1'b0;
endfunction : response_arbitration_ready

task axi_slaver_read_driver::update_response_order_phase();
    axi_response_order_e effective_order;

    case (response_order_phase)
        AXI_SLAVER_READ_ORDER_ACCUMULATE: begin
            if (r_pending_q.size() >= axi_slaver_read_cfg.save_req_num) begin
                initial_release_cutoff = newest_pending_request_seq();
                response_order_phase =
                    AXI_SLAVER_READ_ORDER_INITIAL_RELEASE;
                effective_order = effective_response_order();
                `uvm_info("AXI_SLAVER_READ_ORDER",
                    $sformatf({"Response order phase opened: configured=%s ",
                               "effective=%s phase=%s frozen_count=%0d ",
                               "cutoff=%0d"},
                        axi_slaver_read_cfg.resp_order.name(),
                        effective_order.name(),
                        response_order_phase.name(), r_pending_q.size(),
                        initial_release_cutoff),
                    UVM_HIGH)
            end
        end

        AXI_SLAVER_READ_ORDER_INITIAL_RELEASE: begin
            if (r_ctx == null && !initial_release_has_pending()) begin
                response_order_phase = AXI_SLAVER_READ_ORDER_READY_FOREVER;
                initial_release_cutoff = 0;
                effective_order = effective_response_order();
                `uvm_info("AXI_SLAVER_READ_ORDER",
                    $sformatf({"Response order phase completed: configured=%s ",
                               "effective=%s phase=%s waiting=%0d"},
                        axi_slaver_read_cfg.resp_order.name(),
                        effective_order.name(),
                        response_order_phase.name(), r_pending_q.size()),
                    UVM_HIGH)
            end
        end

        AXI_SLAVER_READ_ORDER_STRICT_IN_ORDER: begin
            // This phase is permanent until reset. The queue-head eligibility
            // check is performed by select_pending_response_index().
            initial_release_cutoff = 0;
        end

        AXI_SLAVER_READ_ORDER_READY_FOREVER: begin
            initial_release_cutoff = 0;
        end

        default: begin
            `uvm_error("AXI_SLAVER_READ_ORDER",
                axi_diag::format(
                    "UNSUPPORTED_RESPONSE_ORDER_PHASE", "SLAVE", "R",
                    "response_arbitration",
                    $sformatf("phase=%0d configured=%0d pending=%0d",
                        int'(response_order_phase),
                        int'(axi_slaver_read_cfg.resp_order),
                        r_pending_q.size()),
                    {"phase inside {ACCUMULATE,INITIAL_RELEASE,",
                     "STRICT_IN_ORDER,READY_FOREVER}"},
                    "fallback_to_READY_FOREVER", get_full_name()))
            response_order_phase = AXI_SLAVER_READ_ORDER_READY_FOREVER;
            initial_release_cutoff = 0;
        end
    endcase
endtask : update_response_order_phase

function axi_response_order_e axi_slaver_read_driver::effective_response_order();
    if (response_order_phase == AXI_SLAVER_READ_ORDER_READY_FOREVER) begin
        return AXI_RESP_READY_ORDER;
    end
    if (response_order_phase == AXI_SLAVER_READ_ORDER_STRICT_IN_ORDER) begin
        return AXI_RESP_IN_ORDER;
    end
    return axi_slaver_read_cfg.resp_order;
endfunction : effective_response_order

function bit axi_slaver_read_driver::initial_release_has_pending();
    foreach (r_pending_q[i]) begin
        if (r_pending_q[i].request_seq <= initial_release_cutoff) begin
            return 1'b1;
        end
    end
    return 1'b0;
endfunction : initial_release_has_pending

function longint unsigned axi_slaver_read_driver::newest_pending_request_seq();
    longint unsigned newest;

    newest = 0;
    foreach (r_pending_q[i]) begin
        if (r_pending_q[i].request_seq > newest) begin
            newest = r_pending_q[i].request_seq;
        end
    end
    return newest;
endfunction : newest_pending_request_seq

function int axi_slaver_read_driver::select_pending_response_index();
    if (r_pending_q.size() == 0) begin
        return -1;
    end

    case (effective_response_order())
        AXI_RESP_IN_ORDER: begin
            if (response_order_phase ==
                AXI_SLAVER_READ_ORDER_STRICT_IN_ORDER) begin
                // r_pending_q is maintained in AR-handshake order in this
                // permanent phase. Do not remove or bypass the head while its
                // independently selected ar_r_delay is still running.
                if (cycle_idx >= r_pending_q[0].rvalid_eligible_cycle) begin
                    return 0;
                end
                return -1;
            end

            foreach (r_pending_q[i]) begin
                if (r_pending_q[i].request_seq <= initial_release_cutoff) begin
                    return i;
                end
            end
        end

        AXI_RESP_REVERSE_ORDER: begin
            for (int i = r_pending_q.size() - 1; i >= 0; i--) begin
                if (r_pending_q[i].request_seq <= initial_release_cutoff &&
                    is_oldest_pending_for_id(i)) begin
                    return i;
                end
            end
        end

        AXI_RESP_READY_ORDER: begin
            foreach (r_pending_q[i]) begin
                if (cycle_idx >= r_pending_q[i].rvalid_eligible_cycle &&
                    is_oldest_pending_for_id(i)) begin
                    return i;
                end
            end
        end

        default: begin
            `uvm_error("AXI_SLAVER_READ_ORDER",
                axi_diag::format(
                    "UNSUPPORTED_RESPONSE_ORDER", "SLAVE", "R",
                    "response_arbitration",
                    $sformatf({"configured_resp_order=%0d ",
                               "effective_resp_order=%0d phase=%0d pending=%0d"},
                        int'(axi_slaver_read_cfg.resp_order),
                        int'(effective_response_order()),
                        int'(response_order_phase),
                        r_pending_q.size()),
                    "resp_order inside {IN_ORDER,REVERSE_ORDER,READY_ORDER}",
                    "fallback_to_IN_ORDER", get_full_name()))
            return 0;
        end
    endcase

    return -1;
endfunction : select_pending_response_index

function bit axi_slaver_read_driver::is_oldest_pending_for_id(int index);
    if (index < 0 || index >= r_pending_q.size()) begin
        return 1'b0;
    end

    foreach (r_pending_q[i]) begin
        if (r_pending_q[i].tr.arid == r_pending_q[index].tr.arid &&
            r_pending_q[i].request_seq < r_pending_q[index].request_seq) begin
            return 1'b0;
        end
    end
    return 1'b1;
endfunction : is_oldest_pending_for_id

function int unsigned axi_slaver_read_driver::get_arready_delay();
    if (axi_slaver_read_cfg.arready_mode == AXI_ALWAYS_HIGH) begin
        return 0;
    end
    if (axi_slaver_read_cfg.fix_arready_delay_enable) begin
        return axi_slaver_read_cfg.arready_delay;
    end

    return select_delay_from_dist(axi_slaver_read_cfg.arready_delay_type_dist);
endfunction : get_arready_delay

function int unsigned axi_slaver_read_driver::get_ar_r_delay();
    if (axi_slaver_read_cfg.fix_ar_r_delay_enable) begin
        return axi_slaver_read_cfg.ar_r_delay;
    end

    return select_delay_from_dist(axi_slaver_read_cfg.ar_r_delay_dist);
endfunction : get_ar_r_delay

function int unsigned axi_slaver_read_driver::get_r_delay();
    if (axi_slaver_read_cfg.fix_r_delay_enable) begin
        return axi_slaver_read_cfg.r_delay;
    end

    return select_delay_from_dist(axi_slaver_read_cfg.r_delay_dist);
endfunction : get_r_delay

function int unsigned axi_slaver_read_driver::select_delay_from_dist(int unsigned delay_dist[]);
    int unsigned total;
    int unsigned pick;
    int unsigned acc;

    total = 0;
    foreach (delay_dist[i]) begin
        total += delay_dist[i];
    end

    if (total == 0) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            "Slaver Read delay distribution has no positive-weight candidate")
        return 0;
    end

    pick = $urandom_range(total - 1, 0);
    acc = 0;
    foreach (delay_dist[i]) begin
        acc += delay_dist[i];
        if (pick < acc) begin
            return delay_value_from_type(axi_slaver_read_delay_type_e'(i));
        end
    end

    return 0;
endfunction : select_delay_from_dist

function int unsigned axi_slaver_read_driver::delay_value_from_type(axi_slaver_read_delay_type_e delay_type);
    case (delay_type)
        AXI_SLAVER_READ_DELAY_ZERO:      return 0;
        AXI_SLAVER_READ_DELAY_SHORT:     return $urandom_range(3, 1);
        AXI_SLAVER_READ_DELAY_MID:       return $urandom_range(10, 4);
        AXI_SLAVER_READ_DELAY_LONG:      return $urandom_range(31, 11);
        AXI_SLAVER_READ_DELAY_MAX_VALUE: return $urandom_range(63, 32);
        default:                  return 0;
    endcase
endfunction : delay_value_from_type

function axi_slaver_read_resp_e axi_slaver_read_driver::select_random_rresp(
    bit allow_exokay
);
    int unsigned okay_weight;
    int unsigned exokay_weight;
    int unsigned slverr_weight;
    int unsigned decerr_weight;
    int unsigned total_weight;
    int unsigned selection;

    if (axi_slaver_read_cfg.rresp_dist.size() !=
        AXI_SLAVER_READ_RESP_DIST_NUM) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            $sformatf("rresp_dist size=%0d, expected=%0d",
                axi_slaver_read_cfg.rresp_dist.size(),
                AXI_SLAVER_READ_RESP_DIST_NUM))
        return AXI_SLAVER_READ_RESP_OKAY;
    end

    // A Slave that does not implement Exclusive access must return OKAY, not
    // EXOKAY, for a locked request. Fold that weight into OKAY unless this
    // endpoint explicitly enables Exclusive support for the request.
    okay_weight = axi_slaver_read_cfg.rresp_dist[0] +
        (allow_exokay ? 0 : axi_slaver_read_cfg.rresp_dist[1]);
    exokay_weight = allow_exokay ? axi_slaver_read_cfg.rresp_dist[1] : 0;
    slverr_weight = axi_slaver_read_cfg.rresp_dist[2];
    decerr_weight = axi_slaver_read_cfg.rresp_dist[3];
    total_weight = okay_weight + exokay_weight + slverr_weight + decerr_weight;
    if (total_weight == 0) begin
        `uvm_fatal("AXI_REQUEST_PREPARE_FAILED",
            "All effective Slaver Read RRESP weights are zero")
        return AXI_SLAVER_READ_RESP_OKAY;
    end

    selection = $urandom_range(total_weight - 1, 0);
    if (selection < okay_weight) begin
        return AXI_SLAVER_READ_RESP_OKAY;
    end
    selection -= okay_weight;
    if (selection < exokay_weight) begin
        return AXI_SLAVER_READ_RESP_EXOKAY;
    end
    selection -= exokay_weight;
    if (selection < slverr_weight) begin
        return AXI_SLAVER_READ_RESP_SLVERR;
    end
    return AXI_SLAVER_READ_RESP_DECERR;
endfunction : select_random_rresp

function axi_slaver_read_resp_e axi_slaver_read_driver::get_memory_rresp(
    context_t ctx
);
    mem_resp_e memory_response;
    int unsigned request_bytes;

    // The common geometry check has already run in apply_response_policy().
    // Check the complete effective-byte footprint before the first model
    // query so an AXI address wider than mem_addr_t cannot alias into its low
    // bits or leave partial model side effects.
    if (!memory_request_addresses_mappable(ctx)) begin
        `uvm_warning("AXI_MEM_ADDRESS_DOMAIN",
            axi_diag::format(
                "MEM_ADDRESS_OUTSIDE_MODEL_DOMAIN", "SLAVE", "R",
                "memory_address_mapping",
                $sformatf(
                    {"ARID=0x%0h ARADDR=0x%0h ARLEN=%0d ARSIZE=%0d ",
                     "ADDR_WIDTH=%0d mem_addr_bits=%0d"},
                    ctx.tr.arid, ctx.tr.araddr, ctx.tr.arlen,
                    ctx.tr.arsize, ADDR_WIDTH, $bits(mem_addr_t)),
                "every effective read byte round-trips through mem_addr_t",
                "respond_DECERR_without_model_access", get_full_name()))
        return AXI_SLAVER_READ_RESP_DECERR;
    end

    if (!ar_addr_in_range(ctx)) begin
        `uvm_error("AXI_SLAVER_READ_ADDR_RANGE",
            axi_diag::format(
                "REQUEST_OUTSIDE_CONFIGURED_RANGE", "SLAVE", "AR",
                "address_range_policy",
                $sformatf(
                    {"ARID=0x%0h ARADDR=0x%0h ARLEN=%0d ARSIZE=%0d ",
                     "ARBURST=%s"},
                    ctx.tr.arid, ctx.tr.araddr, ctx.tr.arlen,
                    ctx.tr.arsize, ctx.tr.arburst.name()),
                $sformatf("complete footprint inside [0x%0h:0x%0h]",
                    axi_slaver_read_cfg.read_addr_min,
                    axi_slaver_read_cfg.read_addr_max),
                "continue_memory_response_policy", get_full_name()))
    end

    memory_response = get_memory_read_response(ctx);
    if (memory_response inside {MEM_RESP_SLVERR, MEM_RESP_DECERR}) begin
        request_bytes = (int'(ctx.tr.arlen) + 1) * (1 << ctx.tr.arsize);
        axi_slaver_read_cfg.memory_model.record_access_exception(
            MEM_OP_READ, ctx.tr.araddr, request_bytes, memory_response,
            "AXI read rejected by memory segment policy");
        return axi_slaver_read_resp_e'(memory_response);
    end

    if (axi_slaver_read_cfg.memory_error_on_uninitialized_read &&
        !memory_request_initialized(ctx)) begin
        request_bytes = (int'(ctx.tr.arlen) + 1) * (1 << ctx.tr.arsize);
        axi_slaver_read_cfg.memory_model.record_access_exception(
            MEM_OP_READ, ctx.tr.araddr, request_bytes, MEM_RESP_SLVERR,
            "AXI read rejected because requested memory is uninitialized");
        return AXI_SLAVER_READ_RESP_SLVERR;
    end

    if (ctx.tr.arlock && axi_slaver_read_cfg.exclusive_access_enable) begin
        if (axi_slaver_read_cfg.memory_model.reserve_exclusive(
                ctx.tr.arid,
                ctx.tr.araddr,
                ctx.tr.arlen,
                ctx.tr.arsize,
                ctx.tr.arburst,
                ctx.tr.arcache,
                ctx.tr.arprot,
                ctx.tr.arregion)) begin
            return AXI_SLAVER_READ_RESP_EXOKAY;
        end
        // A segment that does not support Exclusive treats the request as a
        // normal read and advertises that fact with OKAY rather than EXOKAY.
        return AXI_SLAVER_READ_RESP_OKAY;
    end

    return AXI_SLAVER_READ_RESP_OKAY;
endfunction : get_memory_rresp

function mem_resp_e axi_slaver_read_driver::get_memory_read_response(
    context_t ctx
);
    mem_resp_e response;
    mem_resp_e byte_response;
    int unsigned beats;
    bit [DATA_BYTES-1:0] byte_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    mem_segment_s segment;
    bit segment_valid;

    if (ctx == null || ctx.tr == null ||
        axi_slaver_read_cfg.memory_model == null ||
        ctx.tr.arsize > BUS_SIZE) begin
        return MEM_RESP_DECERR;
    end

    response = MEM_RESP_OKAY;
    beats = int'(ctx.tr.arlen) + 1;
    for (int unsigned beat = 0; beat < beats; beat++) begin
        byte_mask = ctx.tr.get_beat_rdata_valid_mask(beat);
        beat_addr = ctx.tr.get_beat_addr(beat);
        bus_base = (beat_addr / DATA_BYTES) * DATA_BYTES;
        for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
            if (byte_mask[lane]) begin
                segment_valid = axi_slaver_read_cfg.memory_model.find_segment_by_addr(
                    mem_addr_t'(bus_base + lane), segment);
                byte_response = axi_slaver_read_cfg.memory_model.predict_read_exception(
                    1, bus_base + lane);
                if (byte_response == MEM_RESP_DECERR) begin
                    return MEM_RESP_DECERR;
                end
                if (byte_response == MEM_RESP_SLVERR) begin
                    response = MEM_RESP_SLVERR;
                end
                if (segment_valid &&
                    !segment.supported_size_mask[ctx.tr.arsize]) begin
                    response = MEM_RESP_SLVERR;
                end
            end
        end
    end
    return response;
endfunction : get_memory_read_response

function axi_slaver_read_driver::data_t axi_slaver_read_driver::get_response_rdata(
    context_t ctx,
    int unsigned beat_idx
);
    bit [DATA_WIDTH-1:0] data;
    bit [DATA_WIDTH-1:0] selected_data;
    bit [DATA_BYTES-1:0] byte_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    mem_addr_t lane_addr;
    bit [ADDR_WIDTH:0] lane_addr_ext;
    bit active_lanes_from_memory;
    bit lane_address_mappable;

    data = '0;
    if (ctx == null || ctx.tr == null) begin
        `uvm_fatal("AXI_RDATA_CONTEXT_NULL",
            {"Cannot generate successful RDATA because the accepted AR ",
             "request context or captured transaction is null"})
        return '0;
    end
    if (axi_slaver_read_cfg.memory_model == null) begin
        `uvm_fatal("AXI_RDATA_MEMORY_MODEL_NULL", $sformatf(
            {"Cannot generate successful RDATA for ARID=0x%0h: ",
             "memory_model is null; a model is required for inactive-lane ",
             "storage bytes in every RDATA source mode"}, ctx.tr.arid))
        return '0;
    end
    if (beat_idx > ctx.tr.arlen) begin
        `uvm_fatal("AXI_RDATA_BEAT_INDEX", $sformatf(
            {"Cannot generate RDATA for ARID=0x%0h: beat_idx=%0d exceeds ",
             "ARLEN=%0d (valid beat indices [0:%0d])"},
            ctx.tr.arid, beat_idx, ctx.tr.arlen, ctx.tr.arlen))
        return '0;
    end
    if (ctx.tr.arsize > BUS_SIZE) begin
        `uvm_fatal("AXI_RDATA_SIZE_EXCEEDS_BUS", $sformatf(
            {"Cannot generate RDATA for ARID=0x%0h: ARSIZE=%0d exceeds ",
             "bus maximum SIZE=%0d for DATA_WIDTH=%0d"},
            ctx.tr.arid, ctx.tr.arsize, BUS_SIZE, DATA_WIDTH))
        return '0;
    end

    if (axi_slaver_read_cfg.fix_rdata_enable &&
        axi_slaver_read_cfg.rdata_from_aruser_enable) begin
        `uvm_fatal("AXI_RDATA_SOURCE_CONFLICT", $sformatf(
            {"Cannot generate RDATA for ARID=0x%0h: fix_rdata_enable=1 and ",
             "rdata_from_aruser_enable=1 select two explicit sources; ",
             "disable one source"}, ctx.tr.arid))
        return '0;
    end

    active_lanes_from_memory = 1'b0;
    if (axi_slaver_read_cfg.fix_rdata_enable) begin
        selected_data = axi_slaver_read_cfg.rdata;
    end
    else if (axi_slaver_read_cfg.rdata_from_aruser_enable) begin
        selected_data = get_aruser_rdata(ctx);
    end
    else if (axi_slaver_read_cfg.use_mem_model) begin
        selected_data = '0;
        active_lanes_from_memory = 1'b1;
    end
    else begin
        selected_data = select_random_rdata();
    end

    byte_mask = ctx.tr.get_beat_rdata_valid_mask(beat_idx);
    beat_addr = ctx.tr.get_beat_addr(beat_idx);
    bus_base = (beat_addr / DATA_BYTES) * DATA_BYTES;

    for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
        // Extend before the addition so the lane address cannot wrap in
        // ADDR_WIDTH bits before its lossless mem_addr_t round-trip check.
        lane_addr_ext = {1'b0, bus_base} + lane;
        lane_address_mappable = memory_byte_address_mappable(
            lane_addr_ext, lane_addr);
        if (byte_mask[lane]) begin
            if (active_lanes_from_memory) begin
                data[lane*8 +: 8] = lane_address_mappable ?
                    axi_slaver_read_cfg.memory_model.read_byte(lane_addr) :
                    axi_slaver_read_cfg.memory_model.default_read_value;
            end
            else begin
                data[lane*8 +: 8] = selected_data[lane*8 +: 8];
            end
        end
        else begin
            data[lane*8 +: 8] = lane_address_mappable ?
                axi_slaver_read_cfg.memory_model.get_storage_byte(lane_addr) :
                axi_slaver_read_cfg.memory_model.default_read_value;
        end
    end

    return data;
endfunction : get_response_rdata

function axi_slaver_read_driver::data_t axi_slaver_read_driver::get_aruser_rdata(
    context_t ctx
);
    data_t data;

    data = '0;
    if (ctx == null || ctx.tr == null) begin
        `uvm_fatal("AXI_RDATA_ARUSER_SOURCE",
            "Cannot generate ARUSER-derived RDATA because the captured AR transaction is null")
        return data;
    end
    // ARUSER occupies the least-significant RDATA bits.  A narrower ARUSER
    // is zero-extended; a wider ARUSER is truncated above DATA_WIDTH.
    for (int unsigned bit_index = 0;
         bit_index < DATA_WIDTH && bit_index < USER_WIDTH;
         bit_index++) begin
        data[bit_index] = ctx.tr.aruser[bit_index];
    end
    return data;
endfunction : get_aruser_rdata

function axi_slaver_read_driver::data_t axi_slaver_read_driver::select_random_rdata();
    data_t data;
    int unsigned total_weight;
    int unsigned selection;

    data = '0;
    if (axi_slaver_read_cfg.rdata_dist.size() !=
        AXI_SLAVER_READ_RDATA_DIST_NUM) begin
        `uvm_fatal("AXI_RDATA_DIST_SIZE", $sformatf(
            {"Cannot select random RDATA: rdata_dist size=%0d, expected=%0d ",
             "for {ZERO,MIDDLE,ALL_ONES}"},
            axi_slaver_read_cfg.rdata_dist.size(),
            AXI_SLAVER_READ_RDATA_DIST_NUM))
        return data;
    end

    total_weight = 0;
    foreach (axi_slaver_read_cfg.rdata_dist[i]) begin
        if (axi_slaver_read_cfg.rdata_dist[i] > 100) begin
            `uvm_fatal("AXI_RDATA_DIST_WEIGHT", $sformatf(
                {"Cannot select random RDATA: rdata_dist[%0d]=%0d exceeds ",
                 "the supported weight range [0:100]; action=set every ",
                 "rdata_dist entry inside [0:100]"},
                i, axi_slaver_read_cfg.rdata_dist[i]))
            return data;
        end
        total_weight += axi_slaver_read_cfg.rdata_dist[i];
    end
    if (total_weight == 0) begin
        `uvm_fatal("AXI_RDATA_DIST_EMPTY",
            {"Cannot select random RDATA: all rdata_dist weights are zero; ",
             "enable at least one of {ZERO,MIDDLE,ALL_ONES}"})
        return data;
    end
    if (total_weight != 100) begin
        `uvm_fatal("AXI_RDATA_DIST_SUM", $sformatf(
            {"Cannot select random RDATA: rdata_dist sum=%0d, expected=100 ",
             "for percentage weights {ZERO,MIDDLE,ALL_ONES}; action=adjust ",
             "the three weights so their sum is 100"}, total_weight))
        return data;
    end

    selection = $urandom_range(total_weight - 1, 0);
    if (selection < axi_slaver_read_cfg.rdata_dist[0]) begin
        return '0;
    end
    selection -= axi_slaver_read_cfg.rdata_dist[0];
    if (selection >= axi_slaver_read_cfg.rdata_dist[1]) begin
        return '1;
    end

    // The middle bin excludes both endpoints.  Fill every byte independently
    // so parameterized DATA_WIDTH values through 1024 bits are supported.
    for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
        data[lane*8 +: 8] = $urandom_range(8'hff, 8'h00);
    end
    if (data == '0) begin
        data[0] = 1'b1;
    end
    else if (data == '1) begin
        data[0] = 1'b0;
    end
    return data;
endfunction : select_random_rdata

function bit axi_slaver_read_driver::memory_byte_address_mappable(
    bit [ADDR_WIDTH:0] axi_byte_addr,
    output mem_addr_t  memory_addr
);
    bit [ADDR_WIDTH-1:0] round_trip_addr;

    memory_addr = mem_addr_t'(axi_byte_addr[ADDR_WIDTH-1:0]);
    if (axi_byte_addr[ADDR_WIDTH]) begin
        return 1'b0;
    end
    round_trip_addr = memory_addr;
    return round_trip_addr == axi_byte_addr[ADDR_WIDTH-1:0];
endfunction : memory_byte_address_mappable

function bit axi_slaver_read_driver::memory_request_addresses_mappable(
    context_t ctx
);
    int unsigned beats;
    bit [DATA_BYTES-1:0] byte_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    bit [ADDR_WIDTH:0] lane_addr_ext;
    mem_addr_t lane_addr;

    if (ctx == null || ctx.tr == null || ctx.tr.arsize > BUS_SIZE) begin
        return 1'b0;
    end

    beats = int'(ctx.tr.arlen) + 1;
    for (int unsigned beat = 0; beat < beats; beat++) begin
        byte_mask = ctx.tr.get_beat_rdata_valid_mask(beat);
        beat_addr = ctx.tr.get_beat_addr(beat);
        bus_base = (beat_addr / DATA_BYTES) * DATA_BYTES;
        for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
            if (byte_mask[lane]) begin
                lane_addr_ext = {1'b0, bus_base} + lane;
                if (!memory_byte_address_mappable(
                        lane_addr_ext, lane_addr)) begin
                    return 1'b0;
                end
            end
        end
    end
    return 1'b1;
endfunction : memory_request_addresses_mappable

function bit axi_slaver_read_driver::memory_request_initialized(context_t ctx);
    int unsigned beats;
    bit [DATA_BYTES-1:0] byte_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    bit [ADDR_WIDTH:0] lane_addr_ext;
    mem_addr_t lane_addr;

    memory_request_initialized = 1'b0;
    if (ctx == null || ctx.tr == null ||
        axi_slaver_read_cfg.memory_model == null ||
        ctx.tr.arsize > BUS_SIZE) begin
        return memory_request_initialized;
    end

    beats = int'(ctx.tr.arlen) + 1;
    for (int unsigned beat = 0; beat < beats; beat++) begin
        byte_mask = ctx.tr.get_beat_rdata_valid_mask(beat);
        beat_addr = ctx.tr.get_beat_addr(beat);
        bus_base = (beat_addr / DATA_BYTES) * DATA_BYTES;
        for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
            if (byte_mask[lane]) begin
                lane_addr_ext = {1'b0, bus_base} + lane;
                if (!memory_byte_address_mappable(
                        lane_addr_ext, lane_addr) ||
                    !axi_slaver_read_cfg.memory_model.is_initialized(
                        lane_addr)) begin
                    return memory_request_initialized;
                end
            end
        end
    end

    memory_request_initialized = 1'b1;
endfunction : memory_request_initialized

function axi_request_rule_e axi_slaver_read_driver::get_ar_request_rule(
    context_t ctx
);
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;

    if (ctx == null || ctx.tr == null) begin
        return AXI_REQUEST_RULE_NULL_CONTEXT;
    end

    // A Slave validates every received AXI request, including the 4KB rule.
    // This helper is deliberately silent; apply_response_policy() owns the
    // single Driver-side protocol report and the SLVERR response decision.
    return burst_math_t::get_request_geometry_rule(
        ctx.tr.araddr, ctx.tr.arlen, ctx.tr.arsize,
        axi_burst_e'(ctx.tr.arburst), AXI_SLAVER_READ_MAX_BEATS,
        ctx.tr.arlock, 1'b1, low_addr, high_addr);
endfunction : get_ar_request_rule

function string axi_slaver_read_driver::get_ar_rule_expectation(
    axi_request_rule_e rule
);
    case (rule)
        AXI_REQUEST_RULE_NULL_CONTEXT:
            return "non-null request context and transaction";
        AXI_REQUEST_RULE_UNSUPPORTED_BURST:
            return "ARBURST inside {FIXED,INCR,WRAP}";
        AXI_REQUEST_RULE_LEN_EXCEEDS_MAX:
            return $sformatf("ARLEN+1 <= %0d", AXI_SLAVER_READ_MAX_BEATS);
        AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS:
            return $sformatf("ARSIZE <= %0d", BUS_SIZE);
        AXI_REQUEST_RULE_FIXED_TOO_LONG:
            return "FIXED burst has ARLEN+1 <= 16";
        AXI_REQUEST_RULE_WRAP_LENGTH:
            return "WRAP burst has ARLEN+1 inside {2,4,8,16}";
        AXI_REQUEST_RULE_WRAP_ALIGNMENT:
            return "WRAP ARADDR aligned to 2**ARSIZE bytes";
        AXI_REQUEST_RULE_ADDRESS_OVERFLOW:
            return "complete read footprint is representable in ADDR_WIDTH";
        AXI_REQUEST_RULE_CROSSES_4KB:
            return "complete read footprint remains within one 4KB region";
        AXI_REQUEST_RULE_EXCLUSIVE_BEATS:
            return "Exclusive ARLEN+1 inside {1,2,4,8,16}";
        AXI_REQUEST_RULE_EXCLUSIVE_BYTES:
            return "Exclusive total transfer bytes <= 128";
        AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT:
            return "Exclusive ARADDR aligned to total transfer bytes";
        default:
            return "request satisfies the reported AXI read rule";
    endcase
endfunction : get_ar_rule_expectation

function bit axi_slaver_read_driver::ar_addr_in_range(context_t ctx);
    int unsigned beats;
    bit [DATA_BYTES-1:0] byte_mask;
    bit [ADDR_WIDTH-1:0] beat_addr;
    bit [ADDR_WIDTH-1:0] bus_base;
    bit [ADDR_WIDTH:0] byte_addr;
    bit [ADDR_WIDTH:0] min_addr;
    bit [ADDR_WIDTH:0] max_addr;

    ar_addr_in_range = 1'b1;
    if (!axi_slaver_read_cfg.addr_range_check_enable) begin
        return ar_addr_in_range;
    end

    ar_addr_in_range = 1'b0;
    if (ctx == null ||
        ctx.tr.arsize > BUS_SIZE ||
        !is_supported_arburst(ctx.tr.arburst)) begin
        return ar_addr_in_range;
    end

    if (ctx.tr.arburst == AXI_SLAVER_READ_BURST_WRAP) begin
        if (!(ctx.tr.arlen inside {8'd1, 8'd3, 8'd7, 8'd15}) ||
            ((ctx.tr.araddr % (1 << ctx.tr.arsize)) != 0)) begin
            return ar_addr_in_range;
        end
    end

    beats = ctx.tr.arlen + 1;
    min_addr = {1'b0, axi_slaver_read_cfg.read_addr_min};
    max_addr = {1'b0, axi_slaver_read_cfg.read_addr_max};

    for (int unsigned i = 0; i < beats; i++) begin
        byte_mask = ctx.tr.get_beat_rdata_valid_mask(i);
        if (byte_mask == '0) begin
            return ar_addr_in_range;
        end

        beat_addr = ctx.tr.get_beat_addr(i);
        bus_base = (beat_addr / DATA_BYTES) * DATA_BYTES;
        for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
            if (byte_mask[lane]) begin
                byte_addr = {1'b0, bus_base} + lane;
                if (byte_addr < min_addr || byte_addr > max_addr) begin
                    return ar_addr_in_range;
                end
            end
        end
    end

    ar_addr_in_range = 1'b1;
endfunction : ar_addr_in_range

function bit axi_slaver_read_driver::is_supported_arburst(axi_slaver_read_burst_e arburst);
    return burst_math_t::is_supported_burst(axi_burst_e'(arburst));
endfunction : is_supported_arburst

`endif
