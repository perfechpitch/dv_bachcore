package memory_reference_component_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Shared verification Reference component. tb_top creates one component
  // and passes the same handle to every testcase. The component has no RTL
  // ports or module hierarchy; testcases only submit immutable input arrays.
  class memory_reference_component extends uvm_component;
    `uvm_component_utils(memory_reference_component)

    function new(
      string name = "memory_reference_component",
      uvm_component parent = null
    );
      super.new(name, parent);
    endfunction

    protected function uvm_hdl_data_t calculate_word(
      input uvm_hdl_data_t input_value,
      input uvm_hdl_data_t data_mask
    );
      // Current reference algorithm is pass-through. Modify this function
      // when the expected algorithm changes; DUT code remains independent.
      return input_value & data_mask;
    endfunction

    function bit calculate_array(
      input string testcase_name,
      ref uvm_hdl_data_t input_values[$],
      input uvm_hdl_data_t data_mask,
      ref uvm_hdl_data_t result_values[$]
    );
      result_values.delete();
      if (input_values.size() == 0) begin
        `uvm_error(get_type_name(), "Reference input array is empty")
        return 1'b0;
      end
      foreach (input_values[address]) begin
        if ($isunknown(input_values[address] & data_mask)) begin
          `uvm_error(get_type_name(),
            $sformatf("Reference input contains X/Z at address %0d",
                      address))
          result_values.delete();
          return 1'b0;
        end
        result_values.push_back(
          calculate_word(input_values[address], data_mask));
      end
      $display("MEMORY_REFERENCE_COMPONENT_ARRAY_READY testcase=%s words=%0d operation=pass_through",
               testcase_name, result_values.size());
      return 1'b1;
    endfunction
  endclass

endpackage
