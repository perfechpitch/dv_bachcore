// ============================================================================
// Filename             : axi_write_monitor.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_WRITE_MONITOR_SV
`define AXI_WRITE_MONITOR_SV

class axi_write_monitor_context #(
    int unsigned ID_WIDTH,
    int unsigned ADDR_WIDTH,
    int unsigned DATA_WIDTH,
    int unsigned USER_WIDTH
);
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;
    typedef axi_write_transaction #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) transaction_t;
    // One context tracks one in-flight write transaction while AW, W, and B
    // may arrive on different cycles and overlap with other transactions.
    transaction_t transaction;
    bit                     aw_seen;
    bit                     w_started;
    bit                     w_seen;
    bit                     b_seen;
    bit [DATA_WIDTH-1:0] wdata_q[$];
    bit [STRB_WIDTH-1:0] wstrb_q[$];
    bit [USER_WIDTH-1:0] wuser_q[$];
    time                    w_handshake_time_q[$];
    int unsigned            wlast_beat_count;
    bit                     wlast_before_aw;
    bit                     wlast_position_checked;
    longint unsigned        awvalid_start_cycle;
    bit                     awvalid_start_cycle_valid;
    longint unsigned        wlast_handshake_cycle;
    bit                     wlast_handshake_cycle_valid;

    function new(string name = "transaction");
        transaction = transaction_t::type_id::create(name);
        aw_seen = 1'b0;
        w_started = 1'b0;
        w_seen = 1'b0;
        b_seen = 1'b0;
        wlast_beat_count = 0;
        wlast_before_aw = 1'b0;
        wlast_position_checked = 1'b0;
        wdata_q.delete();
        wstrb_q.delete();
        wuser_q.delete();
        w_handshake_time_q.delete();
        awvalid_start_cycle = 0;
        awvalid_start_cycle_valid = 1'b0;
        wlast_handshake_cycle = 0;
        wlast_handshake_cycle_valid = 1'b0;
    endfunction : new
endclass : axi_write_monitor_context

class axi_write_monitor #(
    int unsigned ID_WIDTH,
    int unsigned ADDR_WIDTH,
    int unsigned DATA_WIDTH,
    int unsigned USER_WIDTH
) extends uvm_monitor;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int AXI_BUS_SIZE = $clog2(STRB_WIDTH);
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;
    typedef axi_write_monitor #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_write_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_write_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_cfg_t;
    typedef axi_write_transaction #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) transaction_t;
    typedef axi_write_address_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) address_event_t;
    typedef axi_write_data_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) data_event_t;
    typedef axi_write_response_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) response_event_t;
    typedef axi_write_monitor_context #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) context_t;

    vif_t         vif;
    monitor_cfg_t cfg;

    // Scenario 3: publish a complete write transaction after AW, all W beats,
    // and B response are accepted.
    uvm_analysis_port #(transaction_t) analysis_port;

    // Scenario 1: publish channel-level packets when channel payload first
    // appears on the interface with VALID high. AW/W are master-driven, while
    // B is a slaver/DUT response observed by the master VIP.
    uvm_analysis_port #(address_event_t)  aw_ap;
    uvm_analysis_port #(data_event_t)     w_ap;
    uvm_analysis_port #(response_event_t) b_ap;

    // Hold not-yet-complete transactions for outstanding reconstruction.
    protected context_t context_q[$];

    // AXI4 W channel has no WID, so one W burst is tracked until WLAST.
    protected context_t active_w_ctx;

    // Track whether the current channel payload has already been published on
    // the VALID-based channel ports. This avoids duplicate packets while READY
    // is low, and still supports back-to-back payloads when VALID stays high.
    protected bit aw_valid_active;
    protected bit w_valid_active;
    protected bit b_valid_active;
    protected int unsigned w_valid_beat_index;
    protected longint unsigned cycle_count;
    protected longint unsigned current_awvalid_start_cycle;
    protected bit current_awvalid_start_cycle_valid;
    protected longint unsigned bandwidth_sampled_cycles;
    protected longint unsigned bandwidth_handshake_cycles;
    protected longint unsigned bandwidth_valid_bytes;
    protected bit bandwidth_payload_measurement_valid;

    // Payload snapshots used to check that VALID-side payload stays stable
    // until handshake. logic keeps X/Z visible in !== comparisons.
    protected logic [ID_WIDTH-1:0]     awid_hold;
    protected logic [ADDR_WIDTH-1:0]   awaddr_hold;
    protected logic [7:0]                        awlen_hold;
    protected logic [2:0]                        awsize_hold;
    protected logic [1:0]                        awburst_hold;
    protected logic                              awlock_hold;
    protected logic [3:0]                        awcache_hold;
    protected logic [2:0]                        awprot_hold;
    protected logic [3:0]                        awqos_hold;
    protected logic [3:0]                        awregion_hold;
    protected logic [USER_WIDTH-1:0]   awuser_hold;
    protected logic [DATA_WIDTH-1:0]   wdata_hold;
    protected logic [STRB_WIDTH-1:0]   wstrb_hold;
    protected logic                              wlast_hold;
    protected logic [USER_WIDTH-1:0]   wuser_hold;
    protected logic [ID_WIDTH-1:0]     bid_hold;
    protected logic [1:0]                        bresp_hold;
    protected logic [USER_WIDTH-1:0]   buser_hold;

    protected bit aw_payload_stable_reported;
    protected bit w_payload_stable_reported;
    protected bit b_payload_stable_reported;
    protected bit bvalid_aw_w_order_reported;
    protected bit control_unknown_reported;
    protected bit aw_payload_unknown_reported;
    protected bit w_payload_unknown_reported;
    protected bit b_payload_unknown_reported;

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
        analysis_port    = new("analysis_port", this);
        aw_ap = new("aw_ap", this);
        w_ap  = new("w_ap", this);
        b_ap  = new("b_ap", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (cfg == null) begin
            `uvm_fatal("NOCFG",
                {"cfg must be assigned directly before build for: ",
                 get_full_name()})
        end
        vif = cfg.vif;
        if (vif == null) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set in: ", get_full_name(), ".cfg.vif"})
        end
        vif.coverage_enable = cfg.coverage_enable;
    endfunction: build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();
    extern virtual protected task sample_one_cycle();
    extern virtual protected task check_unknown_signals();
    extern virtual protected task publish_aw_valid_phase();
    extern virtual protected task publish_w_valid_phase();
    extern virtual protected task publish_b_valid_phase();
    extern virtual protected task capture_aw_payload();
    extern virtual protected task capture_w_payload();
    extern virtual protected task capture_b_payload();
    extern virtual protected task check_aw_payload_stable();
    extern virtual protected task check_w_payload_stable();
    extern virtual protected task check_b_payload_stable();
    extern virtual protected task check_bvalid_after_aw_w();
    extern virtual protected task print_write_performance(
        transaction_t transaction);
    extern virtual protected function void reset_write_bandwidth_window();
    extern virtual protected function void sample_write_bandwidth(bit w_hs);
    extern virtual protected function void print_write_bandwidth(bit partial_window);
    extern virtual protected task check_aw_request_legal(
        context_t ctx);
    extern virtual protected task check_collected_wstrb_legal(
        context_t ctx);
    extern virtual protected task check_wstrb_legal(
        context_t ctx,
        int unsigned beat_idx,
        bit [STRB_WIDTH-1:0] wstrb);
    extern virtual protected task check_wlast_position(
        context_t ctx);
    extern virtual protected task sample_aw_phase();
    extern virtual protected task sample_w_phase();
    extern virtual protected task sample_b_phase();
    extern virtual protected task publish_complete_transactions();
    virtual protected function context_t get_aw_context();
        context_t ctx;

        // AW belongs to the oldest context that has not collected AW yet.
        for (int i = 0; i < context_q.size(); i++) begin
            if (!context_q[i].aw_seen) begin
                return context_q[i];
            end
        end

        ctx = new("transaction");
        context_q.push_back(ctx);
        return ctx;
    endfunction : get_aw_context

    virtual protected function context_t get_w_context();
        context_t ctx;

        // Continue collecting the current W burst until WLAST is seen.
        if (active_w_ctx != null) begin
            return active_w_ctx;
        end

        // A new W burst belongs to the oldest context that has not collected W yet.
        for (int i = 0; i < context_q.size(); i++) begin
            if (!context_q[i].w_seen) begin
                active_w_ctx = context_q[i];
                return active_w_ctx;
            end
        end

        ctx = new("transaction");
        context_q.push_back(ctx);
        active_w_ctx = ctx;
        return active_w_ctx;
    endfunction : get_w_context
    extern virtual protected function int find_oldest_same_id_context_index(bit [ID_WIDTH-1:0] bid);
    extern virtual protected function int find_b_context_index(bit [ID_WIDTH-1:0] bid);
    extern virtual protected function int unsigned get_outstanding_depth();
