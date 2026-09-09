`ifndef VU_CASE_CONFIG_SV
`define VU_CASE_CONFIG_SV
class vu_case_config extends uvm_object;
    reset_config     reset_cfg;
    inst_gen_config  inst_gen_cfg;

    `uvm_object_utils_begin(vu_case_config)
        `uvm_field_object       (reset_cfg,                                 UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (inst_gen_cfg,                              UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "vu_case_config");
        super.new(name);
        reset_cfg     = new();
        inst_gen_cfg  = new();
    endfunction : new

    function random_case();
        assert(reset_cfg.randomize());
        assert(inst_gen_cfg.randomize());
    endfunction

endclass
`endif
