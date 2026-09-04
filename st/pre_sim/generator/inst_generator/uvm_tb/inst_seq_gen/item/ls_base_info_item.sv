typedef enum {LOAD_BASE,ALU_LOAD_BASE,ALU_DIV_LOAD_BASE,MDU_LOAD_BASE}base_gen_type_e;
class ls_base_info_item extends uvm_object;
    //override inst_seq_cfg
    ls_seq_config inst_seq_cfg;
    rand bit [4:0] base_num;
    rand bit [4:0] imm_num;
    rand base_gen_type_e    gen_type[$];
    rand bit[3:0]  insert_num[$];//insert safe inst num before load inst
//    rand bit[11:0] base_imm[$];
    rand addr_type_e    base_addr_type[$];

    `uvm_object_utils_begin(ls_base_info_item)
        `uvm_field_int(base_num,UVM_DEFAULT)
        `uvm_field_int(imm_num,UVM_DEFAULT)
        `uvm_field_sarray_enum(base_gen_type_e ,   gen_type,UVM_DEFAULT)
//        `uvm_field_sarray_int(base_imm,UVM_DEFAULT)
        `uvm_field_sarray_enum(addr_type_e ,  base_addr_type,UVM_DEFAULT)

    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_base_info_item");
      super.new(name);
    endfunction : new


    constraint base_num_c{
        base_num inside {[2:5]};
    }
    constraint imm_num_c{
        imm_num inside {[1:5]};
    }
    constraint gen_type_c{
        gen_type.size == base_num;
        base_addr_type.size == base_num;
        insert_num.size == base_num;
        //base_imm.size == base_num;
    }
  //constraint solve_c{
    //    solve base_num before base_imm;
    //}

    constraint base_addr_type_c{
        foreach(base_addr_type[i]){
            if(i==0){base_addr_type[i] == AMO_VALID;}
            else if(i==1){base_addr_type[i] == LOAD_INVALID;}
            else{
            base_addr_type[i] dist{
               LOAD_VALID   :=  inst_seq_cfg.ls_base_addr_type_dist[0],
               LOAD_INVALID :=  inst_seq_cfg.ls_base_addr_type_dist[1],
               LS_VALID     :=  inst_seq_cfg.ls_base_addr_type_dist[2],
               LS_INVALID   :=  inst_seq_cfg.ls_base_addr_type_dist[3],
               AMO_VALID    :=  inst_seq_cfg.ls_base_addr_type_dist[4],
               AMO_INVALID  :=  inst_seq_cfg.ls_base_addr_type_dist[5]
            };
            }
        }
    };
    /*
    constraint base_imm_c{
        foreach(base_imm[i]){
            (base_addr_type[i] == AMO_VALID) base_imm[11] == 0;
        }
    }
    */
endclass
                           
