// ============================================================================
// Filename             : axi_read_monitor.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_READ_MONITOR_SV
`define AXI_READ_MONITOR_SV

class axi_read_monitor_context #(
    int unsigned ID_WIDTH,
    int unsigned ADDR_WIDTH,
    int unsigned DATA_WIDTH,
    int unsigned USER_WIDTH
);
    typedef axi_read_transaction #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) transaction_t;
    // One context tracks one in-flight read transaction while AR and R may be
    // separated by many cycles and multiple IDs may be outstanding.
    transaction_t transaction;
    bit                    ar_seen;
    bit                    arid_known;
    bit                    ar_geometry_known;
    bit                    r_seen;
    bit                    exclusive_seen_okay;
    bit                    exclusive_seen_exokay;
    bit                    exclusive_success_mix_reported;
    bit [DATA_WIDTH-1:0] rdata_q[$];
    bit [1:0]              rresp_q[$];
    bit [USER_WIDTH-1:0] ruser_q[$];
    time                   r_handshake_time_q[$];
    longint unsigned       arvalid_start_cycle;
    bit                    arvalid_start_cycle_valid;
    longint unsigned       current_rvalid_start_cycle;
    bit                    current_rvalid_start_cycle_valid;
    longint unsigned       previous_r_handshake_cycle;
    bit                    previous_r_handshake_cycle_valid;
    longint unsigned       r_inter_beat_bubble_q[$];

    function new(string name = "transaction");
        transaction = transaction_t::type_id::create(name);
        ar_seen = 1'b0;
        arid_known = 1'b0;
        ar_geometry_known = 1'b0;
        r_seen = 1'b0;
        exclusive_seen_okay = 1'b0;
        exclusive_seen_exokay = 1'b0;
        exclusive_success_mix_reported = 1'b0;
        rdata_q.delete();
        rresp_q.delete();
        ruser_q.delete();
        r_handshake_time_q.delete();
        arvalid_start_cycle = 0;
        arvalid_start_cycle_valid = 1'b0;
        current_rvalid_start_cycle = 0;
        current_rvalid_start_cycle_valid = 1'b0;
        previous_r_handshake_cycle = 0;
        previous_r_handshake_cycle_valid = 1'b0;
        r_inter_beat_bubble_q.delete();
    endfunction : new
endclass : axi_read_monitor_context

class axi_read_monitor #(
    int unsigned ID_WIDTH,
    int unsigned ADDR_WIDTH,
    int unsigned DATA_WIDTH,
    int unsigned USER_WIDTH
) extends uvm_monitor;
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    localparam int AXI_BUS_SIZE = $clog2(DATA_BYTES);
    typedef axi_burst_math #(ADDR_WIDTH, DATA_BYTES) burst_math_t;
    typedef axi_read_monitor #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_read_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_read_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_cfg_t;
    typedef axi_read_transaction #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) transaction_t;
    typedef axi_read_address_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) address_event_t;
    typedef axi_read_data_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) data_event_t;
    typedef axi_read_monitor_context #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) context_t;

    vif_t         vif;
    monitor_cfg_t cfg;

    // Scenario 3: publish a complete read transaction from accepted
    // RVALID&RREADY data. For bursts, the full AR+R packet is emitted on the
    // accepted RLAST beat.
    uvm_analysis_port #(transaction_t) analysis_port;

    // Scenario 1: publish channel-level packets when channel payload first
    // appears on the interface with VALID high.
    uvm_analysis_port #(address_event_t) ar_ap;
    uvm_analysis_port #(data_event_t)    r_ap;

    // Hold not-yet-complete transactions for outstanding reconstruction.
    protected context_t context_q[$];

    // Track whether the current channel payload has already been published on
    // the VALID-based channel ports. This avoids duplicate packets while READY
    // is low, and still supports back-to-back payloads when VALID stays high.
    protected bit ar_valid_active;
    protected bit r_valid_active;
    protected int unsigned r_valid_beat_index;
    protected longint unsigned cycle_count;
    protected longint unsigned current_arvalid_start_cycle;
    protected bit current_arvalid_start_cycle_valid;
    protected longint unsigned bandwidth_sampled_cycles;
    protected longint unsigned bandwidth_handshake_cycles;
    protected longint unsigned bandwidth_valid_bytes;
    protected bit bandwidth_payload_measurement_valid;

    // Payload snapshots used to check that VALID-side payload stays stable
    // until handshake. logic keeps X/Z visible in !== comparisons.
    protected logic [ID_WIDTH-1:0]     arid_hold;
    protected logic [ADDR_WIDTH-1:0]   araddr_hold;
    protected logic [7:0]                       arlen_hold;
    protected logic [2:0]                       arsize_hold;
    protected logic [1:0]                       arburst_hold;
    protected logic                             arlock_hold;
    protected logic [3:0]                       arcache_hold;
    protected logic [2:0]                       arprot_hold;
    protected logic [3:0]                       arqos_hold;
    protected logic [3:0]                       arregion_hold;
    protected logic [USER_WIDTH-1:0]   aruser_hold;
    protected logic [ID_WIDTH-1:0]     rid_hold;
    protected logic [DATA_WIDTH-1:0]   rdata_hold;
    protected logic [1:0]                       rresp_hold;
    protected logic                             rlast_hold;
    protected logic [USER_WIDTH-1:0]   ruser_hold;

    protected bit ar_payload_stable_reported;
    protected bit r_payload_stable_reported;
    protected bit rvalid_ar_order_reported;
    protected bit control_unknown_reported;
    protected bit ar_payload_unknown_reported;
    protected bit r_payload_unknown_reported;

    `uvm_component_param_utils_begin(this_type)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
        analysis_port    = new("analysis_port", this);
        ar_ap = new("ar_ap", this);
        r_ap  = new("r_ap", this);
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
    extern virtual protected task publish_ar_valid_phase();
    extern virtual protected task publish_r_valid_phase();
    extern virtual protected task sample_r_performance_presentation();
    extern virtual protected task print_read_performance(
        transaction_t transaction);
    extern virtual protected function void reset_read_bandwidth_window();
    extern virtual protected function void sample_read_bandwidth(bit r_hs);
    extern virtual protected function void print_read_bandwidth(bit partial_window);
    extern virtual protected task capture_ar_payload();
    extern virtual protected task capture_r_payload();
    extern virtual protected task check_ar_payload_stable();
    extern virtual protected task check_r_payload_stable();
    extern virtual protected task check_rvalid_after_ar();
    extern virtual protected task check_ar_request_legal(
        context_t ctx);
    extern virtual protected task sample_ar_phase();
    extern virtual protected task sample_r_phase();
    extern virtual protected task publish_complete_transactions();
    extern virtual protected function int find_oldest_same_id_context_index(bit [ID_WIDTH-1:0] rid);
    extern virtual protected function int find_r_context_index(bit [ID_WIDTH-1:0] rid);
    extern virtual protected function int unsigned get_outstanding_depth();
    extern virtual protected function int unsigned get_visible_r_beat_index(bit [ID_WIDTH-1:0] rid);
    virtual protected function bit [DATA_BYTES-1:0] get_visible_rdata_valid_mask(
        bit [ID_WIDTH-1:0] rid,
        int unsigned beat_idx
    );
        int ctx_idx;

        ctx_idx = find_r_context_index(rid);
        if (ctx_idx >= 0) begin
            return context_q[ctx_idx].transaction.get_beat_rdata_valid_mask(beat_idx);
        end

        return '0;
    endfunction : get_visible_rdata_valid_mask
