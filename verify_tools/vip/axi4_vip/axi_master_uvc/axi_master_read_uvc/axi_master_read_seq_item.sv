// ============================================================================
// Filename             : axi_master_read_seq_item.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_READ_SEQ_ITEM_SV
`define AXI_MASTER_READ_SEQ_ITEM_SV

class axi_master_read_ar_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_master_read_ar_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    bit [ID_WIDTH-1:0]     arid;
    bit [ADDR_WIDTH-1:0]   araddr;
    bit [7:0]                       arlen;
    bit [2:0]                       arsize;
    axi_master_read_burst_e                arburst;
    bit                             arlock;
    bit [3:0]                       arcache;
    bit [2:0]                       arprot;
    bit [3:0]                       arqos;
    bit [3:0]                       arregion;
    bit [USER_WIDTH-1:0]   aruser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (arid,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (araddr,                     UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arlen,                      UVM_DEFAULT | UVM_DEC)
        `uvm_field_int  (arsize,                     UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum (axi_master_read_burst_e, arburst,  UVM_DEFAULT)
        `uvm_field_int  (arlock,                     UVM_DEFAULT | UVM_BIN)
        `uvm_field_int  (arcache,                    UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arprot,                     UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arqos,                      UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arregion,                   UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (aruser,                     UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_master_read_ar_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_master_read_ar_seq_item

class axi_master_read_r_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_master_read_r_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    bit [ID_WIDTH-1:0]     rid;
    bit [DATA_WIDTH-1:0]   rdata;
    axi_master_read_resp_e                 rresp;
    bit                             rlast;
    bit [USER_WIDTH-1:0]   ruser;
    int unsigned                    beat_index;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (rid,                    UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (rdata,                  UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum (axi_master_read_resp_e, rresp, UVM_DEFAULT)
        `uvm_field_int  (rlast,                  UVM_DEFAULT | UVM_BIN)
        `uvm_field_int  (ruser,                  UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (beat_index,             UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_master_read_r_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_master_read_r_seq_item

class axi_master_read_base_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends uvm_sequence_item;
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(DATA_BYTES);
    localparam bit [ID_WIDTH-1:0]   ID_MAX   = '1;
    localparam bit [ADDR_WIDTH-1:0] ADDR_MAX = '1;
    localparam bit [USER_WIDTH-1:0] USER_MAX = '1;

    typedef axi_master_read_base_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_read_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef axi_burst_math #(ADDR_WIDTH, DATA_BYTES) burst_math_t;
    //
    // Random variable declare
    //
    // Base variables are driven to or sampled from the common axi_read_if.
    rand bit [ID_WIDTH-1:0]     arid;
    rand bit [ADDR_WIDTH-1:0]   araddr;
    rand bit [7:0]                       arlen;
    rand bit [2:0]                       arsize;
    rand axi_master_read_burst_e                arburst;
    rand bit                             arlock;
    rand bit [3:0]                       arcache;
    rand bit [2:0]                       arprot;
    rand bit [3:0]                       arqos;
    rand bit [3:0]                       arregion;
    rand bit [USER_WIDTH-1:0]   aruser;

    bit [ID_WIDTH-1:0]          rid;
    bit [DATA_WIDTH-1:0]        rdata[];
    bit [1:0]                            rresp[];
    bit [USER_WIDTH-1:0]        ruser[];
    bit                                  read_done;
    int unsigned                         beat_count;
    time                                 ar_handshake_time;
    time                                 r_handshake_time[];

    // The response used to choose a random Mem-Model Segment is an input
    // intent.  The response predicted from the final access range is a
    // separate output of Driver preparation; never overwrite the intent.
    rand mem_resp_e                      desired_mem_response;
    bit                                  desired_mem_response_valid;
    mem_resp_e                           predicted_mem_response;
    bit                                  predicted_mem_response_valid;
    int unsigned                         predicted_mem_access_bytes;
    rand bit                             expect_size_error;
    bit                                  size_intent_valid;
    axi_prepare_status_e                 prepare_status;
    axi_prepare_reason_e                 prepare_reason;

    // Boundary/control random items for base signal generation.
    rand axi_master_read_id_type_e              arid_type;
    rand axi_master_read_addr_offset_e          araddr_offset_type;
    rand bit [11:0]                             araddr_offset;
    rand axi_master_read_len_type_e             arlen_type;

    cfg_t axi_master_read_cfg;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int        (arid,                         UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (araddr,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (arlen,                        UVM_DEFAULT | UVM_DEC)
        `uvm_field_int        (arsize,                       UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum       (axi_master_read_burst_e, arburst,    UVM_DEFAULT)
        `uvm_field_int        (arlock,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int        (arcache,                      UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (arprot,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (arqos,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (arregion,                     UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (aruser,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (rid,                          UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int  (rdata,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int  (rresp,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int  (ruser,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (read_done,                    UVM_DEFAULT | UVM_BIN)
        `uvm_field_int        (beat_count,                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int        (ar_handshake_time,            UVM_DEFAULT | UVM_TIME)
        `uvm_field_array_int  (r_handshake_time,             UVM_DEFAULT | UVM_TIME)
        `uvm_field_enum       (mem_resp_e, desired_mem_response, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int        (desired_mem_response_valid,   UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_enum       (mem_resp_e, predicted_mem_response, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int        (predicted_mem_response_valid, UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_int        (predicted_mem_access_bytes,   UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int        (expect_size_error,             UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_int        (size_intent_valid,             UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_prepare_status_e, prepare_status, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_prepare_reason_e, prepare_reason, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_read_id_type_e, arid_type,                       UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_read_addr_offset_e, araddr_offset_type,          UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int        (araddr_offset,                                             UVM_DEFAULT | UVM_HEX | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_read_len_type_e, arlen_type,                     UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "axi_master_read_base_seq_item");
        super.new(name);
        desired_mem_response = MEM_RESP_OKAY;
        desired_mem_response_valid = 1'b0;
        predicted_mem_response = MEM_RESP_OKAY;
        predicted_mem_response_valid = 1'b0;
        predicted_mem_access_bytes = 0;
        expect_size_error = 1'b0;
        size_intent_valid = 1'b0;
        prepare_status = AXI_PREPARE_NOT_RUN;
        prepare_reason = AXI_PREPARE_REASON_NONE;
    endfunction : new

    function void pre_randomize();
        if (axi_master_read_cfg == null) begin
            `uvm_fatal("NOCFG", "axi_master_read_cfg must be assigned before randomizing axi_master_read_seq_item")
        end
        desired_mem_response_valid =
            axi_master_read_cfg.use_mem_model &&
            !axi_master_read_cfg.fix_araddr_enable;
        size_intent_valid =
            axi_master_read_cfg.use_mem_model &&
            !axi_master_read_cfg.fix_araddr_enable &&
            !axi_master_read_cfg.fix_arsize_enable;
        predicted_mem_response = MEM_RESP_OKAY;
        predicted_mem_response_valid = 1'b0;
        predicted_mem_access_bytes = 0;
        prepare_status = AXI_PREPARE_NOT_RUN;
        prepare_reason = AXI_PREPARE_REASON_NONE;
    endfunction : pre_randomize

    function bit [ADDR_WIDTH-1:0] get_beat_addr(int unsigned beat_idx);
        return burst_math_t::get_beat_addr(
            araddr, arlen, arsize, axi_burst_e'(arburst), beat_idx);
    endfunction : get_beat_addr

    function bit [DATA_BYTES-1:0] get_beat_rdata_valid_mask(int unsigned beat_idx);
        return burst_math_t::get_byte_lane_mask(
            araddr, arlen, arsize, axi_burst_e'(arburst), beat_idx);
    endfunction : get_beat_rdata_valid_mask

    function bit [DATA_WIDTH-1:0] get_beat_rdata_valid_data_mask(int unsigned beat_idx);
        return burst_math_t::get_data_lane_mask(
            araddr, arlen, arsize, axi_burst_e'(arburst), beat_idx);
    endfunction : get_beat_rdata_valid_data_mask

    // Pack valid lanes in increasing byte-address order into the low bytes.
    function bit [DATA_WIDTH-1:0] get_beat_packed_rdata(int unsigned beat_idx);
        bit [DATA_BYTES-1:0] byte_mask;
        int unsigned packed_lane;

        get_beat_packed_rdata = '0;
        if (beat_idx >= rdata.size()) begin
            return get_beat_packed_rdata;
        end

        byte_mask = get_beat_rdata_valid_mask(beat_idx);
        packed_lane = 0;
        for (int unsigned lane = 0; lane < DATA_BYTES; lane++) begin
            if (byte_mask[lane]) begin
                get_beat_packed_rdata[packed_lane*8 +: 8] = rdata[beat_idx][lane*8 +: 8];
                packed_lane++;
            end
        end
    endfunction : get_beat_packed_rdata

    function int unsigned get_mem_access_bytes();
        return burst_math_t::get_access_bytes(
            arlen, arsize, axi_burst_e'(arburst));
    endfunction : get_mem_access_bytes

    //
    // User constraints
    //
    constraint solve_order_c {
        solve arid_type before arid;
        solve desired_mem_response before arlock;
        solve expect_size_error before arlock;
        solve arlock before arburst;
        solve arlock before arlen_type;
        solve arlock before arlen;
        solve arburst before arlen_type;
        solve arlen_type before arlen;
        solve arburst before arlen;
        solve arlen before arsize;
        solve arsize before araddr_offset_type;
        solve araddr_offset_type before araddr_offset;
        solve araddr_offset before araddr;
        solve arlock before araddr;
        solve arburst before araddr;
        solve arlen before araddr;
        solve arsize before araddr;
    }

    constraint desired_mem_response_c {
        if (axi_master_read_cfg.use_mem_model &&
            !axi_master_read_cfg.fix_araddr_enable) {
            desired_mem_response dist {
                MEM_RESP_OKAY   := axi_master_read_cfg.resp_dist[0],
                MEM_RESP_SLVERR := axi_master_read_cfg.resp_dist[1],
                MEM_RESP_DECERR := axi_master_read_cfg.resp_dist[2]
            };
        }
        else {
            desired_mem_response == MEM_RESP_OKAY;
        }
    }

    constraint expect_size_error_c {
        if (axi_master_read_cfg.use_mem_model &&
            !axi_master_read_cfg.fix_araddr_enable &&
            !axi_master_read_cfg.fix_arsize_enable) {
            expect_size_error dist {
                1'b0 := axi_master_read_cfg.size_resp_weight,
                1'b1 := 100 - axi_master_read_cfg.size_resp_weight
            };
        }
        else {
            expect_size_error == 1'b0;
        }
    }

    constraint arid_type_c {
        if (!axi_master_read_cfg.fix_arid_enable) {
            arid_type dist {
                AXI_MASTER_READ_ID_ZERO      := axi_master_read_cfg.arid_type_dist[AXI_MASTER_READ_ID_ZERO],
                AXI_MASTER_READ_ID_LOW       := axi_master_read_cfg.arid_type_dist[AXI_MASTER_READ_ID_LOW],
                AXI_MASTER_READ_ID_HIGH      := axi_master_read_cfg.arid_type_dist[AXI_MASTER_READ_ID_HIGH],
                AXI_MASTER_READ_ID_MAX_VALUE := axi_master_read_cfg.arid_type_dist[AXI_MASTER_READ_ID_MAX_VALUE]
            };
        }
    }

    constraint arid_c {
        if (axi_master_read_cfg.fix_arid_enable) {
            arid == axi_master_read_cfg.arid;
        }
        else {
            (arid_type == AXI_MASTER_READ_ID_ZERO)      -> arid == '0;
            if (ID_WIDTH <= 2) {
                (arid_type == AXI_MASTER_READ_ID_LOW)  -> arid inside {[1:ID_MAX]};
                (arid_type == AXI_MASTER_READ_ID_HIGH) -> arid inside {[1:ID_MAX]};
            }
            else {
                (arid_type == AXI_MASTER_READ_ID_LOW)  -> arid inside {[1:3]};
                (arid_type == AXI_MASTER_READ_ID_HIGH) -> arid inside {[4:ID_MAX-1]};
            }
            (arid_type == AXI_MASTER_READ_ID_MAX_VALUE) -> arid == ID_MAX;
        }
    }

    constraint araddr_offset_type_c {
        if (!axi_master_read_cfg.fix_araddr_enable) {
            araddr_offset_type dist {
                AXI_MASTER_READ_ADDR_OFFSET_ZERO      := axi_master_read_cfg.araddr_offset_dist[AXI_MASTER_READ_ADDR_OFFSET_ZERO],
                AXI_MASTER_READ_ADDR_OFFSET_LOW       := axi_master_read_cfg.araddr_offset_dist[AXI_MASTER_READ_ADDR_OFFSET_LOW],
                AXI_MASTER_READ_ADDR_OFFSET_NORMAL    := axi_master_read_cfg.araddr_offset_dist[AXI_MASTER_READ_ADDR_OFFSET_NORMAL],
                AXI_MASTER_READ_ADDR_OFFSET_HIGH      := axi_master_read_cfg.araddr_offset_dist[AXI_MASTER_READ_ADDR_OFFSET_HIGH],
                AXI_MASTER_READ_ADDR_OFFSET_MAX_VALUE := axi_master_read_cfg.araddr_offset_dist[AXI_MASTER_READ_ADDR_OFFSET_MAX_VALUE]
            };
        }
        else {
            araddr_offset_type == AXI_MASTER_READ_ADDR_OFFSET_ZERO;
        }
    }

    constraint araddr_offset_c {
        if (axi_master_read_cfg.fix_araddr_enable) {
            araddr_offset == axi_master_read_cfg.araddr[11:0];
        }
        else if (axi_master_read_cfg.use_mem_model) {
            // The offset type is the random intent. Driver materializes and
            // writes back the exact offset with the final Mem address.
            araddr_offset == '0;
        }
        else {
            (araddr_offset_type == AXI_MASTER_READ_ADDR_OFFSET_ZERO)      -> araddr_offset == 12'h000;
            (araddr_offset_type == AXI_MASTER_READ_ADDR_OFFSET_LOW)       -> araddr_offset inside {[12'h001:12'h0ff]};
            (araddr_offset_type == AXI_MASTER_READ_ADDR_OFFSET_NORMAL)    -> araddr_offset inside {[12'h100:12'hfef]};
            (araddr_offset_type == AXI_MASTER_READ_ADDR_OFFSET_HIGH)      -> araddr_offset inside {[12'hff0:12'hffe]};
            (araddr_offset_type == AXI_MASTER_READ_ADDR_OFFSET_MAX_VALUE) -> araddr_offset == 12'hfff;
        }
    }

    constraint araddr_c {
        if (axi_master_read_cfg.fix_araddr_enable) {
            araddr == axi_master_read_cfg.araddr;
        }
        else if (axi_master_read_cfg.use_mem_model) {
            // Driver materializes random Mem-Model addresses after selecting
            // a realizable Segment.  This is not the final bus address.
            araddr == '0;
        }
        else if (axi_master_read_cfg.align_size) {
            araddr[11:0] ==
                (araddr_offset / (1 << arsize)) * (1 << arsize);
        }
        else {
            araddr[11:0] == araddr_offset;
        }
    }

    // For ordinary random-address traffic, ARADDR is the final random node.
    // Upstream BURST/LEN/SIZE/LOCK choices are already final, so only ARADDR
    // is constrained here.  A fixed ARADDR bypasses every constraint below
    // and is instead checked without modification by the Driver.
    constraint random_araddr_range_c {
        if (!axi_master_read_cfg.fix_araddr_enable &&
            !axi_master_read_cfg.use_mem_model) {
            if (arburst == AXI_MASTER_READ_BURST_FIXED) {
                (({17'b0, araddr} / (1 << arsize)) * (1 << arsize)) +
                    (1 << arsize) - 1 <= {17'b0, ADDR_MAX};
            }
            else if (arburst == AXI_MASTER_READ_BURST_INCR) {
                (({17'b0, araddr} / (1 << arsize)) * (1 << arsize)) +
                    ((arlen + 1) * (1 << arsize)) - 1 <=
                    {17'b0, ADDR_MAX};
            }
            else if (arburst == AXI_MASTER_READ_BURST_WRAP) {
                (({17'b0, araddr} /
                    ((arlen + 1) * (1 << arsize))) *
                    ((arlen + 1) * (1 << arsize))) +
                    ((arlen + 1) * (1 << arsize)) - 1 <=
                    {17'b0, ADDR_MAX};
            }
        }
    }

    constraint random_araddr_4k_c {
        if (!axi_master_read_cfg.fix_araddr_enable &&
            !axi_master_read_cfg.use_mem_model &&
            axi_master_read_cfg.addr_4k_protect_enable) {
            if (arburst == AXI_MASTER_READ_BURST_FIXED) {
                ((araddr[11:0] / (1 << arsize)) * (1 << arsize)) +
                    (1 << arsize) <= 4096;
            }
            else if (arburst == AXI_MASTER_READ_BURST_INCR) {
                ((araddr[11:0] / (1 << arsize)) * (1 << arsize)) +
                    ((arlen + 1) * (1 << arsize)) <= 4096;
            }
            else if (arburst == AXI_MASTER_READ_BURST_WRAP) {
                ((araddr[11:0] /
                    ((arlen + 1) * (1 << arsize))) *
                    ((arlen + 1) * (1 << arsize))) +
                    ((arlen + 1) * (1 << arsize)) <= 4096;
            }
        }
    }

    constraint arlen_type_c {
        if (!axi_master_read_cfg.fix_arlen_enable &&
            arburst != AXI_MASTER_READ_BURST_WRAP) {
            arlen_type dist {
                AXI_MASTER_READ_LEN_SINGLE    := axi_master_read_cfg.arlen_type_dist[AXI_MASTER_READ_LEN_SINGLE],
                AXI_MASTER_READ_LEN_SHORT     := axi_master_read_cfg.arlen_type_dist[AXI_MASTER_READ_LEN_SHORT],
                AXI_MASTER_READ_LEN_MID       := axi_master_read_cfg.arlen_type_dist[AXI_MASTER_READ_LEN_MID],
                AXI_MASTER_READ_LEN_LONG      := axi_master_read_cfg.arlen_type_dist[AXI_MASTER_READ_LEN_LONG],
                AXI_MASTER_READ_LEN_MAX_VALUE := axi_master_read_cfg.arlen_type_dist[AXI_MASTER_READ_LEN_MAX_VALUE]
            };
        }
    }

    constraint arlen_c {
        if (axi_master_read_cfg.fix_arlen_enable) {
            arlen == axi_master_read_cfg.arlen;
        }
        else if (arburst == AXI_MASTER_READ_BURST_WRAP) {
            arlen inside {8'd1, 8'd3, 8'd7, 8'd15};
        }
        else {
            (arlen_type == AXI_MASTER_READ_LEN_SINGLE)    -> arlen == 0;
            (arlen_type == AXI_MASTER_READ_LEN_SHORT)     -> arlen inside {[1:3]};
            (arlen_type == AXI_MASTER_READ_LEN_MID)       -> arlen inside {[4:7]};
            (arlen_type == AXI_MASTER_READ_LEN_LONG)      -> arlen inside {[8:AXI_MASTER_READ_MAX_BEATS-2]};
            (arlen_type == AXI_MASTER_READ_LEN_MAX_VALUE) -> arlen == AXI_MASTER_READ_MAX_BEATS - 1;
        }
        if (!axi_master_read_cfg.fix_arlen_enable) {
            arlen inside {[0:AXI_MASTER_READ_MAX_BEATS-1]};
            (arburst == AXI_MASTER_READ_BURST_FIXED) -> arlen <= 8'd15;
            arlock -> arlen inside {8'd0, 8'd1, 8'd3, 8'd7, 8'd15};
        }
    }

    constraint arsize_c {
        if (axi_master_read_cfg.fix_arsize_enable) {
            arsize == axi_master_read_cfg.arsize;
        }
        else if (axi_master_read_cfg.use_mem_model &&
                 !axi_master_read_cfg.fix_araddr_enable) {
            // The Driver owns the single final ARSIZE selection in Mem Model
            // mode.  This deterministic value is only a solver placeholder;
            // it does not consume arsize_dist and is not sent on the bus.
            arsize == 0;
        }
        else if (BUS_SIZE == 0) {
            arsize == 0;
        }
        else if (BUS_SIZE == 1) {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                1 := axi_master_read_cfg.arsize_dist[1]
            };
        }
        else if (BUS_SIZE == 2) {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                1 :/ axi_master_read_cfg.arsize_dist[1],
                2 := axi_master_read_cfg.arsize_dist[2]
            };
        }
        else if (BUS_SIZE == 3) {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                [1:2] :/ axi_master_read_cfg.arsize_dist[1],
                3 := axi_master_read_cfg.arsize_dist[2]
            };
        }
        else if (BUS_SIZE == 4) {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                [1:3] :/ axi_master_read_cfg.arsize_dist[1],
                4 := axi_master_read_cfg.arsize_dist[2]
            };
        }
        else if (BUS_SIZE == 5) {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                [1:4] :/ axi_master_read_cfg.arsize_dist[1],
                5 := axi_master_read_cfg.arsize_dist[2]
            };
        }
        else if (BUS_SIZE == 6) {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                [1:5] :/ axi_master_read_cfg.arsize_dist[1],
                6 := axi_master_read_cfg.arsize_dist[2]
            };
        }
        else {
            arsize dist {
                0 := axi_master_read_cfg.arsize_dist[0],
                [1:6] :/ axi_master_read_cfg.arsize_dist[1],
                7 := axi_master_read_cfg.arsize_dist[2]
            };
        }
        if (!axi_master_read_cfg.fix_arsize_enable &&
            !(axi_master_read_cfg.use_mem_model &&
              !axi_master_read_cfg.fix_araddr_enable) &&
            arlock &&
            (!axi_master_read_cfg.fix_arlen_enable ||
             arlen inside {8'd0, 8'd1, 8'd3, 8'd7, 8'd15})) {
            ((arlen + 1) * (1 << arsize)) <= 128;
        }
    }

    constraint arburst_type_c {
        if (axi_master_read_cfg.fix_arburst_enable) {
            arburst == axi_master_read_cfg.arburst;
        }
        else {
            arburst dist {
                AXI_MASTER_READ_BURST_FIXED := axi_master_read_cfg.arburst_dist[AXI_MASTER_READ_BURST_FIXED],
                AXI_MASTER_READ_BURST_INCR  := axi_master_read_cfg.arburst_dist[AXI_MASTER_READ_BURST_INCR],
                AXI_MASTER_READ_BURST_WRAP  := axi_master_read_cfg.arburst_dist[AXI_MASTER_READ_BURST_WRAP]
            };
        }
    }

    constraint random_araddr_wrap_alignment_c {
        if (!axi_master_read_cfg.fix_araddr_enable &&
            !axi_master_read_cfg.use_mem_model &&
            arburst == AXI_MASTER_READ_BURST_WRAP) {
            (araddr % (1 << arsize)) == 0;
        }
    }

    constraint arlock_c {
        if (axi_master_read_cfg.fix_arlock_enable) {
            arlock == axi_master_read_cfg.arlock;
        }
        else {
            arlock dist {0 := 100 - axi_master_read_cfg.arlock_weight, 1 := axi_master_read_cfg.arlock_weight};
        }
    }

    constraint random_araddr_exclusive_alignment_c {
        if (!axi_master_read_cfg.fix_araddr_enable &&
            !axi_master_read_cfg.use_mem_model && arlock &&
            (arlen inside {8'd0, 8'd1, 8'd3, 8'd7, 8'd15}) &&
            arsize <= BUS_SIZE &&
            ((arlen + 1) * (1 << arsize)) <= 128) {
            (araddr % ((arlen + 1) * (1 << arsize))) == 0;
        }
    }

    constraint arcache_c {
        if (axi_master_read_cfg.fix_arcache_enable) {
            arcache == axi_master_read_cfg.arcache;
        }
        else {
            axi_cache_is_legal(arcache);
            (arcache == 4'h0) dist {
                1'b1 := 100 - axi_master_read_cfg.arcache_nonzero_weight,
                1'b0 := axi_master_read_cfg.arcache_nonzero_weight
            };
        }
    }

    constraint arprot_c {
        if (axi_master_read_cfg.fix_arprot_enable) {
            arprot == axi_master_read_cfg.arprot;
        }
        else {
            arprot dist {3'h0 := 100 - axi_master_read_cfg.arprot_nonzero_weight, [3'h1:3'h7] :/ axi_master_read_cfg.arprot_nonzero_weight};
        }
    }

    constraint arqos_c {
        if (axi_master_read_cfg.fix_arqos_enable) {
            arqos == axi_master_read_cfg.arqos;
        }
        else {
            arqos dist {4'h0 := 100 - axi_master_read_cfg.arqos_nonzero_weight, [4'h1:4'hf] :/ axi_master_read_cfg.arqos_nonzero_weight};
        }
    }

    constraint arregion_c {
        if (axi_master_read_cfg.fix_arregion_enable) {
            arregion == axi_master_read_cfg.arregion;
        }
        else {
            arregion dist {4'h0 := 100 - axi_master_read_cfg.arregion_nonzero_weight, [4'h1:4'hf] :/ axi_master_read_cfg.arregion_nonzero_weight};
        }
    }

    constraint aruser_c {
        if (axi_master_read_cfg.fix_aruser_enable) {
            aruser == axi_master_read_cfg.aruser;
        }
        else {
            aruser dist {'0 := 100 - axi_master_read_cfg.aruser_nonzero_weight, [1:USER_MAX] :/ axi_master_read_cfg.aruser_nonzero_weight};
        }
    }
endclass : axi_master_read_base_seq_item

class axi_master_read_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_READ_USER_WIDTH
) extends axi_master_read_base_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH
);
    typedef axi_master_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    // Per-request AR timing. The reset-to-first-ARVALID delay belongs to the
    // driver reset epoch and is therefore not carried by each transaction.
    rand int unsigned ar_delay;
    rand axi_master_read_timing_gap_segment_e ar_delay_segment;

    rand axi_master_read_delay_type_e rready_delay_type;
    rand int unsigned rready_delay;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (ar_delay,        UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_enum (axi_master_read_delay_type_e, rready_delay_type, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int  (rready_delay,    UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "axi_master_read_seq_item");
        super.new(name);
    endfunction : new

    //
    // User constraints
    //
    constraint ext_solve_order_c {
        solve ar_delay_segment before ar_delay;
        solve rready_delay_type before rready_delay;
    }

    constraint ar_delay_c {
        if (axi_master_read_cfg.fix_ar_delay_enable) {
            ar_delay == axi_master_read_cfg.ar_delay;
        }
        else {
            ar_delay_segment dist {
                AXI_MASTER_READ_TIMING_GAP_ZERO      := axi_master_read_cfg.ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_ZERO],
                AXI_MASTER_READ_TIMING_GAP_SHORT     := axi_master_read_cfg.ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_SHORT],
                AXI_MASTER_READ_TIMING_GAP_MID       := axi_master_read_cfg.ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_MID],
                AXI_MASTER_READ_TIMING_GAP_LONG      := axi_master_read_cfg.ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_LONG],
                AXI_MASTER_READ_TIMING_GAP_MAX_VALUE := axi_master_read_cfg.ar_delay_dist[AXI_MASTER_READ_TIMING_GAP_MAX_VALUE]
            };
            (ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_ZERO)      -> ar_delay == 0;
            (ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_SHORT)     -> ar_delay inside {[1:9]};
            (ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_MID)       -> ar_delay inside {[10:49]};
            (ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_LONG)      -> ar_delay inside {[50:99]};
            (ar_delay_segment == AXI_MASTER_READ_TIMING_GAP_MAX_VALUE) -> ar_delay == 100;
        }
    }

    constraint rready_delay_type_c {
        if (axi_master_read_cfg.rready_mode == AXI_MASTER_READ_RREADY_ALWAYS_HIGH) {
            rready_delay_type == AXI_MASTER_READ_DELAY_ZERO;
        }
        else if (!axi_master_read_cfg.fix_rready_delay_enable) {
            rready_delay_type dist {
                AXI_MASTER_READ_DELAY_ZERO      := axi_master_read_cfg.rready_delay_type_dist[AXI_MASTER_READ_DELAY_ZERO],
                AXI_MASTER_READ_DELAY_SHORT     := axi_master_read_cfg.rready_delay_type_dist[AXI_MASTER_READ_DELAY_SHORT],
                AXI_MASTER_READ_DELAY_MID       := axi_master_read_cfg.rready_delay_type_dist[AXI_MASTER_READ_DELAY_MID],
                AXI_MASTER_READ_DELAY_LONG      := axi_master_read_cfg.rready_delay_type_dist[AXI_MASTER_READ_DELAY_LONG],
                AXI_MASTER_READ_DELAY_MAX_VALUE := axi_master_read_cfg.rready_delay_type_dist[AXI_MASTER_READ_DELAY_MAX_VALUE]
            };
        }
    }

    constraint delay_c {
        if (axi_master_read_cfg.rready_mode == AXI_MASTER_READ_RREADY_ALWAYS_HIGH) {
            if (axi_master_read_cfg.fix_rready_delay_enable) {
                rready_delay == axi_master_read_cfg.rready_delay;
            }
            else {
                rready_delay == 0;
            }
        }
        else if (axi_master_read_cfg.fix_rready_delay_enable) {
            rready_delay == axi_master_read_cfg.rready_delay;
        }
        else {
            (rready_delay_type == AXI_MASTER_READ_DELAY_ZERO)       -> rready_delay == 0;
            (rready_delay_type == AXI_MASTER_READ_DELAY_SHORT)      -> rready_delay inside {[1:3]};
            (rready_delay_type == AXI_MASTER_READ_DELAY_MID)        -> rready_delay inside {[4:10]};
            (rready_delay_type == AXI_MASTER_READ_DELAY_LONG)       -> rready_delay inside {[11:31]};
            (rready_delay_type == AXI_MASTER_READ_DELAY_MAX_VALUE)  -> rready_delay inside {[32:63]};
        }

    }
endclass : axi_master_read_seq_item
`endif
