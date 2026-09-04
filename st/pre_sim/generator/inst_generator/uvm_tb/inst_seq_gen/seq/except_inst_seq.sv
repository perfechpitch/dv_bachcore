class except_inst_sequence extends base_inst_sequence;
    except_seq_config       except_seq_cfg;
    branch_seq_config       branch_seq_cfg;
    except_seq_info_item    except_seq_info;


    inst_generator          inst_gen;
    addr_space_generator    addr_space_gen;
    jalr_sequence           jalr_seq;
    `uvm_object_utils_begin(except_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "except_inst_sequence");
      super.new(name);
      except_seq_info = new();
      jalr_seq = new();
    endfunction : new

    virtual function except_seq_info_item seq_gen();
        int seq_length;
        except_seq_info.inst_seq_cfg = except_seq_cfg;
        assert(except_seq_info.randomize());
        seq_length = except_seq_info.seq_length;
         

        case(except_seq_info.except_seq_type)
            SINGLE_EXCEPT_INST   :begin
                inst_gen.except_inst_gen.ebreak_inst_dist     = except_seq_info.except_inst_dist[0];
                inst_gen.except_inst_gen.ecall_inst_dist      = except_seq_info.except_inst_dist[1];
                inst_gen.except_inst_gen.dret_inst_dist       = except_seq_info.except_inst_dist[2];
                inst_gen.except_inst_gen.branch_misalign_dist = except_seq_info.except_inst_dist[3];
                inst_gen.except_inst_gen.ls_except_inst_dist  = except_seq_info.except_inst_dist[4];
                inst_gen.except_inst_gen.ri_inst_dist         = except_seq_info.except_inst_dist[5];
                inst_gen.insert_inst(seq_length,EXCEPT_INST);
            end
            JALR_EXCEPT_SEQ     :begin
                jalr_seq.sub_seq_gen(branch_seq_cfg, inst_gen, addr_space_gen, FETCH_INVALID);
            end
        endcase

        return except_seq_info;
    endfunction
endclass 
