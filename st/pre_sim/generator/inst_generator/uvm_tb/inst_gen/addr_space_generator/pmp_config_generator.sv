class pmp_config_generator extends uvm_object;

    bit [39:0]      seg_start_addr[4];
    bit [39:0]      seg_end_addr[4];

    seg_info_s      req_seg_info;
    pmp_window_s    pmp_window[$];
    
    rand bit[7:0]   rand_pmp_cfg;

    rand bit[7:0]   rand_reserved_pmp_cfg[4];
//    rand bit[7:0]   rand_memory_seg_pmp_cfg;
//    rand bit[7:0]   rand_io_idem_seg_pmp_cfg;
//    rand bit[7:0]   rand_io_unidem_seg_pmp_cfg;
//    rand bit[7:0]   rand_invalid_seg_pmp_cfg;

    bit [4:0] pmp_window_size;

    int cfg_file;


    `uvm_object_utils_begin(pmp_config_generator)
        `uvm_field_sarray_int(seg_start_addr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(seg_end_addr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(rand_reserved_pmp_cfg,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(rand_pmp_cfg,UVM_DEFAULT|UVM_HEX)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "pmp_config_generator");
        super.new(name);
        cfg_file = $fopen(($psprintf("./pmp_cfg.dat")),"w");
        pmp_window_size = 0;
    endfunction : new

    constraint reserved_pmp_cfg_c{
        rand_reserved_pmp_cfg[0][2:0] == 'b111;  //xrw=111
        rand_reserved_pmp_cfg[0][4:3] inside{1,3};   // mode is 1-TOR or 3-NAPOT, valid mode
        //[6:5] WARL - 0
        rand_reserved_pmp_cfg[1][2:0] == 'b111;  //xrw=111
        rand_reserved_pmp_cfg[1][4:3] inside{1,3};   // mode is 1-TOR or 3-NAPOT, valid mode

        rand_reserved_pmp_cfg[2][1:0] == 'b11;  //rw=11. x= anyvalue. cause pma make fetch invalid also
        rand_reserved_pmp_cfg[2][4:3] inside{1,3};   // mode is 1-TOR or 3-NAPOT, valid mode
        //invalid
        rand_reserved_pmp_cfg[3][4:3] inside{1,3};   // mode is 1-TOR or 3-NAPOT, valid mode
    }
  constraint pmp_cfg_c{
        if(req_seg_info.addr_type == FETCH_INVALID){ //dont care mode/lock/wr
            rand_pmp_cfg[2] == 'b0;  //x=0
        }
        else if(req_seg_info.addr_type == LOAD_INVALID){ //dont care mode/lock/xr
            rand_pmp_cfg[0] == 'b0;  //r=0
        }
        else if(req_seg_info.addr_type == LS_INVALID){ //dont care mode/lock/xr
            rand_pmp_cfg[1] == 'b0;  //w=0
        }
        else if(req_seg_info.addr_type == AMO_INVALID){ //dont care mode/lock/x
            rand_pmp_cfg[1:0] != 'd3;  //x|w=0
        }

        if(req_seg_info.page_size == SMALL_PAGE && req_seg_info.start_paddr[12] == 0 ||
           req_seg_info.page_size == BIG_PAGE && req_seg_info.start_paddr[21] == 0 ||
           req_seg_info.page_size == HUGE_PAGE && req_seg_info.start_paddr[30] == 0
           ){        rand_pmp_cfg[4:3] inside{1,3};}
        else rand_pmp_cfg[4:3] == 1;

        if(req_seg_info.mode == M_MODE && req_seg_info.addr_type != PTE_VALID && req_seg_info.addr_type != PTE_INVALID) rand_pmp_cfg[7] == 1'b1; //lock & hit make M_MODE Hit, if PTE Acc have no this limit
    }


    function void alloc_reserved_pmp();
        pmp_window_s pmp_info;

        for(int i=0; i<4; i++)begin
            pmp_info.pmp_cfg = rand_reserved_pmp_cfg[i];
            if(rand_reserved_pmp_cfg[i][4:3] == 1/*TOR*/)begin
                //pmp_info.pmp_cfg = rand_reserved_pmp_cfg[i];   
                pmp_window.push_front(pmp_info);
                pmp_info.pmp_cfg = 0;
                pmp_window.push_front(pmp_info);
                //if TOR Mode save twice
                pmp_window_size = pmp_window_size + 2;
            end
            else begin
                pmp_window.push_front(pmp_info);
                pmp_window_size = pmp_window_size + 1;
            end
            //$display("rand reserved pmp cfg[%0d] = %0h, seg_start_addr = %0h",i,rand_reserved_pmp_cfg[i],seg_start_addr[i]);
     end
    endfunction
    function void data_out();
    bit [4:0]   reserved_window_index;
    bit [2:0]   reserved_window_cnt;
    bit[7:0][7:0]   pmp_cfg0;
    bit[7:0][7:0]   pmp_cfg2;
        reserved_window_index = pmp_window_size - (4+ (rand_reserved_pmp_cfg[0][4:3]==1) + (rand_reserved_pmp_cfg[1][4:3]==1) +( rand_reserved_pmp_cfg[2][4:3]==1) +( rand_reserved_pmp_cfg[3][4:3]==1)) ;

        //$display("aaa =%0d",reserved_window_index);
        pmp_cfg0 = 0;
        pmp_cfg2 = 0;
        reserved_window_cnt = 3;
        for(int i=0; i<16; i++)begin
            if(i == reserved_window_index)begin
                if(pmp_window[i].pmp_cfg[4:3] == 1/*TOR*/)begin
                    pmp_window[i-1].addr = seg_start_addr[reserved_window_cnt];
                    pmp_window[i].addr = seg_end_addr[reserved_window_cnt];
                    reserved_window_index = reserved_window_index + 1;
                    //$display("TOR i =%0d,cfg=%0h,end addr=%0h, start_addr = %0h",i,pmp_window[i].pmp_cfg,seg_end_addr[reserved_window_cnt],seg_start_addr[reserved_window_cnt]);
                    //$display("22 rand reserved pmp cfg[%0d] = %0h, seg_start_addr = %0h",reserved_window_cnt,pmp_window[i].pmp_cfg,seg_start_addr[reserved_window_cnt]);
                    reserved_window_cnt = reserved_window_cnt -1;
                end
                else if(pmp_window[i].pmp_cfg[4:3] == 3)begin
                    //$display("NAPOT i =%0d,cfg=%0h,end addr=%0h",i,pmp_window[i].pmp_cfg,seg_end_addr[reserved_window_cnt]);
                    pmp_window[i].addr = seg_start_addr[reserved_window_cnt];
                    pmp_window[i].addr[35:0] = 'hfffffffff;
                    reserved_window_index = reserved_window_index + 1;
                    //$display("22 rand reserved pmp cfg[%0d] = %0h, seg_start_addr = %0h",reserved_window_cnt,pmp_window[i].pmp_cfg,seg_start_addr[reserved_window_cnt]);
                    reserved_window_cnt = reserved_window_cnt -1;
                end
                else reserved_window_index = reserved_window_index + 1;//cfg=0. is tor[i-1]

            end

            pmp_window[i].pmp_window_index = i;
            if(i<8) begin
                pmp_cfg0[i] = pmp_window[i].pmp_cfg;
            end
            else begin
                pmp_cfg2[i-8] = pmp_window[i].pmp_cfg;
            end
        end
        for(int i=0; i<16; i++)begin
            $display("pmp_window[%0d]: %0p",i,pmp_window[i]);
            $fwrite(cfg_file,"%8h\n",'h3b0+i);//window start csr addr
            $fwrite(cfg_file,"%8h\n",pmp_window[i].addr );
        end
        //for(int i=0;i<4;i++)begin
   //$display("seg_end_addr=%0h",seg_end_addr[i]);
        //end
            $fwrite(cfg_file,"%8h\n",'h3a0);//pmp_cfg0
            $fwrite(cfg_file,"%16h\n",pmp_cfg0);
            $fwrite(cfg_file,"%8h\n",'h3a2);//pmp_cfg2;
            $fwrite(cfg_file,"%16h\n",pmp_cfg2);


    endfunction
    function bit alloc_pmp();
        bit almost_overflow;
        pmp_window_s pmp_info;

        pmp_info.addr = req_seg_info.start_paddr;
        pmp_info.pmp_cfg = rand_pmp_cfg;

        if(rand_pmp_cfg[4:3] == 1/*TOR*/)begin
            pmp_info.addr = req_seg_info.start_paddr+req_seg_info.size_in_bytes;
            pmp_window.push_front(pmp_info);
            pmp_info.pmp_cfg = 0;
            pmp_info.addr = req_seg_info.start_paddr;
            pmp_window.push_front(pmp_info);
            //if TOR Mode save twice
            pmp_window_size = pmp_window_size + 2;
        end
        else begin
        //
            if(req_seg_info.page_size == SMALL_PAGE)pmp_info.addr[11:0] = 'h7ff;
            if(req_seg_info.page_size == BIG_PAGE)  pmp_info.addr[20:0] = 'h0fffff ;
            if(req_seg_info.page_size == HUGE_PAGE) pmp_info.addr[29:0] = 'h1fffffff ;
            pmp_window.push_front(pmp_info);
            pmp_window_size = pmp_window_size + 1;
        end
//        $display("req_seg info = %0p", req_seg_info);
//        $display("pmp_alloc info = %0p", pmp_info);

        almost_overflow = pmp_window_size > 14;
        return almost_overflow;
    endfunction


    function void post_randomize();
//        $display("req_seg_info is %0p",req_seg_info);
//        $display("reserved_pmp_cfg[MEMORY][A] = %0d",rand_reserved_pmp_cfg[0][4:3]);
//        $display("reserved_pmp_cfg[IO_IDEM][A] = %0d",rand_reserved_pmp_cfg[1][4:3]);
//        $display("reserved_pmp_cfg[UN_IDEM][A] = %0d",rand_reserved_pmp_cfg[2][4:3]);
    endfunction
endclass : pmp_config_generator
