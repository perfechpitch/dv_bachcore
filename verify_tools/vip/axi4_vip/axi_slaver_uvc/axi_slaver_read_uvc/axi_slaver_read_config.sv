// ============================================================================
// Filename             : axi_slaver_read_config.sv
// Author               : kippy xyz
// Created On           : 2026-07-08
// Last Modified        :
// Update Count         :
// Description          : AXI read slaver UVC configuration.
// ============================================================================
`ifndef AXI_SLAVER_READ_CONFIG_SV
`define AXI_SLAVER_READ_CONFIG_SV
localparam int AXI_SLAVER_READ_RESP_DIST_NUM = 4;
localparam int AXI_SLAVER_READ_RDATA_DIST_NUM = 3;

typedef enum bit [1:0] {
    AXI_SLAVER_READ_BURST_FIXED = 2'b00,
    AXI_SLAVER_READ_BURST_INCR  = 2'b01,
    AXI_SLAVER_READ_BURST_WRAP  = 2'b10
} axi_slaver_read_burst_e;

typedef enum bit [1:0] {
    AXI_SLAVER_READ_RESP_OKAY   = 2'b00,
    AXI_SLAVER_READ_RESP_EXOKAY = 2'b01,
    AXI_SLAVER_READ_RESP_SLVERR = 2'b10,
    AXI_SLAVER_READ_RESP_DECERR = 2'b11
} axi_slaver_read_resp_e;

typedef enum int unsigned {
    AXI_SLAVER_READ_DELAY_ZERO,
    AXI_SLAVER_READ_DELAY_SHORT,
    AXI_SLAVER_READ_DELAY_MID,
    AXI_SLAVER_READ_DELAY_LONG,
    AXI_SLAVER_READ_DELAY_MAX_VALUE,
    AXI_SLAVER_READ_DELAY_FIXED
} axi_slaver_read_delay_type_e;

localparam int AXI_SLAVER_READ_DELAY_TYPE_NUM = 5;

