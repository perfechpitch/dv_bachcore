//**************************************************************************************
//ls seg: load/ls/amo valid/invalid

//---------------- valid Load   : can load from all Link seg , load seg, ls seg, amo seg, even program seg.

//---------------- invalid load : can load from invalid ls seg, invalid load seg, invalid amo seg.

//---------------- valid store  : can store to  ls seg, amo seg.

//---------------- invalid store: can store to invalid ls seg, invalid amo seg.

//---------------- valid amo    : can amo to amo seg.

//---------------- invalid amo  : can amo to invalid amo seg. 

//-------hard case1: like base+imm skip to another page or fetch add to next page. seg Miss.
//                  PLAN A use seg_extend is difficult for debug because extend again & again.
//                  PLAN B generator more than one seg once. if skip another page is legal. it work. else fix imm to be limited.
// 
//**************************************************************************************

//step1: release fetch addr allocate(Base function Done)
//step2: release pma gen(Base function Done)
//step3: release ls addr allocate(Base function Done)
//step4: release pmp gen
//step5: release pte generator
class addr_space_generator extends uvm_object;
    seg_generator   seg_gen;
    seg_pool        memory_seg_pool;
    seg_pool        io_idem_seg_pool;
    seg_pool        io_unidem_seg_pool;
    seg_pool        invalid_seg_pool;

    ls_imm_generator    ls_imm_gen;
    pma_config_generator    pma_cfg_gen;
    pmp_config_generator    pmp_cfg_gen;
    pte_generator           pte_gen;
    seg_info_s      link_segs[$];
    bit[63:0]       link_addrs[$];
    int             link_seg_index;

    int             addr_space_log;
    seg_info_s      reserved_seg_info;
    addr_structure_s  reserved_addr_info;
    addr_structure_s  m_except_handle_s;
    addr_structure_s  s_except_handle_s;
    bit[63:0]               fetch_invalid_vaddrs[$];

    addr_space_config  addr_space_cfg;

    `uvm_object_utils_begin(addr_space_generator)
    `uvm_object_utils_end


    // new - constructor
    function new (string name = "addr_space_generator");
        super.new(name);

        addr_space_log = $fopen(($psprintf("./log/addr_space.log")),"w");


        ls_imm_gen = new();
        pma_cfg_gen = new();
        pmp_cfg_gen = new();
        pte_gen = new();
        seg_gen = new();
        memory_seg_pool     = new();
        io_idem_seg_pool    = new();
        io_unidem_seg_pool  = new();
        invalid_seg_pool    = new();


        link_seg_index = 0;


        memory_seg_pool.addr_space_log = addr_space_log;
        io_idem_seg_pool.addr_space_log = addr_space_log;
        io_unidem_seg_pool.addr_space_log = addr_space_log;
        invalid_seg_pool.addr_space_log = addr_space_log;
    endfunction : new


    function void addr_space_init();
        memory_seg_pool.next_seg_addr       = addr_space_cfg.pool_start_paddr[0];//'h00_0000_0000;
        io_idem_seg_pool.next_seg_addr      = addr_space_cfg.pool_start_paddr[1];//'h40_0000_0000;
        io_unidem_seg_pool.next_seg_addr    = addr_space_cfg.pool_start_paddr[2];//'h80_0000_0000;
        invalid_seg_pool.next_seg_addr      = addr_space_cfg.pool_start_paddr[3];//'hc0_0000_0000;

        pma_cfg_gen.seg_start_addr[memory_seg_index]      = memory_seg_pool.next_seg_addr       ;
        pma_cfg_gen.seg_start_addr[io_idem_seg_index]     = io_idem_seg_pool.next_seg_addr      ;
        pma_cfg_gen.seg_start_addr[io_unidem_seg_index]   = io_unidem_seg_pool.next_seg_addr    ;
        pma_cfg_gen.seg_start_addr[invalid_seg_index]     = invalid_seg_pool.next_seg_addr      ;

        pmp_cfg_gen.seg_start_addr[memory_seg_index]      = memory_seg_pool.next_seg_addr       ;
        pmp_cfg_gen.seg_start_addr[io_idem_seg_index]     = io_idem_seg_pool.next_seg_addr      ;
        pmp_cfg_gen.seg_start_addr[io_unidem_seg_index]   = io_unidem_seg_pool.next_seg_addr    ;
        pmp_cfg_gen.seg_start_addr[invalid_seg_index]     = invalid_seg_pool.next_seg_addr      ;


        pte_gen.addr_space_cfg = addr_space_cfg;
        seg_gen.addr_space_cfg = addr_space_cfg;
        seg_gen.addr_type = RESERVED;
        seg_gen.mode = M_MODE;
        seg_gen.randomize();

        //reserved_seg_info.mode      = M_MODE;
        //reserved_seg_info.addr_type = RESERVED;
        //reserved_seg_info.page_size = seg_gen.page_size_type;
        //reserved_seg_info.pma_type  = seg_gen.pma_type;
        //reserved_seg_info.size_in_bytes = seg_gen.size_in_bytes;

 reserved_addr_info.addr_type = RESERVED;
        reserved_addr_info.mode = M_MODE;
        reserved_seg_info.page_size = seg_gen.page_size_type;
        reserved_seg_info.size_in_bytes = seg_gen.size_in_bytes;

        if(memory_seg_pool.next_seg_addr == 0)begin
            reserved_seg_info.pma_type = MEMORY;
            memory_seg_pool.get_seg_info(reserved_seg_info, link_seg_index);
        end
        else if(io_idem_seg_pool.next_seg_addr == 0)begin
            reserved_seg_info.pma_type = IO_IDEM;
            io_idem_seg_pool.get_seg_info(reserved_seg_info, link_seg_index);
        end
        $fwrite(addr_space_log,"#############  reserved for seg link with %0s seg, start from paddr 0\n",reserved_seg_info.pma_type);
        if(addr_space_cfg.map_mode == 'd8)begin
        end
        $fwrite(addr_space_log,"[reserved addr_info] : %p\n",reserved_addr_info);

        memory_seg_pool.max_link_seg_index = reserved_seg_info.size_in_bytes/8 - 1;
        io_idem_seg_pool.max_link_seg_index = reserved_seg_info.size_in_bytes/8 - 1;
        io_unidem_seg_pool.max_link_seg_index = reserved_seg_info.size_in_bytes/8 - 1;
        invalid_seg_pool.max_link_seg_index = reserved_seg_info.size_in_bytes/8 - 1;
        link_seg_index          = link_seg_index + 1;
        link_segs.push_back(reserved_seg_info);
        link_addrs.push_back(seg_gen.addr_offset);

        //pmp_cfg_gen.req_seg_info = reserved_seg_info;
        pmp_cfg_gen.pmp_cfg_c.constraint_mode(0);
        pmp_cfg_gen.randomize(rand_reserved_pmp_cfg);
        pmp_cfg_gen.alloc_reserved_pmp();
        pmp_cfg_gen.pmp_cfg_c.constraint_mode(1);
    endfunction
    function int get_inst_cnt(int req_index);
        int inst_cnt;
        inst_cnt = (link_segs[req_index].size_in_bytes - link_segs[req_index].addr_offset)/4;
        return inst_cnt;
    endfunction
 //get addr function work when
    //jalr seq 
    //get lsbase reg addr
    function seg_info_s get_addr(ref addr_structure_s addr_info);
        bit [1:0] new_seg_gen;  //bit0: new page ,bit1: new link
        bit vaddr_high_bits_err;
        bit pmp_window_almost_overflow;
        seg_info_s  seg_info;
        seg_info_s  fetch_reserved_seg_info;

        new_seg_gen = 0;
        seg_gen.addr_type = addr_info.addr_type;
        seg_gen.mode = addr_info.mode;
        seg_gen.randomize();


        seg_info.mode      = addr_info.mode;
        seg_info.addr_type = addr_info.addr_type;
        seg_info.page_size = seg_gen.page_size_type;
        seg_info.pma_type  = seg_gen.pma_type;
        seg_info.size_in_bytes = seg_gen.size_in_bytes*seg_gen.seg_num;
        seg_info.addr_offset = seg_gen.addr_offset;
        seg_info.addr_except = seg_gen.except;
        if(addr_info.addr_type != PTE_VALID && addr_info.addr_type != PTE_INVALID)
        $fwrite(addr_space_log,"#############  get a %0s %0p addr\n",seg_gen.pma_type,addr_info.addr_type);
        if(seg_info.addr_except == VADDR_HIGH_BITS_ERR)begin
            vaddr_high_bits_err = 1;
            seg_info.start_vaddr = {seg_gen.addr_high_bits,40'b0} + seg_info.addr_offset;
            seg_info.start_paddr = 0;
            seg_info.link_seg_index = link_seg_index;
        end
        else begin
            case(seg_gen.pma_type)
                INVALID:begin
                    new_seg_gen = invalid_seg_pool.get_seg_info(seg_info, link_seg_index);
                end
                MEMORY:begin
                    new_seg_gen = memory_seg_pool.get_seg_info(seg_info, link_seg_index);
                end
                IO_IDEM:begin
                    new_seg_gen = io_idem_seg_pool.get_seg_info(seg_info, link_seg_index);
                end
                IO_UNIDEM:begin
                    new_seg_gen = io_unidem_seg_pool.get_seg_info(seg_info, link_seg_index);
                end
            endcase
        end

        if(new_seg_gen[0] && addr_info.addr_type !== PTE_VALID && addr_info.addr_type !== PTE_INVALID)begin
            if(seg_info.mode != M_MODE && seg_info.addr_except != VADDR_HIGH_BITS_ERR && addr_space_cfg.map_mode == 'd8)begin
                alloc_pte(seg_info);
                override_seg_vaddr(seg_info);

            end
        end
        // vaddr will be override if map
 if((|new_seg_gen || vaddr_high_bits_err) && addr_info.addr_type !== PTE_VALID && addr_info.addr_type !== PTE_INVALID)begin
            link_segs.push_back(seg_info);
            link_seg_index          = link_seg_index + 1;
            link_addrs.push_back(seg_info.start_vaddr + seg_info.addr_offset);
        end

        addr_info.vaddr = seg_info.start_vaddr + seg_info.addr_offset;
        addr_info.paddr = seg_info.start_paddr + seg_info.addr_offset;
        addr_info.link_seg_index = seg_info.link_seg_index;
        addr_info.pma_type = seg_info.pma_type;
        addr_info.addr_except = seg_info.addr_except;
        if(addr_info.addr_type != PTE_VALID && addr_info.addr_type != PTE_INVALID)
        $fwrite(addr_space_log,"[addr_info] : %p\n",addr_info);

        /*
        if(addr_info.addr_type == FETCH_VALID)begin
            seg_extend(addr_info);
            $fwrite(addr_space_log,"----- fetch extend : [seg extend 3]\n");
        end
        */

        //allocate pmp if need
        if(new_seg_gen[0] && seg_info.addr_except == PMP_ACCESS_FAULT)begin
            pmp_window_almost_overflow = allocate_pmp(seg_info);//pmp_cfg_gen.allocate_pmp(seg_info);
            if(pmp_window_almost_overflow) addr_space_cfg.pmp_except_en = 0;
        end

        return seg_info;

    endfunction



    function addr_type_e get_addr_type(pma_type_e pma_type, bit[63:0] vaddr);
        addr_type_e addr_type;

        //case(pma_type)
        //    INVALID:begin
        //        addr_type = invalid_seg_pool.get_addr_type(vaddr);
        //    end
        //    MEMORY:begin
        //        addr_type = memory_seg_pool.get_addr_type(vaddr);
        //    end
        //    IO_IDEM:begin
        //        addr_type = io_idem_seg_pool.get_addr_type(vaddr);
        //    end
        //    IO_UNIDEM:begin
        //        addr_type = io_unidem_seg_pool.get_addr_type(vaddr);
        //    end
        //endcase

        //for bug sitiuation:
        //alloc seg0: vaddr_A -> IO IDEM, AMO VALID seg
        //alloc seg1: vaddr_A + 'h1000 -> MEMORY, LOAD_VALID seg
        //ls req IO IDEM LS SEG, base + 7'hfff hit seg1 vaddr range, but find in IO IDEM seg pool
        //fine failed. return RESERVED.
        //follwing beheavior error.
   addr_type = invalid_seg_pool.get_addr_type(vaddr);
        if(addr_type == RESERVED)
        addr_type = memory_seg_pool.get_addr_type(vaddr);
        if(addr_type == RESERVED)
        addr_type = io_idem_seg_pool.get_addr_type(vaddr);
        if(addr_type == RESERVED)
        addr_type = io_unidem_seg_pool.get_addr_type(vaddr);
       return addr_type;
   endfunction

   function bit addr_type_legal(addr_type_e req_addr_type, addr_type_e check_addr_type);
       bit type_ok;

        //if(check_addr_type == RESERVED)begin
        //    type_ok = 0;
        //end
        //else begin
        case(req_addr_type)
            LOAD_VALID      :   type_ok = check_addr_type == LOAD_VALID   || check_addr_type == LS_VALID    || check_addr_type == AMO_VALID || check_addr_type == RESERVED;
            LOAD_INVALID    :   type_ok = check_addr_type == LOAD_INVALID;
            LS_VALID        :   type_ok =                                    check_addr_type == LS_VALID    || check_addr_type == AMO_VALID;
            LS_INVALID      :   type_ok = check_addr_type == LOAD_INVALID || check_addr_type == LS_INVALID;
            AMO_VALID       :   type_ok =                                                                      check_addr_type == AMO_VALID;
            AMO_INVALID     :   type_ok = check_addr_type == LOAD_INVALID || check_addr_type == LS_INVALID  || check_addr_type == AMO_INVALID;
        endcase
        //end
        return type_ok;
    endfunction
    /*
    function void seg_extend(addr_structure_s addr_info);
        bit extend_end_seg;
        seg_info_s  before_extend_seg_info;
        seg_info_s  after_extend_seg_info;

        before_extend_seg_info = link_segs[addr_info.link_seg_index];

        after_extend_seg_info               = before_extend_seg_info;
        after_extend_seg_info.mode          = addr_info.mode;
        after_extend_seg_info.addr_type     = addr_info.addr_type;
        after_extend_seg_info.addr_offset   = 'd0;
        after_extend_seg_info.start_vaddr   = before_extend_seg_info.start_vaddr + before_extend_seg_info.size_in_bytes;
        after_extend_seg_info.start_paddr   = before_extend_seg_info.start_paddr + before_extend_seg_info.size_in_bytes;
        after_extend_seg_info.link_seg_index = link_seg_index;

        case(after_extend_seg_info.pma_type)
            MEMORY      : extend_end_seg = memory_seg_pool.seg_extend(after_extend_seg_info);
            IO_IDEM     : extend_end_seg = io_idem_seg_pool.seg_extend(after_extend_seg_info);
            IO_UNIDEM   : extend_end_seg = io_unidem_seg_pool.seg_extend(after_extend_seg_info);
            INVALID     : extend_end_seg = invalid_seg_pool.seg_extend(after_extend_seg_info);
        endcase

        $fwrite(addr_space_log,"[Before extend seg info] : %0p\n", before_extend_seg_info);
        $fwrite(addr_space_log,"[After extend seg info] : %0p\n", link_segs[after_extend_seg_info.link_seg_index]);

        link_segs.push_back(after_extend_seg_info);
        link_seg_index = link_seg_index + 1;
        link_addrs.push_back(after_extend_seg_info.start_vaddr);

        if(after_extend_seg_info.mode != M_MODE && after_extend_seg_info.addr_except != VADDR_HIGH_BITS_ERR && addr_space_cfg.map_mode == 'd8)begin
            alloc_pte(after_extend_seg_info);
        end
    endfunction
    */
 function bit[11:0] get_ls_imm(addr_structure_s ls_s,ops_gen_config ops_gen_cfg);
        bit[11:0] ls_imm;
        bit[63:0] temp_addr;
        addr_type_e temp_addr_type;
        bit type_ok;

        ls_imm_gen.base_addr = ls_s.vaddr;
        ls_imm_gen.ls_op_cfg = ops_gen_cfg;
        type_ok=0;

        $fwrite(addr_space_log,"#############  ls_s req imm : %0p\n", ls_s);
        if(!ops_gen_cfg.ls_addr_misalign)begin
            //if(ops_gen_cfg.ls_inst_unsigned)begin   // unsigned is for rd wb , not for imm bit[11]
            //    temp_addr = ls_s.vaddr + 'hfff;
            //    temp_addr_type = get_addr_type(ls_s.pma_type,temp_addr);
            //    if(temp_addr_type == RESERVED)begin
            //        seg_extend(link_segs[ls_s.link_seg_index]);
            //        $fwrite(addr_space_log,"[seg extend 0]\n");
            //        type_ok = 1;
            //    end
            //    else
            //    type_ok = addr_type_legal(ls_s.addr_type,temp_addr_type);
            //    $fwrite(addr_space_log,"00 temp addr = %0h, type_ok = %0h\n",temp_addr,type_ok);

            //    /*set imm range*/
            //    if(type_ok)begin
            //        ls_imm_gen.max_positive_imm = 'hfff; 
            //    end
            //    else begin
            //        ls_imm_gen.max_positive_imm = link_segs[ls_s.link_seg_index].start_vaddr + link_segs[ls_s.link_seg_index].size_in_bytes - ls_s.vaddr;
            //    end
            //end
            //else                    begin
                temp_addr = ls_s.vaddr + 'h7ff;
                temp_addr_type = get_addr_type(ls_s.pma_type,temp_addr);
                if(temp_addr_type == RESERVED)begin
                    type_ok = 0;
                    /*
                    seg_extend(link_segs[ls_s.link_seg_index]);
                    $fwrite(addr_space_log,"----- addr overflow : [seg extend 1]\n");
                    type_ok = 1;*/
                end
                else
                type_ok = addr_type_legal(ls_s.addr_type,temp_addr_type);
                /*set negetive imm range*/
                if(type_ok)begin
                    ls_imm_gen.max_positive_imm = 'h7ff;
                end
                else begin
                    ls_imm_gen.max_positive_imm = link_segs[ls_s.link_seg_index].start_vaddr + link_segs[ls_s.link_seg_index].size_in_bytes - ls_s.vaddr;
                end
 $fwrite(addr_space_log,"11 temp addr = %0h, type_ok = %0h, ls_s.addr_type = %0s, temp_addr_type = %0s,max_imm = %h\n",temp_addr,type_ok,ls_s.addr_type.name(),temp_addr_type,ls_imm_gen.max_positive_imm);

                temp_addr = ls_s.vaddr - 'h7ff;
                temp_addr_type = get_addr_type(ls_s.pma_type,temp_addr);
                if(temp_addr_type == RESERVED)begin
                    type_ok = 0;
                    /*
                    seg_extend(link_segs[ls_s.link_seg_index]);
                    $fwrite(addr_space_log,"----- addr underflow : [seg extend 2]\n");
                    type_ok = 1;
                    */
                end
                else
                type_ok = addr_type_legal(ls_s.addr_type,temp_addr_type);

                /*set negetive imm range*/
                if(type_ok)begin
                    ls_imm_gen.max_negetive_imm = 'h800;
                end
                else begin
                    ls_imm_gen.max_negetive_imm[10:0] = 'h800 - ls_s.vaddr[10:0];
                    ls_imm_gen.max_negetive_imm[11] = 1;
                end
                $fwrite(addr_space_log,"22 temp addr = %0h, type_ok = %0h, ls_s.addr_type = %0s, temp_addr_type = %0s,max_imm = %h\n",temp_addr,type_ok,ls_s.addr_type.name(),temp_addr_type,ls_imm_gen.max_negetive_imm);
            //end
        end
        else begin
            ls_imm_gen.max_positive_imm = 'hfff;
            ls_imm_gen.max_negetive_imm = 'h800;
        end

        ls_imm_gen.randomize();
        ls_imm = ls_imm_gen.ls_imm;
        $fwrite(addr_space_log,"ls_imm_gen.max_positive_imm = %0h, ls_imm_gen.max_negetive_imm = %0h\n",ls_imm_gen.max_positive_imm,ls_imm_gen.max_negetive_imm);
        $fwrite(addr_space_log,"[get a ls imm] : ls_s = %0p, ls_imm =%0h, type_ok = %0h\n",ls_s, ls_imm, type_ok);
//        $fwrite(addr_space_log,"ls_ok hit seg info: %0p\n",link_segs[ls_s.link_seg_index]);
        return ls_imm;
    endfunction
  function bit ls_imm_fix(bit[31:0] ls_imm,ref addr_structure_s ls_s);
        bit[63:0] temp_addr;
        addr_type_e temp_addr_type;
        bit imm_ok;

        imm_ok =0;
        if(ls_imm[11]) temp_addr = ls_s.vaddr + ls_imm[10:0];
        else temp_addr = ls_s.vaddr + 'h1000 - ls_imm;
        temp_addr_type = get_addr_type(ls_s.pma_type,temp_addr);
        $fwrite(addr_space_log,"----- ls_imm_fix : ls_imm = %0h,temp_addr= %0h, temp_addr_type =%0s",ls_imm,temp_addr,temp_addr_type);
        /*when load base reg ,temp_addr_type is RESERVED*/
        if(temp_addr_type == RESERVED)begin
            imm_ok = 0;
            /*
            seg_extend(link_segs[ls_s.link_seg_index]);
            $fwrite(addr_space_log,"----- ls_imm_fix : [seg extend]\n");
            imm_ok = 1;
            */
        end
        else
        imm_ok = addr_type_legal(ls_s.addr_type,temp_addr_type);
        $fwrite(addr_space_log,"----- ls_imm_fix : imm_ok= %0h",imm_ok);
        return imm_ok;
    endfunction
    function void pmp_config_gen();
        pmp_cfg_gen.seg_end_addr[memory_seg_index]      = memory_seg_pool.next_seg_addr;
        pmp_cfg_gen.seg_end_addr[io_idem_seg_index]     = io_idem_seg_pool.next_seg_addr;
        pmp_cfg_gen.seg_end_addr[io_unidem_seg_index]   = io_unidem_seg_pool.next_seg_addr;
        pmp_cfg_gen.seg_end_addr[invalid_seg_index]     = invalid_seg_pool.next_seg_addr;
        pmp_cfg_gen.data_out();
    endfunction
    function void pma_config_gen();
        pma_cfg_gen.seg_end_addr[memory_seg_index]      = memory_seg_pool.next_seg_addr;
        pma_cfg_gen.seg_end_addr[io_idem_seg_index]     = io_idem_seg_pool.next_seg_addr;
        pma_cfg_gen.seg_end_addr[io_unidem_seg_index]   = io_unidem_seg_pool.next_seg_addr;
        pma_cfg_gen.seg_end_addr[invalid_seg_index]     = invalid_seg_pool.next_seg_addr;
        pma_cfg_gen.randomize();
    endfunction
 function void data_vmem_out(int file);
        $fwrite(file,"@%0h\n",reserved_seg_info.start_paddr >> 2);
        foreach(link_segs[i])begin
            $fwrite(file,"%8h\n",link_addrs[i][31:0]);
            $fwrite(file,"%8h\n",link_addrs[i][63:32]);
        end
        if(fetch_invalid_vaddrs.size() != 0)begin
            $fwrite(file,"@%0h\n",(m_except_handle_s.paddr +'h200)>> 2);
                $fwrite(file,"%8h\n",8);//fetch_except_cnt
                $fwrite(file,"%8h\n",0);
            foreach(fetch_invalid_vaddrs[i])begin
                $fwrite(file,"%8h\n",fetch_invalid_vaddrs[i][31:0]);
                $fwrite(file,"%8h\n",fetch_invalid_vaddrs[i][63:32]);
            end
            $fwrite(file,"@%0h\n",(s_except_handle_s.paddr +'h200)>> 2);
                $fwrite(file,"%8h\n",8);//fetch_except_cnt
                $fwrite(file,"%8h\n",0);
            foreach(fetch_invalid_vaddrs[i])begin
                $fwrite(file,"%8h\n",fetch_invalid_vaddrs[i][31:0]);
                $fwrite(file,"%8h\n",fetch_invalid_vaddrs[i][63:32]);
            end
        end
        pma_config_gen();
        pmp_config_gen();
        pte_gen.data_out(file);
    endfunction
    function bit allocate_pmp(seg_info_s seg_info);
        bit almost_overflow;
        pmp_cfg_gen.req_seg_info = seg_info;
        pmp_cfg_gen.reserved_pmp_cfg_c.constraint_mode(0);
        pmp_cfg_gen.randomize(rand_pmp_cfg);
//        $display("rand_pmp_cfg = %0h", pmp_cfg_gen.rand_pmp_cfg);
        $fwrite(addr_space_log,"\t- alloc pmp cfg : %0h\n",pmp_cfg_gen.rand_pmp_cfg);
        almost_overflow = pmp_cfg_gen.alloc_pmp();

        return almost_overflow;
    endfunction
function void alloc_pte(ref seg_info_s seg_info);
        bit [2:0] pte_addr_alloc;
        seg_info_s  pte_seg_info;
        addr_structure_s pte_info;
        bit[63:0] temp_vaddr;
        bit[39:0] temp_paddr;
        bit[1:0] seg_num;
        // Need PTE gen
        seg_num = seg_gen.seg_num;
        $fwrite(addr_space_log,"\t- seg_num : %0d\n",seg_gen.seg_num);
        for(int j=0; j<seg_num; j++)begin
            pte_gen.req_mode = seg_info.mode;
            pte_gen.req_page_size = seg_info.page_size;
            pte_gen.req_addr_type = seg_info.addr_type;
            pte_gen.randomize();    // get rand pte info
            //get pte addr
            pte_addr_alloc = pte_gen.get_pte_attr(addr_space_log);
            $fwrite(addr_space_log,"\t- alloc pte seg : %0p\n",seg_info);

            for(int i=pte_gen.pte_level; i<2; i++)begin
                if(pte_addr_alloc[i] || pte_gen.rand_pte_addr_type[i] == PTE_INVALID )begin
                    pte_info.addr_type = pte_gen.rand_pte_addr_type[i];
                    pte_info.mode = M_MODE;
                    pte_seg_info = get_addr(pte_info);
                    pte_gen.pte_addr[i] = pte_seg_info.start_paddr;
                    $fwrite(addr_space_log,"\t- pte addr alloc[%0d] : %0h\n",i,pte_gen.pte_addr[i]);
                end
            end
            if(j == 0)begin
            seg_info.start_vaddr = pte_gen.get_vaddr(seg_info.start_paddr,addr_space_log); // alloc pte addr seg
            temp_paddr = seg_info.start_paddr;
            end
            else begin
                case(seg_info.page_size)
                    SMALL_PAGE: temp_paddr = temp_paddr +'h1000;
                    BIG_PAGE: temp_paddr = temp_paddr +'h20_0000;
                    HUGE_PAGE: temp_paddr = temp_paddr +'h4000_0000;
                endcase
                temp_vaddr = pte_gen.get_vaddr(temp_paddr,addr_space_log); // alloc pte addr seg
            end
        end

    endfunction
    function void override_seg_vaddr(ref seg_info_s seg_info);
        case(seg_info.pma_type)
            MEMORY  : memory_seg_pool.override_seg_vaddr(seg_info.start_vaddr);
            IO_IDEM  : io_idem_seg_pool.override_seg_vaddr(seg_info.start_vaddr);
            IO_UNIDEM: io_unidem_seg_pool.override_seg_vaddr(seg_info.start_vaddr);
            INVALID : invalid_seg_pool.override_seg_vaddr(seg_info.start_vaddr);
        endcase
    endfunction

  function void alloc_reserved_pte(mode_e base_load_mode); //call in config seq. after pte seg get
        seg_gen.seg_num = 1;
        reserved_seg_info.mode = base_load_mode;
        $fwrite(addr_space_log,"#############  reserved seg alloc pte\n");
        alloc_pte(reserved_seg_info);
        override_seg_vaddr(reserved_seg_info);
        pte_gen.link_reserved_seg_alloc_flag = 1;
    endfunction


endclass
               


