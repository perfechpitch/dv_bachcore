// 抽 seq 类型的旋钮。test_feature_convert 先改 disable/enable，
// random_sub_config 再 randomize() 填 dist，和 inst_gen_config 的角色对应。
class inst_seq_type_config extends uvm_object;
    bit safe_seq_disable   = 0;
    bit ls_seq_disable     = 0;
    bit branch_seq_disable = 0;
    bit flush_seq_enable   = 0;
    bit except_seq_enable  = 0;
    bit wfi_seq_enable     = 0;

    rand int unsigned safe_seq_dist;
    rand int unsigned ls_seq_dist;
    rand int unsigned branch_seq_dist;
    rand int unsigned flush_seq_dist;
    rand int unsigned except_seq_dist;
    rand int unsigned wfi_seq_dist;

    `uvm_object_utils_begin(inst_seq_type_config)
        `uvm_field_int(safe_seq_disable,   UVM_DEFAULT)
        `uvm_field_int(ls_seq_disable,     UVM_DEFAULT)
        `uvm_field_int(branch_seq_disable, UVM_DEFAULT)
        `uvm_field_int(flush_seq_enable,   UVM_DEFAULT)
        `uvm_field_int(except_seq_enable,  UVM_DEFAULT)
        `uvm_field_int(wfi_seq_enable,     UVM_DEFAULT)
        `uvm_field_int(safe_seq_dist,      UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(ls_seq_dist,        UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(branch_seq_dist,    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(flush_seq_dist,     UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(except_seq_dist,    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(wfi_seq_dist,       UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "inst_seq_type_config");
        super.new(name);
    endfunction : new

    constraint dist_c{
        if(safe_seq_disable)   {safe_seq_dist   == 0;}
        else                   {safe_seq_dist   inside {[0:100]};}
        if(ls_seq_disable)     {ls_seq_dist     == 0;}
        else                   {ls_seq_dist     inside {[0:100]};}
        if(branch_seq_disable) {branch_seq_dist == 0;}
        else                   {branch_seq_dist inside {[0:100]};}
        if(!flush_seq_enable)  {flush_seq_dist  == 0;}
        else                   {flush_seq_dist  inside {[0:100]};}
        if(!except_seq_enable) {except_seq_dist == 0;}
        else                   {except_seq_dist inside {[0:100]};}
        if(!wfi_seq_enable)    {wfi_seq_dist    == 0;}
        else                   {wfi_seq_dist    inside {[0:100]};}

        (safe_seq_dist + ls_seq_dist + branch_seq_dist
         + flush_seq_dist + except_seq_dist + wfi_seq_dist) == 100;
    }
endclass
