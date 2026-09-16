class ls_addr_config extends uvm_object;
    bit [63:0] dtcm_base[3];
    bit [63:0] dtcm_size[3];
    bit [63:0] share_base;
    bit [63:0] share_size;
    share_layout_e share_layout;

    `uvm_object_utils(ls_addr_config)

    function new(string name = "ls_addr_config");
        super.new(name);
        foreach(dtcm_base[i]) begin
            dtcm_base[i] = `DTCM_BASE;
            dtcm_size[i] = `DTCM_SIZE;
        end
        share_base   = `SHARE_BASE;
        share_size   = `SHARE_SIZE;
        share_layout = SHARE_RAND_3CORE;
    endfunction

    function void check();
        foreach(dtcm_size[i])
            if(dtcm_size[i] == 0)
                `uvm_fatal("LS_ADDR_CFG", $sformatf("core %0d DTCM size is zero", i))
        if(share_size == 0)
            `uvm_fatal("LS_ADDR_CFG", "Share Memory size is zero")
    endfunction
endclass