endclass : axi_write_monitor

task axi_write_monitor::reset_phase(uvm_phase phase);
    monitor_reset();
endtask : reset_phase

task axi_write_monitor::main_phase(uvm_phase phase);
    collect_transactions();
endtask : main_phase

function void axi_write_monitor::report_phase(uvm_phase phase);
    super.report_phase(phase);
    if (cfg != null && cfg.bandwidth_enable &&
        bandwidth_sampled_cycles > 0) begin
        print_write_bandwidth(1'b1);
        reset_write_bandwidth_window();
    end
endfunction : report_phase

task axi_write_monitor::monitor_reset();
    context_q.delete();
    active_w_ctx = null;
    aw_valid_active = 1'b0;
    w_valid_active = 1'b0;
    b_valid_active = 1'b0;
    w_valid_beat_index = 0;
    cycle_count = 0;
    current_awvalid_start_cycle = 0;
    current_awvalid_start_cycle_valid = 1'b0;
    reset_write_bandwidth_window();
    awid_hold = '0;
    awaddr_hold = '0;
    awlen_hold = '0;
    awsize_hold = '0;
    awburst_hold = '0;
    awlock_hold = 1'b0;
    awcache_hold = '0;
    awprot_hold = '0;
    awqos_hold = '0;
    awregion_hold = '0;
    awuser_hold = '0;
    wdata_hold = '0;
    wstrb_hold = '0;
    wlast_hold = 1'b0;
    wuser_hold = '0;
    bid_hold = '0;
    bresp_hold = '0;
    buser_hold = '0;
    aw_payload_stable_reported = 1'b0;
    w_payload_stable_reported = 1'b0;
    b_payload_stable_reported = 1'b0;
    bvalid_aw_w_order_reported = 1'b0;
    control_unknown_reported = 1'b0;
    aw_payload_unknown_reported = 1'b0;
    w_payload_unknown_reported = 1'b0;
    b_payload_unknown_reported = 1'b0;
endtask : monitor_reset

task axi_write_monitor::collect_transactions();
    forever begin
        @(vif.mon_cb);
        if(!vif.mon_cb.reset) begin
            monitor_reset();
        end
        else begin
            sample_one_cycle();
        end
    end
endtask : collect_transactions

task axi_write_monitor::sample_one_cycle();
    bit aw_valid_issue;
    bit w_valid_issue;
    bit b_valid_issue;
    bit aw_hs;
    bit w_hs;
    bit b_hs;

    if (cfg.performance_enable) begin
        cycle_count++;
    end
    check_unknown_signals();

    aw_hs = vif.mon_cb.awvalid && vif.mon_cb.awready;
    w_hs  = vif.mon_cb.wvalid  && vif.mon_cb.wready;
    b_hs  = vif.mon_cb.bvalid  && vif.mon_cb.bready;
    sample_write_bandwidth(w_hs);

    // Scenario 1 samples the first cycle of each payload while VALID is high.
    // It is earlier than handshake and is used by timing-accurate platforms.
    aw_valid_issue = vif.mon_cb.awvalid && !aw_valid_active;
    w_valid_issue  = vif.mon_cb.wvalid  && !w_valid_active;
    b_valid_issue  = vif.mon_cb.bvalid  && !b_valid_active;

    if (aw_valid_issue) begin
        if (cfg.performance_enable) begin
            current_awvalid_start_cycle = cycle_count;
            current_awvalid_start_cycle_valid = 1'b1;
        end
        capture_aw_payload();
        publish_aw_valid_phase();
        aw_valid_active = 1'b1;
        aw_payload_stable_reported = 1'b0;
    end
    else if (aw_valid_active) begin
        check_aw_payload_stable();
    end

    if (w_valid_issue) begin
        capture_w_payload();
        publish_w_valid_phase();
        w_valid_active = 1'b1;
        w_payload_stable_reported = 1'b0;
    end
    else if (w_valid_active) begin
        check_w_payload_stable();
    end

    if (b_valid_issue) begin
        capture_b_payload();
        publish_b_valid_phase();
        b_valid_active = 1'b1;
        b_payload_stable_reported = 1'b0;
        bvalid_aw_w_order_reported = 1'b0;
    end
    else if (b_valid_active) begin
        check_b_payload_stable();
    end

    // Scenario 3 still reconstructs the complete transaction from accepted
    // transfers, so the full packet is not published before the protocol
    // transaction has really completed.
    if (b_valid_issue) begin
        check_bvalid_after_aw_w();
    end

    if (aw_hs) begin
        sample_aw_phase();
    end

    if (w_hs) begin
        sample_w_phase();
    end

    if (b_hs) begin
        sample_b_phase();
    end

    if (!vif.mon_cb.awvalid || aw_hs) begin
        aw_valid_active = 1'b0;
        aw_payload_stable_reported = 1'b0;
        if (aw_hs || !vif.mon_cb.awvalid) begin
            current_awvalid_start_cycle_valid = 1'b0;
        end
    end

    if (!vif.mon_cb.wvalid || w_hs) begin
        w_valid_active = 1'b0;
        w_payload_stable_reported = 1'b0;
    end

    if (!vif.mon_cb.bvalid || b_hs) begin
        b_valid_active = 1'b0;
        b_payload_stable_reported = 1'b0;
        bvalid_aw_w_order_reported = 1'b0;
    end

    publish_complete_transactions();
endtask : sample_one_cycle

function void axi_write_monitor::reset_write_bandwidth_window();
    bandwidth_sampled_cycles = 0;
    bandwidth_handshake_cycles = 0;
    bandwidth_valid_bytes = 0;
    bandwidth_payload_measurement_valid = 1'b1;
endfunction : reset_write_bandwidth_window

function void axi_write_monitor::sample_write_bandwidth(bit w_hs);
    if (!cfg.bandwidth_enable) begin
        return;
    end

    // Include this edge's W transfer before deciding whether the configured
    // ACLK window is complete.
    bandwidth_sampled_cycles++;
    if (w_hs) begin
        bandwidth_handshake_cycles++;
        if ($isunknown(vif.mon_cb.wstrb)) begin
            // The channel handshake is still observable, but X/Z lanes do not
            // define a trustworthy payload-byte count.
            bandwidth_payload_measurement_valid = 1'b0;
        end
        else begin
            // A legal zero WSTRB still consumes one W channel handshake cycle
            // but intentionally contributes zero payload bytes.
            bandwidth_valid_bytes += $countones(vif.mon_cb.wstrb);
        end
    end

    if (bandwidth_sampled_cycles >= cfg.bandwidth_window_cycles) begin
        print_write_bandwidth(1'b0);
        reset_write_bandwidth_window();
    end
endfunction : sample_write_bandwidth

function void axi_write_monitor::print_write_bandwidth(bit partial_window);
    real channel_utilization_percent;
    real payload_utilization_percent;
    real effective_bytes_per_cycle;

    if (!cfg.bandwidth_enable || bandwidth_sampled_cycles == 0) begin
        return;
    end

    channel_utilization_percent =
        100.0 * bandwidth_handshake_cycles / bandwidth_sampled_cycles;
    if (bandwidth_payload_measurement_valid) begin
        payload_utilization_percent =
            100.0 * bandwidth_valid_bytes /
            bandwidth_sampled_cycles / STRB_WIDTH;
        effective_bytes_per_cycle =
            1.0 * bandwidth_valid_bytes / bandwidth_sampled_cycles;
        `uvm_info("AXI_WRITE_BANDWIDTH",
            $sformatf({"--------------write bandwidth------------\n",
                       "link=%s\n",
                       "window_cycles=%0d configured_window_cycles=%0d partial_window=%0b\n",
                       "handshake_cycles=%0d channel_utilization_percent=%0.3f\n",
                       "payload_measurement_valid=1 valid_bytes=%0d data_bytes_per_cycle=%0d\n",
                       "payload_utilization_percent=%0.3f effective_bytes_per_cycle=%0.6f\n",
                       "-----------------------------------------"},
                get_full_name(), bandwidth_sampled_cycles,
                cfg.bandwidth_window_cycles, partial_window,
                bandwidth_handshake_cycles, channel_utilization_percent,
                bandwidth_valid_bytes, STRB_WIDTH,
                payload_utilization_percent, effective_bytes_per_cycle),
            UVM_LOW)
    end
    else begin
        `uvm_info("AXI_WRITE_BANDWIDTH",
            $sformatf({"--------------write bandwidth------------\n",
                       "link=%s\n",
                       "window_cycles=%0d configured_window_cycles=%0d partial_window=%0b\n",
                       "handshake_cycles=%0d channel_utilization_percent=%0.3f\n",
                       "payload_measurement_valid=0 valid_bytes=%0d data_bytes_per_cycle=%0d\n",
                       "payload_utilization_percent=UNAVAILABLE effective_bytes_per_cycle=UNAVAILABLE\n",
                       "-----------------------------------------"},
                get_full_name(), bandwidth_sampled_cycles,
                cfg.bandwidth_window_cycles, partial_window,
                bandwidth_handshake_cycles, channel_utilization_percent,
                bandwidth_valid_bytes, STRB_WIDTH),
            UVM_LOW)
    end
endfunction : print_write_bandwidth

task axi_write_monitor::check_unknown_signals();
    if (!cfg.checks_enable) begin
        return;
    end

    if ($isunknown({vif.mon_cb.awvalid,
                    vif.mon_cb.awready,
                    vif.mon_cb.wvalid,
                    vif.mon_cb.wready,
                    vif.mon_cb.bvalid,
                    vif.mon_cb.bready})) begin
        if (!control_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "HANDSHAKE_CONTROL_XZ", "AXI_WRITE_MONITOR", "AW/W/B", "SAMPLE",
                $sformatf({"AWVALID=%b AWREADY=%b WVALID=%b WREADY=%b ",
                           "BVALID=%b BREADY=%b time=%0t"},
                    vif.mon_cb.awvalid, vif.mon_cb.awready,
                    vif.mon_cb.wvalid, vif.mon_cb.wready,
                    vif.mon_cb.bvalid, vif.mon_cb.bready, $time),
                "AWVALID/AWREADY/WVALID/WREADY/BVALID/BREADY each resolve to 0 or 1",
                "REPORT_ONLY", "X/Z detected on a write-channel handshake control"))
            control_unknown_reported = 1'b1;
        end
    end
    else begin
        control_unknown_reported = 1'b0;
    end

    if (vif.mon_cb.awvalid === 1'b1 &&
        $isunknown({vif.mon_cb.awid,
                    vif.mon_cb.awaddr,
                    vif.mon_cb.awlen,
                    vif.mon_cb.awsize,
                    vif.mon_cb.awburst,
                    vif.mon_cb.awlock,
                    vif.mon_cb.awcache,
                    vif.mon_cb.awprot,
                    vif.mon_cb.awqos,
                    vif.mon_cb.awregion,
                    vif.mon_cb.awuser})) begin
        if (!aw_payload_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "AW_PAYLOAD_XZ", "AXI_WRITE_MONITOR", "AW", "VALID_HIGH_CHECK",
                $sformatf({"AWVALID=%b AWREADY=%b AWID=0x%0h AWADDR=0x%0h ",
                           "AWLEN=0x%0h AWSIZE=0x%0h AWBURST=0x%0h AWLOCK=%b ",
                           "AWCACHE=0x%0h AWPROT=0x%0h AWQOS=0x%0h ",
                           "AWREGION=0x%0h AWUSER=0x%0h time=%0t"},
                    vif.mon_cb.awvalid, vif.mon_cb.awready, vif.mon_cb.awid,
                    vif.mon_cb.awaddr, vif.mon_cb.awlen, vif.mon_cb.awsize,
                    vif.mon_cb.awburst, vif.mon_cb.awlock, vif.mon_cb.awcache,
                    vif.mon_cb.awprot, vif.mon_cb.awqos, vif.mon_cb.awregion,
                    vif.mon_cb.awuser, $time),
                "all AW payload fields resolve to known values while AWVALID=1",
                "REPORT_ONLY", "X/Z detected in the asserted AW payload"))
            aw_payload_unknown_reported = 1'b1;
        end
    end
    else begin
        aw_payload_unknown_reported = 1'b0;
    end

    if (vif.mon_cb.wvalid === 1'b1 &&
        $isunknown({vif.mon_cb.wdata,
                    vif.mon_cb.wstrb,
                    vif.mon_cb.wlast,
                    vif.mon_cb.wuser})) begin
        if (!w_payload_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "W_PAYLOAD_XZ", "AXI_WRITE_MONITOR", "W", "VALID_HIGH_CHECK",
                $sformatf("WVALID=%b WREADY=%b WDATA=0x%0h WSTRB=0x%0h WLAST=%b WUSER=0x%0h time=%0t",
                    vif.mon_cb.wvalid, vif.mon_cb.wready, vif.mon_cb.wdata,
                    vif.mon_cb.wstrb, vif.mon_cb.wlast, vif.mon_cb.wuser,
                    $time),
                "WDATA/WSTRB/WLAST/WUSER resolve to known values while WVALID=1",
                "REPORT_ONLY", "X/Z detected in the asserted W payload"))
            w_payload_unknown_reported = 1'b1;
        end
    end
    else begin
        w_payload_unknown_reported = 1'b0;
    end

    if (vif.mon_cb.bvalid === 1'b1 &&
        $isunknown({vif.mon_cb.bid,
                    vif.mon_cb.bresp,
                    vif.mon_cb.buser})) begin
        if (!b_payload_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "B_PAYLOAD_XZ", "AXI_WRITE_MONITOR", "B", "VALID_HIGH_CHECK",
                $sformatf("BVALID=%b BREADY=%b BID=0x%0h BRESP=0x%0h BUSER=0x%0h time=%0t",
                    vif.mon_cb.bvalid, vif.mon_cb.bready,
                    vif.mon_cb.bid, vif.mon_cb.bresp, vif.mon_cb.buser,
                    $time),
                "BID/BRESP/BUSER resolve to known values while BVALID=1",
                "REPORT_ONLY", "X/Z detected in the asserted B payload"))
            b_payload_unknown_reported = 1'b1;
        end
    end
    else begin
        b_payload_unknown_reported = 1'b0;
    end
