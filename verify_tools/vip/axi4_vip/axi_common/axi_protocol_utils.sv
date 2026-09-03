// ============================================================================
// Filename             : axi_protocol_utils.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_PROTOCOL_UTILS_SV
`define AXI_PROTOCOL_UTILS_SV

typedef enum bit [1:0] {
    AXI_BURST_FIXED = 2'b00,
    AXI_BURST_INCR  = 2'b01,
    AXI_BURST_WRAP  = 2'b10
} axi_burst_e;

typedef enum bit [1:0] {
    AXI_RESP_OKAY   = 2'b00,
    AXI_RESP_EXOKAY = 2'b01,
    AXI_RESP_SLVERR = 2'b10,
    AXI_RESP_DECERR = 2'b11
} axi_resp_e;

// Shared Slave request-channel READY policy.  The single Common definition
// keeps Read/Write wildcard imports unambiguous while preserving the original
// numeric values (AXI_ALWAYS_HIGH=0, AXI_AFTER_VALID=1).
typedef enum int unsigned {
    AXI_ALWAYS_HIGH = 0,
    AXI_AFTER_VALID = 1
} axi_ready_mode_e;

// Cross-ID response scheduling policy shared by the read and write Slaver
// endpoints. AXI ordering within one ID is always preserved regardless of
// this policy.
typedef enum int unsigned {
    AXI_RESP_IN_ORDER,
    AXI_RESP_REVERSE_ORDER,
    AXI_RESP_READY_ORDER
} axi_response_order_e;

// Driver-side request preparation result.  A sequence item is an attempt;
// only AXI_PREPARE_OK enters a protocol queue and contributes to completion
// accounting.
typedef enum bit [1:0] {
    AXI_PREPARE_NOT_RUN,
    AXI_PREPARE_OK,
    AXI_PREPARE_NO_CANDIDATE
} axi_prepare_status_e;

// Stable reasons carried through stimulus preparation and protocol request
// validation.  Hot-path helpers return these values without reporting; only
// the owning boundary formats a UVM report.
typedef enum int unsigned {
    AXI_PREPARE_REASON_NONE,
    AXI_PREPARE_REASON_NULL_ITEM,
    AXI_PREPARE_REASON_TIMING,
    AXI_PREPARE_REASON_MODEL_NULL,
    AXI_PREPARE_REASON_SEGMENT_MAP_EMPTY,
    AXI_PREPARE_REASON_RESPONSE_TARGET_EMPTY,
    AXI_PREPARE_REASON_SIZE_TARGET_EMPTY,
    AXI_PREPARE_REASON_BASE_GEOMETRY,
    AXI_PREPARE_REASON_ADDR_TARGET_EMPTY,
    AXI_PREPARE_REASON_ADDR_COUNT_OVERFLOW,
    AXI_PREPARE_REASON_FINAL_GEOMETRY,
    AXI_PREPARE_REASON_PAYLOAD_TIMING,
    AXI_PREPARE_REASON_INTERNAL,
    AXI_PREPARE_REASON_CACHE_RESERVED
} axi_prepare_reason_e;

typedef enum int unsigned {
    AXI_REQUEST_RULE_OK,
    AXI_REQUEST_RULE_NULL_CONTEXT,
    AXI_REQUEST_RULE_UNSUPPORTED_BURST,
    AXI_REQUEST_RULE_LEN_EXCEEDS_MAX,
    AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS,
    AXI_REQUEST_RULE_FIXED_TOO_LONG,
    AXI_REQUEST_RULE_WRAP_LENGTH,
    AXI_REQUEST_RULE_WRAP_ALIGNMENT,
    AXI_REQUEST_RULE_ADDRESS_OVERFLOW,
    AXI_REQUEST_RULE_CROSSES_4KB,
    AXI_REQUEST_RULE_EXCLUSIVE_BEATS,
    AXI_REQUEST_RULE_EXCLUSIVE_BYTES,
    AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT,
    AXI_REQUEST_RULE_OUTSIDE_SEGMENT,
    AXI_REQUEST_RULE_PAYLOAD_COUNT,
    AXI_REQUEST_RULE_WDATA_COUNT,
    AXI_REQUEST_RULE_WSTRB_COUNT,
    AXI_REQUEST_RULE_WDELAY_COUNT,
    AXI_REQUEST_RULE_WDATA_TYPE,
    AXI_REQUEST_RULE_AW_W_ORDER,
    AXI_REQUEST_RULE_AW_W_DELAY,
    AXI_REQUEST_RULE_AR_DELAY_RANGE,
    AXI_REQUEST_RULE_RREADY_DELAY_RANGE,
    AXI_REQUEST_RULE_RREADY_MODE_CONFLICT,
    AXI_REQUEST_RULE_WRITE_DELAY_RANGE,
    AXI_REQUEST_RULE_BREADY_MODE_CONFLICT,
    AXI_REQUEST_RULE_WSTRB_LANE,
    AXI_REQUEST_RULE_TIMING,
    AXI_REQUEST_RULE_INTERNAL,
    AXI_REQUEST_RULE_CACHE_RESERVED,
    AXI_REQUEST_RULE_WUSER_COUNT
} axi_request_rule_e;

// AxLEN is eight bits in AXI4, so a protocol-visible burst can contain at
// most 256 transfers. Endpoint MAX_BEATS profiles are stimulus/response
// capability controls; Common Monitors use this protocol limit instead.
localparam int unsigned AXI4_MAX_BURST_BEATS = 256;

typedef enum int unsigned {
    AXI_ADDR_SEARCH_FOUND,
    AXI_ADDR_SEARCH_EMPTY,
    AXI_ADDR_SEARCH_COUNT_OVERFLOW
} axi_addr_search_status_e;

// Common cold-path formatter.  Existing UVM report IDs remain stable while
// every message exposes a machine-searchable reason and enough context to
// understand the observed value, expected rule, and resulting action.
class axi_diag;
    static function string format(
        input string reason,
        input string role,
        input string channel,
        input string stage,
        input string observed,
        input string expected,
        input string action,
        input string detail = ""
    );
        string suffix;

        suffix = (detail == "") ? "" : {" detail={", detail, "}"};
        return $sformatf(
            {"reason=%s role=%s channel=%s stage=%s observed={%s} ",
             "expected={%s} action=%s%s"},
            reason, role, channel, stage, observed, expected, action, suffix);
    endfunction : format
endclass : axi_diag

// AXI4 Table A4-5 defines these ten AxCACHE encodings.  All other 4-bit
// values are reserved.  Keep one pure rule for stimulus, Drivers, and
// Monitors so legal generation and observation cannot drift apart.
localparam string AXI_CACHE_LEGAL_EXPECTED =
    "AxCACHE inside {0x0,0x1,0x2,0x3,0x6,0x7,0xA,0xB,0xE,0xF}";

function automatic bit axi_cache_is_legal(input logic [3:0] cache);
    case (cache)
        4'h0, 4'h1, 4'h2, 4'h3, 4'h6,
        4'h7, 4'ha, 4'hb, 4'he, 4'hf: return 1'b1;
        default: return 1'b0;
    endcase
endfunction : axi_cache_is_legal

// Pure AXI burst calculations shared by common observation and endpoint
// stimulus/response code. ADDR_WIDTH and DATA_BYTES keep endpoint-specific
// compile-time widths intact while centralizing the protocol arithmetic.
class axi_burst_math #(
    parameter int unsigned ADDR_WIDTH,
    parameter int unsigned DATA_BYTES
);
    typedef bit [ADDR_WIDTH-1:0]       addr_t;
    typedef bit [DATA_BYTES-1:0]       byte_mask_t;
    typedef bit [(DATA_BYTES*8)-1:0]   data_mask_t;

    static function bit is_supported_burst(input axi_burst_e burst);
        return burst inside {AXI_BURST_FIXED, AXI_BURST_INCR, AXI_BURST_WRAP};
    endfunction : is_supported_burst

    // Check rules whose result does not depend on the final address.  This is
    // intentionally separate from get_request_geometry_rule() so a random
    // Mem address failure is never misreported when BURST/LEN/SIZE was the
    // actual cause.
    static function axi_request_rule_e get_address_independent_rule(
        input bit [7:0]    len,
        input bit [2:0]    size,
        input axi_burst_e  burst,
        input int unsigned max_beats,
        input bit          exclusive
    );
        longint unsigned beats;
        longint unsigned beat_bytes;

        if (!is_supported_burst(burst)) begin
            return AXI_REQUEST_RULE_UNSUPPORTED_BURST;
        end
        if (size > $clog2(DATA_BYTES)) begin
            return AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS;
        end

        beats = longint'(len) + 64'd1;
        if (beats > max_beats) begin
            return AXI_REQUEST_RULE_LEN_EXCEEDS_MAX;
        end
        if (burst == AXI_BURST_FIXED && beats > 16) begin
            return AXI_REQUEST_RULE_FIXED_TOO_LONG;
        end
        if (burst == AXI_BURST_WRAP &&
            !(beats inside {2, 4, 8, 16})) begin
            return AXI_REQUEST_RULE_WRAP_LENGTH;
        end
        if (exclusive) begin
            if (!(beats inside {1, 2, 4, 8, 16})) begin
                return AXI_REQUEST_RULE_EXCLUSIVE_BEATS;
            end
            beat_bytes = 64'd1 << size;
            if (beats > (64'd128 / beat_bytes)) begin
                return AXI_REQUEST_RULE_EXCLUSIVE_BYTES;
            end
        end
        return AXI_REQUEST_RULE_OK;
    endfunction : get_address_independent_rule

    // Complete request geometry check using the final address.  The 4KB rule
    // remains conditional because the Driver can intentionally emit negative
    // traffic when protection is disabled; Monitors pass protect_4kb=1.
    static function axi_request_rule_e get_request_geometry_rule(
        input  addr_t          start_addr,
        input  bit [7:0]       len,
        input  bit [2:0]       size,
        input  axi_burst_e     burst,
        input  int unsigned    max_beats,
        input  bit             exclusive,
        input  bit             protect_4kb,
        output addr_t          low_addr,
        output addr_t          high_addr
    );
        axi_request_rule_e base_rule;
        longint unsigned   beat_bytes;
        longint unsigned   beats;
        longint unsigned   transfer_bytes;

        low_addr = '0;
        high_addr = '0;
        base_rule = get_address_independent_rule(
            len, size, burst, max_beats, exclusive);
        if (base_rule != AXI_REQUEST_RULE_OK) begin
            return base_rule;
        end

        beat_bytes = 64'd1 << size;
        beats = longint'(len) + 64'd1;
        if (burst == AXI_BURST_WRAP &&
            (start_addr % beat_bytes) != 0) begin
            return AXI_REQUEST_RULE_WRAP_ALIGNMENT;
        end
        if (!get_access_range(
                start_addr, len, size, burst, low_addr, high_addr)) begin
            return AXI_REQUEST_RULE_ADDRESS_OVERFLOW;
        end
        if (protect_4kb &&
            (low_addr / 4096) != (high_addr / 4096)) begin
            return AXI_REQUEST_RULE_CROSSES_4KB;
        end
        if (exclusive) begin
            transfer_bytes = beats * beat_bytes;
            if ((start_addr % transfer_bytes) != 0) begin
                return AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT;
            end
        end
        return AXI_REQUEST_RULE_OK;
    endfunction : get_request_geometry_rule

    static function addr_t get_beat_addr(
        input addr_t       start_addr,
        input bit [7:0]    len,
        input bit [2:0]    size,
        input axi_burst_e  burst,
        input int unsigned beat_idx
    );
        int unsigned beat_bytes;
        int unsigned wrap_bytes;
        addr_t aligned_addr;
        addr_t wrap_base;
        addr_t linear_addr;

        beat_bytes = 1 << size;
        if (burst == AXI_BURST_FIXED) begin
            return start_addr;
        end
        if (burst == AXI_BURST_WRAP) begin
            wrap_bytes = (int'(len) + 1) * beat_bytes;
            wrap_base = (start_addr / wrap_bytes) * wrap_bytes;
            linear_addr = start_addr + beat_idx * beat_bytes;
            return wrap_base + ((linear_addr - wrap_base) % wrap_bytes);
        end
        aligned_addr = (start_addr / beat_bytes) * beat_bytes;
        return (beat_idx == 0) ? start_addr :
            aligned_addr + beat_idx * beat_bytes;
    endfunction : get_beat_addr

    static function byte_mask_t get_byte_lane_mask(
        input addr_t       start_addr,
        input bit [7:0]    len,
        input bit [2:0]    size,
        input axi_burst_e  burst,
        input int unsigned beat_idx
    );
        byte_mask_t mask;
        addr_t beat_addr;
        addr_t aligned_start;
        addr_t range_low;
        addr_t range_high;
        int unsigned beats;
        int unsigned lower_lane;
        int unsigned upper_lane;
        int unsigned number_bytes;

        mask = '0;
        if (!is_supported_burst(burst) ||
            size > $clog2(DATA_BYTES)) begin
            return mask;
        end

        beats = int'(len) + 1;
        if (beat_idx >= beats ||
            (burst == AXI_BURST_FIXED && beats > 16) ||
            (burst == AXI_BURST_WRAP &&
             !(beats inside {2, 4, 8, 16}))) begin
            return mask;
        end

        number_bytes = 1 << size;
        if ((burst == AXI_BURST_WRAP &&
             (start_addr % number_bytes) != 0) ||
            !get_access_range(
                start_addr, len, size, burst, range_low, range_high)) begin
            return mask;
        end

        beat_addr = get_beat_addr(start_addr, len, size, burst, beat_idx);
        lower_lane = beat_addr % DATA_BYTES;

        // Arm AXI4 A3.4: an unaligned first INCR transfer reaches only the
        // end of its natural Number_Bytes-aligned block.  FIXED keeps that
        // same first-transfer lane geometry on every beat.  Later INCR beats
        // and every legal (aligned) WRAP beat use all Number_Bytes lanes.
        if (burst == AXI_BURST_FIXED ||
            (burst == AXI_BURST_INCR && beat_idx == 0)) begin
            aligned_start = (start_addr / number_bytes) * number_bytes;
            upper_lane = (aligned_start % DATA_BYTES) + number_bytes - 1;
        end
        else begin
            upper_lane = lower_lane + number_bytes - 1;
        end

        if (lower_lane > upper_lane || upper_lane >= DATA_BYTES) begin
            return mask;
        end
        for (int unsigned lane = lower_lane; lane <= upper_lane; lane++) begin
            mask[lane] = 1'b1;
        end
        return mask;
    endfunction : get_byte_lane_mask

    static function data_mask_t get_data_lane_mask(
        input addr_t       start_addr,
        input bit [7:0]    len,
        input bit [2:0]    size,
        input axi_burst_e  burst,
        input int unsigned beat_idx
    );
        byte_mask_t byte_mask;
        data_mask_t data_mask;

        byte_mask = get_byte_lane_mask(
            start_addr, len, size, burst, beat_idx);
        data_mask = '0;
        for (int unsigned i = 0; i < DATA_BYTES; i++) begin
            if (byte_mask[i]) begin
                data_mask[(8*i) +: 8] = 8'hff;
            end
        end
        return data_mask;
    endfunction : get_data_lane_mask

    static function int unsigned get_access_bytes(
        input bit [7:0]   len,
        input bit [2:0]   size,
        input axi_burst_e burst
    );
        int unsigned beat_bytes;

        beat_bytes = 1 << size;
        if (burst == AXI_BURST_FIXED) begin
            return beat_bytes;
        end
        return (int'(len) + 1) * beat_bytes;
    endfunction : get_access_bytes

    // Return the complete byte-address footprint of one burst.  Arithmetic is
    // performed with enough guard bits for the maximum AXI burst so callers
    // can reject overflow instead of accepting a truncated address.
    static function bit get_access_range(
        input  addr_t      start_addr,
        input  bit [7:0]   len,
        input  bit [2:0]   size,
        input  axi_burst_e burst,
        output addr_t      low_addr,
        output addr_t      high_addr
    );
        bit [ADDR_WIDTH+16:0] extended_start;
        bit [ADDR_WIDTH+16:0] extended_low;
        bit [ADDR_WIDTH+16:0] extended_high;
        longint unsigned   beat_bytes;
        longint unsigned   beats;
        longint unsigned   burst_bytes;

        low_addr = '0;
        high_addr = '0;
        if (!is_supported_burst(burst) ||
            size > $clog2(DATA_BYTES)) begin
            return 1'b0;
        end

        beat_bytes = 64'd1 << size;
        beats = longint'(len) + 1;
        burst_bytes = beats * beat_bytes;
        extended_start = {1'b0, start_addr};

        case (burst)
            AXI_BURST_FIXED: begin
                extended_low = extended_start;
                extended_high = (extended_start / beat_bytes) * beat_bytes +
                    beat_bytes - 1;
            end
            AXI_BURST_INCR: begin
                extended_low = extended_start;
                extended_high = (extended_start / beat_bytes) * beat_bytes +
                    burst_bytes - 1;
            end
            AXI_BURST_WRAP: begin
                if (!(beats inside {2, 4, 8, 16}) ||
                    (extended_start % beat_bytes) != 0) begin
                    return 1'b0;
                end
                extended_low = (extended_start / burst_bytes) * burst_bytes;
                extended_high = extended_low + burst_bytes - 1;
            end
            default: return 1'b0;
        endcase

        if (extended_low[ADDR_WIDTH+16:ADDR_WIDTH] != '0 ||
            extended_high[ADDR_WIDTH+16:ADDR_WIDTH] != '0 ||
            extended_high < extended_low) begin
            return 1'b0;
        end
        low_addr = extended_low[ADDR_WIDTH-1:0];
        high_addr = extended_high[ADDR_WIDTH-1:0];
        return 1'b1;
    endfunction : get_access_range

    static function bit crosses_4kb(
        input addr_t      start_addr,
        input bit [7:0]   len,
        input bit [2:0]   size,
        input axi_burst_e burst
    );
        addr_t low_addr;
        addr_t high_addr;

        if (!get_access_range(
                start_addr, len, size, burst, low_addr, high_addr)) begin
            return 1'b1;
        end
        return (low_addr / 4096) != (high_addr / 4096);
    endfunction : crosses_4kb

    static function axi_request_rule_e get_exclusive_request_rule(
        input addr_t    start_addr,
        input bit [7:0] len,
        input bit [2:0] size
    );
        longint unsigned beats;
        longint unsigned beat_bytes;
        longint unsigned transfer_bytes;

        if (size > $clog2(DATA_BYTES)) begin
            return AXI_REQUEST_RULE_SIZE_EXCEEDS_BUS;
        end

        beats = longint'(len) + 64'd1;
        if (!(beats inside {1, 2, 4, 8, 16})) begin
            return AXI_REQUEST_RULE_EXCLUSIVE_BEATS;
        end

        beat_bytes = 64'd1 << size;
        if (beats > (64'd128 / beat_bytes)) begin
            return AXI_REQUEST_RULE_EXCLUSIVE_BYTES;
        end

        transfer_bytes = beats * beat_bytes;
        if ((start_addr % transfer_bytes) != 0) begin
            return AXI_REQUEST_RULE_EXCLUSIVE_ALIGNMENT;
        end
        return AXI_REQUEST_RULE_OK;
    endfunction : get_exclusive_request_rule

    static function bit exclusive_request_is_legal(
        input addr_t    start_addr,
        input bit [7:0] len,
        input bit [2:0] size
    );
        return get_exclusive_request_rule(start_addr, len, size) ==
            AXI_REQUEST_RULE_OK;
    endfunction : exclusive_request_is_legal
endclass : axi_burst_math

`endif