endclass : axi_read_monitor

task axi_read_monitor::reset_phase(uvm_phase phase);
    monitor_reset();
endtask : reset_phase

task axi_read_monitor::main_phase(uvm_phase phase);
    collect_transactions();
endtask : main_phase

function void axi_read_monitor::report_phase(uvm_phase phase);
    super.report_phase(phase);
    if (cfg != null && cfg.bandwidth_enable &&
        bandwidth_sampled_cycles > 0) begin
        print_read_bandwidth(1'b1);
        reset_read_bandwidth_window();
    end
endfunction : report_phase

task axi_read_monitor::monitor_reset();
    context_q.delete();
    ar_valid_active = 1'b0;
    r_valid_active = 1'b0;
    r_valid_beat_index = 0;
    cycle_count = 0;
    current_arvalid_start_cycle = 0;
    current_arvalid_start_cycle_valid = 1'b0;
    reset_read_bandwidth_window();
    arid_hold = '0;
    araddr_hold = '0;
    arlen_hold = '0;
    arsize_hold = '0;
    arburst_hold = '0;
    arlock_hold = 1'b0;
    arcache_hold = '0;
    arprot_hold = '0;
    arqos_hold = '0;
    arregion_hold = '0;
    aruser_hold = '0;
    rid_hold = '0;
    rdata_hold = '0;
    rresp_hold = '0;
    rlast_hold = 1'b0;
    ruser_hold = '0;
    ar_payload_stable_reported = 1'b0;
    r_payload_stable_reported = 1'b0;
    rvalid_ar_order_reported = 1'b0;
    control_unknown_reported = 1'b0;
    ar_payload_unknown_reported = 1'b0;
    r_payload_unknown_reported = 1'b0;
endtask : monitor_reset

task axi_read_monitor::collect_transactions();
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

task axi_read_monitor::sample_one_cycle();
    bit ar_valid_issue;
    bit r_valid_issue;
    bit ar_hs;
    bit r_hs;

    if (cfg.performance_enable) begin
        cycle_count++;
    end
    check_unknown_signals();

    ar_hs = vif.mon_cb.arvalid && vif.mon_cb.arready;
    r_hs  = vif.mon_cb.rvalid  && vif.mon_cb.rready;

    // Scenario 1 samples the first cycle of each payload while VALID is high.
    // It is earlier than handshake and is used by timing-accurate platforms.
    ar_valid_issue = vif.mon_cb.arvalid && !ar_valid_active;
    r_valid_issue  = vif.mon_cb.rvalid  && !r_valid_active;

    if (ar_valid_issue) begin
        if (cfg.performance_enable) begin
            current_arvalid_start_cycle = cycle_count;
            current_arvalid_start_cycle_valid = 1'b1;
        end
        capture_ar_payload();
        publish_ar_valid_phase();
        ar_valid_active = 1'b1;
        ar_payload_stable_reported = 1'b0;
    end
    else if (ar_valid_active) begin
        check_ar_payload_stable();
    end

    if (r_valid_issue) begin
        capture_r_payload();
        publish_r_valid_phase();
        r_valid_active = 1'b1;
        r_payload_stable_reported = 1'b0;
        rvalid_ar_order_reported = 1'b0;
        // Protocol causality is evaluated before this edge's AR handshake is
        // added to context_q. A same-edge AR cannot justify this RVALID.
        check_rvalid_after_ar();
    end
    else if (r_valid_active) begin
        check_r_payload_stable();
    end

    if (ar_hs) begin
        sample_ar_phase();
    end

    // Reconstruction intentionally remains AR-first so a same-edge AR/R
    // handshake can still use the new geometry for bandwidth and transaction
    // recovery. The independent RVALID causality check above used only the
    // pre-edge context snapshot and already reports that protocol violation.
    sample_read_bandwidth(r_hs);

    if (r_valid_issue) begin
        sample_r_performance_presentation();
    end

    if (r_hs) begin
        sample_r_phase();
        publish_complete_transactions();
    end

    if (!vif.mon_cb.arvalid || ar_hs) begin
        ar_valid_active = 1'b0;
        ar_payload_stable_reported = 1'b0;
        if (ar_hs || !vif.mon_cb.arvalid) begin
            current_arvalid_start_cycle_valid = 1'b0;
        end
    end

    if (!vif.mon_cb.rvalid || r_hs) begin
        r_valid_active = 1'b0;
        r_payload_stable_reported = 1'b0;
        rvalid_ar_order_reported = 1'b0;
    end

endtask : sample_one_cycle

function void axi_read_monitor::reset_read_bandwidth_window();
    bandwidth_sampled_cycles = 0;
    bandwidth_handshake_cycles = 0;
    bandwidth_valid_bytes = 0;
    bandwidth_payload_measurement_valid = 1'b1;
endfunction : reset_read_bandwidth_window

function void axi_read_monitor::sample_read_bandwidth(bit r_hs);
    int ctx_idx;
    int unsigned beat_idx;
    bit [DATA_BYTES-1:0] valid_mask;
    bit rid_known;

    if (!cfg.bandwidth_enable) begin
        return;
    end

    // The event on this ACLK edge belongs to the current window.  Only after
    // sampling it do we close and clear a full window.
    bandwidth_sampled_cycles++;
    if (r_hs) begin
        bandwidth_handshake_cycles++;
        rid_known = !$isunknown(vif.mon_cb.rid);
        ctx_idx = -1;
        if (!rid_known) begin
            // Do not coerce an unknown RID into the 2-state lookup key and
            // accidentally attribute its payload to a real transaction.
            bandwidth_payload_measurement_valid = 1'b0;
        end
        else begin
            ctx_idx = find_r_context_index(vif.mon_cb.rid);
        end
        if (rid_known && ctx_idx < 0) begin
            // Channel utilization remains measurable, but payload bytes
            // cannot be inferred without the matching AR geometry.
            bandwidth_payload_measurement_valid = 1'b0;
        end
        else if (rid_known &&
                 (!context_q[ctx_idx].arid_known ||
                  !context_q[ctx_idx].ar_geometry_known)) begin
            // The transaction stores 2-state fields. Preserve the fact that
            // accepted AR identity or geometry contained X/Z instead of
            // deriving a false valid-byte mask after that conversion.
            bandwidth_payload_measurement_valid = 1'b0;
        end
        else if (rid_known) begin
            beat_idx = context_q[ctx_idx].rdata_q.size();
            valid_mask = context_q[ctx_idx].transaction.get_beat_rdata_valid_mask(
                beat_idx);
            if (valid_mask == '0) begin
                // An accepted beat whose request geometry yields no valid
                // lanes is not a meaningful zero-byte payload sample.
                bandwidth_payload_measurement_valid = 1'b0;
            end
            else begin
                bandwidth_valid_bytes += $countones(valid_mask);
            end
        end
    end

    if (bandwidth_sampled_cycles >= cfg.bandwidth_window_cycles) begin
        print_read_bandwidth(1'b0);
        reset_read_bandwidth_window();
    end
endfunction : sample_read_bandwidth

function void axi_read_monitor::print_read_bandwidth(bit partial_window);
    real channel_utilization_percent;
    real payload_utilization_percent;
    real effective_bytes_per_cycle;

    if (!cfg.bandwidth_enable || bandwidth_sampled_cycles == 0) begin
        return;
    end

    // Start every expression with a real operand so no intermediate integer
    // multiplication can truncate or overflow before conversion.
    channel_utilization_percent =
        100.0 * bandwidth_handshake_cycles / bandwidth_sampled_cycles;

    if (bandwidth_payload_measurement_valid) begin
        payload_utilization_percent =
            100.0 * bandwidth_valid_bytes /
            bandwidth_sampled_cycles / DATA_BYTES;
        effective_bytes_per_cycle =
            1.0 * bandwidth_valid_bytes / bandwidth_sampled_cycles;
        `uvm_info("AXI_READ_BANDWIDTH",
            $sformatf({"--------------read bandwidth-------------\n",
                       "link=%s\n",
                       "window_cycles=%0d configured_window_cycles=%0d partial_window=%0b\n",
                       "handshake_cycles=%0d channel_utilization_percent=%0.3f\n",
                       "payload_measurement_valid=1 valid_bytes=%0d data_bytes_per_cycle=%0d\n",
                       "payload_utilization_percent=%0.3f effective_bytes_per_cycle=%0.6f\n",
                       "-----------------------------------------"},
                get_full_name(), bandwidth_sampled_cycles,
                cfg.bandwidth_window_cycles, partial_window,
                bandwidth_handshake_cycles, channel_utilization_percent,
                bandwidth_valid_bytes, DATA_BYTES,
                payload_utilization_percent, effective_bytes_per_cycle),
            UVM_LOW)
    end
    else begin
        `uvm_info("AXI_READ_BANDWIDTH",
            $sformatf({"--------------read bandwidth-------------\n",
                       "link=%s\n",
                       "window_cycles=%0d configured_window_cycles=%0d partial_window=%0b\n",
                       "handshake_cycles=%0d channel_utilization_percent=%0.3f\n",
                       "payload_measurement_valid=0 valid_bytes=%0d data_bytes_per_cycle=%0d\n",
                       "payload_utilization_percent=UNAVAILABLE effective_bytes_per_cycle=UNAVAILABLE\n",
                       "-----------------------------------------"},
                get_full_name(), bandwidth_sampled_cycles,
                cfg.bandwidth_window_cycles, partial_window,
                bandwidth_handshake_cycles, channel_utilization_percent,
                bandwidth_valid_bytes, DATA_BYTES),
            UVM_LOW)
    end
endfunction : print_read_bandwidth

task axi_read_monitor::check_unknown_signals();
    if (!cfg.checks_enable) begin
        return;
    end

    if ($isunknown({vif.mon_cb.arvalid,
                    vif.mon_cb.arready,
                    vif.mon_cb.rvalid,
                    vif.mon_cb.rready})) begin
        if (!control_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "HANDSHAKE_CONTROL_XZ", "AXI_READ_MONITOR", "AR/R", "SAMPLE",
                $sformatf("ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b time=%0t",
                    vif.mon_cb.arvalid, vif.mon_cb.arready,
                    vif.mon_cb.rvalid, vif.mon_cb.rready, $time),
                "ARVALID/ARREADY/RVALID/RREADY each resolve to 0 or 1",
                "REPORT_ONLY", "X/Z detected on a read-channel handshake control"))
            control_unknown_reported = 1'b1;
        end
    end
    else begin
        control_unknown_reported = 1'b0;
    end

    if (vif.mon_cb.arvalid === 1'b1 &&
        $isunknown({vif.mon_cb.arid,
                    vif.mon_cb.araddr,
                    vif.mon_cb.arlen,
                    vif.mon_cb.arsize,
                    vif.mon_cb.arburst,
                    vif.mon_cb.arlock,
                    vif.mon_cb.arcache,
                    vif.mon_cb.arprot,
                    vif.mon_cb.arqos,
                    vif.mon_cb.arregion,
                    vif.mon_cb.aruser})) begin
        if (!ar_payload_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "AR_PAYLOAD_XZ", "AXI_READ_MONITOR", "AR", "VALID_HIGH_CHECK",
                $sformatf({"ARVALID=%b ARREADY=%b ARID=0x%0h ARADDR=0x%0h ",
                           "ARLEN=0x%0h ARSIZE=0x%0h ARBURST=0x%0h ARLOCK=%b ",
                           "ARCACHE=0x%0h ARPROT=0x%0h ARQOS=0x%0h ",
                           "ARREGION=0x%0h ARUSER=0x%0h time=%0t"},
                    vif.mon_cb.arvalid, vif.mon_cb.arready, vif.mon_cb.arid,
                    vif.mon_cb.araddr, vif.mon_cb.arlen, vif.mon_cb.arsize,
                    vif.mon_cb.arburst, vif.mon_cb.arlock, vif.mon_cb.arcache,
                    vif.mon_cb.arprot, vif.mon_cb.arqos, vif.mon_cb.arregion,
                    vif.mon_cb.aruser, $time),
                "all AR payload fields resolve to known values while ARVALID=1",
                "REPORT_ONLY", "X/Z detected in the asserted AR payload"))
            ar_payload_unknown_reported = 1'b1;
        end
    end
    else begin
        ar_payload_unknown_reported = 1'b0;
    end

    if (vif.mon_cb.rvalid === 1'b1 &&
        $isunknown({vif.mon_cb.rid,
                    vif.mon_cb.rdata,
                    vif.mon_cb.rresp,
                    vif.mon_cb.rlast,
                    vif.mon_cb.ruser})) begin
        if (!r_payload_unknown_reported) begin
            `uvm_error("AXI_XZ", axi_diag::format(
                "R_PAYLOAD_XZ", "AXI_READ_MONITOR", "R", "VALID_HIGH_CHECK",
                $sformatf({"RVALID=%b RREADY=%b RID=0x%0h RDATA=0x%0h ",
                           "RRESP=0x%0h RLAST=%b RUSER=0x%0h time=%0t"},
                    vif.mon_cb.rvalid, vif.mon_cb.rready, vif.mon_cb.rid,
                    vif.mon_cb.rdata, vif.mon_cb.rresp, vif.mon_cb.rlast,
                    vif.mon_cb.ruser, $time),
                "all R payload fields resolve to known values while RVALID=1",
                "REPORT_ONLY", "X/Z detected in the asserted R payload"))
            r_payload_unknown_reported = 1'b1;
        end
    end
    else begin
        r_payload_unknown_reported = 1'b0;
    end
endtask : check_unknown_signals

task axi_read_monitor::capture_ar_payload();
    arid_hold     = vif.mon_cb.arid;
    araddr_hold   = vif.mon_cb.araddr;
    arlen_hold    = vif.mon_cb.arlen;
    arsize_hold   = vif.mon_cb.arsize;
    arburst_hold  = vif.mon_cb.arburst;
    arlock_hold   = vif.mon_cb.arlock;
    arcache_hold  = vif.mon_cb.arcache;
    arprot_hold   = vif.mon_cb.arprot;
    arqos_hold    = vif.mon_cb.arqos;
    arregion_hold = vif.mon_cb.arregion;
    aruser_hold   = vif.mon_cb.aruser;
endtask : capture_ar_payload

task axi_read_monitor::capture_r_payload();
    rid_hold   = vif.mon_cb.rid;
    rdata_hold = vif.mon_cb.rdata;
    rresp_hold = vif.mon_cb.rresp;
    rlast_hold = vif.mon_cb.rlast;
    ruser_hold = vif.mon_cb.ruser;
endtask : capture_r_payload

task axi_read_monitor::check_ar_payload_stable();
    if (!cfg.checks_enable) begin
        return;
    end

    if (!vif.mon_cb.arvalid) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "ARVALID_DROPPED_BEFORE_HANDSHAKE", "AXI_READ_MONITOR", "AR",
            "WAIT_HANDSHAKE",
            $sformatf({"held_ARVALID=1 current_ARVALID=%b current_ARREADY=%b ",
                       "held_ARID=0x%0h held_ARADDR=0x%0h held_ARLEN=%0d ",
                       "held_ARSIZE=%0d held_ARBURST=0x%0h time=%0t"},
                vif.mon_cb.arvalid, vif.mon_cb.arready, arid_hold, araddr_hold,
                arlen_hold, arsize_hold, arburst_hold, $time),
            "ARVALID remains 1 with the held payload until ARREADY=1",
            "REPORT_ONLY", "The source withdrew ARVALID before an AR handshake"))
        return;
    end

    if (!ar_payload_stable_reported &&
        (vif.mon_cb.arid     !== arid_hold     ||
         vif.mon_cb.araddr   !== araddr_hold   ||
         vif.mon_cb.arlen    !== arlen_hold    ||
         vif.mon_cb.arsize   !== arsize_hold   ||
         vif.mon_cb.arburst  !== arburst_hold  ||
         vif.mon_cb.arlock   !== arlock_hold   ||
         vif.mon_cb.arcache  !== arcache_hold  ||
         vif.mon_cb.arprot   !== arprot_hold   ||
         vif.mon_cb.arqos    !== arqos_hold    ||
         vif.mon_cb.arregion !== arregion_hold ||
         vif.mon_cb.aruser   !== aruser_hold)) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "AR_PAYLOAD_UNSTABLE", "AXI_READ_MONITOR", "AR",
            "WAIT_HANDSHAKE",
            $sformatf({"ARVALID=%b ARREADY=%b current={id=0x%0h addr=0x%0h ",
                       "len=0x%0h size=0x%0h burst=0x%0h lock=%b cache=0x%0h ",
                       "prot=0x%0h qos=0x%0h region=0x%0h user=0x%0h} time=%0t"},
                vif.mon_cb.arvalid, vif.mon_cb.arready, vif.mon_cb.arid,
                vif.mon_cb.araddr, vif.mon_cb.arlen, vif.mon_cb.arsize,
                vif.mon_cb.arburst, vif.mon_cb.arlock, vif.mon_cb.arcache,
                vif.mon_cb.arprot, vif.mon_cb.arqos, vif.mon_cb.arregion,
                vif.mon_cb.aruser, $time),
            $sformatf({"held={id=0x%0h addr=0x%0h len=0x%0h size=0x%0h ",
                       "burst=0x%0h lock=%b cache=0x%0h prot=0x%0h qos=0x%0h ",
                       "region=0x%0h user=0x%0h} until ARREADY=1"},
                arid_hold, araddr_hold, arlen_hold, arsize_hold, arburst_hold,
                arlock_hold, arcache_hold, arprot_hold, arqos_hold,
                arregion_hold, aruser_hold),
            "REPORT_ONLY", "One or more compared AR payload fields changed"))
        ar_payload_stable_reported = 1'b1;
    end
endtask : check_ar_payload_stable

task axi_read_monitor::check_r_payload_stable();
    if (!cfg.checks_enable) begin
        return;
    end

    if (!vif.mon_cb.rvalid) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "RVALID_DROPPED_BEFORE_HANDSHAKE", "AXI_READ_MONITOR", "R",
            "WAIT_HANDSHAKE",
            $sformatf({"held_RVALID=1 current_RVALID=%b current_RREADY=%b ",
                       "held_RID=0x%0h held_RDATA=0x%0h held_RRESP=0x%0h ",
                       "held_RLAST=%b held_RUSER=0x%0h time=%0t"},
                vif.mon_cb.rvalid, vif.mon_cb.rready, rid_hold, rdata_hold,
                rresp_hold, rlast_hold, ruser_hold, $time),
            "RVALID remains 1 with the held payload until RREADY=1",
            "REPORT_ONLY", "The source withdrew RVALID before an R handshake"))
        return;
    end

    if (!r_payload_stable_reported &&
        (vif.mon_cb.rid   !== rid_hold   ||
         vif.mon_cb.rdata !== rdata_hold ||
         vif.mon_cb.rresp !== rresp_hold ||
         vif.mon_cb.rlast !== rlast_hold ||
         vif.mon_cb.ruser !== ruser_hold)) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "R_PAYLOAD_UNSTABLE", "AXI_READ_MONITOR", "R",
            "WAIT_HANDSHAKE",
            $sformatf({"RVALID=%b RREADY=%b current={rid=0x%0h data=0x%0h ",
                       "resp=0x%0h last=%b user=0x%0h} time=%0t"},
                vif.mon_cb.rvalid, vif.mon_cb.rready, vif.mon_cb.rid,
                vif.mon_cb.rdata, vif.mon_cb.rresp, vif.mon_cb.rlast,
                vif.mon_cb.ruser, $time),
            $sformatf({"held={rid=0x%0h data=0x%0h resp=0x%0h last=%b ",
                       "user=0x%0h} until RREADY=1"},
                rid_hold, rdata_hold, rresp_hold, rlast_hold, ruser_hold),
            "REPORT_ONLY", "One or more compared R payload fields changed"))
        r_payload_stable_reported = 1'b1;
    end
endtask : check_r_payload_stable

task axi_read_monitor::check_rvalid_after_ar();
    int same_id_idx;
    bit [ID_WIDTH-1:0] rid;

    if (!cfg.checks_enable) begin
        return;
    end

    if ($isunknown(vif.mon_cb.rid)) begin
        // AXI_XZ already owns this payload error. Mark the dependency check as
        // handled so an accepted beat does not add a misleading coerced-RID
        // R_HANDSHAKE_WITHOUT_AR_CONTEXT report later on the same VALID item.
        rvalid_ar_order_reported = 1'b1;
        return;
    end

    rid = vif.mon_cb.rid;
    same_id_idx = find_oldest_same_id_context_index(rid);
    if (same_id_idx < 0) begin
        `uvm_error("AXI_MON", axi_diag::format(
            "RVALID_WITHOUT_ACCEPTED_AR", "AXI_READ_MONITOR", "R",
            "VALID_ASSERT",
            $sformatf({"RID=0x%0h RVALID=%b RREADY=%b ",
                       "preedge_accepted_contexts=%0d current_edge_ARVALID=%b ",
                       "current_edge_ARREADY=%b current_edge_ARID=0x%0h time=%0t"},
                rid, vif.mon_cb.rvalid, vif.mon_cb.rready,
                context_q.size(), vif.mon_cb.arvalid, vif.mon_cb.arready,
                vif.mon_cb.arid, $time),
            "a matching AR handshake completed on an earlier ACLK edge before RVALID assertion",
            "REPORT_ONLY",
            {"No pre-edge accepted ARID matches RID; an AR handshake on the ",
             "current sampling edge is too late to justify this RVALID"}))
        rvalid_ar_order_reported = 1'b1;
    end
endtask : check_rvalid_after_ar

task axi_read_monitor::check_ar_request_legal(context_t ctx);
    axi_request_rule_e rule;
    bit [ADDR_WIDTH-1:0] low_addr;
    bit [ADDR_WIDTH-1:0] high_addr;
    string report_id;
    string reason;
    string expected;
    string detail;
    string range_observed;

    if (!cfg.checks_enable ||
        ctx == null || !ctx.ar_seen) begin
        return;
    end

    if (!$isunknown(vif.mon_cb.arcache) &&
        !axi_cache_is_legal(vif.mon_cb.arcache)) begin
        `uvm_error("AXI_READ_REQUEST", axi_diag::format(
            "AR_CACHE_RESERVED", "AXI_READ_MONITOR", "AR",
            "HANDSHAKE_CHECK",
            $sformatf("ARCACHE=0x%0h ARID=0x%0h ARADDR=0x%0h time=%0t",
                vif.mon_cb.arcache, ctx.transaction.arid,
                ctx.transaction.araddr, $time),
            AXI_CACHE_LEGAL_EXPECTED, "REPORT_ONLY",
            "Accepted AR request uses an AXI4 reserved ARCACHE encoding"))
    end

    // One common helper owns rule priority and all request geometry math.
    // A Monitor always enforces the AXI 4KB rule, independently of the
    // stimulus-side negative-test protection switch.
    rule = burst_math_t::get_request_geometry_rule(
        ctx.transaction.araddr,
        ctx.transaction.arlen,
        ctx.transaction.arsize,
        ctx.transaction.arburst,
        AXI4_MAX_BURST_BEATS,
        ctx.transaction.arlock,
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
            report_id = "AXI_READ_REQUEST";
            reason = "AR_BURST_UNSUPPORTED";
            expected = "ARBURST is FIXED(0), INCR(1), or WRAP(2)";
            detail = "Accepted AR request uses a reserved burst encoding";
        end
        AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS: begin
            report_id = ctx.transaction.arlock ?
                "AXI_EXCLUSIVE_GEOMETRY" : "AXI_READ_REQUEST";
            reason = "AR_SIZE_EXCEEDS_BUS";
            expected = $sformatf("ARSIZE inside [0:%0d]", AXI_BUS_SIZE);
            detail = "Accepted read beat size exceeds the data bus width";
        end
        AXI_REQUEST_RULE_FIXED_TOO_LONG: begin
            report_id = "AXI_READ_REQUEST";
            reason = "AR_FIXED_BEATS_EXCEED_16";
            expected = "FIXED burst ARLEN+1 <= 16";
            detail = "Accepted FIXED read burst is too long";
        end
        AXI_REQUEST_RULE_WRAP_LENGTH: begin
            report_id = "AXI_READ_REQUEST";
            reason = "AR_WRAP_BEATS_INVALID";
            expected = "WRAP burst ARLEN+1 is one of 2,4,8,16";
            detail = "Accepted WRAP read has an illegal beat count";
        end
        AXI_REQUEST_RULE_WRAP_ALIGNMENT: begin
            report_id = "AXI_READ_REQUEST";
            reason = "AR_WRAP_ADDR_UNALIGNED";
            expected = "WRAP start ARADDR is aligned to 1<<ARSIZE bytes";
            detail = "Accepted WRAP read start address is not beat aligned";
        end
        AXI_REQUEST_RULE_ADDRESS_OVERFLOW: begin
            report_id = "AXI_AR_ADDRESS_OVERFLOW";
            reason = "AR_ADDRESS_OVERFLOW";
            expected = $sformatf("complete read footprint is representable in ADDR_WIDTH=%0d", ADDR_WIDTH);
            detail = "Read footprint arithmetic exceeds the configured address width; this is distinct from a 4KB crossing";
        end
        AXI_REQUEST_RULE_CROSSES_4KB: begin
            report_id = "AXI_AR_CROSSES_4KB";
            reason = "AR_CROSSES_4KB";
            expected = "complete read footprint low_addr and high_addr are in one 4KB region";
            detail = "Accepted read burst crosses a 4KB boundary";
        end
        AXI_REQUEST_RULE_EXCLUSIVE_BEATS: begin
            report_id = "AXI_EXCLUSIVE_GEOMETRY";
            reason = "AR_EXCLUSIVE_BEATS_INVALID";
            expected = "ARLOCK=1 requires ARLEN+1 in {1,2,4,8,16}";
            detail = "Accepted exclusive read uses an illegal beat count";
        end
        AXI_REQUEST_RULE_EXCLUSIVE_BYTES: begin
            report_id = "AXI_EXCLUSIVE_GEOMETRY";
            reason = "AR_EXCLUSIVE_BYTES_EXCEED_128";
            expected = "ARLOCK=1 requires (ARLEN+1)*(1<<ARSIZE) <= 128 bytes";
            detail = "Accepted exclusive read transfer is larger than 128 bytes";
        end
        AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT: begin
            report_id = "AXI_EXCLUSIVE_GEOMETRY";
            reason = "AR_EXCLUSIVE_ADDR_UNALIGNED";
            expected = "ARLOCK=1 requires ARADDR aligned to total transfer bytes";
            detail = "Accepted exclusive read start address is not transfer aligned";
        end
        default: begin
            report_id = "AXI_READ_REQUEST";
            reason = "AR_GEOMETRY_RULE_UNHANDLED";
            expected = "get_request_geometry_rule returns a documented AR geometry rule";
            detail = "Common geometry helper returned an unexpected rule";
        end
    endcase

    `uvm_error(report_id, axi_diag::format(
        reason, "AXI_READ_MONITOR", "AR", "HANDSHAKE_CHECK",
        $sformatf({"ARID=0x%0h ARADDR=0x%0h ARLEN=%0d beats=%0d ",
                   "ARSIZE=%0d BUS_SIZE=%0d ARBURST=0x%0h ARLOCK=%0b ",
                   "%s rule=%s time=%0t"},
            ctx.transaction.arid, ctx.transaction.araddr,
            ctx.transaction.arlen, int'(ctx.transaction.arlen) + 1,
            ctx.transaction.arsize, AXI_BUS_SIZE,
            ctx.transaction.arburst, ctx.transaction.arlock,
            range_observed, rule.name(), $time),
        expected, "REPORT_ONLY", detail))
endtask : check_ar_request_legal

task axi_read_monitor::publish_ar_valid_phase();
    address_event_t axi_master_read_ar_tr;

    // Channel packet at ARVALID issue time.
    axi_master_read_ar_tr = address_event_t::type_id::create("axi_master_read_ar_tr", this);
    axi_master_read_ar_tr.arid     = vif.mon_cb.arid;
    axi_master_read_ar_tr.araddr   = vif.mon_cb.araddr;
    axi_master_read_ar_tr.arlen    = vif.mon_cb.arlen;
    axi_master_read_ar_tr.arsize   = vif.mon_cb.arsize;
    axi_master_read_ar_tr.arburst  = axi_burst_e'(vif.mon_cb.arburst);
    axi_master_read_ar_tr.arlock   = vif.mon_cb.arlock;
    axi_master_read_ar_tr.arcache  = vif.mon_cb.arcache;
    axi_master_read_ar_tr.arprot   = vif.mon_cb.arprot;
    axi_master_read_ar_tr.arqos    = vif.mon_cb.arqos;
    axi_master_read_ar_tr.arregion = vif.mon_cb.arregion;
    axi_master_read_ar_tr.aruser   = vif.mon_cb.aruser;

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=VALID_ASSERT role=BUS_READ channel=AR time=%0t id=0x%0h addr=0x%0h len=%0d size=%0d burst=%s",
            $time, axi_master_read_ar_tr.arid, axi_master_read_ar_tr.araddr,
            axi_master_read_ar_tr.arlen, axi_master_read_ar_tr.arsize,
            axi_master_read_ar_tr.arburst.name()),
        UVM_MEDIUM)
    ar_ap.write(axi_master_read_ar_tr);
