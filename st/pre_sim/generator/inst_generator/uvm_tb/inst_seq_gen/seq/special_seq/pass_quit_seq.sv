class pass_quit_sequence extends uvm_object;
    `uvm_object_utils_begin(pass_quit_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "pass_quit_sequence");
      super.new(name);
    endfunction : new

    //virtual function seq_gen(csr_config csr_cfg);
    function seq_gen(inst_generator inst_gen);
        `add(0,0,0);
    endfunction
endclass
