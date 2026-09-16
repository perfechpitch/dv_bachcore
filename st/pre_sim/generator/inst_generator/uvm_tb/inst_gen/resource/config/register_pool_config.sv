class register_pool_config extends uvm_object;
    bit          gpr_full_valid;
    bit          fpr_full_valid;
    bit          support_rvc;
    int unsigned xlen;

    `uvm_object_utils(register_pool_config)

    function new(string name = "register_pool_config");
        super.new(name);
        gpr_full_valid = 1'b0;
        fpr_full_valid = 1'b0;
        support_rvc    = 1'b0;
        xlen           = 32;
    endfunction

    function void check();
        if(!(xlen inside {32, 64}))
            `uvm_fatal("REGISTER_POOL_CFG", "xlen must be 32 or 64")
    endfunction
endclass
