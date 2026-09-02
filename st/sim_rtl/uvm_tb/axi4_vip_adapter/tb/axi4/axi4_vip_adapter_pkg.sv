package axi4_vip_adapter_pkg;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_cfg_pkg::*;
  import axi4_seq_cfg_pkg::*;

  parameter int AXI_ADDR_WIDTH = VIP_AXI_ADDR_WIDTH;
  parameter int AXI_DATA_WIDTH = VIP_AXI_DATA_WIDTH;
  parameter int AXI_ID_WIDTH   = VIP_AXI_ID_WIDTH;
  parameter int AXI_STRB_WIDTH = VIP_AXI_STRB_WIDTH;
  parameter int AXI_LEN_WIDTH = VIP_AXI_LEN_WIDTH;
  parameter int AXI_SIZE_WIDTH = VIP_AXI_SIZE_WIDTH;
  parameter int AXI_BURST_WIDTH = VIP_AXI_BURST_WIDTH;
  parameter int AXI_LOCK_WIDTH = VIP_AXI_LOCK_WIDTH;
  parameter int AXI_CACHE_WIDTH = VIP_AXI_CACHE_WIDTH;
  parameter int AXI_PROT_WIDTH = VIP_AXI_PROT_WIDTH;
  parameter int AXI_QOS_WIDTH = VIP_AXI_QOS_WIDTH;
  parameter int AXI_REGION_WIDTH = VIP_AXI_REGION_WIDTH;
  parameter int AXI_RESP_WIDTH = VIP_AXI_RESP_WIDTH;
  parameter int AXI_AWUSER_WIDTH = VIP_AXI_AWUSER_WIDTH;
  parameter int AXI_ARUSER_WIDTH = VIP_AXI_ARUSER_WIDTH;
  parameter int AXI_WUSER_WIDTH = VIP_AXI_WUSER_WIDTH;
  parameter int AXI_RUSER_WIDTH = VIP_AXI_RUSER_WIDTH;
  parameter int AXI_BUSER_WIDTH = VIP_AXI_BUSER_WIDTH;
  parameter bit [AXI_ID_WIDTH-1:0] AXI_DEFAULT_ID = VIP_AXI_DEFAULT_ID;
  parameter bit [AXI_STRB_WIDTH-1:0] AXI_DEFAULT_STRB = VIP_AXI_DEFAULT_STRB;
  parameter bit [AXI_BURST_WIDTH-1:0] AXI_DEFAULT_BURST = VIP_AXI_DEFAULT_BURST;
  parameter int AXI_DEFAULT_BURST_LEN = VIP_AXI_DEFAULT_BURST_LEN;
  parameter bit [AXI_LOCK_WIDTH-1:0] AXI_DEFAULT_LOCK = VIP_AXI_DEFAULT_LOCK;
  parameter bit [AXI_CACHE_WIDTH-1:0] AXI_DEFAULT_CACHE = VIP_AXI_DEFAULT_CACHE;
  parameter bit [AXI_PROT_WIDTH-1:0] AXI_DEFAULT_PROT = VIP_AXI_DEFAULT_PROT;
  parameter bit [AXI_QOS_WIDTH-1:0] AXI_DEFAULT_QOS = VIP_AXI_DEFAULT_QOS;
  parameter bit [AXI_REGION_WIDTH-1:0] AXI_DEFAULT_REGION = VIP_AXI_DEFAULT_REGION;
  parameter int AXI_MAX_BURST_LEN = VIP_AXI_MAX_BURST_LEN;
  parameter int AXI_MAX_OUTSTANDING_READS = VIP_AXI_MAX_OUTSTANDING_READS;
  parameter int AXI_MAX_OUTSTANDING_WRITES = VIP_AXI_MAX_OUTSTANDING_WRITES;
  parameter int AXI_OUTSTANDING = VIP_AXI_OUTSTANDING;
  parameter int AXI_READ_TIMEOUT_CYCLES = VIP_AXI_READ_TIMEOUT_CYCLES;
  parameter int AXI_WRITE_TIMEOUT_CYCLES = VIP_AXI_WRITE_TIMEOUT_CYCLES;
  parameter int AXI_READY_TIMEOUT_CYCLES = VIP_AXI_READY_TIMEOUT_CYCLES;
  parameter bit AXI_ENABLE_PROTOCOL_CHECKS = VIP_ENABLE_PROTOCOL_CHECKS;
  parameter bit AXI_ENABLE_RESPONSE_CHECKS = VIP_ENABLE_RESPONSE_CHECKS;
  parameter bit AXI_ENABLE_TIMEOUT_CHECKS = VIP_ENABLE_TIMEOUT_CHECKS;
  parameter int AXI_GAP_DEFAULT_POLICY = SEQ_GAP_DEFAULT_POLICY;
  parameter int AXI_GAP_FIXED_CYCLES = SEQ_GAP_FIXED_CYCLES;
  parameter int AXI_GAP_MIN_MIN_CYCLES = SEQ_GAP_MIN_MIN_CYCLES;
  parameter int AXI_GAP_MIN_MAX_CYCLES = SEQ_GAP_MIN_MAX_CYCLES;
  parameter int AXI_GAP_MIN_WEIGHT = SEQ_GAP_MIN_WEIGHT;
  parameter int AXI_GAP_MID_MIN_CYCLES = SEQ_GAP_MID_MIN_CYCLES;
  parameter int AXI_GAP_MID_MAX_CYCLES = SEQ_GAP_MID_MAX_CYCLES;
  parameter int AXI_GAP_MID_WEIGHT = SEQ_GAP_MID_WEIGHT;
  parameter int AXI_GAP_HIGH_MIN_CYCLES = SEQ_GAP_HIGH_MIN_CYCLES;
  parameter int AXI_GAP_HIGH_MAX_CYCLES = SEQ_GAP_HIGH_MAX_CYCLES;
  parameter int AXI_GAP_HIGH_WEIGHT = SEQ_GAP_HIGH_WEIGHT;
  parameter int AXI_GAP_MAX_MIN_CYCLES = SEQ_GAP_MAX_MIN_CYCLES;
  parameter int AXI_GAP_MAX_MAX_CYCLES = SEQ_GAP_MAX_MAX_CYCLES;
  parameter int AXI_GAP_MAX_WEIGHT = SEQ_GAP_MAX_WEIGHT;

  parameter int AXI_GAP_POLICY_UNIFORM = SEQ_GAP_POLICY_UNIFORM;
  parameter int AXI_GAP_POLICY_WEIGHTED = SEQ_GAP_POLICY_WEIGHTED;

  typedef enum int {
    MIN,
    MID,
    HIGH,
    MAX
  } axi_gap_level_e;

  typedef enum int {
    FULL_ADDR_FULL_BYTE,
    FULL_ADDR_SINGLE_BYTE,
    SINGLE_ADDR_SINGLE_BYTE
  } axi_write_mode_e;

  localparam axi_write_mode_e AXI_WRITE_FULL_WORD = FULL_ADDR_FULL_BYTE;
  localparam axi_write_mode_e AXI_WRITE_SAME_ADDR_BYTE_LANES = FULL_ADDR_SINGLE_BYTE;
  localparam axi_write_mode_e AXI_WRITE_INCR_ADDR_FIXED_STRB = SINGLE_ADDR_SINGLE_BYTE;

  function automatic int unsigned axi_gap_cycles(input axi_gap_level_e level);
    case (level)
      MIN:  return seq_gap_min_cycles();
      MID:  return seq_gap_mid_cycles();
      HIGH: return seq_gap_high_cycles();
      MAX:  return seq_gap_max_cycles();
      default: return 0;
    endcase
  endfunction

  function automatic axi_gap_level_e axi_gap_uniform_level();
    case ($urandom_range(3, 0))
      0: return MIN;
      1: return MID;
      2: return HIGH;
      default: return MAX;
    endcase
  endfunction

  function automatic axi_gap_level_e axi_gap_weighted_level();
    int unsigned total_weight;
    int unsigned pick;
    int unsigned cursor;

    total_weight = AXI_GAP_MIN_WEIGHT + AXI_GAP_MID_WEIGHT +
                   AXI_GAP_HIGH_WEIGHT + AXI_GAP_MAX_WEIGHT;
    if (total_weight == 0) begin
      return axi_gap_uniform_level();
    end

    pick = $urandom_range(total_weight - 1, 0);
    cursor = AXI_GAP_MIN_WEIGHT;
    if (pick < cursor) begin
      return MIN;
    end
    cursor = cursor + AXI_GAP_MID_WEIGHT;
    if (pick < cursor) begin
      return MID;
    end
    cursor = cursor + AXI_GAP_HIGH_WEIGHT;
    if (pick < cursor) begin
      return HIGH;
    end
    return MAX;
  endfunction

  function automatic axi_gap_level_e axi_gap_random_level(input int policy);
    if (policy == AXI_GAP_POLICY_UNIFORM) begin
      return axi_gap_uniform_level();
    end
    return axi_gap_weighted_level();
  endfunction

  function automatic int unsigned axi_gap_random_cycles(input int policy);
    return axi_gap_cycles(axi_gap_random_level(policy));
  endfunction

  function automatic string axi_gap_level_name(input axi_gap_level_e level);
    case (level)
      MIN:     return "MIN";
      MID:     return "MID";
      HIGH:    return "HIGH";
      MAX:     return "MAX";
      default: return "UNKNOWN";
    endcase
  endfunction

  typedef enum bit [1:0] {
    AXI_RESP_OKAY   = 2'b00,
    AXI_RESP_EXOKAY = 2'b01,
    AXI_RESP_SLVERR = 2'b10,
    AXI_RESP_DECERR = 2'b11
  } axi_resp_e;

  function string axi_resp_name(input logic [1:0] resp);
    case (resp)
      AXI_RESP_OKAY:   return "OKAY";
      AXI_RESP_EXOKAY: return "EXOKAY";
      AXI_RESP_SLVERR: return "SLVERR";
      AXI_RESP_DECERR: return "DECERR";
      default:         return "UNKNOWN";
    endcase
  endfunction

  class axi4_vip_adapter_base extends uvm_object;
    `uvm_object_utils(axi4_vip_adapter_base)

    local semaphore bus_lock;

    function new(string name = "axi4_vip_adapter_base");
      super.new(name);
      bus_lock = new(1);
    endfunction

    virtual task init();
      `uvm_info(get_type_name(), "Default init hook", UVM_LOW)
    endtask

    virtual task lock_bus();
      bus_lock.get(1);
    endtask

    virtual function void unlock_bus();
      bus_lock.put(1);
    endfunction

    virtual task axi_write(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] data,
      input bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB
    );
      logic [1:0] bresp;

      axi_write_resp(addr, data, strb, bresp);
      if (bresp !== AXI_RESP_OKAY) begin
        `uvm_error(get_type_name(), $sformatf(
          "AXI write response mismatch at addr=0x%0h expected=%s(0x%0h) got=%s(0x%0h)",
          addr, axi_resp_name(AXI_RESP_OKAY), AXI_RESP_OKAY, axi_resp_name(bresp), bresp))
      end
    endtask

    virtual task axi_write_resp(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      input  bit [AXI_DATA_WIDTH-1:0] data,
      input  bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB,
      output logic [1:0]              bresp
    );
      bresp = 'x;
      `uvm_fatal(get_type_name(), "axi_write_resp is not implemented by the selected VIP adapter")
    endtask

    virtual task axi_read(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      output bit [AXI_DATA_WIDTH-1:0] data
    );
      `uvm_fatal(get_type_name(), "axi_read is not implemented by the selected VIP adapter")
    endtask

    virtual task wait_cycles(input int unsigned cycles);
      repeat (cycles) #1ns;
    endtask
  endclass

  class axi4_null_vip_adapter extends axi4_vip_adapter_base;
    `uvm_object_utils(axi4_null_vip_adapter)

    function new(string name = "axi4_null_vip_adapter");
      super.new(name);
    endfunction

    virtual task axi_write_resp(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      input  bit [AXI_DATA_WIDTH-1:0] data,
      input  bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB,
      output logic [1:0]              bresp
    );
      bresp = AXI_RESP_OKAY;
      `uvm_info(get_type_name(), $sformatf(
        "NULL VIP write addr=0x%0h data=0x%0h strb=0x%0h bresp=%s",
        addr, data, strb, axi_resp_name(bresp)), UVM_MEDIUM)
    endtask

    virtual task axi_read(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      output bit [AXI_DATA_WIDTH-1:0] data
    );
      data = '0;
      `uvm_info(get_type_name(), $sformatf(
        "NULL VIP read addr=0x%0h data=0x%0h", addr, data), UVM_MEDIUM)
    endtask
  endclass

  class axi4_adapter_sequencer extends uvm_sequencer #(uvm_sequence_item);
    `uvm_component_utils(axi4_adapter_sequencer)

    axi4_vip_adapter_base adapter;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(axi4_vip_adapter_base)::get(this, "", "adapter", adapter)) begin
        adapter = axi4_null_vip_adapter::type_id::create("adapter");
        `uvm_warning(get_type_name(), "No AXI4 VIP adapter configured; using axi4_null_vip_adapter")
      end
    endfunction
  endclass

  class axi4_sequence_base extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(axi4_sequence_base)
    `uvm_declare_p_sequencer(axi4_adapter_sequencer)

    function new(string name = "axi4_sequence_base");
      super.new(name);
    endfunction

    function automatic bit axi_is_space(input byte c);
      return c == 8'h20 || c == 8'h09 || c == 8'h0a || c == 8'h0d;
    endfunction

    function automatic string axi_trim(input string text);
      int first;
      int last;

      first = 0;
      last = text.len() - 1;
      while (first <= last && axi_is_space(text.getc(first))) begin
        first++;
      end
      while (last >= first && axi_is_space(text.getc(last))) begin
        last--;
      end
      if (first > last) begin
        return "";
      end
      return text.substr(first, last);
    endfunction

    function automatic string axi_strip_comment(input string text);
      for (int i = 0; i < text.len(); i++) begin
        if (text.getc(i) == 8'h23) begin
          if (i == 0) begin
            return "";
          end
          return text.substr(0, i - 1);
        end
      end
      return text;
    endfunction

    function automatic string axi_normalize_hex_token(input string text);
      string result;
      int start_idx;

      result = "";
      start_idx = 0;
      if (text.len() >= 2 &&
          text.getc(0) == 8'h30 &&
          (text.getc(1) == 8'h78 || text.getc(1) == 8'h58)) begin
        start_idx = 2;
      end
      for (int i = start_idx; i < text.len(); i++) begin
        if (text.getc(i) != 8'h5f) begin
          result = {result, text.substr(i, i)};
        end
      end
      return result;
    endfunction

    function automatic bit axi_has_hex_prefix(input string text);
      return text.len() >= 2 &&
             text.getc(0) == 8'h30 &&
             (text.getc(1) == 8'h78 || text.getc(1) == 8'h58);
    endfunction

    function automatic bit [AXI_ADDR_WIDTH-1:0] axi_parse_addr_text(
      input string value_text,
      input string field_name
    );
      bit [AXI_ADDR_WIDTH-1:0] value;

      if ($sscanf(axi_normalize_hex_token(value_text), "%h", value) != 1) begin
        `uvm_fatal(get_type_name(), $sformatf("Invalid hex for %s: %s", field_name, value_text))
      end
      return value;
    endfunction

    function automatic bit [AXI_DATA_WIDTH-1:0] axi_parse_data_text(
      input string value_text,
      input string field_name
    );
      bit [AXI_DATA_WIDTH-1:0] value;

      if ($sscanf(axi_normalize_hex_token(value_text), "%h", value) != 1) begin
        `uvm_fatal(get_type_name(), $sformatf("Invalid hex for %s: %s", field_name, value_text))
      end
      return value;
    endfunction

    function automatic int unsigned axi_parse_uint_text(
      input string value_text,
      input string field_name
    );
      int unsigned value;

      if (axi_has_hex_prefix(value_text)) begin
        if ($sscanf(axi_normalize_hex_token(value_text), "%h", value) != 1) begin
          `uvm_fatal(get_type_name(), $sformatf("Invalid hex integer for %s: %s", field_name, value_text))
        end
      end else if ($sscanf(value_text, "%d", value) != 1) begin
        if ($sscanf(axi_normalize_hex_token(value_text), "%h", value) != 1) begin
          `uvm_fatal(get_type_name(), $sformatf("Invalid integer for %s: %s", field_name, value_text))
        end
      end
      return value;
    endfunction

    function automatic bit axi_parse_bit_text(
      input string value_text,
      input string field_name
    );
      if (value_text == "1" || value_text == "true" || value_text == "TRUE" ||
          value_text == "yes" || value_text == "YES" || value_text == "on" ||
          value_text == "ON") begin
        return 1'b1;
      end
      if (value_text == "0" || value_text == "false" || value_text == "FALSE" ||
          value_text == "no" || value_text == "NO" || value_text == "off" ||
          value_text == "OFF") begin
        return 1'b0;
      end
      `uvm_fatal(get_type_name(), $sformatf("Invalid boolean for %s: %s", field_name, value_text))
      return 1'b0;
    endfunction

    function automatic string axi_upper(input string text);
      string result;
      byte c;

      result = axi_trim(text);
      for (int i = 0; i < result.len(); i++) begin
        c = result.getc(i);
        if (c >= 8'h61 && c <= 8'h7a) begin
          result.putc(i, c - 8'h20);
        end else if (c == 8'h2d) begin
          result.putc(i, 8'h5f);
        end
      end
      return result;
    endfunction

    function automatic string axi_write_mode_name(input axi_write_mode_e write_mode);
      case (write_mode)
        FULL_ADDR_FULL_BYTE:   return "FULL_ADDR_FULL_BYTE";
        FULL_ADDR_SINGLE_BYTE: return "FULL_ADDR_SINGLE_BYTE";
        SINGLE_ADDR_SINGLE_BYTE: return "SINGLE_ADDR_SINGLE_BYTE";
        default:               return "WRITE_MODE_UNKNOWN";
      endcase
    endfunction

    function automatic axi_write_mode_e axi_write_mode_from_text(input string write_mode_text);
      string mode;

      mode = axi_upper(write_mode_text);
      if (mode == "0" || mode == "00" || mode == "FULL" ||
          mode == "FULL_ADDR_FULL_BYTE" ||
          mode == "FULL_WORD" || mode == "AXI_WRITE_FULL_WORD") begin
        return FULL_ADDR_FULL_BYTE;
      end
      if (mode == "1" || mode == "01" || mode == "SAME_ADDR" ||
          mode == "FULL_ADDR_SINGLE_BYTE" ||
          mode == "SAME_ADDR_BYTE_LANES" || mode == "SAME_ADDR_WSTRB_SHIFT" ||
          mode == "AXI_WRITE_SAME_ADDR_BYTE_LANES") begin
        return FULL_ADDR_SINGLE_BYTE;
      end
      if (mode == "2" || mode == "10" || mode == "FIXED_ADDR" ||
          mode == "SINGLE_ADDR_SINGLE_BYTE" ||
          mode == "FIXED_WSTRB" || mode == "FIXED_WSTRB_BYTE_ADDR" ||
          mode == "INCR_ADDR_FIXED_STRB" || mode == "AXI_WRITE_INCR_ADDR_FIXED_STRB") begin
        return SINGLE_ADDR_SINGLE_BYTE;
      end
      if (mode == "3" || mode == "11") begin
        `uvm_fatal(get_type_name(), "write_mode=11 is reserved as an error code")
      end
      `uvm_fatal(get_type_name(), $sformatf(
        "Unsupported AXI write_mode='%s'. Valid values are FULL_ADDR_FULL_BYTE/FULL_ADDR_SINGLE_BYTE/SINGLE_ADDR_SINGLE_BYTE.",
        write_mode_text))
      return FULL_ADDR_FULL_BYTE;
    endfunction

    function automatic axi_write_mode_e axi_write_mode_from_plusargs(input axi_write_mode_e default_mode);
      string mode_text;

      if ($value$plusargs("write_mode=%s", mode_text) ||
          $value$plusargs("WRITE_MODE=%s", mode_text)) begin
        return axi_write_mode_from_text(mode_text);
      end
      if ($value$plusargs("write_tr_mode=%s", mode_text) ||
          $value$plusargs("WRITE_TR_MODE=%s", mode_text)) begin
        return axi_write_mode_from_text(mode_text);
      end
      if ($value$plusargs("tr_write_mode=%s", mode_text) ||
          $value$plusargs("TR_WRITE_MODE=%s", mode_text)) begin
        return axi_write_mode_from_text(mode_text);
      end
      return default_mode;
    endfunction

    task pre_body();
      if (p_sequencer == null || p_sequencer.adapter == null) begin
        `uvm_fatal(get_type_name(), "AXI4 adapter sequencer or adapter is null")
      end
      p_sequencer.adapter.init();
    endtask

    task axi_write(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] data,
      input bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB
    );
      p_sequencer.adapter.lock_bus();
      p_sequencer.adapter.axi_write(addr, data, strb);
      p_sequencer.adapter.unlock_bus();
    endtask

    task axi_write_checked(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] data,
      input bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB,
      input logic [1:0]              expect_bresp = AXI_RESP_OKAY
    );
      logic [1:0] bresp;

      p_sequencer.adapter.lock_bus();
      p_sequencer.adapter.axi_write_resp(addr, data, strb, bresp);
      if (bresp !== expect_bresp) begin
        `uvm_error(get_type_name(), $sformatf(
          "AXI write response mismatch at addr=0x%0h expected=%s(0x%0h) got=%s(0x%0h)",
          addr, axi_resp_name(expect_bresp), expect_bresp, axi_resp_name(bresp), bresp))
      end
      p_sequencer.adapter.unlock_bus();
    endtask

    task axi_read(
      input  bit [AXI_ADDR_WIDTH-1:0] addr,
      output bit [AXI_DATA_WIDTH-1:0] data
    );
      p_sequencer.adapter.lock_bus();
      p_sequencer.adapter.axi_read(addr, data);
      p_sequencer.adapter.unlock_bus();
    endtask

    task axi_read_checked(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] exp_data,
      input string                   msg_context = "AXI read"
    );
      bit [AXI_DATA_WIDTH-1:0] rdata;

      axi_read(addr, rdata);
      if (rdata !== exp_data) begin
        `uvm_error(get_type_name(), $sformatf(
          "%s mismatch at addr=0x%0h expected=0x%0h got=0x%0h",
          msg_context, addr, exp_data, rdata))
      end else begin
        `uvm_info(get_type_name(), $sformatf(
          "%s match at addr=0x%0h expected=0x%0h got=0x%0h",
          msg_context, addr, exp_data, rdata), UVM_LOW)
      end
    endtask

    task axi_write_by_mode(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] data,
      input axi_write_mode_e         write_mode
    );
      bit [AXI_DATA_WIDTH-1:0] lane_data;
      bit [AXI_STRB_WIDTH-1:0] strb;

      case (write_mode)
        FULL_ADDR_FULL_BYTE: begin
          axi_write_checked(addr, data, '1);
        end
        FULL_ADDR_SINGLE_BYTE: begin
          for (int lane_idx = 0; lane_idx < AXI_STRB_WIDTH; lane_idx++) begin
            lane_data = '0;
            lane_data[8 * lane_idx +: 8] = data[8 * lane_idx +: 8];
            strb = '0;
            strb[lane_idx] = 1'b1;
            axi_write_checked(addr, lane_data, strb);
          end
        end
        SINGLE_ADDR_SINGLE_BYTE: begin
          for (int byte_idx = 0; byte_idx < AXI_STRB_WIDTH; byte_idx++) begin
            lane_data = '0;
            lane_data[7:0] = data[8 * byte_idx +: 8];
            strb = '0;
            strb[0] = 1'b1;
            axi_write_checked(addr + byte_idx, lane_data, strb);
          end
        end
        default: begin
          `uvm_fatal(get_type_name(), $sformatf("Unsupported AXI write_mode enum value: %0d", write_mode))
        end
      endcase
    endtask

    task axi_write_by_mode_with_gap(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] data,
      input axi_write_mode_e         write_mode,
      input string                   tr_gap
    );
      bit [AXI_DATA_WIDTH-1:0] lane_data;
      bit [AXI_STRB_WIDTH-1:0] strb;

      case (write_mode)
        FULL_ADDR_FULL_BYTE: begin
          axi_write_checked(addr, data, '1);
          axi_wait_tr_gap_text(tr_gap);
        end
        FULL_ADDR_SINGLE_BYTE: begin
          for (int lane_idx = 0; lane_idx < AXI_STRB_WIDTH; lane_idx++) begin
            lane_data = '0;
            lane_data[8 * lane_idx +: 8] = data[8 * lane_idx +: 8];
            strb = '0;
            strb[lane_idx] = 1'b1;
            axi_write_checked(addr, lane_data, strb);
            axi_wait_tr_gap_text(tr_gap);
          end
        end
        SINGLE_ADDR_SINGLE_BYTE: begin
          for (int byte_idx = 0; byte_idx < AXI_STRB_WIDTH; byte_idx++) begin
            lane_data = '0;
            lane_data[7:0] = data[8 * byte_idx +: 8];
            strb = '0;
            strb[0] = 1'b1;
            axi_write_checked(addr + byte_idx, lane_data, strb);
            axi_wait_tr_gap_text(tr_gap);
          end
        end
        default: begin
          `uvm_fatal(get_type_name(), $sformatf("Unsupported AXI write_mode enum value: %0d", write_mode))
        end
      endcase
    endtask

    task axi_load_mem_window(
      input string path,
      input int unsigned start_index,
      input int unsigned count,
      ref bit [AXI_DATA_WIDTH-1:0] values[$]
    );
      int fd;
      int unsigned mem_index;
      string line;
      string text;
      bit [AXI_DATA_WIDTH-1:0] value;

      values.delete();
      fd = $fopen(path, "r");
      if (fd == 0) begin
        `uvm_fatal(get_type_name(), $sformatf("Cannot open mem file: %s", path))
      end

      mem_index = 0;
      while ($fgets(line, fd)) begin
        text = axi_trim(axi_strip_comment(line));
        if (text == "") begin
          continue;
        end
        value = axi_parse_data_text(text, path);
        if (mem_index >= start_index && values.size() < count) begin
          values.push_back(value);
        end
        mem_index++;
      end
      $fclose(fd);

      if (values.size() != count) begin
        `uvm_fatal(get_type_name(), $sformatf(
          "Mem window out of range: file=%s start=%0d count=%0d available=%0d",
          path, start_index, count, mem_index))
      end
    endtask

    task axi_wait_cycles(input int unsigned cycles);
      p_sequencer.adapter.wait_cycles(cycles);
    endtask

    task axi_wait_gap_cycles_logged(
      input string       gap_kind,
      input string       gap_setting,
      input string       selected_level,
      input int unsigned cycles
    );
      `uvm_info(get_type_name(), $sformatf(
        "%s gap: setting=%s selected=%s cycles=%0d",
        gap_kind, gap_setting, selected_level, cycles), UVM_LOW)
      axi_wait_cycles(cycles);
    endtask

    task axi_wait_gap_level_logged(
      input string          gap_kind,
      input axi_gap_level_e level,
      input string          gap_setting
    );
      int unsigned cycles;

      cycles = axi_gap_cycles(level);
      axi_wait_gap_cycles_logged(gap_kind, gap_setting, axi_gap_level_name(level), cycles);
    endtask

    task axi_wait_gap_policy_logged(
      input string gap_kind,
      input string gap_setting,
      input int    policy
    );
      axi_gap_level_e level;

      level = axi_gap_random_level(policy);
      axi_wait_gap_level_logged(gap_kind, level, gap_setting);
    endtask

    task axi_wait_gap_text_logged(input string gap_kind, input string gap);
      string gap_text;

      gap_text = axi_upper(gap);
      if (gap_text == "" || gap_text == "NONE") begin
        return;
      end
      if (gap_text == "RAND") begin
        gap_text = "RANDOM";
      end

      if (gap_text == "FIXED") begin
        axi_wait_gap_cycles_logged(gap_kind, gap_text, "FIXED", AXI_GAP_FIXED_CYCLES);
      end else if (gap_text == "MIN") begin
        axi_wait_gap_level_logged(gap_kind, MIN, gap_text);
      end else if (gap_text == "MID") begin
        axi_wait_gap_level_logged(gap_kind, MID, gap_text);
      end else if (gap_text == "HIGH") begin
        axi_wait_gap_level_logged(gap_kind, HIGH, gap_text);
      end else if (gap_text == "MAX") begin
        axi_wait_gap_level_logged(gap_kind, MAX, gap_text);
      end else if (gap_text == "RANDOM") begin
        axi_wait_gap_policy_logged(gap_kind, gap_text, AXI_GAP_DEFAULT_POLICY);
      end else if (gap_text == "UNIFORM") begin
        axi_wait_gap_policy_logged(gap_kind, gap_text, AXI_GAP_POLICY_UNIFORM);
      end else if (gap_text == "WEIGHTED") begin
        axi_wait_gap_policy_logged(gap_kind, gap_text, AXI_GAP_POLICY_WEIGHTED);
      end else begin
        `uvm_fatal(get_type_name(), $sformatf(
          "Invalid gap='%s'. Valid values are FIXED/RANDOM/UNIFORM/WEIGHTED",
          gap))
      end
    endtask

    task axi_wait_tr_gap_text(input string gap);
      axi_wait_gap_text_logged("TR", gap);
    endtask

    task axi_wait_seq_gap_text(input string gap);
      axi_wait_gap_text_logged("SEQ", gap);
    endtask

    task axi_wait_tr_gap_cycles(input int unsigned cycles);
      axi_wait_gap_cycles_logged("TR", "CYCLES", "DIRECT", cycles);
    endtask

    task axi_wait_seq_gap_cycles(input int unsigned cycles);
      axi_wait_gap_cycles_logged("SEQ", "CYCLES", "DIRECT", cycles);
    endtask

    task axi_wait_gap(input axi_gap_level_e level);
      axi_wait_gap_level_logged("GAP", level, axi_gap_level_name(level));
    endtask

    task axi_wait_gap_uniform();
      axi_wait_gap_policy_logged("GAP", "UNIFORM", AXI_GAP_POLICY_UNIFORM);
    endtask

    task axi_wait_gap_weighted();
      axi_wait_gap_policy_logged("GAP", "WEIGHTED", AXI_GAP_POLICY_WEIGHTED);
    endtask

    task axi_wait_gap_random();
      axi_wait_gap_policy_logged("GAP", "RANDOM", AXI_GAP_DEFAULT_POLICY);
    endtask

    task axi_wait_gap_text(input string gap);
      axi_wait_gap_text_logged("GAP", gap);
    endtask
  endclass
endpackage
