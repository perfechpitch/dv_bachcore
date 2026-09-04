//class loop_seq_info_item extends inst_seq_info_item;
class loop_seq_info_item extends branch_seq_info_item;
    rand target_inst_num_type_e target_inst_num_type[$];
    rand int target_inst_num[$];
    rand bit[63:0] start_index[$];//index cnt start value
    rand bit[63:0] end_index[$];  //index cnt end value
    rand int loop_num;  //loop hierarichy
    rand bit       start_index_is_zero[$];  //index cnt end value
    rand bit       end_index_is_zero[$];  //index cnt end value


    bit [12:0] imm[$];
    `uvm_object_utils_begin(loop_seq_info_item)
        `uvm_field_sarray_enum(target_inst_num_type_e ,target_inst_num_type,UVM_DEFAULT)
        `uvm_field_sarray_int(target_inst_num, UVM_DEFAULT)
        `uvm_field_sarray_int(start_index, UVM_DEFAULT)
        `uvm_field_sarray_int(end_index, UVM_DEFAULT)
        `uvm_field_sarray_int(start_index_is_zero, UVM_DEFAULT)
        `uvm_field_sarray_int(end_index_is_zero, UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "loop_seq_info_item");
      super.new(name);
    endfunction : new
    constraint loop_hierarchy_c{
        loop_num inside{[1:4]};
        target_inst_num_type.size() == loop_num;
        target_inst_num.size() == loop_num;
        start_index.size() == loop_num;
        start_index_is_zero.size() == loop_num;
        end_index_is_zero.size() == loop_num;
        end_index.size() == loop_num;
    }
    constraint branch_forward_c{
        branch_forward == 1;
     }
    constraint branch_is_jump_c{
        branch_is_jump == 0;
    }
    constraint index_c{
        foreach(start_index[i]){
        start_index_is_zero[i] -> start_index[i] == 0;
        end_index_is_zero[i] -> end_index[i] == 0;
        start_index_is_zero[i] != end_index_is_zero[i];
        (end_index[i] - start_index[i]) < 'd20;// limit loop times biggest value
        start_index[i] != end_index[i];
        }
    }

    constraint target_num_type_c{
        foreach(target_inst_num_type[i]){
        target_inst_num_type[i] dist{
            DWORD_INSIDE        := inst_seq_cfg.target_inst_num_dist[0],
            CACHELINE_INSIDE    := inst_seq_cfg.target_inst_num_dist[1],
            CACHELINE_BEYOND    := inst_seq_cfg.target_inst_num_dist[2]
        };}
    }

    constraint target_num_c{
        foreach(target_inst_num[i]){
        (target_inst_num_type[i] == DWORD_INSIDE)      ->target_inst_num[i] inside{[1:2]};
        (target_inst_num_type[i] == CACHELINE_INSIDE)  ->target_inst_num[i] inside{[2:16]};
        (target_inst_num_type[i] == CACHELINE_BEYOND)  ->target_inst_num[i] inside{[16:50]};
        }
    }
    function void post_randomize();
        foreach(imm[i])begin
            imm[i] = 'h1000-target_inst_num[i] * 4;
        end
    endfunction
endclass
