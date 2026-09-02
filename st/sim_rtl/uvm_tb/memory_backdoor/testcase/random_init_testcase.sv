package random_init_testcase_pkg;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_backdoor_operation_pkg::*;
  `include "uvm_macros.svh"

  localparam int unsigned  RANDOM_INIT_START_ADDRESS = 0;
  localparam int unsigned  RANDOM_INIT_END_ADDRESS = MEM_BKDR_ADDRESS_AUTO;
  localparam bit            RANDOM_INIT_USE_FULL_DATA_WIDTH = 1'b1;
  localparam uvm_hdl_data_t RANDOM_INIT_MIN = 32'h0000_0000;
  localparam uvm_hdl_data_t RANDOM_INIT_MAX = 32'hffff_ffff;
  localparam bit            RANDOM_INIT_COMPARE_ENABLE = 1'b0;

  class random_init_testcase extends memory_backdoor_testcase_base;
    virtual function string get_name();
      return "random_init";
    endfunction

    virtual task run(output bit success);
      memory_backdoor_operation_request request;
      request = memory_backdoor_operation_request::type_id::create("request");
      if (request == null) begin
        success = 1'b0;
        return;
      end
      request.operation = MEMORY_OPERATION_RANDOM_INIT;
      request.testcase_name = get_name();
      request.start_address = RANDOM_INIT_START_ADDRESS;
      request.end_address = RANDOM_INIT_END_ADDRESS;
      request.use_full_data_width = RANDOM_INIT_USE_FULL_DATA_WIDTH;
      request.random_min = RANDOM_INIT_MIN;
      request.random_max = RANDOM_INIT_MAX;
      request.compare_enable = RANDOM_INIT_COMPARE_ENABLE;
      execute_request(request, success);
    endtask
  endclass

endpackage
