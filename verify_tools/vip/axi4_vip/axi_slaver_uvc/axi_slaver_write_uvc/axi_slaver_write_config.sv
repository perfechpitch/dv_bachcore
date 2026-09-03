// ============================================================================
// Filename             : axi_slaver_write_config.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : AXI write slaver UVC configuration.
// ============================================================================
`ifndef AXI_SLAVER_WRITE_CONFIG_SV
`define AXI_SLAVER_WRITE_CONFIG_SV
localparam int AXI_SLAVER_WRITE_RESP_DIST_NUM = 4;

typedef enum bit [1:0] {
    AXI_SLAVER_WRITE_BURST_FIXED = 2'b00,
    AXI_SLAVER_WRITE_BURST_INCR  = 2'b01,
    AXI_SLAVER_WRITE_BURST_WRAP  = 2'b10
} axi_slaver_write_burst_e;

typedef enum bit [1:0] {
    AXI_SLAVER_WRITE_RESP_OKAY   = 2'b00,
    AXI_SLAVER_WRITE_RESP_EXOKAY = 2'b01,
    AXI_SLAVER_WRITE_RESP_SLVERR = 2'b10,
    AXI_SLAVER_WRITE_RESP_DECERR = 2'b11
} axi_slaver_write_resp_e;

typedef enum int unsigned {
    AXI_SLAVER_WRITE_DELAY_ZERO,
    AXI_SLAVER_WRITE_DELAY_SHORT,
    AXI_SLAVER_WRITE_DELAY_MID,
    AXI_SLAVER_WRITE_DELAY_LONG,
    AXI_SLAVER_WRITE_DELAY_MAX_VALUE,
    AXI_SLAVER_WRITE_DELAY_FIXED
} axi_slaver_write_delay_type_e;

localparam int AXI_SLAVER_WRITE_DELAY_TYPE_NUM = 5;

