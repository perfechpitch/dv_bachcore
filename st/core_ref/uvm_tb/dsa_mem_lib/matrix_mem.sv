class matrix_mem extends base_mem #(MATRIX_MEM_SIZE_KB, MATRIX_MEM_BASE);

    `uvm_object_utils(matrix_mem)

    function new(string name="matrix_mem", bit log_en=1'b0);
        super.new(name, log_en);
    endfunction : new

endclass : matrix_mem
