class seg_pool extends uvm_object;
    mode_e  ls_mode;
    int addr_space_log;
    seg_info_s      segs[$];
    bit [39:0]      next_seg_addr;
    int max_link_seg_index;
    `uvm_object_utils_begin(seg_pool)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "seg_pool");
        super.new(name);
    endfunction : new

    function void override_seg_vaddr(bit[63:0] vaddr);
        int f_q[$];
        f_q = segs.find_last_index with(item.addr_type !== PTE_VALID && item.addr_type !== PTE_INVALID);
        $fwrite(addr_space_log,"[seg va override] : %0h -> %0h\n",segs[f_q[0]].start_vaddr , vaddr);
        segs[f_q[0]].start_vaddr = vaddr;
    endfunction
    function bit[1:0] get_seg_info(ref seg_info_s seg_info, int link_seg_index);
        int find_index_q[$];
        int rand_index_id;

        bit [1:0]new_seg_gen; // bit0 = new page, bit1 = new link
        bit [29:0] addr_offset;

        new_seg_gen = 0;
        find_index_q = segs.find_index with(seg_info.addr_type == item.addr_type && seg_info.page_size == item.page_size && seg_info.mode == item.mode);
//                                            && item.addr_offset != item.size_in_bytes/*pte addr offset will add 8 once when hit*/);

        if(find_index_q.size() == 0 || seg_info.addr_type == FETCH_VALID || seg_info.addr_type == PTE_VALID)begin
            //next_seg_align;

            //$fwrite(addr_space_log,"next_seg_addr = %0h, aaa= %0h",next_seg_addr,next_seg_addr+seg_info.size_in_bytes);
            if((next_seg_addr < `BOOT_PC) && ((next_seg_addr+seg_info.size_in_bytes) > `BOOT_PC)) begin
                next_seg_addr = `BOOT_PC + 'h4000_0000;
                next_seg_addr[29:0] = 0;
            end
            //even M_MODE, need align too. because pmp NAPOT Mode may have big page include small page
            if(seg_info.page_size == BIG_PAGE && next_seg_addr[20:0] !=0)begin
                next_seg_addr = next_seg_addr + 'h20_0000;
                next_seg_addr[20:0] = 0;
            end
            if(seg_info.page_size == HUGE_PAGE && next_seg_addr[29:0] !=0)begin
                next_seg_addr = next_seg_addr + 'h4000_0000;
                next_seg_addr[29:0] = 0;
            end
            //need do twice // think more!!
            if((next_seg_addr < `BOOT_PC) && ((next_seg_addr+seg_info.size_in_bytes) > `BOOT_PC)) begin
                next_seg_addr = `BOOT_PC + 'h4000_0000;
                next_seg_addr[29:0] = 0;
            end
            //$fwrite(addr_space_log,"11 next_seg_addr = %0h",next_seg_addr);
            seg_info.start_paddr = next_seg_addr;
            seg_info.start_vaddr = next_seg_addr;
            new_seg_gen = 1;
            next_seg_addr = next_seg_addr + seg_info.size_in_bytes;
            seg_info.link_seg_index = link_seg_index    ;
            segs.push_back(seg_info);

            $fwrite(addr_space_log,"[seg Miss allocate] : %0p\n",seg_info);
        end
        else begin
        // one page can have different addr_offset until link seg index is all used in reserved area
        // pte addr use vpn find offset
            if(link_seg_index == max_link_seg_index || seg_info.addr_type == PTE_VALID || seg_info.addr_type == PTE_INVALID)begin
                new_seg_gen = 0;
                rand_index_id = $urandom_range(find_index_q.size()-1);
                rand_index_id = find_index_q[rand_index_id];
//                if(seg_info.addr_type == PTE_VALID || seg_info.addr_type == PTE_INVALID)
//                    segs[rand_index_id].addr_offset = segs[rand_index_id].addr_offset + 8;

                seg_info = segs[rand_index_id];
                if(seg_info.addr_type != PTE_VALID && seg_info.addr_type != PTE_INVALID)
                $fwrite(addr_space_log,"[Seg Hit no allocate] : %0p\n", seg_info);
            end
            else begin
                rand_index_id = $urandom_range(find_index_q.size()-1);
                rand_index_id = find_index_q[rand_index_id];
                new_seg_gen = 2;
                addr_offset = seg_info.addr_offset;
                seg_info = segs[rand_index_id];
                seg_info.addr_offset = addr_offset;
                seg_info.link_seg_index = link_seg_index    ;
                segs.push_back(seg_info);
                $fwrite(addr_space_log,"[Seg Hit ] : %0p\n",segs[rand_index_id]);
                $fwrite(addr_space_log,"[Seg Hit allocate Link ] : %0p\n",seg_info);
            end

           //$finish(); 
        end

        return new_seg_gen;
    endfunction
    function addr_type_e    get_addr_type(bit [63:0] vaddr);
        addr_type_e hit_addr_type;
        bit hit;
        hit = 0;
        foreach(segs[i])begin
            if(vaddr >= segs[i].start_vaddr && vaddr < (segs[i].start_vaddr + segs[i].size_in_bytes))begin
                hit = 1;
                hit_addr_type = segs[i].addr_type;
                break;
            end
//        $fwrite(addr_space_log,"[1111] :find addr=%0h, %0p\n",vaddr,segs[i]);
        end
        if(hit == 0)begin
            hit_addr_type = RESERVED;
        end

        return hit_addr_type;
    endfunction
    function bit seg_extend(seg_info_s seg_info);
        bit extend_end_seg;

        segs.push_back(seg_info);

        if(next_seg_addr <= (seg_info.start_paddr + seg_info.size_in_bytes)) begin
            next_seg_addr = seg_info.start_paddr + seg_info.size_in_bytes;
            if(seg_info.page_size == BIG_PAGE && next_seg_addr[20:0] !=0)begin
                next_seg_addr = next_seg_addr + 'h20_0000;
                next_seg_addr[20:0] = 0;
            end
            if(seg_info.page_size == HUGE_PAGE && next_seg_addr[29:0] !=0)begin
                next_seg_addr = next_seg_addr + 'h4000_0000;
                next_seg_addr[29:0] = 0;
            end
            if(seg_info.page_size == SMALL_PAGE)
                next_seg_addr = next_seg_addr + 'h1000;
            extend_end_seg = 0;
        end
        else extend_end_seg = 1;
        return extend_end_seg;
    endfunction
endclass : seg_pool
                                                     
