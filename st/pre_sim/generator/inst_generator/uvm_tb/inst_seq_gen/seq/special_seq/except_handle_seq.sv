class except_handle_sequence extends uvm_object;
    `uvm_object_utils_begin(except_handle_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "except_handle_sequence");
      super.new(name);
    endfunction : new

    function bit[4:0] seq_gen(bit[39:0] except_entry,inst_generator inst_gen,bit except_disable, bit except_handle_disable,mode_e mode);
        int inst_num;
        bit[4:0] temp_reg;
        bit[4:0] temp_reg1;
        bit[4:0] temp_reg2;
        inst_num =1;

        temp_reg1 = inst_gen.reg_pool.get_nonezero_gpr(1'b1);
        temp_reg2 = inst_gen.reg_pool.get_nonezero_gpr(1'b1);
        $fwrite(inst_gen.vmem_file,("@%0h\n"),except_entry>>2);
        $fwrite(inst_gen.gen_file,("%s_except_handle:\n"),mode);

        if(except_handle_disable)begin
            `sub(0,0,0);//fail quit code
        end
        else begin
            // temp reg not always get
            temp_reg = inst_gen.reg_pool.get_reserved_gpr();
            `auipc(temp_reg,'h0);
            `addi(temp_reg,temp_reg,'h100);
            `sd(temp_reg1,'h0,temp_reg) ;
            `sd(temp_reg2,'h0,temp_reg) ;

            if(mode == M_MODE)
                `csrrc(temp_reg1,0,`mcause);
            else
                `csrrc(temp_reg1,0,`scause);
//          if except disable, only interrupt can happen when program run
            if(except_disable)begin
                `srli(temp_reg2,temp_reg1,'h3f);
                `beq(temp_reg2,`zero,'h4c);
            end
            //caseu=0/1/12 is fetch except
            `beq(temp_reg1,`zero,'h14);
            `addi(temp_reg2,`zero,1);
            `beq(temp_reg1,temp_reg2,'hc);
            `addi(temp_reg2,`zero,12);
            `bne(temp_reg1,temp_reg2,'h20);

 $fwrite(inst_gen.gen_file,("fetch except set return pc:\n"));
            `addi(temp_reg2,temp_reg, 'h100);
            `ld(temp_reg1, 'h0, temp_reg2);// fetch except times * 8
            `add(temp_reg2, temp_reg1, temp_reg2);
            `ld(temp_reg2, 'h0, temp_reg2);     // load return addr temp_reg2
            `addi(temp_reg1,temp_reg1,8);       // fetch except times add
            `sd(temp_reg1,'h100,temp_reg);
            `jal(temp_reg1,'hc) ;

            // set return pc
            if(mode == M_MODE)
                `csrrc(temp_reg2,0,`mepc);
            else
                `csrrc(temp_reg2,0,`sepc);
            `addi(temp_reg2,temp_reg2,4);
            if(mode == M_MODE)
                `csrrw(temp_reg2,temp_reg2,`mepc);
            else
                `csrrw(temp_reg2,temp_reg2,`sepc);

            `ld(temp_reg1,'h0,temp_reg) ;
            `ld(temp_reg2,'h0,temp_reg) ;
            if(mode == M_MODE) `mret;
            else    `sret;
            `sub(0,0,0);//fail quit code

            inst_num = 24;
        end


        // for inst access fault return
        return inst_num;
    endfunction
endclass
