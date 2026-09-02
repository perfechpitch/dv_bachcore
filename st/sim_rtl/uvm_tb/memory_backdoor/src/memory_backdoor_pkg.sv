package memory_backdoor_pkg;

  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum int unsigned {
    MEM_BKDR_INIT_ZERO,
    MEM_BKDR_INIT_RANDOM
  } memory_backdoor_init_e;

  // Expected-data source selected by a testcase request. The operation
  // component consumes this setting; Reference and Scoreboard stay external.
  typedef enum int unsigned {
    MEMORY_CHECK_REFERENCE,
    MEMORY_CHECK_FILE
  } memory_check_mode_e;

  localparam int unsigned MEM_BKDR_ADDRESS_AUTO = 32'hffff_ffff;

  // Runtime topology and artifact configuration shared by the low-level bank
  // accessor and the unified operation component.
  class memory_backdoor_cfg extends uvm_object;
    string         hdl_path;
    int unsigned   sram_index;
    int unsigned   bank_index;
    int unsigned   capacity;
    int unsigned   access_width;
    int unsigned   sram_count;
    int unsigned   bank_count;
    int unsigned   address_interleave;
    int unsigned   interleave_granularity_bytes;
    int unsigned   interleave_granularity_words;
    string         data_record_file;
    string         random_dump_file;
    int unsigned   random_seed;
    string         project_dir;
    string         dut_input_data_path;
    string         dut_input_address_path;
    string         dut_input_valid_path;
    int unsigned   dut_input_word_count;
    string         dut_output_data_path;
    string         dut_output_valid_path;

    `uvm_object_utils_begin(memory_backdoor_cfg)
      `uvm_field_string(hdl_path, UVM_DEFAULT)
      `uvm_field_int(sram_index, UVM_DEFAULT)
      `uvm_field_int(bank_index, UVM_DEFAULT)
      `uvm_field_int(capacity, UVM_DEFAULT)
      `uvm_field_int(access_width, UVM_DEFAULT)
      `uvm_field_int(sram_count, UVM_DEFAULT)
      `uvm_field_int(bank_count, UVM_DEFAULT)
      `uvm_field_int(address_interleave, UVM_DEFAULT)
      `uvm_field_int(interleave_granularity_bytes, UVM_DEFAULT)
      `uvm_field_int(interleave_granularity_words, UVM_DEFAULT)
      `uvm_field_string(data_record_file, UVM_DEFAULT)
      `uvm_field_string(random_dump_file, UVM_DEFAULT)
      `uvm_field_int(random_seed, UVM_DEFAULT)
      `uvm_field_string(project_dir, UVM_DEFAULT)
      `uvm_field_string(dut_input_data_path, UVM_DEFAULT)
      `uvm_field_string(dut_input_address_path, UVM_DEFAULT)
      `uvm_field_string(dut_input_valid_path, UVM_DEFAULT)
      `uvm_field_int(dut_input_word_count, UVM_DEFAULT)
      `uvm_field_string(dut_output_data_path, UVM_DEFAULT)
      `uvm_field_string(dut_output_valid_path, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "memory_backdoor_cfg");
      super.new(name);
      hdl_path = "";
      sram_index = 0;
      bank_index = 0;
      capacity = 0;
      access_width = 0;
      sram_count = 0;
      bank_count = 0;
      address_interleave = 1;
      interleave_granularity_bytes = 0;
      interleave_granularity_words = 0;
      data_record_file = "";
      random_dump_file = "";
      random_seed = 32'h1;
      project_dir = ".";
      dut_input_data_path = "tb_top.dut.check_input_data_i";
      dut_input_address_path = "tb_top.dut.check_input_word_address_i";
      dut_input_valid_path = "tb_top.dut.check_input_valid_i";
      dut_input_word_count = MEM_BKDR_ADDRESS_AUTO;
      dut_output_data_path = "tb_top.dut.ref_result_capture_array";
      dut_output_valid_path = "tb_top.dut.ref_result_capture_valid";
    endfunction

    function void load_from_plusargs();
      void'($value$plusargs("MEM_BKDR_SRAM_COUNT=%d", sram_count));
      void'($value$plusargs("MEM_BKDR_BANK_COUNT=%d", bank_count));
      void'($value$plusargs("MEM_BKDR_ADDRESS_INTERLEAVE=%d",
                            address_interleave));
      void'($value$plusargs("MEM_BKDR_INTERLEAVE_BYTES=%d",
                            interleave_granularity_bytes));
      void'($value$plusargs("MEM_BKDR_INTERLEAVE_WORDS=%d",
                            interleave_granularity_words));
      void'($value$plusargs("MEM_BKDR_DATA_RECORD_PREFIX=%s",
                            data_record_file));
      void'($value$plusargs("MEM_BKDR_RANDOM_DUMP_FILE=%s",
                            random_dump_file));
      void'($value$plusargs("MEM_BKDR_RANDOM_SEED=%d", random_seed));
      void'($value$plusargs("MEM_BKDR_PROJECT_DIR=%s", project_dir));
      void'($value$plusargs("MEM_BKDR_DUT_INPUT_DATA_PATH=%s",
                            dut_input_data_path));
      void'($value$plusargs("MEM_BKDR_DUT_INPUT_ADDRESS_PATH=%s",
                            dut_input_address_path));
      void'($value$plusargs("MEM_BKDR_DUT_INPUT_VALID_PATH=%s",
                            dut_input_valid_path));
      void'($value$plusargs("MEM_BKDR_TB_INPUT_WORD_COUNT=%d",
                            dut_input_word_count));
      void'($value$plusargs("MEM_BKDR_DUT_OUTPUT_DATA_PATH=%s",
                            dut_output_data_path));
      void'($value$plusargs("MEM_BKDR_DUT_OUTPUT_VALID_PATH=%s",
                            dut_output_valid_path));
    endfunction
  endclass

  class memory_backdoor_target_cfg;
    string         hdl_path;
    int unsigned   sram_index;
    int unsigned   bank_index;
    int unsigned   capacity;
    int unsigned   access_width;

    function new();
      hdl_path = "";
      sram_index = 0;
      bank_index = 0;
      capacity = 0;
      access_width = 0;
    endfunction
  endclass

  class memory_backdoor_randomizer;
    rand uvm_hdl_data_t value;
    uvm_hdl_data_t min_value;
    uvm_hdl_data_t max_value;

    constraint value_range_c {
      value >= min_value;
      value <= max_value;
    }
  endclass

  // Low-level accessor used by the Operation component. Logical-to-bank
  // mapping and complete testcase flows stay in the Operation component;
  // this class performs selected bank-row and generic HDL path access.
  class memory_backdoor extends uvm_object;
    localparam int unsigned HDL_DATA_WIDTH = $bits(uvm_hdl_data_t);
    memory_backdoor_cfg cfg;

    `uvm_object_utils(memory_backdoor)

    function new(
      string name = "memory_backdoor",
      memory_backdoor_cfg cfg = null
    );
      super.new(name);
      if (cfg == null)
        this.cfg = memory_backdoor_cfg::type_id::create("cfg");
      else
        this.cfg = cfg;
    endfunction

    function string get_word_path(int unsigned row_address);
      return $sformatf("%s[%0d]", cfg.hdl_path, row_address);
    endfunction

    function uvm_hdl_data_t get_width_mask();
      uvm_hdl_data_t mask;
      mask = '1;
      if (cfg.access_width < HDL_DATA_WIDTH)
        mask = (uvm_hdl_data_t'(1) << cfg.access_width) - uvm_hdl_data_t'(1);
      return mask;
    endfunction

    function bit validate_bank_cfg();
      if (cfg.hdl_path == "") begin
        `uvm_error(get_type_name(), "hdl_path must not be empty")
        return 1'b0;
      end
      if (cfg.capacity == 0) begin
        `uvm_error(get_type_name(), "bank capacity must be greater than zero")
        return 1'b0;
      end
      if ((cfg.access_width == 0) || (cfg.access_width > HDL_DATA_WIDTH)) begin
        `uvm_error(get_type_name(),
          $sformatf("access_width must be in [1:%0d], got %0d",
                    HDL_DATA_WIDTH, cfg.access_width))
        return 1'b0;
      end
      return 1'b1;
    endfunction

    // One hexadecimal word per line. Blank/comment lines are ignored.
    function bit load_hex_file(
      string file_name,
      ref uvm_hdl_data_t values[$],
      input int unsigned max_word_count,
      input int unsigned exact_word_count = 0
    );
      int            fd;
      int            scan_count;
      string         line;
      uvm_hdl_data_t value;
      uvm_hdl_data_t mask;

      values.delete();
      if (!validate_bank_cfg())
        return 1'b0;
      mask = get_width_mask();
      fd = $fopen(file_name, "r");
      if (fd == 0) begin
        `uvm_error(get_type_name(),
          $sformatf("Cannot open hex file '%s'", file_name))
        return 1'b0;
      end
      while ($fgets(line, fd)) begin
        value = '0;
        scan_count = $sscanf(line, "%h", value);
        if (scan_count == 1)
          values.push_back(value & mask);
      end
      $fclose(fd);

      if (values.size() == 0) begin
        `uvm_error(get_type_name(),
          $sformatf("File '%s' contains no data words", file_name))
        return 1'b0;
      end
      if (values.size() > max_word_count) begin
        `uvm_error(get_type_name(),
          $sformatf("File '%s' contains %0d words; at most %0d fit",
                    file_name, values.size(), max_word_count))
        return 1'b0;
      end
      if ((exact_word_count != 0) &&
          (values.size() != exact_word_count)) begin
        `uvm_error(get_type_name(),
          $sformatf("File '%s' contains %0d words; expected exactly %0d",
                    file_name, values.size(), exact_word_count))
        return 1'b0;
      end
      return 1'b1;
    endfunction

    function bit deposit_word(
      input int unsigned row_address,
      input uvm_hdl_data_t value
    );
      string path;
      if (row_address >= cfg.capacity) begin
        `uvm_error(get_type_name(), "Bank row address is outside capacity")
        return 1'b0;
      end
      path = get_word_path(row_address);
      if (!uvm_hdl_deposit(path, value & get_width_mask())) begin
        `uvm_error(get_type_name(),
          $sformatf("Backdoor deposit failed at SRAM %0d bank %0d row %0d, path '%s'",
                    cfg.sram_index, cfg.bank_index, row_address, path))
        return 1'b0;
      end
      return 1'b1;
    endfunction

    function bit read_word(
      input int unsigned row_address,
      output uvm_hdl_data_t value
    );
      string path;
      value = '0;
      if (row_address >= cfg.capacity) begin
        `uvm_error(get_type_name(), "Bank row address is outside capacity")
        return 1'b0;
      end
      path = get_word_path(row_address);
      if (!uvm_hdl_read(path, value)) begin
        `uvm_error(get_type_name(),
          $sformatf("Backdoor read failed at SRAM %0d bank %0d row %0d, path '%s'",
                    cfg.sram_index, cfg.bank_index, row_address, path))
        return 1'b0;
      end
      value &= get_width_mask();
      return 1'b1;
    endfunction

    // Generic hierarchy read used when a testcase must inspect DUT state
    // outside the configured SRAM bank arrays.
    function bit read_hdl_path(
      input string hdl_path,
      output uvm_hdl_data_t value
    );
      value = '0;
      if (hdl_path == "") begin
        `uvm_error(get_type_name(), "Backdoor HDL read path is empty")
        return 1'b0;
      end
      if (!uvm_hdl_read(hdl_path, value)) begin
        `uvm_error(get_type_name(),
          $sformatf("Backdoor HDL read failed at path '%s'", hdl_path))
        return 1'b0;
      end
      return 1'b1;
    endfunction

    // Generic hierarchy deposit utility. Check input monitoring is read-only
    // and does not use this method.
    function bit deposit_hdl_path(
      input string hdl_path,
      input uvm_hdl_data_t value
    );
      if (hdl_path == "") begin
        `uvm_error(get_type_name(), "Backdoor HDL deposit path is empty")
        return 1'b0;
      end
      if (!uvm_hdl_deposit(hdl_path, value)) begin
        `uvm_error(get_type_name(),
          $sformatf("Backdoor HDL deposit failed at path '%s'", hdl_path))
        return 1'b0;
      end
      return 1'b1;
    endfunction
  endclass

endpackage
