class inst_seq_info_item extends uvm_object;
typedef enum {MIN,LOW,HIGH,MAX}seq_length_type_e;
    rand seq_length_type_e   seq_length_type;
    rand int seq_length;
    inst_seq_config inst_seq_cfg;
    `uvm_object_utils_begin(inst_seq_info_item)
        `uvm_field_enum(seq_length_type_e,seq_length_type, UVM_DEFAULT)
        `uvm_field_int(seq_length, UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "inst_seq_info_item");
      super.new(name);
    endfunction : new

//    constraint seq_length_type_c{
//        seq_length_type dist{
//        MIN :=  inst_seq_cfg.seq_length_dist[0],
//        LOW :=  inst_seq_cfg.seq_length_dist[1],
//        HIGH:=  inst_seq_cfg.seq_length_dist[2],
//        MAX :=  inst_seq_cfg.seq_length_dist[3]
//        };
//    }

    constraint seq_length_c{
        (seq_length_type == MIN)    -> seq_length == 'd1;
        (seq_length_type == LOW)    -> seq_length inside{[1:20]};
        (seq_length_type == HIGH)   -> seq_length inside{[20:50]};
        (seq_length_type == MAX)    -> seq_length inside{[50:100]};
    }
endclass 
