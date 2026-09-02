package memory_backdoor_operation_pkg;

  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_reference_component_pkg::*;
  import memory_scoreboard_component_pkg::*;
  `include "uvm_macros.svh"

  typedef enum int unsigned {
    MEMORY_OPERATION_FILE_INIT,
    MEMORY_OPERATION_ZERO_INIT,
    MEMORY_OPERATION_RANDOM_INIT,
    MEMORY_OPERATION_REF_CHECK,
    MEMORY_OPERATION_FILE_CHECK
  } memory_backdoor_operation_e;

  // A testcase only fills this request. All mutation, file handling, DUT
  // array access, Reference dispatch, and Scoreboard dispatch live in the
  // operation component below.
  class memory_backdoor_operation_request extends uvm_object;
    memory_backdoor_operation_e operation;
    string                      testcase_name;
    int unsigned                sram_index;
    int unsigned                expected_sram_count;
    int unsigned                check_word_count;
    int unsigned                start_address;
    int unsigned                end_address;
    bit                         compare_enable;
    bit                         use_full_data_width;
    uvm_hdl_data_t              random_min;
    uvm_hdl_data_t              random_max;
    memory_check_mode_e         check_mode;
    string                      golden_file;
    string                      bank0_file;
    string                      bank1_file;
    string                      bank2_file;
    string                      bank3_file;
    int unsigned                bank0_start_row;
    int unsigned                bank1_start_row;
    int unsigned                bank2_start_row;
    int unsigned                bank3_start_row;

    `uvm_object_utils(memory_backdoor_operation_request)

    function new(string name = "memory_backdoor_operation_request");
      super.new(name);
      operation = MEMORY_OPERATION_ZERO_INIT;
      testcase_name = "";
      sram_index = 0;
      expected_sram_count = 1;
      check_word_count = MEM_BKDR_ADDRESS_AUTO;
      start_address = 0;
      end_address = MEM_BKDR_ADDRESS_AUTO;
      compare_enable = 1'b0;
      use_full_data_width = 1'b1;
      random_min = '0;
      random_max = '1;
      check_mode = MEMORY_CHECK_REFERENCE;
      golden_file = "";
      bank0_file = "";
      bank1_file = "";
      bank2_file = "";
      bank3_file = "";
      bank0_start_row = 0;
      bank1_start_row = 0;
      bank2_start_row = 0;
      bank3_start_row = 0;
    endfunction
  endclass

  class memory_backdoor_operation_component extends uvm_component;
    protected memory_backdoor_cfg          cfg;
    protected memory_backdoor              backdoor;
    protected memory_reference_component   reference_component;
    protected memory_scoreboard_component  scoreboard_component;
    protected memory_backdoor_target_cfg   targets[$];
    protected event                        dut_input_capture_ready_event;
    protected event                        dut_input_sample_event;
    protected int unsigned                 base_random_seed;
    protected bit                          busy;

    `uvm_component_utils(memory_backdoor_operation_component)

    function new(string name = "memory_backdoor_operation_component",
                 uvm_component parent = null);
      super.new(name, parent);
      busy = 1'b0;
    endfunction

    function void configure(
      input memory_backdoor_cfg cfg,
      input memory_backdoor backdoor,
      input memory_backdoor_target_cfg targets[$],
      input event dut_input_capture_ready_event,
      input event dut_input_sample_event,
      input memory_reference_component reference_component,
      input memory_scoreboard_component scoreboard_component
    );
      if (cfg == null) begin
        `uvm_fatal(get_name(), "Cannot configure operation with null cfg")
        return;
      end
      this.cfg = cfg;
      this.backdoor = backdoor;
      this.dut_input_capture_ready_event = dut_input_capture_ready_event;
      this.dut_input_sample_event = dut_input_sample_event;
      this.reference_component = reference_component;
      this.scoreboard_component = scoreboard_component;
      this.targets = targets;
      this.base_random_seed = cfg.random_seed;
    endfunction

    protected function bit validate_context();
      int unsigned flat_index;

      if ((cfg == null) || (backdoor == null)) begin
        `uvm_error(get_name(), "Backdoor context is not configured")
        return 1'b0;
      end
      if ((cfg.sram_count == 0) || (cfg.bank_count == 0)) begin
        `uvm_error(get_name(), "SRAM count and bank count must be positive")
        return 1'b0;
      end
      if (cfg.address_interleave > 1) begin
        `uvm_error(get_name(), "address_interleave must be 0 or 1")
        return 1'b0;
      end
      if ((cfg.interleave_granularity_bytes == 0) ||
          (cfg.interleave_granularity_words == 0)) begin
        `uvm_error(get_name(), "Interleave granularity must be positive")
        return 1'b0;
      end
      if (targets.size() != (cfg.sram_count * cfg.bank_count)) begin
        `uvm_error(get_name(),
          $sformatf("Expected %0d targets for %0d SRAMs x %0d banks, got %0d",
                    cfg.sram_count * cfg.bank_count, cfg.sram_count,
                    cfg.bank_count, targets.size()))
        return 1'b0;
      end

      for (int unsigned sram_index = 0;
           sram_index < cfg.sram_count; sram_index++) begin
        for (int unsigned bank_index = 0;
             bank_index < cfg.bank_count; bank_index++) begin
          flat_index = sram_index * cfg.bank_count + bank_index;
          if ((targets[flat_index].sram_index != sram_index) ||
              (targets[flat_index].bank_index != bank_index)) begin
            `uvm_error(get_name(), "Targets must be ordered by SRAM then bank")
            return 1'b0;
          end
          if ((targets[flat_index].hdl_path == "") ||
              (targets[flat_index].capacity == 0) ||
              (targets[flat_index].access_width == 0) ||
              (targets[flat_index].access_width > $bits(uvm_hdl_data_t))) begin
            `uvm_error(get_name(),
              $sformatf("Invalid configuration for SRAM %0d bank %0d",
                        sram_index, bank_index))
            return 1'b0;
          end
          if ((cfg.address_interleave != 0) &&
              ((targets[flat_index].capacity %
                cfg.interleave_granularity_words) != 0)) begin
            `uvm_error(get_name(),
              "Bank capacity must be divisible by interleave granularity")
            return 1'b0;
          end
          if ((targets[flat_index].access_width % 8) != 0 ||
              (cfg.interleave_granularity_bytes !=
               cfg.interleave_granularity_words *
               (targets[flat_index].access_width / 8))) begin
            `uvm_error(get_name(),
              "Interleave byte and word granularities are inconsistent")
            return 1'b0;
          end
          if ((targets[flat_index].capacity !=
               targets[sram_index * cfg.bank_count].capacity) ||
              (targets[flat_index].access_width !=
               targets[sram_index * cfg.bank_count].access_width)) begin
            `uvm_error(get_name(),
              $sformatf("SRAM %0d requires equal bank capacity and width",
                        sram_index))
            return 1'b0;
          end
        end
      end
      return 1'b1;
    endfunction

    protected function int unsigned sram_capacity_words(
      input int unsigned sram_index
    );
      int unsigned first_target;
      if ((cfg == null) || (sram_index >= cfg.sram_count))
        return 0;
      first_target = sram_index * cfg.bank_count;
      return cfg.bank_count * targets[first_target].capacity;
    endfunction

    protected function int unsigned bank_capacity_words(
      input int unsigned sram_index
    );
      int unsigned first_target;
      if ((cfg == null) || (sram_index >= cfg.sram_count))
        return 0;
      first_target = sram_index * cfg.bank_count;
      return targets[first_target].capacity;
    endfunction

    protected function uvm_hdl_data_t sram_data_width_mask(
      input int unsigned sram_index
    );
      int unsigned   first_target;
      int unsigned   data_width;
      uvm_hdl_data_t mask;
      mask = '1;
      if ((cfg == null) || (sram_index >= cfg.sram_count))
        return '0;
      first_target = sram_index * cfg.bank_count;
      data_width = targets[first_target].access_width;
      if (data_width < $bits(uvm_hdl_data_t))
        mask = (uvm_hdl_data_t'(1) << data_width) - uvm_hdl_data_t'(1);
      return mask;
    endfunction

    protected function void apply_target_config(
      input int unsigned sram_index,
      input int unsigned bank_index
    );
      int unsigned flat_index;
      flat_index = sram_index * cfg.bank_count + bank_index;
      cfg.hdl_path = targets[flat_index].hdl_path;
      cfg.sram_index = sram_index;
      cfg.bank_index = bank_index;
      cfg.capacity = targets[flat_index].capacity;
      cfg.access_width = targets[flat_index].access_width;
    endfunction

    protected function int unsigned interleave_bank(
      input int unsigned sram_index,
      input int unsigned local_address
    );
      if (cfg.address_interleave == 0)
        return local_address / bank_capacity_words(sram_index);
      return (local_address / cfg.interleave_granularity_words) %
             cfg.bank_count;
    endfunction

    protected function int unsigned interleave_row(
      input int unsigned sram_index,
      input int unsigned local_address
    );
      if (cfg.address_interleave == 0)
        return local_address % bank_capacity_words(sram_index);
      return
        (local_address /
         (cfg.interleave_granularity_words * cfg.bank_count)) *
          cfg.interleave_granularity_words +
        (local_address % cfg.interleave_granularity_words);
    endfunction

    protected function int unsigned bank_row_to_logical_address(
      input int unsigned sram_index,
      input int unsigned bank_index,
      input int unsigned row_address
    );
      if (cfg.address_interleave == 0)
        return bank_index * bank_capacity_words(sram_index) + row_address;
      return
        (row_address / cfg.interleave_granularity_words) *
          (cfg.bank_count * cfg.interleave_granularity_words) +
        bank_index * cfg.interleave_granularity_words +
        (row_address % cfg.interleave_granularity_words);
    endfunction

    protected function string project_file(input string relative_path);
      if ((relative_path.len() > 0) &&
          (relative_path.getc(0) == 8'h2f))
        return relative_path;
      return {cfg.project_dir, "/", relative_path};
    endfunction

    protected function bit is_hex_string(input string value);
      byte character;
      if (value.len() == 0)
        return 1'b0;
      for (int unsigned index = 0; index < value.len(); index++) begin
        character = value.getc(index);
        if (!(((character >= 8'h30) && (character <= 8'h39)) ||
              ((character >= 8'h41) && (character <= 8'h46)) ||
              ((character >= 8'h61) && (character <= 8'h66))))
          return 1'b0;
      end
      return 1'b1;
    endfunction

    // Shared strict parser for check input and golden files. Files use the
    // stable two-column logical-address format consumed by both check cases.
    protected function bit load_indexed_array_file(
      input string file_name,
      input int unsigned expected_words,
      input int unsigned data_width,
      input uvm_hdl_data_t data_mask,
      ref uvm_hdl_data_t values[$]
    );
      int                file_descriptor;
      int                scan_count;
      int unsigned       logical_address;
      int unsigned       expected_address;
      string             line;
      string             first_token;
      string             second_token;
      string             extra_token;
      string             hex_token;
      uvm_hdl_data_t     value;

      values.delete();
      file_descriptor = $fopen(file_name, "r");
      if (file_descriptor == 0) begin
        `uvm_error(get_name(),
          $sformatf("Cannot open indexed data file '%s'", file_name))
        return 1'b0;
      end
      if (!$fgets(line, file_descriptor)) begin
        `uvm_error(get_name(),
          $sformatf("Indexed data file '%s' is empty", file_name))
        $fclose(file_descriptor);
        return 1'b0;
      end
      first_token = "";
      second_token = "";
      extra_token = "";
      scan_count = $sscanf(line, "%s %s %s", first_token, second_token,
                           extra_token);
      if ((scan_count != 2) ||
          (first_token != "LOGICAL_WORD_ADDRESS") ||
          (second_token != "DATA")) begin
        `uvm_error(get_name(),
          $sformatf("Invalid indexed data header in '%s'", file_name))
        $fclose(file_descriptor);
        return 1'b0;
      end

      expected_address = 0;
      while ($fgets(line, file_descriptor)) begin
        logical_address = '1;
        value = '0;
        second_token = "";
        extra_token = "";
        scan_count = $sscanf(line, "%d %s %s", logical_address,
                             second_token, extra_token);
        if ((scan_count != 2) ||
            (logical_address != expected_address) ||
            (second_token.len() < 3) ||
            (second_token.getc(0) != 8'h30) ||
            ((second_token.getc(1) != 8'h78) &&
             (second_token.getc(1) != 8'h58))) begin
          `uvm_error(get_name(),
            $sformatf("Invalid indexed data at '%s' address %0d",
                      file_name, expected_address))
          $fclose(file_descriptor);
          return 1'b0;
        end
        hex_token = second_token.substr(2, second_token.len() - 1);
        if (!is_hex_string(hex_token) ||
            (hex_token.len() > ((data_width + 3) / 4))) begin
          `uvm_error(get_name(),
            $sformatf("Invalid indexed hexadecimal data at '%s' address %0d",
                      file_name, expected_address))
          $fclose(file_descriptor);
          return 1'b0;
        end
        scan_count = $sscanf(hex_token, "%h", value);
        if ((scan_count != 1) ||
            $isunknown(value & data_mask) ||
            ((value & ~data_mask) !== '0)) begin
          `uvm_error(get_name(),
            $sformatf("Invalid indexed data at '%s' address %0d",
                      file_name, expected_address))
          $fclose(file_descriptor);
          return 1'b0;
        end
        values.push_back(value & data_mask);
        expected_address++;
      end
      $fclose(file_descriptor);

      if (values.size() != expected_words) begin
        `uvm_error(get_name(),
          $sformatf("File '%s' contains %0d words; expected %0d",
                    file_name, values.size(), expected_words))
        values.delete();
        return 1'b0;
      end
      return 1'b1;
    endfunction

    protected function string sram_data_file(
      input string file_prefix,
      input int unsigned sram_index,
      input string extension
    );
      return $sformatf("%s_sram%0d.%s", file_prefix, sram_index, extension);
    endfunction

    protected function string bank_record_file(
      input string record_prefix,
      input int unsigned bank_index
    );
      return $sformatf("%s_bank%0d_record.txt", record_prefix, bank_index);
    endfunction

    protected task create_bank_record(
      input string record_prefix,
      input int unsigned bank_index,
      output int record_fd,
      output string file_name
    );
      file_name = bank_record_file(record_prefix, bank_index);
      record_fd = $fopen(file_name, "w");
      if (record_fd == 0) begin
        `uvm_error(get_name(),
          $sformatf("Cannot create bank record '%s'", file_name))
        return;
      end
      $fdisplay(record_fd,
        "SRAM_INDEX LOGICAL_WORD_ADDRESS BYTE_ADDRESS BANK ROW INPUT_DATA EXPECTED_DATA OUTPUT_DATA RESULT");
    endtask

    protected function longint unsigned sram_byte_address(
      input int unsigned sram_index,
      input int unsigned local_address
    );
      int unsigned first_target;
      if ((cfg == null) || (sram_index >= cfg.sram_count))
        return 0;
      first_target = sram_index * cfg.bank_count;
      return longint'(local_address) *
             (targets[first_target].access_width / 8);
    endfunction

    // Every user-facing record uses the same columns. LOGICAL_WORD_ADDRESS
    // and BYTE_ADDRESS are SRAM-local; ROW is the physical word index inside
    // BANK. Machine-readable one-word-per-line files remain separate.
    protected task write_sram_bank_records(
      input string record_prefix,
      input int unsigned sram_index,
      input int unsigned start_address,
      ref uvm_hdl_data_t input_values[$],
      ref uvm_hdl_data_t expected_values[$],
      input bit compare_enable,
      output bit success
    );
      int              record_fd;
      int unsigned     failure_count;
      int unsigned     total_record_words;
      int unsigned     bank_record_words;
      int unsigned     local_address;
      int unsigned     bank_index;
      int unsigned     row_address;
      int unsigned     end_address;
      int unsigned     value_offset;
      int unsigned     bank_capacity;
      longint unsigned byte_address;
      bit              read_success;
      string           file_name;
      uvm_hdl_data_t   actual_value;

      success = 1'b0;
      if (!validate_context())
        return;
      if (record_prefix == "") begin
        `uvm_error(get_name(), "Data record prefix is required")
        return;
      end
      if ((sram_index >= cfg.sram_count) ||
          (input_values.size() == 0) ||
          (input_values.size() != expected_values.size()) ||
          (start_address >= sram_capacity_words(sram_index)) ||
          ((start_address + input_values.size()) >
           sram_capacity_words(sram_index))) begin
        `uvm_error(get_name(), "Data record range is invalid")
        return;
      end
      failure_count = 0;
      total_record_words = 0;
      end_address = start_address + input_values.size() - 1;
      for (bank_index = 0; bank_index < cfg.bank_count; bank_index++) begin
        create_bank_record(record_prefix, bank_index, record_fd, file_name);
        if (record_fd == 0)
          return;
        apply_target_config(sram_index, bank_index);
        bank_capacity = cfg.capacity;
        bank_record_words = 0;
        for (row_address = 0; row_address < bank_capacity; row_address++) begin
          local_address = bank_row_to_logical_address(sram_index, bank_index,
                                                      row_address);
          if ((local_address >= start_address) &&
              (local_address <= end_address)) begin
            value_offset = local_address - start_address;
            byte_address = sram_byte_address(sram_index, local_address);
            if (compare_enable) begin
              actual_value = '0;
              read_success = backdoor.read_word(row_address, actual_value);
              if (!read_success ||
                  (actual_value !== expected_values[value_offset]))
                failure_count++;
              $fdisplay(record_fd,
                        "%0d %0d 0x%08h %0d %0d 0x%0h 0x%0h 0x%0h %s",
                        sram_index, local_address, byte_address, bank_index,
                        row_address, input_values[value_offset],
                        expected_values[value_offset], actual_value,
                        (read_success &&
                         (actual_value === expected_values[value_offset])) ?
                          "PASS" : "FAIL");
            end
            else begin
              $fdisplay(record_fd,
                        "%0d %0d 0x%08h %0d %0d 0x%0h 0x%0h NOT_CHECKED SKIP",
                        sram_index, local_address, byte_address, bank_index,
                        row_address, input_values[value_offset],
                        expected_values[value_offset]);
            end
            bank_record_words++;
            total_record_words++;
          end
        end
        $fclose(record_fd);
        $display("BANK_DATA_RECORD_READY file=%s sram=%0d bank=%0d rows=%0d compare=%0d",
                 file_name, sram_index, bank_index, bank_record_words,
                 compare_enable);
      end
      if (total_record_words != input_values.size()) begin
        `uvm_error(get_name(),
          $sformatf("Bank records contain %0d words; expected %0d",
                    total_record_words, input_values.size()))
        return;
      end
      $display("BANK_DATA_RECORD_SET_READY prefix=%s sram=%0d local_start=%0d words=%0d banks=%0d compare=%0d failures=%0d",
               record_prefix, sram_index, start_address,
               input_values.size(), cfg.bank_count, compare_enable,
               failure_count);
      if (failure_count != 0) begin
        `uvm_error(get_name(),
          $sformatf("Data record found %0d SRAM mismatches", failure_count))
        return;
      end
      success = 1'b1;
    endtask

    protected function bit deposit_sram_word(
      input int unsigned sram_index,
      input int unsigned local_address,
      input uvm_hdl_data_t value
    );
      int unsigned bank_index;
      int unsigned row_address;

      if (local_address >= sram_capacity_words(sram_index)) begin
        `uvm_error(get_name(),
          $sformatf("SRAM %0d local word address %0d is outside memory",
                    sram_index, local_address))
        return 1'b0;
      end
      bank_index = interleave_bank(sram_index, local_address);
      row_address = interleave_row(sram_index, local_address);
      apply_target_config(sram_index, bank_index);
      return backdoor.deposit_word(row_address, value);
    endfunction

    protected function bit load_sram_file(
      input int unsigned sram_index,
      input string file_name,
      ref uvm_hdl_data_t values[$],
      input int unsigned max_word_count,
      input int unsigned exact_word_count = 0
    );
      apply_target_config(sram_index, 0);
      return backdoor.load_hex_file(file_name, values, max_word_count,
                                    exact_word_count);
    endfunction

    protected function bit load_bank_file(
      input int unsigned sram_index,
      input int unsigned bank_index,
      input string file_name,
      ref uvm_hdl_data_t values[$],
      input int unsigned max_word_count,
      input int unsigned exact_word_count = 0
    );
      if ((sram_index >= cfg.sram_count) ||
          (bank_index >= cfg.bank_count)) begin
        `uvm_error(get_name(), "Bank file target is invalid")
        return 1'b0;
      end
      apply_target_config(sram_index, bank_index);
      return backdoor.load_hex_file(file_name, values, max_word_count,
                                    exact_word_count);
    endfunction

    protected task initialize_bank_file(
      input int unsigned sram_index,
      input int unsigned bank_index,
      input string file_name,
      input int unsigned start_row,
      ref uvm_hdl_data_t values[$],
      output bit success
    );
      int unsigned failure_count;
      time         start_time;

      success = 1'b0;
      values.delete();
      if (!validate_context())
        return;
      if ((sram_index >= cfg.sram_count) ||
          (bank_index >= cfg.bank_count)) begin
        `uvm_error(get_name(), "Bank file target is invalid")
        return;
      end
      apply_target_config(sram_index, bank_index);
      if (start_row >= cfg.capacity) begin
        `uvm_error(get_name(), "Bank initialization start row is invalid")
        return;
      end
      if (!load_bank_file(sram_index, bank_index, file_name, values,
                          cfg.capacity - start_row))
        return;
      start_time = $time;
      failure_count = 0;
      foreach (values[offset]) begin
        apply_target_config(sram_index, bank_index);
        if (!backdoor.deposit_word(start_row + offset, values[offset]))
          failure_count++;
      end
      if ((failure_count != 0) || ($time != start_time)) begin
        `uvm_error(get_name(), "Physical bank file initialization failed")
        return;
      end
      $display("MEMORY_BACKDOOR_BANK_FILE_INIT_ZERO_TIME_PASS sram=%0d bank=%0d start_row=%0d words=%0d file=%s time=%0d ns",
               sram_index, bank_index, start_row, values.size(), file_name,
               $rtoi($realtime / 1ns));
      success = 1'b1;
    endtask

    protected task append_bank_file_record(
      input int record_fd,
      input int unsigned sram_index,
      input int unsigned bank_index,
      input int unsigned start_row,
      ref uvm_hdl_data_t input_values[$],
      input bit compare_enable,
      output int unsigned failure_count
    );
      int unsigned     local_address;
      int unsigned     row_address;
      longint unsigned byte_address;
      bit              read_success;
      uvm_hdl_data_t   actual_value;

      failure_count = 0;
      foreach (input_values[offset]) begin
        row_address = start_row + offset;
        local_address = bank_row_to_logical_address(sram_index, bank_index,
                                                    row_address);
        byte_address = sram_byte_address(sram_index, local_address);
        actual_value = '0;
        read_success = 1'b0;
        if (compare_enable) begin
          apply_target_config(sram_index, bank_index);
          read_success = backdoor.read_word(row_address, actual_value);
          if (!read_success || (actual_value !== input_values[offset]))
            failure_count++;
          $fdisplay(record_fd,
                    "%0d %0d 0x%08h %0d %0d 0x%0h 0x%0h 0x%0h %s",
                    sram_index, local_address, byte_address, bank_index,
                    row_address, input_values[offset], input_values[offset],
                    actual_value,
                    (read_success &&
                     (actual_value === input_values[offset])) ?
                      "PASS" : "FAIL");
        end
        else begin
          $fdisplay(record_fd,
                    "%0d %0d 0x%08h %0d %0d 0x%0h 0x%0h NOT_CHECKED SKIP",
                    sram_index, local_address, byte_address, bank_index,
                    row_address, input_values[offset], input_values[offset]);
        end
      end
    endtask

    protected task initialize_interleaved(
      input int unsigned sram_index,
      input memory_backdoor_init_e mode,
      input int unsigned start_address,
      input int unsigned end_address,
      input uvm_hdl_data_t random_min,
      input uvm_hdl_data_t random_max,
      input string random_dump_file,
      output bit success
    );
      int unsigned               effective_end;
      int unsigned               word_count;
      int unsigned               failure_count;
      int                        dump_fd;
      time                       start_time;
      uvm_hdl_data_t             value;
      memory_backdoor_randomizer rng;

      success = 1'b0;
      if (!validate_context())
        return;
      if ((sram_index >= cfg.sram_count) ||
          (start_address >= sram_capacity_words(sram_index))) begin
        `uvm_error(get_name(), "Invalid SRAM or initialization start address")
        return;
      end

      effective_end = end_address;
      if (effective_end == MEM_BKDR_ADDRESS_AUTO)
        effective_end = sram_capacity_words(sram_index) - 1;
      if ((effective_end >= sram_capacity_words(sram_index)) ||
          (effective_end < start_address)) begin
        `uvm_error(get_name(), "Invalid SRAM-local initialization range")
        return;
      end

      start_time = $time;
      failure_count = 0;
      dump_fd = 0;
      case (mode)
        MEM_BKDR_INIT_ZERO: begin
          word_count = effective_end - start_address + 1;
          for (int unsigned offset = 0; offset < word_count; offset++)
            if (!deposit_sram_word(sram_index, start_address + offset, '0))
              failure_count++;
        end

        MEM_BKDR_INIT_RANDOM: begin
          apply_target_config(sram_index, 0);
          if ((random_min > random_max) ||
              ((random_min & ~backdoor.get_width_mask()) != '0) ||
              ((random_max & ~backdoor.get_width_mask()) != '0)) begin
            `uvm_error(get_name(), "Random range is invalid for access width")
            return;
          end
          if (random_dump_file != "") begin
            dump_fd = $fopen(random_dump_file, "w");
            if (dump_fd == 0) begin
              `uvm_error(get_name(),
                $sformatf("Cannot create random dump '%s'", random_dump_file))
              return;
            end
          end
          rng = new();
          rng.min_value = random_min;
          rng.max_value = random_max;
          rng.srandom(base_random_seed + sram_index);
          word_count = effective_end - start_address + 1;
          for (int unsigned offset = 0; offset < word_count; offset++) begin
            if (!rng.randomize()) begin
              `uvm_error(get_name(),
                $sformatf("Randomization failed at SRAM %0d address %0d",
                          sram_index, start_address + offset))
              failure_count++;
            end
            else begin
              value = rng.value & backdoor.get_width_mask();
              if (dump_fd != 0)
                $fdisplay(dump_fd, "%0h", value);
              if (!deposit_sram_word(sram_index, start_address + offset, value))
                failure_count++;
            end
          end
          if (dump_fd != 0)
            $fclose(dump_fd);
        end

        default: begin
          `uvm_error(get_name(), "Unsupported initialization mode")
          return;
        end
      endcase

      if (failure_count != 0) begin
        `uvm_error(get_name(),
          $sformatf("SRAM %0d initialization has %0d failed deposits",
                    sram_index, failure_count))
        return;
      end
      if ($time != start_time) begin
        `uvm_error(get_name(), "Backdoor initialization advanced simulation time")
        return;
      end
      $display("MEMORY_BACKDOOR_INIT_ZERO_TIME_PASS sram=%0d mode=%0d local_start=%0d words=%0d banks=%0d address_interleave=%0d interleave_words=%0d time=%0d ns",
               sram_index, mode, start_address, word_count, cfg.bank_count,
               cfg.address_interleave, cfg.interleave_granularity_words,
               $rtoi($realtime / 1ns));
      success = 1'b1;
    endtask

    protected function string operation_name(
      input memory_backdoor_operation_e operation
    );
      case (operation)
        MEMORY_OPERATION_FILE_INIT:   return "file_init";
        MEMORY_OPERATION_ZERO_INIT:   return "zero_init";
        MEMORY_OPERATION_RANDOM_INIT: return "random_init";
        MEMORY_OPERATION_REF_CHECK:   return "ref_check";
        MEMORY_OPERATION_FILE_CHECK:  return "file_check";
        default:                      return "unknown";
      endcase
    endfunction

    protected function string request_bank_file(
      input memory_backdoor_operation_request request,
      input int unsigned bank_index
    );
      case (bank_index)
        0: return project_file(request.bank0_file);
        1: return project_file(request.bank1_file);
        2: return project_file(request.bank2_file);
        3: return project_file(request.bank3_file);
        default: return "";
      endcase
    endfunction

    protected function int unsigned request_bank_start_row(
      input memory_backdoor_operation_request request,
      input int unsigned bank_index
    );
      case (bank_index)
        0: return request.bank0_start_row;
        1: return request.bank1_start_row;
        2: return request.bank2_start_row;
        3: return request.bank3_start_row;
        default: return 0;
      endcase
    endfunction

    protected function bit write_array_file(
      input string file_name,
      input string marker_prefix,
      input string data_kind,
      ref uvm_hdl_data_t values[$]
    );
      int file_descriptor;
      file_descriptor = $fopen(file_name, "w");
      if (file_descriptor == 0) begin
        `uvm_error(get_name(),
          $sformatf("Cannot create check data file '%s'", file_name))
        return 1'b0;
      end
      $fdisplay(file_descriptor, "LOGICAL_WORD_ADDRESS DATA");
      foreach (values[address])
        $fdisplay(file_descriptor, "%0d 0x%0h", address, values[address]);
      $fclose(file_descriptor);
      $display("%s_DATA_FILE_READY kind=%s file=%s words=%0d",
               marker_prefix, data_kind, file_name, values.size());
      return 1'b1;
    endfunction

    // Passively sample the real DUT input interface. tb_top is the only
    // driver; this task only uses uvm_hdl_read and builds an address-ordered
    // snapshot outside the DUT for Reference consumption and reporting.
    protected task capture_dut_input_interface(
      input string testcase_name,
      input int unsigned expected_words,
      input int unsigned address_space_words,
      input uvm_hdl_data_t data_mask,
      ref uvm_hdl_data_t captured_values[$],
      output bit success
    );
      uvm_hdl_data_t raw_valid;
      uvm_hdl_data_t raw_address;
      uvm_hdl_data_t raw_data;
      uvm_hdl_data_t address_mask;
      uvm_hdl_data_t captured_by_address[];
      bit            seen[];
      int unsigned   sampled_address;
      int unsigned   captured_count;
      int unsigned   cycle_count;
      int unsigned   timeout_cycles;

      success = 1'b0;
      captured_values.delete();
      if ((backdoor == null) || (expected_words == 0) ||
          (address_space_words == 0) ||
          (expected_words > address_space_words)) begin
        `uvm_error(get_name(), "Invalid DUT input capture context")
        return;
      end

      captured_by_address = new[expected_words];
      seen = new[expected_words];
      captured_count = 0;
      cycle_count = 0;
      timeout_cycles = (expected_words * 2) + 64;
      address_mask = '0;
      for (int unsigned bit_index = 0;
           bit_index < ((address_space_words > 1) ?
                        $clog2(address_space_words) : 1);
           bit_index++)
        address_mask[bit_index] = 1'b1;

      // Release the independent TB driver only after this monitor is armed.
      ->dut_input_capture_ready_event;
      while (captured_count < expected_words) begin
        @(dut_input_sample_event);
        cycle_count++;
        if (cycle_count > timeout_cycles) begin
          `uvm_error(get_name(),
            $sformatf("DUT input capture timed out after %0d cycles; captured %0d/%0d words",
                      cycle_count, captured_count, expected_words))
          return;
        end
        if (!backdoor.read_hdl_path(cfg.dut_input_valid_path, raw_valid) ||
            $isunknown(raw_valid[0])) begin
          `uvm_error(get_name(), "DUT input valid read failed or contains X/Z")
          return;
        end
        if (raw_valid[0] === 1'b1) begin
          if (!backdoor.read_hdl_path(cfg.dut_input_address_path,
                                      raw_address) ||
              $isunknown(raw_address & address_mask)) begin
            `uvm_error(get_name(),
              "DUT input address read failed or contains X/Z")
            return;
          end
          sampled_address = int'(raw_address & address_mask);
          if (sampled_address >= expected_words) begin
            `uvm_error(get_name(),
              $sformatf("DUT input address %0d is outside 0..%0d",
                        sampled_address, expected_words - 1))
            return;
          end
          if (seen[sampled_address]) begin
            `uvm_error(get_name(),
              $sformatf("Duplicate DUT input address %0d", sampled_address))
            return;
          end
          if (!backdoor.read_hdl_path(cfg.dut_input_data_path, raw_data) ||
              $isunknown(raw_data & data_mask)) begin
            `uvm_error(get_name(),
              $sformatf("DUT input data read failed at address %0d",
                        sampled_address))
            return;
          end
          captured_by_address[sampled_address] = raw_data & data_mask;
          seen[sampled_address] = 1'b1;
          captured_count++;
        end
      end

      // Require one quiet sample after the final transaction. This closes the
      // stream before Reference/Scoreboard processing and rejects extra data.
      @(dut_input_sample_event);
      if (!backdoor.read_hdl_path(cfg.dut_input_valid_path, raw_valid) ||
          $isunknown(raw_valid[0]) || (raw_valid[0] !== 1'b0)) begin
        `uvm_error(get_name(),
          "DUT input valid did not deassert after the expected input stream")
        return;
      end

      for (int unsigned address = 0; address < expected_words; address++) begin
        if (!seen[address]) begin
          `uvm_error(get_name(),
            $sformatf("DUT input address %0d was not captured", address))
          captured_values.delete();
          return;
        end
        captured_values.push_back(captured_by_address[address]);
      end
      $display("MEMORY_DUT_INPUT_INTERFACE_CAPTURE_READY testcase=%s words=%0d source=uvm_hdl_read data_path=%s address_path=%s valid_path=%s",
               testcase_name, captured_values.size(), cfg.dut_input_data_path,
               cfg.dut_input_address_path, cfg.dut_input_valid_path);
      success = 1'b1;
    endtask

    protected task read_dut_result_array(
      input int unsigned word_count,
      input uvm_hdl_data_t data_mask,
      ref uvm_hdl_data_t result_values[$],
      output bit success
    );
      string         hdl_path;
      uvm_hdl_data_t read_value;
      uvm_hdl_data_t read_valid;

      success = 1'b0;
      result_values.delete();
      for (int unsigned address = 0; address < word_count; address++) begin
        hdl_path = $sformatf("%s[%0d]", cfg.dut_output_valid_path,
                             address);
        if (!backdoor.read_hdl_path(hdl_path, read_valid) ||
            $isunknown(read_valid[0]) || (read_valid[0] !== 1'b1)) begin
          `uvm_error(get_name(),
            $sformatf("DUT output valid is missing at address %0d", address))
          return;
        end
        hdl_path = $sformatf("%s[%0d]", cfg.dut_output_data_path,
                             address);
        if (!backdoor.read_hdl_path(hdl_path, read_value) ||
            $isunknown(read_value & data_mask)) begin
          `uvm_error(get_name(),
            $sformatf("DUT output read failed at address %0d", address))
          return;
        end
        result_values.push_back(read_value & data_mask);
      end
      success = 1'b1;
    endtask

    protected task run_file_init(
      input memory_backdoor_operation_request request,
      output bit success
    );
      bit            operation_success;
      int            record_fd;
      int unsigned   bank_failures;
      int unsigned   failure_count;
      int unsigned   total_words;
      string         record_file;
      uvm_hdl_data_t values[$];

      success = 1'b0;
      record_fd = 0;
      failure_count = 0;
      total_words = 0;
      if ((cfg.sram_count != request.expected_sram_count) ||
          (cfg.bank_count != 4)) begin
        `uvm_error(get_name(), "file_init expects one SRAM with four banks")
        return;
      end
      if (cfg.data_record_file == "") begin
        `uvm_error(get_name(), "MEM_BKDR_DATA_RECORD_PREFIX is required")
        return;
      end
      for (int unsigned bank_index = 0;
           bank_index < cfg.bank_count; bank_index++) begin
        initialize_bank_file(request.sram_index, bank_index,
                             request_bank_file(request, bank_index),
                             request_bank_start_row(request, bank_index),
                             values, operation_success);
        if (!operation_success)
          return;
        create_bank_record(cfg.data_record_file, bank_index, record_fd,
                           record_file);
        if (record_fd == 0)
          return;
        append_bank_file_record(
          record_fd, request.sram_index, bank_index,
          request_bank_start_row(request, bank_index), values,
          request.compare_enable, bank_failures);
        $fclose(record_fd);
        $display("FILE_INIT_BANK_RECORD_READY file=%s bank=%0d start_row=%0d words=%0d compare=%0d",
                 record_file, bank_index,
                 request_bank_start_row(request, bank_index), values.size(),
                 request.compare_enable);
        failure_count += bank_failures;
        total_words += values.size();
      end
      if (failure_count != 0) begin
        `uvm_error(get_name(),
          $sformatf("file_init readback found %0d mismatches", failure_count))
        return;
      end
      $display("FILE_INIT_PASS srams=1 banks=4 words=%0d compare=%0d record_prefix=%s mapping=physical_bank_file",
               total_words, request.compare_enable, cfg.data_record_file);
      success = 1'b1;
    endtask

    protected task run_zero_init(
      input memory_backdoor_operation_request request,
      output bit success
    );
      bit           operation_success;
      int unsigned effective_end_address;
      uvm_hdl_data_t input_values[$];
      uvm_hdl_data_t expected_values[$];

      success = 1'b0;
      if (cfg.data_record_file == "") begin
        `uvm_error(get_name(), "MEM_BKDR_DATA_RECORD_PREFIX is required")
        return;
      end
      for (int unsigned sram_index = 0;
           sram_index < cfg.sram_count; sram_index++) begin
        input_values.delete();
        expected_values.delete();
        initialize_interleaved(sram_index, MEM_BKDR_INIT_ZERO,
                               request.start_address, request.end_address,
                               '0, '0, "", operation_success);
        if (!operation_success)
          return;
        effective_end_address = request.end_address;
        if (effective_end_address == MEM_BKDR_ADDRESS_AUTO)
          effective_end_address = sram_capacity_words(sram_index) - 1;
        for (int unsigned local_address = request.start_address;
             local_address <= effective_end_address; local_address++) begin
          input_values.push_back('0);
          expected_values.push_back('0);
        end
        write_sram_bank_records(cfg.data_record_file, sram_index,
                                request.start_address, input_values,
                                expected_values, request.compare_enable,
                                operation_success);
        if (!operation_success)
          return;
      end
      $display("ZERO_INIT_PASS srams=%0d compare=%0d record_prefix=%s address_interleave=%0d",
               cfg.sram_count, request.compare_enable, cfg.data_record_file,
               cfg.address_interleave);
      success = 1'b1;
    endtask

    protected task run_random_init(
      input memory_backdoor_operation_request request,
      output bit success
    );
      bit           operation_success;
      int unsigned effective_end_address;
      int unsigned record_word_count;
      string       dump_file;
      uvm_hdl_data_t input_values[$];
      uvm_hdl_data_t expected_values[$];

      success = 1'b0;
      if (cfg.random_dump_file == "") begin
        `uvm_error(get_name(), "MEM_BKDR_RANDOM_DUMP_FILE prefix is required")
        return;
      end
      if (cfg.data_record_file == "") begin
        `uvm_error(get_name(), "MEM_BKDR_DATA_RECORD_PREFIX is required")
        return;
      end
      for (int unsigned sram_index = 0;
           sram_index < cfg.sram_count; sram_index++) begin
        input_values.delete();
        expected_values.delete();
        dump_file = sram_data_file(cfg.random_dump_file, sram_index, "hex");
        initialize_interleaved(
          sram_index, MEM_BKDR_INIT_RANDOM, request.start_address,
          request.end_address, request.random_min,
          request.use_full_data_width ? sram_data_width_mask(sram_index) :
                                        request.random_max,
          dump_file, operation_success);
        if (!operation_success)
          return;
        effective_end_address = request.end_address;
        if (effective_end_address == MEM_BKDR_ADDRESS_AUTO)
          effective_end_address = sram_capacity_words(sram_index) - 1;
        record_word_count = effective_end_address - request.start_address + 1;
        if (!load_sram_file(sram_index, dump_file, input_values,
                            record_word_count, record_word_count))
          return;
        foreach (input_values[offset])
          expected_values.push_back(input_values[offset]);
        write_sram_bank_records(cfg.data_record_file, sram_index,
                                request.start_address, input_values,
                                expected_values, request.compare_enable,
                                operation_success);
        if (!operation_success)
          return;
      end
      $display("RANDOM_INIT_PASS srams=%0d compare=%0d file_prefix=%s record_prefix=%s base_seed=%0d",
               cfg.sram_count, request.compare_enable, cfg.random_dump_file,
               cfg.data_record_file, base_random_seed);
      success = 1'b1;
    endtask

    protected task run_check(
      input memory_backdoor_operation_request request,
      output bit success
    );
      bit                        is_ref_check;
      bit                        operation_success;
      int unsigned               word_count;
      int unsigned               data_width;
      int unsigned               mismatch_count;
      uvm_hdl_data_t             data_mask;
      uvm_hdl_data_t             dut_input_array[$];
      uvm_hdl_data_t             dut_result_array[$];
      uvm_hdl_data_t             expected_result_array[$];
      string                     golden_file;
      string                     dut_input_file;
      string                     expected_output_file;
      string                     dut_output_file;
      string                     compare_file;
      string                     expected_source;
      string                     expected_data_kind;
      string                     check_mode_name;
      string                     marker_prefix;

      success = 1'b0;
      is_ref_check = (request.operation == MEMORY_OPERATION_REF_CHECK);
      if (is_ref_check)
        marker_prefix = "REF_CHECK";
      else
        marker_prefix = "FILE_CHECK";
      if ((cfg.sram_count != 1) || (request.sram_index >= cfg.sram_count)) begin
        `uvm_error(get_name(), "check operation requires exactly one SRAM")
        $display("TEST_FAIL testcase=%s reason=invalid_topology",
                 request.testcase_name);
        return;
      end
      word_count = request.check_word_count;
      if (word_count == MEM_BKDR_ADDRESS_AUTO)
        word_count = sram_capacity_words(request.sram_index);
      data_width = targets[request.sram_index * cfg.bank_count].access_width;
      data_mask = sram_data_width_mask(request.sram_index);
      if ((word_count == 0) ||
          (word_count > sram_capacity_words(request.sram_index))) begin
        `uvm_error(get_name(),
          $sformatf("check word count %0d is outside 1..%0d",
                    word_count, sram_capacity_words(request.sram_index)))
        $display("TEST_FAIL testcase=%s reason=invalid_check_word_count",
                 request.testcase_name);
        return;
      end
      if (cfg.dut_input_word_count != word_count) begin
        `uvm_error(get_name(),
          $sformatf("TB input word count %0d does not match testcase request %0d",
                    cfg.dut_input_word_count, word_count))
        $display("TEST_FAIL testcase=%s reason=check_word_count_mismatch",
                 request.testcase_name);
        return;
      end
      if (cfg.data_record_file == "") begin
        `uvm_error(get_name(), "check data record prefix is required")
        $display("TEST_FAIL testcase=%s reason=missing_data_prefix",
                 request.testcase_name);
        return;
      end
      if ((cfg.dut_input_data_path == "") ||
          (cfg.dut_input_address_path == "") ||
          (cfg.dut_input_valid_path == "") ||
          (cfg.dut_output_data_path == "") ||
          (cfg.dut_output_valid_path == "")) begin
        `uvm_error(get_name(), "DUT input/output HDL paths are not configured")
        $display("TEST_FAIL testcase=%s reason=missing_dut_paths",
                 request.testcase_name);
        return;
      end
      dut_input_file =
        $sformatf("%s_dut_input_interface.txt", cfg.data_record_file);
      dut_output_file =
        $sformatf("%s_dut_output_backdoor.txt", cfg.data_record_file);
      compare_file =
        $sformatf("%s_dut_reference_compare.txt", cfg.data_record_file);

      capture_dut_input_interface(
                                  request.testcase_name, word_count,
                                  sram_capacity_words(request.sram_index),
                                  data_mask, dut_input_array,
                                  operation_success);
      if (!operation_success || (dut_input_array.size() != word_count)) begin
        $display("TEST_FAIL testcase=%s reason=dut_input_interface_capture",
                 request.testcase_name);
        return;
      end
      if (is_ref_check)
        $display("REF_CHECK_DUT_INPUT_INTERFACE_ARRAY_READY words=%0d data_path=%s address_path=%s valid_path=%s",
                 dut_input_array.size(), cfg.dut_input_data_path,
                 cfg.dut_input_address_path, cfg.dut_input_valid_path);
      else
        $display("FILE_CHECK_DUT_INPUT_INTERFACE_ARRAY_READY words=%0d data_path=%s address_path=%s valid_path=%s",
                 dut_input_array.size(), cfg.dut_input_data_path,
                 cfg.dut_input_address_path, cfg.dut_input_valid_path);

      read_dut_result_array(word_count, data_mask, dut_result_array,
                            operation_success);
      if (!operation_success) begin
        $display("TEST_FAIL testcase=%s reason=dut_output_backdoor",
                 request.testcase_name);
        return;
      end
      if (is_ref_check)
        $display("REF_CHECK_DUT_RESULT_BACKDOOR_ARRAY_READY words=%0d path=%s",
                 dut_result_array.size(), cfg.dut_output_data_path);
      else
        $display("FILE_CHECK_DUT_RESULT_BACKDOOR_ARRAY_READY words=%0d path=%s",
                 dut_result_array.size(), cfg.dut_output_data_path);

      case (request.check_mode)
        MEMORY_CHECK_REFERENCE: begin
          check_mode_name = "REFERENCE";
          expected_source = "reference_component";
          expected_data_kind = "reference_output";
          expected_output_file =
            $sformatf("%s_reference_output.txt", cfg.data_record_file);
          if ((reference_component == null) ||
              !reference_component.calculate_array(
                request.testcase_name, dut_input_array, data_mask,
                expected_result_array) ||
              (expected_result_array.size() != word_count)) begin
            $display("TEST_FAIL testcase=%s reason=reference_component",
                     request.testcase_name);
            return;
          end
        end
        MEMORY_CHECK_FILE: begin
          check_mode_name = "FILE";
          expected_source = "golden_file";
          expected_data_kind = "golden_data";
          golden_file = project_file(request.golden_file);
          expected_output_file =
            $sformatf("%s_golden_data.txt", cfg.data_record_file);
          if (!load_indexed_array_file(golden_file, word_count, data_width,
                                       data_mask, expected_result_array)) begin
            $display("TEST_FAIL testcase=%s reason=golden_file",
                     request.testcase_name);
            return;
          end
          if (is_ref_check)
            $display("REF_CHECK_GOLDEN_FILE_LOAD_PASS file=%s words=%0d",
                     golden_file, expected_result_array.size());
          else
            $display("FILE_CHECK_GOLDEN_FILE_LOAD_PASS file=%s words=%0d",
                     golden_file, expected_result_array.size());
        end
        default: begin
          `uvm_error(get_name(), "Unsupported check mode")
          $display("TEST_FAIL testcase=%s reason=check_mode",
                   request.testcase_name);
          return;
        end
      endcase

      if (is_ref_check)
        $display("REF_CHECK_MODE_SELECTED mode=%s expected_source=%s",
                 check_mode_name, expected_source);
      else
        $display("FILE_CHECK_MODE_SELECTED mode=%s expected_source=%s",
                 check_mode_name, expected_source);

      if (!write_array_file(dut_input_file, marker_prefix,
                            "dut_input_interface", dut_input_array) ||
          !write_array_file(expected_output_file, marker_prefix,
                            expected_data_kind, expected_result_array) ||
          !write_array_file(dut_output_file, marker_prefix,
                            "dut_output_backdoor", dut_result_array)) begin
        $display("TEST_FAIL testcase=%s reason=data_file",
                 request.testcase_name);
        return;
      end

      if ((scoreboard_component == null) ||
          !scoreboard_component.compare_arrays(
            request.testcase_name, expected_result_array, dut_result_array,
            word_count, compare_file, expected_source, mismatch_count)) begin
        $display("TEST_FAIL testcase=%s mismatches=%0d",
                 request.testcase_name, mismatch_count);
        return;
      end
      if (is_ref_check)
        $display("TEST_PASS testcase=ref_check words=%0d mismatches=0 operation=pass_through expected_source=%s",
                 word_count, expected_source);
      else
        $display("TEST_PASS testcase=file_check words=%0d mismatches=0 expected_source=%s",
                 word_count, expected_source);
      success = 1'b1;
    endtask

    task execute(
      input memory_backdoor_operation_request request,
      output bit success
    );
      success = 1'b0;
      if (request == null) begin
        `uvm_error(get_name(), "Operation request is null")
        return;
      end
      if (busy) begin
        `uvm_error(get_name(), "Operation component is already executing")
        return;
      end
      if (request.testcase_name == "") begin
        `uvm_error(get_name(), "Operation testcase_name must not be empty")
        return;
      end
      if (!validate_context())
        return;

      busy = 1'b1;
      $display("MEMORY_BACKDOOR_OPERATION_SELECTED testcase=%s operation=%s",
               request.testcase_name, operation_name(request.operation));
      case (request.operation)
        MEMORY_OPERATION_FILE_INIT:
          run_file_init(request, success);
        MEMORY_OPERATION_ZERO_INIT:
          run_zero_init(request, success);
        MEMORY_OPERATION_RANDOM_INIT:
          run_random_init(request, success);
        MEMORY_OPERATION_REF_CHECK,
        MEMORY_OPERATION_FILE_CHECK:
          run_check(request, success);
        default: begin
          `uvm_error(get_name(), "Unsupported memory operation")
          success = 1'b0;
        end
      endcase
      busy = 1'b0;
    endtask

  endclass

  // Common request adapter used by the five small testcase classes. It owns
  // no memory/check behavior; that behavior remains in the component above.
  virtual class memory_backdoor_testcase_base;
    protected memory_backdoor_operation_component operation_component;

    function void configure(
      input memory_backdoor_operation_component operation_component
    );
      this.operation_component = operation_component;
    endfunction

    virtual function string get_name();
      return "memory_backdoor_testcase_base";
    endfunction

    protected task execute_request(
      input memory_backdoor_operation_request request,
      output bit success
    );
      success = 1'b0;
      if (operation_component == null) begin
        `uvm_error(get_name(), "Memory backdoor operation component is null")
        return;
      end
      operation_component.execute(request, success);
    endtask

    pure virtual task run(output bit success);
  endclass

endpackage
