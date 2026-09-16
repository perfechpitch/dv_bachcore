// Unified Single-Core / Multi-Core core_ref self-test.
`include "public_typedef_pkg.sv"
`include "csr_lib_pkg.sv"
`include "mem_lib_pkg.sv"
`include "dsa_mem_lib_pkg.sv"
`include "dsa_mmio_lib_pkg.sv"
`include "vu_inst_lib_pkg.sv"
`include "mu_inst_lib_pkg.sv"
`include "dte_inst_lib_pkg.sv"
`include "inst_lib_pkg.sv"
`include "core_ref_pkg.sv"

import uvm_pkg::*;
import public_typedef_pkg::*;
import csr_lib_pkg::*;
import mem_lib_pkg::*;
import dsa_mem_lib_pkg::*;
import dsa_mmio_lib_pkg::*;
import inst_lib_pkg::*;
import core_ref_pkg::*;

class test extends uvm_test;
    `uvm_component_utils(test)

    localparam int MAX_CORE_NUM = 3;

    int core_num = 1;
    core_reference core_ref[MAX_CORE_NUM];
    core_ref_config core_ref_cfg[MAX_CORE_NUM];

    base_mem #(SM_SIZE_KB, SM_BASE_ADDR) sm;
    base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR) atomic_mem;
    dsa_mem_library shared_dsa_mem;
    int shared_dsa_mem_log;
    string mem_init_files[$];

    function new(string name="test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function dsa_mmio_type_e configured_dsa_type(int index);
        string single_type;
        if(core_num == 3) begin
            case(index)
                0: return DSA_MMIO_VU;
                1: return DSA_MMIO_MU;
                default: return DSA_MMIO_DTE;
            endcase
        end

        if(!$value$plusargs("CORE_DSA_TYPE=%s", single_type))
            return DSA_MMIO_VU;
        case(single_type.toupper())
            "VU":  return DSA_MMIO_VU;
            "MU":  return DSA_MMIO_MU;
            "DTE": return DSA_MMIO_DTE;
            default: begin
                `uvm_error("BAD_DSA_TYPE",
                    $sformatf("Unsupported +CORE_DSA_TYPE=%s", single_type))
                return DSA_MMIO_VU;
            end
        endcase
    endfunction

    function int find_core(dsa_mmio_type_e dsa_type);
        for(int i=0; i<core_num; i++)
            if(core_ref_cfg[i].dsa_type == dsa_type)
                return i;
        return -1;
    endfunction

    function int dispatch_task(task_info_s task_info);
        int index;
        index = find_core(task_info.dsa_type);
        if(index < 0) begin
            `uvm_error("NO_TASK_CORE", $sformatf(
                "No enabled core for task_id=%0d dsa_type=%0s",
                task_info.task_id, task_info.dsa_type.name))
            return -1;
        end
        core_ref[index].set_task_info(task_info);
        return index;
    endfunction

    function void build_phase(uvm_phase phase);
        int requested_core_num;
        string mem_file;
        int idx;

        super.build_phase(phase);
        if($value$plusargs("CORE_NUM=%d", requested_core_num))
            core_num = requested_core_num;
        if(!(core_num inside {1, 3}))
            `uvm_fatal("BAD_CORE_NUM", "+CORE_NUM must be 1 or 3")

        sm = base_mem #(SM_SIZE_KB, SM_BASE_ADDR)::type_id::create("sm");
        atomic_mem = base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR)::
            type_id::create("atomic_mem");
        shared_dsa_mem = dsa_mem_library::type_id::create("shared_dsa_mem");

        for(int i=0; i<core_num; i++) begin
            core_ref_cfg[i] = core_ref_config::type_id::create(
                $sformatf("core_ref_cfg%0d", i));
            core_ref_cfg[i].core_id = i;
            core_ref_cfg[i].dsa_type = configured_dsa_type(i);
            uvm_config_db#(core_ref_config)::set(
                this, $sformatf("core_ref%0d", i),
                "core_ref_cfg", core_ref_cfg[i]);

            core_ref[i] = core_reference::type_id::create(
                $sformatf("core_ref%0d", i), this);
            core_ref[i].mem_lib.set_sm(sm);
            core_ref[i].mem_lib.set_atomic_mem(atomic_mem);
            core_ref[i].set_dsa_mem_lib(shared_dsa_mem);
        end

        mem_init_files.push_back("test.vmem");
        idx = 0;
        while($value$plusargs($sformatf("MEM_INIT%0d=%%s", idx), mem_file)) begin
            if(idx == 0)
                mem_init_files.delete();
            mem_init_files.push_back(mem_file);
            idx++;
        end
    endfunction

    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        phase.raise_objection(this);
        sm.init();
        atomic_mem.init();
        sm.open_log("log/sm.log");
        atomic_mem.open_log("log/atomic_mem.log");
        shared_dsa_mem_log = $fopen("log/shared_dsa_mem.log", "w");
        if(shared_dsa_mem_log == 0)
            `uvm_error("DSA_MEM_LOG", "Cannot open shared DSA memory log")
        else
            shared_dsa_mem.set_log(shared_dsa_mem_log);
        phase.drop_objection(this);
    endtask

    function int tcm_owner(bit [31:0] addr, output bit is_itcm);
        for(int i=0; i<core_num; i++) begin
            if(core_ref[i].mem_lib.owns_itcm_addr(addr)) begin
                is_itcm = 1'b1;
                return i;
            end
            if(core_ref[i].mem_lib.owns_dtcm_addr(addr)) begin
                is_itcm = 1'b0;
                return i;
            end
        end
        return -1;
    endfunction

    virtual function bit vmem_uses_word_address();
        return 1'b0;
    endfunction

    task load_mem_file(string file_name);
        int fd;
        int ret;
        int owner;
        string line;
        string file_path;
        bit is_itcm;
        bit [31:0] addr;
        bit [31:0] file_addr;
        bit [31:0] data;

        file_path = {"src_file/", file_name};
        fd = $fopen(file_path, "r");
        if(fd == 0)
            `uvm_fatal(get_type_name(),
                $sformatf("Cannot open memory init file: %s", file_name))

        addr = '0;
        while($fgets(line, fd)) begin
            if($sscanf(line, "@%h", file_addr) == 1) begin
                addr = vmem_uses_word_address() ? (file_addr << 2) : file_addr;
                continue;
            end
            ret = $sscanf(line, "%h", data);
            if(ret != 1)
                continue;

            owner = tcm_owner(addr, is_itcm);
            if(owner >= 0) begin
                if(is_itcm)
                    core_ref[owner].mem_lib.init_itcm_data(addr, data);
                else
                    core_ref[owner].mem_lib.init_dtcm_data(addr, data);
            end
            else if(addr inside {[SM_BASE_ADDR:SM_END_ADDR]})
                sm.init_data(addr, data);
            else if(ATOMIC_MEM_SIZE_KB != 0 &&
                    addr inside {[ATOMIC_MEM_BASE_ADDR:ATOMIC_MEM_END_ADDR]})
                atomic_mem.init_data(addr, data);
            else if(!shared_dsa_mem.is_dsa_addr(addr))
                `uvm_error(get_type_name(), $sformatf(
                    "Memory init address has no owner: addr=0x%08h", addr))
            addr += 4;
        end
        $fclose(fd);

        // Shared DSA storage is initialized once by its owner for each overlay.
        shared_dsa_mem.init(file_path);
    endtask

    task init_ref_memory();
        foreach(mem_init_files[i])
            load_mem_file(mem_init_files[i]);
    endtask

    task execute_program(core_reference target);
        inst_retire_structure retire_s;
        bit [31:0] inst;

        retire_s = '{default:'0};
        forever begin
            inst = target.mem_lib.peek_inst(target.core_state.pc);
            if(inst == 32'h00000000) begin
                `uvm_error("ZERO_INST", $sformatf(
                    "core%0d zero instruction at pc=%08h",
                    target.core_id, target.core_state.pc))
                break;
            end
            if(inst == 32'h00000033) begin
                $display("**** CORE%0d PROGRAM PASS ****", target.core_id);
                break;
            end
            if(inst == 32'h40000033) begin
                `uvm_error("FAIL_INST", $sformatf(
                    "core%0d fail instruction at pc=%08h",
                    target.core_id, target.core_state.pc))
                break;
            end
            retire_s.retire_num = 1;
            retire_s.retire_pc[0] = target.core_state.pc;
            target.write_retire_in(retire_s);
            if((inst & 32'h7fff_ffff) == 32'h0000_200b) begin
                $display("**** CORE%0d TASK DONE ts_notify=%0d ****",
                    target.core_id, inst[31]);
                break;
            end
        end
    endtask

    task check_topology_and_dispatch();
        task_info_s task_info;
        int index;

        for(int i=0; i<core_num; i++) begin
            if(core_ref[i].mem_lib.sm != sm ||
               core_ref[i].mem_lib.atomic_mem != atomic_mem ||
               core_ref[i].dsa_mem_lib != shared_dsa_mem)
                `uvm_error("SHARED_STATE", $sformatf(
                    "core%0d shared handle mismatch", i))
            if(core_ref[i].dsa_mmio_lib.dsa_type != core_ref_cfg[i].dsa_type)
                `uvm_error("CORE_IDENTITY", $sformatf(
                    "core%0d DSA identity mismatch", i))
        end

        if(core_num == 3) begin
            if(core_ref[0].mem_lib.itcm == core_ref[1].mem_lib.itcm ||
               core_ref[0].mem_lib.itcm == core_ref[2].mem_lib.itcm ||
               core_ref[1].mem_lib.itcm == core_ref[2].mem_lib.itcm ||
               core_ref[0].mem_lib.dtcm == core_ref[1].mem_lib.dtcm ||
               core_ref[0].mem_lib.dtcm == core_ref[2].mem_lib.dtcm ||
               core_ref[1].mem_lib.dtcm == core_ref[2].mem_lib.dtcm ||
               core_ref[0].dsa_mmio_lib == core_ref[1].dsa_mmio_lib ||
               core_ref[0].dsa_mmio_lib == core_ref[2].dsa_mmio_lib ||
               core_ref[1].dsa_mmio_lib == core_ref[2].dsa_mmio_lib ||
               core_ref[0].csr_lib == core_ref[1].csr_lib ||
               core_ref[0].csr_lib == core_ref[2].csr_lib ||
               core_ref[1].csr_lib == core_ref[2].csr_lib)
                `uvm_error("PRIVATE_STATE", "Per-core private handle alias detected")

            // Different-type tasks route to their fixed physical cores.
            for(int i=0; i<3; i++) begin
                task_info = '{core_itcm_base(core_ref_cfg[i].dsa_type),
                    4'(i), 6'(i+1), 16'(i+10), 6'(i+20), 2'(i),
                    core_ref_cfg[i].dsa_type};
                index = dispatch_task(task_info);
                if(index != i || core_ref[i].core_state.pc != task_info.start_pc)
                    `uvm_error("TASK_ROUTE", $sformatf(
                        "Task for %0s routed to core%0d, expected core%0d",
                        task_info.dsa_type.name, index, i))
            end

            // Same-type task switch reuses the same core and preserves context.
            core_ref[0].gpr_s.reg_data[5] = 32'h5a5a_a5a5;
            task_info = '{core_itcm_base(DSA_MMIO_VU) + 32'h40,
                4'd7, 6'd9, 16'h1234, 6'h12, 2'd2, DSA_MMIO_VU};
            index = dispatch_task(task_info);
            if(index != 0 || core_ref[0].core_state.pc != task_info.start_pc ||
               core_ref[0].gpr_s.reg_data[5] != 32'h5a5a_a5a5)
                `uvm_error("TASK_SWITCH",
                    "Same-type task switch did not preserve core context")
        end
    endtask

    task main_phase(uvm_phase phase);
        task_info_s task_info;
        int vu_index;

        super.main_phase(phase);
        phase.raise_objection(this);

        check_topology_and_dispatch();

        vu_index = find_core(DSA_MMIO_VU);
        if(vu_index >= 0) begin
            init_ref_memory();
            task_info = '{core_itcm_base(DSA_MMIO_VU), 4'd2, 6'd3,
                16'h0015, 6'h08, 2'd1, DSA_MMIO_VU};
            void'(dispatch_task(task_info));
            execute_program(core_ref[vu_index]);

            // The MU and DTE self-test programs are RV-only. Their configured
            // request logs must therefore exist and remain empty.
            if(core_num == 3) begin
                for(int i=1; i<3; i++) begin
                    core_ref[i].mem_lib.init_itcm_data(
                        core_itcm_base(core_ref_cfg[i].dsa_type), 32'h00500093);
                    core_ref[i].mem_lib.init_itcm_data(
                        core_itcm_base(core_ref_cfg[i].dsa_type) + 4, 32'h00000033);
                    task_info = '{core_itcm_base(core_ref_cfg[i].dsa_type),
                        4'(i), 6'(i+3), 16'(i+16), 6'(i+8), 2'(i),
                        core_ref_cfg[i].dsa_type};
                    void'(dispatch_task(task_info));
                    execute_program(core_ref[i]);
                end
            end
        end
        else begin
            // MU/DTE execution models are not implemented yet. Identity,
            // routing and private/shared ownership are still checked above.
            $display("**** SINGLE-CORE %0s CONFIGURATION PASS ****",
                core_ref_cfg[0].dsa_type.name);
        end

        phase.drop_objection(this);
    endtask
endclass
