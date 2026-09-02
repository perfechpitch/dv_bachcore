// Reference memory initialization:
// - Memory image files are located under the "src_file" directory.
// - By default, "src_file/test.vmem" is loaded when no argument is specified.
// - One or more memory image files can be specified from the command line:
//     +MEM_INIT0=<file>
//     +MEM_INIT1=<file>
//     +MEM_INIT2=<file>
// - Only the file name is specified in the argument. The "src_file/" prefix
//   is added automatically.
// - Files are loaded in index order. A later file overwrites data at the same
//   address initialized by an earlier file.
// - Each file may contain ITCM, DTCM and SM data. "@<addr>" sets the current
//   byte address, and each following 32-bit data entry advances it by 4.
// Example:
//     +MEM_INIT0=test.vmem +MEM_INIT1=case.vmem
//   loads src_file/test.vmem first, then src_file/case.vmem.

`include "public_typedef_pkg.sv"
`include "csr_lib_pkg.sv"
`include "mem_lib_pkg.sv"
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
import dsa_mmio_lib_pkg::*;
//import vu_inst_lib_pkg::*;
import inst_lib_pkg::*;
import core_ref_pkg::*;

class test extends uvm_test;

    `uvm_component_utils(test)

    core_reference core_ref;
    base_mem #(SM_SIZE_KB, SM_BASE_ADDR) sm;
    base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR) atomic_mem;

    string mem_init_files[$];

    function new(string name="test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        core_ref_config core_ref_cfg;
        string mem_file;
        int idx;

        super.build_phase(phase);

        core_ref_cfg = core_ref_config::type_id::create("core_ref_cfg");
        uvm_config_db#(core_ref_config)::set(this, "core_ref", "core_ref_cfg", core_ref_cfg);

        core_ref = core_reference::type_id::create("core_ref", this);

        sm = base_mem #(SM_SIZE_KB, SM_BASE_ADDR)::type_id::create("sm");
        atomic_mem = base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR)::type_id::create("atomic_mem");

        core_ref.mem_lib.set_sm(sm);
        core_ref.mem_lib.set_atomic_mem(atomic_mem);

        // Default memory image.
        mem_init_files.push_back("test.vmem");

        // Optional command-line memory images.
        idx = 0;
        while($value$plusargs($sformatf("MEM_INIT%0d=%%s", idx), mem_file)) begin
            if(idx == 0)
                mem_init_files.delete();

            mem_init_files.push_back(mem_file);
            idx++;
        end
    endfunction : build_phase

    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);

        phase.raise_objection(this);

        // Shared memories are initialized by their owner.
        sm.init();
        atomic_mem.init();

        sm.open_log("log/sm.log");
        atomic_mem.open_log("log/atomic_mem.log");

        phase.drop_objection(this);
    endtask : reset_phase

    task main_phase(uvm_phase phase);
        inst_retire_structure retire_s;
        bit [31:0] inst;

        super.main_phase(phase);
        phase.raise_objection(this);

        init_ref_memory();

        retire_s = '{default:'0};

        forever begin
            // Peek instruction only for direct-test termination detection.
            // FETCH does not participate in memory operation checking.
            inst = peek_inst(core_ref.core_state.pc);

            if(inst == 32'h00000000) begin
                `uvm_error(get_type_name(), $sformatf(
                    "Instruction is zero: pc=0x%08h",
                    core_ref.core_state.pc))
                break;
            end

            if(inst == 32'h00000033) begin
                $display("**** DIRECT TEST PASS ****");
                break;
            end

            if(inst == 32'h40000033) begin
                `uvm_error(get_type_name(), $sformatf(
                    "**** DIRECT TEST FAIL **** pc=0x%08h",
                    core_ref.core_state.pc))
                break;
            end

            retire_s.retire_num = 1;
            retire_s.retire_pc[0] = core_ref.core_state.pc;

            core_ref.write_retire_in(retire_s);
        end

        phase.drop_objection(this);
    endtask : main_phase

    task load_mem_file(string file_name);
        int fd;
        int ret;
        string line;
        string file_path;
        bit [31:0] addr;
        bit [31:0] data;

        file_path = {"src_file/", file_name};

        fd = $fopen(file_path, "r");
        if(fd == 0)
            `uvm_fatal(get_type_name(),
                $sformatf("Cannot open memory init file: %s", file_name))

        addr = '0;

        while($fgets(line, fd)) begin
            if($sscanf(line, "@%h", addr) == 1)
                continue;

            ret = $sscanf(line, "%h", data);
            if(ret != 1)
                continue;

            if(addr inside {[ITCM_BASE_ADDR:ITCM_END_ADDR]})
                core_ref.mem_lib.itcm.init_data(addr, data);
            else if(addr inside {[DTCM_BASE_ADDR:DTCM_END_ADDR]})
                core_ref.mem_lib.dtcm.init_data(addr, data);
            else if(addr inside {[SM_BASE_ADDR:SM_END_ADDR]})
                sm.init_data(addr, data);
            else
                `uvm_error(get_type_name(), $sformatf(
                    "Memory init address out of range: addr=0x%08h data=0x%08h",
                    addr, data))

            addr += 4;
        end

        $fclose(fd);
    endtask : load_mem_file

    task init_ref_memory();
        foreach(mem_init_files[i])
            load_mem_file(mem_init_files[i]);
    endtask : init_ref_memory

    // Direct-test-only instruction peek.
    // FETCH must not participate in LOAD/STORE operation checking.
    function bit [31:0] peek_inst(bit [31:0] pc);
        return core_ref.mem_lib.itcm.read_mem(2'd2, pc, 1'b0);
    endfunction : peek_inst

endclass : test
