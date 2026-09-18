class rvcore_base_test extends uvm_test;
    `uvm_component_utils(rvcore_base_test)

    rvcore_env env;
    virtual rvcore_checker_if vif;

    function new(string name = "rvcore_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual rvcore_checker_if)::get(this, "", "vif", vif))
            `uvm_fatal("RVCORE_NO_VIF", "rvcore_checker_if was not configured")
        env = rvcore_env::type_id::create("env", this);
    endfunction

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        wait (vif.reset_n === 1'b1);
        repeat (10) @(posedge vif.clk);
        phase.drop_objection(this);
    endtask

endclass