endtask : publish_ar_valid_phase

task axi_read_monitor::publish_r_valid_phase();
    data_event_t axi_master_read_r_tr;

    // Channel packet when slaver/DUT read data first becomes visible with
    // RVALID. beat_index is best-effort at VALID phase, using accepted beats
    // already collected for the matching RID when available.
    axi_master_read_r_tr = data_event_t::type_id::create("axi_master_read_r_tr", this);
    axi_master_read_r_tr.rid        = vif.mon_cb.rid;
    axi_master_read_r_tr.rdata      = vif.mon_cb.rdata;
    axi_master_read_r_tr.rresp      = axi_resp_e'(vif.mon_cb.rresp);
    axi_master_read_r_tr.rlast      = vif.mon_cb.rlast;
    axi_master_read_r_tr.ruser      = vif.mon_cb.ruser;
    axi_master_read_r_tr.beat_index = get_visible_r_beat_index(axi_master_read_r_tr.rid);
    axi_master_read_r_tr.rdata_valid_mask = get_visible_rdata_valid_mask(axi_master_read_r_tr.rid, axi_master_read_r_tr.beat_index);

    if (axi_master_read_r_tr.rlast) begin
        r_valid_beat_index = 0;
    end
    else begin
        r_valid_beat_index++;
    end

    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=VALID_ASSERT role=BUS_READ channel=R time=%0t id=0x%0h beat=%0d data=0x%0h mask=0x%0h resp=%s last=%0b",
            $time, axi_master_read_r_tr.rid, axi_master_read_r_tr.beat_index,
            axi_master_read_r_tr.rdata, axi_master_read_r_tr.rdata_valid_mask,
            axi_master_read_r_tr.rresp.name(), axi_master_read_r_tr.rlast),
        UVM_MEDIUM)
    r_ap.write(axi_master_read_r_tr);
