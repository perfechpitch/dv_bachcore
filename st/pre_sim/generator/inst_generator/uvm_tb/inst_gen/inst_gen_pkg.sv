package inst_gen_pkg;

    import  uvm_pkg::*;
    import  cpu_set_pkg::*;
    //  
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //  
    // For example:

    
`include "uvm_macros.svh"

`include "inst_gen_define.svh"
`include "inst_gen_e.sv"
`include "inst_gen_config.sv"
`include "csr_config.sv"
`include "ops_gen_config.sv"

`include "addr_space_generator/addr_space_e.sv"
`include "addr_space_generator/addr_space_config.sv"
`include "addr_space_generator/seg_generator.sv"
`include "addr_space_generator/seg_pool.sv"
`include "addr_space_generator/ls_imm_generator.sv"
`include "addr_space_generator/pma_config_generator.sv"
`include "addr_space_generator/pmp_config_generator.sv"
`include "addr_space_generator/pte_generator.sv"
`include "addr_space_generator/addr_space_generator.sv"

`include "ls_addr_e.sv"
`include "ls_addr_generator.sv"

`include "register_pool.sv"

`include "inst_group/base_inst.sv"
`include "inst_group/int_inst/b_type_inst.sv"
`include "inst_group/int_inst/jump_inst.sv"
`include "inst_group/int_inst/n_type_inst.sv"
`include "inst_group/int_inst/ri_type_inst.sv"
`include "inst_group/int_inst/rr_type_inst.sv"
//`include "inst_group/int_inst/s_type_inst.sv"
`include "inst_group/int_inst/ui_type_inst.sv"
`include "inst_group/load_inst.sv"
`include "inst_group/store_inst.sv"
`include "inst_group/amo_inst.sv"
`include "ri_inst_generator.sv"

`include "inst_group/float_inst/float_inst.sv"



`include "inst_name_generator.sv"
`include "inst_generator.sv"

endpackage : inst_gen_pkg
