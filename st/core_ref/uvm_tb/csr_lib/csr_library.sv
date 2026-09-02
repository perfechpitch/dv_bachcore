class csr_library extends uvm_object;

    `uvm_object_utils(csr_library)

    `CSR_DECLARATION(  mstatus)
    `CSR_DECLARATION(  mcause)
    `CSR_DECLARATION(  mtvec)
    `CSR_DECLARATION(  mepc)
    `CSR_DECLARATION(  mtval)
    `CSR_DECLARATION(  mnvec)
    `CSR_DECLARATION(  mcountinhibit)
    `CSR_DECLARATION(  mscratch)
    `CSR_DECLARATION(  menvcfg)
    `CSR_DECLARATION(  misa)
    `CSR_DECLARATION(  mcycle)
    `CSR_DECLARATION(  minstret)

    riscv_csr csr_queue[$];
    int csr_q_size;

    bit log_en = 1'b1;
    int csr_lib_log;

    function new(string name="csr_library");
        super.new(name);

        mstatus       = new();
        mcause        = new();
        mtvec         = new();
        mepc          = new();
        mtval         = new();
        mnvec         = new();
        mcountinhibit = new();
        mscratch      = new();
        menvcfg       = new();
        misa          = new();
        mcycle        = new();
        minstret      = new();

        csr_lib_log = 0;
    endfunction : new

    function void set_log(integer log_fd);
        csr_lib_log = log_fd;

        foreach(csr_queue[i])
            csr_queue[i].csr_lib_log = csr_lib_log;
    endfunction : set_log

    function void csr_queue_gen();
        csr_queue.delete();

        csr_queue.push_back(mstatus);
        csr_queue.push_back(mcause);
        csr_queue.push_back(mtvec);
        csr_queue.push_back(mepc);
        csr_queue.push_back(mtval);
        csr_queue.push_back(mnvec);
        csr_queue.push_back(mcountinhibit);
        csr_queue.push_back(mscratch);
        csr_queue.push_back(menvcfg);
        csr_queue.push_back(misa);
        csr_queue.push_back(mcycle);
        csr_queue.push_back(minstret);

        csr_q_size = csr_queue.size();

        foreach(csr_queue[i])
            csr_queue[i].csr_lib_log = csr_lib_log;
    endfunction : csr_queue_gen

    function void reset_csr();
        mstatus.reset_csr();
        mcause.reset_csr();
        mtvec.reset_csr();
        mepc.reset_csr();
        mtval.reset_csr();
        mnvec.reset_csr();
        mcountinhibit.reset_csr();
        mscratch.reset_csr();
        menvcfg.reset_csr();
        misa.reset_csr();
        mcycle.reset_csr();
        minstret.reset_csr();
    endfunction : reset_csr

    function string csr_access(
        csr_access_type_e acc_type,
        ref core_state_s core_state,
        bit [11:0] csr_addr,
        ref bit [63:0] data
    );
        csr_acc_except_type_e acc_except;
        string csr_name;
        bit find_csr;

        find_csr = 1'b0;
        csr_name = "no_csr";
        acc_except = NONE_CSR_EXCEPT;

        for(int i=0; i<csr_q_size; i++) begin
            if(csr_queue[i].addr_match(csr_addr)) begin
                acc_except = csr_queue[i].csr_access(acc_type, data);
                csr_name = csr_queue[i].csr_name;
                find_csr = 1'b1;
                break;
            end
        end

        if(!find_csr)
            acc_except = FIND_NO_CSR;

        if(acc_except != NONE_CSR_EXCEPT) begin
            if(acc_type == INST_WRITE || acc_type == INST_READ)
                core_state.except = ILLEGAL_INST;
        end

        if(log_en && csr_lib_log)
            $fwrite(csr_lib_log,
                "# [M_MODE] %0s : csr_addr=%0h, csr_name=%0s, data=%0h, acc_except=%0s\n",
                acc_type.name(), csr_addr, csr_name, data, acc_except.name());

        return csr_name;
    endfunction : csr_access

    function void except_update_csr(core_state_s core_state);
        mepc.set_val(core_state.pc);
        mcause.except_update(core_state.except);

        case(mcause.val)
            'd2,
            'd11: mtval.set_val(64'h0);
            default: mtval.set_val(core_state.except_info);
        endcase
    endfunction : except_update_csr

    function bit [63:0] except_entry_gen();
        return mtvec.except_entry_gen();
    endfunction : except_entry_gen

    function void except_handle(ref core_state_s core_state);
        except_update_csr(core_state);

        core_state.pc = except_entry_gen();
        core_state.except = NONE_EXCEPT;
        core_state.except_info = '0;
    endfunction : except_handle

endclass : csr_library