endtask : publish_r_valid_phase

task axi_read_monitor::sample_r_performance_presentation();
    int ctx_idx;
    context_t ctx;

    if (!cfg.performance_enable) begin
        return;
    end

    ctx_idx = find_r_context_index(vif.mon_cb.rid);
    if (ctx_idx < 0) begin
        return;
    end

    ctx = context_q[ctx_idx];
    ctx.current_rvalid_start_cycle = cycle_count;
    ctx.current_rvalid_start_cycle_valid = 1'b1;
endtask : sample_r_performance_presentation

task axi_read_monitor::print_read_performance(
    transaction_t transaction);
    if (!cfg.performance_enable || transaction == null ||
        !transaction.performance_valid) begin
        return;
    end

    `uvm_info("AXI_READ_PERFORMANCE",
        $sformatf({"--------------read performance------------\n",
                   "link=%s id=0x%0h\n",
                   "read_first_latency_cycles=%0d\n",
                   "ar_handshake_latency_cycles=%0d\n",
                   "read_transaction_latency_cycles=%0d\n",
                   "r_inter_beat_bubble_cycles=%p\n",
                   "r_inter_beat_nonzero_bubble_count=%0d\n",
                   "r_inter_beat_bubble_total_cycles=%0d\n",
                   "r_inter_beat_bubble_max_cycles=%0d\n",
                   "------------------------------------------"},
            get_full_name(), transaction.rid,
            transaction.read_first_latency_cycles,
            transaction.ar_handshake_latency_cycles,
            transaction.read_transaction_latency_cycles,
            transaction.r_inter_beat_bubble_cycles,
            transaction.r_inter_beat_nonzero_bubble_count,
            transaction.r_inter_beat_bubble_total_cycles,
            transaction.r_inter_beat_bubble_max_cycles),
        UVM_LOW)
endtask : print_read_performance

task axi_read_monitor::sample_ar_phase();
    context_t ctx;

    // Accepted AR fields are used only to reconstruct the complete transaction.
    ctx = new("transaction");
    ctx.transaction.arid     = vif.mon_cb.arid;
    ctx.transaction.araddr   = vif.mon_cb.araddr;
    ctx.transaction.arlen    = vif.mon_cb.arlen;
    ctx.transaction.arsize   = vif.mon_cb.arsize;
    ctx.transaction.arburst  = axi_burst_e'(vif.mon_cb.arburst);
    ctx.transaction.arlock   = vif.mon_cb.arlock;
    ctx.transaction.arcache  = vif.mon_cb.arcache;
    ctx.transaction.arprot   = vif.mon_cb.arprot;
    ctx.transaction.arqos    = vif.mon_cb.arqos;
    ctx.transaction.arregion = vif.mon_cb.arregion;
    ctx.transaction.aruser   = vif.mon_cb.aruser;
    ctx.arid_known = !$isunknown(vif.mon_cb.arid);
    ctx.ar_geometry_known = !$isunknown({vif.mon_cb.araddr,
                                         vif.mon_cb.arlen,
                                         vif.mon_cb.arsize,
                                         vif.mon_cb.arburst});
    ctx.transaction.ar_handshake_time = $time;
    if (cfg.performance_enable) begin
        ctx.arvalid_start_cycle = current_arvalid_start_cycle_valid ?
            current_arvalid_start_cycle : cycle_count;
        ctx.arvalid_start_cycle_valid = 1'b1;
        ctx.transaction.ar_handshake_latency_cycles =
            cycle_count - ctx.arvalid_start_cycle;
    end
    ctx.ar_seen = 1'b1;
    context_q.push_back(ctx);
    check_ar_request_legal(ctx);
    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=HANDSHAKE role=BUS_READ channel=AR time=%0t id=0x%0h addr=0x%0h len=%0d size=%0d burst=%s",
            $time, ctx.transaction.arid, ctx.transaction.araddr,
            ctx.transaction.arlen, ctx.transaction.arsize,
            ctx.transaction.arburst.name()),
        UVM_MEDIUM)
    vif.sample_outstanding_depth(get_outstanding_depth());
    if (cfg.checks_enable &&
        get_outstanding_depth() > cfg.outstanding_depth) begin
        `uvm_error("AXI_OUTSTANDING", axi_diag::format(
            "READ_OUTSTANDING_LIMIT_EXCEEDED", "AXI_READ_MONITOR", "AR",
            "HANDSHAKE_CHECK",
            $sformatf("ARID=0x%0h accepted_depth=%0d configured_limit=%0d time=%0t",
                ctx.transaction.arid, get_outstanding_depth(),
                cfg.outstanding_depth, $time),
            "accepted read outstanding depth <= configured limit",
            "REPORT_ONLY", "AR handshake increased the tracked read depth above its limit"))
    end
