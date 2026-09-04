class inst_gen_vsequencer extends uvm_sequencer;
  
      inst_generator          inst_gen;
      addr_space_generator    addr_space_gen;
      inst_seq_generator      inst_seq_gen;
      inst_seq_type_generator inst_seq_type_gen;
      
      inst_gen_case_config    inst_gen_case_cfg;
      
      `uvm_component_utils_begin(inst_gen_vsequencer)
      `uvm_component_utils_end
        
      function new (string name, uvm_component parent);
        super.new(name, parent);
      endfunction : new
      
      // build_phase
      function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          // if(!uvm_config_db#($XXXX_config)::get(this,"","XXXX_cfg",XXXX_cfg))
          //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".XXXX_cfg"});
          // XXXX_vif = XXXX_cfg.XXXX_vif;
          // except_seq = except_seq::type_id::create("except_seq");
      endfunction : build_phase
  
  endclass : inst_gen_vsequencer
