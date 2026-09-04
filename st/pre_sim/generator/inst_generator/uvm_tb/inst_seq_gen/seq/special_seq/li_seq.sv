class li_sequence extends uvm_object;
    `uvm_object_utils_begin(li_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "li_sequence");
      super.new(name);
    endfunction : new

    //virtual function seq_gen(csr_config csr_cfg);
    function bit [4:0] seq_gen(inst_generator inst_gen,bit[63:0] val, bit[4:0] dst_reg);
        bit [4:0] inst_num;
        bit [4:0] src_reg;
//        src_reg = inst_gen.reg_pool.get_nonezero_gpr(1);

        $fwrite(inst_gen.gen_file,("// -------------- li seq start: li x%0d,0x%0h\n"),dst_reg,val);
        if(val[63:11] == 0)begin
            `addi(dst_reg,0,val[10:0]);
            inst_num = 1;
        end
        else if(val[63:32] == 0)begin
            `addi(dst_reg,0,val[32:22]);
            `slli(dst_reg,dst_reg,11);
            `addi(dst_reg,dst_reg,val[21:11]);
            `slli(dst_reg,dst_reg,11);
            `addi(dst_reg,dst_reg,val[10:0]);
            inst_num = 5;
        end
        else begin
            `addi(dst_reg,0,val[63:53]);
            `slli(dst_reg,dst_reg,11);
            `addi(dst_reg,dst_reg,val[52:42]);
            `slli(dst_reg,dst_reg,11);
            `addi(dst_reg,dst_reg,val[41:31]);
            `slli(dst_reg,dst_reg,11);
            `addi(dst_reg,dst_reg,val[30:20]);
            `slli(dst_reg,dst_reg,11);
            `addi(dst_reg,dst_reg,val[19:9]);
            `slli(dst_reg,dst_reg,9);
            `addi(dst_reg,dst_reg,val[8:0]);
            inst_num = 11;
        end
        $fwrite(inst_gen.gen_file,("// --------------- li seq end\n"));
 /*
        error with 64bit data
        //low 32bit get
        `lui(1,val[31:12]);
        `slli(1,1,12); 
        `addiw(1,1,val[11:0]);

        //high 32bit get
        `lui(2,val[63:44]); 
        `slli(2,2,12); 
        `addiw(2,2,val[43:32]);
        `slli(2,2,32); 

        //or 
        `or(dst_reg,2,1);
        */

        return inst_num;
    endfunction
endclass
