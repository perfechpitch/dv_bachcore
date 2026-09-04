
class jalr_sequence extends uvm_object;
    li_sequence             li_seq;
    jalr_seq_info_item      branch_seq_info;
    `uvm_object_utils_begin(jalr_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "jalr_sequence");
      super.new(name);
      branch_seq_info = new();
      li_seq = new();
    endfunction : new

    virtual function inst_seq_info_item sub_seq_gen(branch_seq_config   branch_seq_cfg,inst_generator inst_gen,addr_space_generator addr_space_gen,addr_type_e  fetch_addr_type);
        addr_structure_s    fetch_s;
        seg_info_s          seg_info;
        bit[63:0]           fetch_addr;
        bit [4:0]           target_reg;
        bit [4:0]           temp_reg;

        target_reg = inst_gen.reg_pool.get_nonezero_gpr(1);
        temp_reg = inst_gen.reg_pool.get_nonezero_gpr(1);

        fetch_s.addr_type = fetch_addr_type;
        fetch_s.mode = branch_seq_cfg.program_mode;
        if(fetch_addr_type == FETCH_VALID)begin
            fetch_s.vaddr = inst_gen.rand_pc_in_current_task();
            fetch_s.paddr = fetch_s.vaddr[39:0];
        end
        else
            seg_info = addr_space_gen.get_addr(fetch_s);

         

        branch_seq_info.inst_seq_cfg = branch_seq_cfg;
        branch_seq_info.randomize();
        if(fetch_addr_type == FETCH_VALID && branch_seq_info.target_gen_type == LOAD_TARGET)
            branch_seq_info.target_gen_type = ALU_TARGET;
         
        if(branch_seq_info.jalr_imm[11])
        fetch_addr = fetch_s.vaddr + 'h1000 - branch_seq_info.jalr_imm;
        else
        fetch_addr = fetch_s.vaddr - branch_seq_info.jalr_imm;

  //$display("fetch_addr = %0h, fetch_s.vaddr = %0h, jalr_imm = %0h", fetch_addr, fetch_s.vaddr, branch_seq_info.jalr_imm);
        $fwrite(inst_gen.gen_file,("//--- jalr go to %0p \n"),fetch_s);
//        branch_seq_info.print();
        case(branch_seq_info.target_gen_type)
            ALU_TARGET: li_seq.seq_gen(inst_gen, fetch_addr, target_reg);
            LOAD_TARGET:begin
                if(seg_info.link_seg_index >= 'h100)begin
                    `lui(target_reg,(seg_info.link_seg_index/'h100));
                    `srli(target_reg,target_reg,1);
                    seg_info.link_seg_index =  seg_info.link_seg_index % 'h100 * 8;
                    `addi(target_reg,target_reg,seg_info.link_seg_index); // target_reg -> target_reg+base_seg_index[i]
                    `ld(target_reg,0,target_reg);
                end
                else begin
                `ld(target_reg,seg_info.link_seg_index*8,0);
                end
            end
            MDU_TARGET:begin
                li_seq.seq_gen(inst_gen, fetch_addr, target_reg);
                `div(temp_reg,target_reg,target_reg);  // temp_reg = target_reg/target_reg = 1
                `mul(target_reg,target_reg,temp_reg);
            end
            DIV_TARGET:begin
                li_seq.seq_gen(inst_gen, fetch_addr, target_reg);
                `div(temp_reg,target_reg,target_reg);  // temp_reg = target_reg/target_reg = 1
                `div(target_reg,target_reg,temp_reg);   // target_reg = target_reg/temp_reg 
            end
        endcase


        `jalr(temp_reg,target_reg,branch_seq_info.jalr_imm);   //temp_reg = pc+4, next pc = target_reg + $signextend(jalr.imm);
        if(fetch_addr_type == FETCH_INVALID)
            inst_gen.addr_space_gen.fetch_invalid_vaddrs.push_back(inst_gen.inst_addr);
        // FETCH_VALID: keep sequential fetch layout; do not relocate inst_addr.

        $fwrite(inst_gen.gen_file,("//--- jalr seq end \n"));

        return branch_seq_info;
    endfunction

endclass
                       