endtask : check_unknown_signals

task axi_write_monitor::capture_aw_payload();
    awid_hold     = vif.mon_cb.awid;
    awaddr_hold   = vif.mon_cb.awaddr;
    awlen_hold    = vif.mon_cb.awlen;
    awsize_hold   = vif.mon_cb.awsize;
    awburst_hold  = vif.mon_cb.awburst;
    awlock_hold   = vif.mon_cb.awlock;
    awcache_hold  = vif.mon_cb.awcache;
    awprot_hold   = vif.mon_cb.awprot;
    awqos_hold    = vif.mon_cb.awqos;
    awregion_hold = vif.mon_cb.awregion;
    awuser_hold   = vif.mon_cb.awuser;
endtask : capture_aw_payload

task axi_write_monitor::capture_w_payload();
    wdata_hold = vif.mon_cb.wdata;
    wstrb_hold = vif.mon_cb.wstrb;
    wlast_hold = vif.mon_cb.wlast;
    wuser_hold = vif.mon_cb.wuser;
endtask : capture_w_payload

task axi_write_monitor::capture_b_payload();
    bid_hold   = vif.mon_cb.bid;
    bresp_hold = vif.mon_cb.bresp;
    buser_hold = vif.mon_cb.buser;
endtask : capture_b_payload

