class core_mem extends base_mem #(CORE_MEM_SIZE_KB, CORE_MEM_BASE);

    `uvm_object_utils(core_mem)

    function new(string name="core_mem", bit log_en=1'b0);
        super.new(name, log_en);
    endfunction : new

endclass : core_mem
