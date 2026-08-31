// ============================================================================
// Filename             : reset_config.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_CONFIG_SV
`define RESET_CONFIG_SV
//typedef enum {RESET_ONCE,RESET_RANDOM}reset_type_e;
class reset_config extends uvm_object;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    virtual reset_if reset_vif;

    bit checks_enable   = 1;
    bit coverage_enable = 1;

    //rand reset_type_e reset_type;
    reset_type_e      reset_type = RESET_ONCE;

    rand int unsigned delay_dist[];
    rand int unsigned next_reset_delay_dist[];

    `uvm_object_utils_begin(reset_config)
        `uvm_field_enum         (uvm_active_passive_enum,   is_active,      UVM_DEFAULT)
        `uvm_field_int          (checks_enable,                             UVM_DEFAULT) 
        `uvm_field_int          (coverage_enable,                           UVM_DEFAULT)
        `uvm_field_enum         (reset_type_e,  reset_type,                 UVM_DEFAULT)
        `uvm_field_array_int    (delay_dist,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (next_reset_delay_dist,                     UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    
    function new (string name = "reset_config");
        super.new(name);
    endfunction : new

    constraint delay_dist_c  {
        delay_dist.sum == 100;
        delay_dist.size() == 5;
        foreach(delay_dist[i])
            delay_dist[i] inside {[0:100]};
    } 

    constraint next_reset_delay_dist_c  {
        next_reset_delay_dist.sum == 100;
        next_reset_delay_dist.size() == 5;
        foreach(next_reset_delay_dist[i])
            next_reset_delay_dist[i] inside {[0:100]};
    } 

endclass
`endif