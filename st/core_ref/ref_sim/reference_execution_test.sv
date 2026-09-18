class reference_execution_test extends test;
    `uvm_component_utils(reference_execution_test)

    string task_info_path;
    task_info_s tasks[$];

    function new(string name="reference_execution_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void parse_task_info();
        int fd;
        int unsigned value;
        int current_valid;
        string line;
        string unit;
        task_info_s current;
        task_info_s swap;
        string fallback_type;

        if(!$value$plusargs("TASK_INFO_PATH=%s", task_info_path)) begin
            current = '{default:'0};
            current.dsa_type = DSA_MMIO_VU;
            if($value$plusargs("CORE_DSA_TYPE=%s", fallback_type)) begin
                case(fallback_type.toupper())
                    "VU":  current.dsa_type = DSA_MMIO_VU;
                    "MU":  current.dsa_type = DSA_MMIO_MU;
                    "DTE": current.dsa_type = DSA_MMIO_DTE;
                    default: `uvm_fatal("REF_EXEC", $sformatf(
                        "unsupported +CORE_DSA_TYPE=%s", fallback_type))
                endcase
            end
            current.start_pc = core_itcm_base(current.dsa_type);
            if($value$plusargs("TASK_START_PC=%h", value))
                current.start_pc = value;
            if($value$plusargs("TASK_ID=%d", value))
                current.task_id = value[5:0];
            if($value$plusargs("STREAM_ID=%d", value))
                current.stream_id = value[3:0];
            if($value$plusargs("UID=%d", value))
                current.user_id = value[15:0];
            if($value$plusargs("PID=%d", value))
                current.path_id = value[5:0];
            if($value$plusargs("VCID=%d", value))
                current.vc_id = value[1:0];
            tasks.push_back(current);
            core_num = 1;
            `uvm_info("REF_EXEC", $sformatf(
                "TASK_INFO_PATH absent; use single-task fallback core=%0s pc=%08h",
                current.dsa_type.name, current.start_pc), UVM_LOW)
            return;
        end
        fd = $fopen(task_info_path, "r");
        if(fd == 0)
            `uvm_fatal("REF_EXEC", $sformatf(
                "cannot open task input: %s", task_info_path))

        current_valid = 0;
        current = '{default:'0};
        while($fgets(line, fd)) begin
            if($sscanf(line, " \"task_id\": %d", value) == 1) begin
                if(current_valid)
                    tasks.push_back(current);
                current = '{default:'0};
                current.task_id = value[5:0];
                current_valid = 1;
            end
            else if(current_valid &&
                    $sscanf(line, " \"start_pc\": \"0x%h\"", value) == 1)
                current.start_pc = value;
            else if(current_valid &&
                    $sscanf(line, " \"stream_id\": %d", value) == 1)
                current.stream_id = value[3:0];
            else if(current_valid &&
                    $sscanf(line, " \"uid\": %d", value) == 1)
                current.user_id = value[15:0];
            else if(current_valid &&
                    $sscanf(line, " \"user_id\": %d", value) == 1)
                current.user_id = value[15:0];
            else if(current_valid &&
                    $sscanf(line, " \"pid\": %d", value) == 1)
                current.path_id = value[5:0];
            else if(current_valid &&
                    $sscanf(line, " \"path_id\": %d", value) == 1)
                current.path_id = value[5:0];
            else if(current_valid &&
                    $sscanf(line, " \"vcid\": %d", value) == 1)
                current.vc_id = value[1:0];
            else if(current_valid &&
                    $sscanf(line, " \"vc_id\": %d", value) == 1)
                current.vc_id = value[1:0];
            else if(current_valid &&
                    $sscanf(line, " \"execute_unit\": \"%s", unit) == 1) begin
                if(unit.len() >= 2 && unit.substr(0, 1).tolower() == "vu")
                    current.dsa_type = DSA_MMIO_VU;
                else if(unit.len() >= 2 && unit.substr(0, 1).tolower() == "mu")
                    current.dsa_type = DSA_MMIO_MU;
                else if(unit.len() >= 3 && unit.substr(0, 2).tolower() == "dte")
                    current.dsa_type = DSA_MMIO_DTE;
                else
                    `uvm_fatal("REF_EXEC", $sformatf(
                        "unsupported execute_unit in line: %s", line))
            end
        end
        if(current_valid)
            tasks.push_back(current);
        $fclose(fd);

        if(tasks.size() == 0)
            `uvm_fatal("REF_EXEC", "Task[] must contain at least one task")

        // Scene JSON describes the RV-core-local start PC. Reference memory
        // images use global system addresses, so translate the entry point to
        // the selected core's global ITCM window before execution.
        foreach(tasks[i])
            tasks[i].start_pc = core_itcm_base(tasks[i].dsa_type) +
                                tasks[i].start_pc;

        // Reject duplicate upstream identity before ordering the execution.
        for(int i=0; i<tasks.size(); i++)
            for(int j=i+1; j<tasks.size(); j++) begin
                if(tasks[i].task_id == tasks[j].task_id)
                    `uvm_fatal("REF_EXEC", $sformatf(
                        "duplicate task_id=%0d", tasks[i].task_id))
                if(tasks[j].task_id < tasks[i].task_id) begin
                    swap = tasks[i];
                    tasks[i] = tasks[j];
                    tasks[j] = swap;
                end
            end

        core_num = 1;
        for(int i=1; i<tasks.size(); i++)
            if(tasks[i].dsa_type != tasks[0].dsa_type)
                core_num = 3;
    endfunction

    virtual function bit vmem_uses_word_address();
        return 1'b1;
    endfunction

    virtual function dsa_mmio_type_e configured_dsa_type(int index);
        if(core_num == 1)
            return tasks[0].dsa_type;
        case(index)
            0: return DSA_MMIO_VU;
            1: return DSA_MMIO_MU;
            default: return DSA_MMIO_DTE;
        endcase
    endfunction

    function void build_phase(uvm_phase phase);
        parse_task_info();
        super.build_phase(phase);
    endfunction

    task main_phase(uvm_phase phase);
        int index;

        phase.raise_objection(this);
        init_ref_memory();
        foreach(tasks[i]) begin
            index = dispatch_task(tasks[i]);
            if(index < 0)
                `uvm_fatal("REF_EXEC", $sformatf(
                    "cannot dispatch task_id=%0d", tasks[i].task_id))
            execute_program(core_ref[index]);
        end
        $display("**** REFERENCE EXECUTION PASS tasks=%0d cores=%0d ****",
            tasks.size(), core_num);
        phase.drop_objection(this);
    endtask
endclass
