// Pure per-core register state. Random-selection algorithms remain in
// register_pool; these objects only preserve mutable state on a core switch.
class reg_generator_context extends uvm_object;
    bit [4:0] regs[$];
    bit [4:0] rand_reg;
    bit [4:0] disable_regs[$];
    `uvm_object_utils(reg_generator_context)
    function new(string name = "reg_generator_context");
        super.new(name);
    endfunction
endclass

class vreg_generator_context extends reg_generator_context;
    bit [3:0] emul;
    bit       vm;
    bit [4:0] vreg_group;
    `uvm_object_utils(vreg_generator_context)
    function new(string name = "vreg_generator_context");
        super.new(name);
        emul = 1;
    endfunction
endclass

class base_reg_generator_context extends reg_generator_context;
    addr_structure_s base_addr_info[$];
    `uvm_object_utils(base_reg_generator_context)
    function new(string name = "base_reg_generator_context");
        super.new(name);
    endfunction
endclass

class register_context extends uvm_object;
    bit [4:0] regs[$];
    bit [4:0] fregs[$];
    bit [4:0] vregs[$];
    bit [4:0] branch_regs[$];
    bit [4:0] base_regs[$];
    addr_structure_s sp_base_addr_info;
    bit              sp_base_valid;
    bit [4:0] imm_regs[$];
    bit [4:0] vector_imm_regs[$];
    bit [4:0] reserved_regs[$];

    reg_generator_context      gpr_gen_ctx;
    reg_generator_context      fpr_gen_ctx;
    base_reg_generator_context base_reg_gen_ctx;
    reg_generator_context      imm_reg_gen_ctx;
    vreg_generator_context     vpr_gen_ctx;
    vreg_generator_context     vector_imm_reg_gen_ctx;
    bit                        initialized;

    `uvm_object_utils(register_context)
    function new(string name = "register_context");
        super.new(name);
        gpr_gen_ctx            = new({name, "_gpr"});
        fpr_gen_ctx            = new({name, "_fpr"});
        base_reg_gen_ctx       = new({name, "_base"});
        imm_reg_gen_ctx        = new({name, "_imm"});
        vpr_gen_ctx            = new({name, "_vpr"});
        vector_imm_reg_gen_ctx = new({name, "_vector_imm"});
        initialized            = 1'b0;
        sp_base_valid          = 1'b0;
    endfunction
endclass