task axi_write_monitor::check_aw_payload_stable();
    if (!cfg.checks_enable) begin
        return;
    end

    if (!vif.mon_cb.awvalid) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "AWVALID_DROPPED_BEFORE_HANDSHAKE", "AXI_WRITE_MONITOR", "AW",
            "WAIT_HANDSHAKE",
            $sformatf({"held_AWVALID=1 current_AWVALID=%b current_AWREADY=%b ",
                       "held_AWID=0x%0h held_AWADDR=0x%0h held_AWLEN=%0d ",
                       "held_AWSIZE=%0d held_AWBURST=0x%0h time=%0t"},
                vif.mon_cb.awvalid, vif.mon_cb.awready, awid_hold, awaddr_hold,
                awlen_hold, awsize_hold, awburst_hold, $time),
            "AWVALID remains 1 with the held payload until AWREADY=1",
            "REPORT_ONLY", "The source withdrew AWVALID before an AW handshake"))
        return;
    end

    if (!aw_payload_stable_reported &&
        (vif.mon_cb.awid     !== awid_hold     ||
         vif.mon_cb.awaddr   !== awaddr_hold   ||
         vif.mon_cb.awlen    !== awlen_hold    ||
         vif.mon_cb.awsize   !== awsize_hold   ||
         vif.mon_cb.awburst  !== awburst_hold  ||
         vif.mon_cb.awlock   !== awlock_hold   ||
         vif.mon_cb.awcache  !== awcache_hold  ||
         vif.mon_cb.awprot   !== awprot_hold   ||
         vif.mon_cb.awqos    !== awqos_hold    ||
         vif.mon_cb.awregion !== awregion_hold ||
         vif.mon_cb.awuser   !== awuser_hold)) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "AW_PAYLOAD_UNSTABLE", "AXI_WRITE_MONITOR", "AW",
            "WAIT_HANDSHAKE",
            $sformatf({"AWVALID=%b AWREADY=%b current={id=0x%0h addr=0x%0h ",
                       "len=0x%0h size=0x%0h burst=0x%0h lock=%b cache=0x%0h ",
                       "prot=0x%0h qos=0x%0h region=0x%0h user=0x%0h} time=%0t"},
                vif.mon_cb.awvalid, vif.mon_cb.awready, vif.mon_cb.awid,
                vif.mon_cb.awaddr, vif.mon_cb.awlen, vif.mon_cb.awsize,
                vif.mon_cb.awburst, vif.mon_cb.awlock, vif.mon_cb.awcache,
                vif.mon_cb.awprot, vif.mon_cb.awqos, vif.mon_cb.awregion,
                vif.mon_cb.awuser, $time),
            $sformatf({"held={id=0x%0h addr=0x%0h len=0x%0h size=0x%0h ",
                       "burst=0x%0h lock=%b cache=0x%0h prot=0x%0h qos=0x%0h ",
                       "region=0x%0h user=0x%0h} until AWREADY=1"},
                awid_hold, awaddr_hold, awlen_hold, awsize_hold, awburst_hold,
                awlock_hold, awcache_hold, awprot_hold, awqos_hold,
                awregion_hold, awuser_hold),
            "REPORT_ONLY", "One or more compared AW payload fields changed"))
        aw_payload_stable_reported = 1'b1;
    end
endtask : check_aw_payload_stable

task axi_write_monitor::check_w_payload_stable();
    if (!cfg.checks_enable) begin
        return;
    end

    if (!vif.mon_cb.wvalid) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "WVALID_DROPPED_BEFORE_HANDSHAKE", "AXI_WRITE_MONITOR", "W",
            "WAIT_HANDSHAKE",
            $sformatf({"held_WVALID=1 current_WVALID=%b current_WREADY=%b ",
                       "held_WDATA=0x%0h held_WSTRB=0x%0h held_WLAST=%b ",
                       "held_WUSER=0x%0h ",
                       "visible_beat_index=%0d time=%0t"},
                vif.mon_cb.wvalid, vif.mon_cb.wready, wdata_hold, wstrb_hold,
                wlast_hold, wuser_hold, w_valid_beat_index, $time),
            "WVALID remains 1 with the held payload until WREADY=1",
            "REPORT_ONLY", "The source withdrew WVALID before a W handshake"))
        return;
    end

    if (!w_payload_stable_reported &&
        (vif.mon_cb.wdata !== wdata_hold ||
         vif.mon_cb.wstrb !== wstrb_hold ||
         vif.mon_cb.wlast !== wlast_hold ||
         vif.mon_cb.wuser !== wuser_hold)) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "W_PAYLOAD_UNSTABLE", "AXI_WRITE_MONITOR", "W",
            "WAIT_HANDSHAKE",
            $sformatf({"WVALID=%b WREADY=%b current={data=0x%0h strb=0x%0h ",
                       "last=%b user=0x%0h} visible_beat_index=%0d time=%0t"},
                vif.mon_cb.wvalid, vif.mon_cb.wready, vif.mon_cb.wdata,
                vif.mon_cb.wstrb, vif.mon_cb.wlast, vif.mon_cb.wuser,
                w_valid_beat_index, $time),
            $sformatf("held={data=0x%0h strb=0x%0h last=%b user=0x%0h} until WREADY=1",
                wdata_hold, wstrb_hold, wlast_hold, wuser_hold),
            "REPORT_ONLY", "One or more compared W payload fields changed"))
        w_payload_stable_reported = 1'b1;
    end
endtask : check_w_payload_stable

task axi_write_monitor::check_b_payload_stable();
    if (!cfg.checks_enable) begin
        return;
    end

    if (!vif.mon_cb.bvalid) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "BVALID_DROPPED_BEFORE_HANDSHAKE", "AXI_WRITE_MONITOR", "B",
            "WAIT_HANDSHAKE",
            $sformatf({"held_BVALID=1 current_BVALID=%b current_BREADY=%b ",
                       "held_BID=0x%0h held_BRESP=0x%0h held_BUSER=0x%0h time=%0t"},
                vif.mon_cb.bvalid, vif.mon_cb.bready,
                bid_hold, bresp_hold, buser_hold, $time),
            "BVALID remains 1 with the held payload until BREADY=1",
            "REPORT_ONLY", "The response source withdrew BVALID before a B handshake"))
        return;
    end

    if (!b_payload_stable_reported &&
        (vif.mon_cb.bid   !== bid_hold ||
         vif.mon_cb.bresp !== bresp_hold ||
         vif.mon_cb.buser !== buser_hold)) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "B_PAYLOAD_UNSTABLE", "AXI_WRITE_MONITOR", "B",
            "WAIT_HANDSHAKE",
            $sformatf("BVALID=%b BREADY=%b current={bid=0x%0h bresp=0x%0h buser=0x%0h} time=%0t",
                vif.mon_cb.bvalid, vif.mon_cb.bready,
                vif.mon_cb.bid, vif.mon_cb.bresp, vif.mon_cb.buser, $time),
            $sformatf("held={bid=0x%0h bresp=0x%0h buser=0x%0h} until BREADY=1",
                bid_hold, bresp_hold, buser_hold),
            "REPORT_ONLY", "One or more compared B payload fields changed"))
        b_payload_stable_reported = 1'b1;
    end
endtask : check_b_payload_stable

