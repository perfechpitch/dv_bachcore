class mu_mmio_set extends uvm_object;

    `uvm_object_utils(mu_mmio_set)

    protected int log_fd = 0;

    `include "generated/mu_mmio_decl_auto.svh"

    function new(string name = "mu_mmio_set");
        super.new(name);
    endfunction : new

    protected function void mmio_log(string msg);
        if(log_fd != 0)
            $fwrite(log_fd, "%s", msg);
    endfunction : mmio_log

    function void set_log(int fd);
        log_fd = fd;
    endfunction : set_log

    function void reset_mmio();
        `include "generated/mu_mmio_reset_auto.svh"
    endfunction : reset_mmio

    function void write(bit [31:0] addr, bit [31:0] data);
        bit mmio_hit;

        mmio_hit = 1'b0;

        mmio_log($sformatf(
            "[MU_MMIO] W addr=0x%08h data=0x%08h\n",
            addr,
            data
        ));

        `include "generated/mu_mmio_write_auto.svh"

        if(!mmio_hit)
            `uvm_error("MU_MMIO", $sformatf(
                "unknown MMIO write addr=0x%08h data=0x%08h",
                addr,
                data
            ))
    endfunction : write

    function bit [31:0] read(bit [31:0] addr);
        bit mmio_hit;
        bit [31:0] data;

        mmio_hit = 1'b0;
        data = 32'h0;

        `include "generated/mu_mmio_read_auto.svh"

        if(!mmio_hit)
            `uvm_error("MU_MMIO", $sformatf(
                "unknown MMIO read addr=0x%08h",
                addr
            ))

        mmio_log($sformatf(
            "[MU_MMIO] R addr=0x%08h data=0x%08h\n",
            addr,
            data
        ));

        return data;
    endfunction : read

endclass : mu_mmio_set