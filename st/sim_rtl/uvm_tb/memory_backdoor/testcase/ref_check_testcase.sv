package ref_check_testcase_pkg;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_backdoor_operation_pkg::*;
  `include "uvm_macros.svh"

  localparam int unsigned REF_CHECK_SRAM_INDEX = 0;
  // MEM_BKDR_ADDRESS_AUTO uses the complete configured SRAM. Set a positive
  // decimal value to check only the first N input transactions.
  localparam int unsigned REF_CHECK_WORD_COUNT = MEM_BKDR_ADDRESS_AUTO;
  localparam memory_check_mode_e REF_CHECK_CHECK_MODE = MEMORY_CHECK_REFERENCE;
  localparam string REF_CHECK_GOLDEN_FILE = "config/ref_check/golden_data.txt";

  class ref_check_testcase extends memory_backdoor_testcase_base;
    virtual function string get_name();
      return "ref_check";
    endfunction

    virtual task run(output bit success);
      memory_backdoor_operation_request request;
      request = memory_backdoor_operation_request::type_id::create("request");
      if (request == null) begin
        success = 1'b0;
        return;
      end
      request.operation = MEMORY_OPERATION_REF_CHECK;
      request.testcase_name = get_name();
      request.sram_index = REF_CHECK_SRAM_INDEX;
      request.check_word_count = REF_CHECK_WORD_COUNT;
      request.check_mode = REF_CHECK_CHECK_MODE;
      request.golden_file = REF_CHECK_GOLDEN_FILE;
      execute_request(request, success);
    endtask
  endclass

endpackage
