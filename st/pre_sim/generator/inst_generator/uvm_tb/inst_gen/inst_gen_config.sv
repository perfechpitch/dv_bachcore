class inst_gen_config extends uvm_object;
    bit float_en = 1'b0;

    bit gpr_full_valid = 1'b0;
    bit fpr_full_valid = 1'b0;

    bit vmem_file_gen = 1'b1;
    int unsigned xlen = 32;
    int gen_file ;
    int vmem_file;
    
    inst_set_e      support_inst_set[];
    mode_e          support_prv_mode[];
    inst_e          support_inst_name[$];
    `uvm_object_utils_begin(inst_gen_config)
        `uvm_field_int(float_en, UVM_DEFAULT)
        `uvm_field_int(gpr_full_valid, UVM_DEFAULT)
        `uvm_field_int(fpr_full_valid, UVM_DEFAULT)
        `uvm_field_int(vmem_file_gen, UVM_DEFAULT)
        `uvm_field_int(xlen, UVM_DEFAULT)

        `uvm_field_int(gen_file, UVM_DEFAULT)
        `uvm_field_int(vmem_file, UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "inst_gen_config");
      super.new(name);
    endfunction : new

endclass 
