// ============================================================================
// Filename             : axi_master_write_seq_item.sv
// Author               : kippy xyz
// Created On           : 2026-6-12 10:17
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MASTER_WRITE_SEQ_ITEM_SV
`define AXI_MASTER_WRITE_SEQ_ITEM_SV
class axi_master_write_aw_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_master_write_aw_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    bit [ID_WIDTH-1:0]     awid;
    bit [ADDR_WIDTH-1:0]   awaddr;
    bit [7:0]                        awlen;
    bit [2:0]                        awsize;
    axi_master_write_burst_e                awburst;
    bit                              awlock;
    bit [3:0]                        awcache;
    bit [2:0]                        awprot;
    bit [3:0]                        awqos;
    bit [3:0]                        awregion;
    bit [USER_WIDTH-1:0]   awuser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (awid,                         UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awaddr,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awlen,                        UVM_DEFAULT | UVM_DEC)
        `uvm_field_int  (awsize,                       UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum (axi_master_write_burst_e, awburst,   UVM_DEFAULT)
        `uvm_field_int  (awlock,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int  (awcache,                      UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awprot,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awqos,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awregion,                     UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awuser,                       UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_master_write_aw_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_master_write_aw_seq_item

class axi_master_write_w_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_master_write_w_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    bit [DATA_WIDTH-1:0]   wdata;
    bit [STRB_WIDTH-1:0]   wstrb;
    bit                              wlast;
    bit [USER_WIDTH-1:0]   wuser;
    int unsigned                     beat_index;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int (wdata,       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int (wstrb,       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int (wlast,       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int (wuser,       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int (beat_index,  UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_master_write_w_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_master_write_w_seq_item

class axi_master_write_b_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_master_write_b_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    bit [ID_WIDTH-1:0]     bid;
    axi_master_write_resp_e                 bresp;
    bit [USER_WIDTH-1:0]   buser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (bid,                     UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum (axi_master_write_resp_e, bresp, UVM_DEFAULT)
        `uvm_field_int  (buser,                   UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_master_write_b_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_master_write_b_seq_item

class axi_master_write_base_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    localparam int BUS_SIZE   = $clog2(STRB_WIDTH);
    localparam bit [ID_WIDTH-1:0]   ID_MAX   = '1;
    localparam bit [ADDR_WIDTH-1:0] ADDR_MAX = '1;
    localparam bit [USER_WIDTH-1:0] USER_MAX = '1;

    typedef axi_master_write_base_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef axi_master_write_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) cfg_t;
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;
    //
    // Random variable declare
    //
    // Base variables are driven to or sampled from the common axi_write_if.
    rand bit [ID_WIDTH-1:0]     awid;
    rand bit [ADDR_WIDTH-1:0]   awaddr;
    rand bit [7:0]                        awlen;
    rand bit [2:0]                        awsize;
    rand axi_master_write_burst_e                awburst;
    rand bit                              awlock;
    rand bit [3:0]                        awcache;
    rand bit [2:0]                        awprot;
    rand bit [3:0]                        awqos;
    rand bit [3:0]                        awregion;
    rand bit [USER_WIDTH-1:0]   awuser;
    rand bit [DATA_WIDTH-1:0]   wdata[];
    rand bit [STRB_WIDTH-1:0]   wstrb[];
    rand bit [USER_WIDTH-1:0]   wuser[];

    bit [ID_WIDTH-1:0]          bid;
    axi_master_write_resp_e                      bresp;
    bit [USER_WIDTH-1:0]        buser;
    bit                                   write_done;
    int unsigned                          beat_count;
    time                                  aw_handshake_time;
    time                                  w_handshake_time[];
    time                                  b_handshake_time;

    // The response used to choose a random Mem-Model Segment is an input
    // intent.  The response predicted from the final access range is a
    // separate output of Driver preparation; never overwrite the intent.
    rand mem_resp_e                       desired_mem_response;
    bit                                   desired_mem_response_valid;
    mem_resp_e                            predicted_mem_response;
    bit                                   predicted_mem_response_valid;
    int unsigned                          predicted_mem_access_bytes;
    rand bit                              expect_size_error;
    bit                                   size_intent_valid;
    axi_prepare_status_e                  prepare_status;
    axi_prepare_reason_e                  prepare_reason;

    // Boundary/control random items for base signal generation.
    // These keep boundary values explicit for later corner-case sequences.
    rand axi_master_write_id_type_e              awid_type;
    rand axi_master_write_addr_offset_e          awaddr_offset_type;
    rand bit [11:0]                              awaddr_offset;
    rand axi_master_write_len_type_e             awlen_type;
    rand axi_master_write_data_type_e            wdata_type;

    cfg_t axi_master_write_cfg;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int        (awid,                         UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (awaddr,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (awlen,                        UVM_DEFAULT | UVM_DEC)
        `uvm_field_int        (awsize,                       UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum       (axi_master_write_burst_e, awburst,   UVM_DEFAULT)
        `uvm_field_int        (awlock,                       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int        (awcache,                      UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (awprot,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (awqos,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (awregion,                     UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (awuser,                       UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int  (wdata,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int  (wstrb,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int  (wuser,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (bid,                          UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum       (axi_master_write_resp_e, bresp,      UVM_DEFAULT)
        `uvm_field_int        (buser,                        UVM_DEFAULT | UVM_HEX)
        `uvm_field_int        (write_done,                   UVM_DEFAULT | UVM_BIN)
        `uvm_field_int        (beat_count,                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int        (aw_handshake_time,            UVM_DEFAULT | UVM_TIME)
        `uvm_field_array_int  (w_handshake_time,             UVM_DEFAULT | UVM_TIME)
        `uvm_field_int        (b_handshake_time,             UVM_DEFAULT | UVM_TIME)
        `uvm_field_enum       (mem_resp_e, desired_mem_response, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int        (desired_mem_response_valid,   UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_enum       (mem_resp_e, predicted_mem_response, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int        (predicted_mem_response_valid, UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_int        (predicted_mem_access_bytes,   UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int        (expect_size_error,             UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_int        (size_intent_valid,             UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_prepare_status_e, prepare_status, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_prepare_reason_e, prepare_reason, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_write_id_type_e, awid_type,                       UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_write_addr_offset_e, awaddr_offset_type,          UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int        (awaddr_offset,                                              UVM_DEFAULT | UVM_HEX | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_write_len_type_e, awlen_type,                     UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_enum       (axi_master_write_data_type_e, wdata_type,                    UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "axi_master_write_base_seq_item");
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
        if (axi_master_write_cfg == null) begin
            `uvm_fatal("NOCFG", "axi_master_write_cfg must be assigned before randomizing axi_master_write_seq_item")
        end
        desired_mem_response_valid =
            axi_master_write_cfg.use_mem_model &&
            !axi_master_write_cfg.fix_awaddr_enable;
        size_intent_valid =
            axi_master_write_cfg.use_mem_model &&
            !axi_master_write_cfg.fix_awaddr_enable &&
            !axi_master_write_cfg.fix_awsize_enable;
        predicted_mem_response = MEM_RESP_OKAY;
        predicted_mem_response_valid = 1'b0;
        predicted_mem_access_bytes = 0;
        prepare_status = AXI_PREPARE_NOT_RUN;
        prepare_reason = AXI_PREPARE_REASON_NONE;
    endfunction : pre_randomize

    function bit [ADDR_WIDTH-1:0] get_beat_addr(int unsigned beat_idx);
        return burst_math_t::get_beat_addr(
            awaddr, awlen, awsize, axi_burst_e'(awburst), beat_idx);
    endfunction : get_beat_addr

    function bit [STRB_WIDTH-1:0] get_beat_wstrb_mask(int unsigned beat_idx);
        return burst_math_t::get_byte_lane_mask(
            awaddr, awlen, awsize, axi_burst_e'(awburst), beat_idx);
    endfunction : get_beat_wstrb_mask

    function int unsigned get_mem_access_bytes();
        return burst_math_t::get_access_bytes(
            awlen, awsize, axi_burst_e'(awburst));
    endfunction : get_mem_access_bytes

    function void post_randomize();
        bit [ADDR_WIDTH-1:0] beat_addr;
        bit [DATA_WIDTH-1:0] beat_data;
        bit [STRB_WIDTH-1:0] legal_mask;

        if (axi_master_write_cfg == null) begin
            return;
        end

        // Fixed arrays are payload overrides, not AWLEN constraints.  Copy
        // them only after the request geometry has been randomized; Driver
        // rejects any length mismatch before either source VALID is driven.
        if (axi_master_write_cfg.fix_wdata_array_enable) begin
            wdata = new[axi_master_write_cfg.wdata_array.size()];
            foreach (wdata[i]) wdata[i] = axi_master_write_cfg.wdata_array[i];
        end
        else if (axi_master_write_cfg.fix_wdata_enable) begin
            foreach (wdata[i]) wdata[i] = axi_master_write_cfg.wdata;
        end
        // Keep deterministic patterns out of the solver.  ADDR_BASED data is
        // deferred in random-address Mem mode because Driver owns the single
        // final AWADDR/AWSIZE materialization in that mode.
        else begin
            if (wdata_type == AXI_MASTER_WRITE_DATA_INCREMENT) begin
                foreach (wdata[i]) begin
                    wdata[i] = i;
                end
            end
            else if (wdata_type == AXI_MASTER_WRITE_DATA_ADDR_BASED &&
                     !(axi_master_write_cfg.use_mem_model &&
                       !axi_master_write_cfg.fix_awaddr_enable)) begin
                foreach (wdata[i]) begin
                    beat_addr = get_beat_addr(i);
                    beat_data = '0;
                    beat_data = beat_addr;
                    wdata[i] = beat_data;
                end
            end
        end

        if (axi_master_write_cfg.fix_wstrb_array_enable) begin
            wstrb = new[axi_master_write_cfg.wstrb_array.size()];
            foreach (wstrb[i]) wstrb[i] = axi_master_write_cfg.wstrb_array[i];
        end
        else if (axi_master_write_cfg.fix_wstrb_enable) begin
            foreach (wstrb[i]) wstrb[i] = axi_master_write_cfg.wstrb;
        end
        // Keep the solver-randomized WSTRB bits only on byte lanes that belong
        // to this beat. A zero mask is legal and represents a no-byte write.
        // Random-address Mem mode defers this masking until Driver owns the
        // final AWADDR/AWSIZE geometry.
        else if (!(axi_master_write_cfg.use_mem_model &&
                   !axi_master_write_cfg.fix_awaddr_enable)) begin
            foreach (wstrb[i]) begin
                legal_mask = get_beat_wstrb_mask(i);
                wstrb[i] &= legal_mask;
            end
        end
    endfunction : post_randomize

    //
    // User constraints
    //
    constraint solve_order_c {
        solve awid_type before awid;
        solve desired_mem_response before awlock;
        solve expect_size_error before awlock;
        solve awlock before awburst;
        solve awlock before awlen_type;
        solve awlock before awlen;
        solve awburst before awlen_type;
        solve awlen_type before awlen;
        solve awburst before awlen;
        solve awlen before awsize;
        solve awsize before awaddr_offset_type;
        solve awaddr_offset_type before awaddr_offset;
        solve awaddr_offset before awaddr;
        solve awlock before awaddr;
        solve awburst before awaddr;
        solve awlen before awaddr;
        solve awsize before awaddr;
    }

    constraint desired_mem_response_c {
        if (axi_master_write_cfg.use_mem_model &&
            !axi_master_write_cfg.fix_awaddr_enable) {
            desired_mem_response dist {
                MEM_RESP_OKAY   := axi_master_write_cfg.resp_dist[0],
                MEM_RESP_SLVERR := axi_master_write_cfg.resp_dist[1],
                MEM_RESP_DECERR := axi_master_write_cfg.resp_dist[2]
            };
        }
        else {
            desired_mem_response == MEM_RESP_OKAY;
        }
    }

    constraint expect_size_error_c {
        if (axi_master_write_cfg.use_mem_model &&
            !axi_master_write_cfg.fix_awaddr_enable &&
            !axi_master_write_cfg.fix_awsize_enable) {
            expect_size_error dist {
                1'b0 := axi_master_write_cfg.size_resp_weight,
                1'b1 := 100 - axi_master_write_cfg.size_resp_weight
            };
        }
        else {
            expect_size_error == 1'b0;
        }
    }

    // awid uses axi_master_write_cfg.awid_type_dist:
    // ZERO/MIN, LOW, HIGH, MAX are separate random items for corner cases.
    constraint awid_type_c {
        if (!axi_master_write_cfg.fix_awid_enable) {
            awid_type dist {
                AXI_MASTER_WRITE_ID_ZERO      := axi_master_write_cfg.awid_type_dist[AXI_MASTER_WRITE_ID_ZERO],
                AXI_MASTER_WRITE_ID_LOW       := axi_master_write_cfg.awid_type_dist[AXI_MASTER_WRITE_ID_LOW],
                AXI_MASTER_WRITE_ID_HIGH      := axi_master_write_cfg.awid_type_dist[AXI_MASTER_WRITE_ID_HIGH],
                AXI_MASTER_WRITE_ID_MAX_VALUE := axi_master_write_cfg.awid_type_dist[AXI_MASTER_WRITE_ID_MAX_VALUE]
            };
        }
    }

    constraint awid_c {
        if (axi_master_write_cfg.fix_awid_enable) {
            awid == axi_master_write_cfg.awid;
        }
        else {
            (awid_type == AXI_MASTER_WRITE_ID_ZERO)      -> awid == '0;
            if (ID_WIDTH <= 2) {
                (awid_type == AXI_MASTER_WRITE_ID_LOW)  -> awid inside {[1:ID_MAX]};
                (awid_type == AXI_MASTER_WRITE_ID_HIGH) -> awid inside {[1:ID_MAX]};
            }
            else {
                (awid_type == AXI_MASTER_WRITE_ID_LOW)  -> awid inside {[1:3]};
                (awid_type == AXI_MASTER_WRITE_ID_HIGH) -> awid inside {[4:ID_MAX-1]};
            }
            (awid_type == AXI_MASTER_WRITE_ID_MAX_VALUE) -> awid == ID_MAX;
        }
    }

    constraint awaddr_offset_type_c {
        if (!axi_master_write_cfg.fix_awaddr_enable) {
            awaddr_offset_type dist {
                AXI_MASTER_WRITE_ADDR_OFFSET_ZERO      := axi_master_write_cfg.awaddr_offset_dist[AXI_MASTER_WRITE_ADDR_OFFSET_ZERO],
                AXI_MASTER_WRITE_ADDR_OFFSET_LOW       := axi_master_write_cfg.awaddr_offset_dist[AXI_MASTER_WRITE_ADDR_OFFSET_LOW],
                AXI_MASTER_WRITE_ADDR_OFFSET_NORMAL    := axi_master_write_cfg.awaddr_offset_dist[AXI_MASTER_WRITE_ADDR_OFFSET_NORMAL],
                AXI_MASTER_WRITE_ADDR_OFFSET_HIGH      := axi_master_write_cfg.awaddr_offset_dist[AXI_MASTER_WRITE_ADDR_OFFSET_HIGH],
                AXI_MASTER_WRITE_ADDR_OFFSET_MAX_VALUE := axi_master_write_cfg.awaddr_offset_dist[AXI_MASTER_WRITE_ADDR_OFFSET_MAX_VALUE]
            };
        }
        else {
            awaddr_offset_type == AXI_MASTER_WRITE_ADDR_OFFSET_ZERO;
        }
    }

    constraint awaddr_offset_c {
        if (axi_master_write_cfg.fix_awaddr_enable) {
            awaddr_offset == axi_master_write_cfg.awaddr[11:0];
        }
        else if (axi_master_write_cfg.use_mem_model) {
            // The offset type is the random intent. Driver materializes and
            // writes back the exact offset with the final Mem address.
            awaddr_offset == '0;
        }
        else {
            (awaddr_offset_type == AXI_MASTER_WRITE_ADDR_OFFSET_ZERO)      -> awaddr_offset == 12'h000;
            (awaddr_offset_type == AXI_MASTER_WRITE_ADDR_OFFSET_LOW)       -> awaddr_offset inside {[12'h001:12'h0ff]};
            (awaddr_offset_type == AXI_MASTER_WRITE_ADDR_OFFSET_NORMAL)    -> awaddr_offset inside {[12'h100:12'hfef]};
            (awaddr_offset_type == AXI_MASTER_WRITE_ADDR_OFFSET_HIGH)      -> awaddr_offset inside {[12'hff0:12'hffe]};
            (awaddr_offset_type == AXI_MASTER_WRITE_ADDR_OFFSET_MAX_VALUE) -> awaddr_offset == 12'hfff;
        }
    }

    constraint awaddr_c {
        if (axi_master_write_cfg.fix_awaddr_enable) {
            awaddr == axi_master_write_cfg.awaddr;
        }
        else if (axi_master_write_cfg.use_mem_model) {
            // Driver materializes the final address from the selected Segment.
            awaddr == '0;
        }
        else if (axi_master_write_cfg.align_size) {
            awaddr[11:0] ==
                (awaddr_offset / (1 << awsize)) * (1 << awsize);
        }
        else {
            awaddr[11:0] == awaddr_offset;
        }
    }

    // For ordinary random-address traffic, AWADDR is the final random node.
    // Extend the arithmetic beyond ADDR_WIDTH so a legal low address cannot
    // silently wrap at the top of the configured address space. Fixed and
    // Mem-Model addresses bypass this constraint and are checked by Driver.
    constraint random_awaddr_range_c {
        if (!axi_master_write_cfg.fix_awaddr_enable &&
            !axi_master_write_cfg.use_mem_model) {
            if (awburst == AXI_MASTER_WRITE_BURST_FIXED) {
                (({17'b0, awaddr} / (1 << awsize)) * (1 << awsize)) +
                    (1 << awsize) - 1 <=
                    {17'b0, ADDR_MAX};
            }
            else if (awburst == AXI_MASTER_WRITE_BURST_INCR) {
                (({17'b0, awaddr} / (1 << awsize)) * (1 << awsize)) +
                    ((int'(awlen) + 1) * (1 << awsize)) - 1 <=
                    {17'b0, ADDR_MAX};
            }
            else if (awburst == AXI_MASTER_WRITE_BURST_WRAP) {
                (({17'b0, awaddr} /
                    ((int'(awlen) + 1) * (1 << awsize))) *
                    ((int'(awlen) + 1) * (1 << awsize))) +
                    ((int'(awlen) + 1) * (1 << awsize)) - 1 <=
                    {17'b0, ADDR_MAX};
            }
        }
    }

    // awlen uses axi_master_write_cfg.awlen_type_dist. awlen is the AXI field
    // value, so total beats are awlen + 1.
    constraint awlen_type_c {
        if (!axi_master_write_cfg.fix_awlen_enable &&
            awburst != AXI_MASTER_WRITE_BURST_WRAP) {
            awlen_type dist {
                AXI_MASTER_WRITE_LEN_SINGLE    := axi_master_write_cfg.awlen_type_dist[AXI_MASTER_WRITE_LEN_SINGLE],
                AXI_MASTER_WRITE_LEN_SHORT     := axi_master_write_cfg.awlen_type_dist[AXI_MASTER_WRITE_LEN_SHORT],
                AXI_MASTER_WRITE_LEN_MID       := axi_master_write_cfg.awlen_type_dist[AXI_MASTER_WRITE_LEN_MID],
                AXI_MASTER_WRITE_LEN_LONG      := axi_master_write_cfg.awlen_type_dist[AXI_MASTER_WRITE_LEN_LONG],
                AXI_MASTER_WRITE_LEN_MAX_VALUE := axi_master_write_cfg.awlen_type_dist[AXI_MASTER_WRITE_LEN_MAX_VALUE]
            };
        }
    }

    constraint awlen_c {
        if (axi_master_write_cfg.fix_awlen_enable) {
            awlen == axi_master_write_cfg.awlen;
        }
        else if (awburst == AXI_MASTER_WRITE_BURST_WRAP) {
            awlen inside {8'd1, 8'd3, 8'd7, 8'd15};
        }
        else {
            (awlen_type == AXI_MASTER_WRITE_LEN_SINGLE)    -> awlen == 0;
            (awlen_type == AXI_MASTER_WRITE_LEN_SHORT)     -> awlen inside {[1:3]};
            (awlen_type == AXI_MASTER_WRITE_LEN_MID)       -> awlen inside {[4:7]};
            (awlen_type == AXI_MASTER_WRITE_LEN_LONG)      -> awlen inside {[8:AXI_MASTER_WRITE_MAX_BEATS-2]};
            (awlen_type == AXI_MASTER_WRITE_LEN_MAX_VALUE) -> awlen == AXI_MASTER_WRITE_MAX_BEATS - 1;
        }
        if (!axi_master_write_cfg.fix_awlen_enable) {
            awlen inside {[0:AXI_MASTER_WRITE_MAX_BEATS-1]};
            (awburst == AXI_MASTER_WRITE_BURST_FIXED) -> awlen <= 8'd15;
            awlock -> awlen inside {8'd0, 8'd1, 8'd3, 8'd7, 8'd15};
        }
    }

    constraint awsize_c {
        if (axi_master_write_cfg.fix_awsize_enable) {
            awsize == axi_master_write_cfg.awsize;
        }
        else if (axi_master_write_cfg.use_mem_model &&
                 !axi_master_write_cfg.fix_awaddr_enable) {
            // The Driver owns the single final AWSIZE selection in Mem Model
            // mode.  This deterministic value is only a solver placeholder;
            // it does not consume awsize_dist and is not sent on the bus.
            awsize == 0;
        }
        else if (BUS_SIZE == 0) {
            awsize == 0;
        }
        else if (BUS_SIZE == 1) {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                1 := axi_master_write_cfg.awsize_dist[1]
            };
        }
        else if (BUS_SIZE == 2) {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                1 :/ axi_master_write_cfg.awsize_dist[1],
                2 := axi_master_write_cfg.awsize_dist[2]
            };
        }
        else if (BUS_SIZE == 3) {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                [1:2] :/ axi_master_write_cfg.awsize_dist[1],
                3 := axi_master_write_cfg.awsize_dist[2]
            };
        }
        else if (BUS_SIZE == 4) {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                [1:3] :/ axi_master_write_cfg.awsize_dist[1],
                4 := axi_master_write_cfg.awsize_dist[2]
            };
        }
        else if (BUS_SIZE == 5) {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                [1:4] :/ axi_master_write_cfg.awsize_dist[1],
                5 := axi_master_write_cfg.awsize_dist[2]
            };
        }
        else if (BUS_SIZE == 6) {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                [1:5] :/ axi_master_write_cfg.awsize_dist[1],
                6 := axi_master_write_cfg.awsize_dist[2]
            };
        }
        else {
            awsize dist {
                0 := axi_master_write_cfg.awsize_dist[0],
                [1:6] :/ axi_master_write_cfg.awsize_dist[1],
                7 := axi_master_write_cfg.awsize_dist[2]
            };
        }
        if (!axi_master_write_cfg.fix_awsize_enable &&
            !(axi_master_write_cfg.use_mem_model &&
              !axi_master_write_cfg.fix_awaddr_enable) &&
            awlock &&
            (!axi_master_write_cfg.fix_awlen_enable ||
             awlen inside {8'd0, 8'd1, 8'd3, 8'd7, 8'd15})) {
            ((int'(awlen) + 1) * (1 << awsize)) <= 128;
        }
    }

    constraint awburst_type_c {
        if (axi_master_write_cfg.fix_awburst_enable) {
            awburst == axi_master_write_cfg.awburst;
        }
        else {
            awburst dist {
                AXI_MASTER_WRITE_BURST_FIXED := axi_master_write_cfg.awburst_dist[AXI_MASTER_WRITE_BURST_FIXED],
                AXI_MASTER_WRITE_BURST_INCR  := axi_master_write_cfg.awburst_dist[AXI_MASTER_WRITE_BURST_INCR],
                AXI_MASTER_WRITE_BURST_WRAP  := axi_master_write_cfg.awburst_dist[AXI_MASTER_WRITE_BURST_WRAP]
            };
        }
    }

    constraint awburst_wrap_addr_c {
        if (!axi_master_write_cfg.fix_awaddr_enable &&
            !axi_master_write_cfg.use_mem_model) {
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 1) -> awaddr[0:0] == '0;
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 2) -> awaddr[1:0] == '0;
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 3) -> awaddr[2:0] == '0;
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 4) -> awaddr[3:0] == '0;
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 5) -> awaddr[4:0] == '0;
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 6) -> awaddr[5:0] == '0;
            (awburst == AXI_MASTER_WRITE_BURST_WRAP && awsize == 7) -> awaddr[6:0] == '0;
            // Exclusive total-size alignment mirrors the Read side: only apply
            // it to a legal exclusive geometry. An illegal fixed AWLEN (not in
            // {0,1,3,7,15}) is left for the Driver to reject instead of forcing
            // a non-power-of-two alignment here.
            (awlock &&
             (awlen inside {8'd0, 8'd1, 8'd3, 8'd7, 8'd15}) &&
             awsize <= BUS_SIZE &&
             ((int'(awlen) + 1) * (1 << awsize)) <= 128) ->
                (awaddr % ((int'(awlen) + 1) * (1 << awsize))) == 0;
            if (axi_master_write_cfg.addr_4k_protect_enable) {
                if (awburst == AXI_MASTER_WRITE_BURST_FIXED) {
                    ((awaddr[11:0] / (1 << awsize)) * (1 << awsize)) +
                        (1 << awsize) <= 4096;
                }
                else if (awburst == AXI_MASTER_WRITE_BURST_WRAP) {
                    ((awaddr[11:0] /
                      ((int'(awlen) + 1) * (1 << awsize))) *
                     ((int'(awlen) + 1) * (1 << awsize))) +
                        ((int'(awlen) + 1) * (1 << awsize)) <= 4096;
                }
                else if (awburst == AXI_MASTER_WRITE_BURST_INCR) {
                    ((awaddr[11:0] / (1 << awsize)) * (1 << awsize)) +
                        ((int'(awlen) + 1) * (1 << awsize)) <= 4096;
                }
            }
        }
    }

    constraint awlock_c {
        if (axi_master_write_cfg.fix_awlock_enable) {
            awlock == axi_master_write_cfg.awlock;
        }
        else {
            awlock dist {0 := 100 - axi_master_write_cfg.awlock_weight, 1 := axi_master_write_cfg.awlock_weight};
        }
    }

    constraint awcache_c {
        if (axi_master_write_cfg.fix_awcache_enable) {
            awcache == axi_master_write_cfg.awcache;
        }
        else {
            axi_cache_is_legal(awcache);
            (awcache == 4'h0) dist {
                1'b1 := 100 - axi_master_write_cfg.awcache_nonzero_weight,
                1'b0 := axi_master_write_cfg.awcache_nonzero_weight
            };
        }
    }

    constraint awprot_c {
        if (axi_master_write_cfg.fix_awprot_enable) {
            awprot == axi_master_write_cfg.awprot;
        }
        else {
            awprot dist {3'h0 := 100 - axi_master_write_cfg.awprot_nonzero_weight, [3'h1:3'h7] :/ axi_master_write_cfg.awprot_nonzero_weight};
        }
    }

    constraint awqos_c {
        if (axi_master_write_cfg.fix_awqos_enable) {
            awqos == axi_master_write_cfg.awqos;
        }
        else {
            awqos dist {4'h0 := 100 - axi_master_write_cfg.awqos_nonzero_weight, [4'h1:4'hf] :/ axi_master_write_cfg.awqos_nonzero_weight};
        }
    }

    constraint awregion_c {
        if (axi_master_write_cfg.fix_awregion_enable) {
            awregion == axi_master_write_cfg.awregion;
        }
        else {
            awregion dist {4'h0 := 100 - axi_master_write_cfg.awregion_nonzero_weight, [4'h1:4'hf] :/ axi_master_write_cfg.awregion_nonzero_weight};
        }
    }

    constraint awuser_c {
        if (axi_master_write_cfg.fix_awuser_enable) {
            awuser == axi_master_write_cfg.awuser;
        }
        else {
            awuser dist {'0 := 100 - axi_master_write_cfg.awuser_nonzero_weight, [1:USER_MAX] :/ axi_master_write_cfg.awuser_nonzero_weight};
        }
    }

    constraint warray_size_c {
        wdata.size() == awlen + 1;
        wstrb.size() == awlen + 1;
        wuser.size() == awlen + 1;
    }

    constraint wdata_type_c {
        if (axi_master_write_cfg.fix_wdata_type_enable) {
            wdata_type == axi_master_write_cfg.wdata_type;
        }
        else if (!axi_master_write_cfg.fix_wdata_enable && !axi_master_write_cfg.fix_wdata_array_enable) {
            wdata_type dist {
                AXI_MASTER_WRITE_DATA_RANDOM     := axi_master_write_cfg.wdata_type_dist[AXI_MASTER_WRITE_DATA_RANDOM],
                AXI_MASTER_WRITE_DATA_INCREMENT  := axi_master_write_cfg.wdata_type_dist[AXI_MASTER_WRITE_DATA_INCREMENT],
                AXI_MASTER_WRITE_DATA_ADDR_BASED := axi_master_write_cfg.wdata_type_dist[AXI_MASTER_WRITE_DATA_ADDR_BASED]
            };
        }
    }

    constraint wdata_c {
        if (axi_master_write_cfg.fix_wdata_enable &&
            !axi_master_write_cfg.fix_wdata_array_enable) {
            foreach (wdata[i]) {
                wdata[i] == axi_master_write_cfg.wdata;
            }
        }
        // Auto payload (RANDOM/INCREMENT/ADDR_BASED) is materialized outside
        // the solver: RANDOM stays free-random, INCREMENT/ADDR_BASED are
        // filled in post_randomize (or Driver, in random-address Mem mode).
        // Constant patterns (all-0, all-1, 0xA5...) are obtained via fix_wdata.
    }

    constraint wstrb_c {
        if (axi_master_write_cfg.fix_wstrb_enable &&
            !axi_master_write_cfg.fix_wstrb_array_enable) {
            foreach (wstrb[i]) {
                wstrb[i] == axi_master_write_cfg.wstrb;
            }
        }
    }

    constraint wuser_c {
        foreach (wuser[i]) {
            if (axi_master_write_cfg.fix_wuser_enable) {
                wuser[i] == axi_master_write_cfg.wuser;
            }
            else {
                wuser[i] dist {
                    '0 := 100 - axi_master_write_cfg.wuser_nonzero_weight,
                    [1:USER_MAX] :/ axi_master_write_cfg.wuser_nonzero_weight
                };
            }
        }
    }
endclass : axi_master_write_base_seq_item

class axi_master_write_seq_item #(
    int unsigned ID_WIDTH   = AXI_MASTER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_MASTER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_MASTER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_MASTER_WRITE_USER_WIDTH
) extends axi_master_write_base_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH
);
    typedef axi_master_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    // Per-packet timing. The reset-to-first-source-VALID delay belongs to the
    // driver reset epoch and is therefore not carried by each transaction.
    // The item only selects basic values; FIFO ownership, history anchors and
    // protocol-safe issue decisions are implemented by the driver.
    rand axi_master_write_aw_w_order_e aw_w_order;
    rand int unsigned aw_w_delay;
    rand int unsigned pkg_delay;
    // One entry for each inter-beat gap. AWLEN is beat_count-1, so the array is
    // empty for a single-beat burst and has exactly AWLEN entries otherwise.
    rand int unsigned w_delay[];
    rand axi_master_write_timing_delay_segment_e aw_w_delay_segment;
    rand axi_master_write_timing_delay_segment_e pkg_delay_segment;
    rand axi_master_write_timing_delay_segment_e w_delay_segment[];

    rand axi_master_write_delay_type_e bready_delay_type;
    rand int unsigned bready_delay;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_enum (axi_master_write_aw_w_order_e, aw_w_order, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int  (aw_w_delay,   UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int  (pkg_delay,    UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_array_int(w_delay,  UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_enum (axi_master_write_delay_type_e, bready_delay_type, UVM_DEFAULT | UVM_NOCOMPARE)
        `uvm_field_int  (bready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new (string name = "axi_master_write_seq_item");
        super.new(name);
    endfunction : new

    constraint ext_solve_order_c {
        solve aw_w_order before aw_w_delay_segment;
        solve aw_w_delay_segment before aw_w_delay;
        solve pkg_delay_segment before pkg_delay;
        solve awlen before w_delay_segment;
        solve awlen before w_delay;
        solve w_delay_segment before w_delay;
        solve bready_delay_type before bready_delay;
    }

    constraint aw_w_order_c {
        if (axi_master_write_cfg.fix_aw_w_order_enable) {
            aw_w_order == axi_master_write_cfg.aw_w_order;
        }
        else {
            aw_w_order dist {
                AXI_MASTER_WRITE_AW_W_SAME := axi_master_write_cfg.aw_w_order_dist[AXI_MASTER_WRITE_AW_W_SAME],
                AXI_MASTER_WRITE_AW_FIRST  := axi_master_write_cfg.aw_w_order_dist[AXI_MASTER_WRITE_AW_FIRST],
                AXI_MASTER_WRITE_W_FIRST   := axi_master_write_cfg.aw_w_order_dist[AXI_MASTER_WRITE_W_FIRST]
            };
        }
    }

    constraint aw_w_delay_c {
        if (axi_master_write_cfg.fix_aw_w_delay_enable) {
            aw_w_delay == axi_master_write_cfg.aw_w_delay;
        }
        else if (aw_w_order == AXI_MASTER_WRITE_AW_W_SAME) {
            aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_ZERO;
            aw_w_delay == 0;
        }
        else {
            aw_w_delay_segment dist {
                AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := axi_master_write_cfg.aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
                AXI_MASTER_WRITE_TIMING_DELAY_MID       := axi_master_write_cfg.aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
                AXI_MASTER_WRITE_TIMING_DELAY_LONG      := axi_master_write_cfg.aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
                AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := axi_master_write_cfg.aw_w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
            };
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> aw_w_delay inside {[1:3]};
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> aw_w_delay inside {[4:10]};
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> aw_w_delay inside {[11:31]};
            (aw_w_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> aw_w_delay inside {[32:63]};
        }
    }

    constraint pkg_delay_c {
        if (axi_master_write_cfg.fix_pkg_delay_enable) {
            pkg_delay == axi_master_write_cfg.pkg_delay;
        }
        else {
            pkg_delay_segment dist {
                AXI_MASTER_WRITE_TIMING_DELAY_ZERO      := axi_master_write_cfg.pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_ZERO],
                AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := axi_master_write_cfg.pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
                AXI_MASTER_WRITE_TIMING_DELAY_MID       := axi_master_write_cfg.pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
                AXI_MASTER_WRITE_TIMING_DELAY_LONG      := axi_master_write_cfg.pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
                AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := axi_master_write_cfg.pkg_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
            };
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_ZERO)      -> pkg_delay == 0;
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> pkg_delay inside {[1:3]};
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> pkg_delay inside {[4:10]};
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> pkg_delay inside {[11:31]};
            (pkg_delay_segment == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> pkg_delay inside {[32:63]};
        }
    }

    constraint w_delay_c {
        w_delay.size() == awlen;
        if (axi_master_write_cfg.fix_w_delay_enable) {
            w_delay_segment.size() == 0;
            foreach (w_delay[i]) {
                w_delay[i] == axi_master_write_cfg.w_delay;
            }
        }
        else {
            w_delay_segment.size() == awlen;
            foreach (w_delay[i]) {
                w_delay_segment[i] dist {
                    AXI_MASTER_WRITE_TIMING_DELAY_ZERO      := axi_master_write_cfg.w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_ZERO],
                    AXI_MASTER_WRITE_TIMING_DELAY_SHORT     := axi_master_write_cfg.w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_SHORT],
                    AXI_MASTER_WRITE_TIMING_DELAY_MID       := axi_master_write_cfg.w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MID],
                    AXI_MASTER_WRITE_TIMING_DELAY_LONG      := axi_master_write_cfg.w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_LONG],
                    AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE := axi_master_write_cfg.w_delay_dist[AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE]
                };
                (w_delay_segment[i] == AXI_MASTER_WRITE_TIMING_DELAY_ZERO)      -> w_delay[i] == 0;
                (w_delay_segment[i] == AXI_MASTER_WRITE_TIMING_DELAY_SHORT)     -> w_delay[i] inside {[1:3]};
                (w_delay_segment[i] == AXI_MASTER_WRITE_TIMING_DELAY_MID)       -> w_delay[i] inside {[4:10]};
                (w_delay_segment[i] == AXI_MASTER_WRITE_TIMING_DELAY_LONG)      -> w_delay[i] inside {[11:31]};
                (w_delay_segment[i] == AXI_MASTER_WRITE_TIMING_DELAY_MAX_VALUE) -> w_delay[i] inside {[32:63]};
            }
        }
    }

    constraint bready_delay_type_c {
        if (!axi_master_write_cfg.fix_bready_delay_enable &&
            axi_master_write_cfg.bready_mode == AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH) {
            bready_delay_type == AXI_MASTER_WRITE_DELAY_ZERO;
        }
        else if (!axi_master_write_cfg.fix_bready_delay_enable) {
            bready_delay_type dist {
                AXI_MASTER_WRITE_DELAY_ZERO      := axi_master_write_cfg.bready_delay_type_dist[AXI_MASTER_WRITE_DELAY_ZERO],
                AXI_MASTER_WRITE_DELAY_SHORT     := axi_master_write_cfg.bready_delay_type_dist[AXI_MASTER_WRITE_DELAY_SHORT],
                AXI_MASTER_WRITE_DELAY_MID       := axi_master_write_cfg.bready_delay_type_dist[AXI_MASTER_WRITE_DELAY_MID],
                AXI_MASTER_WRITE_DELAY_LONG      := axi_master_write_cfg.bready_delay_type_dist[AXI_MASTER_WRITE_DELAY_LONG],
                AXI_MASTER_WRITE_DELAY_MAX_VALUE := axi_master_write_cfg.bready_delay_type_dist[AXI_MASTER_WRITE_DELAY_MAX_VALUE]
            };
        }
    }

    constraint bready_delay_c {
        if (axi_master_write_cfg.fix_bready_delay_enable) {
            bready_delay == axi_master_write_cfg.bready_delay;
        }
        else if (axi_master_write_cfg.bready_mode == AXI_MASTER_WRITE_BREADY_ALWAYS_HIGH) {
            bready_delay == 0;
        }
        else {
            (bready_delay_type == AXI_MASTER_WRITE_DELAY_ZERO)      -> bready_delay == 0;
            (bready_delay_type == AXI_MASTER_WRITE_DELAY_SHORT)     -> bready_delay inside {[1:3]};
            (bready_delay_type == AXI_MASTER_WRITE_DELAY_MID)       -> bready_delay inside {[4:10]};
            (bready_delay_type == AXI_MASTER_WRITE_DELAY_LONG)      -> bready_delay inside {[11:31]};
            (bready_delay_type == AXI_MASTER_WRITE_DELAY_MAX_VALUE) -> bready_delay inside {[32:63]};
        }
    }
endclass : axi_master_write_seq_item
`endif
