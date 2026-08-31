// ============================================================================
// Filename             : $(CLASSNAME)_config.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_CONFIG_SV
`define $(FILENAME)_CONFIG_SV
class $(CLASSNAME)_config extends uvm_object;
    //
    // Basic variables in config class.
    //
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    virtual $(CLASSNAME)_if $(CLASSNAME)_vif;

    bit checks_enable   = 1;
    bit coverage_enable = 1;

    //
    // Declare user random config informations.
    //
    // For example:
    // rand int unsigned delay_dist[];
    // rand int unsigned cc_weight;
    
    `uvm_object_utils_begin($(CLASSNAME)_config)
        `uvm_field_enum         (uvm_active_passive_enum,   is_active,      UVM_DEFAULT)
        `uvm_field_int          (checks_enable,                             UVM_DEFAULT) 
        `uvm_field_int          (coverage_enable,                           UVM_DEFAULT)
        //`uvm_field_array_int    (delay_dist,                              UVM_DEFAULT | UVM_DEC)
        //`uvm_field_int          (cc_weight   ,                            UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    
    function new (string name = "$(CLASSNAME)_config");
        super.new(name);
    endfunction : new

    //
    // Implement constraints for user config.
    //
    // For example:
    // constraint delay_dist_c  {
    //     delay_dist.sum == 100;
    //     delay_dist.size() == 5;
    //     foreach(delay_dist[i])
    //         delay_dist[i] inside {[0:100]};
    // }

    // constraint cc_weight_c  {
    //     cc_weight inside {[0:100]};
    // }
endclass
`endif