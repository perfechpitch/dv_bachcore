package file_init_testcase_pkg;

  import uvm_pkg::*;
  import memory_backdoor_pkg::*;
  import memory_backdoor_operation_pkg::*;
  `include "uvm_macros.svh"

  localparam int unsigned FILE_INIT_SRAM_COUNT = 1;
  localparam bit          FILE_INIT_COMPARE_ENABLE = 1'b0;

  localparam string FILE_INIT_SRAM0_BANK0_FILE = "config/file_init/file_init_sram0_bank0.hex";
  localparam int unsigned FILE_INIT_SRAM0_BANK0_START_ROW = 64;
  localparam string FILE_INIT_SRAM0_BANK1_FILE = "config/file_init/file_init_sram0_bank1.hex";
  localparam int unsigned FILE_INIT_SRAM0_BANK1_START_ROW = 128;
  localparam string FILE_INIT_SRAM0_BANK2_FILE = "config/file_init/file_init_sram0_bank2.hex";
  localparam int unsigned FILE_INIT_SRAM0_BANK2_START_ROW = 0;
  localparam string FILE_INIT_SRAM0_BANK3_FILE = "config/file_init/file_init_sram0_bank3.hex";
  localparam int unsigned FILE_INIT_SRAM0_BANK3_START_ROW = 0;

  class file_init_testcase extends memory_backdoor_testcase_base;
    virtual function string get_name();
      return "file_init";
    endfunction

    virtual task run(output bit success);
      memory_backdoor_operation_request request;
      request = memory_backdoor_operation_request::type_id::create("request");
      if (request == null) begin
        success = 1'b0;
        return;
      end
      request.operation = MEMORY_OPERATION_FILE_INIT;
      request.testcase_name = get_name();
      request.sram_index = 0;
      request.expected_sram_count = FILE_INIT_SRAM_COUNT;
      request.compare_enable = FILE_INIT_COMPARE_ENABLE;
      request.bank0_file = FILE_INIT_SRAM0_BANK0_FILE;
      request.bank1_file = FILE_INIT_SRAM0_BANK1_FILE;
      request.bank2_file = FILE_INIT_SRAM0_BANK2_FILE;
      request.bank3_file = FILE_INIT_SRAM0_BANK3_FILE;
      request.bank0_start_row = FILE_INIT_SRAM0_BANK0_START_ROW;
      request.bank1_start_row = FILE_INIT_SRAM0_BANK1_START_ROW;
      request.bank2_start_row = FILE_INIT_SRAM0_BANK2_START_ROW;
      request.bank3_start_row = FILE_INIT_SRAM0_BANK3_START_ROW;
      execute_request(request, success);
    endtask
  endclass

endpackage
