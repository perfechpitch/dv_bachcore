class mem_library extends uvm_object;

    base_mem #(ITCM_SIZE_KB, ITCM_BASE_ADDR) itcm;
    base_mem #(DTCM_SIZE_KB, DTCM_BASE_ADDR) dtcm;
    base_mem #(SM_SIZE_KB, SM_BASE_ADDR) sm;
    base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR) atomic_mem;

    bit log_en;

    `uvm_object_utils(mem_library)

    function new(string name="mem_library", bit log_en=1'b0);
        super.new(name);

        this.log_en = log_en;

        itcm = new("itcm", 0); // fetch no print
        dtcm = new("dtcm", log_en);

        sm = null;
        atomic_mem = null;
    endfunction : new

    function void set_log(integer log_fd);
        if(itcm != null)
            itcm.set_log(log_fd);

        if(dtcm != null)
            dtcm.set_log(log_fd);
    endfunction : set_log

    // SM is shared and owned by upper level.
    function void set_sm(base_mem #(SM_SIZE_KB, SM_BASE_ADDR) sm);
        if(sm == null) begin
            `uvm_error(get_type_name(), "set_sm() gets null SM handle")
            return;
        end

        this.sm = sm;
    endfunction : set_sm

    // Atomic memory is shared and owned by upper level.
    function void set_atomic_mem(
        base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR) atomic_mem
    );
        if(atomic_mem == null) begin
            `uvm_error(get_type_name(), "set_atomic_mem() gets null ATOMIC_MEM handle")
            return;
        end

        this.atomic_mem = atomic_mem;
    endfunction : set_atomic_mem

    // Initialize private memories.
    function void mem_lib_init();
        if(itcm == null || dtcm == null) begin
            `uvm_error(get_type_name(), "Private memory is not initialized before mem_lib_init()")
            return;
        end

        itcm.init();
        dtcm.init();
    endfunction : mem_lib_init

    local function bit is_itcm_addr(bit [31:0] addr);
        return addr >= ITCM_BASE_ADDR && addr <= ITCM_END_ADDR;
    endfunction : is_itcm_addr

    local function bit is_dtcm_addr(bit [31:0] addr);
        return addr >= DTCM_BASE_ADDR && addr <= DTCM_END_ADDR;
    endfunction : is_dtcm_addr

    local function bit is_sm_addr(bit [31:0] addr);
        return addr >= SM_BASE_ADDR && addr <= SM_END_ADDR;
    endfunction : is_sm_addr

    local function bit is_atomic_mem_addr(bit [31:0] addr);
        return addr >= ATOMIC_MEM_BASE_ADDR && addr <= ATOMIC_MEM_END_ADDR;
    endfunction : is_atomic_mem_addr

    local function bit addr_aligned(bit [1:0] size, bit [31:0] addr);
        case(size)
            2'd0: return 1'b1;
            2'd1: return addr[0] == 1'b0;
            2'd2: return addr[1:0] == 2'b00;
            default: return 1'b0;
        endcase
    endfunction : addr_aligned

    // Check REF architectural memory access.
    function bit addr_check(ref core_state_s core_state, addr_state_s addr_state);
        bit [31:0] addr;

        addr = addr_state.addr[31:0];

        case(addr_state.acc_type)
            FETCH: begin
                if(addr[0] != 1'b0) begin
                    core_state.except = INST_ADDR_MISALIGN;
                    return 1'b0;
                end
                if(!is_itcm_addr(addr)) begin
                    core_state.except = INST_ACCESS_FAULT;
                    return 1'b0;
                end
                if(itcm == null) begin
                    `uvm_error(get_type_name(), "ITCM is not initialized")
                    return 1'b0;
                end
            end

            LOAD: begin
                if(addr_state.size > 2'd2) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "Unsupported LOAD size=%0d", addr_state.size))
                    return 1'b0;
                end
                if(!addr_aligned(addr_state.size, addr)) begin
                    core_state.except = LOAD_ADDR_MISALIGN;
                    return 1'b0;
                end
                if(!is_dtcm_addr(addr) && !is_sm_addr(addr)) begin
                    core_state.except = LOAD_ACCESS_FAULT;
                    return 1'b0;
                end
                if((is_dtcm_addr(addr) && dtcm == null) ||
                   (is_sm_addr(addr) && sm == null)) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "LOAD memory is not initialized: addr=0x%08h", addr))
                    return 1'b0;
                end
            end

            STORE: begin
                if(addr_state.size > 2'd2) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "Unsupported STORE size=%0d", addr_state.size))
                    return 1'b0;
                end
                if(!addr_aligned(addr_state.size, addr)) begin
                    core_state.except = STORE_AMO_ADDR_MISALIGN;
                    return 1'b0;
                end
                if(!is_dtcm_addr(addr) && !is_sm_addr(addr)) begin
                    core_state.except = STORE_AMO_ACCESS_FAULT;
                    return 1'b0;
                end
                if((is_dtcm_addr(addr) && dtcm == null) ||
                   (is_sm_addr(addr) && sm == null)) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "STORE memory is not initialized: addr=0x%08h", addr))
                    return 1'b0;
                end
            end

            AMO: begin
                if(addr_state.size != 2'd2) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "Unsupported AMO size=%0d", addr_state.size))
                    return 1'b0;
                end
                if(!addr_aligned(addr_state.size, addr)) begin
                    core_state.except = STORE_AMO_ADDR_MISALIGN;
                    return 1'b0;
                end
                if(!is_atomic_mem_addr(addr)) begin
                    core_state.except = STORE_AMO_ACCESS_FAULT;
                    return 1'b0;
                end
                if(atomic_mem == null) begin
                    `uvm_error(get_type_name(), "ATOMIC_MEM is not initialized")
                    return 1'b0;
                end
            end

            LR: begin
                if(addr_state.size != 2'd2) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "Unsupported LR size=%0d", addr_state.size))
                    return 1'b0;
                end
                if(!addr_aligned(addr_state.size, addr)) begin
                    core_state.except = LOAD_ADDR_MISALIGN;
                    return 1'b0;
                end
                if(!is_atomic_mem_addr(addr)) begin
                    core_state.except = LOAD_ACCESS_FAULT;
                    return 1'b0;
                end
                if(atomic_mem == null) begin
                    `uvm_error(get_type_name(), "ATOMIC_MEM is not initialized")
                    return 1'b0;
                end
            end

            SC: begin
                if(addr_state.size != 2'd2) begin
                    `uvm_error(get_type_name(), $sformatf(
                        "Unsupported SC size=%0d", addr_state.size))
                    return 1'b0;
                end
                if(!addr_aligned(addr_state.size, addr)) begin
                    core_state.except = STORE_AMO_ADDR_MISALIGN;
                    return 1'b0;
                end
                if(!is_atomic_mem_addr(addr)) begin
                    core_state.except = STORE_AMO_ACCESS_FAULT;
                    return 1'b0;
                end
                if(atomic_mem == null) begin
                    `uvm_error(get_type_name(), "ATOMIC_MEM is not initialized")
                    return 1'b0;
                end
            end

            default: begin
                `uvm_error(get_type_name(), $sformatf(
                    "Unsupported memory access type=%0d", addr_state.acc_type))
                return 1'b0;
            end
        endcase

        return 1'b1;
    endfunction : addr_check

    // REF memory read.
    function bit [31:0] read_mem(ref core_state_s core_state, addr_state_s addr_state);
        bit [31:0] addr;

        addr = addr_state.addr[31:0];

        if(!addr_check(core_state, addr_state))
            return '0;

        case(addr_state.acc_type)
            FETCH:
                return itcm.read_mem(addr_state.size, addr, 1'b0);

            LOAD: begin
                if(is_dtcm_addr(addr))
                    return dtcm.read_mem(addr_state.size, addr);
                else
                    return sm.read_mem(addr_state.size, addr);
            end

            AMO, LR:
                return atomic_mem.read_mem(addr_state.size, addr);

            default: begin
                `uvm_error(get_type_name(), $sformatf(
                    "Unsupported read access type=%0d", addr_state.acc_type))
                return '0;
            end
        endcase
    endfunction : read_mem

    // REF memory write.
    function void write_mem(bit [31:0] wdata, ref core_state_s core_state, addr_state_s addr_state);
        bit [31:0] addr;

        addr = addr_state.addr[31:0];

        if(!addr_check(core_state, addr_state))
            return;

        case(addr_state.acc_type)
            STORE: begin
                if(is_dtcm_addr(addr))
                    dtcm.write_mem(addr_state.size, addr, wdata);
                else
                    sm.write_mem(addr_state.size, addr, wdata);
            end

            AMO, SC:
                atomic_mem.write_mem(addr_state.size, addr, wdata);

            default:
                `uvm_error(get_type_name(), $sformatf(
                    "Unsupported write access type=%0d", addr_state.acc_type))
        endcase
    endfunction : write_mem

    // FENCE requires all checked memory operations to be completed.
    function void fence_exe();
        if(!dtcm.op_queue_empty())
            `uvm_error(get_type_name(), "FENCE failed: DTCM operation queue is not empty")
        if(!sm.op_queue_empty())
            `uvm_error(get_type_name(), "FENCE failed: SM operation queue is not empty")
        if(!atomic_mem.op_queue_empty())
            `uvm_error(get_type_name(), "FENCE failed: ATOMIC_MEM operation queue is not empty")
    endfunction : fence_exe

    // DUT LOAD check.
    function void read_check(mem_source_e source, bit [31:0] addr);
        case(source)
            MEM_DTCM:
                dtcm.read_check(addr);

            MEM_SM:
                sm.read_check(addr);

            MEM_ITCM:
                `uvm_error(get_type_name(), $sformatf(
                    "ITCM is not a valid LOAD mem_op source: addr=0x%08h", addr))

            default:
                `uvm_error(get_type_name(), $sformatf(
                    "Unsupported memory source=%0d", source))
        endcase
    endfunction : read_check

    // DUT STORE check.
    function void write_check(
        mem_source_e source,
        bit [31:0] addr,
        bit [31:0] data,
        bit [3:0] mask
    );
        case(source)
            MEM_DTCM:
                dtcm.write_check(addr, data, mask);

            MEM_SM:
                sm.write_check(addr, data, mask);

            MEM_ITCM:
                `uvm_error(get_type_name(), $sformatf(
                    "ITCM is not a valid STORE mem_op source: addr=0x%08h", addr))

            default:
                `uvm_error(get_type_name(), $sformatf(
                    "Unsupported memory source=%0d", source))
        endcase
    endfunction : write_check

endclass : mem_library