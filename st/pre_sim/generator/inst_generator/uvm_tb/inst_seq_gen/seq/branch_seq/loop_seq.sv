/*
    loop structure:
    loop hierarchy = N
    loop times = a0...aN, loop index = i0...iN.
    loop seq = seq0..seqN
    loop stride : a[*][0] | i[*][0] == 0 -> 2, else 1
    for(i0=i[0];i<a[0];i0++)begin
        ... other insts
        for(i1=i[1];i1<a[1];i1++)begin
            ... other insts
            ...
            for(iN=i[N];iN<a[N];iN++)begin
                .... other insts
            end
        end
    end
    --constraint
    i[*]<a[*] -no need
    N inside [0:32/2=15];//i[*] & a[*] reg is not available to be rd in other insts,x0 is not avaliable to be i[*] & a[*]
    assume N=4
    -- asm

    li i0, ..
    li a0, ..
    loop0:
    ..other insts

    li i1, ..
    li a1, ..
    loop1:
    ..other insts

    li i2, ..
    li a2, ..
    loop2:
    ..other insts

    li i3, ..
    li a3, ..
    loop3:
    ..other insts
    addi i3, i3, i3_stride
    b**  i3, a3, loop3

    addi i2, i2, i2_stride
    b**  i2, a2, loop2

    addi i1, i1, i1_stride
    b**  i1, a1, loop1

    addi i0, i0, i0_stride
    b**  i0, a0, loop0

*/
class loop_sequence extends base_inst_sequence;
    loop_seq_info_item  loop_seq_info;
    li_sequence         li_seq;
    int seq_num;
    `uvm_object_utils_begin(loop_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "loop_sequence");
      super.new(name);
      loop_seq_info = new();
      li_seq = new();
      seq_num = 0;
    endfunction : new

    virtual function inst_seq_info_item sub_seq_gen(branch_seq_config   branch_seq_cfg, inst_generator inst_gen);
        bit [4:0] regs[$];
        bit [4:0] i_reg_num[$];
        bit [4:0] a_reg_num[$];

        bit [2:0] loop_stride[$];
        bit [31:0] ops[$];
        int inst_num[$];
        int li_seq_inst_num[$];
        int N;

 //reg_pool.gpr_full_valid=1'b1;
        //reg_pool.randomize();
        inst_gen.reg_pool.branch_reg_get(N*2);
        regs = inst_gen.reg_pool.branch_regs;
        N= regs.size()/2;//reg may not enough

        //if don't insert other insts
        //the program will be like
        //initial i[*],a[*]
        for(int i=0;i<N;i++)begin
            li_seq_inst_num[i] = 0;
            inst_num[i] = 0;
            loop_stride[i] = ((loop_seq_info.start_index[i][0] | loop_seq_info.end_index[i][0])==0) + 1;
            a_reg_num[i] = regs.pop_front();
            i_reg_num[i] = regs.pop_front();
            $fwrite(inst_gen.gen_file,("//--------------li branch reg start\n"));
            if(loop_seq_info.start_index[i] == 0) begin
                `addi(i_reg_num[i],0,0);
                li_seq_inst_num[i] = 1;
                $fwrite(inst_gen.gen_file,("//x%0d - start_index[%0d] = %0h.\n"),0,i,0);
            end
            else begin
                li_seq_inst_num[i] = li_seq.seq_gen(inst_gen,loop_seq_info.start_index[i],i_reg_num[i]);
                $fwrite(inst_gen.gen_file,("//x%0d - start_index[%0d] = %0h.\n"),i_reg_num[i],i,loop_seq_info.start_index[i]);
            end
            if(loop_seq_info.end_index[i] == 0) begin
                `addi(a_reg_num[i],0,0);
                li_seq_inst_num[i] = 1 + li_seq_inst_num[i];
                $fwrite(inst_gen.gen_file,("//x%0d - end_index[%0d] = %0h.\n"),0,i,0);
            end
            else begin
                li_seq_inst_num[i] = (li_seq.seq_gen(inst_gen,loop_seq_info.end_index[i],a_reg_num[i]))+ li_seq_inst_num[i];
                $fwrite(inst_gen.gen_file,("//x%0d - end_index[%0d] = %0h.\n"),a_reg_num[i],i,loop_seq_info.end_index[i]);
            end
            $fwrite(inst_gen.gen_file,("//---------------li branch reg end\n"));
            $fwrite(inst_gen.gen_file,("loop_seq%0d_loop%0d:\n"),seq_num,i);
            gen_rand_inst(inst_gen,loop_seq_info.target_inst_num[i],loop_seq_info.ls_inst_dist,loop_seq_info.safe_inst_dist,loop_seq_info.flush_inst_dist,loop_seq_info.except_inst_dist,'d0,loop_seq_info.wfi_inst_dist);

            ops[i][24:20] = i_reg_num[i];
            ops[i][19:15] = a_reg_num[i];
            ops[i][31] = 1'b1;
            //$display("i_reg_num[i] =  %0d. i_reg_val = %0h",i_reg_num[i],loop_seq_info.start_index[i]);
            //$display("a_reg_num[i] =  %0d. a_reg_val = %0h",a_reg_num[i],loop_seq_info.end_index[i]);
        end
        for(int i=(N-1);i>=0;i--)begin
            if(i!==(N-1))inst_num[i] = /*li_seq_inst_num[i] +*/ loop_seq_info.target_inst_num[i] + inst_num[i+1] +li_seq_inst_num[i+1]+2;
            else inst_num[i] = loop_seq_info.target_inst_num[i] + 1;
            `addi(i_reg_num[i],i_reg_num[i],loop_stride[i]);
            {ops[i][7],ops[i][30:25],ops[i][11:8]} = ('h1000-inst_num[i]*'h4) >> 1;
            inst_gen.get_rand_branch_inst(ops[i]);
            //$display("target_inst_num[%0d] = %0d, inst_num=%0d,imm=%0h",i,loop_seq_info.target_inst_num[i],inst_num[i],'h1000-inst_num[i]*'h4);
        end


        seq_num = seq_num + 1;
        inst_gen.reg_pool.branch_reg_free();
        return loop_seq_info;
    endfunction
endclass
