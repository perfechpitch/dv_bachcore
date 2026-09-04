class ri_inst_generator extends uvm_object;
    int gen_file;
    // new - constructor 
    function new (string name = "ri_inst_generator");
        super.new(name);
    endfunction : new 
    `uvm_object_param_utils(ri_inst_generator)
    function bit[31:0] get_rand_inst(); 
        asm_print(); 
        return 0; 
    endfunction 
    function void asm_print(); 
        //$fwrite(gen_file,`N_TYPE_ASM_STRING,`N_TYPE_ASM_VAL);
        $fwrite(gen_file,".insn 0x00000000//\t %8s\n",RI);
    endfunction
endclass 
              