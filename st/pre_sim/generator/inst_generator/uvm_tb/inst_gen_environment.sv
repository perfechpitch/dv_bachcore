 class inst_gen_environment extends uvm_env;
      inst_gen_case_config        inst_gen_case_cfg;
  
      int                             config_log;
  
      inst_generator      inst_gen;
      register_pool       reg_pool;
      inst_seq_generator  inst_seq_gen;
      inst_seq_type_generator inst_seq_type_gen;
  
      addr_space_generator    addr_space_gen;
      inst_gen_vsequencer  inst_gen_vsqr;
  
  
      // Provide implementations of virtual methods such as get_type_name and create
      `uvm_component_utils_begin(inst_gen_environment)
        `uvm_field_object(inst_gen_case_cfg, UVM_DEFAULT)
      `uvm_component_utils_end
  
      // new - constructor
      function new(string name, uvm_component parent);
          super.new(name, parent);
      endfunction : new
  
      // build_phase
      function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          if(!uvm_config_db#(inst_gen_case_config)::get(this, "", "inst_gen_case_cfg", inst_gen_case_cfg))
             `uvm_fatal("NOCFG",{"inst_gen_case_cfg must be set for: ",get_full_name(),".inst_gen_case_cfg"});
  
          addr_space_gen      = addr_space_generator::type_id::create("addr_space_gen",this);
          inst_gen            = inst_generator::type_id::create("inst_gen",this);
          inst_seq_gen        = inst_seq_generator::type_id::create("inst_seq_gen",this);
          inst_seq_type_gen   = inst_seq_type_generator::type_id::create("inst_seq_type_gen",this);
          reg_pool            = register_pool::type_id::create("reg_pool",this);
          inst_gen_vsqr       = inst_gen_vsequencer::type_id::create("inst_gen_vsqr",this);
  
          config_log = $fopen($sformatf("./log/inst_gen_config.log"),"w");
               set_report_id_action("CONFIG_LOG",UVM_LOG);
          set_report_id_file("CONFIG_LOG",config_log);

      endfunction : build_phase
  
      function void connect_phase(uvm_phase phase);

          inst_gen_vsqr.inst_seq_type_gen = inst_seq_type_gen;
          inst_gen_vsqr.inst_seq_gen = inst_seq_gen;
          inst_gen_vsqr.inst_gen_case_cfg = inst_gen_case_cfg;
          inst_gen_vsqr.inst_gen  = inst_gen;
          inst_gen_vsqr.addr_space_gen  = addr_space_gen;
  
  
          inst_seq_gen.addr_space_gen = addr_space_gen;
          inst_seq_gen.inst_gen = inst_gen;
          inst_seq_gen.safe_seq_cfg   = inst_gen_case_cfg.safe_seq_cfg;
          inst_seq_gen.except_seq_cfg = inst_gen_case_cfg.except_seq_cfg;
          inst_seq_gen.flush_seq_cfg  = inst_gen_case_cfg.flush_seq_cfg;
          inst_seq_gen.branch_seq_cfg = inst_gen_case_cfg.branch_seq_cfg;
          inst_seq_gen.ls_seq_cfg     = inst_gen_case_cfg.ls_seq_cfg;
  
          inst_seq_gen.gen_file = inst_gen_case_cfg.gen_file;
  
  
          inst_seq_type_gen.inst_seq_type_cfg = inst_gen_case_cfg.inst_seq_type_cfg;
          inst_gen.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
          inst_gen.safe_inst_gen.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
          inst_gen.flush_inst_gen.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
          inst_gen.except_inst_gen.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
          inst_gen.branch_inst_gen.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
          inst_gen.ls_inst_gen.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
  
     	  inst_gen.safe_inst_gen.csr_cfg      = inst_gen_case_cfg.csr_cfg;
          inst_gen.ls_inst_gen.csr_cfg      = inst_gen_case_cfg.csr_cfg;
          inst_gen.addr_space_gen = addr_space_gen;
      inst_gen.ls_addr_gen.share_layout = inst_gen_case_cfg.ls_seq_cfg.share_layout;
      inst_gen.ls_addr_gen.hart         = inst_gen_case_cfg.ls_seq_cfg.hart;
      inst_gen.ls_addr_gen.dtcm_base    = inst_gen_case_cfg.ls_seq_cfg.dtcm_base;
      inst_gen.ls_addr_gen.share_base   = inst_gen_case_cfg.ls_seq_cfg.share_base;
  
          addr_space_gen.addr_space_cfg = inst_gen_case_cfg.addr_space_cfg;
  
          reg_pool.csr_cfg = inst_gen_case_cfg.csr_cfg;
          reg_pool.inst_gen_cfg = inst_gen_case_cfg.inst_gen_cfg;
	  assert(reg_pool.randomize());
          inst_gen.reg_pool = reg_pool;
          inst_seq_gen.reg_pool = reg_pool;
      endfunction : connect_phase
  
      function void start_of_simulation_phase(uvm_phase phase);
          // Do something before run_phase
          `uvm_info("CONFIG_LOG",$sformatf("\ninst_gen_case_cfg       :\n%s",inst_gen_case_cfg.sprint()),UVM_LOW);
          //`uvm_info("CONFIG_LOG",$sformatf("\nreset_cfg                 :\n%s",inst_gen_case_cfg.reset_cfg.sprint()),UVM_LOW);
          //`uvm_info("CONFIG_LOG",$sformatf("\nxxx_cfg                   :\n%s",inst_gen_case_cfg.xxx_cfg.sprint()),UVM_LOW);
          // more cfg from tb args
          if(inst_gen_case_cfg.global_disable_ls == 1)begin
              inst_gen.safe_inst_gen.safe_int_ls_dist = 0;
            inst_gen.except_inst_gen.ls_except_inst_dist = 0;
        end
 
     endfunction : start_of_simulation_phase
 endclass : inst_gen_environment
                                                                              
