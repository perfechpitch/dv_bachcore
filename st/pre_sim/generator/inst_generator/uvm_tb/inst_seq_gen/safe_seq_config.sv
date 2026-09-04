class safe_seq_config extends inst_seq_config;
    bit float_en;
    bit ls_inst_disable=0;

    //safe inst dist
    rand int unsigned int_inst_dist;
    rand int unsigned float_inst_dist;
    
    rand int unsigned safe_int_cal_dist;
    rand int unsigned safe_float_cal_dist;
    rand int unsigned safe_branch_dist;
    rand int unsigned safe_int_ls_dist;
    
    `uvm_object_utils_begin(safe_seq_config)
    //    `uvm_field_int(vreg_size, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(float_en, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(ls_inst_disable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(int_inst_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(float_inst_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(safe_int_cal_dist,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(safe_float_cal_dist,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(safe_branch_dist,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(safe_int_ls_dist,UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "safe_seq_config");
      super.new(name);
    endfunction : new

 constraint dist_c{
    int_inst_dist     inside {[0:100]};
    if(float_en == 0){float_inst_dist == 0;}
    else {float_inst_dist      inside {[0:100]};}
    if(ls_inst_disable){safe_int_ls_dist ==0;}

    (int_inst_dist + float_inst_dist ) == 100;


    safe_int_cal_dist       inside{[0:100]};
    safe_float_cal_dist     inside{[0:100]};
    safe_branch_dist        inside{[0:100]};
    safe_int_ls_dist        inside{[0:100]};

    (safe_int_ls_dist + safe_branch_dist) inside{[0:5]}; // make safe pref & safe branch low rate
    (safe_int_cal_dist + safe_int_ls_dist + safe_branch_dist) == int_inst_dist;
    (safe_float_cal_dist ) == float_inst_dist;
    }
endclass
