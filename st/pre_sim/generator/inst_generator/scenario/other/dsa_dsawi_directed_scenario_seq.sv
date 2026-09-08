// Configure the DSAWI address register, then program one DSA register with imm16.
class dsa_dsawi_directed_scenario_seq extends directed_scenario_seq;
    `uvm_object_utils(dsa_dsawi_directed_scenario_seq)

    function new(string name = "dsa_dsawi_directed_scenario_seq");
        super.new(name);
    endfunction : new

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
        li_sequence li_seq;
        int unsigned addr_reg_arg;
        int unsigned imm_arg;
        bit [4:0]    addr_reg;
        bit [15:0]   dsa_imm;
        bit [31:0]   dsa_addr;

        addr_reg_arg = 5;
        dsa_addr     = 32'h0000_0008;
        imm_arg      = 16'habcd;
        void'($value$plusargs("dsa_addr_reg=%d", addr_reg_arg));
        void'($value$plusargs("dsa_addr=%h", dsa_addr));
        void'($value$plusargs("dsa_imm=%h", imm_arg));

        if(addr_reg_arg == 0 || addr_reg_arg > 31)
            `uvm_fatal("DSAWI_SCENARIO", "+dsa_addr_reg must be in [1:31]")
        if(imm_arg > 16'hffff)
            `uvm_fatal("DSAWI_SCENARIO", "+dsa_imm must be an unsigned 16-bit value")
        if(!(CUSTOM inside inst_gen.inst_gen_cfg.support_inst_set))
            `uvm_fatal("DSAWI_SCENARIO", "CUSTOM is not enabled; add +support_custom")

        addr_reg = addr_reg_arg[4:0];
        dsa_imm  = imm_arg[15:0];
        li_seq = new("dsa_dsawi_li_seq");

        $fwrite(inst_gen.gen_file,
                "// === directed scenario: DSAWI addr=x%0d(0x%08h) imm=0x%04h ===\n",
                addr_reg, dsa_addr, dsa_imm);

        void'(li_seq.seq_gen(inst_gen, dsa_addr, addr_reg));
        inst_gen.get_specified_inst(DSAWI, addr_reg, '0, '0, dsa_imm);

        `uvm_info("DSAWI_SCENARIO",
                  $sformatf("DSAWI rs1=x%0d addr=0x%08h imm=0x%04h",
                            addr_reg, dsa_addr, dsa_imm),
                  UVM_LOW)
    endfunction : seq_gen
endclass : dsa_dsawi_directed_scenario_seq

`DIRECTED_SCENARIO_REGISTER(dsa_dsawi_directed_scenario_seq, "dsa_dsawi")