class axi_slaver_read_config #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends uvm_object;
    typedef axi_slaver_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_read_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_read_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_cfg_t;

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    monitor_cfg_t monitor_cfg;

    vif_t axi_slaver_read_vif;

    // Maximum accepted reads from AR handshake through final R handshake.
    int unsigned read_outstanding_depth = 16;
    // IN_ORDER with save_req_num=0 never accumulates requests: it permanently
    // checks only the oldest pending AR and cannot bypass it while that
    // request's ar_r_delay is still running. IN_ORDER with save_req_num>0 and
    // REVERSE_ORDER accumulate save_req_num accepted AR requests once per
    // reset epoch, freeze that initial request set, and release it in the
    // configured order. Later AR requests wait outside the frozen set; after
    // its final RLAST handshake all remaining responses use READY_ORDER until
    // reset. READY_ORDER starts immediately and requires save_req_num=0.
    // A finite threshold-based epoch that never reaches save_req_num cannot
    // respond. The initiator must therefore be able to complete at least
    // save_req_num AR handshakes without first waiting for an R response.
    axi_response_order_e resp_order = AXI_RESP_READY_ORDER;
    int unsigned save_req_num = 0;
    bit addr_range_check_enable = 0;
    bit [ADDR_WIDTH-1:0] read_addr_min = '0;
    bit [ADDR_WIDTH-1:0] read_addr_max = '1;

    // This shared byte-addressable storage model supplies memory-backed
    // RDATA and the bytes displayed on inactive lanes.
    mem_model memory_model;
    bit memory_error_on_uninitialized_read = 1;
    bit exclusive_access_enable = 0;

    // Effective-lane RDATA source priority is fixed value, captured ARUSER,
    // memory model, then weighted random data.  fix_rdata_enable and
    // rdata_from_aruser_enable are mutually exclusive explicit overrides;
    // validate_cfg reports their conflict instead of hiding it in a random
    // constraint.  rdata_dist weights {ZERO, MIDDLE, ALL_ONES} and is used
    // only when neither override nor the memory model source is selected.
    bit fix_rdata_enable = 0;
    rand bit [DATA_WIDTH-1:0] rdata;
    bit rdata_from_aruser_enable = 0;
    rand int unsigned rdata_dist[];

    // RRESP selection priority is fixed response, memory-model response,
    // then weighted random response.  RDATA follows the independent source
    // priority above; the model handle remains required for inactive lanes.
    bit fix_rresp_enable = 0;
    rand axi_slaver_read_resp_e rresp;
    bit use_mem_model = 0;
    rand int unsigned rresp_dist[];

    axi_ready_mode_e arready_mode = AXI_AFTER_VALID;
    // In AXI_AFTER_VALID mode, wait this many full cycles after first observing
    // ARVALID before asserting ARREADY. AXI_ALWAYS_HIGH ignores this value.
    bit fix_arready_delay_enable = 0;
    rand int unsigned arready_delay = 0;

    // Minimum delay from the matching AR handshake to the first RVALID issue.
    // Arbitration and an earlier active R burst may delay it further.
    bit fix_ar_r_delay_enable = 0;
    rand int unsigned ar_r_delay = 0;
    // Delay between two adjacent R beats in one burst. Every non-last beat
    // boundary selects its own value in random mode.
    bit fix_r_delay_enable = 0;
    rand int unsigned r_delay = 0;

    bit fix_ruser_enable = 0;
    rand bit [USER_WIDTH-1:0] ruser;

    rand int unsigned arready_delay_type_dist[];
    rand int unsigned ar_r_delay_dist[];
    rand int unsigned r_delay_dist[];

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_enum      (uvm_active_passive_enum, is_active, UVM_DEFAULT)
        `uvm_field_object    (monitor_cfg, UVM_DEFAULT)
        `uvm_field_int       (read_outstanding_depth, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum      (axi_response_order_e, resp_order, UVM_DEFAULT)
        `uvm_field_int       (save_req_num, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (addr_range_check_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (read_addr_min, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (read_addr_max, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (memory_error_on_uninitialized_read, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (exclusive_access_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (fix_rdata_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (rdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (rdata_from_aruser_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_array_int (rdata_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (fix_rresp_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum      (axi_slaver_read_resp_e, rresp, UVM_DEFAULT)
        `uvm_field_int       (use_mem_model, UVM_DEFAULT | UVM_BIN)
        `uvm_field_array_int (rresp_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum      (axi_ready_mode_e, arready_mode, UVM_DEFAULT)
        `uvm_field_int       (fix_arready_delay_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (arready_delay, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (fix_ar_r_delay_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (ar_r_delay, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (fix_r_delay_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (r_delay, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (fix_ruser_enable, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (ruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (arready_delay_type_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int (ar_r_delay_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int (r_delay_dist, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_read_config");
        super.new(name);
        monitor_cfg = monitor_cfg_t::type_id::create(
            {name, "_monitor_cfg"});
        if (monitor_cfg == null) begin
            `uvm_fatal("AXI_CFG", "Failed to create Slaver Read monitor cfg")
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
        if (!is_valid_max_beats(AXI_SLAVER_READ_MAX_BEATS)) begin
            `uvm_fatal("AXI_CFG", "AXI_SLAVER_READ_MAX_BEATS must be in [16:256]")
        end

        ruser = '0;

        rdata_dist = new[AXI_SLAVER_READ_RDATA_DIST_NUM];
        rresp_dist = new[AXI_SLAVER_READ_RESP_DIST_NUM];
        arready_delay_type_dist = new[AXI_SLAVER_READ_DELAY_TYPE_NUM];
        ar_r_delay_dist         = new[AXI_SLAVER_READ_DELAY_TYPE_NUM];
        r_delay_dist            = new[AXI_SLAVER_READ_DELAY_TYPE_NUM];

        rdata_dist              = '{10, 80, 10};
        rresp_dist              = '{25, 25, 25, 25};
        arready_delay_type_dist = '{20, 20, 20, 20, 20};
        ar_r_delay_dist         = '{20, 20, 20, 20, 20};
        r_delay_dist            = '{20, 20, 20, 20, 20};
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
    // SR_0), so one process can configure every Slaver Read endpoint without
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
                "Slaver Read get_args requires non-null parser and report")
            return 1'b0;
        end

        errors_before = report.error_count;
        scope = $sformatf("%s.plusargs[%s]", get_full_name(), prefix);
        if (prefix.len() == 0) begin
            report.invalid(scope, "actual_prefix=empty expected=non-empty",
                "SLAVE_READ_PLUSARG_PREFIX_EMPTY");
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
                    key, raw_value), "SLAVE_READ_PLUSARG_ACTIVE_ENUM");
            end
        end

        get_bounded_uint_arg(parser,
            {prefix, "_READ_OUTSTANDING_DEPTH"}, scope, report,
            1, 256, "SLAVE_READ_PLUSARG_OUTSTANDING_RANGE",
            read_outstanding_depth);

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
                    key, raw_value), "SLAVE_READ_PLUSARG_ORDER_ENUM");
            end
        end
        get_bounded_uint_arg(parser, {prefix, "_SAVE_REQ_NUM"},
            scope, report, 0, 256, "SLAVE_READ_PLUSARG_SAVE_RANGE",
            save_req_num);

        if (parser.get_bit({prefix, "_ADDR_RANGE_CHECK_ENABLE"},
                scope, report, bit_value)) begin
            addr_range_check_enable = bit_value;
        end
        if (parser.get_hex({prefix, "_READ_ADDR_MIN"}, scope, report,
                ADDR_WIDTH, hex_value)) begin
            read_addr_min = hex_value;
        end
        if (parser.get_hex({prefix, "_READ_ADDR_MAX"}, scope, report,
                ADDR_WIDTH, hex_value)) begin
            read_addr_max = hex_value;
        end
        if (parser.get_bit(
                {prefix, "_MEMORY_ERROR_ON_UNINITIALIZED_READ"},
                scope, report, bit_value)) begin
            memory_error_on_uninitialized_read = bit_value;
        end
        if (parser.get_bit({prefix, "_EXCLUSIVE_ACCESS_ENABLE"},
                scope, report, bit_value)) begin
            exclusive_access_enable = bit_value;
        end

        if (parser.get_bit({prefix, "_FIX_RDATA_EN"},
                scope, report, bit_value)) begin
            fix_rdata_enable = bit_value;
        end
        if (parser.get_hex({prefix, "_RDATA"}, scope, report,
                DATA_WIDTH, hex_value)) begin
            rdata = hex_value;
        end
        if (parser.get_bit({prefix, "_RDATA_FROM_ARUSER_EN"},
                scope, report, bit_value)) begin
            rdata_from_aruser_enable = bit_value;
        end
        foreach (rdata_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_RDATA_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_READ_PLUSARG_RDATA_DIST_RANGE", rdata_dist[i]);
        end

        if (parser.get_bit({prefix, "_FIX_RRESP_EN"},
                scope, report, bit_value)) begin
            fix_rresp_enable = bit_value;
        end
        key = {prefix, "_RRESP"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value inside {
                    "AXI_SLAVER_READ_RESP_OKAY", "OKAY"}) begin
                rresp = AXI_SLAVER_READ_RESP_OKAY;
            end
            else if (normalized_value inside {
                    "AXI_SLAVER_READ_RESP_EXOKAY", "EXOKAY"}) begin
                rresp = AXI_SLAVER_READ_RESP_EXOKAY;
            end
            else if (normalized_value inside {
                    "AXI_SLAVER_READ_RESP_SLVERR", "SLVERR"}) begin
                rresp = AXI_SLAVER_READ_RESP_SLVERR;
            end
            else if (normalized_value inside {
                    "AXI_SLAVER_READ_RESP_DECERR", "DECERR"}) begin
                rresp = AXI_SLAVER_READ_RESP_DECERR;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {[0:3]}) begin
                rresp = axi_slaver_read_resp_e'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    {"key=%s actual=%s expected={OKAY(0),EXOKAY(1),",
                     "SLVERR(2),DECERR(3)}"}, key, raw_value),
                    "SLAVE_READ_PLUSARG_RRESP_ENUM");
            end
        end
        if (parser.get_bit({prefix, "_USE_MEM_MODEL"},
                scope, report, bit_value)) begin
            use_mem_model = bit_value;
        end
        foreach (rresp_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_RRESP_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_READ_PLUSARG_RRESP_DIST_RANGE", rresp_dist[i]);
        end

        key = {prefix, "_ARREADY_MODE"};
        if (parser.get_raw(key, scope, report, raw_value)) begin
            normalized_value = raw_value.toupper();
            if (normalized_value == "AXI_ALWAYS_HIGH") begin
                arready_mode = AXI_ALWAYS_HIGH;
            end
            else if (normalized_value == "AXI_AFTER_VALID") begin
                arready_mode = AXI_AFTER_VALID;
            end
            else if (parse_unsigned_enum_value(raw_value, enum_value) &&
                     enum_value inside {[0:1]}) begin
                arready_mode = axi_ready_mode_e'(enum_value);
            end
            else begin
                report.invalid(scope, $sformatf(
                    "key=%s actual=%s expected={AXI_ALWAYS_HIGH(0),AXI_AFTER_VALID(1)}",
                    key, raw_value), "SLAVE_READ_PLUSARG_ARREADY_ENUM");
            end
        end
        if (parser.get_bit({prefix, "_FIX_ARREADY_DELAY_EN"},
                scope, report, bit_value)) begin
            fix_arready_delay_enable = bit_value;
        end
        get_bounded_uint_arg(parser, {prefix, "_ARREADY_DELAY"},
            scope, report, 0, 63, "SLAVE_READ_PLUSARG_ARREADY_DELAY_RANGE",
            arready_delay);
        if (parser.get_bit({prefix, "_FIX_AR_R_DELAY_EN"},
                scope, report, bit_value)) begin
            fix_ar_r_delay_enable = bit_value;
        end
        get_bounded_uint_arg(parser, {prefix, "_AR_R_DELAY"},
            scope, report, 0, 63, "SLAVE_READ_PLUSARG_AR_R_DELAY_RANGE",
            ar_r_delay);
        if (parser.get_bit({prefix, "_FIX_R_DELAY_EN"},
                scope, report, bit_value)) begin
            fix_r_delay_enable = bit_value;
        end
        get_bounded_uint_arg(parser, {prefix, "_R_DELAY"},
            scope, report, 0, 63, "SLAVE_READ_PLUSARG_R_DELAY_RANGE",
            r_delay);
        if (parser.get_bit({prefix, "_FIX_RUSER_EN"},
                scope, report, bit_value)) begin
            fix_ruser_enable = bit_value;
        end
        if (parser.get_hex({prefix, "_RUSER"}, scope, report,
                USER_WIDTH, hex_value)) begin
            ruser = hex_value;
        end

        foreach (arready_delay_type_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_ARREADY_DELAY_TYPE_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_READ_PLUSARG_ARREADY_DIST_RANGE",
                arready_delay_type_dist[i]);
        end
        foreach (ar_r_delay_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_AR_R_DELAY_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_READ_PLUSARG_AR_R_DIST_RANGE", ar_r_delay_dist[i]);
        end
        foreach (r_delay_dist[i]) begin
            get_bounded_uint_arg(parser,
                $sformatf("%s_R_DELAY_DIST_%0d", prefix, i),
                scope, report, 0, 100,
                "SLAVE_READ_PLUSARG_R_DELAY_DIST_RANGE", r_delay_dist[i]);
        end

        if (monitor_cfg == null) begin
            report.invalid(scope,
                "actual_monitor_cfg=null expected=non-null",
                "SLAVE_READ_PLUSARG_MONITOR_CFG_NULL");
        end
        else begin
            monitor_cfg.get_args(prefix, parser, report);
        end

        get_args = report.error_count == errors_before;
    endfunction : get_args

    // Generate one random scalar candidate for every optional fixed field.
    // axi_multi_env_config calls this when the cfg graph is created, so later
    // project assignments still override these defaults, including zero.
    function bit randomize_fixed_value_defaults();
        string saved_randstate;
        bit saved_fix_arready_delay_enable;
        bit saved_fix_ar_r_delay_enable;
        bit saved_fix_r_delay_enable;
        bit saved_fix_ruser_enable;
        bit saved_fix_rresp_enable;
        bit saved_fix_rdata_enable;

        saved_randstate = this.get_randstate();
        saved_fix_arready_delay_enable = fix_arready_delay_enable;
        saved_fix_ar_r_delay_enable = fix_ar_r_delay_enable;
        saved_fix_r_delay_enable = fix_r_delay_enable;
        saved_fix_ruser_enable = fix_ruser_enable;
        saved_fix_rresp_enable = fix_rresp_enable;
        saved_fix_rdata_enable = fix_rdata_enable;

        fix_arready_delay_enable = 1'b1;
        fix_ar_r_delay_enable = 1'b1;
        fix_r_delay_enable = 1'b1;
        fix_ruser_enable = 1'b1;
        fix_rresp_enable = 1'b1;
        fix_rdata_enable = 1'b1;

        randomize_fixed_value_defaults = this.randomize(
            arready_delay,
            ar_r_delay,
            r_delay,
            ruser,
            rresp,
            rdata
        ) with {
            // A user who later enables only fix_rresp_enable gets a response that
            // is legal without also enabling/configuring Exclusive support.
            rresp != AXI_SLAVER_READ_RESP_EXOKAY;
        };
        this.set_randstate(saved_randstate);

        fix_arready_delay_enable = saved_fix_arready_delay_enable;
        fix_ar_r_delay_enable = saved_fix_ar_r_delay_enable;
        fix_r_delay_enable = saved_fix_r_delay_enable;
        fix_ruser_enable = saved_fix_ruser_enable;
        fix_rresp_enable = saved_fix_rresp_enable;
        fix_rdata_enable = saved_fix_rdata_enable;
    endfunction : randomize_fixed_value_defaults

    function bit validate_cfg(
        axi_cfg_validation_report report,
        string                    scope
    );
        int unsigned errors_before;

        errors_before = report.error_count;

        if (!(read_outstanding_depth inside {[1:256]}))
            report.invalid(scope, $sformatf(
                "actual_read_outstanding_depth=%0d expected_range=[1:256]",
                read_outstanding_depth), "SLAVE_READ_OUTSTANDING_DEPTH_RANGE");
        if (!(is_active inside {UVM_ACTIVE, UVM_PASSIVE}))
            report.invalid(scope, $sformatf(
                "actual_is_active=%0d expected={UVM_ACTIVE,UVM_PASSIVE}",
                is_active), "SLAVE_READ_ACTIVE_MODE");
        if (addr_range_check_enable && read_addr_min > read_addr_max)
            report.conflict(scope, $sformatf(
                "actual_addr_range=[0x%0h:0x%0h] expected_min<=max",
                read_addr_min, read_addr_max), "SLAVE_READ_ADDR_RANGE_ORDER");
        if (is_active == UVM_PASSIVE) begin
            validate_cfg = report.error_count == errors_before;
            return validate_cfg;
        end

        case (resp_order)
            AXI_RESP_IN_ORDER: begin
                if (save_req_num > read_outstanding_depth) begin
                    report.conflict(scope, $sformatf(
                        {"resp_order=IN_ORDER actual_save_req_num=%0d ",
                         "expected=0_for_permanent_strict_order_or_range=[1:%0d]",
                         "_for_one_time_initial_release"},
                        save_req_num, read_outstanding_depth),
                        "SLAVE_READ_IN_ORDER_SAVE_DEPTH");
                end
            end
            AXI_RESP_REVERSE_ORDER: begin
                if (read_outstanding_depth < 2 || save_req_num < 2 ||
                    save_req_num > read_outstanding_depth) begin
                    report.conflict(scope, $sformatf(
                        {"resp_order=REVERSE_ORDER actual_save_req_num=%0d ",
                         "actual_outstanding_depth=%0d expected_save_range=[2:%0d]"},
                        save_req_num, read_outstanding_depth,
                        read_outstanding_depth),
                        "SLAVE_READ_REVERSE_ORDER_SAVE_DEPTH");
                end
            end
            AXI_RESP_READY_ORDER: begin
                if (save_req_num != 0) begin
                    report.conflict(scope, $sformatf(
                        "resp_order=READY_ORDER actual_save_req_num=%0d expected=0",
                        save_req_num), "SLAVE_READ_READY_ORDER_SAVE_DEPTH");
                end
            end
            default: begin
                report.invalid(scope, $sformatf(
                    "actual_resp_order=%0d expected={IN_ORDER,REVERSE_ORDER,READY_ORDER}",
                    int'(resp_order)), "SLAVE_READ_RESPONSE_ORDER");
            end
        endcase

        if (is_active == UVM_ACTIVE && memory_model == null) begin
            report.invalid(scope,
                {"is_active=UVM_ACTIVE actual_memory_model=null ",
                 "expected=non-null_for_memory_backed_or_inactive_lane_rdata ",
                 "action=assign_shared_memory_model"},
                "SLAVE_READ_MEM_MODEL_NULL");
        end

        if (fix_rdata_enable && rdata_from_aruser_enable) begin
            report.conflict(scope,
                {"actual_fix_rdata_enable=1 actual_rdata_from_aruser_enable=1 ",
                 "expected_at_most_one_explicit_rdata_source=1 ",
                 "action=disable_fix_rdata_en_or_rdata_from_aruser_enable"},
                "SLAVE_READ_RDATA_SOURCE_CONFLICT");
        end
        if (!fix_rdata_enable && !rdata_from_aruser_enable && !use_mem_model)
            void'(report.check_dist(scope, "rdata_dist",
                rdata_dist, AXI_SLAVER_READ_RDATA_DIST_NUM));

        if (!fix_rresp_enable && !use_mem_model)
            void'(report.check_dist(scope, "rresp_dist",
                rresp_dist, AXI_SLAVER_READ_RESP_DIST_NUM));
        if (fix_rresp_enable && !(rresp inside {
                AXI_SLAVER_READ_RESP_OKAY,
                AXI_SLAVER_READ_RESP_EXOKAY,
                AXI_SLAVER_READ_RESP_SLVERR,
                AXI_SLAVER_READ_RESP_DECERR}))
            report.invalid(scope, $sformatf(
                "actual_fixed_rresp=%0d expected={OKAY,EXOKAY,SLVERR,DECERR}",
                rresp), "SLAVE_READ_FIXED_RRESP_ENCODING");
        if (fix_rresp_enable &&
            rresp == AXI_SLAVER_READ_RESP_EXOKAY &&
            !exclusive_access_enable) begin
            report.conflict(scope,
                {"actual_fixed_rresp=EXOKAY exclusive_access_enable=0 ",
                 "expected=enable_exclusive_support_or_choose_OKAY_SLVERR_DECERR"},
                "SLAVE_READ_FIXED_EXOKAY_REQUIRES_EXCLUSIVE");
        end

        if (!(arready_mode inside {
                AXI_ALWAYS_HIGH,
                AXI_AFTER_VALID})) begin
            report.invalid(scope, $sformatf(
                "actual_arready_mode=%0d expected={AXI_ALWAYS_HIGH,AXI_AFTER_VALID}",
                arready_mode), "SLAVE_READ_ARREADY_MODE");
        end
        else if (arready_mode == AXI_ALWAYS_HIGH) begin
            if (fix_arready_delay_enable && arready_delay != 0)
                report.conflict(scope, $sformatf(
                    "arready_mode=AXI_ALWAYS_HIGH actual_fixed_arready_delay=%0d expected=0",
                    arready_delay), "SLAVE_READ_ARREADY_DELAY_MODE_CONFLICT");
        end
        else if (fix_arready_delay_enable) begin
            if (arready_delay > 63)
                report.invalid(scope, $sformatf(
                    "actual_fixed_arready_delay=%0d expected_range=[0:63]",
                    arready_delay), "SLAVE_READ_ARREADY_DELAY_RANGE");
        end
        else begin
            void'(report.check_dist(scope, "arready_delay_type_dist",
                arready_delay_type_dist, AXI_SLAVER_READ_DELAY_TYPE_NUM));
        end

        if (fix_ar_r_delay_enable) begin
            if (ar_r_delay > 63)
                report.invalid(scope, $sformatf(
                    "actual_fixed_ar_r_delay=%0d expected_range=[0:63]",
                    ar_r_delay), "SLAVE_READ_AR_R_DELAY_RANGE");
        end else
            void'(report.check_dist(scope, "ar_r_delay_dist",
                ar_r_delay_dist, AXI_SLAVER_READ_DELAY_TYPE_NUM));

        if (fix_r_delay_enable) begin
            if (r_delay > 63)
                report.invalid(scope, $sformatf(
                    "actual_fixed_r_delay=%0d expected_range=[0:63]",
                    r_delay), "SLAVE_READ_R_DELAY_RANGE");
        end else
            void'(report.check_dist(scope, "r_delay_dist",
                r_delay_dist, AXI_SLAVER_READ_DELAY_TYPE_NUM));

        validate_cfg = report.error_count == errors_before;
    endfunction : validate_cfg

    constraint delay_dist_c {
        if (arready_mode == AXI_AFTER_VALID &&
            !fix_arready_delay_enable) {
            arready_delay_type_dist.size() == AXI_SLAVER_READ_DELAY_TYPE_NUM;
            arready_delay_type_dist.sum == 100;
            foreach (arready_delay_type_dist[i]) arready_delay_type_dist[i] inside {[0:100]};
        }
        if (!fix_ar_r_delay_enable) {
            ar_r_delay_dist.size() == AXI_SLAVER_READ_DELAY_TYPE_NUM;
            ar_r_delay_dist.sum == 100;
            foreach (ar_r_delay_dist[i]) ar_r_delay_dist[i] inside {[0:100]};
        }
        if (!fix_r_delay_enable) {
            r_delay_dist.size() == AXI_SLAVER_READ_DELAY_TYPE_NUM;
            r_delay_dist.sum == 100;
            foreach (r_delay_dist[i]) r_delay_dist[i] inside {[0:100]};
        }
    }

    constraint resp_dist_c {
        if (!fix_rresp_enable && !use_mem_model) {
            rresp_dist.size() == AXI_SLAVER_READ_RESP_DIST_NUM;
            rresp_dist.sum == 100;
            foreach (rresp_dist[i]) rresp_dist[i] inside {[0:100]};
        }
    }

    constraint rdata_dist_c {
        if (!fix_rdata_enable && !rdata_from_aruser_enable && !use_mem_model) {
            rdata_dist.size() == AXI_SLAVER_READ_RDATA_DIST_NUM;
            rdata_dist.sum == 100;
            foreach (rdata_dist[i]) rdata_dist[i] inside {[0:100]};
        }
    }

    constraint enable_value_c {
        read_outstanding_depth inside {[1:256]};
        save_req_num inside {[0:256]};
        save_req_num <= read_outstanding_depth;
        addr_range_check_enable inside {0, 1};
        memory_error_on_uninitialized_read inside {0, 1};
        exclusive_access_enable inside {0, 1};
        fix_rdata_enable inside {0, 1};
        rdata_from_aruser_enable inside {0, 1};
        fix_rresp_enable inside {0, 1};
        use_mem_model inside {0, 1};
        read_addr_min <= read_addr_max;
        fix_arready_delay_enable inside {0, 1};
        fix_ar_r_delay_enable inside {0, 1};
        fix_r_delay_enable inside {0, 1};
        fix_ruser_enable inside {0, 1};
        arready_delay inside {[0:63]};
        ar_r_delay inside {[0:63]};
        r_delay inside {[0:63]};
    }
endclass : axi_slaver_read_config
`endif