endtask : sample_ar_phase

task axi_read_monitor::sample_r_phase();
    int ctx_idx;
    context_t ctx;
    data_event_t axi_master_read_r_tr;
    bit exclusive_success_conflict;
    axi_resp_e prior_exclusive_success;

    // Accepted R beat is used only to reconstruct the complete transaction.
    axi_master_read_r_tr = data_event_t::type_id::create("axi_master_read_r_tr", this);
    axi_master_read_r_tr.rid        = vif.mon_cb.rid;
    axi_master_read_r_tr.rdata      = vif.mon_cb.rdata;
    axi_master_read_r_tr.rresp      = axi_resp_e'(vif.mon_cb.rresp);
    axi_master_read_r_tr.rlast      = vif.mon_cb.rlast;
    axi_master_read_r_tr.ruser      = vif.mon_cb.ruser;

    ctx_idx = find_r_context_index(axi_master_read_r_tr.rid);
    if (ctx_idx < 0) begin
        if (cfg.checks_enable && !rvalid_ar_order_reported) begin
            `uvm_error("AXI_MON", axi_diag::format(
                "R_HANDSHAKE_WITHOUT_AR_CONTEXT", "AXI_READ_MONITOR", "R",
                "HANDSHAKE_CHECK",
                $sformatf("RID=0x%0h RRESP=%s RLAST=%0b collected_AR_contexts=%0d time=%0t",
                    axi_master_read_r_tr.rid,
                    axi_master_read_r_tr.rresp.name(),
                    axi_master_read_r_tr.rlast, context_q.size(), $time),
                "an accepted AR context with matching ARID exists before the R handshake",
                "REPORT_ONLY", "Accepted R beat cannot be assigned to a read request"))
        end
        return;
    end

    ctx = context_q[ctx_idx];
    axi_master_read_r_tr.beat_index = ctx.rdata_q.size();
    axi_master_read_r_tr.rdata_valid_mask = ctx.transaction.get_beat_rdata_valid_mask(axi_master_read_r_tr.beat_index);
    `uvm_info("AXI_CHANNEL_EVENT",
        $sformatf("event=HANDSHAKE role=BUS_READ channel=R time=%0t id=0x%0h beat=%0d data=0x%0h mask=0x%0h resp=%s last=%0b",
            $time, axi_master_read_r_tr.rid, axi_master_read_r_tr.beat_index,
            axi_master_read_r_tr.rdata, axi_master_read_r_tr.rdata_valid_mask,
            axi_master_read_r_tr.rresp.name(), axi_master_read_r_tr.rlast),
        UVM_MEDIUM)
    ctx.rdata_q.push_back(axi_master_read_r_tr.rdata);
    ctx.rresp_q.push_back(vif.mon_cb.rresp);
    ctx.ruser_q.push_back(axi_master_read_r_tr.ruser);
    ctx.r_handshake_time_q.push_back($time);
    if (cfg.performance_enable && ctx.arvalid_start_cycle_valid) begin
        if (!ctx.current_rvalid_start_cycle_valid) begin
            ctx.current_rvalid_start_cycle = cycle_count;
            ctx.current_rvalid_start_cycle_valid = 1'b1;
        end
        if (ctx.rdata_q.size() == 1) begin
            ctx.transaction.read_first_latency_cycles =
                cycle_count - ctx.arvalid_start_cycle;
        end
        if (ctx.previous_r_handshake_cycle_valid) begin
            longint unsigned bubble_cycles;

            if (ctx.current_rvalid_start_cycle >
                ctx.previous_r_handshake_cycle) begin
                bubble_cycles = ctx.current_rvalid_start_cycle -
                    ctx.previous_r_handshake_cycle - 1;
            end
            else begin
                bubble_cycles = 0;
            end
            ctx.r_inter_beat_bubble_q.push_back(bubble_cycles);
            ctx.transaction.r_inter_beat_bubble_total_cycles += bubble_cycles;
            if (bubble_cycles > 0) begin
                ctx.transaction.r_inter_beat_nonzero_bubble_count++;
            end
            if (bubble_cycles >
                ctx.transaction.r_inter_beat_bubble_max_cycles) begin
                ctx.transaction.r_inter_beat_bubble_max_cycles = bubble_cycles;
            end
        end
        ctx.previous_r_handshake_cycle = cycle_count;
        ctx.previous_r_handshake_cycle_valid = 1'b1;
        ctx.current_rvalid_start_cycle = 0;
        ctx.current_rvalid_start_cycle_valid = 1'b0;
    end
    ctx.transaction.beat_count = ctx.rdata_q.size();

    if (cfg.checks_enable) begin
        if (axi_master_read_r_tr.rresp == AXI_RESP_EXOKAY &&
            !ctx.transaction.arlock) begin
            `uvm_error("AXI_EXCLUSIVE", axi_diag::format(
                "READ_EXOKAY_WITHOUT_ARLOCK", "AXI_READ_MONITOR", "R",
                "HANDSHAKE_CHECK",
                $sformatf("RID=0x%0h beat_index=%0d RRESP=%s ARLOCK=%0b ARID=0x%0h time=%0t",
                    axi_master_read_r_tr.rid,
                    axi_master_read_r_tr.beat_index,
                    axi_master_read_r_tr.rresp.name(),
                    ctx.transaction.arlock, ctx.transaction.arid, $time),
                "RRESP is not EXOKAY when the matching ARLOCK=0",
                "REPORT_ONLY", "Non-exclusive read returned the exclusive-success response"))
        end
        exclusive_success_conflict = 1'b0;
        prior_exclusive_success = AXI_RESP_OKAY;
        // AXI4 permits SLVERR/DECERR alongside one successful response
        // class in an exclusive read; only OKAY and EXOKAY together conflict.
        if (ctx.transaction.arlock &&
            !$isunknown(vif.mon_cb.rresp)) begin
            case (axi_master_read_r_tr.rresp)
                AXI_RESP_OKAY: begin
                    exclusive_success_conflict =
                        ctx.exclusive_seen_exokay;
                    prior_exclusive_success = AXI_RESP_EXOKAY;
                    ctx.exclusive_seen_okay = 1'b1;
                end
                AXI_RESP_EXOKAY: begin
                    exclusive_success_conflict =
                        ctx.exclusive_seen_okay;
                    prior_exclusive_success = AXI_RESP_OKAY;
                    ctx.exclusive_seen_exokay = 1'b1;
                end
                default: begin
                    // SLVERR and DECERR may coexist with either successful
                    // response class and therefore do not alter this state.
                end
            endcase
        end
        if (exclusive_success_conflict &&
            !ctx.exclusive_success_mix_reported) begin
            `uvm_error("AXI_EXCLUSIVE", axi_diag::format(
                "EXCLUSIVE_READ_OKAY_EXOKAY_MIXED", "AXI_READ_MONITOR", "R",
                "HANDSHAKE_CHECK",
                $sformatf({"RID=0x%0h ARID=0x%0h beat_index=%0d ",
                           "prior_success=%s current_RRESP=%s ",
                           "seen_OKAY=%0b seen_EXOKAY=%0b ",
                           "ARLOCK=%0b time=%0t"},
                    axi_master_read_r_tr.rid,
                    ctx.transaction.arid,
                    axi_master_read_r_tr.beat_index,
                    prior_exclusive_success.name(),
                    axi_master_read_r_tr.rresp.name(),
                    ctx.exclusive_seen_okay,
                    ctx.exclusive_seen_exokay,
                    ctx.transaction.arlock, $time),
                {"one exclusive read burst uses at most one successful response class: ",
                 "OKAY or EXOKAY; SLVERR/DECERR may coexist with that class"},
                "REPORT_ONLY",
                {"Both OKAY and EXOKAY were accepted in one ARLOCK=1 burst; ",
                 "error responses do not cause this rule"}))
            ctx.exclusive_success_mix_reported = 1'b1;
        end
        if (axi_master_read_r_tr.rlast && ctx.rdata_q.size() != ctx.transaction.arlen + 1) begin
            `uvm_error("AXI_MON", axi_diag::format(
                "RLAST_ON_WRONG_BEAT", "AXI_READ_MONITOR", "R",
                "HANDSHAKE_CHECK",
                $sformatf("RID=0x%0h RLAST=%0b actual_beat_count=%0d expected_beat_count=%0d ARLEN=%0d time=%0t",
                    axi_master_read_r_tr.rid, axi_master_read_r_tr.rlast,
                    ctx.rdata_q.size(), ctx.transaction.arlen + 1,
                    ctx.transaction.arlen, $time),
                "RLAST=1 exactly when accepted beat_count=ARLEN+1",
                "REPORT_ONLY", "RLAST terminated the read burst on the wrong beat"))
        end
        else if (!axi_master_read_r_tr.rlast && ctx.rdata_q.size() >= ctx.transaction.arlen + 1) begin
            `uvm_error("AXI_MON", axi_diag::format(
                "RLAST_MISSING_ON_FINAL_BEAT", "AXI_READ_MONITOR", "R",
                "HANDSHAKE_CHECK",
                $sformatf("RID=0x%0h RLAST=%0b actual_beat_count=%0d expected_beat_count=%0d ARLEN=%0d time=%0t",
                    axi_master_read_r_tr.rid, axi_master_read_r_tr.rlast,
                    ctx.rdata_q.size(), ctx.transaction.arlen + 1,
                    ctx.transaction.arlen, $time),
                "RLAST=1 on accepted beat number ARLEN+1",
                "REPORT_ONLY", "Expected final R beat handshook without RLAST"))
        end
    end

    if (axi_master_read_r_tr.rlast) begin
        ctx.transaction.rid = axi_master_read_r_tr.rid;
        ctx.transaction.read_done = 1'b1;
        if (cfg.performance_enable && ctx.arvalid_start_cycle_valid) begin
            ctx.transaction.read_transaction_latency_cycles =
                cycle_count - ctx.arvalid_start_cycle;
            ctx.transaction.performance_valid = 1'b1;
        end
        ctx.r_seen = 1'b1;
        vif.sample_outstanding_depth(get_outstanding_depth());
    end
