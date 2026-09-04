// 对照 inst_generator：后者按 inst_type 从 queue 里取一条指令；
// 本类只负责下一段 seq 的种类，真正铺指令在 inst_seq_generator.rand_seq。
class inst_seq_type_generator extends uvm_component;
    inst_seq_type_config inst_seq_type_cfg;
    inst_seq_type_item   seq_type_item;

    `uvm_component_utils(inst_seq_type_generator)

    function new (string name, uvm_component parent);
        super.new(name, parent);
        seq_type_item = new();
    endfunction : new

    function inst_seq_type_e get_seq_type();
        if(inst_seq_type_cfg == null)
            `uvm_fatal(get_full_name(), "inst_seq_type_cfg is null")
        seq_type_item.inst_seq_type_cfg = inst_seq_type_cfg;
        if(!seq_type_item.randomize())begin
            `uvm_error(get_full_name(), "inst_seq_type_item randomize failed")
            $finish;
        end
        return seq_type_item.inst_seq_type;
    endfunction
endclass
