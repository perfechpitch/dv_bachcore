class inst_seq_generator extends uvm_component;

    inst_generator      inst_gen;
    register_pool       reg_pool;
    addr_space_generator    addr_space_gen;

    safe_inst_sequence      safe_inst_seq;
    flush_inst_sequence     flush_inst_seq;
    except_inst_sequence    except_inst_seq;
    branch_inst_sequence    branch_inst_seq;
    ls_inst_sequence        ls_inst_seq;
    wfi_inst_sequence       wfi_inst_seq;
    pass_quit_sequence      pass_quit_seq;

    safe_seq_config     safe_seq_cfg;
    except_seq_config   except_seq_cfg;
    inst_seq_config     flush_seq_cfg;
    branch_seq_config   branch_seq_cfg;
    ls_seq_config       ls_seq_cfg;


    int inst_seq_log;
    int gen_file;

    `uvm_component_utils_begin(inst_seq_generator)
    `uvm_component_utils_end

function new (string name, uvm_component parent);
      super.new(name, parent);
        safe_inst_seq     = new();
        flush_inst_seq    = new();
        except_inst_seq   = new();
        branch_inst_seq   = new();
        ls_inst_seq       = new();
        wfi_inst_seq      = new();
        pass_quit_seq     = new();

    endfunction : new

    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        inst_seq_log = $fopen($sformatf("./log/inst_seq.log"),"w");
        set_report_id_action("INST_SEQ_LOG",UVM_LOG);
        set_report_id_file("INST_SEQ_LOG",inst_seq_log);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction : connect_phase

task pre_main_phase(uvm_phase phase);
    //if do this in connect phase,  will get null pointer? phase work from downside to upside?
        safe_inst_seq.inst_gen     = inst_gen;
        flush_inst_seq.inst_gen    = inst_gen;
        except_inst_seq.inst_gen   = inst_gen;
        branch_inst_seq.inst_gen   = inst_gen;
        ls_inst_seq.inst_gen       = inst_gen;
        wfi_inst_seq.inst_gen      = inst_gen;
        safe_inst_seq.reg_pool     = reg_pool;
        flush_inst_seq.reg_pool    = reg_pool;
        except_inst_seq.reg_pool   = reg_pool;
        branch_inst_seq.reg_pool   = reg_pool;
        ls_inst_seq.reg_pool       = reg_pool;
        wfi_inst_seq.reg_pool      = reg_pool;
        safe_inst_seq.addr_space_gen     = addr_space_gen;
        flush_inst_seq.addr_space_gen    = addr_space_gen;
        except_inst_seq.addr_space_gen   = addr_space_gen;
        branch_inst_seq.addr_space_gen   = addr_space_gen;
        ls_inst_seq.addr_space_gen       = addr_space_gen;
        wfi_inst_seq.addr_space_gen      = addr_space_gen;

        branch_inst_seq.branch_seq_cfg  = this.branch_seq_cfg;
        ls_inst_seq.ls_seq_cfg          = this.ls_seq_cfg;
        safe_inst_seq.safe_seq_cfg      = this.safe_seq_cfg;
        flush_inst_seq.flush_seq_cfg    = this.flush_seq_cfg;
        except_inst_seq.except_seq_cfg  = this.except_seq_cfg;
        except_inst_seq.branch_seq_cfg  = this.branch_seq_cfg;

    endtask
    function void do_pass_quit_seq(inst_generator  inst_gen);
        pass_quit_seq.seq_gen(inst_gen);
    endfunction
    function void rand_seq(inst_seq_type_e  inst_seq_type);
        inst_seq_info_item  inst_seq_info;
        if(!ls_inst_seq.base_initial)begin
            ls_inst_seq.do_base_config();
        end
	case(inst_seq_type)
            SAFE_INST_SEQ   : inst_seq_info = safe_inst_seq.seq_gen();
            FLUSH_INST_SEQ  : inst_seq_info = flush_inst_seq.seq_gen();
            EXCEPT_INST_SEQ : inst_seq_info = except_inst_seq.seq_gen();
            BRANCH_INST_SEQ : inst_seq_info = branch_inst_seq.seq_gen();
            LS_INST_SEQ     : inst_seq_info = ls_inst_seq.seq_gen();
            WFI_INST_SEQ    : inst_seq_info = wfi_inst_seq.seq_gen();
        endcase
        //$fwrite(gen_file,"/*\n");
        //$fwrite(gen_file,"%s\n",inst_seq_info.sprint());
        //$fwrite(gen_file,"*/\n");
        //`uvm_info("INST_SEQ_LOG",$sformatf("\ninst_seq_type       :\n%s",inst_seq_type),UVM_LOW);
        //`uvm_info("INST_SEQ_LOG",$sformatf("\ninst_seq_info       :\n%s",inst_seq_info.sprint()),UVM_LOW);
        `uvm_info($psprintf("%s","INST_SEQ_LOG"),$psprintf("#--------- %s ---------------",inst_seq_type),UVM_LOW);
        `uvm_info($psprintf("%s","INST_SEQ_LOG"),$psprintf("%s",inst_seq_info.sprint()),UVM_LOW);
    endfunction
endclass : inst_seq_generator
