// ============================================================================
// Filename             : axi_master_write_config.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_WRITE_CONFIG_SV
`define AXI_MASTER_WRITE_CONFIG_SV
// Default-specialization compatibility helpers. Parameterized classes below
// derive their widths locally and must not use these package-wide aliases.
localparam int AXI_MASTER_WRITE_STRB_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH / 8;
localparam int AXI_WRITE_BUS_SIZE          = $clog2(AXI_MASTER_WRITE_STRB_WIDTH);
localparam int AXI_MASTER_WRITE_BURST_COUNT_MIN     = 1;
localparam int AXI_MASTER_WRITE_BURST_COUNT_MAX     = 1024;
localparam int AXI_MASTER_WRITE_BURST_COUNT_DEFAULT = 20;

localparam bit [AXI_MASTER_WRITE_ID_WIDTH-1:0]   AXI_MASTER_WRITE_ID_MAX   = '1;
localparam bit [AXI_MASTER_WRITE_ADDR_WIDTH-1:0] AXI_MASTER_WRITE_ADDR_MAX = '1;
localparam bit [AXI_MASTER_WRITE_USER_WIDTH-1:0] AXI_MASTER_WRITE_USER_MAX = '1;
localparam bit [AXI_MASTER_WRITE_STRB_WIDTH-1:0] AXI_MASTER_WRITE_STRB_ALL = '1;

typedef axi_burst_math #(
    AXI_MASTER_WRITE_ADDR_WIDTH,
    AXI_MASTER_WRITE_STRB_WIDTH
) axi_master_write_burst_math;

typedef enum bit [1:0] {
    AXI_MASTER_WRITE_BURST_FIXED = 2'b00,
    AXI_MASTER_WRITE_BURST_INCR  = 2'b01,
    AXI_MASTER_WRITE_BURST_WRAP  = 2'b10
} axi_master_write_burst_e;

typedef enum bit [1:0] {
    AXI_MASTER_WRITE_RESP_OKAY   = 2'b00,
    AXI_MASTER_WRITE_RESP_EXOKAY = 2'b01,
    AXI_MASTER_WRITE_RESP_SLVERR = 2'b10,
    AXI_MASTER_WRITE_RESP_DECERR = 2'b11
} axi_master_write_resp_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_ID_ZERO,
    AXI_MASTER_WRITE_ID_LOW,
    AXI_MASTER_WRITE_ID_HIGH,
    AXI_MASTER_WRITE_ID_MAX_VALUE
} axi_master_write_id_type_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_ADDR_OFFSET_ZERO,
    AXI_MASTER_WRITE_ADDR_OFFSET_LOW,
    AXI_MASTER_WRITE_ADDR_OFFSET_NORMAL,
    AXI_MASTER_WRITE_ADDR_OFFSET_HIGH,
    AXI_MASTER_WRITE_ADDR_OFFSET_MAX_VALUE
} axi_master_write_addr_offset_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_LEN_SINGLE,
    AXI_MASTER_WRITE_LEN_SHORT,
    AXI_MASTER_WRITE_LEN_MID,
    AXI_MASTER_WRITE_LEN_LONG,
    AXI_MASTER_WRITE_LEN_MAX_VALUE
} axi_master_write_len_type_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_DATA_RANDOM,
    AXI_MASTER_WRITE_DATA_INCREMENT,
    AXI_MASTER_WRITE_DATA_ADDR_BASED
} axi_master_write_data_type_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_DELAY_ZERO,
    AXI_MASTER_WRITE_DELAY_SHORT,
    AXI_MASTER_WRITE_DELAY_MID,
    AXI_MASTER_WRITE_DELAY_LONG,
    AXI_MASTER_WRITE_DELAY_MAX_VALUE
} axi_master_write_delay_type_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_AW_W_SAME,
    AXI_MASTER_WRITE_AW_FIRST,
    AXI_MASTER_WRITE_W_FIRST
} axi_master_write_aw_w_order_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_TIMING_DELAY_ZERO,
    AXI_MASTER_WRITE_TIMING_DELAY_SHORT,
    AXI_MASTER_WRITE_TIMING_DELAY_MID,
    AXI_MASTER_WRITE_TIMING_DELAY_LONG,
    AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE
} axi_master_write_timing_delay_segment_e;

typedef enum int unsigned {
    AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH,
    AXI_MASTER_WRITE_BREADY_AFTER_BVALID
} axi_master_write_bready_mode_e;

localparam int AXI_MASTER_WRITE_ID_TYPE_NUM            = 4;
localparam int AXI_MASTER_WRITE_ADDR_OFFSET_TYPE_NUM   = 5;
localparam int AXI_MASTER_WRITE_LEN_TYPE_NUM           = 5;
localparam int AXI_MASTER_WRITE_DATA_TYPE_NUM          = 3;
localparam int AXI_MASTER_WRITE_DELAY_TYPE_NUM         = 5;
localparam int AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM  = 5;
localparam int AXI_MASTER_WRITE_AW_W_ORDER_TYPE_NUM    = 3;
localparam int AXI_MASTER_WRITE_SIZE_DIST_NUM          = 3;
localparam int AXI_MASTER_WRITE_BURST_DIST_NUM         = 3;
localparam int AXI_MASTER_WRITE_MEM_RESP_DIST_NUM      = 3;

class axi_master_write_config #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends uvm_object;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(STRB_WIDTH);
    localparam bit [STRB_WIDTH-1:0] STRB_ALL = '1;

    typedef axi_master_write_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_write_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    typedef axi_write_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) monitor_cfg_t;
    //
    // Basic variables in config class.
    //
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    monitor_cfg_t monitor_cfg;

    vif_t axi_master_write_vif;

    // Random-address control. align_size clears the low AWSIZE bits of the
    // randomized page offset. Fixed AWADDR bypasses this alignment control.
    bit align_size = 0;
    bit addr_4k_protect_enable = 1;
    // Maximum protocol-active writes. A write becomes active on its first AW
    // or leading-W handshake and retires only on the matching B handshake.
    int unsigned write_outstanding_depth = 1;
    int unsigned write_burst_count = AXI_MASTER_WRITE_BURST_COUNT_DEFAULT;

    // Only use_mem_model enables response-directed page selection. Every
    // configured response segment is expected to contain complete 4KB pages.
    bit       use_mem_model = 0;
    mem_model memory_model;
    int unsigned size_resp_weight = 100;

    // Optional cfg fixed fields. Each enable defaults to 0. axi_multi_env_config
    // randomizes the scalar value candidates once when it creates this cfg, so
    // enabling a field without assigning its value fixes one random value.
    // A later project-level assignment, including an explicit zero, wins.
    bit fix_awid_enable = 0;
    rand bit [ID_WIDTH-1:0] awid;
    bit fix_awaddr_enable = 0;
    rand bit [ADDR_WIDTH-1:0] awaddr;
    bit fix_awlen_enable = 0;
    rand bit [7:0] awlen;
    bit fix_awsize_enable = 0;
    rand bit [2:0] awsize;
    bit fix_awburst_enable = 0;
    rand axi_master_write_burst_e awburst;
    bit fix_awlock_enable = 0;
    rand bit awlock;
    bit fix_awcache_enable = 0;
    rand bit [3:0] awcache;
    bit fix_awprot_enable = 0;
    rand bit [2:0] awprot;
    bit fix_awqos_enable = 0;
    rand bit [3:0] awqos;
    bit fix_awregion_enable = 0;
    rand bit [3:0] awregion;
    bit fix_awuser_enable = 0;
    rand bit [USER_WIDTH-1:0] awuser;
    // WUSER is generated independently for every W beat unless this scalar
    // override is enabled.
    bit fix_wuser_enable = 0;
    rand bit [USER_WIDTH-1:0] wuser;
    bit fix_wdata_type_enable = 0;
    rand axi_master_write_data_type_e wdata_type;
    bit fix_wdata_enable = 0;
    rand bit [DATA_WIDTH-1:0] wdata;
    bit fix_wdata_array_enable = 0;
    rand bit [DATA_WIDTH-1:0] wdata_array[];
    bit fix_wstrb_enable = 0;
    rand bit [STRB_WIDTH-1:0] wstrb;
    bit fix_wstrb_array_enable = 0;
    rand bit [STRB_WIDTH-1:0] wstrb_array[];

    // Write request timing controls:
    // - first_delay is measured from reset release to the earliest
    //   first source VALID issue. aw_w_delay decides whether that source is AW,
    //   W, or both. A packet arriving after the deadline starts immediately.
    // - aw_w_order selects SAME, AW-first or W-first for each packet.
    // - aw_w_delay is the earliest trailing-VALID issue offset from the
    //   leading VALID. Queue ordering may increase the observed interval.
    // - pkg_delay belongs to the current packet and is measured from the
    //   previous packet's order-selected handshake anchor.
    // - w_delay is the fixed delay candidate between handshaken W beats.
    //   When unfixed, every inter-beat gap is selected independently from
    //   w_delay_dist by the sequence item.
    // With fix_first_delay_enable=0, the driver selects one delay per
    // reset release. AW/W order, AW/W delay and packet delay remain per-packet
    // random values; W delay is independently randomized per inter-beat gap.
    bit fix_first_delay_enable = 0;
    rand int unsigned first_delay = 0;
    bit fix_aw_w_order_enable = 0;
    rand axi_master_write_aw_w_order_e aw_w_order =
        AXI_MASTER_WRITE_AW_W_SAME;
    bit fix_aw_w_delay_enable = 0;
    rand int unsigned aw_w_delay = 0;
    bit fix_pkg_delay_enable = 0;
    rand int unsigned pkg_delay = 0;
    bit fix_w_delay_enable = 0;
    rand int unsigned w_delay = 0;

    // Internal helpers for reset-level first_delay and per-packet timing.
    rand axi_master_write_timing_delay_segment_e first_delay_segment;
    rand axi_master_write_timing_delay_segment_e aw_w_delay_segment;
    rand axi_master_write_timing_delay_segment_e pkg_delay_segment;
    rand axi_master_write_timing_delay_segment_e w_delay_segment;

    // BREADY timing mode:
    // - ALWAYS_HIGH: master keeps BREADY high after reset.
    // - AFTER_BVALID: master waits for BVALID, then applies bready_delay.
    axi_master_write_bready_mode_e bready_mode = AXI_MASTER_WRITE_BREADY_AFTER_BVALID;
    bit fix_bready_delay_enable = 0;
    rand int unsigned bready_delay = 0;

    //
    // Declare user random config informations.
    //
    // Base seq_item random weights/distributions:
    // - awid_type_dist controls awid boundary/random segment.
    // - awaddr_offset_dist controls the randomized 4KB page offset.
    // - awlen_type_dist controls awlen burst length segment.
    // - awsize_dist controls MIN/MIDDLE/FULL category weights when neither a
    //   fixed SIZE nor Mem Model SIZE selection is active.
    // - awburst_dist controls FIXED/INCR/WRAP selection.
    // - wdata_type_dist controls auto-payload generator selection:
    //   RANDOM / INCREMENT / ADDR_BASED (constant patterns use fix_wdata).
    rand int unsigned awid_type_dist[];
    rand int unsigned awaddr_offset_dist[];
    rand int unsigned awlen_type_dist[];
    rand int unsigned awsize_dist[AXI_MASTER_WRITE_SIZE_DIST_NUM];
    rand int unsigned awburst_dist[];
    // Array order: OKAY, SLVERR, DECERR.
    rand int unsigned resp_dist[];
    rand int unsigned wdata_type_dist[];
    // Source timing arrays follow axi_master_write_timing_delay_segment_e.
    // first_delay_type_dist is sampled once per reset; all other timing
    // selections are made independently for every packet.
    rand int unsigned first_delay_type_dist[];
    rand int unsigned aw_w_order_dist[];
    rand int unsigned aw_w_delay_dist[];
    rand int unsigned pkg_delay_dist[];
    rand int unsigned w_delay_dist[];

    // Binary/zero-vs-nonzero signal weights. The signal is randomized with:
    // 0 : 100 - xxx_weight, 1/nonzero : xxx_weight.
    rand int unsigned awlock_weight;
    rand int unsigned awcache_nonzero_weight;
    rand int unsigned awprot_nonzero_weight;
    rand int unsigned awqos_nonzero_weight;
    rand int unsigned awregion_nonzero_weight;
    rand int unsigned awuser_nonzero_weight;
    rand int unsigned wuser_nonzero_weight;

    // bready_delay_type_dist is used only when bready_mode is
    // AXI_MASTER_WRITE_BREADY_AFTER_BVALID and fix_bready_delay_enable is 0.
    rand int unsigned bready_delay_type_dist[];

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_enum         (uvm_active_passive_enum,   is_active,      UVM_DEFAULT)
        `uvm_field_object       (monitor_cfg,                               UVM_DEFAULT)
        `uvm_field_int          (align_size,                               UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (addr_4k_protect_enable,                    UVM_DEFAULT)
        `uvm_field_int          (write_outstanding_depth,                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (write_burst_count,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (use_mem_model,                            UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (size_resp_weight,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_awid_enable,                      UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awid,                             UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_awaddr_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awaddr,                           UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_awlen_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awlen,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_awsize_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awsize,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_awburst_enable,                   UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum         (axi_master_write_burst_e, awburst,       UVM_DEFAULT)
        `uvm_field_int          (fix_awlock_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awlock,                           UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (fix_awcache_enable,                   UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awcache,                          UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_awprot_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awprot,                           UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_awqos_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awqos,                            UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_awregion_enable,                  UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awregion,                         UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_awuser_enable,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (awuser,                           UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_wuser_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (wuser,                            UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_wdata_type_enable,                UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum         (axi_master_write_data_type_e, wdata_type, UVM_DEFAULT)
        `uvm_field_int          (fix_wdata_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (wdata,                            UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_wdata_array_enable,               UVM_DEFAULT | UVM_BIN)
        `uvm_field_array_int    (wdata_array,                      UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_wstrb_enable,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (wstrb,                            UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_wstrb_array_enable,               UVM_DEFAULT | UVM_BIN)
        `uvm_field_array_int    (wstrb_array,                      UVM_DEFAULT | UVM_HEX)
        `uvm_field_int          (fix_first_delay_enable,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (first_delay,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_aw_w_order_enable,                         UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum         (axi_master_write_aw_w_order_e, aw_w_order, UVM_DEFAULT)
        `uvm_field_int          (fix_aw_w_delay_enable,                         UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (aw_w_delay,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_pkg_delay_enable,                          UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (pkg_delay,                                 UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_w_delay_enable,                            UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (w_delay,                                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_bready_delay_enable,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int          (bready_delay,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum         (axi_master_write_bready_mode_e, bready_mode,      UVM_DEFAULT)
        `uvm_field_array_int    (awid_type_dist,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (awaddr_offset_dist,                        UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (awlen_type_dist,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_sarray_int   (awsize_dist,                               UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (awburst_dist,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (resp_dist,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (wdata_type_dist,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (first_delay_type_dist,                     UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (aw_w_order_dist,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (aw_w_delay_dist,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (pkg_delay_dist,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (w_delay_dist,                              UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (awlock_weight,                             UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (awcache_nonzero_weight,                    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (awprot_nonzero_weight,                     UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (awqos_nonzero_weight,                      UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (awregion_nonzero_weight,                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (awuser_nonzero_weight,                     UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (wuser_nonzero_weight,                      UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (bready_delay_type_dist,                    UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "axi_master_write_config");
        super.new(name);
        monitor_cfg = monitor_cfg_t::type_id::create(
            {name, "_monitor_cfg"});
        if (monitor_cfg == null) begin
            `uvm_fatal("AXI_CFG", "Failed to create Master Write monitor cfg")
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
        if (!is_valid_max_beats(AXI_MASTER_WRITE_MAX_BEATS)) begin
            `uvm_fatal("AXI_CFG", "AXI_MASTER_WRITE_MAX_BEATS must be in [16:256]")
        end

        awid       = '0;
        awaddr     = '0;
        awlen      = '0;
        awsize     = BUS_SIZE;
        awburst    = AXI_MASTER_WRITE_BURST_INCR;
        awlock     = '0;
        awcache    = '0;
        awprot     = '0;
        awqos      = '0;
        awregion   = '0;
        awuser     = '0;
        wuser      = '0;
        wdata_type = AXI_MASTER_WRITE_DATA_RANDOM;
        wdata      = '0;
        wstrb      = STRB_ALL;

        awlock_weight           = 20;
        awcache_nonzero_weight  = 20;
        awprot_nonzero_weight   = 20;
        awqos_nonzero_weight    = 20;
        awregion_nonzero_weight = 20;
        awuser_nonzero_weight   = 20;
        wuser_nonzero_weight    = 20;

        awid_type_dist          = new[AXI_MASTER_WRITE_ID_TYPE_NUM];
        awaddr_offset_dist      = new[AXI_MASTER_WRITE_ADDR_OFFSET_TYPE_NUM];
        awlen_type_dist         = new[AXI_MASTER_WRITE_LEN_TYPE_NUM];
        awburst_dist            = new[AXI_MASTER_WRITE_BURST_DIST_NUM];
        resp_dist               = new[AXI_MASTER_WRITE_MEM_RESP_DIST_NUM];
        wdata_type_dist         = new[AXI_MASTER_WRITE_DATA_TYPE_NUM];
        first_delay_type_dist  = new[AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM];
        aw_w_order_dist         = new[AXI_MASTER_WRITE_AW_W_ORDER_TYPE_NUM];
        aw_w_delay_dist         = new[AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM];
        pkg_delay_dist          = new[AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM];
        w_delay_dist            = new[AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM];
        bready_delay_type_dist  = new[AXI_MASTER_WRITE_DELAY_TYPE_NUM];

        awid_type_dist          = '{25, 25, 25, 25};
        awaddr_offset_dist      = '{5, 15, 60, 10, 10};
        awlen_type_dist         = '{30, 30, 20, 15, 5};
        if (BUS_SIZE == 0) begin
            awsize_dist = '{100, 0, 0};
        end
        else if (BUS_SIZE == 1) begin
            awsize_dist = '{50, 50, 0};
        end
        else begin
            awsize_dist = '{34, 33, 33};
        end
        awburst_dist            = '{15, 70, 15};
        resp_dist               = '{60, 20, 20};
        wdata_type_dist         = '{60, 25, 15};
        first_delay_type_dist  = '{20, 20, 20, 20, 20};
        aw_w_order_dist         = '{34, 33, 33};
        aw_w_delay_dist         = '{20, 20, 20, 20, 20};
        pkg_delay_dist          = '{20, 20, 20, 20, 20};
        w_delay_dist            = '{20, 20, 20, 20, 20};
        bready_delay_type_dist  = '{20, 20, 20, 20, 20};
    endfunction : new

    // Randomize independent scalar fixed-value defaults. Array payloads are
    // intentionally excluded and must be provided explicitly by callers;
    // their sizes never select or constrain AWLEN. Cross-field legality is
    // checked only on the final request before either source VALID is driven.
    function bit randomize_fixed_value_defaults();
        string saved_randstate;
        bit saved_fix_awid_enable;
        bit saved_fix_awaddr_enable;
        bit saved_fix_awlen_enable;
        bit saved_fix_awsize_enable;
        bit saved_fix_awburst_enable;
        bit saved_fix_awlock_enable;
        bit saved_fix_awcache_enable;
        bit saved_fix_awprot_enable;
        bit saved_fix_awqos_enable;
        bit saved_fix_awregion_enable;
        bit saved_fix_awuser_enable;
        bit saved_fix_wuser_enable;
        bit saved_fix_wdata_type_enable;
        bit saved_fix_wdata_enable;
        bit saved_fix_wdata_array_enable;
        bit saved_fix_wstrb_enable;
        bit saved_fix_wstrb_array_enable;
        bit saved_fix_first_delay_enable;
        bit saved_fix_aw_w_order_enable;
        bit saved_fix_aw_w_delay_enable;
        bit saved_fix_pkg_delay_enable;
        bit saved_fix_w_delay_enable;
        bit saved_fix_bready_delay_enable;

        saved_randstate = this.get_randstate();
        saved_fix_awid_enable = fix_awid_enable;
        saved_fix_awaddr_enable = fix_awaddr_enable;
        saved_fix_awlen_enable = fix_awlen_enable;
        saved_fix_awsize_enable = fix_awsize_enable;
        saved_fix_awburst_enable = fix_awburst_enable;
        saved_fix_awlock_enable = fix_awlock_enable;
        saved_fix_awcache_enable = fix_awcache_enable;
        saved_fix_awprot_enable = fix_awprot_enable;
        saved_fix_awqos_enable = fix_awqos_enable;
        saved_fix_awregion_enable = fix_awregion_enable;
        saved_fix_awuser_enable = fix_awuser_enable;
        saved_fix_wuser_enable = fix_wuser_enable;
        saved_fix_wdata_type_enable = fix_wdata_type_enable;
        saved_fix_wdata_enable = fix_wdata_enable;
        saved_fix_wdata_array_enable = fix_wdata_array_enable;
        saved_fix_wstrb_enable = fix_wstrb_enable;
        saved_fix_wstrb_array_enable = fix_wstrb_array_enable;
        saved_fix_first_delay_enable = fix_first_delay_enable;
        saved_fix_aw_w_order_enable = fix_aw_w_order_enable;
        saved_fix_aw_w_delay_enable = fix_aw_w_delay_enable;
        saved_fix_pkg_delay_enable = fix_pkg_delay_enable;
        saved_fix_w_delay_enable = fix_w_delay_enable;
        saved_fix_bready_delay_enable = fix_bready_delay_enable;

        fix_awid_enable = 1'b1;
        fix_awaddr_enable = 1'b1;
        fix_awlen_enable = 1'b1;
        fix_awsize_enable = 1'b1;
        fix_awburst_enable = 1'b1;
        fix_awlock_enable = 1'b1;
        fix_awcache_enable = 1'b1;
        fix_awprot_enable = 1'b1;
        fix_awqos_enable = 1'b1;
        fix_awregion_enable = 1'b1;
        fix_awuser_enable = 1'b1;
        fix_wuser_enable = 1'b1;
        fix_wdata_type_enable = 1'b1;
        fix_wdata_enable = 1'b1;
        fix_wdata_array_enable = 1'b0;
        fix_wstrb_enable = 1'b1;
        fix_wstrb_array_enable = 1'b0;
        fix_first_delay_enable = 1'b1;
        fix_aw_w_order_enable = 1'b1;
        fix_aw_w_delay_enable = 1'b1;
        fix_pkg_delay_enable = 1'b1;
        fix_w_delay_enable = 1'b1;
        fix_bready_delay_enable = 1'b1;

        randomize_fixed_value_defaults = this.randomize(
            awid,
            awaddr,
            awlen,
            awsize,
            awburst,
            awlock,
            awcache,
            awprot,
            awqos,
            awregion,
            awuser,
            wuser,
            wdata_type,
            wdata,
            wstrb,
            first_delay,
            aw_w_order,
            aw_w_delay,
            pkg_delay,
            w_delay,
            first_delay_segment,
            aw_w_delay_segment,
            pkg_delay_segment,
            w_delay_segment,
            bready_delay
        ) with {
            axi_cache_is_legal(awcache);
        };
        this.set_randstate(saved_randstate);

        fix_awid_enable = saved_fix_awid_enable;
        fix_awaddr_enable = saved_fix_awaddr_enable;
        fix_awlen_enable = saved_fix_awlen_enable;
        fix_awsize_enable = saved_fix_awsize_enable;
        fix_awburst_enable = saved_fix_awburst_enable;
        fix_awlock_enable = saved_fix_awlock_enable;
        fix_awcache_enable = saved_fix_awcache_enable;
        fix_awprot_enable = saved_fix_awprot_enable;
        fix_awqos_enable = saved_fix_awqos_enable;
        fix_awregion_enable = saved_fix_awregion_enable;
        fix_awuser_enable = saved_fix_awuser_enable;
        fix_wuser_enable = saved_fix_wuser_enable;
        fix_wdata_type_enable = saved_fix_wdata_type_enable;
        fix_wdata_enable = saved_fix_wdata_enable;
        fix_wdata_array_enable = saved_fix_wdata_array_enable;
        fix_wstrb_enable = saved_fix_wstrb_enable;
        fix_wstrb_array_enable = saved_fix_wstrb_array_enable;
        fix_first_delay_enable = saved_fix_first_delay_enable;
        fix_aw_w_order_enable = saved_fix_aw_w_order_enable;
        fix_aw_w_delay_enable = saved_fix_aw_w_delay_enable;
        fix_pkg_delay_enable = saved_fix_pkg_delay_enable;
        fix_w_delay_enable = saved_fix_w_delay_enable;
        fix_bready_delay_enable = saved_fix_bready_delay_enable;
    endfunction : randomize_fixed_value_defaults

    // Select one reset-to-first-source-VALID delay for a driver reset
    // epoch. The driver caches the value until the next reset.
    function bit select_first_delay(
        output int unsigned selected_delay
    );
        int unsigned selection;
        int unsigned cumulative;

        if (fix_first_delay_enable) begin
            if (first_delay > 63) begin
                selected_delay = 0;
                return 1'b0;
            end
            selected_delay = first_delay;
            return 1'b1;
        end
        if (first_delay_type_dist.size() !=
                AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM ||
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
                    AXI_MASTER_WRITE_TIMING_DELAY_ZERO:
                        selected_delay = 0;
                    AXI_MASTER_WRITE_TIMING_DELAY_SHORT:
                        selected_delay = $urandom_range(3, 1);
                    AXI_MASTER_WRITE_TIMING_DELAY_MID:
                        selected_delay = $urandom_range(10, 4);
                    AXI_MASTER_WRITE_TIMING_DELAY_LONG:
                        selected_delay = $urandom_range(31, 11);
                    AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE:
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
                    "MASTER_WRITE_PLUSARG_RANGE");
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
                    key, value), "MASTER_WRITE_PLUSARG_DIST_RANGE");
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
    // its matching fix_*_enable switch implicitly. Dynamic payload arrays are
    // replaced atomically only when ARRAY_SIZE and every indexed value parse.
    function bit get_args(
        string                    prefix,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report
    );
        int unsigned                errors_before;
        longint unsigned            uint_value;
        uvm_bitstream_t             hex_value;
        string                      raw_value;
        string                      normalized;
        int signed                  enum_value;
        string                      key;
        bit                         array_complete;
        bit [DATA_WIDTH-1:0]        parsed_wdata_array[];
        bit [STRB_WIDTH-1:0]        parsed_wstrb_array[];

        if (parser == null) begin
            `uvm_fatal("AXI_CFG_PLUSARG", $sformatf(
                "Master Write cfg prefix=%s received null parser", prefix))
            return 1'b0;
        end
        if (report == null) begin
            `uvm_fatal("AXI_CFG_PLUSARG", $sformatf(
                "Master Write cfg prefix=%s received null report", prefix))
            return 1'b0;
        end
        errors_before = report.error_count;
        if (prefix.len() == 0) begin
            report.invalid(get_full_name(),
                "actual_plusarg_prefix=empty expected=non-empty",
                "MASTER_WRITE_PLUSARG_PREFIX_EMPTY");
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
                            key, raw_value), "MASTER_WRITE_PLUSARG_ENUM");
                end
            endcase
        end

        get_plusarg_bit(prefix, "ALIGN_SIZE", parser, report, align_size);
        get_plusarg_bit(prefix, "ADDR_4K_PROTECT_ENABLE", parser, report,
            addr_4k_protect_enable);
        get_plusarg_uint(prefix, "WRITE_OUTSTANDING_DEPTH", parser, report,
            write_outstanding_depth, 1, 256);
        get_plusarg_uint(prefix, "WRITE_BURST_COUNT", parser, report,
            write_burst_count, AXI_MASTER_WRITE_BURST_COUNT_MIN,
            AXI_MASTER_WRITE_BURST_COUNT_MAX);
        get_plusarg_bit(prefix, "USE_MEM_MODEL", parser, report,
            use_mem_model);
        get_plusarg_uint(prefix, "SIZE_RESP_WEIGHT", parser, report,
            size_resp_weight, 0, 100);

        get_plusarg_bit(prefix, "FIX_AWID_EN", parser, report, fix_awid_enable);
        key = {prefix, "_AWID"};
        if (parser.get_hex(key, prefix, report, ID_WIDTH, hex_value))
            awid = hex_value;
        get_plusarg_bit(prefix, "FIX_AWADDR_EN", parser, report,
            fix_awaddr_enable);
        key = {prefix, "_AWADDR"};
        if (parser.get_hex(key, prefix, report, ADDR_WIDTH, hex_value))
            awaddr = hex_value;
        get_plusarg_bit(prefix, "FIX_AWLEN_EN", parser, report, fix_awlen_enable);
        key = {prefix, "_AWLEN"};
        if (parser.get_uint(key, prefix, report, uint_value)) begin
            if (uint_value >= AXI_MASTER_WRITE_MAX_BEATS)
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:%0d]", key,
                    uint_value, AXI_MASTER_WRITE_MAX_BEATS-1),
                    "MASTER_WRITE_PLUSARG_RANGE");
            else
                awlen = uint_value[7:0];
        end
        get_plusarg_bit(prefix, "FIX_AWSIZE_EN", parser, report,
            fix_awsize_enable);
        key = {prefix, "_AWSIZE"};
        if (parser.get_uint(key, prefix, report, uint_value)) begin
            if (uint_value > BUS_SIZE)
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:%0d]",
                    key, uint_value, BUS_SIZE), "MASTER_WRITE_PLUSARG_RANGE");
            else
                awsize = uint_value[2:0];
        end
        get_plusarg_bit(prefix, "FIX_AWBURST_EN", parser, report,
            fix_awburst_enable);
        key = {prefix, "_AWBURST"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "FIXED", "AXI_MASTER_WRITE_BURST_FIXED":
                    awburst = AXI_MASTER_WRITE_BURST_FIXED;
                "INCR", "AXI_MASTER_WRITE_BURST_INCR":
                    awburst = AXI_MASTER_WRITE_BURST_INCR;
                "WRAP", "AXI_MASTER_WRITE_BURST_WRAP":
                    awburst = AXI_MASTER_WRITE_BURST_WRAP;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 2, enum_value))
                        awburst = axi_master_write_burst_e'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            "key=%s actual=%s expected={FIXED,INCR,WRAP,0,1,2}",
                            key, raw_value), "MASTER_WRITE_PLUSARG_ENUM");
                end
            endcase
        end
        get_plusarg_bit(prefix, "FIX_AWLOCK_EN", parser, report,
            fix_awlock_enable);
        get_plusarg_bit(prefix, "AWLOCK", parser, report, awlock);
        get_plusarg_bit(prefix, "FIX_AWCACHE_EN", parser, report,
            fix_awcache_enable);
        key = {prefix, "_AWCACHE"};
        if (parser.get_hex(key, prefix, report, 4, hex_value))
            awcache = hex_value;
        get_plusarg_bit(prefix, "FIX_AWPROT_EN", parser, report,
            fix_awprot_enable);
        key = {prefix, "_AWPROT"};
        if (parser.get_hex(key, prefix, report, 3, hex_value))
            awprot = hex_value;
        get_plusarg_bit(prefix, "FIX_AWQOS_EN", parser, report,
            fix_awqos_enable);
        key = {prefix, "_AWQOS"};
        if (parser.get_hex(key, prefix, report, 4, hex_value))
            awqos = hex_value;
        get_plusarg_bit(prefix, "FIX_AWREGION_EN", parser, report,
            fix_awregion_enable);
        key = {prefix, "_AWREGION"};
        if (parser.get_hex(key, prefix, report, 4, hex_value))
            awregion = hex_value;
        get_plusarg_bit(prefix, "FIX_AWUSER_EN", parser, report,
            fix_awuser_enable);
        key = {prefix, "_AWUSER"};
        if (parser.get_hex(key, prefix, report, USER_WIDTH, hex_value))
            awuser = hex_value;
        get_plusarg_bit(prefix, "FIX_WUSER_EN", parser, report,
            fix_wuser_enable);
        key = {prefix, "_WUSER"};
        if (parser.get_hex(key, prefix, report, USER_WIDTH, hex_value))
            wuser = hex_value;

        get_plusarg_bit(prefix, "FIX_WDATA_TYPE_EN", parser, report,
            fix_wdata_type_enable);
        key = {prefix, "_WDATA_TYPE"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "RANDOM", "AXI_MASTER_WRITE_DATA_RANDOM":
                    wdata_type = AXI_MASTER_WRITE_DATA_RANDOM;
                "INCREMENT", "AXI_MASTER_WRITE_DATA_INCREMENT":
                    wdata_type = AXI_MASTER_WRITE_DATA_INCREMENT;
                "ADDR_BASED", "AXI_MASTER_WRITE_DATA_ADDR_BASED":
                    wdata_type = AXI_MASTER_WRITE_DATA_ADDR_BASED;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 2, enum_value))
                        wdata_type = axi_master_write_data_type_e'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            {"key=%s actual=%s expected=",
                             "{RANDOM,INCREMENT,ADDR_BASED,0,1,2}"},
                            key, raw_value), "MASTER_WRITE_PLUSARG_ENUM");
                end
            endcase
        end
        get_plusarg_bit(prefix, "FIX_WDATA_EN", parser, report,
            fix_wdata_enable);
        key = {prefix, "_WDATA"};
        if (parser.get_hex(key, prefix, report, DATA_WIDTH, hex_value))
            wdata = hex_value;
        get_plusarg_bit(prefix, "FIX_WDATA_ARRAY_EN", parser, report,
            fix_wdata_array_enable);
        key = {prefix, "_WDATA_ARRAY_SIZE"};
        if (parser.get_uint(key, prefix, report, uint_value)) begin
            if (uint_value > AXI_MASTER_WRITE_MAX_BEATS) begin
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:%0d]", key,
                    uint_value, AXI_MASTER_WRITE_MAX_BEATS),
                    "MASTER_WRITE_PLUSARG_ARRAY_SIZE");
            end
            else begin
                parsed_wdata_array = new[int'(uint_value)];
                array_complete = 1'b1;
                foreach (parsed_wdata_array[i]) begin
                    key = $sformatf("%s_WDATA_ARRAY_%0d", prefix, i);
                    if (parser.get_hex(key, prefix, report, DATA_WIDTH,
                            hex_value))
                        parsed_wdata_array[i] = hex_value;
                    else begin
                        array_complete = 1'b0;
                        report.invalid(prefix, $sformatf(
                            "key=%s expected=present_valid_hex_value", key),
                            "MASTER_WRITE_PLUSARG_ARRAY_INCOMPLETE");
                    end
                end
                if (array_complete)
                    wdata_array = parsed_wdata_array;
            end
        end

        get_plusarg_bit(prefix, "FIX_WSTRB_EN", parser, report,
            fix_wstrb_enable);
        key = {prefix, "_WSTRB"};
        if (parser.get_hex(key, prefix, report, STRB_WIDTH, hex_value))
            wstrb = hex_value;
        get_plusarg_bit(prefix, "FIX_WSTRB_ARRAY_EN", parser, report,
            fix_wstrb_array_enable);
        key = {prefix, "_WSTRB_ARRAY_SIZE"};
        if (parser.get_uint(key, prefix, report, uint_value)) begin
            if (uint_value > AXI_MASTER_WRITE_MAX_BEATS) begin
                report.invalid(prefix, $sformatf(
                    "key=%s actual=%0d expected_range=[0:%0d]", key,
                    uint_value, AXI_MASTER_WRITE_MAX_BEATS),
                    "MASTER_WRITE_PLUSARG_ARRAY_SIZE");
            end
            else begin
                parsed_wstrb_array = new[int'(uint_value)];
                array_complete = 1'b1;
                foreach (parsed_wstrb_array[i]) begin
                    key = $sformatf("%s_WSTRB_ARRAY_%0d", prefix, i);
                    if (parser.get_hex(key, prefix, report, STRB_WIDTH,
                            hex_value))
                        parsed_wstrb_array[i] = hex_value;
                    else begin
                        array_complete = 1'b0;
                        report.invalid(prefix, $sformatf(
                            "key=%s expected=present_valid_hex_value", key),
                            "MASTER_WRITE_PLUSARG_ARRAY_INCOMPLETE");
                    end
                end
                if (array_complete)
                    wstrb_array = parsed_wstrb_array;
            end
        end

        get_plusarg_bit(prefix, "FIX_FIRST_DELAY_EN", parser, report,
            fix_first_delay_enable);
        get_plusarg_uint(prefix, "FIRST_DELAY", parser, report, first_delay,
            0, 63);
        get_plusarg_bit(prefix, "FIX_AW_W_ORDER_EN", parser, report,
            fix_aw_w_order_enable);
        key = {prefix, "_AW_W_ORDER"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "SAME", "AXI_MASTER_WRITE_AW_W_SAME":
                    aw_w_order = AXI_MASTER_WRITE_AW_W_SAME;
                "AW_FIRST", "AXI_MASTER_WRITE_AW_FIRST":
                    aw_w_order = AXI_MASTER_WRITE_AW_FIRST;
                "W_FIRST", "AXI_MASTER_WRITE_W_FIRST":
                    aw_w_order = AXI_MASTER_WRITE_W_FIRST;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 2, enum_value))
                        aw_w_order = axi_master_write_aw_w_order_e'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            "key=%s actual=%s expected={SAME,AW_FIRST,W_FIRST,0,1,2}",
                            key, raw_value), "MASTER_WRITE_PLUSARG_ENUM");
                end
            endcase
        end
        get_plusarg_bit(prefix, "FIX_AW_W_DELAY_EN", parser, report,
            fix_aw_w_delay_enable);
        get_plusarg_uint(prefix, "AW_W_DELAY", parser, report, aw_w_delay,
            0, 63);
        get_plusarg_bit(prefix, "FIX_PKG_DELAY_EN", parser, report,
            fix_pkg_delay_enable);
        get_plusarg_uint(prefix, "PKG_DELAY", parser, report, pkg_delay,
            0, 63);
        get_plusarg_bit(prefix, "FIX_W_DELAY_EN", parser, report,
            fix_w_delay_enable);
        get_plusarg_uint(prefix, "W_DELAY", parser, report, w_delay,
            0, 63);

        key = {prefix, "_BREADY_MODE"};
        if (parser.get_raw(key, prefix, report, raw_value)) begin
            normalized = raw_value.toupper();
            case (normalized)
                "ALWAYS_HIGH", "AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH":
                    bready_mode = AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH;
                "AFTER_BVALID", "AXI_MASTER_WRITE_BREADY_AFTER_BVALID":
                    bready_mode = AXI_MASTER_WRITE_BREADY_AFTER_BVALID;
                default: begin
                    if (parse_plusarg_enum_number(raw_value, 1, enum_value))
                        bready_mode = axi_master_write_bready_mode_e'(enum_value);
                    else
                        report.invalid(prefix, $sformatf(
                            "key=%s actual=%s expected={ALWAYS_HIGH,AFTER_BVALID,0,1}",
                            key, raw_value), "MASTER_WRITE_PLUSARG_ENUM");
                end
            endcase
        end
        get_plusarg_bit(prefix, "FIX_BREADY_DELAY_EN", parser, report,
            fix_bready_delay_enable);
        get_plusarg_uint(prefix, "BREADY_DELAY", parser, report,
            bready_delay, 0, 63);

        foreach (awid_type_dist[i])
            get_plusarg_dist_element(prefix, "AWID_TYPE_DIST", i, parser,
                report, awid_type_dist[i]);
        foreach (awaddr_offset_dist[i])
            get_plusarg_dist_element(prefix, "AWADDR_OFFSET_DIST", i,
                parser, report, awaddr_offset_dist[i]);
        foreach (awlen_type_dist[i])
            get_plusarg_dist_element(prefix, "AWLEN_TYPE_DIST", i, parser,
                report, awlen_type_dist[i]);
        foreach (awsize_dist[i])
            get_plusarg_dist_element(prefix, "AWSIZE_DIST", i, parser,
                report, awsize_dist[i]);
        foreach (awburst_dist[i])
            get_plusarg_dist_element(prefix, "AWBURST_DIST", i, parser,
                report, awburst_dist[i]);
        foreach (resp_dist[i])
            get_plusarg_dist_element(prefix, "RESP_DIST", i, parser,
                report, resp_dist[i]);
        foreach (wdata_type_dist[i])
            get_plusarg_dist_element(prefix, "WDATA_TYPE_DIST", i, parser,
                report, wdata_type_dist[i]);
        foreach (first_delay_type_dist[i])
            get_plusarg_dist_element(prefix, "FIRST_DELAY_TYPE_DIST", i,
                parser, report, first_delay_type_dist[i]);
        foreach (aw_w_order_dist[i])
            get_plusarg_dist_element(prefix, "AW_W_ORDER_DIST", i, parser,
                report, aw_w_order_dist[i]);
        foreach (aw_w_delay_dist[i])
            get_plusarg_dist_element(prefix, "AW_W_DELAY_DIST", i, parser,
                report, aw_w_delay_dist[i]);
        foreach (pkg_delay_dist[i])
            get_plusarg_dist_element(prefix, "PKG_DELAY_DIST", i, parser,
                report, pkg_delay_dist[i]);
        foreach (w_delay_dist[i])
            get_plusarg_dist_element(prefix, "W_DELAY_DIST", i, parser,
                report, w_delay_dist[i]);
        foreach (bready_delay_type_dist[i])
            get_plusarg_dist_element(prefix, "BREADY_DELAY_TYPE_DIST", i,
                parser, report, bready_delay_type_dist[i]);

        get_plusarg_uint(prefix, "AWLOCK_WEIGHT", parser, report,
            awlock_weight, 0, 100);
        get_plusarg_uint(prefix, "AWCACHE_NONZERO_WEIGHT", parser, report,
            awcache_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "AWPROT_NONZERO_WEIGHT", parser, report,
            awprot_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "AWQOS_NONZERO_WEIGHT", parser, report,
            awqos_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "AWREGION_NONZERO_WEIGHT", parser, report,
            awregion_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "AWUSER_NONZERO_WEIGHT", parser, report,
            awuser_nonzero_weight, 0, 100);
        get_plusarg_uint(prefix, "WUSER_NONZERO_WEIGHT", parser, report,
            wuser_nonzero_weight, 0, 100);

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
        non_wrap_burst_possible = fix_awburst_enable ?
            (awburst != AXI_MASTER_WRITE_BURST_WRAP) : 1'b1;
        if (!fix_awburst_enable &&
            awburst_dist.size() == AXI_MASTER_WRITE_BURST_DIST_NUM)
            non_wrap_burst_possible =
                (awburst_dist[AXI_MASTER_WRITE_BURST_FIXED] +
                 awburst_dist[AXI_MASTER_WRITE_BURST_INCR]) != 0;

        if (!(write_outstanding_depth inside {[1:256]}))
            report.invalid(scope, $sformatf(
                "actual_write_outstanding_depth=%0d expected_range=[1:256]",
                write_outstanding_depth), "MASTER_WRITE_OUTSTANDING_DEPTH_RANGE");
        if (!(is_active inside {UVM_ACTIVE, UVM_PASSIVE}))
            report.invalid(scope, $sformatf(
                "actual_is_active=%0d expected={UVM_ACTIVE,UVM_PASSIVE}",
                is_active), "MASTER_WRITE_ACTIVE_MODE");
        if (is_active == UVM_PASSIVE) begin
            validate_cfg = report.error_count == errors_before;
            return validate_cfg;
        end
        if (!(write_burst_count inside {
                [AXI_MASTER_WRITE_BURST_COUNT_MIN:AXI_MASTER_WRITE_BURST_COUNT_MAX]}))
            report.invalid(scope, $sformatf(
                "actual_write_burst_count=%0d expected_range=[%0d:%0d]",
                write_burst_count, AXI_MASTER_WRITE_BURST_COUNT_MIN,
                AXI_MASTER_WRITE_BURST_COUNT_MAX),
                "MASTER_WRITE_BURST_COUNT_RANGE");

        if (use_mem_model && memory_model == null) begin
            report.invalid(scope,
                "use_mem_model=1 actual_memory_model=null expected=non-null",
                "MASTER_WRITE_MEM_MODEL_NULL");
        end
        if (use_mem_model &&
            ADDR_WIDTH > $bits(mem_addr_t)) begin
            report.invalid(scope, $sformatf(
                "actual_addr_width=%0d expected_max_mem_addr_width=%0d",
                ADDR_WIDTH, $bits(mem_addr_t)),
                "MASTER_WRITE_MEM_ADDR_WIDTH");
        end
        if (use_mem_model && !fix_awaddr_enable &&
            !fix_awsize_enable && size_resp_weight > 100) begin
            report.invalid(scope, $sformatf(
                "actual_size_resp_weight=%0d expected_range=[0:100]",
                size_resp_weight), "MASTER_WRITE_SIZE_RESP_WEIGHT_RANGE");
        end

        if (!fix_awid_enable)
            void'(report.check_dist(scope, "awid_type_dist",
                awid_type_dist, AXI_MASTER_WRITE_ID_TYPE_NUM));
        if (!fix_awaddr_enable)
            void'(report.check_dist(scope, "awaddr_offset_dist",
                awaddr_offset_dist, AXI_MASTER_WRITE_ADDR_OFFSET_TYPE_NUM));
        if (!fix_awlen_enable)
            if (non_wrap_burst_possible)
                void'(report.check_dist(scope, "awlen_type_dist",
                    awlen_type_dist, AXI_MASTER_WRITE_LEN_TYPE_NUM));
        if (!fix_awburst_enable)
            void'(report.check_dist(scope, "awburst_dist",
                awburst_dist, AXI_MASTER_WRITE_BURST_DIST_NUM));
        if (!fix_awsize_enable &&
            !(use_mem_model && !fix_awaddr_enable) &&
            BUS_SIZE != 0) begin
            void'(report.check_dist(scope, "awsize_dist",
                awsize_dist, AXI_MASTER_WRITE_SIZE_DIST_NUM));
            if ($size(awsize_dist) == AXI_MASTER_WRITE_SIZE_DIST_NUM &&
                BUS_SIZE <= 1 && awsize_dist[2] != 0)
                report.invalid(scope, $sformatf(
                    "actual_awsize_dist[2]=%0d BUS_SIZE=%0d expected_awsize_dist[2]=0",
                    awsize_dist[2], BUS_SIZE),
                    "MASTER_WRITE_SIZE_DIST_UNUSED_SLOT");
        end
        if (use_mem_model && !fix_awaddr_enable)
            void'(report.check_dist(scope, "resp_dist",
                resp_dist, AXI_MASTER_WRITE_MEM_RESP_DIST_NUM));
        if (!fix_wdata_type_enable && !fix_wdata_enable && !fix_wdata_array_enable)
            void'(report.check_dist(scope, "wdata_type_dist",
                wdata_type_dist, AXI_MASTER_WRITE_DATA_TYPE_NUM));
        if (!fix_first_delay_enable)
            void'(report.check_dist(scope, "first_delay_type_dist",
                first_delay_type_dist,
                AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM));
        if (!fix_aw_w_order_enable)
            void'(report.check_dist(scope, "aw_w_order_dist",
                aw_w_order_dist, AXI_MASTER_WRITE_AW_W_ORDER_TYPE_NUM));
        if (!fix_pkg_delay_enable)
            void'(report.check_dist(scope, "pkg_delay_dist",
                pkg_delay_dist, AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM));
        if (!fix_w_delay_enable)
            void'(report.check_dist(scope, "w_delay_dist",
                w_delay_dist, AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM));
        if (bready_mode == AXI_MASTER_WRITE_BREADY_AFTER_BVALID &&
            !fix_bready_delay_enable)
            void'(report.check_dist(scope, "bready_delay_type_dist",
                bready_delay_type_dist, AXI_MASTER_WRITE_DELAY_TYPE_NUM));

        if (!fix_awlock_enable && awlock_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_awlock_weight=%0d expected_range=[0:100]",
                awlock_weight), "MASTER_WRITE_LOCK_WEIGHT_RANGE");
        if (!fix_awcache_enable && awcache_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_awcache_nonzero_weight=%0d expected_range=[0:100]",
                awcache_nonzero_weight), "MASTER_WRITE_CACHE_WEIGHT_RANGE");
        if (!fix_awprot_enable && awprot_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_awprot_nonzero_weight=%0d expected_range=[0:100]",
                awprot_nonzero_weight), "MASTER_WRITE_PROT_WEIGHT_RANGE");
        if (!fix_awqos_enable && awqos_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_awqos_nonzero_weight=%0d expected_range=[0:100]",
                awqos_nonzero_weight), "MASTER_WRITE_QOS_WEIGHT_RANGE");
        if (!fix_awregion_enable && awregion_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_awregion_nonzero_weight=%0d expected_range=[0:100]",
                awregion_nonzero_weight), "MASTER_WRITE_REGION_WEIGHT_RANGE");
        if (!fix_awuser_enable && awuser_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_awuser_nonzero_weight=%0d expected_range=[0:100]",
                awuser_nonzero_weight), "MASTER_WRITE_USER_WEIGHT_RANGE");
        if (!fix_wuser_enable && wuser_nonzero_weight > 100)
            report.invalid(scope, $sformatf(
                "actual_wuser_nonzero_weight=%0d expected_range=[0:100]",
                wuser_nonzero_weight), "MASTER_WRITE_WUSER_WEIGHT_RANGE");

        if (fix_awburst_enable && !(awburst inside {
                AXI_MASTER_WRITE_BURST_FIXED,
                AXI_MASTER_WRITE_BURST_INCR,
                AXI_MASTER_WRITE_BURST_WRAP}))
            report.invalid(scope, $sformatf(
                "actual_fixed_awburst=%0d expected={FIXED,INCR,WRAP}",
                awburst), "MASTER_WRITE_FIXED_BURST_ENCODING");
        if (fix_awlen_enable && awlen >= AXI_MASTER_WRITE_MAX_BEATS)
            report.invalid(scope, $sformatf(
                "actual_fixed_awlen=%0d expected_range=[0:%0d]",
                awlen, AXI_MASTER_WRITE_MAX_BEATS-1),
                "MASTER_WRITE_FIXED_LEN_RANGE");
        if (fix_awsize_enable && awsize > BUS_SIZE)
            report.invalid(scope, $sformatf(
                "actual_fixed_awsize=%0d expected_range=[0:%0d]",
                awsize, BUS_SIZE), "MASTER_WRITE_FIXED_SIZE_RANGE");
        if (fix_awcache_enable && !axi_cache_is_legal(awcache))
            report.invalid(scope, $sformatf(
                "actual_fixed_awcache=0x%0h expected_legal_axi4_cache_encoding",
                awcache), "MASTER_WRITE_FIXED_CACHE_ENCODING");
        if (fix_wdata_type_enable && !(wdata_type inside {
                AXI_MASTER_WRITE_DATA_RANDOM,
                AXI_MASTER_WRITE_DATA_INCREMENT,
                AXI_MASTER_WRITE_DATA_ADDR_BASED}))
            report.invalid(scope, $sformatf(
                "actual_fixed_wdata_type=%0d expected={RANDOM,INCREMENT,ADDR_BASED}",
                wdata_type), "MASTER_WRITE_FIXED_WDATA_TYPE");

        if (fix_wdata_enable && fix_wdata_array_enable)
            report.conflict(scope,
                "actual_fix_wdata_enable=1 actual_fix_wdata_array_enable=1 expected_at_most_one=1",
                "MASTER_WRITE_WDATA_OVERRIDE_CONFLICT");
        if (fix_wstrb_enable && fix_wstrb_array_enable)
            report.conflict(scope,
                "actual_fix_wstrb_enable=1 actual_fix_wstrb_array_enable=1 expected_at_most_one=1",
                "MASTER_WRITE_WSTRB_OVERRIDE_CONFLICT");
        if (fix_wdata_array_enable &&
            !(wdata_array.size() inside {[1:AXI_MASTER_WRITE_MAX_BEATS]}))
            report.invalid(scope, $sformatf(
                "actual_wdata_array_size=%0d expected_range=[1:%0d]",
                wdata_array.size(), AXI_MASTER_WRITE_MAX_BEATS),
                "MASTER_WRITE_WDATA_ARRAY_SIZE");
        if (fix_wstrb_array_enable &&
            !(wstrb_array.size() inside {[1:AXI_MASTER_WRITE_MAX_BEATS]}))
            report.invalid(scope, $sformatf(
                "actual_wstrb_array_size=%0d expected_range=[1:%0d]",
                wstrb_array.size(), AXI_MASTER_WRITE_MAX_BEATS),
                "MASTER_WRITE_WSTRB_ARRAY_SIZE");
        if (fix_first_delay_enable && first_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_first_delay=%0d expected_range=[0:63]",
                first_delay), "MASTER_WRITE_FIRST_DELAY_RANGE");
        if (fix_aw_w_delay_enable && aw_w_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_aw_w_delay=%0d expected_range=[0:63]",
                aw_w_delay), "MASTER_WRITE_AW_W_DELAY_RANGE");
        if (fix_pkg_delay_enable && pkg_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_pkg_delay=%0d expected_range=[0:63]",
                pkg_delay), "MASTER_WRITE_PKG_DELAY_RANGE");
        if (fix_w_delay_enable && w_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_w_delay=%0d expected_range=[0:63]",
                w_delay), "MASTER_WRITE_W_DELAY_RANGE");
        if (fix_bready_delay_enable && bready_delay > 63)
            report.invalid(scope, $sformatf(
                "actual_fixed_bready_delay=%0d expected_range=[0:63]",
                bready_delay), "MASTER_WRITE_BREADY_DELAY_RANGE");
        if (fix_aw_w_order_enable && !(aw_w_order inside {
                AXI_MASTER_WRITE_AW_W_SAME,
                AXI_MASTER_WRITE_AW_FIRST,
                AXI_MASTER_WRITE_W_FIRST}))
            report.invalid(scope, $sformatf(
                "actual_fixed_aw_w_order=%0d expected={SAME,AW_FIRST,W_FIRST}",
                aw_w_order), "MASTER_WRITE_AW_W_ORDER");
        if (fix_aw_w_order_enable && fix_aw_w_delay_enable &&
            aw_w_order == AXI_MASTER_WRITE_AW_W_SAME && aw_w_delay != 0)
            report.conflict(scope, $sformatf(
                {"actual_fixed_aw_w_order=SAME actual_fixed_aw_w_delay=%0d ",
                 "expected_fixed_aw_w_delay=0"}, aw_w_delay),
                "MASTER_WRITE_AW_W_ORDER_DELAY_CONFLICT");
        if (fix_aw_w_order_enable && fix_aw_w_delay_enable &&
            (aw_w_order inside {
                AXI_MASTER_WRITE_AW_FIRST,
                AXI_MASTER_WRITE_W_FIRST}) && aw_w_delay == 0)
            report.conflict(scope,
                {"actual_fixed_aw_w_order=FIRST actual_fixed_aw_w_delay=0 ",
                 "expected_fixed_aw_w_delay_range=[1:63]"},
                "MASTER_WRITE_AW_W_ORDER_DELAY_CONFLICT");
        if (!fix_aw_w_delay_enable) begin
            bit first_order_possible;
            first_order_possible = fix_aw_w_order_enable ?
                (aw_w_order != AXI_MASTER_WRITE_AW_W_SAME) :
                (aw_w_order_dist.size() == AXI_MASTER_WRITE_AW_W_ORDER_TYPE_NUM &&
                 (aw_w_order_dist[AXI_MASTER_WRITE_AW_FIRST] +
                  aw_w_order_dist[AXI_MASTER_WRITE_W_FIRST]) != 0);
            if (first_order_possible) begin
                void'(report.check_dist(scope, "aw_w_delay_dist",
                    aw_w_delay_dist,
                    AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM));
                if (aw_w_delay_dist.size() ==
                        AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM &&
                    (aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT] +
                     aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID] +
                     aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG] +
                     aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]) == 0) begin
                    report.conflict(scope,
                        $sformatf(
                            {"actual_first_order_possible=1 nonzero_delay_weight_sum=0 ",
                             "aw_w_delay_dist={%0d,%0d,%0d,%0d,%0d} ",
                             "expected_nonzero_delay_weight_sum>0"},
                            aw_w_delay_dist[0], aw_w_delay_dist[1],
                            aw_w_delay_dist[2], aw_w_delay_dist[3],
                            aw_w_delay_dist[4]),
                        "MASTER_WRITE_AW_W_DELAY_CANDIDATE_EMPTY");
                end
            end
        end

        if (!(bready_mode inside {
                AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH,
                AXI_MASTER_WRITE_BREADY_AFTER_BVALID}))
            report.invalid(scope, $sformatf(
                "actual_bready_mode=%0d expected={ALWAYS_HIGH,AFTER_BVALID}",
                bready_mode), "MASTER_WRITE_BREADY_MODE");
        if (bready_mode == AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH &&
            fix_bready_delay_enable && bready_delay != 0)
            report.conflict(scope, $sformatf(
                {"actual_bready_mode=ALWAYS_HIGH actual_fixed_bready_delay=%0d ",
                 "expected_fixed_bready_delay=0"}, bready_delay),
                "MASTER_WRITE_BREADY_MODE_DELAY_CONFLICT");
        // Combinations that depend on the final randomized request geometry or
        // payload length remain Driver-time checks. Directly fixed scalar
        // ranges and fully fixed timing-mode conflicts are rejected above.

        // Segment/response/SIZE reachability is deliberately request-time
        // policy. A valid but empty or non-matching map rejects only the
        // affected attempt before VALID; it is not a structural cfg failure.

        validate_cfg = report.error_count == errors_before;
    endfunction : validate_cfg

    //
    // Implement constraints for user config.
    //
    constraint awid_type_dist_c {
        if (!fix_awid_enable) {
            awid_type_dist.sum == 100;
            awid_type_dist.size() == AXI_MASTER_WRITE_ID_TYPE_NUM;
            foreach (awid_type_dist[i]) awid_type_dist[i] inside {[0:100]};
        }
    }

    constraint awaddr_offset_dist_c {
        if (!fix_awaddr_enable) {
            awaddr_offset_dist.sum == 100;
            awaddr_offset_dist.size() == AXI_MASTER_WRITE_ADDR_OFFSET_TYPE_NUM;
            foreach (awaddr_offset_dist[i]) awaddr_offset_dist[i] inside {[0:100]};
        }
    }

    constraint awlen_type_dist_c {
        if (!fix_awlen_enable &&
            ((fix_awburst_enable && awburst != AXI_MASTER_WRITE_BURST_WRAP) ||
             (!fix_awburst_enable &&
              (awburst_dist[AXI_MASTER_WRITE_BURST_FIXED] +
               awburst_dist[AXI_MASTER_WRITE_BURST_INCR] > 0)))) {
            awlen_type_dist.sum == 100;
            awlen_type_dist.size() == AXI_MASTER_WRITE_LEN_TYPE_NUM;
            foreach (awlen_type_dist[i]) awlen_type_dist[i] inside {[0:100]};
        }
    }

    constraint awsize_dist_c {
        if (!fix_awsize_enable &&
            !(use_mem_model && !fix_awaddr_enable) &&
            BUS_SIZE != 0) {
            awsize_dist.sum == 100;
            foreach (awsize_dist[i]) awsize_dist[i] inside {[0:100]};
            (BUS_SIZE <= 1) -> awsize_dist[2] == 0;
        }
    }

    constraint awburst_dist_c {
        if (!fix_awburst_enable) {
            awburst_dist.sum == 100;
            awburst_dist.size() == AXI_MASTER_WRITE_BURST_DIST_NUM;
            foreach (awburst_dist[i]) awburst_dist[i] inside {[0:100]};
        }
    }

    constraint resp_dist_c {
        if (use_mem_model && !fix_awaddr_enable) {
            resp_dist.sum == 100;
            resp_dist.size() == AXI_MASTER_WRITE_MEM_RESP_DIST_NUM;
            foreach (resp_dist[i]) resp_dist[i] inside {[0:100]};
        }
    }

    constraint wdata_type_dist_c {
        if (!fix_wdata_type_enable && !fix_wdata_enable && !fix_wdata_array_enable) {
            wdata_type_dist.sum == 100;
            wdata_type_dist.size() == AXI_MASTER_WRITE_DATA_TYPE_NUM;
            foreach (wdata_type_dist[i]) wdata_type_dist[i] inside {[0:100]};
        }
    }

    constraint bready_delay_type_dist_c {
        if (bready_mode == AXI_MASTER_WRITE_BREADY_AFTER_BVALID &&
            !fix_bready_delay_enable) {
            bready_delay_type_dist.sum == 100;
            bready_delay_type_dist.size() == AXI_MASTER_WRITE_DELAY_TYPE_NUM;
            foreach (bready_delay_type_dist[i]) bready_delay_type_dist[i] inside {[0:100]};
        }
    }

    constraint timing_candidate_solve_order_c {
        solve first_delay_segment before first_delay;
        solve aw_w_order before aw_w_delay_segment;
        solve aw_w_delay_segment before aw_w_delay;
        solve pkg_delay_segment before pkg_delay;
        solve w_delay_segment before w_delay;
    }

    constraint first_delay_candidate_c {
        if (!fix_first_delay_enable) {
            first_delay_segment dist {
            AXI_MASTER_WRITE_TIMING_DELAY_ZERO      := first_delay_type_dist[AXI_MASTER_WRITE_TIMING_DELAY_ZERO],
            AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := first_delay_type_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
            AXI_MASTER_WRITE_TIMING_DELAY_MID       := first_delay_type_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
            AXI_MASTER_WRITE_TIMING_DELAY_LONG      := first_delay_type_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
            AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := first_delay_type_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
            };
            (first_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_ZERO)      -> first_delay == 0;
            (first_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> first_delay inside {[1:3]};
            (first_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> first_delay inside {[4:10]};
            (first_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> first_delay inside {[11:31]};
            (first_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> first_delay inside {[32:63]};
        }
    }

    constraint aw_w_order_candidate_c {
        if (!fix_aw_w_order_enable) {
            aw_w_order dist {
            AXI_MASTER_WRITE_AW_W_SAME := aw_w_order_dist[AXI_MASTER_WRITE_AW_W_SAME],
            AXI_MASTER_WRITE_AW_FIRST  := aw_w_order_dist[AXI_MASTER_WRITE_AW_FIRST],
            AXI_MASTER_WRITE_W_FIRST   := aw_w_order_dist[AXI_MASTER_WRITE_W_FIRST]
            };
        }
    }

    constraint aw_w_delay_candidate_c {
        if (!fix_aw_w_delay_enable &&
            aw_w_order == AXI_MASTER_WRITE_AW_W_SAME) {
            aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_ZERO;
            aw_w_delay == 0;
        }
        else if (!fix_aw_w_delay_enable) {
            aw_w_delay_segment dist {
                AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
                AXI_MASTER_WRITE_TIMING_DELAY_MID       := aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
                AXI_MASTER_WRITE_TIMING_DELAY_LONG      := aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
                AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
            };
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> aw_w_delay inside {[1:3]};
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> aw_w_delay inside {[4:10]};
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> aw_w_delay inside {[11:31]};
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> aw_w_delay inside {[32:63]};
        }
    }

    constraint pkg_delay_candidate_c {
        if (!fix_pkg_delay_enable) {
            pkg_delay_segment dist {
            AXI_MASTER_WRITE_TIMING_DELAY_ZERO      := pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_ZERO],
            AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
            AXI_MASTER_WRITE_TIMING_DELAY_MID       := pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
            AXI_MASTER_WRITE_TIMING_DELAY_LONG      := pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
            AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
            };
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_ZERO)      -> pkg_delay == 0;
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> pkg_delay inside {[1:3]};
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> pkg_delay inside {[4:10]};
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> pkg_delay inside {[11:31]};
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> pkg_delay inside {[32:63]};
        }
    }

    constraint w_delay_candidate_c {
        if (!fix_w_delay_enable) {
            w_delay_segment dist {
            AXI_MASTER_WRITE_TIMING_DELAY_ZERO      := w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_ZERO],
            AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
            AXI_MASTER_WRITE_TIMING_DELAY_MID       := w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
            AXI_MASTER_WRITE_TIMING_DELAY_LONG      := w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
            AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
            };
            (w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_ZERO)      -> w_delay == 0;
            (w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> w_delay inside {[1:3]};
            (w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> w_delay inside {[4:10]};
            (w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> w_delay inside {[11:31]};
            (w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> w_delay inside {[32:63]};
        }
    }

    constraint source_timing_type_dist_c {
        if (!fix_first_delay_enable) {
            first_delay_type_dist.sum == 100;
            first_delay_type_dist.size() == AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM;
            foreach (first_delay_type_dist[i]) first_delay_type_dist[i] inside {[0:100]};
        }
        if (!fix_aw_w_order_enable) {
            aw_w_order_dist.sum == 100;
            aw_w_order_dist.size() == AXI_MASTER_WRITE_AW_W_ORDER_TYPE_NUM;
            foreach (aw_w_order_dist[i]) aw_w_order_dist[i] inside {[0:100]};
        }
        if (!fix_aw_w_delay_enable &&
            ((fix_aw_w_order_enable && aw_w_order != AXI_MASTER_WRITE_AW_W_SAME) ||
             (!fix_aw_w_order_enable &&
              (aw_w_order_dist[AXI_MASTER_WRITE_AW_FIRST] +
               aw_w_order_dist[AXI_MASTER_WRITE_W_FIRST] > 0)))) {
            aw_w_delay_dist.sum == 100;
            aw_w_delay_dist.size() == AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM;
            foreach (aw_w_delay_dist[i]) aw_w_delay_dist[i] inside {[0:100]};
        }
        if (!fix_pkg_delay_enable) {
            pkg_delay_dist.sum == 100;
            pkg_delay_dist.size() == AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM;
            foreach (pkg_delay_dist[i]) pkg_delay_dist[i] inside {[0:100]};
        }
        if (!fix_w_delay_enable) {
            w_delay_dist.sum == 100;
            w_delay_dist.size() == AXI_MASTER_WRITE_TIMING_DELAY_TYPE_NUM;
            foreach (w_delay_dist[i]) w_delay_dist[i] inside {[0:100]};
        }
    }

    constraint delay_value_c {
        first_delay inside {[0:63]};
        aw_w_delay inside {[0:63]};
        pkg_delay inside {[0:63]};
        w_delay inside {[0:63]};
        bready_delay inside {[0:63]};
    }

    constraint weight_value_c {
        (!fix_awlock_enable)   -> awlock_weight inside {[0:100]};
        (!fix_awcache_enable)  -> awcache_nonzero_weight inside {[0:100]};
        (!fix_awprot_enable)   -> awprot_nonzero_weight inside {[0:100]};
        (!fix_awqos_enable)    -> awqos_nonzero_weight inside {[0:100]};
        (!fix_awregion_enable) -> awregion_nonzero_weight inside {[0:100]};
        (!fix_awuser_enable)   -> awuser_nonzero_weight inside {[0:100]};
        (!fix_wuser_enable)    -> wuser_nonzero_weight inside {[0:100]};
    }

    constraint enable_value_c {
        align_size inside {0, 1};
        use_mem_model inside {0, 1};
        addr_4k_protect_enable inside {0, 1};
        write_outstanding_depth inside {[1:256]};
        write_burst_count inside {
            [AXI_MASTER_WRITE_BURST_COUNT_MIN:AXI_MASTER_WRITE_BURST_COUNT_MAX]};
        fix_first_delay_enable inside {0, 1};
        fix_aw_w_order_enable inside {0, 1};
        fix_aw_w_delay_enable inside {0, 1};
        fix_pkg_delay_enable inside {0, 1};
        fix_w_delay_enable inside {0, 1};
        fix_awid_enable inside {0, 1};
        fix_awaddr_enable inside {0, 1};
        fix_awlen_enable inside {0, 1};
        fix_awsize_enable inside {0, 1};
        fix_awburst_enable inside {0, 1};
        fix_awlock_enable inside {0, 1};
        fix_awcache_enable inside {0, 1};
        fix_awprot_enable inside {0, 1};
        fix_awqos_enable inside {0, 1};
        fix_awregion_enable inside {0, 1};
        fix_awuser_enable inside {0, 1};
        fix_wuser_enable inside {0, 1};
        fix_wdata_type_enable inside {0, 1};
        fix_wdata_enable inside {0, 1};
        fix_wdata_array_enable inside {0, 1};
        fix_wstrb_enable inside {0, 1};
        fix_wstrb_array_enable inside {0, 1};
        fix_bready_delay_enable inside {0, 1};
        !(fix_wdata_enable && fix_wdata_array_enable);
        !(fix_wstrb_enable && fix_wstrb_array_enable);
        (fix_awlen_enable) -> awlen inside {[0:AXI_MASTER_WRITE_MAX_BEATS-1]};
        (fix_awsize_enable) -> awsize inside {[0:BUS_SIZE]};
        (!fix_wdata_array_enable) -> wdata_array.size() == 0;
        (!fix_wstrb_array_enable) -> wstrb_array.size() == 0;
        (fix_wdata_array_enable) -> wdata_array.size() inside {[1:AXI_MASTER_WRITE_MAX_BEATS]};
        (fix_wstrb_array_enable) -> wstrb_array.size() inside {[1:AXI_MASTER_WRITE_MAX_BEATS]};
        (fix_wstrb_enable) -> wstrb inside {[0:STRB_ALL]};
        (fix_wdata_type_enable) -> wdata_type inside {
            AXI_MASTER_WRITE_DATA_RANDOM,
            AXI_MASTER_WRITE_DATA_INCREMENT,
            AXI_MASTER_WRITE_DATA_ADDR_BASED
        };
    }

    constraint fixed_value_c {
        // Cross-field protocol legality is checked on the final request in
        // Driver.  Fixed values never constrain or silently reweight another
        // field during cfg randomization.
        foreach (wstrb_array[i]) {
            (fix_wstrb_array_enable) -> wstrb_array[i] inside {[0:STRB_ALL]};
        }
    }
endclass
`endif
