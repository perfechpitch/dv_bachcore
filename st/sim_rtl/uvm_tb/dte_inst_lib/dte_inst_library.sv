class dte_inst_library extends uvm_object;

    `uvm_object_utils(dte_inst_library)

    protected int log_fd = 0;

    function new(string name = "dte_inst_library");
        super.new(name);
    endfunction : new

    function void set_log(int fd);
        log_fd = fd;
    endfunction : set_log

    function void reset();
    endfunction : reset

endclass : dte_inst_library