task axi_write_monitor::check_bvalid_after_aw_w();
    int same_id_idx;
    bit [ID_WIDTH-1:0] bid;

    if (!cfg.checks_enable) begin
        return;
    end

    if ($isunknown(vif.mon_cb.bid)) begin
        return;
    end

    bid = vif.mon_cb.bid;
    same_id_idx = find_oldest_same_id_context_index(bid);
    if (same_id_idx < 0) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "BVALID_WITHOUT_ACCEPTED_AW", "AXI_WRITE_MONITOR", "B",
            "VALID_ASSERT",
            $sformatf("BID=0x%0h BVALID=%b BREADY=%b tracked_contexts=%0d time=%0t",
                bid, vif.mon_cb.bvalid, vif.mon_cb.bready,
                context_q.size(), $time),
            "an accepted, oldest same-ID AW context exists before BVALID",
            "REPORT_ONLY", "No accepted AWID matches the asserted BID"))
        bvalid_aw_w_order_reported = 1'b1;
    end
    else if (!context_q[same_id_idx].w_seen) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "BVALID_BEFORE_WLAST", "AXI_WRITE_MONITOR", "B",
            "VALID_ASSERT",
            $sformatf({"BID=0x%0h BVALID=%b BREADY=%b context_index=%0d ",
                       "AWID=0x%0h AW_seen=%0b W_started=%0b W_seen=%0b ",
                       "collected_W_beats=%0d time=%0t"},
                bid, vif.mon_cb.bvalid, vif.mon_cb.bready, same_id_idx,
                context_q[same_id_idx].transaction.awid,
                context_q[same_id_idx].aw_seen,
                context_q[same_id_idx].w_started,
                context_q[same_id_idx].w_seen,
                context_q[same_id_idx].wdata_q.size(), $time),
            "the oldest same-ID transaction accepts WLAST before BVALID",
            "REPORT_ONLY", "BVALID became visible before the matching W burst completed"))
        bvalid_aw_w_order_reported = 1'b1;
    end
endtask : check_bvalid_after_aw_w

