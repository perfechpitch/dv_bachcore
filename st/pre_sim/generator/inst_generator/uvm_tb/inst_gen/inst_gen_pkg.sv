package inst_gen_pkg;

    import  uvm_pkg::*;
    import  cpu_set_pkg::*;
    import  core_context_types_pkg::*;
    import  core_context_pkg::*;
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

`include "resource/config/fetch_addr_config.sv"
`include "resource/config/ls_addr_config.sv"
`include "resource/config/register_pool_config.sv"

`include "resource/ls_addr_generator.sv"
`include "resource/fetch_addr_generator.sv"

`include "resource/register_pool.sv"

`include "inst_group/base_inst.sv"
`include "inst_group/dsa_custom_inst.sv"
`include "inst_group/int_inst/b_type_inst.sv"
`include "inst_group/other_custom_inst.sv"
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
`include "inst_group/c_inst.sv"

`include "inst_group/float_inst/float_inst.sv"



`include "inst_name_generator.sv"
`include "inst_generator.sv"

endpackage : inst_gen_pkg
