`ifndef MEMORY_TESTCASE_PACKAGE
  `define MEMORY_TESTCASE_PACKAGE file_init_testcase_pkg
`endif

`ifndef MEMORY_TESTCASE_CLASS
  `define MEMORY_TESTCASE_CLASS file_init_testcase
`endif

module tb_top;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_reference_component_pkg::*;
  import memory_scoreboard_component_pkg::*;
  import memory_backdoor_operation_pkg::*;
  import `MEMORY_TESTCASE_PACKAGE::*;

  logic rst_n;
  logic clk;
  localparam int unsigned DUT_INPUT_WORD_COUNT =
    sram_geometry_pkg::sram_words(0);
  localparam int unsigned DUT_INPUT_ADDRESS_WIDTH =
    (DUT_INPUT_WORD_COUNT > 1) ? $clog2(DUT_INPUT_WORD_COUNT) : 1;
  localparam int unsigned DUT_INPUT_DATA_WIDTH =
    sram_geometry_pkg::SRAM_DATA_WIDTH;

  logic                           dut_input_valid;
  logic [DUT_INPUT_ADDRESS_WIDTH-1:0] dut_input_word_address;
  logic [DUT_INPUT_DATA_WIDTH-1:0] dut_input_data;
  event dut_input_capture_ready_event;
  event dut_input_sample_event;

  function automatic bit tb_is_hex_string(input string value);
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

  function automatic bit load_tb_input_file(
    input string file_name,
    input int unsigned expected_words,
    input int unsigned data_width,
    input uvm_hdl_data_t data_mask,
    ref uvm_hdl_data_t values[$]
  );
    int            file_descriptor;
    int            scan_count;
    int unsigned   logical_address;
    int unsigned   expected_address;
    string         line;
    string         first_token;
    string         second_token;
    string         extra_token;
    string         hex_token;
    uvm_hdl_data_t value;

    values.delete();
    file_descriptor = $fopen(file_name, "r");
    if (file_descriptor == 0)
      return 1'b0;
    if (!$fgets(line, file_descriptor)) begin
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
        $fclose(file_descriptor);
        return 1'b0;
      end
      hex_token = second_token.substr(2, second_token.len() - 1);
      if (!tb_is_hex_string(hex_token) ||
          (hex_token.len() > ((data_width + 3) / 4)) ||
          ($sscanf(hex_token, "%h", value) != 1) ||
          $isunknown(value & data_mask) ||
          ((value & ~data_mask) !== '0)) begin
        $fclose(file_descriptor);
        return 1'b0;
      end
      values.push_back(value & data_mask);
      expected_address++;
    end
    $fclose(file_descriptor);
    if (values.size() != expected_words) begin
      values.delete();
      return 1'b0;
    end
    return 1'b1;
  endfunction

  function automatic void split_csv(
    input string value_list,
    ref string values[$]
  );
    int start_index;
    values.delete();
    start_index = 0;
    for (int char_index = 0; char_index <= value_list.len(); char_index++) begin
      if ((char_index == value_list.len()) ||
          (value_list.getc(char_index) == 8'h2c)) begin
        if (char_index > start_index)
          values.push_back(value_list.substr(start_index, char_index - 1));
        start_index = char_index + 1;
      end
    end
  endfunction

  function automatic void split_target_specs(
    input string target_list,
    ref string paths[$],
    ref int unsigned capacities[$],
    ref int unsigned access_widths[$]
  );
    int item_start;
    int first_colon;
    int second_colon;
    string item;
    string capacity_text;
    string width_text;

    paths.delete();
    capacities.delete();
    access_widths.delete();
    item_start = 0;
    for (int char_index = 0; char_index <= target_list.len(); char_index++) begin
      if ((char_index == target_list.len()) ||
          (target_list.getc(char_index) == 8'h2c)) begin
        if (char_index <= item_start)
          return;
        item = target_list.substr(item_start, char_index - 1);
        first_colon = -1;
        second_colon = -1;
        for (int field_index = 0; field_index < item.len(); field_index++) begin
          if (item.getc(field_index) == 8'h3a) begin
            if (first_colon < 0)
              first_colon = field_index;
            else if (second_colon < 0)
              second_colon = field_index;
          end
        end
        if ((first_colon <= 0) || (second_colon <= (first_colon + 1)) ||
            (second_colon >= (item.len() - 1))) begin
          paths.delete();
          capacities.delete();
          access_widths.delete();
          return;
        end
        paths.push_back(item.substr(0, first_colon - 1));
        capacity_text = item.substr(first_colon + 1, second_colon - 1);
        width_text = item.substr(second_colon + 1, item.len() - 1);
        if ((capacity_text.atoi() == 0) || (width_text.atoi() == 0)) begin
          paths.delete();
          capacities.delete();
          access_widths.delete();
          return;
        end
        capacities.push_back(capacity_text.atoi());
        access_widths.push_back(width_text.atoi());
        item_start = char_index + 1;
      end
    end
  endfunction

  initial begin : reset_driver
    int unsigned reset_release_ns;
    reset_release_ns = 10;
    void'($value$plusargs("RESET_RELEASE_NS=%d", reset_release_ns));
    if (reset_release_ns == 0)
      $fatal(1, "RESET_RELEASE_NS must be greater than zero");
    rst_n = 1'b0;
    $display("RESET_ASSERTED");
    #(reset_release_ns * 1ns);
    rst_n = 1'b1;
    $display("RESET_DEASSERTED time=%0d ns", reset_release_ns);
  end

  initial begin : clock_driver
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  // The TB is the sole DUT-input producer. Operation only observes the DUT
  // ports after each accepting clock edge and never writes these signals.
  initial begin : external_dut_input_driver
    string                     input_mode;
    string                     input_file;
    string                     testcase_name;
    string                     source_name;
    int unsigned               random_seed;
    int unsigned               input_word_count;
    uvm_hdl_data_t             data_mask;
    uvm_hdl_data_t             input_values[$];
    memory_backdoor_randomizer rng;

    dut_input_valid = 1'b0;
    dut_input_word_address = '0;
    dut_input_data = '0;
    input_mode = "NONE";
    void'($value$plusargs("MEM_BKDR_TB_INPUT_MODE=%s", input_mode));
    input_word_count = DUT_INPUT_WORD_COUNT;
    void'($value$plusargs("MEM_BKDR_TB_INPUT_WORD_COUNT=%d",
                          input_word_count));
    if ((input_mode != "NONE") &&
        ((input_word_count == 0) ||
         (input_word_count > DUT_INPUT_WORD_COUNT)))
      $fatal(1, "MEM_BKDR_TB_INPUT_WORD_COUNT %0d is outside 1..%0d",
             input_word_count, DUT_INPUT_WORD_COUNT);

    data_mask = '0;
    for (int unsigned bit_index = 0;
         bit_index < DUT_INPUT_DATA_WIDTH; bit_index++)
      data_mask[bit_index] = 1'b1;

    if (input_mode == "RANDOM") begin
      testcase_name = "ref_check";
      source_name = "random";
      random_seed = 32'h1;
      void'($value$plusargs("MEM_BKDR_RANDOM_SEED=%d", random_seed));
      rng = new();
      rng.min_value = '0;
      rng.max_value = data_mask;
      rng.srandom(random_seed);
      for (int unsigned address = 0;
           address < input_word_count; address++) begin
        if (!rng.randomize())
          $fatal(1, "TB random DUT input generation failed at address %0d",
                 address);
        input_values.push_back(rng.value & data_mask);
      end
      $display("TB_DUT_INPUT_SOURCE_READY testcase=ref_check source=random words=%0d",
               input_values.size());
      $display("TB_DUT_INPUT_RANDOM_SEED value=%0d", random_seed);
    end
    else if (input_mode == "FILE") begin
      testcase_name = "file_check";
      source_name = "file";
      if (!$value$plusargs("MEM_BKDR_TB_INPUT_FILE=%s", input_file))
        $fatal(1, "MEM_BKDR_TB_INPUT_FILE is required in FILE mode");
      if (!load_tb_input_file(input_file, input_word_count,
                              DUT_INPUT_DATA_WIDTH, data_mask,
                              input_values))
        $fatal(1, "Cannot load TB DUT input file '%s'", input_file);
      $display("FILE_CHECK_INPUT_FILE_LOAD_PASS file=%s words=%0d",
               input_file, input_values.size());
      $display("TB_DUT_INPUT_SOURCE_READY testcase=file_check source=file words=%0d file=%s",
               input_values.size(), input_file);
    end
    else if (input_mode != "NONE") begin
      $fatal(1, "Unsupported MEM_BKDR_TB_INPUT_MODE '%s'", input_mode);
    end

    if (input_mode != "NONE") begin
      // Waiting for this event guarantees that Operation is armed before the
      // first externally driven transaction.
      @(dut_input_capture_ready_event);
      #1ps;
      foreach (input_values[address]) begin
        @(negedge clk);
        dut_input_word_address = DUT_INPUT_ADDRESS_WIDTH'(address);
        dut_input_data = input_values[address][DUT_INPUT_DATA_WIDTH-1:0];
        dut_input_valid = 1'b1;
      end
      @(negedge clk);
      dut_input_valid = 1'b0;
      $display("TB_DUT_INPUT_STREAM_DONE testcase=%s source=%s words=%0d",
               testcase_name, source_name, input_values.size());
    end
  end

  // Operation waits on this event, then reads the actual DUT input ports via
  // uvm_hdl_read. The 1ps offset places sampling after the DUT's NBA updates.
  always @(posedge clk) begin : dut_input_sample_event_driver
    #1ps;
    ->dut_input_sample_event;
  end

  dut dut (
    .clk_i                      ( clk                    ),
    .rst_ni                     ( rst_n                  ),
    .check_input_valid_i        ( dut_input_valid        ),
    .check_input_word_address_i ( dut_input_word_address ),
    .check_input_data_i         ( dut_input_data         )
  );

  initial begin : fsdb_wave_dump
    bit    fsdb_enable;
    string fsdb_file;
    fsdb_enable = 1'b1;
    void'($value$plusargs("FSDB_ENABLE=%d", fsdb_enable));
    if (!$value$plusargs("FSDB_FILE=%s", fsdb_file))
      fsdb_file = "memory_backdoor.fsdb";
    if (fsdb_enable) begin
      $fsdbDumpfile(fsdb_file);
      $fsdbDumpvars(0, tb_top);
      $fsdbDumpMDA();
      $display("FSDB_DUMP_ENABLED file=%s", fsdb_file);
    end
    else
      $display("FSDB_DUMP_DISABLED");
  end

  initial begin : run_selected_testcase
    memory_backdoor_cfg           cfg;
    memory_backdoor               backdoor;
    memory_reference_component    reference_component;
    memory_scoreboard_component   scoreboard_component;
    memory_backdoor_operation_component operation_component;
    memory_backdoor_testcase_base testcase;
    `MEMORY_TESTCASE_CLASS         selected_testcase;
    int unsigned                  sim_time_ns;
    bit                           testcase_success;
    string                        target_spec_list;
    string                        sram_index_list;
    string                        bank_index_list;
    string                        hdl_paths[$];
    int unsigned                  target_capacities[$];
    int unsigned                  target_access_widths[$];
    string                        sram_indices[$];
    string                        bank_indices[$];
    memory_backdoor_target_cfg    targets[$];
    memory_backdoor_target_cfg    target_cfg;

    sim_time_ns = 100;
    void'($value$plusargs("SIM_TIME_NS=%d", sim_time_ns));
    if (sim_time_ns == 0)
      $fatal(1, "SIM_TIME_NS must be greater than zero");

    cfg = memory_backdoor_cfg::type_id::create("cfg");
    cfg.load_from_plusargs();
    backdoor = new("backdoor", cfg);
    reference_component =
      memory_reference_component::type_id::create(
        "reference_component", null);
    if (reference_component == null)
      $fatal(1, "Cannot create shared memory Reference component");
    scoreboard_component =
      memory_scoreboard_component::type_id::create(
        "scoreboard_component", null);
    if (scoreboard_component == null)
      $fatal(1, "Cannot create shared memory Scoreboard component");
    operation_component =
      memory_backdoor_operation_component::type_id::create(
        "operation_component", null);
    if (operation_component == null)
      $fatal(1, "Cannot create memory backdoor operation component");
    if ((cfg.sram_count != sram_geometry_pkg::SRAM_COUNT) ||
        (cfg.bank_count != sram_geometry_pkg::SRAM_BANK_COUNT) ||
        (cfg.address_interleave !=
         sram_geometry_pkg::SRAM_ADDRESS_INTERLEAVE) ||
        (cfg.interleave_granularity_bytes !=
         sram_geometry_pkg::SRAM_INTERLEAVE_GRANULARITY_BYTES) ||
        (cfg.interleave_granularity_words !=
         sram_geometry_pkg::SRAM_INTERLEAVE_GRANULARITY_WORDS))
      $fatal(1, "Runtime SRAM geometry does not match compiled geometry");

    if (!$value$plusargs("MEM_BKDR_TARGET_SPECS=%s", target_spec_list))
      $fatal(1, "MEM_BKDR_TARGET_SPECS is required");
    split_target_specs(target_spec_list, hdl_paths, target_capacities,
                       target_access_widths);
    if (hdl_paths.size() == 0)
      $fatal(1, "Invalid MEM_BKDR_TARGET_SPECS '%s'", target_spec_list);

    if (!$value$plusargs("MEM_BKDR_SRAM_INDICES=%s", sram_index_list) ||
        !$value$plusargs("MEM_BKDR_BANK_INDICES=%s", bank_index_list))
      $fatal(1, "SRAM and bank index lists are required");
    split_csv(sram_index_list, sram_indices);
    split_csv(bank_index_list, bank_indices);
    if ((sram_indices.size() != hdl_paths.size()) ||
        (bank_indices.size() != hdl_paths.size()))
      $fatal(1, "Structural metadata count does not match target count");

    foreach (hdl_paths[target_index]) begin
      if (target_access_widths[target_index] !=
          sram_geometry_pkg::SRAM_DATA_WIDTH)
        $fatal(1,
          "Target data width %0d does not match compiled YAML width %0d",
          target_access_widths[target_index],
          sram_geometry_pkg::SRAM_DATA_WIDTH);
      target_cfg = new();
      target_cfg.hdl_path = hdl_paths[target_index];
      target_cfg.sram_index = sram_indices[target_index].atoi();
      target_cfg.bank_index = bank_indices[target_index].atoi();
      target_cfg.capacity = target_capacities[target_index];
      target_cfg.access_width = target_access_widths[target_index];
      targets.push_back(target_cfg);
    end

    selected_testcase = new();
    testcase = selected_testcase;
    operation_component.configure(cfg, backdoor, targets,
                                  dut_input_capture_ready_event,
                                  dut_input_sample_event,
                                  reference_component,
                                  scoreboard_component);
    testcase.configure(operation_component);
    $display("MEMORY_BACKDOOR_TOPOLOGY srams=%0d banks_per_sram=%0d targets=%0d address_interleave=%0d mapping=%s interleave_bytes=%0d interleave_words=%0d",
             cfg.sram_count, cfg.bank_count, targets.size(),
             cfg.address_interleave,
             (cfg.address_interleave != 0) ?
               "block_interleave" : "contiguous",
             cfg.interleave_granularity_bytes,
             cfg.interleave_granularity_words);
    foreach (targets[target_index]) begin
      if (cfg.address_interleave != 0)
        $display("MEMORY_BACKDOOR_TARGET index=%0d sram=%0d bank=%0d path=%s rows=%0d mapping=block_interleave first_block_word=%0d block_words=%0d block_stride=%0d width=%0d",
                 target_index, targets[target_index].sram_index,
                 targets[target_index].bank_index,
                 targets[target_index].hdl_path,
                 targets[target_index].capacity,
                 targets[target_index].bank_index *
                   cfg.interleave_granularity_words,
                 cfg.interleave_granularity_words,
                 cfg.bank_count * cfg.interleave_granularity_words,
                 targets[target_index].access_width);
      else
        $display("MEMORY_BACKDOOR_TARGET index=%0d sram=%0d bank=%0d path=%s rows=%0d mapping=contiguous logical_first=%0d logical_last=%0d width=%0d",
                 target_index, targets[target_index].sram_index,
                 targets[target_index].bank_index,
                 targets[target_index].hdl_path,
                 targets[target_index].capacity,
                 targets[target_index].bank_index *
                   targets[target_index].capacity,
                 ((targets[target_index].bank_index + 1) *
                   targets[target_index].capacity) - 1,
                 targets[target_index].access_width);
    end
    $display("MEMORY_BACKDOOR_TESTCASE_SELECTED name=%s", testcase.get_name());

    @(posedge rst_n);
    $display("MEMORY_BACKDOOR_TESTCASE_ON_RESET_RELEASE name=%s",
             testcase.get_name());
    if ($time >= (sim_time_ns * 1ns))
      $fatal(1, "SIM_TIME_NS must be later than reset deassertion");

    testcase.run(testcase_success);
    if (!testcase_success)
      $fatal(1, "Testcase '%s' failed", testcase.get_name());
    if ($time < (sim_time_ns * 1ns))
      #(sim_time_ns * 1ns - $time);
    $display("MEMORY_BACKDOOR_EXAMPLE_PASS testcase=%s time=%0d ns",
             testcase.get_name(), $rtoi($realtime / 1ns));
    $finish;
  end
endmodule
