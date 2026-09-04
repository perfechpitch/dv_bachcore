class base_inst extends uvm_object;
    //string              inst_name;
    inst_e              inst_name;
    inst_format_e       inst_format;
    string              asm_name;
    exe_unit_e          exe_unit;
//    ops_generator       ops_gen;
    register_pool       reg_pool;
    addr_space_generator addr_space_gen;
    ls_addr_generator    ls_addr_gen;

    // decode varaible
    bit[31:0]  const_ops_mask;
    bit[31:0]  const_ops_val;
    bit[31:0]      inst;

    int gen_file;
    `uvm_object_utils_begin(base_inst)
        `uvm_field_int  (inst,  UVM_DEFAULT|UVM_HEX)
        `uvm_field_int  (const_ops_mask,    UVM_DEFAULT|UVM_HEX)
        `uvm_field_int  (const_ops_val,     UVM_DEFAULT|UVM_HEX)
        `uvm_field_enum (exe_unit_e,exe_unit,       UVM_DEFAULT|UVM_HEX)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "base_inst");
      super.new(name);
    endfunction : new
    
    
    virtual function void asm_print();
    endfunction

  virtual function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg);
        bit[31:0] rand_ops;
        //ops_gen_cfg.randomize();
        //rand_ops = ops_gen.ops_gen(inst_format,ops_gen_cfg);
        ops_gen_cfg_rand(ops_gen_cfg);
        rand_ops = rand_ops_gen(ops_gen_cfg);
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & rand_ops;
        asm_print();
        return inst;
    endfunction

    virtual function bit[31:0] get_specified_inst(bit[31:0] specified_ops);
        //specified_ops = ops_gen.specified_ops_gen(inst_format,rs1,rs2,rd,imm);
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & specified_ops;
        //$display("inst_name = %0s, specified_ops=%0h, inst=%0h", inst_name, specified_ops, inst);
        asm_print();
        return inst;
    endfunction


    virtual function bit inst_match(inst_e check_inst);
        bit is_match;
        is_match = check_inst == inst_name;
        return is_match;
    endfunction


    virtual function bit[31:0]  rand_ops_gen(ops_gen_config ops_gen_cfg);
    endfunction

    virtual function void ops_gen_cfg_rand(ref ops_gen_config ops_gen_cfg);
        `RANDOMIZE_CHECK(ops_gen_cfg,"ERROR: ops gen cfg rand error!")
    endfunction
 virtual function bit [31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg,ref bit[31:0] imm);
        bit[31:0] rand_ops;
        //ops_gen_cfg.randomize();
        //rand_ops = ops_gen.ops_gen(inst_format,ops_gen_cfg);
        ops_gen_cfg_rand(ops_gen_cfg);
        rand_ops = rand_ops_gen(ops_gen_cfg);
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & rand_ops;
        asm_print();
        return inst;
    endfunction

endclass
