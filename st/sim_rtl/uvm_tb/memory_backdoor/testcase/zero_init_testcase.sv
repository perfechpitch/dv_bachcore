package zero_init_testcase_pkg;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_backdoor_operation_pkg::*;
  `include "uvm_macros.svh"

  localparam int unsigned ZERO_INIT_START_ADDRESS = 0;
  localparam int unsigned ZERO_INIT_END_ADDRESS = MEM_BKDR_ADDRESS_AUTO;
  localparam bit          ZERO_INIT_COMPARE_ENABLE = 1'b0;

  class zero_init_testcase extends memory_backdoor_testcase_base;
    virtual function string get_name();
      return "zero_init";
    endfunction

    virtual task run(output bit success);
      memory_backdoor_operation_request request;
      request = memory_backdoor_operation_request::type_id::create("request");
      if (request == null) begin
        success = 1'b0;
        return;
      end
      request.operation = MEMORY_OPERATION_ZERO_INIT;
      request.testcase_name = get_name();
      request.start_address = ZERO_INIT_START_ADDRESS;
      request.end_address = ZERO_INIT_END_ADDRESS;
      request.compare_enable = ZERO_INIT_COMPARE_ENABLE;
      execute_request(request, success);
    endtask
  endclass

endpackage
