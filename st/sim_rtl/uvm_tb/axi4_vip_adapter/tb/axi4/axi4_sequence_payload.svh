// Included inside axi4_sequence_base. Payload/strobes are transfer-relative;
// the lower-level burst request arrays contain bus-lane-aligned values.
    // Raw request wrappers support continuous sliding-window traffic. Preserve
    // the driver's status/response contract for callers that handle errors.
    task axi_submit_write(input axi4_burst_request req, output axi4_completion handle);
      p_sequencer.adapter.submit_write(req, handle);
    endtask

    task axi_submit_read(input axi4_burst_request req, output axi4_completion handle);
      p_sequencer.adapter.submit_read(req, handle);
    endtask

    task axi_wait_completion(input axi4_completion handle, output axi4_burst_response rsp);
      p_sequencer.adapter.wait_completion(handle, rsp);
    endtask

    function void axi_require_completion_ok(input axi4_completion handle);
      if (handle == null) begin
        `uvm_fatal("AXI_SEQ_ABORT", "Null sequence completion handle")
        return;
      end
      if (!handle.done || handle.status != AXI_COMPLETION_OK)
        `uvm_fatal("AXI_SEQ_ABORT", $sformatf("Sequence completion failed status=%0d detail=%s",
                                            handle.status, handle.detail))
    endfunction

    function automatic string axi_checked_hex_token(
      input string text,
      input int unsigned width,
      input string field_name
    );
      string token;
      bit significant;
      int unsigned digit, significant_bits;
      byte c;
      token = axi_normalize_hex_token(axi_trim(text));
      if (token.len() == 0)
        `uvm_fatal(get_type_name(), $sformatf("Empty hex value for %s", field_name))
      significant = 0;
      for (int idx = 0; idx < token.len(); idx++) begin
        c = token.getc(idx);
        if (c >= "0" && c <= "9") digit = c - "0";
        else if (c >= "a" && c <= "f") digit = c - "a" + 10;
        else if (c >= "A" && c <= "F") digit = c - "A" + 10;
        else
          `uvm_fatal(get_type_name(), $sformatf("Invalid hex value for %s: %s", field_name, text))
        if (!significant && digit != 0) begin
          significant = 1;
          significant_bits = (token.len() - idx - 1) * 4 + $clog2(digit + 1);
          if (significant_bits > width)
            `uvm_fatal(get_type_name(), $sformatf("%s overflows %0d bits: %s", field_name, width, text))
        end
      end
      return token;
    endfunction

    function automatic int unsigned axi_checked_uint_text(
      input string text,
      input string field_name
    );
      string token;
      longint unsigned value;
      int unsigned parsed;
      byte c;
      token = axi_trim(text);
      // Retain the old bare-hex fallback, but validate the whole token and its
      // width before $sscanf can truncate it into an int unsigned.
      if (axi_has_hex_prefix(token)) begin
        token = axi_checked_hex_token(token, 32, field_name);
        void'($sscanf(token, "%h", parsed));
        return parsed;
      end
      token = axi_normalize_hex_token(token);
      if (token.len() == 0)
        `uvm_fatal(get_type_name(), $sformatf("Empty integer for %s", field_name))
      for (int idx = 0; idx < token.len(); idx++) begin
        c = token.getc(idx);
        if (c < "0" || c > "9") begin
          token = axi_checked_hex_token(token, 32, field_name);
          void'($sscanf(token, "%h", parsed));
          return parsed;
        end
      end
      value = 0;
      for (int idx = 0; idx < token.len(); idx++) begin
        value = value * 10 + token.getc(idx) - "0";
        if (value > 64'hffffffff)
          `uvm_fatal(get_type_name(), $sformatf("%s overflows 32 bits: %s", field_name, text))
      end
      return int'(value);
    endfunction

    task axi_submit_write_payload(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_ID_WIDTH-1:0] id,
      input int unsigned size,
      input logic [AXI_DATA_WIDTH-1:0] payload[],
      input logic [AXI_STRB_WIDTH-1:0] strobes[],
      output axi4_completion handle
    );
      axi4_burst_request req;
      int unsigned bytes_per_beat, lane;
      if (size > $clog2(AXI_STRB_WIDTH))
        `uvm_fatal(get_type_name(), "Payload SIZE exceeds the bus width")
      if (payload.size() == 0 || payload.size() != strobes.size())
        `uvm_fatal(get_type_name(), "Payload/strobe arrays must contain equal nonzero beat counts")
      bytes_per_beat = 1 << size;
      req = new("sequence_write_payload");
      req.addr = addr;
      req.id = id;
      req.size = size;
      req.beat_count = payload.size();
      req.burst = 1;
      req.lock = 0;
      req.check_response = 0; // The explicit wait checks the caller's expectation.
      req.data = new[req.beat_count];
      req.strb = new[req.beat_count];
      foreach (payload[beat]) begin
        if ($isunknown(payload[beat]) || $isunknown(strobes[beat]) ||
            (payload[beat] >> (8 * bytes_per_beat)) !== '0 ||
            (strobes[beat] >> bytes_per_beat) !== '0)
          `uvm_fatal(get_type_name(), "Payload or relative strobe does not fit SIZE")
        lane = (addr + beat * bytes_per_beat) % AXI_STRB_WIDTH;
        req.data[beat] = payload[beat] << (8 * lane);
        req.strb[beat] = strobes[beat] << lane;
      end
      axi_submit_write(req, handle);
    endtask

    task axi_submit_read_payload(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_ID_WIDTH-1:0] id,
      input int unsigned size,
      input int unsigned beats,
      output axi4_completion handle
    );
      axi4_burst_request req;
      req = new("sequence_read_payload");
      req.addr = addr;
      req.id = id;
      req.size = size;
      req.beat_count = beats;
      req.burst = 1;
      req.lock = 0;
      req.check_response = 0;
      axi_submit_read(req, handle);
    endtask

    task axi_wait_write_checked(
      input axi4_completion handle,
      input logic [1:0] expected_resp = AXI_RESP_OKAY
    );
      axi4_burst_response rsp;
      axi_wait_completion(handle, rsp);
      axi_require_completion_ok(handle);
      if (rsp == null)
        `uvm_fatal(get_type_name(), "Write completed without a response")
      if (rsp.bresp !== expected_resp)
        `uvm_error(get_type_name(), $sformatf("Sequence write response expected=%0h got=%0h",
                                            expected_resp, rsp.bresp))
    endtask

    task axi_wait_read_checked(
      input axi4_completion handle,
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input int unsigned size,
      input logic [AXI_DATA_WIDTH-1:0] expected[],
      input logic [AXI_DATA_WIDTH-1:0] masks[],
      input logic [1:0] expected_resp = AXI_RESP_OKAY
    );
      axi4_burst_response rsp;
      logic [AXI_DATA_WIDTH-1:0] value, valid_mask;
      int unsigned bytes_per_beat, lane;
      if (size > $clog2(AXI_STRB_WIDTH))
        `uvm_fatal(get_type_name(), "Read check SIZE exceeds the bus width")
      bytes_per_beat = 1 << size;
      valid_mask = '1;
      valid_mask >>= AXI_DATA_WIDTH - 8 * bytes_per_beat;
      axi_wait_completion(handle, rsp);
      axi_require_completion_ok(handle);
      if (rsp == null)
        `uvm_fatal(get_type_name(), "Read completed without a response")
      if (expected.size() != masks.size() ||
          (expected.size() != 0 && expected.size() != rsp.data.size()))
        `uvm_fatal(get_type_name(), "Read check array lengths differ from response beats")
      foreach (rsp.data[beat]) begin
        if (rsp.rresp[beat] !== expected_resp)
          `uvm_error(get_type_name(), $sformatf("Sequence read response beat=%0d expected=%0h got=%0h",
                                              beat, expected_resp, rsp.rresp[beat]))
        if (expected.size() != 0) begin
          if ($isunknown(expected[beat]) || $isunknown(masks[beat]) ||
              (expected[beat] & ~valid_mask) !== '0 || (masks[beat] & ~valid_mask) !== '0)
            `uvm_fatal(get_type_name(), "Read expected payload/mask does not fit SIZE")
          lane = (addr + beat * bytes_per_beat) % AXI_STRB_WIDTH;
          value = (rsp.data[beat] >> (8 * lane)) & valid_mask;
          if ((value & masks[beat]) !== (expected[beat] & masks[beat]))
            `uvm_error(get_type_name(), $sformatf(
              "Sequence read addr=0x%0h beat=%0d expected=0x%0h got=0x%0h mask=0x%0h",
              addr, beat, expected[beat], value, masks[beat]))
        end
      end
    endtask

    task axi_write_byte_checked(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [7:0] data
    );
      axi4_completion handle;
      logic [AXI_DATA_WIDTH-1:0] payload[];
      logic [AXI_STRB_WIDTH-1:0] strobes[];
      payload = new[1];
      strobes = new[1];
      payload[0] = data;
      strobes[0] = 1;
      axi_submit_write_payload(addr, AXI_DEFAULT_ID, 0, payload, strobes, handle);
      axi_wait_write_checked(handle);
    endtask

    task axi_check_range(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_ADDR_WIDTH-1:0] stride,
      input int unsigned count,
      input axi_write_mode_e mode,
      input bit check_readback_overlap = 0
    );
      bit [AXI_ADDR_WIDTH+32:0] last_byte;
      if (count == 0 || stride == 0)
        `uvm_fatal(get_type_name(), "Range count and stride must be positive")
      if (check_readback_overlap && count > 1 && stride < AXI_STRB_WIDTH)
        `uvm_fatal(get_type_name(), "Range readback windows overlap; increase stride or disable readback")
      if (mode != SINGLE_ADDR_SINGLE_BYTE &&
          ((addr % AXI_STRB_WIDTH) != 0 || (stride % AXI_STRB_WIDTH) != 0))
        `uvm_fatal(get_type_name(), "Full-width range address/stride must be bus-byte aligned")
      last_byte = (AXI_ADDR_WIDTH+33)'(addr) +
                  (AXI_ADDR_WIDTH+33)'(count - 1) * stride + AXI_STRB_WIDTH - 1;
      if ((last_byte >> AXI_ADDR_WIDTH) != 0)
        `uvm_fatal(get_type_name(), "Range address window overflows AXI address width")
    endtask

    task axi_read_by_mode(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      output bit [AXI_DATA_WIDTH-1:0] data,
      input axi_write_mode_e mode
    );
      axi4_completion handle;
      axi4_burst_response rsp;
      int unsigned lane;
      if (mode != SINGLE_ADDR_SINGLE_BYTE) begin
        axi_read(addr, data);
        return;
      end
      axi_check_range(addr, 1, 1, mode);
      data = '0;
      for (int idx = 0; idx < AXI_STRB_WIDTH; idx++) begin
        axi_submit_read_payload(addr + idx, AXI_DEFAULT_ID, 0, 1, handle);
        axi_wait_completion(handle, rsp);
        axi_require_completion_ok(handle);
        if (rsp == null || rsp.data.size() != 1)
          `uvm_fatal(get_type_name(), "Byte read did not return exactly one beat")
        if (rsp.rresp[0] !== AXI_RESP_OKAY)
          `uvm_error(get_type_name(), "Byte read received non-OKAY response")
        lane = (addr + idx) % AXI_STRB_WIDTH;
        if ($isunknown(rsp.data[0][8*lane +: 8]))
          `uvm_error(get_type_name(), "Byte read received unknown data")
        data[8*idx +: 8] = rsp.data[0][8*lane +: 8];
      end
    endtask

    task axi_read_by_mode_checked(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] expected,
      input axi_write_mode_e mode
    );
      bit [AXI_DATA_WIDTH-1:0] data;
      axi_read_by_mode(addr, data, mode);
      if (data !== expected)
        `uvm_error(get_type_name(), $sformatf("Mode readback addr=0x%0h expected=0x%0h got=0x%0h",
                                            addr, expected, data))
    endtask
