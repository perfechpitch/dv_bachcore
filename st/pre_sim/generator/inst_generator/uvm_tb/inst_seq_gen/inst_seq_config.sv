class inst_seq_config extends uvm_object;
    rand int unsigned seq_length_dist[$];
    `uvm_object_utils_begin(inst_seq_config)
        `uvm_field_sarray_int( seq_length_dist, UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "inst_seq_config");
      super.new(name);
    endfunction : new

    constraint seq_length_c{
        seq_length_dist.size() == 4;
        foreach(seq_length_dist[i]){
            seq_length_dist[i] inside{[0:100]};
        }
        seq_length_dist.sum() == 100;
    }

endclass
