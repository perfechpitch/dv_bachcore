class riscv_csr extends uvm_object;

    bit [63:0] reset_val;
    bit [63:0] val;
    bit [63:0] write_en;

    int csr_lib_log;
    bit log_en = 1'b1;

    string csr_name;
    bit [11:0] csr_addr;
    csr_rw_type_e rw_type;

    `uvm_object_utils(riscv_csr)

    function new(string name="riscv_csr");
        super.new(name);
    endfunction : new

    extern virtual function void reset_csr();
    extern virtual function bit [63:0] get_val();
    extern virtual function void set_val(bit [63:0] wdata);
    extern virtual function string get_csr_name();
    extern virtual function bit addr_match(bit [11:0] addr);
    extern virtual function csr_acc_except_type_e csr_access(csr_access_type_e acc_type, ref bit [63:0] data);
    extern virtual function csr_acc_except_type_e csr_acc_except_gen(csr_access_type_e acc_type);

endclass : riscv_csr

function csr_acc_except_type_e riscv_csr::csr_acc_except_gen(csr_access_type_e acc_type);
    return NONE_CSR_EXCEPT;
endfunction : csr_acc_except_gen

function bit riscv_csr::addr_match(bit [11:0] addr);
    return addr == csr_addr;
endfunction : addr_match

function bit [63:0] riscv_csr::get_val();
    return val;
endfunction : get_val

function void riscv_csr::reset_csr();
    val = reset_val;
endfunction : reset_csr

function void riscv_csr::set_val(bit [63:0] wdata);
    val = (val & ~write_en) | (wdata & write_en);
endfunction : set_val

function string riscv_csr::get_csr_name();
    return csr_name;
endfunction : get_csr_name

function csr_acc_except_type_e riscv_csr::csr_access(
    csr_access_type_e acc_type,
    ref bit [63:0] data
);
    csr_acc_except_type_e csr_acc_except;

    csr_acc_except = csr_acc_except_gen(acc_type);

    if(log_en)
        $fwrite(csr_lib_log, "before csr_%0s, data=%0h, val=%0h\n",
                get_name(), data, val);

    if(csr_acc_except == NONE_CSR_EXCEPT) begin
        if(acc_type == ABS_READ || acc_type == INST_READ)
            data = get_val();
        else if(rw_type != RO)
            set_val(data);
    end

    if(log_en)
        $fwrite(csr_lib_log, "after csr_%0s, data=%0h, val=%0h\n",
                get_name(), data, val);

    return csr_acc_except;
endfunction : csr_access