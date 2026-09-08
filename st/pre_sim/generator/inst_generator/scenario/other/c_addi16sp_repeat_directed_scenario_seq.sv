// Reproduce and check consecutive C.ADDI16SP state updates.
// Each task first initializes x2 and its LS window through the existing base
// configuration sequence, then emits only C.ADDI16SP instructions in the
// marked repeat region.
class c_addi16sp_repeat_directed_scenario_seq extends directed_scenario_seq;
    `uvm_object_utils(c_addi16sp_repeat_directed_scenario_seq)

    function new(string name = "c_addi16sp_repeat_directed_scenario_seq");
        super.new(name);
    endfunction : new

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
        int unsigned repeat_num;
        int unsigned generated_num;

        repeat_num = 16;
        void'($value$plusargs("c_addi16sp_num=%d", repeat_num));
        if(repeat_num == 0)
            `uvm_fatal("C_ADDI16SP_REPEAT", "+c_addi16sp_num must be greater than zero")
        if(!(RVC inside inst_gen.inst_gen_cfg.support_inst_set))
            `uvm_fatal("C_ADDI16SP_REPEAT", "RVC is not enabled in support_inst_set")

        // Reconfigure for every task so the architectural x2 value and the
        // generator's SP/window metadata start from the same state.
        inst_seq_gen.ls_inst_seq.do_base_config();
        $fwrite(inst_gen.gen_file,
                "// === directed scenario: c_addi16sp_repeat count=%0d ===\n",
                repeat_num);

        generated_num = 0;
        for(int unsigned i = 0; i < repeat_num; i++) begin
            if(!inst_gen.fetch_space_avail())
                break;
            inst_gen.get_specified_rand_inst(C_ADDI16SP);
            generated_num++;
        end
        `uvm_info("C_ADDI16SP_REPEAT",
                  $sformatf("requested=%0d generated=%0d", repeat_num, generated_num),
                  UVM_LOW)
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(c_addi16sp_repeat_directed_scenario_seq, "c_addi16sp_repeat")
