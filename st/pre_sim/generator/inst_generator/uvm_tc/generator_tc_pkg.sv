
package tc_pkg;
    import  uvm_pkg::*;
    import  inst_gen_env_pkg::*;
    import  scenario_seq_pkg::*;
    import  directed_registry_pkg::*;
    import  random_registry_pkg::*;


`include "uvm_macros.svh"

`include "base_case/rand_inst_test.sv"
`include "rand_flush_except_test.sv"
`include "directed_inst_test.sv"
`include "random_scenario_test.sv"

endpackage : tc_pkg
