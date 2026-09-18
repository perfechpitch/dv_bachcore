typedef enum {
    BACH_CORE_INACTIVE,
    BACH_CORE_TS_DUMMY,
    BACH_CORE_RVCORE_DUMMY,
    BACH_CORE_FULL
} bach_core_mode_e;

typedef enum {
    BACH_CORE_CHECK_INST,
    BACH_CORE_CHECK_TASK,
    BACH_CORE_CHECK_USER
} bach_core_check_level_e;

class bach_core_env_cfg extends uvm_object;
    `uvm_object_utils_begin(bach_core_env_cfg)
        `uvm_field_enum(bach_core_mode_e, mode, UVM_DEFAULT)
        `uvm_field_enum(bach_core_check_level_e, check_level, UVM_DEFAULT)
    `uvm_object_utils_end

    bach_core_mode_e mode = BACH_CORE_FULL;
    bach_core_check_level_e check_level = BACH_CORE_CHECK_INST;

    virtual router_if router_vif;
    virtual rv_dsa_if rv_dsa_vif[3];
    virtual ts_if ts_vif;

    function new(string name = "bach_core_env_cfg");
        super.new(name);
    endfunction

    function void apply_plusargs();
        string value;
        if ($value$plusargs("BACH_CORE_MODE=%s", value)) begin
            case (value.toupper())
                "INACTIVE":     mode = BACH_CORE_INACTIVE;
                "TS_DUMMY":     mode = BACH_CORE_TS_DUMMY;
                "RVCORE_DUMMY": mode = BACH_CORE_RVCORE_DUMMY;
                "FULL":         mode = BACH_CORE_FULL;
                default: `uvm_fatal("BACH_CORE_MODE", $sformatf("Unsupported BACH_CORE_MODE=%s", value))
            endcase
        end
        if ($value$plusargs("BACH_CORE_CHECK_LEVEL=%s", value)) begin
            case (value.toupper())
                "INST": mode_check_set(BACH_CORE_CHECK_INST);
                "TASK": mode_check_set(BACH_CORE_CHECK_TASK);
                "USER": mode_check_set(BACH_CORE_CHECK_USER);
                default: `uvm_fatal("BACH_CORE_CHECK", $sformatf("Unsupported BACH_CORE_CHECK_LEVEL=%s", value))
            endcase
        end
    endfunction

    local function void mode_check_set(bach_core_check_level_e level);
        check_level = level;
    endfunction
endclass
