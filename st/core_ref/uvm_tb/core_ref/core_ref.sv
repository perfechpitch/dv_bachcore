`uvm_analysis_imp_decl(_retire_in)
`uvm_analysis_imp_decl(_reg_update)
`uvm_analysis_imp_decl(_mem_op)

class core_reference extends uvm_component;

    uvm_analysis_imp_retire_in #(inst_retire_structure, core_reference) retire_in_imp;
    uvm_analysis_imp_reg_update #(reg_update_s, core_reference) reg_update_imp;
    uvm_analysis_imp_mem_op #(mem_op_s, core_reference) mem_op_imp;

    core_ref_config core_ref_cfg;
    inst_library inst_lib;
    csr_library csr_lib;
    mem_library mem_lib;
    dsa_mem_library dsa_mem_lib;
    dsa_mmio_library dsa_mmio_lib;
    vu_inst_library vu_inst_lib;

    int unsigned core_id;
    bit core_id_valid;

    reg_data_s gpr_s;
    reg_data_s fpr_s;
    vreg_data_s vpr_s;
    core_state_s core_state;

    int retire_cnt;
    bit log_en = 1'b1;
    int inst_exe_log;
    string inst_exe_log_name;

    `uvm_component_utils(core_reference)

    function new(string name, uvm_component parent);
        super.new(name, parent);

        retire_in_imp = new("retire_in_imp", this);
        reg_update_imp = new("reg_update_imp", this);
        mem_op_imp = new("mem_op_imp", this);

        inst_lib = new();
        csr_lib = new();
        mem_lib = new("mem_lib", log_en);
        dsa_mem_lib = new("dsa_mem_lib", log_en);
        dsa_mmio_lib = new();
        vu_inst_lib = new();

        core_id = '0;
        core_id_valid = 1'b0;
        inst_exe_log = 0;
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(core_ref_config)::get(this, "", "core_ref_cfg", core_ref_cfg))
            `uvm_fatal("NOCFG", {"core_ref_cfg must be set for: ", get_full_name()})

        inst_lib.support_inst_set = core_ref_cfg.support_inst_set;
    endfunction : build_phase

    extern virtual task reset_phase(uvm_phase phase);
    extern virtual function void set_core_id(int unsigned core_id);
    extern virtual function void open_log();
    extern virtual function void ref_reset();
    extern virtual function void write_retire_in(inst_retire_structure retire_s);
    extern virtual function void write_reg_update(reg_update_s reg_update);
    extern virtual function void write_mem_op(mem_op_s mem_op);
    extern virtual function void do_retire_inst();

endclass : core_reference

function void core_reference::set_core_id(int unsigned core_id);
    if(core_id_valid) begin
        if(this.core_id != core_id)
            `uvm_error(get_type_name(), $sformatf(
                "Core ID already configured: old=%0d new=%0d",
                this.core_id, core_id))
        return;
    end

    this.core_id = core_id;
    core_id_valid = 1'b1;
endfunction : set_core_id

function void core_reference::open_log();
    if(!log_en)
        return;

    if(inst_exe_log != 0) begin
        $fclose(inst_exe_log);
        inst_exe_log = 0;
    end

    if(core_id_valid)
        inst_exe_log_name = $sformatf("log/core%0d_core_ref.log", core_id);
    else
        inst_exe_log_name = "log/core_ref.log";

    inst_exe_log = $fopen(inst_exe_log_name, "w");

    if(inst_exe_log == 0) begin
        `uvm_error(get_type_name(), $sformatf(
            "Cannot open core_ref log file: %s", inst_exe_log_name))
        return;
    end

    inst_lib.inst_exe_log = inst_exe_log;
    vu_inst_lib.set_log(inst_exe_log);
endfunction : open_log

task core_reference::reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    open_log();

    csr_lib.csr_queue_gen();
    inst_lib.inst_queue_gen();

    csr_lib.set_log(inst_exe_log);
    mem_lib.set_log(inst_exe_log);
    dsa_mem_lib.set_log(inst_exe_log);
    dsa_mmio_lib.set_log(inst_exe_log);

    mem_lib.mem_lib_init();

    ref_reset();
endtask : reset_phase

function void core_reference::ref_reset();
    core_state.pc = 0;
    core_state.except = NONE_EXCEPT;
    core_state.except_info = '0;
    core_state.lrbit = 1'b0;

    retire_cnt = 0;
    gpr_s = '0;
    fpr_s = '0;
    vpr_s = '0;

    csr_lib.reset_csr();
    dsa_mmio_lib.reset_mmio();
endfunction : ref_reset

function void core_reference::write_retire_in(inst_retire_structure retire_s);
    if(retire_s.retire_num > 2) begin
        `uvm_error(get_type_name(), $sformatf(
            "Invalid retire_num=%0d", retire_s.retire_num))
        return;
    end

    for(int i=0; i<retire_s.retire_num; i++) begin
        if(core_state.pc != retire_s.retire_pc[i]) begin
            `uvm_error(get_type_name(), $sformatf(
                "Retire PC mismatch: REF PC=0x%08h DUT PC=0x%08h",
                core_state.pc, retire_s.retire_pc[i]))
            return;
        end

        do_retire_inst();
    end
endfunction : write_retire_in

function void core_reference::write_reg_update(reg_update_s reg_update);
    if(gpr_s.reg_data[reg_update.reg_idx] != reg_update.data)
        `uvm_error(get_type_name(), $sformatf(
            "GPR[%0d] mismatch: REF=0x%0h DUT=0x%0h",
            reg_update.reg_idx,
            gpr_s.reg_data[reg_update.reg_idx],
            reg_update.data))
endfunction : write_reg_update

function void core_reference::write_mem_op(mem_op_s mem_op);
    case(mem_op.op)
        MEM_LOAD:
            mem_lib.read_check(mem_op.source, mem_op.addr);

        MEM_STORE:
            mem_lib.write_check(mem_op.source, mem_op.addr, mem_op.data, mem_op.mask);

        default:
            `uvm_error(get_type_name(), $sformatf(
                "Unsupported mem operation type=%0d", mem_op.op))
    endcase
endfunction : write_mem_op

function void core_reference::do_retire_inst();
    bit [31:0] inst;
    addr_state_s pc_state;

    pc_state.acc_type = FETCH;
    pc_state.addr = core_state.pc;
    pc_state.size = 2'd2;

    core_state.except_info = core_state.pc;

    // FETCH only reads instruction data. It is not part of mem_op checking.
    inst = mem_lib.read_mem(core_state, pc_state);

    if(log_en)
        $fwrite(inst_exe_log, "[%04d] PC=%08h INST=%08h  ",
            retire_cnt + 1, core_state.pc, inst);

    if(core_state.except == NONE_EXCEPT) begin
        inst_lib.do_inst(csr_lib, dsa_mmio_lib, gpr_s, mem_lib, inst, core_state);

        // Consume a VU trigger immediately after the RV custom instruction
        // finishes updating the VU MMIO state.
        if(core_state.except == NONE_EXCEPT &&
           dsa_mmio_lib.dsa_type == DSA_MMIO_VU)
            vu_inst_lib.do_trigger(dsa_mmio_lib.vu_mmio);

        gpr_s.reg_data[0] = '0;
    end

    retire_cnt++;

    if(core_state.except != NONE_EXCEPT) begin
        if(log_en)
            $fwrite(inst_exe_log, "# except <%0s>\n", core_state.except.name);

        csr_lib.except_handle(core_state);
    end
endfunction : do_retire_inst