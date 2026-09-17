package file_check_testcase_pkg;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_backdoor_operation_pkg::*;
  `include "uvm_macros.svh"

  localparam string FILE_CHECK_INPUT_FILE = "config/file_check/dut_input_data.txt";
  localparam string FILE_CHECK_GOLDEN_FILE = "config/file_check/golden_data.txt";
  localparam memory_check_mode_e FILE_CHECK_CHECK_MODE = MEMORY_CHECK_FILE;
  localparam int unsigned FILE_CHECK_SRAM_INDEX = 0;
  // MEM_BKDR_ADDRESS_AUTO uses the complete configured SRAM. Set a positive
  // decimal value when the input and Golden files contain only the first N words.
  localparam int unsigned FILE_CHECK_WORD_COUNT = MEM_BKDR_ADDRESS_AUTO;

  class file_check_testcase extends memory_backdoor_testcase_base;
    virtual function string get_name();
      return "file_check";
    endfunction

    virtual task run(output bit success);
      memory_backdoor_operation_request request;
      request = memory_backdoor_operation_request::type_id::create("request");
      if (request == null) begin
        success = 1'b0;
        return;
      end
      request.operation = MEMORY_OPERATION_FILE_CHECK;
      request.testcase_name = get_name();
      request.sram_index = FILE_CHECK_SRAM_INDEX;
      request.check_word_count = FILE_CHECK_WORD_COUNT;
      request.check_mode = FILE_CHECK_CHECK_MODE;
      request.golden_file = FILE_CHECK_GOLDEN_FILE;
      execute_request(request, success);
    endtask
  endclass

endpackage
