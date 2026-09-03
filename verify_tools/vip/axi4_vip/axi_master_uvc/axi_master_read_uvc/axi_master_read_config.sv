// ============================================================================
// Filename             : axi_master_read_config.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_READ_CONFIG_SV
`define AXI_MASTER_READ_CONFIG_SV
// Default-specialization compatibility helpers. Parameterized classes below
// derive their widths locally and must not use these package-wide aliases.
localparam int AXI_MASTER_READ_DATA_BYTES = AXI_MASTER_READ_DATA_WIDTH / 8;
localparam int AXI_MASTER_READ_BUS_SIZE   = $clog2(AXI_MASTER_READ_DATA_BYTES);

typedef axi_burst_math #(
    AXI_MASTER_READ_ADDR_WIDTH,
    AXI_MASTER_READ_DATA_BYTES
) axi_master_read_burst_math;

localparam int AXI_MASTER_READ_BURST_COUNT_MIN     = 1;
localparam int AXI_MASTER_READ_BURST_COUNT_MAX     = 1024;
localparam int AXI_MASTER_READ_BURST_COUNT_DEFAULT = 20;

localparam bit [AXI_MASTER_READ_ID_WIDTH-1:0]   AXI_MASTER_READ_ID_MAX   = '1;
localparam bit [AXI_MASTER_READ_ADDR_WIDTH-1:0] AXI_MASTER_READ_ADDR_MAX = '1;
localparam bit [AXI_MASTER_READ_USER_WIDTH-1:0] AXI_MASTER_READ_USER_MAX = '1;

typedef enum bit [1:0] {
    AXI_MASTER_READ_BURST_FIXED = 2'b00,
    AXI_MASTER_READ_BURST_INCR  = 2'b01,
    AXI_MASTER_READ_BURST_WRAP  = 2'b10
} axi_master_read_burst_e;

typedef enum bit [1:0] {
    AXI_MASTER_READ_RESP_OKAY   = 2'b00,
    AXI_MASTER_READ_RESP_EXOKAY = 2'b01,
    AXI_MASTER_READ_RESP_SLVERR = 2'b10,
    AXI_MASTER_READ_RESP_DECERR = 2'b11
} axi_master_read_resp_e;

typedef enum int unsigned {
    AXI_MASTER_READ_ID_ZERO,
    AXI_MASTER_READ_ID_LOW,
    AXI_MASTER_READ_ID_HIGH,
    AXI_MASTER_READ_ID_MAX_VALUE
} axi_master_read_id_type_e;

typedef enum int unsigned {
    AXI_MASTER_READ_ADDR_OFFSET_ZERO,
    AXI_MASTER_READ_ADDR_OFFSET_LOW,
    AXI_MASTER_READ_ADDR_OFFSET_NORMAL,
    AXI_MASTER_READ_ADDR_OFFSET_HIGH,
    AXI_MASTER_READ_ADDR_OFFSET_MAX_VALUE
} axi_master_read_addr_offset_e;

typedef enum int unsigned {
    AXI_MASTER_READ_LEN_SINGLE,
    AXI_MASTER_READ_LEN_SHORT,
    AXI_MASTER_READ_LEN_MID,
    AXI_MASTER_READ_LEN_LONG,
    AXI_MASTER_READ_LEN_MAX_VALUE
} axi_master_read_len_type_e;

typedef enum int unsigned {
    AXI_MASTER_READ_DELAY_ZERO,
    AXI_MASTER_READ_DELAY_SHORT,
    AXI_MASTER_READ_DELAY_MID,
    AXI_MASTER_READ_DELAY_LONG,
    AXI_MASTER_READ_DELAY_MAX_VALUE
} axi_master_read_delay_type_e;

typedef enum int unsigned {
    AXI_MASTER_READ_TIMING_GAP_ZERO,
    AXI_MASTER_READ_TIMING_GAP_SHORT,
    AXI_MASTER_READ_TIMING_GAP_MID,
    AXI_MASTER_READ_TIMING_GAP_LONG,
    AXI_MASTER_READ_TIMING_GAP_MAX_VALUE
} axi_master_read_timing_gap_segment_e;

typedef enum int unsigned {
    AXI_MASTER_READ_RREADY_ALWAYS_HIGH,
    AXI_MASTER_READ_RREADY_AFTER_RVALID
} axi_master_read_rready_mode_e;

localparam int AXI_MASTER_READ_ID_TYPE_NUM          = 4;
localparam int AXI_MASTER_READ_ADDR_OFFSET_TYPE_NUM = 5;
localparam int AXI_MASTER_READ_LEN_TYPE_NUM         = 5;
localparam int AXI_MASTER_READ_DELAY_TYPE_NUM       = 5;
localparam int AXI_MASTER_READ_TIMING_GAP_TYPE_NUM  = 5;
localparam int AXI_MASTER_READ_SIZE_DIST_NUM        = 3;
localparam int AXI_MASTER_READ_BURST_DIST_NUM       = 3;
localparam int AXI_MASTER_READ_MEM_RESP_DIST_NUM    = 3;

class axi_master_read_config #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_object;
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(DATA_BYTES);

    typedef axi_master_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_read_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_read_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_cfg_t;
    //
    // Basic variables in config class.
    //
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    monitor_cfg_t monitor_cfg;

    vif_t axi_master_read_vif;

    // Random-address control. align_size clears the low ARSIZE bits of the
    // randomized page offset. Fixed ARADDR bypasses this alignment control.
    bit align_size = 0;
    bit addr_4k_protect_enable = 1;
    // Maximum protocol-active reads: AR handshake through final R handshake.
    int unsigned read_outstanding_depth = 1;
    int unsigned read_burst_count = AXI_MASTER_READ_BURST_COUNT_DEFAULT;

    // Only use_mem_model enables response-directed page selection. Every
    // configured response segment is expected to contain complete 4KB pages.
    bit       use_mem_model = 0;
    mem_model memory_model;
    // When SIZE is not fixed in Mem Model mode, this is the weight of
    // selecting a Segment-supported SIZE.  The complementary weight selects
    // an unsupported SIZE for a directed negative request.
    int unsigned size_resp_weight = 100;

    // Optional cfg fixed fields. Each enable defaults to 0. axi_multi_env_config
    // randomizes the scalar value candidates once when it creates this cfg, so
    // enabling a field without assigning its value fixes one random value.
    // A later project-level assignment, including an explicit zero, wins.
    bit fix_arid_enable = 0;
    rand bit [ID_WIDTH-1:0] arid;
    bit fix_araddr_enable = 0;
    rand bit [ADDR_WIDTH-1:0] araddr;
    bit fix_arlen_enable = 0;
    rand bit [7:0] arlen;
    bit fix_arsize_enable = 0;
    rand bit [2:0] arsize;
    bit fix_arburst_enable = 0;
    rand axi_master_read_burst_e arburst;
    bit fix_arlock_enable = 0;
    rand bit arlock;
    bit fix_arcache_enable = 0;
    rand bit [3:0] arcache;
    bit fix_arprot_enable = 0;
    rand bit [2:0] arprot;
    bit fix_arqos_enable = 0;
    rand bit [3:0] arqos;
    bit fix_arregion_enable = 0;
    rand bit [3:0] arregion;
    bit fix_aruser_enable = 0;
    rand bit [USER_WIDTH-1:0] aruser;

    // ARVALID timing controls:
    // - first_delay is measured from reset release to the earliest first
    //   ARVALID issue. If the first request arrives after this deadline, it
    //   may issue immediately.
    // - ar_delay is measured from one AR handshake to the next ARVALID issue.
    // The first request never adds ar_delay, and later requests never add
    // first_delay. With fix_first_delay_enable=0, the driver selects first_delay
    // once per reset release. ar_delay remains a per-request random value.
    bit fix_first_delay_enable = 0;
    rand int unsigned first_delay = 0;
    bit fix_ar_delay_enable = 0;
    rand int unsigned ar_delay = 0;

    // Internal helpers for reset-level first_delay and per-request ar_delay.
    rand axi_master_read_timing_gap_segment_e first_delay_segment;
    rand axi_master_read_timing_gap_segment_e fix_ar_delay_segment;

    // RREADY timing mode:
    // - ALWAYS_HIGH: master keeps RREADY high after reset.
    // - AFTER_RVALID: master waits for the first RVALID, applies rready_delay,
    //   then keeps RREADY high through the RLAST handshake of that burst.
    axi_master_read_rready_mode_e rready_mode = AXI_MASTER_READ_RREADY_AFTER_RVALID;
    bit fix_rready_delay_enable = 0;
    rand int unsigned rready_delay = 0;

    //
    // Declare user random config informations.
    //
    rand int unsigned arid_type_dist[];
    // 4KB page-offset bins: 0, 1:0ff, 100:fef, ff0:ffe, fff.
    rand int unsigned araddr_offset_dist[];
    rand int unsigned arlen_type_dist[];
    // Non-Mem, non-fixed SIZE categories: MIN, MIDDLE, FULL.  For an 8-bit
    // bus MIN and FULL both normalize to SIZE0; slot 2 is disabled.
    rand int unsigned arsize_dist[AXI_MASTER_READ_SIZE_DIST_NUM];
    rand int unsigned arburst_dist[];
    // Array order: OKAY, SLVERR, DECERR. EXOKAY is protocol state, not an
    // address-segment attribute, so it is intentionally not selectable here.
    rand int unsigned resp_dist[];
    // Array order follows axi_master_read_timing_gap_segment_e.
    // first_delay_type_dist is sampled once per reset; ar_delay_dist is
    // sampled per request when its matching fix enable is zero.
    rand int unsigned first_delay_type_dist[];
    rand int unsigned ar_delay_dist[];
    rand int unsigned rready_delay_type_dist[];

    // Binary/zero-vs-nonzero signal weights. The signal is randomized with:
    // 0 : 100 - xxx_weight, 1/nonzero : xxx_weight.
    rand int unsigned arlock_weight;
    rand int unsigned arcache_nonzero_weight;
    rand int unsigned arprot_nonzero_weight;
    rand int unsigned arqos_nonzero_weight;
    rand int unsigned arregion_nonzero_weight;
    rand int unsigned aruser_nonzero_weight;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_enum         (uvm_active_passive_enum,   is_active,      UVM_DEFAULT)
        `uvm_field_object       (monitor_cfg,                               UVM_DEFAULT)
        `uvm_field_int          (align_size,                               UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (addr_4k_protect_enable,                    UVM_DEFAULT)
        `uvm_field_int          (read_outstanding_depth,                    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (read_burst_count,                          UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (use_mem_model,                            UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (size_resp_weight,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_arid_enable,                      UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arid,                             UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_araddr_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (araddr,                           UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_arlen_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arlen,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_arsize_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arsize,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_arburst_enable,                   UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum         (axi_master_read_burst_e, arburst,        UVM_DEFAULT)
        `uvm_field_int          (fix_arlock_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arlock,                           UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (fix_arcache_enable,                   UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arcache,                          UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_arprot_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arprot,                           UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_arqos_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arqos,                            UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_arregion_enable,                  UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (arregion,                         UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_aruser_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (aruser,                           UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_first_delay_enable,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (first_delay,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_ar_delay_enable,                          UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (ar_delay,                                 UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_rready_delay_enable,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (rready_delay,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum         (axi_master_read_rready_mode_e, rready_mode,        UVM_DEFAULT)
        `uvm_field_array_int    (arid_type_dist,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (araddr_offset_dist,                        UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (arlen_type_dist,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_sarray_int   (arsize_dist,                               UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (arburst_dist,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (resp_dist,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (first_delay_type_dist,                     UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (ar_delay_dist,                             UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (rready_delay_type_dist,                    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (arlock_weight,                             UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (arcache_nonzero_weight,                    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (arprot_nonzero_weight,                     UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (arqos_nonzero_weight,                      UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (arregion_nonzero_weight,                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (aruser_nonzero_weight,                     UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "axi_master_read_config");
        super.new(name);
        monitor_cfg = monitor_cfg_t::type_id::create(
            {name, "_monitor_cfg"});
        if (monitor_cfg == null) begin
            `uvm_fatal("AXI_CFG", "Failed to create Master Read monitor cfg")
        end
        if (!is_valid_id_width(ID_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "ID_WIDTH must be >= 1")
        end
        if (!is_valid_addr_width(ADDR_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "ADDR_WIDTH must be >= 12 for 4KB page-offset generation")
        end
        if (!is_valid_data_width(DATA_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "DATA_WIDTH must be byte-aligned in [16:1024] and DATA_WIDTH/8 must be a power of two")
        end
        if (!is_valid_user_width(USER_WIDTH)) begin
            `uvm_fatal("AXI_CFG", "USER_WIDTH must be >= 1")
        end
        if (!is_valid_max_beats(AXI_MASTER_READ_MAX_BEATS)) begin
            `uvm_fatal("AXI_CFG", "AXI_MASTER_READ_MAX_BEATS must be in [16:256]")
        end

        arid     = '0;
        araddr   = '0;
        arlen    = '0;
        arsize   = BUS_SIZE;
        arburst  = AXI_MASTER_READ_BURST_INCR;
        arlock   = '0;
        arcache  = '0;
        arprot   = '0;
        arqos    = '0;
        arregion = '0;
        aruser   = '0;

        arlock_weight           = 20;
        arcache_nonzero_weight  = 20;
        arprot_nonzero_weight   = 20;
        arqos_nonzero_weight    = 20;
        arregion_nonzero_weight = 20;
        aruser_nonzero_weight   = 20;

        arid_type_dist         = new[AXI_MASTER_READ_ID_TYPE_NUM];
        araddr_offset_dist     = new[AXI_MASTER_READ_ADDR_OFFSET_TYPE_NUM];
        arlen_type_dist        = new[AXI_MASTER_READ_LEN_TYPE_NUM];
        arburst_dist           = new[AXI_MASTER_READ_BURST_DIST_NUM];
        resp_dist              = new[AXI_MASTER_READ_MEM_RESP_DIST_NUM];
        first_delay_type_dist  = new[AXI_MASTER_READ_TIMING_GAP_TYPE_NUM];
        ar_delay_dist          = new[AXI_MASTER_READ_TIMING_GAP_TYPE_NUM];
        rready_delay_type_dist = new[AXI_MASTER_READ_DELAY_TYPE_NUM];

        arid_type_dist         = '{25, 25, 25, 25};
        araddr_offset_dist     = '{5, 15, 60, 10, 10};
        arlen_type_dist        = '{30, 30, 20, 15, 5};
        if (BUS_SIZE == 0) begin
            arsize_dist = '{100, 0, 0};
        end
        else if (BUS_SIZE == 1) begin
            arsize_dist = '{50, 50, 0};
        end
        else begin
            arsize_dist = '{34, 33, 33};
        end
        arburst_dist           = '{15, 70, 15};
        resp_dist              = '{60, 20, 20};
        first_delay_type_dist  = '{20, 20, 20, 20, 20};
        ar_delay_dist          = '{20, 20, 20, 20, 20};
        rready_delay_type_dist = '{20, 20, 20, 20, 20};
    endfunction : new

    // Randomize only independent scalar fixed-value defaults.  There are no
    // cross-field legality constraints here: a later user combination is
    // preserved exactly and the Driver validates that final request before it
    // can reach ARVALID.
    function bit randomize_fixed_value_defaults();
        string saved_randstate;
        bit saved_fix_arid_enable;
        bit saved_fix_araddr_enable;
        bit saved_fix_arlen_enable;
        bit saved_fix_arsize_enable;
        bit saved_fix_arburst_enable;
        bit saved_fix_arlock_enable;
        bit saved_fix_arcache_enable;
        bit saved_fix_arprot_enable;
        bit saved_fix_arqos_enable;
        bit saved_fix_arregion_enable;
        bit saved_fix_aruser_enable;
        bit saved_fix_first_delay_enable;
        bit saved_fix_ar_delay_enable;
        bit saved_fix_rready_delay_enable;

        saved_randstate = this.get_randstate();
        saved_fix_arid_enable = fix_arid_enable;
        saved_fix_araddr_enable = fix_araddr_enable;
        saved_fix_arlen_enable = fix_arlen_enable;
        saved_fix_arsize_enable = fix_arsize_enable;
        saved_fix_arburst_enable = fix_arburst_enable;
        saved_fix_arlock_enable = fix_arlock_enable;
        saved_fix_arcache_enable = fix_arcache_enable;
        saved_fix_arprot_enable = fix_arprot_enable;
        saved_fix_arqos_enable = fix_arqos_enable;
        saved_fix_arregion_enable = fix_arregion_enable;
        saved_fix_aruser_enable = fix_aruser_enable;
        saved_fix_first_delay_enable = fix_first_delay_enable;
        saved_fix_ar_delay_enable = fix_ar_delay_enable;
        saved_fix_rready_delay_enable = fix_rready_delay_enable;

        fix_arid_enable = 1'b1;
        fix_araddr_enable = 1'b1;
        fix_arlen_enable = 1'b1;
        fix_arsize_enable = 1'b1;
        fix_arburst_enable = 1'b1;
        fix_arlock_enable = 1'b1;
        fix_arcache_enable = 1'b1;
        fix_arprot_enable = 1'b1;
        fix_arqos_enable = 1'b1;
        fix_arregion_enable = 1'b1;
        fix_aruser_enable = 1'b1;
        fix_first_delay_enable = 1'b1;
        fix_ar_delay_enable = 1'b1;
        fix_rready_delay_enable = 1'b1;

        randomize_fixed_value_defaults = this.randomize(
            arid,
            araddr,
            arlen,
            arsize,
            arburst,
            arlock,
            arcache,
            arprot,
            arqos,
            arregion,
            aruser,
            first_delay,
            ar_delay,
            first_delay_segment,
            fix_ar_delay_segment,
            rready_delay
        ) with {
            axi_cache_is_legal(arcache);
        };
        this.set_randstate(saved_randstate);

        fix_arid_enable = saved_fix_arid_enable;
        fix_araddr_enable = saved_fix_araddr_enable;
        fix_arlen_enable = saved_fix_arlen_enable;
        fix_arsize_enable = saved_fix_arsize_enable;
        fix_arburst_enable = saved_fix_arburst_enable;
        fix_arlock_enable = saved_fix_arlock_enable;
        fix_arcache_enable = saved_fix_arcache_enable;
        fix_arprot_enable = saved_fix_arprot_enable;
        fix_arqos_enable = saved_fix_arqos_enable;
        fix_arregion_enable = saved_fix_arregion_enable;
        fix_aruser_enable = saved_fix_aruser_enable;
        fix_first_delay_enable = saved_fix_first_delay_enable;
        fix_ar_delay_enable = saved_fix_ar_delay_enable;
        fix_rready_delay_enable = saved_fix_rready_delay_enable;
    endfunction : randomize_fixed_value_defaults

    // Select exactly one reset-to-first-ARVALID delay for a driver reset
    // epoch. The driver calls this once after reset release and caches the
    // result until the next reset.
    function bit select_first_delay(output int unsigned selected_delay);
        int unsigned selection;
        int unsigned cumulative;

        if (fix_first_delay_enable) begin
            selected_delay = first_delay;
            return 1'b1;
        end
        if (first_delay_type_dist.size() !=
                AXI_MASTER_READ_TIMING_GAP_TYPE_NUM ||
            first_delay_type_dist.sum() != 100) begin
            selected_delay = 0;
            return 1'b0;
        end
        selection = $urandom_range(99, 0);
        cumulative = 0;
        foreach (first_delay_type_dist[i]) begin
            cumulative += first_delay_type_dist[i];
            if (selection < cumulative) begin
                case (i)
                    AXI_MASTER_READ_TIMING_GAP_ZERO:
                        selected_delay = 0;
                    AXI_MASTER_READ_TIMING_GAP_SHORT:
                        selected_delay = $urandom_range(3, 1);
                    AXI_MASTER_READ_TIMING_GAP_MID:
                        selected_delay = $urandom_range(10, 4);
                    AXI_MASTER_READ_TIMING_GAP_LONG:
                        selected_delay = $urandom_range(31, 11);
                    AXI_MASTER_READ_TIMING_GAP_MAX_VALUE:
                        selected_delay = $urandom_range(63, 32);
                    default: return 1'b0;
                endcase
                return 1'b1;
            end
        end
        selected_delay = 0;
        return 1'b0;
    endfunction : select_first_delay

    protected function void get_plusarg_bit(
        string                    prefix,
        string                    field_name,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report,
        ref bit                   target
    );
        bit value;
        if (parser.get_bit({prefix, "_", field_name}, prefix, report,
                value)) begin
            target = value;
        end
    endfunction : get_plusarg_bit

    protected function void get_plusarg_uint(
        string                    prefix,
        string                    field_name,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report,
        ref int unsigned          target,
        longint unsigned          minimum,
        longint unsigned          maximum
    );
        longint unsigned value;
        string key;

        key = {prefix, "_", field_name};
        if (parser.get_uint(key, prefix, report, value)) begin
            if (value < minimum || value > maximum) begin
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[%0d:%0d]",
                    key, value, minimum, maximum),
                    "MASTER_READ_PLUSARG_RANGE");
            end
            else begin
                target = int'(value);
            end
        end
    endfunction : get_plusarg_uint

    protected function void get_plusarg_dist_element(
        string                    prefix,
        string                    field_name,
        int unsigned              index,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report,
        ref int unsigned          target
    );
        longint unsigned value;
        string key;

        key = $sformatf("%s_%s_%0d", prefix, field_name, index);
        if (parser.get_uint(key, prefix, report, value)) begin
            if (value > 100) begin
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:100]",
                    key, value), "MASTER_READ_PLUSARG_DIST_RANGE");
            end
            else begin
                target = int'(value);
            end
        end
    endfunction : get_plusarg_dist_element

    protected function bit parse_plusarg_enum_number(
        string       raw_value,
        int unsigned maximum,
        output int   value
    );
        int unsigned parsed_value;
        byte unsigned character;

        value = 0;
        if (raw_value.len() == 0) begin
            return 1'b0;
        end
        parsed_value = 0;
        for (int i = 0; i < raw_value.len(); i++) begin
            character = raw_value.getc(i);
            if (character < 8'h30 || character > 8'h39) begin
                return 1'b0;
            end
            parsed_value = (parsed_value * 10) + (character - 8'h30);
            if (parsed_value > maximum) begin
                return 1'b0;
            end
        end
        value = int'(parsed_value);
        return 1'b1;
    endfunction : parse_plusarg_enum_number

    // Apply command-line overrides after Test source configuration and before
    // axi_multi_env_config::validate_and_freeze(). A value override never enables
    // its matching fix_*_enable switch implicitly.
    function bit get_args(
        string                    prefix,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report
    );
        int unsigned     errors_before;
        longint unsigned uint_value;
        uvm_bitstream_t  hex_value;
        string           raw_value;
        string           normalized;
        int signed       enum_value;
        string           key;

        if (parser == null) begin
            `uvm_fatal("AXI_CFG_PLUSARG", $sformatf(
                "Master Read cfg prefix=%s received null parser", prefix))
            return 1'b0;
        end
        if (report == null) begin
            `uvm_fatal("AXI_CFG_PLUSARG", $sformatf(
                "Master Read cfg prefix=%s received null report", prefix))
            return 1'b0;
        end
        errors_before = report.error_count;
        if (prefix.len() == 0) begin
            report.invalid(get_full_name(),
                "actual_plusarg_prefix=empty expected=non-empty",
                "MASTER_READ_PLUSARG_PREFIX_EMPTY");
            return 1'b0;
        end

        key = {prefix, "_IS_ACTIVE"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "PASSIVE", "UVM_PASSIVE": is_active = UVM_PASSIVE;
                "ACTIVE",  "UVM_ACTIVE":  is_active = UVM_ACTIVE;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 1, enum_value))
                        is_active = uvm_active_passive_enum'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            "key=%s actual=%s expected={PASSIVE,ACTIVE,0,1}",
                            key, raw_value), "MASTER_READ_PLUSARG_ENUM");
                end
            endcase
        end

        get_plusarg_bit(prefix, "ALIGN_SIZE", parser, report, align_size);
        get_plusarg_bit(prefix, "ADDR_4K_PROTECT_ENABLE", parser, report,
            addr_4k_protect_enable);
        get_plusarg_uint(prefix, "READ_OUTSTANDING_DEPTH", parser, report,
            read_outstanding_depth, 1, 256);
        get_plusarg_uint(prefix, "READ_BURST_COUNT", parser, report,
            read_burst_count, AXI_MASTER_READ_BURST_COUNT_MIN,
            AXI_MASTER_READ_BURST_COUNT_MAX);
        get_plusarg_bit(prefix, "USE_MEM_MODEL", parser, report,
            use_mem_model);
        get_plusarg_uint(prefix, "SIZE_RESP_WEIGHT", parser, report,
            size_resp_weight, 0, 100);

        get_plusarg_bit(prefix, "FIX_ARID_EN", parser, report, fix_arid_enable);
        key = {prefix, "_ARID"};
        if (parser.get_hex(key, prefix, report, ID_WIDTH, hex_value))
            arid = hex_value;
        get_plusarg_bit(prefix, "FIX_ARADDR_EN", parser, report,
            fix_araddr_enable);
        key = {prefix, "_ARADDR"};
        if (parser.get_hex(key, prefix, report, ADDR_WIDTH, hex_value))
            araddr = hex_value;
        get_plusarg_bit(prefix, "FIX_ARLEN_EN", parser, report, fix_arlen_enable);
        key = {prefix, "_ARLEN"};
        if (parser.get_uint(key, prefix, report, uint_value)) begin
            if (uint_value >= AXI_MASTER_READ_MAX_BEATS)
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:%0d]", key,
                    uint_value, AXI_MASTER_READ_MAX_BEATS-1),
                    "MASTER_READ_PLUSARG_RANGE");
            else
                arlen = uint_value[7:0];
        end
        get_plusarg_bit(prefix, "FIX_ARSIZE_EN", parser, report,
            fix_arsize_enable);
        key = {prefix, "_ARSIZE"};
        if (parser.get_uint(key, prefix, report, uint_value)) begin
            if (uint_value > BUS_SIZE)
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:%0d]",
                    key, uint_value, BUS_SIZE), "MASTER_READ_PLUSARG_RANGE");
            else
                arsize = uint_value[2:0];
        end
        get_plusarg_bit(prefix, "FIX_ARBURST_EN", parser, report,
            fix_arburst_enable);
        key = {prefix, "_ARBURST"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "FIXED", "AXI_MASTER_READ_BURST_FIXED":
                    arburst = AXI_MASTER_READ_BURST_FIXED;
                "INCR", "AXI_MASTER_READ_BURST_INCR":
                    arburst = AXI_MASTER_READ_BURST_INCR;
                "WRAP", "AXI_MASTER_READ_BURST_WRAP":
                    arburst = AXI_MASTER_READ_BURST_WRAP;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 2, enum_value))
                        arburst = axi_master_read_burst_e'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            "key=%s actual=%s expected={FIXED,INCR,WRAP,0,1,2}",
                            key, raw_value), "MASTER_READ_PLUSARG_ENUM");
                end
            endcase
        end
        get_plusarg_bit(prefix, "FIX_ARLOCK_EN", parser, report,
            fix_arlock_enable);
        get_plusarg_bit(prefix, "ARLOCK", parser, report, arlock);
        get_plusarg_bit(prefix, "FIX_ARCACHE_EN", parser, report,
            fix_arcache_enable);
        key = {prefix, "_ARCACHE"};
        if (parser.get_hex(key, prefix, report, 4, hex_value))
            arcache = hex_value;
        get_plusarg_bit(prefix, "FIX_ARPROT_EN", parser, report,
            fix_arprot_enable);
        key = {prefix, "_ARPROT"};
        if (parser.get_hex(key, prefix, report, 3, hex_value))
            arprot = hex_value;
        get_plusarg_bit(prefix, "FIX_ARQOS_EN", parser, report,
            fix_arqos_enable);
        key = {prefix, "_ARQOS"};
        if (parser.get_hex(key, prefix, report, 4, hex_value))
            arqos = hex_value;
        get_plusarg_bit(prefix, "FIX_ARREGION_EN", parser, report,
            fix_arregion_enable);
        key = {prefix, "_ARREGION"};
        if (parser.get_hex(key, prefix, report, 4, hex_value))
            arregion = hex_value;
        get_plusarg_bit(prefix, "FIX_ARUSER_EN", parser, report,
            fix_aruser_enable);
        key = {prefix, "_ARUSER"};
        if (parser.get_hex(key, prefix, report, USER_WIDTH, hex_value))
            aruser = hex_value;

        get_plusarg_bit(prefix, "FIX_FIRST_DELAY_EN", parser, report,
            fix_first_delay_enable);
        get_plusarg_uint(prefix, "FIRST_DELAY", parser, report, first_delay,
            0, 63);
        get_plusarg_bit(prefix, "FIX_AR_DELAY_EN", parser, report,
            fix_ar_delay_enable);
        get_plusarg_uint(prefix, "AR_DELAY", parser, report, ar_delay,
            0, 100);

        key = {prefix, "_RREADY_MODE"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "ALWAYS_HIGH", "AXI_MASTER_READ_RREADY_ALWAYS_HIGH":
                    rready_mode = AXI_MASTER_READ_RREADY_ALWAYS_HIGH;
                "AFTER_RVALID", "AXI_MASTER_READ_RREADY_AFTER_RVALID":
                    rready_mode = AXI_MASTER_READ_RREADY_AFTER_RVALID;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 1, enum_value))
                        rready_mode = axi_master_read_rready_mode_e'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            "key=%s actual=%s expected={ALWAYS_HIGH,AFTER_RVALID,0,1}",
                            key, raw_value), "MASTER_READ_PLUSARG_ENUM");
                end
            endcase
        end
        get_plusarg_bit(prefix, "FIX_RREADY_DELAY_EN", parser, report,
            fix_rready_delay_enable);
        get_plusarg_uint(prefix, "RREADY_DELAY", parser, report,
            rready_delay, 0, 63);

        foreach (arid_type_dist[i])
            get_plusarg_dist_element(prefix, "ARID_TYPE_DIST", i, parser,
                report, arid_type_dist[i]);
        foreach (araddr_offset_dist[i])
            get_plusarg_dist_element(prefix, "ARADDR_OFFSET_DIST", i,
                parser, report, araddr_offset_dist[i]);
        foreach (arlen_type_dist[i])
            get_plusarg_dist_element(prefix, "ARLEN_TYPE_DIST", i, parser,
                report, arlen_type_dist[i]);
        foreach (arsize_dist[i])
            get_plusarg_dist_element(prefix, "ARSIZE_DIST", i, parser,
                report, arsize_dist[i]);
        foreach (arburst_dist[i])
            get_plusarg_dist_element(prefix, "ARBURST_DIST", i, parser,
                report, arburst_dist[i]);
        foreach (resp_dist[i])
            get_plusarg_dist_element(prefix, "RESP_DIST", i, parser,
                report, resp_dist[i]);
        foreach (first_delay_type_dist[i])
            get_plusarg_dist_element(prefix, "FIRST_DELAY_TYPE_DIST", i,
                parser, report, first_delay_type_dist[i]);
        foreach (ar_delay_dist[i])
            get_plusarg_dist_element(prefix, "AR_DELAY_DIST", i, parser,
                report, ar_delay_dist[i]);
        foreach (rready_delay_type_dist[i])
            get_plusarg_dist_element(prefix, "RREADY_DELAY_TYPE_DIST", i,
                parser, report, rready_delay_type_dist[i]);

        get_plusarg_uint(prefix, "ARLOCK_WEIGHT", parser, report,
            arlock_weight, 0, 100);
        get_plusarg_uint(prefix, "ARCACHE_NONZERO_WEIGHT", parser, report,
            arcache_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "ARPROT_NONZERO_WEIGHT", parser, report,
            arprot_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "ARQOS_NONZERO_WEIGHT", parser, report,
            arqos_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "ARREGION_NONZERO_WEIGHT", parser, report,
            arregion_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "ARUSER_NONZERO_WEIGHT", parser, report,
            aruser_nonzero_weight, 0, 100);

        if (monitor_cfg != null)
            monitor_cfg.get_args(prefix, parser, report);

        return report.error_count == errors_before;
    endfunction : get_args

    function bit validate_cfg(
        axi_cfg_validation_report report,
        string                    scope
    );
        int unsigned errors_before;
        bit non_wrap_burst_possible;

        errors_before = report.error_count;
        non_wrap_burst_possible = fix_arburst_enable ?
            (arburst != AXI_MASTER_READ_BURST_WRAP) : 1'b1;
        if (!fix_arburst_enable &&
            arburst_dist.size() == AXI_MASTER_READ_BURST_DIST_NUM)
            non_wrap_burst_possible =
                (arburst_dist[AXI_MASTER_READ_BURST_FIXED] +
                 arburst_dist[AXI_MASTER_READ_BURST_INCR]) != 0;
        if (!(read_outstanding_depth inside {[1:256]})) begin
            report.invalid(scope, $sformatf(
                "actual_read_outstanding_depth=%0d expected_range=[1:256]",
                read_outstanding_depth), "MASTER_READ_OUTSTANDING_DEPTH_RANGE");
        end
        if (!(is_active inside {UVM_ACTIVE, UVM_PASSIVE}))
            report.invalid(scope, $sformatf(
                "actual_is_active=%0d expected={UVM_ACTIVE,UVM_PASSIVE}",
                is_active), "MASTER_READ_ACTIVE_MODE");
        if (is_active == UVM_PASSIVE) begin
            validate_cfg = report.error_count == errors_before;
            return validate_cfg;
        end
        if (!(read_burst_count inside {
                [AXI_MASTER_READ_BURST_COUNT_MIN:AXI_MASTER_READ_BURST_COUNT_MAX]})) begin
            report.invalid(scope, $sformatf(
                "actual_read_burst_count=%0d expected_range=[%0d:%0d]",
                read_burst_count, AXI_MASTER_READ_BURST_COUNT_MIN,
                AXI_MASTER_READ_BURST_COUNT_MAX),
                "MASTER_READ_BURST_COUNT_RANGE");
        end

        if (use_mem_model && memory_model == null) begin
            report.invalid(scope,
                "use_mem_model=1 actual_memory_model=null expected=non-null",
                "MASTER_READ_MEM_MODEL_NULL");
        end
        if (use_mem_model &&
            ADDR_WIDTH > $bits(mem_addr_t)) begin
            report.invalid(scope, $sformatf(
                "actual_addr_width=%0d expected_max_mem_addr_width=%0d",
                ADDR_WIDTH, $bits(mem_addr_t)),
                "MASTER_READ_MEM_ADDR_WIDTH");
        end
        if (use_mem_model && !fix_araddr_enable && !fix_arsize_enable &&
            size_resp_weight > 100) begin
            report.invalid(scope, $sformatf(
                "actual_size_resp_weight=%0d expected_range=[0:100]",
                size_resp_weight), "MASTER_READ_SIZE_RESP_WEIGHT_RANGE");
        end

        if (!fix_arid_enable)
            void'(report.check_dist(scope, "arid_type_dist",
                arid_type_dist, AXI_MASTER_READ_ID_TYPE_NUM));
        if (!fix_araddr_enable)
            void'(report.check_dist(scope, "araddr_offset_dist",
                araddr_offset_dist, AXI_MASTER_READ_ADDR_OFFSET_TYPE_NUM));
        if (!fix_arlen_enable && non_wrap_burst_possible)
            void'(report.check_dist(scope, "arlen_type_dist",
                arlen_type_dist, AXI_MASTER_READ_LEN_TYPE_NUM));
        if (!fix_arburst_enable)
            void'(report.check_dist(scope, "arburst_dist",
                arburst_dist, AXI_MASTER_READ_BURST_DIST_NUM));
        if (!fix_arsize_enable &&
            (!use_mem_model || fix_araddr_enable) &&
            BUS_SIZE != 0) begin
            void'(report.check_dist(scope, "arsize_dist",
                arsize_dist, AXI_MASTER_READ_SIZE_DIST_NUM));
            if ($size(arsize_dist) == AXI_MASTER_READ_SIZE_DIST_NUM &&
                BUS_SIZE <= 1 && arsize_dist[2] != 0)
                report.invalid(scope, $sformatf(
                    "actual_arsize_dist[2]=%0d BUS_SIZE=%0d expected_arsize_dist[2]=0",
                    arsize_dist[2], BUS_SIZE),
                    "MASTER_READ_SIZE_DIST_UNUSED_SLOT");
        end
        if (use_mem_model && !fix_araddr_enable)
            void'(report.check_dist(scope, "resp_dist",
                resp_dist, AXI_MASTER_READ_MEM_RESP_DIST_NUM));
        if (!fix_first_delay_enable)
            void'(report.check_dist(scope, "first_delay_type_dist",
                first_delay_type_dist, AXI_MASTER_READ_TIMING_GAP_TYPE_NUM));
        if (!fix_ar_delay_enable)
            void'(report.check_dist(scope, "ar_delay_dist",
                ar_delay_dist, AXI_MASTER_READ_TIMING_GAP_TYPE_NUM));
        if (rready_mode == AXI_MASTER_READ_RREADY_AFTER_RVALID &&
            !fix_rready_delay_enable)
            void'(report.check_dist(scope, "rready_delay_type_dist",
                rready_delay_type_dist, AXI_MASTER_READ_DELAY_TYPE_NUM));

        if (!fix_arlock_enable && arlock_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_arlock_weight=%0d expected_range=[0:100]",
                arlock_weight), "MASTER_READ_LOCK_WEIGHT_RANGE");
        if (!fix_arcache_enable && arcache_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_arcache_nonzero_weight=%0d expected_range=[0:100]",
                arcache_nonzero_weight), "MASTER_READ_CACHE_WEIGHT_RANGE");
        if (!fix_arprot_enable && arprot_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_arprot_nonzero_weight=%0d expected_range=[0:100]",
                arprot_nonzero_weight), "MASTER_READ_PROT_WEIGHT_RANGE");
        if (!fix_arqos_enable && arqos_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_arqos_nonzero_weight=%0d expected_range=[0:100]",
                arqos_nonzero_weight), "MASTER_READ_QOS_WEIGHT_RANGE");
        if (!fix_arregion_enable && arregion_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_arregion_nonzero_weight=%0d expected_range=[0:100]",
                arregion_nonzero_weight), "MASTER_READ_REGION_WEIGHT_RANGE");
        if (!fix_aruser_enable && aruser_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_aruser_nonzero_weight=%0d expected_range=[0:100]",
                aruser_nonzero_weight), "MASTER_READ_USER_WEIGHT_RANGE");

        if (fix_arburst_enable && !(arburst inside {
                AXI_MASTER_READ_BURST_FIXED,
                AXI_MASTER_READ_BURST_INCR,
                AXI_MASTER_READ_BURST_WRAP})) begin
            report.invalid(scope, $sformatf(
                "actual_fixed_arburst=%0d expected={FIXED,INCR,WRAP}",
                arburst), "MASTER_READ_FIXED_BURST_ENCODING");
        end

        if (fix_arlen_enable && arlen >= AXI_MASTER_READ_MAX_BEATS)
            report.invalid(scope, $sformatf(
                "actual_fixed_arlen=%0d expected_range=[0:%0d]",
                arlen, AXI_MASTER_READ_MAX_BEATS-1),
                "MASTER_READ_FIXED_LEN_RANGE");
        if (fix_arsize_enable && arsize > BUS_SIZE)
            report.invalid(scope, $sformatf(
                "actual_fixed_arsize=%0d expected_range=[0:%0d]",
                arsize, BUS_SIZE), "MASTER_READ_FIXED_SIZE_RANGE");
        if (fix_arcache_enable && !axi_cache_is_legal(arcache))
            report.invalid(scope, $sformatf(
                "actual_fixed_arcache=0x%0h expected_legal_axi4_cache_encoding",
                arcache), "MASTER_READ_FIXED_CACHE_ENCODING");

        if (fix_first_delay_enable && first_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_first_delay=%0d expected_range=[0:63]",
                first_delay), "MASTER_READ_FIRST_DELAY_RANGE");
        if (fix_ar_delay_enable && ar_delay > 100)
            report.invalid(scope, $sformatf(
                "actual_fixed_ar_delay=%0d expected_range=[0:100]",
                ar_delay), "MASTER_READ_AR_DELAY_RANGE");
        if (fix_rready_delay_enable && rready_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_rready_delay=%0d expected_range=[0:63]",
                rready_delay), "MASTER_READ_RREADY_DELAY_RANGE");
        if (!(rready_mode inside {
                AXI_MASTER_READ_RREADY_ALWAYS_HIGH,
                AXI_MASTER_READ_RREADY_AFTER_RVALID}))
            report.invalid(scope, $sformatf(
                "actual_rready_mode=%0d expected={ALWAYS_HIGH,AFTER_RVALID}",
                rready_mode), "MASTER_READ_RREADY_MODE");
        if (rready_mode == AXI_MASTER_READ_RREADY_ALWAYS_HIGH &&
            fix_rready_delay_enable && rready_delay != 0)
            report.conflict(scope, $sformatf(
                {"actual_rready_mode=ALWAYS_HIGH actual_fixed_rready_delay=%0d ",
                 "expected_fixed_rready_delay=0"}, rready_delay),
                "MASTER_READ_RREADY_MODE_DELAY_CONFLICT");

        // Segment/response/SIZE reachability is deliberately request-time
        // policy. A valid but empty or non-matching map rejects only the
        // affected attempt before VALID; it is not a structural cfg failure.

        validate_cfg = report.error_count == errors_before;
    endfunction : validate_cfg

    //
    // Implement constraints for user config.
    //
    constraint arid_type_dist_c {
        if (!fix_arid_enable) {
            arid_type_dist.sum == 100;
            arid_type_dist.size() == AXI_MASTER_READ_ID_TYPE_NUM;
            foreach (arid_type_dist[i]) arid_type_dist[i] inside {[0:100]};
        }
    }

    constraint araddr_offset_dist_c {
        if (!fix_araddr_enable) {
            araddr_offset_dist.sum == 100;
            araddr_offset_dist.size() == AXI_MASTER_READ_ADDR_OFFSET_TYPE_NUM;
            foreach (araddr_offset_dist[i]) araddr_offset_dist[i] inside {[0:100]};
        }
    }

    constraint arlen_type_dist_c {
        if (!fix_arlen_enable &&
            ((fix_arburst_enable && arburst != AXI_MASTER_READ_BURST_WRAP) ||
             (!fix_arburst_enable &&
              (arburst_dist[AXI_MASTER_READ_BURST_FIXED] +
               arburst_dist[AXI_MASTER_READ_BURST_INCR] > 0)))) {
            arlen_type_dist.sum == 100;
            arlen_type_dist.size() == AXI_MASTER_READ_LEN_TYPE_NUM;
            foreach (arlen_type_dist[i]) arlen_type_dist[i] inside {[0:100]};
        }
    }

    constraint arsize_dist_c {
        if (!fix_arsize_enable &&
            (!use_mem_model || fix_araddr_enable) &&
            BUS_SIZE != 0) {
            arsize_dist.sum == 100;
            foreach (arsize_dist[i]) arsize_dist[i] inside {[0:100]};
            (BUS_SIZE <= 1) -> arsize_dist[2] == 0;
        }
    }

    constraint arburst_dist_c {
        if (!fix_arburst_enable) {
            arburst_dist.sum == 100;
            arburst_dist.size() == AXI_MASTER_READ_BURST_DIST_NUM;
            foreach (arburst_dist[i]) arburst_dist[i] inside {[0:100]};
        }
    }

    constraint resp_dist_c {
        if (use_mem_model && !fix_araddr_enable) {
            resp_dist.sum == 100;
            resp_dist.size() == AXI_MASTER_READ_MEM_RESP_DIST_NUM;
            foreach (resp_dist[i]) resp_dist[i] inside {[0:100]};
        }
    }

    constraint ar_timing_candidate_solve_order_c {
        solve first_delay_segment before first_delay;
        solve fix_ar_delay_segment before ar_delay;
    }

    constraint first_delay_candidate_c {
        if (!fix_first_delay_enable) {
            first_delay_segment dist {
                AXI_MASTER_READ_TIMING_GAP_ZERO      := first_delay_type_dist[AXI_MASTER_READ_TIMING_GAP_ZERO],
                AXI_MASTER_READ_TIMING_GAP_SHORT     := first_delay_type_dist[AXI_MASTER_READ_TIMING_GAP_SHORT],
                AXI_MASTER_READ_TIMING_GAP_MID       := first_delay_type_dist[AXI_MASTER_READ_TIMING_GAP_MID],
                AXI_MASTER_READ_TIMING_GAP_LONG      := first_delay_type_dist[AXI_MASTER_READ_TIMING_GAP_LONG],
                AXI_MASTER_READ_TIMING_GAP_MAX_VALUE := first_delay_type_dist[AXI_MASTER_READ_TIMING_GAP_MAX_VALUE]
            };
            (first_delay_segment == AXI_MASTER_READ_TIMING_GAP_ZERO)      -> first_delay == 0;
            (first_delay_segment == AXI_MASTER_READ_TIMING_GAP_SHORT)     -> first_delay inside {[1:3]};
            (first_delay_segment == AXI_MASTER_READ_TIMING_GAP_MID)       -> first_delay inside {[4:10]};
            (first_delay_segment == AXI_MASTER_READ_TIMING_GAP_LONG)      -> first_delay inside {[11:31]};
            (first_delay_segment == AXI_MASTER_READ_TIMING_GAP_MAX_VALUE) -> first_delay inside {[32:63]};
        }
    }

    constraint fix_ar_delay_candidate_c {
        if (!fix_ar_delay_enable) {
            fix_ar_delay_segment dist {
            AXI_MASTER_READ_TIMING_GAP_ZERO      := ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_ZERO],
            AXI_MASTER_READ_TIMING_GAP_SHORT     := ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_SHORT],
            AXI_MASTER_READ_TIMING_GAP_MID       := ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_MID],
            AXI_MASTER_READ_TIMING_GAP_LONG      := ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_LONG],
            AXI_MASTER_READ_TIMING_GAP_MAX_VALUE := ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_MAX_VALUE]
            };
            (fix_ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_ZERO)      -> ar_delay == 0;
            (fix_ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_SHORT)     -> ar_delay inside {[1:9]};
            (fix_ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_MID)       -> ar_delay inside {[10:49]};
            (fix_ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_LONG)      -> ar_delay inside {[50:99]};
            (fix_ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_MAX_VALUE) -> ar_delay == 100;
        }
    }

    constraint ar_timing_type_dist_c {
        if (!fix_first_delay_enable) {
            first_delay_type_dist.sum == 100;
            first_delay_type_dist.size() == AXI_MASTER_READ_TIMING_GAP_TYPE_NUM;
            foreach (first_delay_type_dist[i]) first_delay_type_dist[i] inside {[0:100]};
        }
        if (!fix_ar_delay_enable) {
            ar_delay_dist.sum == 100;
            ar_delay_dist.size() == AXI_MASTER_READ_TIMING_GAP_TYPE_NUM;
            foreach (ar_delay_dist[i]) ar_delay_dist[i] inside {[0:100]};
        }
    }

    constraint rready_delay_type_dist_c {
        if (rready_mode == AXI_MASTER_READ_RREADY_AFTER_RVALID &&
            !fix_rready_delay_enable) {
            rready_delay_type_dist.sum == 100;
            rready_delay_type_dist.size() == AXI_MASTER_READ_DELAY_TYPE_NUM;
            foreach (rready_delay_type_dist[i]) rready_delay_type_dist[i] inside {[0:100]};
        }
    }

    constraint delay_value_c {
        first_delay inside {[0:63]};
        ar_delay inside {[0:100]};
        rready_delay inside {[0:63]};
    }

    constraint weight_value_c {
        (!fix_arlock_enable)   -> arlock_weight inside {[0:100]};
        (!fix_arcache_enable)  -> arcache_nonzero_weight inside {[0:100]};
        (!fix_arprot_enable)   -> arprot_nonzero_weight inside {[0:100]};
        (!fix_arqos_enable)    -> arqos_nonzero_weight inside {[0:100]};
        (!fix_arregion_enable) -> arregion_nonzero_weight inside {[0:100]};
        (!fix_aruser_enable)   -> aruser_nonzero_weight inside {[0:100]};
    }

    constraint enable_value_c {
        align_size inside {0, 1};
        use_mem_model inside {0, 1};
        addr_4k_protect_enable inside {0, 1};
        read_outstanding_depth inside {[1:256]};
        read_burst_count inside {
            [AXI_MASTER_READ_BURST_COUNT_MIN:AXI_MASTER_READ_BURST_COUNT_MAX]};
        fix_arid_enable inside {0, 1};
        fix_araddr_enable inside {0, 1};
        fix_arlen_enable inside {0, 1};
        fix_arsize_enable inside {0, 1};
        fix_arburst_enable inside {0, 1};
        fix_arlock_enable inside {0, 1};
        fix_arcache_enable inside {0, 1};
        fix_arprot_enable inside {0, 1};
        fix_arqos_enable inside {0, 1};
        fix_arregion_enable inside {0, 1};
        fix_aruser_enable inside {0, 1};
        fix_first_delay_enable inside {0, 1};
        fix_ar_delay_enable inside {0, 1};
        fix_rready_delay_enable inside {0, 1};
        (fix_arlen_enable) -> arlen inside {[0:AXI_MASTER_READ_MAX_BEATS-1]};
        (fix_arsize_enable) -> arsize inside {[0:BUS_SIZE]};
    }

endclass
`endif
