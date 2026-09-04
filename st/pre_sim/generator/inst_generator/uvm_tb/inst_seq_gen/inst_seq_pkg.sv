package inst_seq_pkg;
    import  uvm_pkg::*;
    import  inst_seq_type_pkg::*;
    import  inst_gen_pkg::*;
    import  cpu_set_pkg::*;
    //  
    // If any files in this package need reference a class in other
    // package, user should import the package at here ,and explicitly
    // indicate that association.
    //  
    // For example:
    // import  xxxx_pkg::*;
    
`include "uvm_macros.svh"

`define asm_log(A,B) $fwrite(``A,``B);
`define asm_log_para(A,B,C) $fwrite(``A,``B,``C);
`include "inst_seq_config.sv"
`include "safe_seq_config.sv"
`include "branch_seq_config.sv"
`include "ls_seq_config.sv"
`include "except_seq_config.sv"

`include "item/inst_seq_info_item.sv"
`include "item/branch_seq_info_item.sv"
`include "item/loop_seq_info_item.sv"

`include "item/ls_base_info_item.sv"
`include "item/ls_seq_info_item.sv"

`include "item/except_seq_info_item.sv"

`include "./seq/special_seq/except_handle_seq.sv"
`include "./seq/special_seq/li_seq.sv"
`include "./seq/special_seq/pass_quit_seq.sv"
`include "./seq/special_seq/fail_quit_seq.sv"
`include "./seq/special_seq/config_seq.sv"
`include "./seq/base_inst_seq.sv"

`include "./seq/branch_seq/single_branch_seq.sv"
`include "./seq/branch_seq/loop_seq.sv"
`include "./seq/branch_seq/jalr_seq.sv"
`include "./seq/branch_seq/branch_inst_seq.sv"

`include "./seq/ls_seq/ls_base_config_seq.sv"
`include "./seq/ls_seq/ls_rand_seq.sv"
`include "./seq/ls_seq/ls_linear_seq.sv"
`include "./seq/ls_seq/lrsc_seq.sv"
`include "./seq/ls_seq/ls_memcpy_seq.sv"

`include "./seq/ls_seq/ls_inst_seq.sv"

`include "./seq/except_inst_seq.sv"
`include "./seq/flush_inst_seq.sv"
`include "./seq/safe_inst_seq.sv"
`include "./seq/wfi_inst_seq.sv"

`include "./seq/asm_seq/base_asm_seq.sv"

`include "inst_seq_generator.sv"
endpackage : inst_seq_pkg
                                   
