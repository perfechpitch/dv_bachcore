// 定向场景仓库。按 name 取出；登记由各 scenario 文件自己 add，本文件不再列场景。
class directed_seq extends uvm_object;
    static uvm_object_wrapper pool[string];

    `uvm_object_utils(directed_seq)

    function new (string name = "directed_seq");
        super.new(name);
    endfunction : new

    // 在 scenario 文件里调用（类定义之后），不要在本 class 里逐个写。
    static function bit add(string seq_name, uvm_object_wrapper w);
        pool[seq_name] = w;
        return 1'b1;
    endfunction

    static function string name_list();
        string s;
        bit    first;
        first = 1;
        foreach(pool[n])begin
            if(first) s = n;
            else      s = {s, ", ", n};
            first = 0;
        end
        if(first)
            return "(none)";
        return s;
    endfunction

    function directed_scenario_seq get(string seq_name);
        uvm_object            obj;
        directed_scenario_seq seq;
        if(!pool.exists(seq_name))begin
            `uvm_fatal("DIRECTED_SEQ",
                $sformatf("unknown directed_seq_name=%s  registered=[%s]", seq_name, name_list()))
        end
        obj = pool[seq_name].create_object(seq_name);
        if(obj == null || !$cast(seq, obj))begin
            `uvm_fatal("DIRECTED_SEQ",
                $sformatf("create/cast failed directed_seq_name=%s", seq_name))
        end
        return seq;
    endfunction
endclass

// 放在 xxx_directed_seq 的 endclass 之后，只改那个 scenario 文件：
//   `DIRECTED_SCENARIO_REGISTER(jalr_directed_seq, "jalr_seq")
`define DIRECTED_SCENARIO_REGISTER(TYPE, NAME) \
    static bit TYPE``_directed_reg = directed_seq::add(NAME, TYPE::get_type());
