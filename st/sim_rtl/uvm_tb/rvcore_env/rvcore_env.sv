class rvcore_env extends uvm_env;
  `uvm_component_utils(rvcore_env)

  localparam int MAX_CORE_NUM = 3;

  int core_num = 1;
  core_reference core_ref[MAX_CORE_NUM];
  core_ref_config core_ref_cfg[MAX_CORE_NUM];
  rvcore_retire_monitor retire_monitor[MAX_CORE_NUM];
  rvcore_writeback_monitor writeback_monitor[MAX_CORE_NUM];

  base_mem #(SM_SIZE_KB, SM_BASE_ADDR) sm;
  base_mem #(ATOMIC_MEM_SIZE_KB, ATOMIC_MEM_BASE_ADDR) atomic_mem;
  dsa_mem_library shared_dsa_mem;
  int shared_dsa_mem_log;

  function new(string name="rvcore_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function dsa_mmio_type_e configured_dsa_type(int index);
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
        `uvm_error("RVCORE_BAD_DSA_TYPE",
          $sformatf("Unsupported +CORE_DSA_TYPE=%s; use VU/MU/DTE", single_type))
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

  function void dispatch_task(task_info_s task_info);
    int index;
    index = find_core(task_info.dsa_type);
    if(index < 0) begin
      `uvm_error("RVCORE_NO_TASK_CORE", $sformatf(
        "No enabled core for task_id=%0d dsa_type=%0s",
        task_info.task_id, task_info.dsa_type.name))
      return;
    end
    core_ref[index].set_task_info(task_info);
  endfunction

  function void build_phase(uvm_phase phase);
    int requested_core_num;
    super.build_phase(phase);

    if($value$plusargs("CORE_NUM=%d", requested_core_num))
      core_num = requested_core_num;
    if(!(core_num inside {1, 3}))
      `uvm_fatal("RVCORE_BAD_CORE_NUM", "+CORE_NUM must be 1 or 3")

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
        this, $sformatf("core_ref%0d", i), "core_ref_cfg", core_ref_cfg[i]);

      core_ref[i] = core_reference::type_id::create(
        $sformatf("core_ref%0d", i), this);
      core_ref[i].mem_lib.set_sm(sm);
      core_ref[i].mem_lib.set_atomic_mem(atomic_mem);
      core_ref[i].set_dsa_mem_lib(shared_dsa_mem);

      uvm_config_db#(core_reference)::set(
        this, $sformatf("retire_monitor%0d", i),
        "core_ref_h", core_ref[i]);
      retire_monitor[i] = rvcore_retire_monitor::type_id::create(
        $sformatf("retire_monitor%0d", i), this);
      writeback_monitor[i] = rvcore_writeback_monitor::type_id::create(
        $sformatf("writeback_monitor%0d", i), this);
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
      `uvm_error("RVCORE_DSA_MEM_LOG", "Cannot open shared DSA memory log")
    else
      shared_dsa_mem.set_log(shared_dsa_mem_log);
    phase.drop_objection(this);
  endtask

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    for(int i=0; i<core_num; i++) begin
      retire_monitor[i].analysis_port.connect(core_ref[i].retire_in_imp);
      writeback_monitor[i].analysis_port.connect(core_ref[i].reg_update_imp);
    end
  endfunction
endclass