endtask : sample_r_phase

function int axi_read_monitor::find_oldest_same_id_context_index(bit [ID_WIDTH-1:0] rid);
    // Same-ID read responses must retire in AR acceptance order. Return the
    // oldest outstanding transaction for this RID.
    for (int i = 0; i < context_q.size(); i++) begin
        if (context_q[i].ar_seen &&
            !context_q[i].r_seen &&
            context_q[i].transaction.arid == rid) begin
            return i;
        end
    end
    return -1;
endfunction : find_oldest_same_id_context_index

function int axi_read_monitor::find_r_context_index(bit [ID_WIDTH-1:0] rid);
    return find_oldest_same_id_context_index(rid);
endfunction : find_r_context_index

function int unsigned axi_read_monitor::get_outstanding_depth();
    int unsigned depth;

    depth = 0;
    for (int i = 0; i < context_q.size(); i++) begin
        if (context_q[i].ar_seen && !context_q[i].r_seen) begin
            depth++;
        end
    end

    return depth;
endfunction : get_outstanding_depth

function int unsigned axi_read_monitor::get_visible_r_beat_index(bit [ID_WIDTH-1:0] rid);
    int ctx_idx;

    ctx_idx = find_r_context_index(rid);
    if (ctx_idx >= 0) begin
        return context_q[ctx_idx].rdata_q.size();
    end

    return r_valid_beat_index;
