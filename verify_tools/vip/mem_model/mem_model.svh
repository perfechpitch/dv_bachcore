`ifndef MEM_MODEL_SVH
`define MEM_MODEL_SVH

class mem_model extends uvm_object;
    `uvm_object_utils(mem_model)

    protected mem_byte_t         memory[mem_addr_t];
    protected mem_segment_s      segments[$];
    protected mem_history_s      history[$];
    protected mem_exclusive_reservation reservations[mem_id_t];

    mem_byte_t  default_read_value = 8'h00;
    int unsigned read_count;
    int unsigned write_count;
    int unsigned exception_count;
    int unsigned compare_count;
    int unsigned compare_fail_count;
    int unsigned uninitialized_read_count;
    int unsigned exclusive_read_count;
    int unsigned exclusive_write_success_count;
    int unsigned exclusive_write_fail_count;
    int unsigned reservation_invalidation_count;

    function new(string name = "mem_model");
        super.new(name);
        memory.delete();
        segments.delete();
        history.delete();
        reservations.delete();
        read_count = 0;
        write_count = 0;
        exception_count = 0;
        compare_count = 0;
        compare_fail_count = 0;
        uninitialized_read_count = 0;
        exclusive_read_count = 0;
        exclusive_write_success_count = 0;
        exclusive_write_fail_count = 0;
        reservation_invalidation_count = 0;
    endfunction : new

    // Segments are inclusive. Overlap is rejected so one address has one policy.
    function bit create_seg(
        input mem_addr_t                start_addr,
        input mem_addr_t                end_addr,
        input mem_seg_attr_e            seg_attr,
        input bit                       exclusive_support,
        input mem_supported_size_mask_t supported_size_mask
    );
        mem_segment_s segment;

        if (start_addr > end_addr) begin
            `uvm_error("MEM_SEG_RANGE", $sformatf(
                "Invalid segment [0x%0h:0x%0h]", start_addr, end_addr))
            return 1'b0;
        end

        foreach (segments[i]) begin
            if (start_addr <= segments[i].end_addr &&
                end_addr >= segments[i].start_addr) begin
                `uvm_error("MEM_SEG_OVERLAP", $sformatf(
                    "Segment [0x%0h:0x%0h] overlaps [0x%0h:0x%0h]",
                    start_addr, end_addr,
                    segments[i].start_addr, segments[i].end_addr))
                return 1'b0;
            end
        end

        segment.start_addr = start_addr;
        segment.end_addr = end_addr;
        segment.attr = seg_attr;
        segment.exclusive_support = exclusive_support;
        segment.supported_size_mask = supported_size_mask;
        segments.push_back(segment);
        return 1'b1;
    endfunction : create_seg

    function void delete_segments();
        segments.delete();
    endfunction : delete_segments

    function int unsigned segment_count();
        return segments.size();
    endfunction : segment_count

    function bit get_segment(
        input  int unsigned  index,
        output mem_segment_s segment
    );
        segment = '{default: '0};
        if (index >= segments.size()) begin
            return 1'b0;
        end
        segment = segments[index];
        return 1'b1;
    endfunction : get_segment

    function bit find_segment_by_addr(
        input  mem_addr_t    addr,
        output mem_segment_s segment
    );
        segment = '{default: '0};
        foreach (segments[i]) begin
            if (addr >= segments[i].start_addr &&
                addr <= segments[i].end_addr) begin
                segment = segments[i];
                return 1'b1;
            end
        end
        return 1'b0;
    endfunction : find_segment_by_addr

    function mem_seg_attr_e get_seg_attr(input mem_addr_t addr);
        foreach (segments[i]) begin
            if (addr >= segments[i].start_addr &&
                addr <= segments[i].end_addr) begin
                return segments[i].attr;
            end
        end
        return MEM_OK;
    endfunction : get_seg_attr

    // Exclusive support is explicit segment policy. Unmapped addresses do
    // not support Exclusive, even though their normal response defaults to
    // MEM_OK. The complete addressed range must stay inside one segment.
    function bit exclusive_access_supported(
        input mem_addr_t addr,
        input bit [7:0]  len,
        input bit [2:0]  size,
        input bit [1:0]  burst
    );
        int unsigned beat_bytes;
        int unsigned total_bytes;
        mem_addr_t low_address;
        mem_addr_t high_address;

        beat_bytes = 1 << size;
        total_bytes = (int'(len) + 1) * beat_bytes;
        case (burst)
            2'b00: begin
                low_address = addr;
                high_address = addr + beat_bytes - 1;
            end
            2'b10: begin
                low_address = (addr / total_bytes) * total_bytes;
                high_address = low_address + total_bytes - 1;
            end
            default: begin
                low_address = addr;
                high_address = addr + total_bytes - 1;
            end
        endcase

        if (high_address < low_address) begin
            return 1'b0;
        end
        foreach (segments[i]) begin
            if (low_address >= segments[i].start_addr &&
                high_address <= segments[i].end_addr) begin
                return segments[i].exclusive_support;
            end
        end
        return 1'b0;
    endfunction : exclusive_access_supported

    // Select an aligned address range from an explicit segment whose policy
    // produces the requested response for the specified operation. The whole
    // range stays in one segment so every byte has the same response policy.
    function bit select_random_addr_by_response(
        input  mem_op_e     op,
        input  mem_resp_e   desired_response,
        input  int unsigned byte_size,
        input  mem_addr_t   min_addr,
        input  mem_addr_t   max_addr,
        input  int unsigned alignment,
        output mem_addr_t   addr
    );
        int unsigned eligible_segments[$];
        int unsigned selected_entry;
        int unsigned segment_index;
        mem_addr_t   range_start;
        mem_addr_t   range_end;
        mem_addr_t   first_addr;
        mem_addr_t   last_addr;
        mem_addr_t   align_remainder;
        mem_addr_t   slot_count;
        mem_addr_t   selected_slot;
        mem_addr_t   random_value;
        mem_addr_t   max_address;
        mem_resp_e   segment_response;

        addr = '0;
        max_address = '1;
        if (!(op inside {MEM_OP_READ, MEM_OP_WRITE}) ||
            !(desired_response inside {
                MEM_RESP_OKAY, MEM_RESP_SLVERR, MEM_RESP_DECERR}) ||
            byte_size == 0 || alignment == 0 || min_addr > max_addr) begin
            return 1'b0;
        end

        foreach (segments[i]) begin
            segment_response = (op == MEM_OP_READ) ?
                predict_read_exception(1, segments[i].start_addr) :
                predict_write_exception(1, segments[i].start_addr);
            if (segment_response != desired_response) begin
                continue;
            end

            range_start = (segments[i].start_addr > min_addr) ?
                segments[i].start_addr : min_addr;
            range_end = (segments[i].end_addr < max_addr) ?
                segments[i].end_addr : max_addr;
            if (range_start > range_end ||
                (range_end - range_start) < (byte_size - 1)) begin
                continue;
            end

            align_remainder = range_start % alignment;
            first_addr = range_start;
            if (align_remainder != 0) begin
                if (range_start >
                    (max_address - (alignment - align_remainder))) begin
                    continue;
                end
                first_addr = range_start + (alignment - align_remainder);
            end
            last_addr = range_end - byte_size + 1;
            if (first_addr <= last_addr) begin
                eligible_segments.push_back(i);
            end
        end

        if (eligible_segments.size() == 0) begin
            return 1'b0;
        end

        selected_entry = $urandom_range(eligible_segments.size() - 1, 0);
        segment_index = eligible_segments[selected_entry];
        range_start = (segments[segment_index].start_addr > min_addr) ?
            segments[segment_index].start_addr : min_addr;
        range_end = (segments[segment_index].end_addr < max_addr) ?
            segments[segment_index].end_addr : max_addr;
        align_remainder = range_start % alignment;
        first_addr = range_start;
        if (align_remainder != 0) begin
            first_addr = range_start + (alignment - align_remainder);
        end
        last_addr = range_end - byte_size + 1;
        slot_count = ((last_addr - first_addr) / alignment) + 1;
        random_value = {$urandom(), $urandom()};
        selected_slot = random_value % slot_count;
        addr = first_addr + selected_slot * alignment;

        return ((op == MEM_OP_READ) ?
            predict_read_exception(byte_size, addr) :
            predict_write_exception(byte_size, addr)) == desired_response;
    endfunction : select_random_addr_by_response

    // Reset clears sparse data but deliberately keeps the configured segment map.
    function void reset_mem();
        bit had_state;
        mem_byte_array_t history_data;

        had_state = memory.num() != 0 || reservations.num() != 0 ||
            read_count != 0 || write_count != 0 || exception_count != 0 ||
            compare_count != 0 || compare_fail_count != 0 ||
            uninitialized_read_count != 0 || exclusive_read_count != 0 ||
            exclusive_write_success_count != 0 ||
            exclusive_write_fail_count != 0 ||
            reservation_invalidation_count != 0;
        memory.delete();
        reservations.delete();
        read_count = 0;
        write_count = 0;
        exception_count = 0;
        compare_count = 0;
        compare_fail_count = 0;
        uninitialized_read_count = 0;
        exclusive_read_count = 0;
        exclusive_write_success_count = 0;
        exclusive_write_fail_count = 0;
        reservation_invalidation_count = 0;
        if (had_state) begin
            history_data = new[0];
            record_history(MEM_OP_RESET, '0, 0, history_data,
                           MEM_RESP_OKAY, MEM_OK,
                           "storage and reservations cleared; segment map preserved");
        end
    endfunction : reset_mem

    function void clear_history();
        history.delete();
    endfunction : clear_history

    function mem_resp_e predict_read_exception(
        input int unsigned byte_size,
        input mem_addr_t   addr
    );
        mem_resp_e response;
        mem_seg_attr_e attr;

        if (!valid_access(byte_size, addr)) begin
            return MEM_RESP_DECERR;
        end

        response = MEM_RESP_OKAY;
        for (int unsigned i = 0; i < byte_size; i++) begin
            attr = get_seg_attr(addr + i);
            case (attr)
                MEM_SLV_ERR, MEM_R_SLV_ERR:
                    response = merge_response(response, MEM_RESP_SLVERR);
                MEM_DEC_ERR, MEM_R_DEC_ERR:
                    response = merge_response(response, MEM_RESP_DECERR);
                default:
                    response = merge_response(response, MEM_RESP_OKAY);
            endcase
        end
        return response;
    endfunction : predict_read_exception

    function mem_resp_e predict_write_exception(
        input int unsigned byte_size,
        input mem_addr_t   addr
    );
        mem_resp_e response;
        mem_seg_attr_e attr;

        if (!valid_access(byte_size, addr)) begin
            return MEM_RESP_DECERR;
        end

        response = MEM_RESP_OKAY;
        for (int unsigned i = 0; i < byte_size; i++) begin
            attr = get_seg_attr(addr + i);
            case (attr)
                MEM_SLV_ERR, MEM_W_SLV_ERR:
                    response = merge_response(response, MEM_RESP_SLVERR);
                MEM_DEC_ERR, MEM_W_DEC_ERR:
                    response = merge_response(response, MEM_RESP_DECERR);
                default:
                    response = merge_response(response, MEM_RESP_OKAY);
            endcase
        end
        return response;
    endfunction : predict_write_exception

    function mem_resp_e write_byte(
        input mem_addr_t addr,
        input int unsigned data
    );
        mem_resp_e response;
        mem_byte_array_t history_data;

        response = predict_write_exception(1, addr);
        history_data = new[1];
        history_data[0] = data[7:0];
        write_count++;

        if (response inside {MEM_RESP_OKAY, MEM_RESP_EXOKAY}) begin
            invalidate_reservations(addr, addr);
            memory[addr] = data[7:0];
        end
        else begin
            exception_count++;
        end

        record_history(MEM_OP_WRITE, addr, 1, history_data,
                       response, get_seg_attr(addr), "write_byte");
        return response;
    endfunction : write_byte

    function mem_byte_t read_byte(input mem_addr_t addr);
        mem_resp_e response;
        mem_byte_t data;
        bit initialized;
        mem_byte_array_t history_data;

        response = predict_read_exception(1, addr);
        read_count++;
        data = '0;

        if (response inside {MEM_RESP_OKAY, MEM_RESP_EXOKAY}) begin
            initialized = memory.exists(addr);
            data = initialized ? memory[addr] : default_read_value;
            if (!initialized) begin
                uninitialized_read_count++;
            end
        end
        else begin
            exception_count++;
        end

        history_data = new[1];
        history_data[0] = data;
        record_history(MEM_OP_READ, addr, 1, history_data,
                       response, get_seg_attr(addr), "read_byte");
        return data;
    endfunction : read_byte

    // Pure storage lookup used when a protocol adapter needs to display a
    // byte without performing a logical memory access.  Missing bytes use
    // the same default as a normal uninitialized read, but this helper does
    // not consult segment policy and does not update counters, history,
    // exceptions, reservations, or initialization state.
    function mem_byte_t get_storage_byte(input mem_addr_t addr);
        return memory.exists(addr) ? memory[addr] : default_read_value;
    endfunction : get_storage_byte

    // byte_size is a positive byte count with no model-defined upper bound.
    function mem_resp_e write_data(
        input int unsigned byte_size,
        input mem_addr_t   addr,
        input mem_byte_array_t data
    );
        mem_resp_e response;

        if (data.size() < byte_size) begin
            `uvm_error("MEM_WRITE_DATA_SIZE", $sformatf(
                "write_data byte_size=%0d exceeds supplied data bytes=%0d",
                byte_size, data.size()))
            exception_count++;
            write_count++;
            record_history(MEM_OP_WRITE, addr, byte_size, data,
                           MEM_RESP_DECERR, get_seg_attr(addr),
                           "insufficient write data");
            return MEM_RESP_DECERR;
        end

        response = predict_write_exception(byte_size, addr);
        write_count++;

        if (response inside {MEM_RESP_OKAY, MEM_RESP_EXOKAY}) begin
            invalidate_reservations(addr, addr + byte_size - 1);
            for (int unsigned i = 0; i < byte_size; i++) begin
                memory[addr + i] = data[i];
            end
        end
        else begin
            exception_count++;
        end

        record_history(MEM_OP_WRITE, addr, byte_size, data,
                       response, get_seg_attr(addr), "write_data");
        return response;
    endfunction : write_data

    function mem_byte_array_t read_data(
        input int unsigned byte_size,
        input mem_addr_t   addr
    );
        mem_resp_e response;
        mem_byte_array_t data;
        mem_byte_t byte_data;
        bit initialized;

        response = predict_read_exception(byte_size, addr);
        read_count++;
        data = new[byte_size];

        if (response inside {MEM_RESP_OKAY, MEM_RESP_EXOKAY}) begin
            for (int unsigned i = 0; i < byte_size; i++) begin
                initialized = memory.exists(addr + i);
                byte_data = initialized ? memory[addr + i] :
                    default_read_value;
                data[i] = byte_data;
                if (!initialized) begin
                    uninitialized_read_count++;
                end
            end
        end
        else begin
            exception_count++;
        end

        record_history(MEM_OP_READ, addr, byte_size, data,
                       response, get_seg_attr(addr), "read_data");
        return data;
    endfunction : read_data

    // Reads the explicit trailing [msb:lsb] part-select in hdl_path. Pure UVM
    // string-based HDL access does not report the selected object's width, so
    // the range is parsed from the path. Only data[bit_size-1:0] is valid.
    // Backdoor accesses do not affect logical model state or counters.
    function mem_backdoor_read_result_s backdoor_read(input string hdl_path);
        uvm_hdl_data_t raw_data;
        mem_backdoor_read_result_s result;
        longint unsigned parsed_bit_size;

        result.success = 1'b0;
        result.bit_size = 0;
        result.data = '0;
        if (hdl_path.len() == 0) begin
            `uvm_error("MEM_BACKDOOR_READ_PATH",
                "Backdoor read requires a non-empty HDL path")
            return result;
        end
        if (!parse_trailing_hdl_slice_width(hdl_path, parsed_bit_size)) begin
            `uvm_error("MEM_BACKDOOR_READ_RANGE", $sformatf(
                {"Backdoor read path must end with an explicit constant ",
                 "[msb:lsb] range: path=%s"}, hdl_path))
            return result;
        end
        if (parsed_bit_size > MEM_BACKDOOR_MAX_BITS) begin
            `uvm_error("MEM_BACKDOOR_READ_WIDTH", $sformatf(
                "Backdoor read path=%s width=%0d exceeds mem backdoor maximum=%0d bits",
                hdl_path, parsed_bit_size, MEM_BACKDOOR_MAX_BITS))
            return result;
        end
        result.bit_size = int'(parsed_bit_size);
        if (result.bit_size > $bits(raw_data)) begin
            `uvm_error("MEM_BACKDOOR_UVM_WIDTH", $sformatf(
                "Requested path=%s width=%0d exceeds compiled uvm_hdl_data_t width=%0d; compile UVM_HDL_MAX_WIDTH >= %0d",
                hdl_path, result.bit_size, $bits(raw_data),
                MEM_BACKDOOR_MAX_BITS))
            return result;
        end

        raw_data = '0;
        if (!uvm_hdl_read(hdl_path, raw_data)) begin
            `uvm_error("MEM_BACKDOOR_READ", $sformatf(
                "Could not read HDL path=%s", hdl_path))
            return result;
        end

        for (int unsigned i = 0; i < result.bit_size; i++) begin
            result.data[i] = raw_data[i];
        end
        result.success = 1'b1;
        return result;
    endfunction : backdoor_read

    // Writes one complete HDL block from the model bytes at addr. Missing
    // model bytes use default_read_value, matching normal uninitialized reads.
    // The trailing [msb:lsb] range must match byte_size because the pure UVM
    // string-based HDL API cannot query the selected object's width.
    function bit backdoor_write(
        input int unsigned byte_size,
        input mem_addr_t   addr,
        input string       hdl_path
    );
        uvm_hdl_data_t raw_data;
        int unsigned bit_size;
        longint unsigned parsed_bit_size;

        if (!valid_access(byte_size, addr)) begin
            `uvm_error("MEM_BACKDOOR_WRITE_RANGE", $sformatf(
                "Invalid backdoor write range addr=0x%0h byte_size=%0d path=%s",
                addr, byte_size, hdl_path))
            return 1'b0;
        end
        if (hdl_path.len() == 0) begin
            `uvm_error("MEM_BACKDOOR_WRITE_PATH",
                "Backdoor write requires a non-empty HDL path")
            return 1'b0;
        end
        if (byte_size > (MEM_BACKDOOR_MAX_BITS / 8)) begin
            `uvm_error("MEM_BACKDOOR_WRITE_WIDTH", $sformatf(
                "Backdoor write byte_size=%0d exceeds mem backdoor maximum=%0d bytes for path=%s",
                byte_size, MEM_BACKDOOR_MAX_BITS / 8, hdl_path))
            return 1'b0;
        end

        bit_size = byte_size * 8;
        if (!parse_trailing_hdl_slice_width(hdl_path, parsed_bit_size)) begin
            `uvm_error("MEM_BACKDOOR_WRITE_RANGE", $sformatf(
                {"Backdoor write path must end with an explicit constant ",
                 "[msb:lsb] range: path=%s"}, hdl_path))
            return 1'b0;
        end
        if (parsed_bit_size != bit_size) begin
            `uvm_error("MEM_BACKDOOR_WRITE_SIZE", $sformatf(
                "Backdoor write path=%s width=%0d does not match byte_size=%0d (%0d bits)",
                hdl_path, parsed_bit_size, byte_size, bit_size))
            return 1'b0;
        end
        if (bit_size > $bits(raw_data)) begin
            `uvm_error("MEM_BACKDOOR_UVM_WIDTH", $sformatf(
                "Requested path=%s width=%0d exceeds compiled uvm_hdl_data_t width=%0d; compile UVM_HDL_MAX_WIDTH >= %0d",
                hdl_path, bit_size, $bits(raw_data),
                MEM_BACKDOOR_MAX_BITS))
            return 1'b0;
        end

        raw_data = '0;
        for (int unsigned i = 0; i < byte_size; i++) begin
            raw_data[(8 * i) +: 8] = memory.exists(addr + i) ?
                memory[addr + i] : default_read_value;
        end
        if (!uvm_hdl_deposit(hdl_path, raw_data)) begin
            `uvm_error("MEM_BACKDOOR_WRITE", $sformatf(
                "Could not write HDL path=%s from logical range [0x%0h:0x%0h]",
                hdl_path, addr, addr + byte_size - 1))
            return 1'b0;
        end
        return 1'b1;
    endfunction : backdoor_write

    function bit is_initialized(input mem_addr_t addr);
        return memory.exists(addr);
    endfunction : is_initialized

    function int unsigned initialized_byte_count();
        return memory.num();
    endfunction : initialized_byte_count

    function bit reserve_exclusive(
        input mem_id_t   id,
        input mem_addr_t addr,
        input bit [7:0]  len,
        input bit [2:0]  size,
        input bit [1:0]  burst,
        input bit [3:0]  cache,
        input bit [2:0]  prot,
        input bit [3:0]  region
    );
        mem_exclusive_reservation reservation;
        int unsigned beat_bytes;
        int unsigned total_bytes;

        if (!exclusive_access_supported(addr, len, size, burst)) begin
            return 1'b0;
        end

        reservation = new();
        beat_bytes = 1 << size;
        total_bytes = (int'(len) + 1) * beat_bytes;
        reservation.address = addr;
        reservation.len = len;
        reservation.size = size;
        reservation.burst = burst;
        reservation.cache = cache;
        reservation.prot = prot;
        reservation.region = region;

        case (burst)
            2'b00: begin
                reservation.low_address = addr;
                reservation.high_address = addr + beat_bytes - 1;
            end
            2'b10: begin
                reservation.low_address = (addr / total_bytes) * total_bytes;
                reservation.high_address = reservation.low_address + total_bytes - 1;
            end
            default: begin
                reservation.low_address = addr;
                reservation.high_address = addr + total_bytes - 1;
            end
        endcase

        reservations[id] = reservation;
        exclusive_read_count++;
        return 1'b1;
    endfunction : reserve_exclusive

    function bit exclusive_write_matches(
        input mem_id_t   id,
        input mem_addr_t addr,
        input bit [7:0]  len,
        input bit [2:0]  size,
        input bit [1:0]  burst,
        input bit [3:0]  cache,
        input bit [2:0]  prot,
        input bit [3:0]  region
    );
        if (!exclusive_access_supported(addr, len, size, burst)) begin
            return 1'b0;
        end
        if (!reservations.exists(id)) begin
            return 1'b0;
        end

        return reservations[id].address == addr &&
               reservations[id].len == len &&
               reservations[id].size == size &&
               reservations[id].burst == burst &&
               reservations[id].cache == cache &&
               reservations[id].prot == prot &&
               reservations[id].region == region;
    endfunction : exclusive_write_matches

    function void complete_exclusive_write(
        input mem_id_t id,
        input bit      success
    );
        if (reservations.exists(id)) begin
            reservations.delete(id);
        end
        if (success) begin
            exclusive_write_success_count++;
        end
        else begin
            exclusive_write_fail_count++;
        end
    endfunction : complete_exclusive_write

    function void invalidate_reservations(
        input mem_addr_t low_address,
        input mem_addr_t high_address
    );
        mem_id_t invalid_ids[$];

        foreach (reservations[id]) begin
            if (low_address <= reservations[id].high_address &&
                high_address >= reservations[id].low_address) begin
                invalid_ids.push_back(id);
            end
        end
        foreach (invalid_ids[i]) begin
            reservations.delete(invalid_ids[i]);
            reservation_invalidation_count++;
        end
    endfunction : invalidate_reservations

    function int unsigned reservation_count();
        return reservations.num();
    endfunction : reservation_count

    function void record_access_exception(
        input mem_op_e     op,
        input mem_addr_t   addr,
        input int unsigned byte_size,
        input mem_resp_e   response,
        input string       note = ""
    );
        mem_byte_array_t history_data;

        if (!(op inside {MEM_OP_READ, MEM_OP_WRITE}) ||
            !(response inside {MEM_RESP_SLVERR, MEM_RESP_DECERR})) begin
            `uvm_error("MEM_EXCEPTION_RECORD",
                "record_access_exception requires READ/WRITE and SLVERR/DECERR")
            return;
        end

        exception_count++;
        history_data = new[0];
        record_history(op, addr, byte_size, history_data, response,
                       get_seg_attr(addr), note);
    endfunction : record_access_exception

    // Compares one explicit packed DUT slice against consecutive model bytes.
    // The HDL slice width determines the compare size, so byte_size is not a
    // separate argument. Path bits [8*i +: 8] map to model address addr + i,
    // matching backdoor_write(). Bank/row selection remains part of hdl_path.
    function bit compare_mem(
        input mem_addr_t addr,
        input string     hdl_path
    );
        mem_backdoor_read_result_s actual;
        mem_byte_array_t expected_data;
        mem_byte_array_t history_data;
        int unsigned byte_size;
        bit match;
        string expected_text;
        string actual_text;

        compare_count++;
        actual = backdoor_read(hdl_path);
        if (!actual.success) begin
            compare_fail_count++;
            `uvm_error("MEM_COMPARE_BACKDOOR_READ", $sformatf(
                "Could not compare address 0x%0h because HDL path=%s could not be read",
                addr, hdl_path))
            return 1'b0;
        end
        if ((actual.bit_size % 8) != 0) begin
            compare_fail_count++;
            `uvm_error("MEM_COMPARE_WIDTH", $sformatf(
                "HDL path=%s width=%0d is not a whole number of bytes",
                hdl_path, actual.bit_size))
            return 1'b0;
        end

        byte_size = actual.bit_size / 8;
        if (!valid_access(byte_size, addr)) begin
            compare_fail_count++;
            `uvm_error("MEM_COMPARE_RANGE", $sformatf(
                "Invalid model compare range addr=0x%0h byte_size=%0d path=%s",
                addr, byte_size, hdl_path))
            return 1'b0;
        end

        expected_data = new[byte_size];
        history_data = new[byte_size];
        match = 1'b1;
        for (int unsigned i = 0; i < byte_size; i++) begin
            expected_data[i] = memory.exists(addr + i) ?
                memory[addr + i] : default_read_value;
            history_data[i] = mem_byte_t'(actual.data[(8 * i) +: 8]);
            if (actual.data[(8 * i) +: 8] !== expected_data[i]) begin
                match = 1'b0;
            end
        end

        expected_text = "0x";
        actual_text = "0x";
        for (int i = byte_size - 1; i >= 0; i--) begin
            expected_text = {expected_text,
                $sformatf("%02h", expected_data[i])};
            actual_text = {actual_text,
                $sformatf("%02h", actual.data[(8 * i) +: 8])};
        end

        record_history(MEM_OP_COMPARE, addr, byte_size, history_data,
                       MEM_RESP_OKAY, get_seg_attr(addr),
                       $sformatf("path=%s expected=%s actual=%s",
                                 hdl_path, expected_text, actual_text));

        if (!match) begin
            compare_fail_count++;
            `uvm_error("MEM_COMPARE_MISMATCH", $sformatf(
                "Address 0x%0h byte_size=%0d path=%s expected=%s actual=%s",
                addr, byte_size, hdl_path, expected_text, actual_text))
        end
        else begin
            `uvm_info("MEM_COMPARE_PASS", $sformatf(
                "Address 0x%0h byte_size=%0d matched path=%s data=%s",
                addr, byte_size, hdl_path, actual_text), UVM_HIGH)
        end
        return match;
    endfunction : compare_mem

    function void record_history(
        input mem_op_e       op,
        input mem_addr_t     addr,
        input int unsigned   byte_size,
        input mem_byte_array_t data,
        input mem_resp_e     response,
        input mem_seg_attr_e seg_attr,
        input string         note = ""
    );
        mem_history_s item;

        item.op_time = $time;
        item.op = op;
        item.addr = addr;
        item.byte_size = byte_size;
        item.data = data;
        item.response = response;
        item.seg_attr = seg_attr;
        item.note = note;
        history.push_back(item);
    endfunction : record_history

    function int unsigned history_size();
        return history.size();
    endfunction : history_size

    function string format_history();
        string report;

        report = "\n";
        report = {report, "===============================================================================================================\n"};
        report = {report, "MEMORY ACCESS HISTORY\n"};
        report = {report, "===============================================================================================================\n"};
        report = {report, $sformatf("%-10s | %-8s | %-18s | %-5s | %-18s | %-16s | %-16s | %s\n",
                                   "TIME", "OP", "ADDR", "BYTES", "DATA", "RESPONSE", "SEG_ATTR", "NOTE")};
        report = {report, "---------------------------------------------------------------------------------------------------------------\n"};
        foreach (history[i]) begin
            report = {report, $sformatf("%-10t | %-8s | 0x%016h | %-5d | %-18s | %-16s | %-16s | %s\n",
                                       history[i].op_time,
                                       history[i].op.name(),
                                       history[i].addr,
                                       history[i].byte_size,
                                       format_byte_array(history[i].data),
                                       history[i].response.name(),
                                       history[i].seg_attr.name(),
                                       history[i].note)};
        end
        report = {report, "===============================================================================================================\n"};
        report = {report, $sformatf(
            "reads=%0d writes=%0d exceptions=%0d compares=%0d compare_failures=%0d uninitialized_bytes_read=%0d initialized_bytes=%0d exclusive_reads=%0d exclusive_write_pass=%0d exclusive_write_fail=%0d invalidations=%0d reservations=%0d",
            read_count, write_count, exception_count, compare_count,
            compare_fail_count, uninitialized_read_count, initialized_byte_count(),
            exclusive_read_count, exclusive_write_success_count,
            exclusive_write_fail_count, reservation_invalidation_count,
            reservation_count())};
        return report;
    endfunction : format_history

    function void report_mem();
        `uvm_info("MEM_HISTORY", format_history(), UVM_LOW)
    endfunction : report_mem

    function string format_segments();
        string report;

        report = "\nMEMORY SEGMENTS\n";
        if (segments.size() == 0) begin
            return {report,
                "<none; all addresses use MEM_OK, support every size, and do not support Exclusive>"};
        end
        foreach (segments[i]) begin
            report = {report, $sformatf("[0x%016h:0x%016h] %s exclusive_support=%0b supported_size_mask=0x%02h\n",
                                       segments[i].start_addr,
                                       segments[i].end_addr,
                                       segments[i].attr.name(),
                                       segments[i].exclusive_support,
                                       segments[i].supported_size_mask)};
        end
        return report;
    endfunction : format_segments

    function void report_segments();
        `uvm_info("MEM_SEGMENTS", format_segments(), UVM_LOW)
    endfunction : report_segments

    protected function bit parse_decimal_index(
        input  string           text,
        output longint unsigned value
    );
        byte             character;
        longint unsigned digit;
        longint unsigned max_value;

        value = 0;
        max_value = '1;
        if (text.len() == 0) begin
            return 1'b0;
        end
        for (int unsigned i = 0; i < text.len(); i++) begin
            character = text.getc(i);
            if (character < 8'd48 || character > 8'd57) begin
                return 1'b0;
            end
            digit = character - 8'd48;
            if (value > ((max_value - digit) / 10)) begin
                return 1'b0;
            end
            value = (value * 10) + digit;
        end
        return 1'b1;
    endfunction : parse_decimal_index

    protected function bit parse_trailing_hdl_slice_width(
        input  string           hdl_path,
        output longint unsigned bit_size
    );
        int              open_bracket;
        int              close_bracket;
        int              colon;
        longint unsigned msb;
        longint unsigned lsb;
        longint unsigned width_minus_one;
        string           msb_text;
        string           lsb_text;

        bit_size = 0;
        if (hdl_path.len() < 5) begin
            return 1'b0;
        end

        close_bracket = hdl_path.len() - 1;
        if (hdl_path.getc(close_bracket) != 8'h5d) begin
            return 1'b0;
        end

        open_bracket = -1;
        for (int i = close_bracket - 1; i >= 0; i--) begin
            if (hdl_path.getc(i) == 8'h5b) begin
                open_bracket = i;
                break;
            end
        end
        if (open_bracket < 0 || open_bracket + 1 >= close_bracket) begin
            return 1'b0;
        end

        colon = -1;
        for (int i = open_bracket + 1; i < close_bracket; i++) begin
            if (hdl_path.getc(i) == 8'h3a) begin
                if (colon >= 0) begin
                    return 1'b0;
                end
                colon = i;
            end
        end
        if (colon <= open_bracket + 1 || colon >= close_bracket - 1) begin
            return 1'b0;
        end

        msb_text = hdl_path.substr(open_bracket + 1, colon - 1);
        lsb_text = hdl_path.substr(colon + 1, close_bracket - 1);
        if (!parse_decimal_index(msb_text, msb) ||
            !parse_decimal_index(lsb_text, lsb)) begin
            return 1'b0;
        end

        width_minus_one = (msb >= lsb) ? (msb - lsb) : (lsb - msb);
        if (width_minus_one == 64'hffff_ffff_ffff_ffff) begin
            return 1'b0;
        end
        bit_size = width_minus_one + 1;
        return 1'b1;
    endfunction : parse_trailing_hdl_slice_width

    protected function bit valid_access(
        input int unsigned byte_size,
        input mem_addr_t   addr
    );
        mem_addr_t last_addr;

        if (byte_size == 0) begin
            return 1'b0;
        end
        last_addr = addr + byte_size - 1;
        return last_addr >= addr;
    endfunction : valid_access

    protected function string format_byte_array(
        input mem_byte_array_t data
    );
        string value;

        if (data.size() == 0) begin
            return "-";
        end
        value = "0x";
        for (int i = data.size() - 1; i >= 0; i--) begin
            value = {value, $sformatf("%02h", data[i])};
        end
        return value;
    endfunction : format_byte_array

    protected function mem_resp_e merge_response(
        input mem_resp_e lhs,
        input mem_resp_e rhs
    );
        if (lhs == MEM_RESP_DECERR || rhs == MEM_RESP_DECERR) begin
            return MEM_RESP_DECERR;
        end
        if (lhs == MEM_RESP_SLVERR || rhs == MEM_RESP_SLVERR) begin
            return MEM_RESP_SLVERR;
        end
        return MEM_RESP_OKAY;
    endfunction : merge_response
endclass : mem_model

`endif
