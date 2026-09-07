// AUTO-GENERATED from mu_mmio.json. DO NOT EDIT.

function string get_write_desc(bit [31:0] addr, bit [31:0] data);
    return $sformatf("[MU_MMIO] W addr=0x%08h data=0x%08h", addr, data);
endfunction : get_write_desc

function string get_read_desc(bit [31:0] addr, bit [31:0] data);
    return $sformatf("[MU_MMIO] R addr=0x%08h data=0x%08h", addr, data);
endfunction : get_read_desc