task axi_write_monitor::print_write_performance(
    transaction_t transaction);
    if (!cfg.performance_enable || transaction == null ||
        !transaction.performance_valid) begin
        return;
    end

    `uvm_info("AXI_WRITE_PERFORMANCE",
        $sformatf({"--------------write performance------------\n",
                   "link=%s id=0x%0h\n",
                   "write_response_latency_cycles=%0d\n",
                   "wlast_to_b_latency_cycles=%0d\n",
                   "aw_handshake_latency_cycles=%0d\n",
                   "-------------------------------------------"},
            get_full_name(), transaction.bid,
            transaction.write_response_latency_cycles,
            transaction.wlast_to_b_latency_cycles,
            transaction.aw_handshake_latency_cycles),
        UVM_LOW)
endtask : print_write_performance

task axi_write_monitor::check_aw_request_legal(context_t ctx);
    axi_request_rule_e rule;
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;
    string report_id;
    string reason;
    string expected;
    string detail;
    string range_observed;

    if (!cfg.checks_enable ||
        ctx == null || !ctx.aw_seen) begin
        return;
    end

    if (!$isunknown(vif.mon_cb.awcache) &&
        !axi_cache_is_legal(vif.mon_cb.awcache)) begin
        `uvm_error("AXI_WRITE_REQUEST", axi_diag::format(
            "AW_CACHE_RESERVED", "AXI_WRITE_MONITOR", "AW",
            "HANDSHAKE_CHECK",
            $sformatf("AWCACHE=0x%0h AWID=0x%0h AWADDR=0x%0h time=%0t",
                vif.mon_cb.awcache, ctx.transaction.awid,
                ctx.transaction.awaddr, $time),
            AXI_CACHE_LEGAL_EXPECTED, "REPORT_ONLY",
            "Accepted AW request uses an AXI4 reserved AWCACHE encoding"))
    end

    // One common helper owns rule priority and all request geometry math.
    // A Monitor always enforces the AXI 4KB rule, independently of the
    // stimulus-side negative-test protection switch.
    rule = burst_math_t::get_request_geometry_rule(
        ctx.transaction.awaddr,
        ctx.transaction.awlen,
        ctx.transaction.awsize,
        ctx.transaction.awburst,
        AXI4_MAX_BURST_BEATS,
        ctx.transaction.awlock,
        1'b1,
        low_addr,
        high_addr);
    if (rule == AXI_REQUEST_RULE_OK) begin
        return;
    end
    if (rule inside {
            AXI_REQUEST_RULE_CROSSES_4KB,
            AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT}) begin
        range_observed = $sformatf(
            "range_valid=1 low_addr=0x%0h high_addr=0x%0h",
            low_addr, high_addr);
    end
    else begin
        range_observed = "range_valid=0 range=UNAVAILABLE";
    end

    case (rule)
        AXI_REQUEST_RULE_UNSUPPORTED_BURST: begin
            report_id = "AXI_WRITE_REQUEST";
            reason = "AW_BURST_UNSUPPORTED";
            expected = "AWBURST is FIXED(0), INCR(1), or WRAP(2)";
            detail = "Accepted AW request uses a reserved burst encoding";
        end
        AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS: begin
            report_id = ctx.transaction.awlock ?
                "AXI_EXCLUSIVE_GEOMETRY" : "AXI_WRITE_REQUEST";
            reason = "AW_SIZE_EXCEEDS_BUS";
            expected = $sformatf("AWSIZE inside [0:%0d]", AXI_BUS_SIZE);
            detail = "Accepted write beat size exceeds the data bus width";
        end
        AXI_REQUEST_RULE_FIXED_TOO_LONG: begin
            report_id = "AXI_WRITE_REQUEST";
            reason = "AW_FIXED_BEATS_EXCEED_16";
            expected = "FIXED burst AWLEN+1 <= 16";
            detail = "Accepted FIXED write burst is too long";
        end
        AXI_REQUEST_RULE_WRAP_LENGTH: begin
            report_id = "AXI_WRITE_REQUEST";
            reason = "AW_WRAP_BEATS_INVALID";
            expected = "WRAP burst AWLEN+1 is one of 2,4,8,16";
            detail = "Accepted WRAP write has an illegal beat count";
        end
        AXI_REQUEST_RULE_WRAP_ALIGNMENT: begin
            report_id = "AXI_WRITE_REQUEST";
            reason = "AW_WRAP_ADDR_UNALIGNED";
            expected = "WRAP start AWADDR is aligned to 1<<AWSIZE bytes";
            detail = "Accepted WRAP write start address is not beat aligned";
        end
        AXI_REQUEST_RULE_ADDRESS_OVERFLOW: begin
            report_id = "AXI_AW_ADDRESS_OVERFLOW";
            reason = "AW_ADDRESS_OVERFLOW";
            expected = $sformatf("complete write footprint is representable in ADDR_WIDTH=%0d", ADDR_WIDTH);
            detail = "Write footprint arithmetic exceeds the configured address width; this is distinct from a 4KB crossing";
        end
        AXI_REQUEST_RULE_CROSSES_4KB: begin
            report_id = "AXI_AW_CROSSES_4KB";
            reason = "AW_CROSSES_4KB";
            expected = "complete write footprint low_addr and high_addr are in one 4KB region";
            detail = "Accepted write burst crosses a 4KB boundary";
        end
        AXI_REQUEST_RULE_EXCLUSIVE_BEATS: begin
            report_id = "AXI_EXCLUSIVE_GEOMETRY";
            reason = "AW_EXCLUSIVE_BEATS_INVALID";
            expected = "AWLOCK=1 requires AWLEN+1 in {1,2,4,8,16}";
            detail = "Accepted exclusive write uses an illegal beat count";
        end
        AXI_REQUEST_RULE_EXCLUSIVE_BYTES: begin
            report_id = "AXI_EXCLUSIVE_GEOMETRY";
            reason = "AW_EXCLUSIVE_BYTES_EXCEED_128";
            expected = "AWLOCK=1 requires (AWLEN+1)*(1<<AWSIZE) <= 128 bytes";
            detail = "Accepted exclusive write transfer is larger than 128 bytes";
        end
        AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT: begin
            report_id = "AXI_EXCLUSIVE_GEOMETRY";
            reason = "AW_EXCLUSIVE_ADDR_UNALIGNED";
            expected = "AWLOCK=1 requires AWADDR aligned to total transfer bytes";
            detail = "Accepted exclusive write start address is not transfer aligned";
        end
        default: begin
            report_id = "AXI_WRITE_REQUEST";
            reason = "AW_GEOMETRY_RULE_UNHANDLED";
            expected = "get_request_geometry_rule returns a documented AW geometry rule";
            detail = "Common geometry helper returned an unexpected rule";
        end
    endcase

    `uvm_error(report_id, axi_diag::format(
        reason, "AXI_WRITE_MONITOR", "AW", "HANDSHAKE_CHECK",
        $sformatf({"AWID=0x%0h AWADDR=0x%0h AWLEN=%0d beats=%0d ",
                   "AWSIZE=%0d BUS_SIZE=%0d AWBURST=0x%0h AWLOCK=%0b ",
                   "%s rule=%s time=%0t"},
            ctx.transaction.awid, ctx.transaction.awaddr,
            ctx.transaction.awlen, int'(ctx.transaction.awlen) + 1,
            ctx.transaction.awsize, AXI_BUS_SIZE,
            ctx.transaction.awburst, ctx.transaction.awlock,
            range_observed, rule.name(), $time),
        expected, "REPORT_ONLY", detail))
endtask : check_aw_request_legal

task axi_write_monitor::check_collected_wstrb_legal(
    context_t ctx
);
    if (!cfg.checks_enable ||
        ctx == null || !ctx.aw_seen) begin
        return;
    end
    for (int unsigned i = 0; i < ctx.wstrb_q.size(); i++) begin
        check_wstrb_legal(ctx, i, ctx.wstrb_q[i]);
    end
endtask : check_collected_wstrb_legal

task axi_write_monitor::check_wstrb_legal(
    context_t ctx,
    int unsigned beat_idx,
    bit [STRB_WIDTH-1:0] wstrb
);
    bit [STRB_WIDTH-1:0] legal_mask;

    if (!cfg.checks_enable ||
        ctx == null || !ctx.aw_seen ||
        !burst_math_t::is_supported_burst(ctx.transaction.awburst) ||
        ctx.transaction.awsize > AXI_BUS_SIZE) begin
        return;
    end

    legal_mask = ctx.transaction.get_beat_wstrb_mask(beat_idx);
    if (legal_mask == '0) begin
        `uvm_error("AXI_WRITE_WSTRB", axi_diag::format(
            "WSTRB_LEGAL_MASK_ZERO", "AXI_WRITE_MONITOR", "W",
            "HANDSHAKE_CHECK",
            $sformatf({"AWID=0x%0h beat_index=%0d observed_WSTRB=0x%0h ",
                       "legal_mask=0x%0h AWADDR=0x%0h AWLEN=%0d AWSIZE=%0d ",
                       "AWBURST=%s time=%0t"},
                ctx.transaction.awid, beat_idx, wstrb, legal_mask,
                ctx.transaction.awaddr, ctx.transaction.awlen,
                ctx.transaction.awsize, ctx.transaction.awburst.name(), $time),
            "burst geometry produces at least one legal WSTRB lane for the beat",
            "REPORT_ONLY", "Unable to derive a nonzero legal WSTRB mask"))
    end
    else if ((wstrb & ~legal_mask) != '0) begin
        `uvm_error("AXI_WRITE_WSTRB", axi_diag::format(
            "WSTRB_LANE_OUTSIDE_TRANSFER", "AXI_WRITE_MONITOR", "W",
            "HANDSHAKE_CHECK",
            $sformatf({"AWID=0x%0h beat_index=%0d WSTRB=0x%0h ",
                       "legal_mask=0x%0h illegal_lanes=0x%0h AWADDR=0x%0h ",
                       "AWLEN=%0d AWSIZE=%0d AWBURST=%s time=%0t"},
                ctx.transaction.awid, beat_idx, wstrb, legal_mask,
                wstrb & ~legal_mask, ctx.transaction.awaddr,
                ctx.transaction.awlen, ctx.transaction.awsize,
                ctx.transaction.awburst.name(), $time),
            "(WSTRB & ~legal_mask)==0 for the addressed byte lanes",
            "REPORT_ONLY", "WSTRB enables one or more lanes outside the beat transfer"))
    end
endtask : check_wstrb_legal

task axi_write_monitor::publish_aw_valid_phase();
    address_event_t axi_master_write_aw_tr;

    // Channel packet at AWVALID issue time.
    axi_master_write_aw_tr = address_event_t::type_id::create("axi_master_write_aw_tr", this);
    axi_master_write_aw_tr.awid     = vif.mon_cb.awid;
    axi_master_write_aw_tr.awaddr   = vif.mon_cb.awaddr;
    axi_master_write_aw_tr.awlen    = vif.mon_cb.awlen;
    axi_master_write_aw_tr.awsize   = vif.mon_cb.awsize;
    axi_master_write_aw_tr.awburst  = axi_burst_e'(vif.mon_cb.awburst);
    axi_master_write_aw_tr.awlock   = vif.mon_cb.awlock;
    axi_master_write_aw_tr.awcache  = vif.mon_cb.awcache;
    axi_master_write_aw_tr.awprot   = vif.mon_cb.awprot;
    axi_master_write_aw_tr.awqos    = vif.mon_cb.awqos;
    axi_master_write_aw_tr.awregion = vif.mon_cb.awregion;
    axi_master_write_aw_tr.awuser   = vif.mon_cb.awuser;

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=VALID_ASSERT role=BUS_WRITE channel=AW time=%0t id=0x%0h addr=0x%0h len=%0d size=%0d burst=%s",
            $time, axi_master_write_aw_tr.awid, axi_master_write_aw_tr.awaddr,
            axi_master_write_aw_tr.awlen, axi_master_write_aw_tr.awsize,
            axi_master_write_aw_tr.awburst.name()),
        UVM_MEDIUM)
    aw_ap.write(axi_master_write_aw_tr);
endtask : publish_aw_valid_phase

task axi_write_monitor::publish_w_valid_phase();
    data_event_t axi_master_write_w_tr;

    // Channel packet at WVALID issue time. w_valid_beat_index keeps useful
    // beat numbering even when WVALID stays high for back-to-back beats.
    axi_master_write_w_tr = data_event_t::type_id::create("axi_master_write_w_tr", this);
    axi_master_write_w_tr.wdata      = vif.mon_cb.wdata;
    axi_master_write_w_tr.wstrb      = vif.mon_cb.wstrb;
    axi_master_write_w_tr.wlast      = vif.mon_cb.wlast;
    axi_master_write_w_tr.wuser      = vif.mon_cb.wuser;
    axi_master_write_w_tr.beat_index = w_valid_beat_index;

    if (axi_master_write_w_tr.wlast) begin
        w_valid_beat_index = 0;
    end
    else begin
        w_valid_beat_index++;
    end

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=VALID_ASSERT role=BUS_WRITE channel=W time=%0t beat=%0d data=0x%0h strb=0x%0h last=%0b user=0x%0h",
            $time, axi_master_write_w_tr.beat_index, axi_master_write_w_tr.wdata,
            axi_master_write_w_tr.wstrb, axi_master_write_w_tr.wlast,
            axi_master_write_w_tr.wuser),
        UVM_MEDIUM)
    w_ap.write(axi_master_write_w_tr);
endtask : publish_w_valid_phase

task axi_write_monitor::publish_b_valid_phase();
    response_event_t axi_master_write_b_tr;

    // Channel packet when slaver/DUT response first becomes visible with BVALID.
    axi_master_write_b_tr = response_event_t::type_id::create("axi_master_write_b_tr", this);
    axi_master_write_b_tr.bid   = vif.mon_cb.bid;
    axi_master_write_b_tr.bresp = axi_resp_e'(vif.mon_cb.bresp);
    axi_master_write_b_tr.buser = vif.mon_cb.buser;

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=VALID_ASSERT role=BUS_WRITE channel=B time=%0t id=0x%0h resp=%s user=0x%0h",
            $time, axi_master_write_b_tr.bid, axi_master_write_b_tr.bresp.name(),
            axi_master_write_b_tr.buser),
        UVM_MEDIUM)
    b_ap.write(axi_master_write_b_tr);
endtask : publish_b_valid_phase

task axi_write_monitor::check_wlast_position(
    context_t ctx
);
    int unsigned expected_beats;

    if (!cfg.checks_enable ||
        !ctx.aw_seen ||
        !ctx.w_seen ||
        ctx.wlast_position_checked) begin
        return;
    end

    expected_beats = ctx.transaction.awlen + 1;
    ctx.wlast_position_checked = 1'b1;
    if (ctx.wlast_beat_count != expected_beats) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "WLAST_ON_WRONG_BEAT", "AXI_WRITE_MONITOR", "W",
            "HANDSHAKE_CHECK",
            $sformatf({"AWID=0x%0h WLAST=1 observed_WLAST_beat=%0d ",
                       "expected_beat_count=%0d AWLEN=%0d WLAST_before_AW=%0b time=%0t"},
                ctx.transaction.awid, ctx.wlast_beat_count,
                expected_beats, ctx.transaction.awlen,
                ctx.wlast_before_aw, $time),
            "WLAST=1 exactly on accepted W beat number AWLEN+1",
            "REPORT_ONLY", "WLAST terminated the write burst on the wrong beat"))
    end
endtask : check_wlast_position

task axi_write_monitor::sample_aw_phase();
    context_t ctx;
    bit starts_outstanding;

    // Accepted AW fields are used only to reconstruct the complete transaction.
    ctx = get_aw_context();
    starts_outstanding = !ctx.w_started;
    ctx.transaction.awid     = vif.mon_cb.awid;
    ctx.transaction.awaddr   = vif.mon_cb.awaddr;
    ctx.transaction.awlen    = vif.mon_cb.awlen;
    ctx.transaction.awsize   = vif.mon_cb.awsize;
    ctx.transaction.awburst  = axi_burst_e'(vif.mon_cb.awburst);
    ctx.transaction.awlock   = vif.mon_cb.awlock;
    ctx.transaction.awcache  = vif.mon_cb.awcache;
    ctx.transaction.awprot   = vif.mon_cb.awprot;
    ctx.transaction.awqos    = vif.mon_cb.awqos;
    ctx.transaction.awregion = vif.mon_cb.awregion;
    ctx.transaction.awuser   = vif.mon_cb.awuser;
    ctx.transaction.aw_handshake_time = $time;
    if (cfg.performance_enable) begin
        ctx.awvalid_start_cycle = current_awvalid_start_cycle_valid ?
            current_awvalid_start_cycle : cycle_count;
        ctx.awvalid_start_cycle_valid = 1'b1;
        ctx.transaction.aw_handshake_latency_cycles =
            cycle_count - ctx.awvalid_start_cycle;
    end
    ctx.aw_seen = 1'b1;
    check_aw_request_legal(ctx);
    check_collected_wstrb_legal(ctx);
    check_wlast_position(ctx);

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=HANDSHAKE role=BUS_WRITE channel=AW time=%0t id=0x%0h addr=0x%0h len=%0d size=%0d burst=%s",
            $time, ctx.transaction.awid, ctx.transaction.awaddr,
            ctx.transaction.awlen, ctx.transaction.awsize,
            ctx.transaction.awburst.name()),
        UVM_MEDIUM)
    if (starts_outstanding) begin
        vif.sample_outstanding_depth(get_outstanding_depth());
        if (cfg.checks_enable &&
            get_outstanding_depth() > cfg.outstanding_depth) begin
            `uvm_error("AXI_OUTSTANDING", axi_diag::format(
                "WRITE_OUTSTANDING_LIMIT_EXCEEDED", "AXI_WRITE_MONITOR", "AW",
                "HANDSHAKE_CHECK",
                $sformatf("event=AW_HANDSHAKE AWID=0x%0h active_depth=%0d configured_limit=%0d time=%0t",
                    ctx.transaction.awid, get_outstanding_depth(),
                    cfg.outstanding_depth, $time),
                "active write outstanding depth <= configured limit",
                "REPORT_ONLY", "AW handshake started a write context above the configured limit"))
        end
    end
endtask : sample_aw_phase

task axi_write_monitor::sample_w_phase();
    context_t ctx;
    data_event_t axi_master_write_w_tr;
    bit starts_outstanding;

    // Accepted W beats are used only to reconstruct the complete transaction.
    ctx = get_w_context();
    starts_outstanding = !ctx.aw_seen && !ctx.w_started;
    ctx.w_started = 1'b1;
    axi_master_write_w_tr = data_event_t::type_id::create("axi_master_write_w_tr", this);
    axi_master_write_w_tr.wdata      = vif.mon_cb.wdata;
    axi_master_write_w_tr.wstrb      = vif.mon_cb.wstrb;
    axi_master_write_w_tr.wlast      = vif.mon_cb.wlast;
    axi_master_write_w_tr.wuser      = vif.mon_cb.wuser;
    axi_master_write_w_tr.beat_index = ctx.wdata_q.size();

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=HANDSHAKE role=BUS_WRITE channel=W time=%0t beat=%0d data=0x%0h strb=0x%0h last=%0b user=0x%0h",
            $time, axi_master_write_w_tr.beat_index, axi_master_write_w_tr.wdata,
            axi_master_write_w_tr.wstrb, axi_master_write_w_tr.wlast,
            axi_master_write_w_tr.wuser),
        UVM_MEDIUM)
    ctx.wdata_q.push_back(axi_master_write_w_tr.wdata);
    ctx.wstrb_q.push_back(axi_master_write_w_tr.wstrb);
    ctx.wuser_q.push_back(axi_master_write_w_tr.wuser);
    ctx.w_handshake_time_q.push_back($time);
    ctx.transaction.beat_count = ctx.wdata_q.size();
    if (ctx.aw_seen) begin
        check_wstrb_legal(ctx, axi_master_write_w_tr.beat_index,
            axi_master_write_w_tr.wstrb);
    end

    if (starts_outstanding) begin
        vif.sample_outstanding_depth(get_outstanding_depth());
        if (cfg.checks_enable &&
            get_outstanding_depth() > cfg.outstanding_depth) begin
            `uvm_error("AXI_OUTSTANDING", axi_diag::format(
                "WRITE_OUTSTANDING_LIMIT_EXCEEDED", "AXI_WRITE_MONITOR", "W",
                "HANDSHAKE_CHECK",
                $sformatf({"event=LEADING_W_HANDSHAKE beat_index=%0d WLAST=%0b ",
                           "active_depth=%0d configured_limit=%0d AW_seen=%0b time=%0t"},
                    axi_master_write_w_tr.beat_index,
                    axi_master_write_w_tr.wlast,
                    get_outstanding_depth(), cfg.outstanding_depth,
                    ctx.aw_seen, $time),
                "active write outstanding depth <= configured limit",
                "REPORT_ONLY", "Leading W handshake started a write context above the configured limit"))
        end
    end

    if (cfg.checks_enable &&
        ctx.aw_seen &&
        !axi_master_write_w_tr.wlast &&
        ctx.wdata_q.size() >= ctx.transaction.awlen + 1) begin
            `uvm_error("AXI_MON", axi_diag::format(
                "WLAST_MISSING_ON_FINAL_BEAT", "AXI_WRITE_MONITOR", "W",
                "HANDSHAKE_CHECK",
                $sformatf({"AWID=0x%0h WLAST=%0b actual_beat_count=%0d ",
                           "expected_beat_count=%0d AWLEN=%0d time=%0t"},
                    ctx.transaction.awid, axi_master_write_w_tr.wlast,
                    ctx.wdata_q.size(), ctx.transaction.awlen + 1,
                    ctx.transaction.awlen, $time),
                "WLAST=1 on accepted W beat number AWLEN+1",
                "REPORT_ONLY", "Expected final W beat handshook without WLAST"))
    end

    if (axi_master_write_w_tr.wlast) begin
        ctx.wlast_beat_count = ctx.wdata_q.size();
        ctx.wlast_before_aw = !ctx.aw_seen;
        if (cfg.performance_enable) begin
            ctx.wlast_handshake_cycle = cycle_count;
            ctx.wlast_handshake_cycle_valid = 1'b1;
        end
        ctx.w_seen = 1'b1;
        active_w_ctx = null;
        check_wlast_position(ctx);
    end
