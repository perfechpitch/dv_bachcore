class core_ref_config extends uvm_object;

    ref_mode_e  ref_mode;
    bit ref_only     = 1'b0;

    bit [1:0] stop_cnt = 'd1;//software program may need more stop cnt
    //TODO: define other quit interface with software
    bit inst_quit = 1'b1;
    bit [31:0] quit_inst = 32'b0;


    inst_set_e    support_inst_set[] = {RV32I,RV32M,RV32A,RV32C,CUSTOM,RI};
    mode_e        support_prv_mode[] = {M_MODE};
    `uvm_object_utils_begin(core_ref_config)
        `uvm_field_enum(ref_mode_e, ref_mode, UVM_DEFAULT)
        `uvm_field_int(stop_cnt, UVM_DEFAULT)
        `uvm_field_int(ref_only, UVM_DEFAULT)
        `uvm_field_int(inst_quit, UVM_DEFAULT)
        `uvm_field_int(quit_inst, UVM_DEFAULT)

   `uvm_object_utils_end

    function new (string name = "core_ref_config");
        super.new(name);
    endfunction : new

endclass