endfunction : get_visible_r_beat_index

task axi_read_monitor::publish_complete_transactions();
    int unsigned i;
    context_t ctx;

    // Publish only when AR and the RLAST beat are collected.
    i = 0;
    while (i < context_q.size()) begin
        ctx = context_q[i];
        if (ctx.ar_seen && ctx.r_seen) begin
            ctx.transaction.rdata = new[ctx.rdata_q.size()];
            ctx.transaction.rresp = new[ctx.rresp_q.size()];
            ctx.transaction.ruser = new[ctx.ruser_q.size()];
            ctx.transaction.r_handshake_time =
                new[ctx.r_handshake_time_q.size()];
            ctx.transaction.r_inter_beat_bubble_cycles =
                new[ctx.r_inter_beat_bubble_q.size()];

            for (int unsigned j = 0; j < ctx.rdata_q.size(); j++) begin
                ctx.transaction.rdata[j] = ctx.rdata_q[j];
                ctx.transaction.rresp[j] = ctx.rresp_q[j];
                ctx.transaction.ruser[j] = ctx.ruser_q[j];
                ctx.transaction.r_handshake_time[j] =
                    ctx.r_handshake_time_q[j];
            end
            for (int unsigned j = 0;
                 j < ctx.r_inter_beat_bubble_q.size(); j++) begin
                ctx.transaction.r_inter_beat_bubble_cycles[j] =
                    ctx.r_inter_beat_bubble_q[j];
            end

            ctx.transaction.beat_count = ctx.rdata_q.size();
            if (cfg.checks_enable &&
                ctx.transaction.beat_count != ctx.transaction.arlen + 1) begin
                `uvm_error("AXI_MON", axi_diag::format(
                    "READ_COLLECTED_BEAT_COUNT_MISMATCH", "AXI_READ_MONITOR", "R",
                    "TRANSACTION_PUBLISH",
                    $sformatf("ARID=0x%0h RID=0x%0h collected_beats=%0d expected_beats=%0d ARLEN=%0d time=%0t",
                        ctx.transaction.arid, ctx.transaction.rid,
                        ctx.transaction.beat_count,
                        ctx.transaction.arlen + 1,
                        ctx.transaction.arlen, $time),
                    "collected R beats=ARLEN+1 when the RLAST-completed transaction is published",
                    "REPORT_ONLY", "Published read transaction has an inconsistent R beat count"))
            end

            `uvm_info("AXI_MON",
                $sformatf("Transfer collected:\n%s", ctx.transaction.sprint()),
                UVM_FULL)

            print_read_performance(ctx.transaction);
            analysis_port.write(ctx.transaction);
            context_q.delete(i);
        end
        else begin
            i++;
        end
    end
endtask : publish_complete_transactions

`endif
