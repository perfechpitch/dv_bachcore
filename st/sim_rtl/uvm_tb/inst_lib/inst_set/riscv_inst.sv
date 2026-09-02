class riscv_inst extends uvm_object;

    string inst_name;
    inst_set_e inst_set;
    exe_unit_e exe_unit;

    bit [31:0] const_ops_mask;
    bit [31:0] const_ops_val;

    bit log_en = 1'b1;
    int inst_exe_log;

    `uvm_object_utils(riscv_inst)

    function new(string name="riscv_inst");
        super.new(name);
    endfunction : new

    extern virtual function bit name_match(string check_str);
    extern virtual function bit inst_match(bit [31:0] inst);
    extern virtual function void inst_exe(`INST_EXE_PARAS);

endclass : riscv_inst

function bit riscv_inst::name_match(string check_str);
    return uvm_is_match(check_str, inst_name);
endfunction : name_match

function bit riscv_inst::inst_match(bit [31:0] inst);
    return (inst & const_ops_mask) == const_ops_val;
endfunction : inst_match

function void riscv_inst::inst_exe(`INST_EXE_PARAS);
endfunction : inst_exe