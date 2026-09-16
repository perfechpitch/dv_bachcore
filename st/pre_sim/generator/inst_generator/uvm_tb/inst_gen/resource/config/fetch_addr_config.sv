class fetch_addr_config extends uvm_object;
    bit [63:0] itcm_start[3];
    bit [63:0] itcm_size[3];
    int unsigned ialign_bytes;
    bit          allow_exception;
    int unsigned start_exception_pct;
    int unsigned control_exception_pct;
    int unsigned end_exception_pct;

    `uvm_object_utils(fetch_addr_config)

    function new(string name = "fetch_addr_config");
        super.new(name);
        foreach(itcm_start[i]) begin
            itcm_start[i] = '0;
            itcm_size[i]  = `ITCM_SIZE;
        end
        ialign_bytes          = 4;
        allow_exception       = 1'b1;
        start_exception_pct   = 10;
        control_exception_pct = 10;
        end_exception_pct     = 10;
    endfunction

    function void check();
        if(!(ialign_bytes inside {2, 4}))
            `uvm_fatal("FETCH_ADDR_CFG", "ialign_bytes must be 2 or 4")
        if(start_exception_pct > 100 || control_exception_pct > 100 ||
           end_exception_pct > 100)
            `uvm_fatal("FETCH_ADDR_CFG", "fetch exception percentages must be in [0:100]")
    endfunction
endclass
