//TODO: generate int ops,fp ops,
class ops_gen_config extends uvm_object;
    rand bit rs1_eq_rs2;
    rand bit rs1_eq_rd;
    rand bit rs2_eq_rd;

    //normal imm
    rand bit[11:0] i_type_imm;
    rand bit[19:0] u_type_imm;
    //float cfg
    bit rm_illegal_en;
    rand bit[2:0] round_mode;
    



    //imm with max width 
    rand bit [20:0] rand_imm;
    bit [20:0] set_imm;

    //for ls inst
    rand bit      ls_addr_misalign_en;
    rand bit      ls_inst_unsigned;
    rand bit[3:0] align_bytes;
    rand int ls_imm_range_dist[$];
    rand int ls_imm_negetive_dist[$];
    rand int ls_addr_misalign_dist[$];
    rand bit ls_addr_misalign;




   `uvm_object_utils_begin(ops_gen_config)
        `uvm_field_int(rs1_eq_rs2, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(rs1_eq_rd, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(rs2_eq_rd, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(round_mode, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(rand_imm, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(set_imm, UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(ls_imm_range_dist,UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(ls_imm_negetive_dist,UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(ls_imm_negetive_dist,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(ls_addr_misalign_en,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(ls_addr_misalign,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(ls_inst_unsigned,UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(align_bytes,UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ops_gen_config");
      super.new(name);
    endfunction : new

    constraint rs_c{
    {rs1_eq_rs2, rs1_eq_rd, rs2_eq_rd} inside{0,1,2,4,7};
    }


    constraint rm_c{
        (rm_illegal_en == 1) -> round_mode inside{['d0:'d7]};
        (rm_illegal_en == 0) -> round_mode inside{['d0:'d4]};
    }

    constraint ls_imm_range_c{
        ls_imm_range_dist.size() == 3;
        foreach(ls_imm_range_dist[i]){
            ls_imm_range_dist[i] inside{[1:100]};//can not be [0:100]. may cause ls imm gen constraint error because ls_imm_range_dist[2] =0
        }
        ls_imm_range_dist.sum() == 100;
    }
    constraint ls_imm_negetive_c{
        ls_imm_negetive_dist.size() == 2;
        foreach(ls_imm_negetive_dist[i]){
            ls_imm_negetive_dist[i] inside{[1:100]};//can not be [0:100]. may cause ls imm gen constraint error because base=xxxffc, align bytes=8, all negetive imm choosed.
        }
        ls_imm_negetive_dist.sum() == 100;
    }
    constraint ls_addr_misalign_c{
        ls_addr_misalign_dist.size() == 2;
        foreach(ls_addr_misalign_dist[i]){
            ls_addr_misalign_dist[i] inside{[0:100]};
        }
        ls_addr_misalign_dist.sum() == 100;
    }

    constraint ls_addr_misalgin_c{
        (ls_addr_misalign_en == 0 || align_bytes == 1) -> ls_addr_misalign == 0;
        (ls_addr_misalign_en == 1 && align_bytes != 1) -> ls_addr_misalign dist{
            0:= ls_addr_misalign_dist[0],
            1:= ls_addr_misalign_dist[1]
        };
    }
endclass
