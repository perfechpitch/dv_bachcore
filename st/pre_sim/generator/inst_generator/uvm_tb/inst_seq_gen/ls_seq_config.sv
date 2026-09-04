class ls_seq_config extends inst_seq_config;
    bit float_en;

    mode_e  ls_mode;
    
    bit flush_inst_enable=0;
    bit except_inst_enable=0;
    bit wfi_inst_enable=0;
    
    //default every seq gen new base
    bit base_confirm=0;
    
    int gen_file;
    
    //bit [4:0] vlmul=0;
    //bit [4:0] vreg_size;
    
    //ls dist
    rand int unsigned int_ls_dist;
    rand int unsigned fp_ls_dist;

    rand int unsigned load_dist;
    rand int unsigned store_dist;
    rand int unsigned amo_dist;
    rand int unsigned fence_dist;
    rand int unsigned other_dist;

    rand int unsigned ls_seq_type_dist[$];
    rand int unsigned ls_base_addr_type_dist[$];

    rand int unsigned base_change_dist;
    share_layout_e  share_layout = SHARE_RAND_3CORE;
    tcm_hart_e      hart = HART_MU;
    bit[63:0]       dtcm_base  = `DTCM_BASE;
    bit[63:0]       share_base = `SHARE_BASE;
 `uvm_object_utils_begin(ls_seq_config)
        `uvm_field_sarray_int(ls_base_addr_type_dist, UVM_DEFAULT | UVM_DEC)
        `uvm_field_sarray_int(ls_seq_type_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_enum(mode_e,ls_mode,UVM_DEFAULT)
        `uvm_field_int(base_confirm, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(float_en, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(flush_inst_enable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(except_inst_enable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(wfi_inst_enable, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(int_ls_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(fp_ls_dist, UVM_DEFAULT|UVM_DEC)

        `uvm_field_int(load_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(store_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(amo_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(fence_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(other_dist, UVM_DEFAULT|UVM_DEC)

        `uvm_field_int(base_change_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_enum(share_layout_e, share_layout, UVM_DEFAULT)
        `uvm_field_enum(tcm_hart_e, hart, UVM_DEFAULT)
        `uvm_field_int(dtcm_base, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(share_base, UVM_DEFAULT|UVM_HEX)

    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_seq_config");
      super.new(name);
    endfunction : new


    constraint dist_c{
    int_ls_dist     inside {[1:100]};
    if(float_en == 0){fp_ls_dist == 0;}
    else {fp_ls_dist      inside {[0:100]};}
    (int_ls_dist + fp_ls_dist ) == 100;

  load_dist   inside {[0:100]};
    store_dist  inside {[0:100]};
    amo_dist    inside {[0:100]};
    fence_dist  inside {[0:100]};
    other_dist  inside {[0:100]};
    (load_dist + store_dist + amo_dist +fence_dist +other_dist) == 100;

    (amo_dist +fence_dist + other_dist)< int_ls_dist;//if not define this, it will fail in item random.
    //they are all int ls
    }

    constraint ls_seq_type_dist_c{
//    TODO: add ls seq type num
        ls_seq_type_dist.size() == 4;
        foreach(ls_seq_type_dist[i]){
            ls_seq_type_dist[i] inside{[0:100]};
        }
        ls_seq_type_dist.sum() == 100;
    }
    constraint ls_base_addr_type_dist_c{
        ls_base_addr_type_dist.size() == 6;
        foreach(ls_base_addr_type_dist[i]){
            ls_base_addr_type_dist[i] inside{[0:100]};
        }
        ls_base_addr_type_dist.sum() == 100;
    }
    constraint base_change_dist_c{
        if(base_confirm) {base_change_dist == 0;}
        else {base_change_dist inside {[0:100]};}
    }
    /*
    function void post_randomize();
    bit [4:0] vreg_group;
        case(vlmul)
            0: vreg_group = 1;
            1: vreg_group = 2;
            2: vreg_group = 4;
            3: vreg_group = 8;
            default: vreg_group = 1;
        endcase
        vreg_size = 32/vreg_group;
    endfunction
    */
endclass