class axi_slaver_write_config #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_object;
    typedef axi_slaver_write_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_write_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_write_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_cfg_t;

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    monitor_cfg_t monitor_cfg;

    vif_t axi_slaver_write_vif;

    // Maximum accepted protocol-active writes. Leading AW and leading W share
    // one transaction limit; the matching B handshake retires the entry.
    int unsigned write_outstanding_depth = 16;
    // IN_ORDER with save_req_num=0 is permanent strict head-of-line ordering:
    // the earliest B-ready request must become delay-eligible and same-BID
    // legal before any later request can respond. IN_ORDER with a nonzero
    // save_req_num and REVERSE_ORDER use save_req_num as the one-time
    // post-reset threshold of complete AW+WLAST requests waiting for B. At the
    // first threshold crossing, the Driver freezes all current B-ready
    // requests and their older same-BID AW predecessors, releases only that
    // initial set in the configured order, then uses READY_ORDER permanently
    // until reset. BVALID eligibility delay does not affect threshold
    // counting. For a nonzero threshold, the initiator must be able to make at
    // least save_req_num writes B-ready without first waiting for a B response.
    axi_response_order_e resp_order = AXI_RESP_READY_ORDER;
    int unsigned save_req_num = 0;
    bit addr_range_check_enable = 0;
    bit [ADDR_WIDTH-1:0] write_addr_min = '0;
    bit [ADDR_WIDTH-1:0] write_addr_max = '1;

    // Shared storage and address-segment response source for every write.
    bit memory_clear_on_reset = 1;
    mem_model memory_model;
    bit exclusive_access_enable = 0;

    // Response selection priority is fixed response, memory-model response,
    // then weighted random response. The storage model remains the write-data
    // destination even when use_mem_model is disabled for response selection.
    bit fix_bresp_enable = 0;
    rand axi_slaver_write_resp_e bresp;
    // BUSER defaults to zero and can be fixed to a project-defined response
    // sideband value.
    bit fix_buser_enable = 0;
    rand bit [USER_WIDTH-1:0] buser;
    bit use_mem_model = 0;
    rand int unsigned bresp_dist[];

    axi_ready_mode_e awready_mode = AXI_AFTER_VALID;
    axi_ready_mode_e wready_mode  = AXI_AFTER_VALID;
    // AXI_AFTER_VALID: start this delay when AWVALID is first observed, then keep
    // AWREADY asserted until the AW handshake completes.
    bit fix_awready_delay_enable = 0;
    rand int unsigned awready_delay = 0;
    // AXI_AFTER_VALID: apply this delay only to the first observed WVALID of a
    // burst, then keep WREADY asserted through the WLAST handshake.
    bit fix_wready_delay_enable = 0;
    rand int unsigned wready_delay = 0;
    // Minimum delay from both the AW handshake and complete W burst to the
    // first cycle on which the matching BVALID may be asserted.
    bit fix_b_delay_enable = 0;
    rand int unsigned b_delay = 0;

    rand int unsigned awready_delay_type_dist[];
    rand int unsigned wready_delay_type_dist[];
    rand int unsigned b_delay_dist[];

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_enum      (uvm_active_passive_enum, is_active, UVM_DEFAULT)
        `uvm_field_object    (monitor_cfg, UVM_DEFAULT)
        `uvm_field_int       (write_outstanding_depth, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum      (axi_response_order_e, resp_order, UVM_DEFAULT)
        `uvm_field_int       (save_req_num, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (addr_range_check_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (write_addr_min, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (write_addr_max, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (memory_clear_on_reset, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (exclusive_access_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (fix_bresp_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum      (axi_slaver_write_resp_e, bresp, UVM_DEFAULT)
        `uvm_field_int       (fix_buser_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (buser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (use_mem_model, UVM_DEFAULT | UVM_BIN)
        `uvm_field_array_int (bresp_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum      (axi_ready_mode_e, awready_mode, UVM_DEFAULT)
        `uvm_field_enum      (axi_ready_mode_e, wready_mode, UVM_DEFAULT)
        `uvm_field_int       (fix_awready_delay_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (awready_delay, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (fix_wready_delay_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (wready_delay, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (fix_b_delay_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (b_delay, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int (awready_delay_type_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int (wready_delay_type_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int (b_delay_dist, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_write_config");
        super.new(name);
        monitor_cfg = monitor_cfg_t::type_id::create(
            {name, "_monitor_cfg"});
        if (monitor_cfg == null) begin
            `uvm_fatal("AXI_CFG", "Failed to create Slaver Write monitor cfg")
        end
        if (!is_valid_id_width(ID_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "ID_WIDTH must be >= 1")
        end
        if (!is_valid_addr_width(ADDR_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "ADDR_WIDTH must be >= 12")
        end
        if (!is_valid_data_width(DATA_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "DATA_WIDTH must be byte-aligned in [16:1024] and DATA_WIDTH/8 must be a power of two")
        end
        if (!is_valid_user_width(USER_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "USER_WIDTH must be >= 1")
        end
        if (!is_valid_max_beats(AXI_SLAVER_WRITE_MAX_BEATS)) begin
            `uvm_fatal("AXI_CFG", "AXI_SLAVER_WRITE_MAX_BEATS must be in [16:256]")
        end

        buser = '0;

        bresp_dist              = new[AXI_SLAVER_WRITE_RESP_DIST_NUM];
        awready_delay_type_dist = new[AXI_SLAVER_WRITE_DELAY_TYPE_NUM];
        wready_delay_type_dist  = new[AXI_SLAVER_WRITE_DELAY_TYPE_NUM];
        b_delay_dist            = new[AXI_SLAVER_WRITE_DELAY_TYPE_NUM];

        bresp_dist              = '{25, 25, 25, 25};
        awready_delay_type_dist = '{20, 20, 20, 20, 20};
        wready_delay_type_dist  = '{20, 20, 20, 20, 20};
        b_delay_dist            = '{20, 20, 20, 20, 20};
    endfunction : new

    protected function bit parse_unsigned_enum_value(
        string       raw_value,
        output int unsigned enum_value
    );
        longint unsigned parsed_value;
        int unsigned     digit;
        byte unsigned    character;

        enum_value = 0;
        parsed_value = 0;
        if (raw_value.len() == 0) begin
            return 1'b0;
        end
        for (int i = 0; i < raw_value.len(); i++) begin
            character = raw_value.getc(i);
            if (character < 8'h30 || character > 8'h39) begin
                return 1'b0;
            end
            digit = character - 8'h30;
            if (parsed_value > ((64'h0000_0000_ffff_ffff - digit) / 10)) begin
                return 1'b0;
            end
            parsed_value = (parsed_value * 10) + digit;
        end
        enum_value = parsed_value;
        return 1'b1;
    endfunction : parse_unsigned_enum_value

    protected function void get_bounded_uint_arg(
        axi_cfg_plusarg_parser    parser,
        string                    key,
        string                    scope,
        axi_cfg_validation_report report,
        longint unsigned          minimum,
        longint unsigned          maximum,
        string                    reason,
        ref int unsigned          destination
    );
        longint unsigned parsed_value;

        if (parser.get_uint(key, scope, report, parsed_value)) begin
            if (parsed_value < minimum || parsed_value > maximum) begin
                report.invalid(scope, $sformatf(
                    "key=%s actual=%0d expected_range=[%0d:%0d]",
                    key, parsed_value, minimum, maximum), reason);
            end
            else begin
                destination = parsed_value;
            end
        end
    endfunction : get_bounded_uint_arg

    // Apply command-line overrides after Test-owned assignments and before
    // validate_and_freeze(). Prefixes are instance-specific (for example,
    // SW_0), so one process can configure every Slaver Write endpoint without
    // key collisions. Handles, interface parameters and array sizes are not
    // command-line configuration.
    function bit get_args(
        string                    prefix,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report
    );
        int unsigned     errors_before;
        string           scope;
        string           key;
        string           raw_value;
        string           normalized_value;
        int unsigned     enum_value;
        bit              bit_value;
        uvm_bitstream_t  hex_value;

        if (parser == null || report == null) begin
            `uvm_error("AXI_CFG_PLUSARG",
                "Slaver Write get_args requires non-null parser and report")
            return 1'b0;
        end

        errors_before = report.error_count;
        scope = $sformatf("%s.plusargs[%s]", get_full_name(), prefix);
        if (prefix.len() == 0) begin
            report.invalid(scope, "actual_prefix=empty expected=non-empty",
                "SLAVE_WRITE_PLUSARG_PREFIX_EMPTY");
            return 1'b0;
        end

        key = {prefix, "_IS_ACTIVE"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value inside {"UVM_PASSIVE", "PASSIVE"}) begin
                is_active = UVM_PASSIVE;
            end
            else if (normalized_value inside {"UVM_ACTIVE", "ACTIVE"}) begin
                is_active = UVM_ACTIVE;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {int'(UVM_PASSIVE), int'(UVM_ACTIVE)}) begin
                is_active = uvm_active_passive_enum'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    "key=%s actual=%s expected={UVM_PASSIVE,UVM_ACTIVE,0,1}",
                    key, raw_value), "SLAVE_WRITE_PLUSARG_ACTIVE_ENUM");
            end
        end

        get_bounded_uint_arg(parser,
            {prefix, "_WRITE_OUTSTANDING_DEPTH"}, scope, report,
            1, 256, "SLAVE_WRITE_PLUSARG_OUTSTANDING_RANGE",
            write_outstanding_depth);

        key = {prefix, "_RESP_ORDER"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value inside {"AXI_RESP_IN_ORDER", "IN_ORDER"}) begin
                resp_order = AXI_RESP_IN_ORDER;
            end
            else if (normalized_value inside {
                    "AXI_RESP_REVERSE_ORDER", "REVERSE_ORDER"}) begin
                resp_order = AXI_RESP_REVERSE_ORDER;
            end
            else if (normalized_value inside {
                    "AXI_RESP_READY_ORDER", "READY_ORDER"}) begin
                resp_order = AXI_RESP_READY_ORDER;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {[0:2]}) begin
                resp_order = axi_response_order_e'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    {"key=%s actual=%s expected={AXI_RESP_IN_ORDER(0),",
                     "AXI_RESP_REVERSE_ORDER(1),AXI_RESP_READY_ORDER(2)}"},
                    key, raw_value), "SLAVE_WRITE_PLUSARG_ORDER_ENUM");
            end
        end
        get_bounded_uint_arg(parser, {prefix, "_SAVE_REQ_NUM"},
            scope, report, 0, 256, "SLAVE_WRITE_PLUSARG_SAVE_RANGE",
            save_req_num);

        if (parser.get_bit({prefix, "_ADDR_RANGE_CHECK_ENABLE"},
                scope, report, bit_value)) begin
            addr_range_check_enable = bit_value;
        end
        if (parser.get_hex({prefix, "_WRITE_ADDR_MIN"}, scope, report,
                ADDR_WIDTH, hex_value)) begin
            write_addr_min = hex_value;
        end
        if (parser.get_hex({prefix, "_WRITE_ADDR_MAX"}, scope, report,
                ADDR_WIDTH, hex_value)) begin
            write_addr_max = hex_value;
        end
        if (parser.get_bit({prefix, "_MEMORY_CLEAR_ON_RESET"},
                scope, report, bit_value)) begin
            memory_clear_on_reset = bit_value;
        end
        if (parser.get_bit({prefix, "_EXCLUSIVE_ACCESS_ENABLE"},
                scope, report, bit_value)) begin
            exclusive_access_enable = bit_value;
        end

        if (parser.get_bit({prefix, "_FIX_BRESP_EN"},
                scope, report, bit_value)) begin
            fix_bresp_enable = bit_value;
        end
        key = {prefix, "_BRESP"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value inside {
                    "AXI_SLAVER_WRITE_RESP_OKAY", "OKAY"}) begin
                bresp = AXI_SLAVER_WRITE_RESP_OKAY;
            end
            else if (normalized_value inside {
                    "AXI_SLAVER_WRITE_RESP_EXOKAY", "EXOKAY"}) begin
                bresp = AXI_SLAVER_WRITE_RESP_EXOKAY;
            end
            else if (normalized_value inside {
                    "AXI_SLAVER_WRITE_RESP_SLVERR", "SLVERR"}) begin
                bresp = AXI_SLAVER_WRITE_RESP_SLVERR;
            end
            else if (normalized_value inside {
                    "AXI_SLAVER_WRITE_RESP_DECERR", "DECERR"}) begin
                bresp = AXI_SLAVER_WRITE_RESP_DECERR;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {[0:3]}) begin
                bresp = axi_slaver_write_resp_e'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    {"key=%s actual=%s expected={OKAY(0),EXOKAY(1),",
                     "SLVERR(2),DECERR(3)}"}, key, raw_value),
                    "SLAVE_WRITE_PLUSARG_BRESP_ENUM");
            end
        end
        if (parser.get_bit({prefix, "_FIX_BUSER_EN"},
                scope, report, bit_value)) begin
            fix_buser_enable = bit_value;
        end
        if (parser.get_hex({prefix, "_BUSER"}, scope, report,
                USER_WIDTH, hex_value)) begin
            buser = hex_value;
        end
        if (parser.get_bit({prefix, "_USE_MEM_MODEL"},
                scope, report, bit_value)) begin
            use_mem_model = bit_value;
        end
        foreach (bresp_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_BRESP_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_WRITE_PLUSARG_BRESP_DIST_RANGE", bresp_dist[i]);
        end

        key = {prefix, "_AWREADY_MODE"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value == "AXI_ALWAYS_HIGH") begin
                awready_mode = AXI_ALWAYS_HIGH;
            end
            else if (normalized_value == "AXI_AFTER_VALID") begin
                awready_mode = AXI_AFTER_VALID;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {[0:1]}) begin
                awready_mode = axi_ready_mode_e'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    "key=%s actual=%s expected={AXI_ALWAYS_HIGH(0),AXI_AFTER_VALID(1)}",
                    key, raw_value), "SLAVE_WRITE_PLUSARG_AWREADY_ENUM");
            end
        end

        key = {prefix, "_WREADY_MODE"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value == "AXI_ALWAYS_HIGH") begin
                wready_mode = AXI_ALWAYS_HIGH;
            end
            else if (normalized_value == "AXI_AFTER_VALID") begin
                wready_mode = AXI_AFTER_VALID;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {[0:1]}) begin
                wready_mode = axi_ready_mode_e'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    "key=%s actual=%s expected={AXI_ALWAYS_HIGH(0),AXI_AFTER_VALID(1)}",
                    key, raw_value), "SLAVE_WRITE_PLUSARG_WREADY_ENUM");
            end
        end

        if (parser.get_bit({prefix, "_FIX_AWREADY_DELAY_EN"},
                scope, report, bit_value)) begin
            fix_awready_delay_enable = bit_value;
        end
        get_bounded_uint_arg(parser, {prefix, "_AWREADY_DELAY"},
            scope, report, 0, 63, "SLAVE_WRITE_PLUSARG_AWREADY_DELAY_RANGE",
            awready_delay);
        if (parser.get_bit({prefix, "_FIX_WREADY_DELAY_EN"},
                scope, report, bit_value)) begin
            fix_wready_delay_enable = bit_value;
        end
        get_bounded_uint_arg(parser, {prefix, "_WREADY_DELAY"},
            scope, report, 0, 63, "SLAVE_WRITE_PLUSARG_WREADY_DELAY_RANGE",
            wready_delay);
        if (parser.get_bit({prefix, "_FIX_B_DELAY_EN"},
                scope, report, bit_value)) begin
            fix_b_delay_enable = bit_value;
        end
        get_bounded_uint_arg(parser, {prefix, "_B_DELAY"},
            scope, report, 0, 63, "SLAVE_WRITE_PLUSARG_B_DELAY_RANGE",
            b_delay);

        foreach (awready_delay_type_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_AWREADY_DELAY_TYPE_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_WRITE_PLUSARG_AWREADY_DIST_RANGE",
                awready_delay_type_dist[i]);
        end
        foreach (wready_delay_type_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_WREADY_DELAY_TYPE_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_WRITE_PLUSARG_WREADY_DIST_RANGE",
                wready_delay_type_dist[i]);
        end
        foreach (b_delay_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_B_DELAY_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_WRITE_PLUSARG_B_DELAY_DIST_RANGE", b_delay_dist[i]);
        end

        if (monitor_cfg == null) begin
            report.invalid(scope,
                "actual_monitor_cfg=null expected=non-null",
                "SLAVE_WRITE_PLUSARG_MONITOR_CFG_NULL");
        end
        else begin
            monitor_cfg.get_args(prefix, parser, report);
        end

        get_args = report.error_count == errors_before;
    endfunction : get_args

    // Generate one random scalar candidate for every optional fixed field.
    // Configure-hook assignments run afterward and therefore take priority.
    function bit randomize_fixed_value_defaults();
        string saved_randstate;
        bit saved_fix_awready_delay_enable;
        bit saved_fix_wready_delay_enable;
        bit saved_fix_b_delay_enable;
        bit saved_fix_bresp_enable;
        bit saved_fix_buser_enable;

        saved_randstate = this.get_randstate();
        saved_fix_awready_delay_enable = fix_awready_delay_enable;
        saved_fix_wready_delay_enable = fix_wready_delay_enable;
        saved_fix_b_delay_enable = fix_b_delay_enable;
        saved_fix_bresp_enable = fix_bresp_enable;
        saved_fix_buser_enable = fix_buser_enable;

        fix_awready_delay_enable = 1'b1;
        fix_wready_delay_enable = 1'b1;
        fix_b_delay_enable = 1'b1;
        fix_bresp_enable = 1'b1;
        fix_buser_enable = 1'b1;

        randomize_fixed_value_defaults = this.randomize(
            awready_delay,
            wready_delay,
            b_delay,
            bresp,
            buser
        ) with {
            // EXOKAY requires an explicitly configured Exclusive policy.
            // Enabling only fix_bresp_enable must remain a legal baseline.
            bresp != AXI_SLAVER_WRITE_RESP_EXOKAY;
        };
        this.set_randstate(saved_randstate);

        fix_awready_delay_enable = saved_fix_awready_delay_enable;
        fix_wready_delay_enable = saved_fix_wready_delay_enable;
        fix_b_delay_enable = saved_fix_b_delay_enable;
        fix_bresp_enable = saved_fix_bresp_enable;
        fix_buser_enable = saved_fix_buser_enable;
    endfunction : randomize_fixed_value_defaults

    function bit validate_cfg(
        axi_cfg_validation_report report,
        string                    scope
    );
        int unsigned errors_before;

        errors_before = report.error_count;

        if (!(write_outstanding_depth inside {[1:256]}))
            report.invalid(scope, $sformatf(
                "actual_write_outstanding_depth=%0d expected_range=[1:256]",
                write_outstanding_depth), "SLAVE_WRITE_OUTSTANDING_DEPTH_RANGE");
        if (!(is_active inside {UVM_ACTIVE, UVM_PASSIVE}))
            report.invalid(scope, $sformatf(
                "actual_is_active=%0d expected={UVM_ACTIVE,UVM_PASSIVE}",
                is_active), "SLAVE_WRITE_ACTIVE_MODE");
        if (addr_range_check_enable && write_addr_min > write_addr_max)
            report.conflict(scope, $sformatf(
                "actual_addr_range=[0x%0h:0x%0h] expected_min<=max",
                write_addr_min, write_addr_max), "SLAVE_WRITE_ADDR_RANGE_ORDER");
        if (is_active == UVM_PASSIVE) begin
            validate_cfg = report.error_count == errors_before;
            return validate_cfg;
        end

        case (resp_order)
            AXI_RESP_READY_ORDER: begin
                if (save_req_num != 0) begin
                    report.conflict(scope, $sformatf(
                        "resp_order=READY_ORDER actual_save_req_num=%0d expected=0",
                        save_req_num), "SLAVE_WRITE_READY_ORDER_SAVE_DEPTH");
                end
            end

            AXI_RESP_IN_ORDER: begin
                if (save_req_num > write_outstanding_depth) begin
                    report.conflict(scope, $sformatf(
                        {"resp_order=IN_ORDER actual_save_req_num=%0d ",
                         "expected_save_req_num=0(permanent_strict_order) ",
                         "or [1:%0d](one_time_accumulation)"},
                        save_req_num, write_outstanding_depth),
                        "SLAVE_WRITE_IN_ORDER_SAVE_DEPTH");
                end
            end

            AXI_RESP_REVERSE_ORDER: begin
                if (write_outstanding_depth < 2 ||
                    save_req_num < 2 ||
                    save_req_num > write_outstanding_depth) begin
                    report.conflict(scope, $sformatf(
                        {"resp_order=REVERSE_ORDER actual_save_req_num=%0d ",
                         "actual_outstanding_depth=%0d expected_save_range=[2:%0d]"},
                        save_req_num, write_outstanding_depth,
                        write_outstanding_depth),
                        "SLAVE_WRITE_REVERSE_ORDER_SAVE_DEPTH");
                end
            end

            default: begin
                report.invalid(scope, $sformatf(
                    "actual_resp_order=%0d expected={IN_ORDER,REVERSE_ORDER,READY_ORDER}",
                    int'(resp_order)), "SLAVE_WRITE_RESPONSE_ORDER");
            end
        endcase

        if (is_active == UVM_ACTIVE && memory_model == null) begin
            report.invalid(scope,
                "is_active=UVM_ACTIVE actual_memory_model=null expected=non-null for BRESP/write storage",
                "SLAVE_WRITE_MEM_MODEL_NULL");
        end

        if (!fix_bresp_enable && !use_mem_model)
            void'(report.check_dist(scope, "bresp_dist",
                bresp_dist, AXI_SLAVER_WRITE_RESP_DIST_NUM));
        if (fix_bresp_enable && !(bresp inside {
                AXI_SLAVER_WRITE_RESP_OKAY,
                AXI_SLAVER_WRITE_RESP_EXOKAY,
                AXI_SLAVER_WRITE_RESP_SLVERR,
                AXI_SLAVER_WRITE_RESP_DECERR}))
            report.invalid(scope, $sformatf(
                "actual_fixed_bresp=%0d expected={OKAY,EXOKAY,SLVERR,DECERR}",
                bresp), "SLAVE_WRITE_FIXED_BRESP_ENCODING");
        if (fix_bresp_enable &&
            bresp == AXI_SLAVER_WRITE_RESP_EXOKAY &&
            !exclusive_access_enable) begin
            report.conflict(scope,
                {"actual_fixed_bresp=EXOKAY exclusive_access_enable=0 ",
                 "expected=enable_exclusive_support_or_choose_OKAY_SLVERR_DECERR"},
                "SLAVE_WRITE_FIXED_EXOKAY_REQUIRES_EXCLUSIVE");
        end

        if (!(awready_mode inside {
                AXI_ALWAYS_HIGH,
                AXI_AFTER_VALID})) begin
            report.invalid(scope, $sformatf(
                "actual_awready_mode=%0d expected={AXI_ALWAYS_HIGH,AXI_AFTER_VALID}",
                awready_mode), "SLAVE_WRITE_AWREADY_MODE");
        end
        else if (awready_mode == AXI_ALWAYS_HIGH) begin
            if (fix_awready_delay_enable && awready_delay != 0)
                report.conflict(scope, $sformatf(
                    "awready_mode=AXI_ALWAYS_HIGH actual_fixed_awready_delay=%0d expected=0",
                    awready_delay), "SLAVE_WRITE_AWREADY_DELAY_MODE_CONFLICT");
        end
        else if (fix_awready_delay_enable) begin
            if (awready_delay > 63)
                report.invalid(scope, $sformatf(
                    "actual_fixed_awready_delay=%0d expected_range=[0:63]",
                    awready_delay), "SLAVE_WRITE_AWREADY_DELAY_RANGE");
        end
        else begin
            void'(report.check_dist(scope, "awready_delay_type_dist",
                awready_delay_type_dist, AXI_SLAVER_WRITE_DELAY_TYPE_NUM));
        end

        if (!(wready_mode inside {
                AXI_ALWAYS_HIGH,
                AXI_AFTER_VALID})) begin
            report.invalid(scope, $sformatf(
                "actual_wready_mode=%0d expected={AXI_ALWAYS_HIGH,AXI_AFTER_VALID}",
                wready_mode), "SLAVE_WRITE_WREADY_MODE");
        end
        else if (wready_mode == AXI_ALWAYS_HIGH) begin
            if (fix_wready_delay_enable && wready_delay != 0)
                report.conflict(scope, $sformatf(
                    "wready_mode=AXI_ALWAYS_HIGH actual_fixed_wready_delay=%0d expected=0",
                    wready_delay), "SLAVE_WRITE_WREADY_DELAY_MODE_CONFLICT");
        end
        else if (fix_wready_delay_enable) begin
            if (wready_delay > 63)
                report.invalid(scope, $sformatf(
                    "actual_fixed_wready_delay=%0d expected_range=[0:63]",
                    wready_delay), "SLAVE_WRITE_WREADY_DELAY_RANGE");
        end
        else begin
            void'(report.check_dist(scope, "wready_delay_type_dist",
                wready_delay_type_dist, AXI_SLAVER_WRITE_DELAY_TYPE_NUM));
        end

        if (fix_b_delay_enable) begin
            if (b_delay > 63)
                report.invalid(scope, $sformatf(
                    "actual_fixed_b_delay=%0d expected_range=[0:63]",
                    b_delay), "SLAVE_WRITE_B_DELAY_RANGE");
        end else
            void'(report.check_dist(scope, "b_delay_dist",
                b_delay_dist, AXI_SLAVER_WRITE_DELAY_TYPE_NUM));

        validate_cfg = report.error_count == errors_before;
    endfunction : validate_cfg

    constraint delay_dist_c {
        if (awready_mode == AXI_AFTER_VALID &&
            !fix_awready_delay_enable) {
            awready_delay_type_dist.size() == AXI_SLAVER_WRITE_DELAY_TYPE_NUM;
            awready_delay_type_dist.sum == 100;
            foreach (awready_delay_type_dist[i]) awready_delay_type_dist[i] inside {[0:100]};
        }
        if (wready_mode == AXI_AFTER_VALID &&
            !fix_wready_delay_enable) {
            wready_delay_type_dist.size() == AXI_SLAVER_WRITE_DELAY_TYPE_NUM;
            wready_delay_type_dist.sum == 100;
            foreach (wready_delay_type_dist[i]) wready_delay_type_dist[i] inside {[0:100]};
        }
        if (!fix_b_delay_enable) {
            b_delay_dist.size() == AXI_SLAVER_WRITE_DELAY_TYPE_NUM;
            b_delay_dist.sum == 100;
            foreach (b_delay_dist[i]) b_delay_dist[i] inside {[0:100]};
        }
    }

    constraint resp_dist_c {
        if (!fix_bresp_enable && !use_mem_model) {
            bresp_dist.size() == AXI_SLAVER_WRITE_RESP_DIST_NUM;
            bresp_dist.sum == 100;
            foreach (bresp_dist[i]) bresp_dist[i] inside {[0:100]};
        }
    }

    constraint enable_value_c {
        write_outstanding_depth inside {[1:256]};
        save_req_num inside {[0:256]};
        save_req_num <= write_outstanding_depth;
        addr_range_check_enable inside {0, 1};
        write_addr_min <= write_addr_max;
        memory_clear_on_reset inside {0, 1};
        exclusive_access_enable inside {0, 1};
        fix_bresp_enable inside {0, 1};
        fix_buser_enable inside {0, 1};
        use_mem_model inside {0, 1};
        fix_awready_delay_enable inside {0, 1};
        fix_wready_delay_enable inside {0, 1};
        fix_b_delay_enable inside {0, 1};
        awready_delay inside {[0:63]};
        wready_delay inside {[0:63]};
        b_delay inside {[0:63]};
    }
endclass : axi_slaver_write_config
`endif
