typedef enum{SINGLE_BRANCH_SEQ,LOOP_SEQ,JALR_SEQ}branch_seq_type_e;
class branch_seq_type_item extends uvm_object;
    branch_seq_config inst_seq_cfg;
    rand branch_seq_type_e branch_seq_type;
    `uvm_object_utils_begin(branch_seq_type_item)
        `uvm_field_enum(branch_seq_type_e ,branch_seq_type,UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "branch_seq_type_item");
      super.new(name);
    endfunction : new
    
    constraint branch_seq_type_c{
        branch_seq_type dist{
        SINGLE_BRANCH_SEQ   := inst_seq_cfg.branch_seq_type_dist[0],
        LOOP_SEQ            := inst_seq_cfg.branch_seq_type_dist[1],
        JALR_SEQ            := inst_seq_cfg.branch_seq_type_dist[2]
        //check loop
        //SINGLE_BRANCH_SEQ   := 0,
        //LOOP_SEQ            := 1
        };
    }
endclass

typedef enum{ALU_TARGET,LOAD_TARGET,MDU_TARGET,DIV_TARGET}jalr_target_gen_type_e;
class jalr_seq_info_item extends inst_seq_info_item;
    branch_seq_config   inst_seq_cfg;
    branch_seq_type_e   branch_seq_type;
    rand bit [11:0] jalr_imm;

rand jalr_target_gen_type_e target_gen_type;
    `uvm_object_utils_begin(jalr_seq_info_item)
        `uvm_field_enum(jalr_target_gen_type_e, target_gen_type,    UVM_DEFAULT)
        `uvm_field_int(jalr_imm, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end
    function new (string name = "jalr_seq_info_item");
      super.new(name);
    endfunction : new

    constraint jalr_target_c{
        target_gen_type dist{
            ALU_TARGET  := inst_seq_cfg.jalr_target_gen_type_dist[0],
            LOAD_TARGET := inst_seq_cfg.jalr_target_gen_type_dist[1],
            MDU_TARGET  := inst_seq_cfg.jalr_target_gen_type_dist[2],
            DIV_TARGET  := inst_seq_cfg.jalr_target_gen_type_dist[3]
        };
    }

    constraint jalr_imm_c{
        (target_gen_type == LOAD_TARGET) -> jalr_imm == 0; // load + JALR, imm = 0
    }
    //// dont do this will sim Error.
    constraint seq_length_type_c{
        seq_length_type dist{
        MIN :=  inst_seq_cfg.seq_length_dist[0],
        LOW :=  inst_seq_cfg.seq_length_dist[1],
        HIGH:=  inst_seq_cfg.seq_length_dist[2],
        MAX :=  inst_seq_cfg.seq_length_dist[3]
        };
    }
endclass

class branch_seq_info_item extends inst_seq_info_item;
    branch_seq_config inst_seq_cfg;
    branch_seq_type_e   branch_seq_type;
typedef enum{DWORD_INSIDE,CACHELINE_INSIDE,CACHELINE_BEYOND}target_inst_num_type_e;
    rand target_inst_num_type_e target_inst_num_type;
    rand int target_inst_num;
    rand bit branch_forward;
    rand bit branch_is_jump;

    rand int unsigned safe_inst_dist;
    rand int unsigned flush_inst_dist;
    rand int unsigned except_inst_dist;
    rand int unsigned ls_inst_dist;
    rand int unsigned wfi_inst_dist;
    bit [20:0] imm;
    `uvm_object_utils_begin(branch_seq_info_item)
        `uvm_field_enum(target_inst_num_type_e ,target_inst_num_type,UVM_DEFAULT)
        `uvm_field_enum(branch_seq_type_e ,branch_seq_type,UVM_DEFAULT)
        `uvm_field_int(target_inst_num, UVM_DEFAULT)
        `uvm_field_int(branch_forward, UVM_DEFAULT)
        `uvm_field_int(branch_is_jump, UVM_DEFAULT)
        `uvm_field_int(safe_inst_dist,UVM_DEFAULT)
        `uvm_field_int(flush_inst_dist,UVM_DEFAULT)
        `uvm_field_int(except_inst_dist,UVM_DEFAULT)
        `uvm_field_int(ls_inst_dist,UVM_DEFAULT)
        `uvm_field_int(wfi_inst_dist,UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "branch_seq_info_item");
      super.new(name);
    endfunction : new

    constraint branch_forward_c{
        branch_forward dist{
        1 := inst_seq_cfg.branch_forward_dist,
        0 := 100- inst_seq_cfg.branch_forward_dist
        };
    }
    constraint target_num_type_c{
        target_inst_num_type dist{
            DWORD_INSIDE        := inst_seq_cfg.target_inst_num_dist[0],
            CACHELINE_INSIDE    := inst_seq_cfg.target_inst_num_dist[1],
            CACHELINE_BEYOND    := inst_seq_cfg.target_inst_num_dist[2]
        };
    }

    constraint target_num_c{
        (target_inst_num_type == DWORD_INSIDE)      ->target_inst_num inside{[1:2]};
        (target_inst_num_type == CACHELINE_INSIDE)  ->target_inst_num inside{[2:16]};
        (target_inst_num_type == CACHELINE_BEYOND)  ->target_inst_num inside{[16:50]};
    }
    constraint inst_dist_c{
        safe_inst_dist inside{[0:100]};
        if(inst_seq_cfg.ls_inst_disable){ls_inst_dist == 'd0;}
        else{
        ls_inst_dist inside{[0:100]};}
        if(!inst_seq_cfg.flush_inst_enable){flush_inst_dist == 'd0;}
        else{
        flush_inst_dist inside{[0:100]};}
        if(!inst_seq_cfg.except_inst_enable){except_inst_dist == 'd0;}
        else{
        except_inst_dist inside{[0:100]};}
        if(!inst_seq_cfg.wfi_inst_enable){wfi_inst_dist == 'd0;}
        else{
        wfi_inst_dist inside{[0:100]};}
        safe_inst_dist + ls_inst_dist + flush_inst_dist + except_inst_dist + wfi_inst_dist == 100;
    }
    constraint seq_length_type_c{
        seq_length_type dist{
        MIN :=  inst_seq_cfg.seq_length_dist[0],
        LOW :=  inst_seq_cfg.seq_length_dist[1],
        HIGH:=  inst_seq_cfg.seq_length_dist[2],
        MAX :=  inst_seq_cfg.seq_length_dist[3]
        };
    }
    function void post_randomize();
        imm = target_inst_num * 4;
    endfunction
endclass
