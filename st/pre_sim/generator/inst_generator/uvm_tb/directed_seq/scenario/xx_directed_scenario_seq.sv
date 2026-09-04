// demo：定向场景只改本文件 + scenario_list.svh 的一行 include。
// 跑法：vseq 用 directed_vsequence，+directed_seq_name=xx
class xx_directed_scenario_seq extends directed_scenario_seq;
    `uvm_object_utils(xx_directed_scenario_seq)

    function new (string name = "xx_directed_scenario_seq");
        super.new(name);
    endfunction : new

    // 场景配方：调用已有下层 seq，不要在这里直接 get_rand_inst / 指令宏。
    virtual function void seq_gen(inst_gen_vsequencer vsqr);
        $fwrite(vsqr.inst_gen.gen_file, ("// === directed scenario: xx ===\n"));
        void'(vsqr.inst_seq_gen.safe_inst_seq.seq_gen());
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(xx_directed_scenario_seq, "xx")
