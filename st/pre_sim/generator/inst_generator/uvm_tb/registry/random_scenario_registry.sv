class random_scenario_registry extends uvm_object;
    static uvm_object_wrapper pool[string];

    `uvm_object_utils(random_scenario_registry)

    function new(string name = "random_scenario_registry");
        super.new(name);
    endfunction

    static function bit add(string seq_name, uvm_object_wrapper wrapper);
        pool[seq_name] = wrapper;
        return 1'b1;
    endfunction

    static function string name_list();
        string names;
        bit first;
        first = 1'b1;
        foreach(pool[name]) begin
            if(first)
                names = name;
            else
                names = {names, ", ", name};
            first = 1'b0;
        end
        if(first)
            return "(none)";
        return names;
    endfunction

    function scenario_base_seq get(string seq_name);
        uvm_object       obj;
        scenario_base_seq scenario;
        if(!pool.exists(seq_name))
            `uvm_fatal("RANDOM_SEQ",
                       $sformatf("unknown random_scenario_name=%s registered=[%s]",
                                 seq_name, name_list()))
        obj = pool[seq_name].create_object(seq_name);
        if(obj == null || !$cast(scenario, obj))
            `uvm_fatal("RANDOM_SEQ",
                       $sformatf("create/cast failed random_scenario_name=%s", seq_name))
        return scenario;
    endfunction
endclass

`define RANDOM_SCENARIO_REGISTER(TYPE, NAME) \
    static bit TYPE``_random_reg = random_scenario_registry::add(NAME, TYPE::get_type());
