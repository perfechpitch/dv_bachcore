typedef enum{SINGLE_EXCEPT_INST,JALR_EXCEPT_SEQ}except_seq_type_e;
class except_seq_info_item extends inst_seq_info_item;
    //override inst_seq_cfg
    except_seq_config inst_seq_cfg;

    rand except_seq_type_e except_seq_type;
    rand int unsigned except_inst_dist[$];

    `uvm_object_utils_begin(except_seq_info_item)

        `uvm_field_enum(except_seq_type_e ,except_seq_type,UVM_DEFAULT)
        `uvm_field_sarray_int(except_inst_dist, UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "except_seq_info_item");
      super.new(name);
    endfunction : new

    constraint except_seq_type_c{
        except_seq_type dist{
        SINGLE_EXCEPT_INST := inst_seq_cfg.except_seq_type_dist[0],
        JALR_EXCEPT_SEQ := inst_seq_cfg.except_seq_type_dist[1]
        };
    }
    constraint dist_c{
        except_inst_dist.size() == 6;
        except_inst_dist.sum() == 100;
        foreach(except_inst_dist[i]){
            except_inst_dist[i] inside{[0:100]};
        }
        if(inst_seq_cfg.disable_misalign_branch)    except_inst_dist[3] == 0;

    }

    constraint seq_length_type_c{
        seq_length_type dist{
        MIN :=  inst_seq_cfg.seq_length_dist[0],
        LOW :=  inst_seq_cfg.seq_length_dist[1],
        HIGH:=  inst_seq_cfg.seq_length_dist[2],
        MAX :=  inst_seq_cfg.seq_length_dist[3]
        };
    }
    constraint seq_length_c{
        (seq_length_type == MIN)    -> seq_length == 'd1;
        (seq_length_type == LOW)    -> seq_length inside{[1:2]};
        (seq_length_type == HIGH)   -> seq_length inside{[2:4]};
        (seq_length_type == MAX)    -> seq_length inside{[4:8]};
    }
endclass