endtask : sample_w_phase

task axi_write_monitor::sample_b_phase();
    int ctx_idx;
    int same_id_idx;
    context_t ctx;
    response_event_t axi_master_write_b_tr;

    // Accepted B response completes the full transaction context.
    axi_master_write_b_tr = response_event_t::type_id::create("axi_master_write_b_tr", this);
    axi_master_write_b_tr.bid   = vif.mon_cb.bid;
    axi_master_write_b_tr.bresp = axi_resp_e'(vif.mon_cb.bresp);
    axi_master_write_b_tr.buser = vif.mon_cb.buser;

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=HANDSHAKE role=BUS_WRITE channel=B time=%0t id=0x%0h resp=%s user=0x%0h",
            $time, axi_master_write_b_tr.bid, axi_master_write_b_tr.bresp.name(),
            axi_master_write_b_tr.buser),
        UVM_MEDIUM)
    same_id_idx = find_oldest_same_id_context_index(axi_master_write_b_tr.bid);
    if (cfg.checks_enable &&
        same_id_idx >= 0 && !context_q[same_id_idx].w_seen) begin
        if (!bvalid_aw_w_order_reported) begin
            `uvm_error("AXI_MON", axi_diag::format(
                "B_HANDSHAKE_BEFORE_OLDEST_SAME_ID_WLAST", "AXI_WRITE_MONITOR", "B",
                "HANDSHAKE_CHECK",
                $sformatf({"BID=0x%0h BRESP=%s context_index=%0d AWID=0x%0h ",
                           "AW_seen=%0b W_started=%0b W_seen=%0b ",
                           "collected_W_beats=%0d time=%0t"},
                    axi_master_write_b_tr.bid,
                    axi_master_write_b_tr.bresp.name(), same_id_idx,
                    context_q[same_id_idx].transaction.awid,
                    context_q[same_id_idx].aw_seen,
                    context_q[same_id_idx].w_started,
                    context_q[same_id_idx].w_seen,
                    context_q[same_id_idx].wdata_q.size(), $time),
                "the oldest same-ID write accepts WLAST before its B handshake",
                "REPORT_ONLY", "B response arrived early or skipped an older same-ID write"))
        end
        return;
    end

    ctx_idx = find_b_context_index(axi_master_write_b_tr.bid);
    if (ctx_idx < 0) begin
        if (cfg.checks_enable && !bvalid_aw_w_order_reported) begin
            `uvm_error("AXI_MON", axi_diag::format(
                "B_HANDSHAKE_WITHOUT_AW_W_CONTEXT", "AXI_WRITE_MONITOR", "B",
                "HANDSHAKE_CHECK",
                $sformatf("BID=0x%0h BRESP=%s tracked_contexts=%0d time=%0t",
                    axi_master_write_b_tr.bid,
                    axi_master_write_b_tr.bresp.name(),
                    context_q.size(), $time),
                "a collected AW/W-complete context with matching AWID exists before B handshake",
                "REPORT_ONLY", "Accepted B response cannot be assigned to a write request"))
        end
    end
    else begin
        ctx = context_q[ctx_idx];
        ctx.transaction.bid        = axi_master_write_b_tr.bid;
        ctx.transaction.bresp      = axi_master_write_b_tr.bresp;
        ctx.transaction.buser      = axi_master_write_b_tr.buser;
        ctx.transaction.b_handshake_time = $time;
        if (cfg.performance_enable && ctx.awvalid_start_cycle_valid &&
            ctx.wlast_handshake_cycle_valid) begin
            ctx.transaction.write_response_latency_cycles =
                cycle_count - ctx.awvalid_start_cycle;
            ctx.transaction.wlast_to_b_latency_cycles =
                cycle_count - ctx.wlast_handshake_cycle;
            ctx.transaction.performance_valid = 1'b1;
        end
        ctx.transaction.write_done = 1'b1;
        ctx.b_seen = 1'b1;
        if (cfg.checks_enable &&
            axi_master_write_b_tr.bresp == AXI_RESP_EXOKAY &&
            !ctx.transaction.awlock) begin
            `uvm_error("AXI_EXCLUSIVE", axi_diag::format(
                "WRITE_EXOKAY_WITHOUT_AWLOCK", "AXI_WRITE_MONITOR", "B",
                "HANDSHAKE_CHECK",
                $sformatf("BID=0x%0h BRESP=%s AWID=0x%0h AWLOCK=%0b time=%0t",
                    axi_master_write_b_tr.bid,
                    axi_master_write_b_tr.bresp.name(),
                    ctx.transaction.awid, ctx.transaction.awlock, $time),
                "BRESP is not EXOKAY when the matching AWLOCK=0",
                "REPORT_ONLY", "Non-exclusive write returned the exclusive-success response"))
        end
        vif.sample_outstanding_depth(get_outstanding_depth());
    end
endtask : sample_b_phase

function int axi_write_monitor::find_oldest_same_id_context_index(bit [ID_WIDTH-1:0] bid);
    // Same-ID responses must retire in AW acceptance order. Return the oldest
    // outstanding transaction for this BID even if W has not completed yet, so
    // a later same-ID response cannot skip over it.
    for (int i = 0; i < context_q.size(); i++) begin
        if (context_q[i].aw_seen &&
            !context_q[i].b_seen &&
            context_q[i].transaction.awid == bid) begin
            return i;
        end
    end
    return -1;
endfunction : find_oldest_same_id_context_index

function int axi_write_monitor::find_b_context_index(bit [ID_WIDTH-1:0] bid);
    int same_id_idx;

    same_id_idx = find_oldest_same_id_context_index(bid);
    if (same_id_idx < 0) begin
        return -1;
    end

    if (context_q[same_id_idx].w_seen) begin
        return same_id_idx;
    end

    return -1;
endfunction : find_b_context_index

function int unsigned axi_write_monitor::get_outstanding_depth();
    int unsigned depth;

    depth = 0;
    for (int i = 0; i < context_q.size(); i++) begin
        if ((context_q[i].aw_seen || context_q[i].w_started) &&
            !context_q[i].b_seen) begin
            depth++;
        end
    end

    return depth;
endfunction : get_outstanding_depth

task axi_write_monitor::publish_complete_transactions();
    int unsigned i;
    context_t ctx;

    // Publish only when AW, all W beats, and B response are all collected.
    i = 0;
    while (i < context_q.size()) begin
        ctx = context_q[i];
        if (ctx.aw_seen && ctx.w_seen && ctx.b_seen) begin
            ctx.transaction.wdata = new[ctx.wdata_q.size()];
            ctx.transaction.wstrb = new[ctx.wstrb_q.size()];
            ctx.transaction.wuser = new[ctx.wuser_q.size()];
            ctx.transaction.w_handshake_time =
                new[ctx.w_handshake_time_q.size()];

            for (int unsigned j = 0; j < ctx.wdata_q.size(); j++) begin
                ctx.transaction.wdata[j] = ctx.wdata_q[j];
                ctx.transaction.wstrb[j] = ctx.wstrb_q[j];
                ctx.transaction.wuser[j] = ctx.wuser_q[j];
                ctx.transaction.w_handshake_time[j] =
                    ctx.w_handshake_time_q[j];
            end

            // Check collected W beat count before publishing the full transaction.
            ctx.transaction.beat_count = ctx.wdata_q.size();
            if (cfg.checks_enable &&
                ctx.transaction.beat_count != ctx.transaction.awlen + 1) begin
                `uvm_error("AXI_MON", axi_diag::format(
                    "WRITE_COLLECTED_BEAT_COUNT_MISMATCH", "AXI_WRITE_MONITOR", "W",
                    "TRANSACTION_PUBLISH",
                    $sformatf("AWID=0x%0h BID=0x%0h collected_beats=%0d expected_beats=%0d AWLEN=%0d time=%0t",
                        ctx.transaction.awid, ctx.transaction.bid,
                        ctx.transaction.beat_count,
                        ctx.transaction.awlen + 1,
                        ctx.transaction.awlen, $time),
                    "collected W beats=AWLEN+1 when the B-completed transaction is published",
                    "REPORT_ONLY", "Published write transaction has an inconsistent W beat count"))
            end

            `uvm_info("AXI_MON",
                $sformatf("Transfer collected:\n%s", ctx.transaction.sprint()),
                UVM_FULL)

            print_write_performance(ctx.transaction);
            analysis_port.write(ctx.transaction);
            context_q.delete(i);
        end
        else begin
            i++;
        end
    end
endtask : publish_complete_transactions

`endif
