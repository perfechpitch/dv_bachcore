typedef enum{RAND_LS,LINEAR_LS,LRSC_LS,MEMCPY_LS}ls_seq_type_e;
class ls_seq_info_item extends inst_seq_info_item;
    //override inst_seq_cfg
    ls_seq_config inst_seq_cfg;
    
    //other inst dist
    rand int unsigned safe_inst_dist;
    rand int unsigned flush_inst_dist;
    rand int unsigned except_inst_dist;
    rand int unsigned ls_inst_dist;
    rand int unsigned wfi_inst_dist;
    //ls inst dist
    rand int unsigned pref_dist;
    rand int unsigned load_dist;
    rand int unsigned store_dist;
    rand int unsigned amo_dist;
    rand int unsigned fence_dist;
    rand int unsigned fp_load_dist;
    rand int unsigned fp_store_dist;

    rand ls_seq_type_e ls_seq_type;
    rand bit            base_change;

    `uvm_object_utils_begin(ls_seq_info_item)

        `uvm_field_enum(ls_seq_type_e ,ls_seq_type,UVM_DEFAULT)
        `uvm_field_int(safe_inst_dist,UVM_DEFAULT)
        `uvm_field_int(flush_inst_dist,UVM_DEFAULT)
        `uvm_field_int(except_inst_dist,UVM_DEFAULT)
        `uvm_field_int(ls_inst_dist,UVM_DEFAULT)
        `uvm_field_int(wfi_inst_dist,UVM_DEFAULT)

        `uvm_field_int(pref_dist,UVM_DEFAULT)
        `uvm_field_int(load_dist,UVM_DEFAULT)
        `uvm_field_int(store_dist,UVM_DEFAULT)
        `uvm_field_int(amo_dist,UVM_DEFAULT)
        `uvm_field_int(fence_dist,UVM_DEFAULT)
        `uvm_field_int(fp_load_dist,UVM_DEFAULT)
        `uvm_field_int(fp_store_dist,UVM_DEFAULT)
        `uvm_field_int(base_change,UVM_DEFAULT)
    `uvm_object_utils_end
// new - constructor
    function new (string name = "ls_seq_info_item");
      super.new(name);
    endfunction : new

    constraint ls_seq_type_c{
        ls_seq_type dist{
        RAND_LS     := inst_seq_cfg.ls_seq_type_dist[0],
        LINEAR_LS   := inst_seq_cfg.ls_seq_type_dist[1],
        LRSC_LS     := inst_seq_cfg.ls_seq_type_dist[2],
        MEMCPY_LS   := inst_seq_cfg.ls_seq_type_dist[3]
        };
    }

    constraint other_inst_dist_c{
        safe_inst_dist inside{[0:10]};
        ls_inst_dist inside{[0:100]};
        flush_inst_dist == 0;
        except_inst_dist == 0;
        //if(!inst_seq_cfg.flush_inst_enable){flush_inst_dist == 'd0;}
        //else{
        //flush_inst_dist inside{[0:100]};}
        //if(!inst_seq_cfg.except_inst_enable){except_inst_dist == 'd0;}
        //else{
        //except_inst_dist inside{[0:100]};}
        if(!inst_seq_cfg.wfi_inst_enable){wfi_inst_dist == 'd0;}
        else{
        wfi_inst_dist inside{[0:100]};}
        (safe_inst_dist + flush_inst_dist + except_inst_dist + wfi_inst_dist + ls_inst_dist) == 100;
    }
 //TODO:cache inst dist
    constraint ls_inst_dist_c{
        pref_dist   inside{[0:100]};
        load_dist   inside{[0:100]};
        store_dist  inside{[0:100]};
        amo_dist    inside{[0:100]};
        fence_dist  inside{[0:100]};
        fp_load_dist   inside{[0:100]};
        fp_store_dist  inside{[0:100]};

        (fp_load_dist+fp_store_dist) == inst_seq_cfg.fp_ls_dist;
        (pref_dist + load_dist + store_dist +amo_dist + fence_dist) == inst_seq_cfg.int_ls_dist;

        (load_dist+fp_load_dist) == inst_seq_cfg.load_dist;
        (store_dist+fp_store_dist) == inst_seq_cfg.store_dist;

        (pref_dist/*TODO+cache/cbo*/) == inst_seq_cfg.other_dist;
        amo_dist == inst_seq_cfg.amo_dist;
        fence_dist == inst_seq_cfg.fence_dist;

    }
    //because inst_seq_cfg override, this constraint should override too
    //if don't do this, seq_length_dist will not found
    constraint seq_length_type_c{
        seq_length_type dist{
        MIN :=  inst_seq_cfg.seq_length_dist[0],
        LOW :=  inst_seq_cfg.seq_length_dist[1],
        HIGH:=  inst_seq_cfg.seq_length_dist[2],
        MAX :=  inst_seq_cfg.seq_length_dist[3]
        };
    }
    constraint seq_length_c{
        (seq_length_type == MIN)    -> seq_length == 'd1;
        (seq_length_type == LOW)    -> seq_length inside{[1:20]};
        (seq_length_type == HIGH)   -> seq_length inside{[20:50]};
        (seq_length_type == MAX)    -> seq_length inside{[50:100]};
    }

    constraint base_change_c{
        base_change dist{
        1:= inst_seq_cfg.base_change_dist,
        0:= 100 -inst_seq_cfg.base_change_dist
        };
    }
endclass
