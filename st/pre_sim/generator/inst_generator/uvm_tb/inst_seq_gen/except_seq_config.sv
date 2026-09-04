class except_seq_config extends inst_seq_config;
    bit float_en;
    bit disable_misalign_branch = 0;
    bit ls_inst_disable = 0;
    rand int unsigned except_seq_type_dist[$];
    rand int unsigned except_inst_dist[$];
    `uvm_object_utils_begin(except_seq_config)
        `uvm_field_sarray_int(except_seq_type_dist, UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(except_inst_dist, UVM_DEFAULT)
        `uvm_field_int(disable_misalign_branch,UVM_DEFAULT)
        `uvm_field_int(ls_inst_disable,UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "except_seq_config");
      super.new(name);
    endfunction : new



    constraint except_seq_type_dist_c{
        except_seq_type_dist.size() == 2;
        foreach(except_seq_type_dist[i]){
            except_seq_type_dist[i] inside{[0:100]};
        }
        except_seq_type_dist.sum() == 100;
    }

    constraint except_inst_dist_c{
        except_inst_dist.size() == 6;
        foreach(except_inst_dist[i]){
            if(disable_misalign_branch && i==3 || ls_inst_disable && i==4)
                except_inst_dist[i] ==0;
            else
                except_inst_dist[i] inside{[0:100]};
        }
        except_inst_dist.sum() == 100;
    }
endclass 
