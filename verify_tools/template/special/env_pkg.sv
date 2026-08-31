`ifndef $(FILENAME)_ENV_PKG_SV
`define $(FILENAME)_ENV_PKG_SV

//`include "$(CLASSNAME)_enum_pkg.sv"
//`include "xxx_pkg.sv"
//`include "$(CLASSNAME)_ref_pkg.sv"
//`include "$(CLASSNAME)_mon_pkg.sv"
//`include "$(CLASSNAME)_scb_pkg.sv"
//`include "reset_pkg.sv"

package $(CLASSNAME)_env_pkg;

    import  uvm_pkg::*;
    //import  $(CLASSNAME)_enum_pkg::*;
    //import  xxx_pkg::*;
    //import  $(CLASSNAME)_ref_pkg::*;
    //import  $(CLASSNAME)_scb_pkg::*;
    //import  reset_pkg::*;
    
`include "uvm_macros.svh"
`include "$(CLASSNAME)_case_config.sv"
`include "$(CLASSNAME)_vsequencer.sv"
`include "./vseq/$(CLASSNAME)_base_vsequence.sv"
`include "./vseq/$(CLASSNAME)_vsequence.sv"
`include "$(CLASSNAME)_environment.sv"
endpackage : $(CLASSNAME)_env_pkg
`endif