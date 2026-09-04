class config_sequence extends uvm_object;
    li_sequence         li_seq;
    except_handle_sequence   except_handle_seq;
    `uvm_object_utils_begin(config_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "config_sequence");
      super.new(name);
      li_seq = new();
      except_handle_seq = new();
    endfunction : new

    virtual function seq_gen(csr_config csr_cfg,inst_generator inst_gen,bit except_disable,bit int_ack_disable);
        int csr_cfg_size;
        bit [63:0] avl;
        bit [63:0] vtype;
        //get mepc value
        bit[63:0] mepc;
        addr_structure_s    pte_base_s;
        addr_structure_s    m_except_handle_s;
        addr_structure_s    s_except_handle_s;

        csr_cfg_size = csr_cfg.csr_cfg_addr.size();

        // TODO: when code work, it is not sure pma window num & config value
        if($test$plusargs("csr_fast_cfg"))begin
        end
        else begin
            for(int i=0; i<inst_gen.addr_space_gen.pma_cfg_gen.seg_pma_window_num.sum();i++)begin
                li_to_csr(inst_gen,inst_gen.addr_space_gen.pma_cfg_gen.pma_window[i].pma_window_index,`pma_attr_addr(inst_gen.addr_space_gen.pma_cfg_gen.pma_window[i].pma_attr));
                li_to_csr(inst_gen,inst_gen.addr_space_gen.pma_cfg_gen.pma_window[i].pma_window_index,`pma_start_addr(inst_gen.addr_space_gen.pma_cfg_gen.pma_window[i].start_addr));
                li_to_csr(inst_gen,inst_gen.addr_space_gen.pma_cfg_gen.pma_window[i].pma_window_index,`pma_end_addr(inst_gen.addr_space_gen.pma_cfg_gen.pma_window[i].end_addr));
            end
        end

//do not skippable cfg
        if(csr_cfg.map_mode !=0 && (csr_cfg.program_mode !== M_MODE || csr_cfg.ls_mode !== M_MODE))begin  //need map, cfg satp
            pte_base_s.addr_type= PTE_VALID;
            //pte_base_s.addr_type= RESERVED;  // reserved for pte base
            pte_base_s.mode     = M_MODE;
            inst_gen.addr_space_gen.get_addr(pte_base_s);
            csr_cfg.csr_cfg_val[4][43:0] = pte_base_s.paddr >> 12;//satp.ppn
            $display("csr_cfg.satp[%0h] = %0h", csr_cfg.csr_cfg_addr[4],csr_cfg.csr_cfg_val[4]);
            inst_gen.addr_space_gen.pte_gen.pte_base_addr = pte_base_s.paddr;
            inst_gen.addr_space_gen.pte_gen.mstatus_sum = csr_cfg.mstatus_sum;
            inst_gen.addr_space_gen.alloc_reserved_pte(csr_cfg.ls_mode);
        end
        else inst_gen.addr_space_gen.pte_gen.link_reserved_seg_alloc_flag = 1;
        //config except entry
        m_except_handle_s.addr_type = RESERVED;
        m_except_handle_s.mode = M_MODE;
        inst_gen.addr_space_gen.get_addr(m_except_handle_s);
//        `csrrw(0,0,`mtvec);
        //`csrrw(0,0,`stvec);
        inst_gen.inst_addr = m_except_handle_s.vaddr;
        inst_gen.inst_paddr = m_except_handle_s.paddr;
        except_handle_seq.seq_gen(m_except_handle_s.paddr, inst_gen,except_disable,except_disable&int_ack_disable,M_MODE);
        inst_gen.addr_space_gen.m_except_handle_s = m_except_handle_s;

        s_except_handle_s.addr_type = RESERVED;

        if(csr_cfg.map_mode !=0 && (csr_cfg.program_mode !== M_MODE || csr_cfg.ls_mode !== M_MODE))begin
        s_except_handle_s.mode = S_MODE;
        end
        else
        s_except_handle_s.mode = M_MODE;
        inst_gen.addr_space_gen.get_addr(s_except_handle_s);
        inst_gen.inst_addr = s_except_handle_s.vaddr;
        inst_gen.inst_paddr = s_except_handle_s.paddr;
        except_handle_seq.seq_gen(s_except_handle_s.paddr, inst_gen,except_disable,csr_cfg.s_except_handle_en,S_MODE);
        inst_gen.addr_space_gen.s_except_handle_s = s_except_handle_s;

 inst_gen.inst_addr  =`BOOT_PC;
        inst_gen.inst_paddr =`BOOT_PC;
        inst_gen.inst_cnt = 'h4000_0000;
        $fwrite(inst_gen.vmem_file,("@%0h\n"),`BOOT_PC>>2);

        li_to_csr(inst_gen,`mtvec,m_except_handle_s.vaddr);
        li_to_csr(inst_gen,`stvec,s_except_handle_s.vaddr);


        //if(csr_cfg.program_mode !== M_MODE || csr_cfg.program_mode == M_MODE && csr_cfg.ls_mode == U_MODE && csr_cfg.mprv == 0)begin
        if(csr_cfg.mret_config)begin
            mepc = 0;
            li_to_csr(inst_gen,`mepc, mepc);
            `mret;
            inst_gen.switch_task(0);
        end

    endfunction

    function void li_to_csr(inst_generator inst_gen,bit[11:0] csr_addr, bit[63:0] csr_val);
        $fwrite(inst_gen.gen_file,("// li to csr[%0h] : %0h\n"),csr_addr,csr_val);
        li_seq.seq_gen(inst_gen,csr_val,1);
        `csrrw(1,1,csr_addr);
    endfunction

endclass
                                   
