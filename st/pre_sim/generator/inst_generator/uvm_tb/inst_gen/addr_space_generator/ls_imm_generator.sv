class ls_imm_generator extends uvm_object;
    ops_gen_config       ls_op_cfg;

    bit [63:0]          base_addr;
    bit [11:0]          max_positive_imm;
    bit [11:0]          max_negetive_imm;

    rand bit            ls_imm_negetive;
    rand bit [11:0]     ls_imm;
    `uvm_object_utils_begin(ls_imm_generator)
        `uvm_field_int(base_addr, UVM_DEFAULT)
        `uvm_field_int(max_positive_imm, UVM_DEFAULT)
        `uvm_field_int(max_negetive_imm, UVM_DEFAULT)
        `uvm_field_int(ls_imm_negetive, UVM_DEFAULT)
        `uvm_field_int(ls_imm, UVM_DEFAULT)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "ls_imm_generator");
        super.new(name);
    endfunction : new

    constraint ls_imm_c{
        if(ls_imm_negetive){
            //ls_imm[11] == 1'b1;
            //ls_imm[10:0] > max_negetive_imm[10:0];
            ls_imm >= max_negetive_imm;
        }
        else {
            ls_imm[11] == 1'b0;
            ls_imm <= max_positive_imm;
        }

        ls_imm[10:0] dist{
            ['h0 :'h10]   := ls_op_cfg.ls_imm_range_dist[0],
            ['h10:'h50]   := ls_op_cfg.ls_imm_range_dist[1],
            ['h50:'h7ff]  := ls_op_cfg.ls_imm_range_dist[2]
        };

        if(ls_op_cfg.ls_addr_misalign){
            (ls_imm + base_addr) % ls_op_cfg.align_bytes !=0;
        }
        else {
            (ls_imm + base_addr) % ls_op_cfg.align_bytes ==0;
        }
    }

    constraint imm_negetive_c{
        (ls_op_cfg.ls_inst_unsigned == 1) ->ls_imm_negetive == 0;
        (ls_op_cfg.ls_inst_unsigned == 0) ->ls_imm_negetive dist{
            0   := ls_op_cfg.ls_imm_negetive_dist[0],
            1   := ls_op_cfg.ls_imm_negetive_dist[1]
        };

    }
    constraint solve_c{
        solve ls_imm_negetive before ls_imm;
    }


endclass : ls_imm_generator
