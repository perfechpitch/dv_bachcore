// 定向场景基类。具体 scenario 覆盖 seq_gen，内部调用 inst/API/complex 积木。
class directed_scenario_seq extends uvm_object;
    `uvm_object_utils(directed_scenario_seq)

    function new (string name = "directed_scenario_seq");
        super.new(name);
    endfunction : new

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
    endfunction
endclass
