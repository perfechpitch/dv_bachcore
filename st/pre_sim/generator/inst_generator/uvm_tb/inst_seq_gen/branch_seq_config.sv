class branch_seq_config extends inst_seq_config;

    //test cfg
    bit flush_inst_enable=0;
    bit except_inst_enable=0;
    bit wfi_inst_enable=0;
    bit ls_inst_disable=0;
    
    rand int unsigned branch_forward_dist;
    rand int unsigned branch_is_jump_dist;
    rand int unsigned target_inst_num_dist[$];
    
    rand int unsigned branch_seq_type_dist[$];
    rand int unsigned jalr_target_gen_type_dist[$];

    mode_e  program_mode;
    
    `uvm_object_utils_begin(branch_seq_config)
        `uvm_field_enum(mode_e,program_mode, UVM_DEFAULT)
        `uvm_field_int(flush_inst_enable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(except_inst_enable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(wfi_inst_enable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(ls_inst_disable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(branch_forward_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(branch_is_jump_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(target_inst_num_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(branch_seq_type_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(jalr_target_gen_type_dist, UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "branch_seq_config");
      super.new(name);
    endfunction : new
    
    constraint branch_c{
        //branch_forward_dist inside{[0:100]};
        branch_forward_dist ==0;
        branch_is_jump_dist inside{[0:100]};
    }

  constraint branch_seq_type_dist_c{
//    TODO: add branch seq type num
        branch_seq_type_dist.size() == 3;
        foreach(branch_seq_type_dist[i]){
            branch_seq_type_dist[i] inside{[0:100]};
        }
        branch_seq_type_dist.sum() == 100;
    }
    constraint target_inst_num_dist_c{
        target_inst_num_dist.size() == 3;
        foreach(target_inst_num_dist[i]){
            target_inst_num_dist[i] inside{[0:100]};
        }
        target_inst_num_dist.sum() == 100;
    }

    constraint jalr_target_gen_type_dist_c{
        jalr_target_gen_type_dist.size() == 4;
        foreach(jalr_target_gen_type_dist[i]){
            jalr_target_gen_type_dist[i] inside{[0:100]};
        }
        jalr_target_gen_type_dist.sum() == 100;
    }
endclass
