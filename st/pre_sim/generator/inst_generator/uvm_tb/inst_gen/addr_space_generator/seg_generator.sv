class seg_generator extends uvm_object;

    mode_e              mode;
    addr_type_e         addr_type;
    rand pma_type_e     pma_type;
    rand page_size_e    page_size_type;
    rand addr_except_e  except;

    rand bit[63:39] addr_high_bits;
    rand bit[1:0]   seg_num;    // generator serveral same attr seg once

    addr_space_config   addr_space_cfg;

    int size_in_bytes;
    rand bit [29:0] addr_offset;

    `uvm_object_utils_begin(seg_generator)
        `uvm_field_enum(addr_type_e,    addr_type, UVM_DEFAULT)
        `uvm_field_enum(pma_type_e,  pma_type, UVM_DEFAULT)
        `uvm_field_enum(page_size_e,    page_size_type, UVM_DEFAULT)
        `uvm_field_enum(addr_except_e,  except, UVM_DEFAULT)
        `uvm_field_int(addr_offset, UVM_DEFAULT)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "seg_generator");
        super.new(name);
    endfunction : new
    constraint pma_type_c{
        if(addr_type == LOAD_VALID || addr_type == LS_VALID){
            pma_type dist{
            MEMORY      := addr_space_cfg.pma_type_dist[0],
            IO_IDEM     := addr_space_cfg.pma_type_dist[1],
            IO_UNIDEM   := addr_space_cfg.pma_type_dist[2]
            };
        }
        else if(addr_type == FETCH_VALID || addr_type == AMO_VALID||addr_type == RESERVED || addr_type == PTE_VALID){
            pma_type dist{
            MEMORY      := addr_space_cfg.pma_type_dist[0],
            IO_IDEM     := addr_space_cfg.pma_type_dist[1]
            };
        }
        else if((addr_type == LOAD_INVALID || addr_type == LS_INVALID) && except ==PMA_ACCESS_FAULT) {pma_type == INVALID;}
        else if((addr_type == FETCH_INVALID || addr_type == AMO_INVALID || PTE_INVALID)&& except ==PMA_ACCESS_FAULT){pma_type inside {INVALID,IO_UNIDEM};}
        else{
            pma_type dist{
            MEMORY      := addr_space_cfg.pma_type_dist[0],
            IO_IDEM     := addr_space_cfg.pma_type_dist[1],
            IO_UNIDEM   := addr_space_cfg.pma_type_dist[2],
            INVALID     := addr_space_cfg.pma_type_dist[3]
            };
        }
    }

    constraint seg_num_c{
        if(addr_type == RESERVED || addr_type == PTE_VALID) {seg_num == 1;}
        else seg_num > 0;
    }

    constraint addr_offset_c{
        if(addr_type == FETCH_VALID) {addr_offset[1:0] == 0;}       //align with word because fetch align with word.(if support compress inst TODO)
        //else if(addr_type == AMO_VALID || addr_type == PTE_INVALID) {addr_offset[2:0] == 0;}    //align with dword because amo have no addr+offset
        else if(addr_type == AMO_VALID ) {addr_offset[1:0] == 0;}    //align with dword because amo have no addr+offset -- modify because amo has amo.w
        else if(addr_type == AMO_INVALID && except == ADDR_MISALIGN) {addr_offset[2:0] inside{[1:7]};}
        else if(addr_type == PTE_VALID) {addr_offset[11:0] == 0;}   // vpn offset
        else if(addr_type == RESERVED){addr_offset[11:0] == 0;}
        else if(addr_type == FETCH_INVALID)  addr_offset[1:0] == 0; //TODO: if design compress inst not support. can close this

//        if(page_size_type == HUGE_PAGE) addr_offset random
        if(page_size_type == BIG_PAGE) addr_offset[29:21] == 0;
        else if(page_size_type == SMALL_PAGE) addr_offset[29:12] == 0;


    }
    constraint size_in_bytes_c{
        if(addr_type == RESERVED) { page_size_type inside{BIG_PAGE,HUGE_PAGE};}
        else {
            page_size_type dist{
                HUGE_PAGE   := addr_space_cfg.page_size_dist[0],
                BIG_PAGE    := addr_space_cfg.page_size_dist[1],
                SMALL_PAGE  := addr_space_cfg.page_size_dist[2]
            };
        }
    }
    constraint addr_except_c{
        (addr_type == FETCH_VALID || addr_type == LOAD_VALID || addr_type == RESERVED ||
         addr_type == LS_VALID || addr_type == AMO_VALID || addr_type == PTE_VALID)       -> except == NONE_ADDR_EXCEPT;
        (addr_type == FETCH_INVALID || addr_type == LOAD_INVALID ||
         addr_type == LS_INVALID || addr_type == AMO_INVALID)   -> except != NONE_ADDR_EXCEPT;
        (addr_type == PTE_INVALID) -> except inside{PMA_ACCESS_FAULT , PMP_ACCESS_FAULT};   //pte addr only have pma/pmp access fault
         if(!addr_space_cfg.pmp_except_en) except != PMP_ACCESS_FAULT;
         if(mode == M_MODE || addr_space_cfg.map_mode !=8 ) except != PTE_PAGE_FAULT;
         if(addr_type != AMO_INVALID)except != ADDR_MISALIGN;//ls will do with another mechinism
    }

    constraint solve_c{
        solve except before pma_type;
    }

    constraint addr_high_bits_c{
        if(except == VADDR_HIGH_BITS_ERR) {addr_high_bits !=0;}
        else {addr_high_bits == 0};
    }

    function void post_randomize();
        if(addr_type == AMO_INVALID && except == ADDR_MISALIGN)begin
            size_in_bytes = 0;//no need allocate in seg pool
        end
        else begin
            case(page_size_type)
                SMALL_PAGE  : size_in_bytes = 'h1000       ;
                BIG_PAGE    : size_in_bytes = 'h20_0000    ;
                HUGE_PAGE   : size_in_bytes = 'h4000_0000  ;
            endcase
        end

    endfunction
endclass : seg_generator
