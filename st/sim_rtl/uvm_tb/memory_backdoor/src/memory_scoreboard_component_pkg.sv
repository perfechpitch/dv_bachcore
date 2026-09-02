package memory_scoreboard_component_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Shared result-array scoreboard. The unified Operation component provides
  // the expected source, DUT result snapshot, and output report path.
  class memory_scoreboard_component extends uvm_component;
    `uvm_component_utils(memory_scoreboard_component)

    function new(string name = "memory_scoreboard_component",
                 uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function bit compare_arrays(
      input string testcase_name,
      ref uvm_hdl_data_t expected_array[$],
      ref uvm_hdl_data_t dut_array[$],
      input int unsigned expected_words,
      input string compare_file,
      input string expected_source,
      output int unsigned mismatch_count
    );
      int file_descriptor;
      bit word_match;

      mismatch_count = 0;
      if ((testcase_name == "") || (expected_source == "")) begin
        `uvm_error(get_type_name(),
          "testcase_name and expected_source must not be empty")
        return 1'b0;
      end
      if ((expected_array.size() != expected_words) ||
          (dut_array.size() != expected_words)) begin
        `uvm_error(get_type_name(),
          $sformatf("Array size mismatch for %s: expected=%0d dut=%0d required=%0d",
                    testcase_name, expected_array.size(), dut_array.size(),
                    expected_words))
        return 1'b0;
      end
      if (compare_file == "") begin
        `uvm_error(get_type_name(), "DUT comparison file is empty")
        return 1'b0;
      end
      file_descriptor = $fopen(compare_file, "w");
      if (file_descriptor == 0) begin
        `uvm_error(get_type_name(),
          $sformatf("Cannot create DUT comparison file '%s'", compare_file))
        return 1'b0;
      end
      $fdisplay(file_descriptor,
        "LOGICAL_WORD_ADDRESS EXPECTED_DATA DUT_DATA RESULT");

      for (int unsigned index = 0; index < expected_words; index++) begin
        word_match = !$isunknown(expected_array[index]) &&
                     !$isunknown(dut_array[index]) &&
                     (dut_array[index] === expected_array[index]);
        if (word_match)
          $fdisplay(file_descriptor,
                    "%0d 0x%0h 0x%0h PASS", index,
                    expected_array[index], dut_array[index]);
        else begin
          $fdisplay(file_descriptor,
                    "%0d 0x%0h 0x%0h FAIL", index,
                    expected_array[index], dut_array[index]);
          mismatch_count++;
          if (mismatch_count <= 16)
            `uvm_error(get_type_name(),
              $sformatf("Mismatch testcase=%s index=%0d expected=0x%0h dut=0x%0h source=%s",
                        testcase_name, index, expected_array[index],
                        dut_array[index], expected_source))
        end
      end
      $fclose(file_descriptor);
      $display("MEMORY_SCOREBOARD_COMPARE_FILE_READY testcase=%s file=%s words=%0d mismatches=%0d expected_source=%s",
               testcase_name, compare_file, expected_words, mismatch_count,
               expected_source);

      if (mismatch_count != 0) begin
        $display("MEMORY_SCOREBOARD_FAIL testcase=%s words=%0d mismatches=%0d expected_source=%s",
                 testcase_name, expected_words, mismatch_count,
                 expected_source);
        return 1'b0;
      end
      $display("MEMORY_SCOREBOARD_PASS testcase=%s words=%0d mismatches=0 expected_source=%s",
               testcase_name, expected_words, expected_source);
      return 1'b1;
    endfunction
  endclass

endpackage
