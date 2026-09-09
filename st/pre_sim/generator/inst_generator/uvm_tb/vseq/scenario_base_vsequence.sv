class scenario_base_vsequence extends inst_gen_base_vsequence;
    scenario_base_seq scenario;

    `uvm_object_utils(scenario_base_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "scenario_base_vsequence");
        super.new(name);
    endfunction

    virtual function bit get_scenario_name(output string seq_name);
        seq_name = "";
        return 1'b0;
    endfunction

    virtual function string scenario_arg_help();
        return "+scenario_name=<scenario>";
    endfunction

    virtual function scenario_base_seq create_scenario(string seq_name);
        return null;
    endfunction

    virtual task body();
        string seq_name;
        if(!get_scenario_name(seq_name))
            `uvm_fatal("SCENARIO_VSEQ", $sformatf("need %s", scenario_arg_help()))
        scenario = create_scenario(seq_name);
        if(scenario == null)
            `uvm_fatal("SCENARIO_VSEQ", $sformatf("cannot create scenario=%s", seq_name))
        scenario.run(p_sequencer.inst_gen,
                     p_sequencer.inst_seq_gen,
                     p_sequencer.inst_seq_type_gen,
                     p_sequencer.addr_space_gen);
    endtask

    virtual task post_body();
        // scenario.run() emits per-core termination and data images.
    endtask
endclass
