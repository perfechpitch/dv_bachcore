class task_info_config extends uvm_object;
    rand int unsigned  task_num;
    bit[63:0]          start_pc[$];
    int                log_file;

    `uvm_object_utils_begin(task_info_config)
        `uvm_field_int(task_num, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "task_info_config");
        super.new(name);
        log_file = 0;
    endfunction : new

    constraint task_num_c{
        task_num inside {[1:8]};
    }

    function void init();
        start_pc.delete();
        if(log_file)
            $fclose(log_file);
        log_file = $fopen("./log/task_info.log", "w");
        $fwrite(log_file, ("# task_info.log  task_num=%0d  fetch_start=0\n"), task_num);
        $fwrite(log_file, ("# task_id  start_pc      end_pc        inst_num\n"));
    endfunction

    function void record_start(int task_id, bit[63:0] pc);
        if(task_id < start_pc.size())
            start_pc[task_id] = pc;
        else
            start_pc.push_back(pc);
        if(log_file)
            $fwrite(log_file, ("# switch task_id=%0d start_pc=0x%016h\n"), task_id, pc);
        `uvm_info("TASK_INFO", $sformatf("task_id=%0d start_pc=0x%016h", task_id, pc), UVM_LOW)
    endfunction

    function void record_end(int task_id, bit[63:0] end_pc);
        bit[63:0] sp;
        int unsigned n;
        sp = (task_id < start_pc.size()) ? start_pc[task_id] : 0;
        n  = (end_pc >= sp) ? ((end_pc - sp) / 4) : 0;
        if(log_file)
            $fwrite(log_file, ("  %0d        0x%016h  0x%016h  %0d\n"),
                    task_id, sp, end_pc, n);
        `uvm_info("TASK_INFO", $sformatf("task_id=%0d start_pc=0x%016h end_pc=0x%016h inst_num=%0d", task_id, sp, end_pc, n), UVM_LOW)
    endfunction

    function void finish_log();
        if(log_file)begin
            $fwrite(log_file, ("# done  tasks=%0d\n"), start_pc.size());
            $fclose(log_file);
            log_file = 0;
        end
    endfunction
endclass
