class ls_linear_seq extends base_inst_sequence;
    ls_seq_info_item    ls_seq_info;
    `uvm_object_utils_begin(ls_linear_seq)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_linear_seq");
      super.new(name);
      ls_seq_info = new();
    endfunction : new

    virtual function void sub_seq_gen(ls_seq_info_item  ls_seq_info,inst_generator inst_gen);
        bit[31:0] ls_imm;
        int ls_linear_stride;
        int seq_length;
        seq_length = ls_seq_info.seq_length;
        ls_imm = 0;

        for(int i=0; i<seq_length; i++)begin
            inst_gen.get_rand_ls_with_imm(ls_imm);
            if($value$plusargs("ls_linear_stride=%0h",ls_linear_stride))
            ls_imm  = i * ls_linear_stride;
            else
            ls_imm  = i * 'h8;  
        end

    endfunction
endclass 
