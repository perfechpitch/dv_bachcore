// Configure DSAW source registers, then use DSAW to program one DSA register.
class dsa_dsaw_directed_scenario_seq extends directed_scenario_seq;
    `uvm_object_utils(dsa_dsaw_directed_scenario_seq)

    function new(string name = "dsa_dsaw_directed_scenario_seq");
        super.new(name);
    endfunction : new

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
        li_sequence li_seq;
        int unsigned addr_reg_arg;
        int unsigned data_reg_arg;
        bit [4:0]    addr_reg;
        bit [4:0]    data_reg;
        bit [31:0]   dsa_addr;
        bit [31:0]   dsa_data;

        addr_reg_arg = 5;
        data_reg_arg = 6;
        dsa_addr     = 32'h0000_0008;
        dsa_data     = 32'h1234_5678;
        void'($value$plusargs("dsa_addr_reg=%d", addr_reg_arg));
        void'($value$plusargs("dsa_data_reg=%d", data_reg_arg));
        void'($value$plusargs("dsa_addr=%h", dsa_addr));
        void'($value$plusargs("dsa_data=%h", dsa_data));

        if(addr_reg_arg == 0 || addr_reg_arg > 31)
            `uvm_fatal("DSAW_SCENARIO", "+dsa_addr_reg must be in [1:31]")
        if(data_reg_arg == 0 || data_reg_arg > 31)
            `uvm_fatal("DSAW_SCENARIO", "+dsa_data_reg must be in [1:31]")
        if(addr_reg_arg == data_reg_arg)
            `uvm_fatal("DSAW_SCENARIO", "address and data registers must be different")
        if(!(CUSTOM inside inst_gen.inst_gen_cfg.support_inst_set))
            `uvm_fatal("DSAW_SCENARIO", "CUSTOM is not enabled; add +support_custom")

        addr_reg = addr_reg_arg[4:0];
        data_reg = data_reg_arg[4:0];
        li_seq = new("dsa_dsaw_li_seq");

        $fwrite(inst_gen.gen_file,
                "// === directed scenario: DSAW addr=x%0d(0x%08h) data=x%0d(0x%08h) ===\n",
                addr_reg, dsa_addr, data_reg, dsa_data);

        // li_sequence emits only get_specified_inst(name, operands, imm) calls.
        void'(li_seq.seq_gen(inst_gen, dsa_addr, addr_reg));
        void'(li_seq.seq_gen(inst_gen, dsa_data, data_reg));
        inst_gen.get_specified_inst(DSAW, addr_reg, data_reg, '0, '0);

        `uvm_info("DSAW_SCENARIO",
                  $sformatf("DSAW rs1=x%0d addr=0x%08h rs2=x%0d data=0x%08h",
                            addr_reg, dsa_addr, data_reg, dsa_data),
                  UVM_LOW)
    endfunction : seq_gen
endclass : dsa_dsaw_directed_scenario_seq

`DIRECTED_SCENARIO_REGISTER(dsa_dsaw_directed_scenario_seq, "dsa_dsaw")
