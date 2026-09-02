class scale_mem #(
    int MEM_SIZE_KB=CORE_SCALE_MEM_SIZE_KB,
    logic [31:0] BASE_ADDR=CORE_SCALE_MEM_BASE
) extends base_mem #(MEM_SIZE_KB, BASE_ADDR);

    `uvm_object_param_utils(scale_mem #(MEM_SIZE_KB, BASE_ADDR))

    function new(string name="scale_mem", bit log_en=1'b0);
        super.new(name, log_en);
    endfunction : new

endclass : scale_mem
