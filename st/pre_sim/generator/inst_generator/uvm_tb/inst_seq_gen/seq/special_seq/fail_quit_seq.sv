class fail_quit_sequence extends uvm_object;
    `uvm_object_utils_begin(fail_quit_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "fail_quit_sequence");
      super.new(name);
    endfunction : new

    //virtual function seq_gen(csr_config csr_cfg);
    function seq_gen(inst_generator inst_gen);
        `sub(0,0,0);
    endfunction
endclass 
