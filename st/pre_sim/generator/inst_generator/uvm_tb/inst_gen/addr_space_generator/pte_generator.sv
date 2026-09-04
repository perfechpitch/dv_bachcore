//TODO: support pbmt en. override pma
class pte_generator extends uvm_object;

    addr_type_e         req_addr_type;
    page_size_e         req_page_size;
    mode_e              req_mode;
    addr_space_config   addr_space_cfg;
    rand pte_type_e     rand_pte_type;
    rand pte_except_e   rand_pte_except;
    rand addr_type_e    rand_pte_addr_type[3];
    bit [8:0] disabled_vpn2_q [$];
    rand bit [8:0] rand_vpn2;
    rand bit[1:0]   rand_pbmt[3];
    rand bit[2:0]   rand_pte_d;
    rand bit[2:0]   rand_pte_w;
    rand bit[2:0]   rand_pte_a;
    rand bit[2:0]   rand_pte_g;
    rand bit[2:0]   rand_pte_u;
    rand bit[2:0]   rand_pte_x;
    rand bit[2:0]   rand_pte_r;
    rand bit[2:0]   rand_pte_v;
    rand bit        va_high_bits_all_zero;


    page_1G_pte_info_s  page_1G_pte_info_q[$];
    page_2M_pte_info_s  page_2M_pte_info_q[$];
    page_4K_pte_info_s  page_4K_pte_info_q[$];
    bit [1:0]           pte_level;
    bit [39:0]          pte_addr[3];
    bit [39:0]          pte_base_addr;
    bit                 mstatus_sum;

    bit[2:0] pte_alloc;
    bit[2:0] pte_addr_alloc;
    // like 4K page can have over 512 index
    int page_1G_index_id;
    int page_2M_index_id;
    int page_4K_index_id;

    bit link_reserved_seg_alloc_flag;
    `uvm_object_utils_begin(pte_generator)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "pte_generator");
        super.new(name);
        link_reserved_seg_alloc_flag = 0;
        disabled_vpn2_q.push_back(2);
    endfunction : new

    constraint page_1G_index_id_c{
        if(req_addr_type == RESERVED && !link_reserved_seg_alloc_flag){rand_vpn2 == 0;}
        else{
            !(rand_vpn2 inside{disabled_vpn2_q});
        }
    }
 constraint pte_type_c{
        if(req_addr_type == FETCH_VALID || req_addr_type == LOAD_VALID ||
           req_addr_type == LS_VALID    || req_addr_type == AMO_VALID || req_addr_type == RESERVED) {
            if(req_page_size == HUGE_PAGE)      {rand_pte_type == VALID_1G_LEAF_PAGE;}
            else if(req_page_size == BIG_PAGE)  {rand_pte_type == VALID_2M_LEAF_PAGE;}
            else if(req_page_size == SMALL_PAGE){rand_pte_type == VALID_4K_LEAF_PAGE;}
        }
        else if(req_page_size == HUGE_PAGE) {rand_pte_type == INVALID_1G_LEAF_PAGE;}
        else if(req_page_size == BIG_PAGE)  {rand_pte_type inside{INVALID_1G_ROOT_PAGE, INVALID_2M_LEAF_PAGE};}
        else if(req_page_size == SMALL_PAGE){rand_pte_type inside{INVALID_1G_ROOT_PAGE,INVALID_2M_ROOT_PAGE,INVALID_4K_LEAF_PAGE};}
    }


    constraint pte_except_c{
        if(req_page_size != SMALL_PAGE)     {!(rand_pte_except inside{MISS_LEAF_PTE});}
        if(req_addr_type == FETCH_INVALID)  {!(rand_pte_except inside{LEAF_PTE_R_INVALID,LEAF_PTE_DW_INVALID});}
        if(req_addr_type == LOAD_INVALID)   {!(rand_pte_except inside{LEAF_PTE_X_INVALID,LEAF_PTE_DW_INVALID});}
        if(req_addr_type == LS_INVALID)     {!(rand_pte_except inside{LEAF_PTE_X_INVALID,LEAF_PTE_R_INVALID});}
        if(req_addr_type == AMO_INVALID)    {!(rand_pte_except inside{LEAF_PTE_X_INVALID});}

        if(rand_pte_type == INVALID_1G_ROOT_PAGE || rand_pte_type == INVALID_2M_ROOT_PAGE) {
            rand_pte_except inside {PTE_ADDR_PMA_ACCESS_FAULT,PTE_ADDR_PMP_ACCESS_FAULT,
                                    PTE_INVALID_PAGE_FAULT,
                                    ROOT_PTE_PBMT_NONE_ZERO,
                                    MISALIGNED_SUPERPAGE
                                    };
        }
        else if(rand_pte_type == INVALID_1G_LEAF_PAGE || rand_pte_type == INVALID_2M_LEAF_PAGE || rand_pte_type == INVALID_4K_LEAF_PAGE){
            rand_pte_except inside{PTE_ADDR_PMA_ACCESS_FAULT,PTE_ADDR_PMP_ACCESS_FAULT,
                                   PTE_INVALID_PAGE_FAULT,
                                   LEAF_PTE_A_INVALID,
                                   LEAF_PTE_U_MISMATCH,
                                   LEAF_PTE_PBMT_3,
                                   LEAF_PTE_X_INVALID, LEAF_PTE_R_INVALID, LEAF_PTE_DW_INVALID,
                                   MISS_LEAF_PTE//4k page only
            };
        }
        else rand_pte_except == NONE_PTE_EXCEPT;
        if(!addr_space_cfg.pmp_except_en) rand_pte_except != PTE_ADDR_PMP_ACCESS_FAULT;

    }
    constraint pte_addr_type_c{
        // level 2
        if((rand_pte_type == INVALID_1G_ROOT_PAGE || rand_pte_type == INVALID_1G_LEAF_PAGE) &&
           (rand_pte_except == PTE_ADDR_PMA_ACCESS_FAULT || rand_pte_except == PTE_ADDR_PMP_ACCESS_FAULT)){
            rand_pte_addr_type[2] == PTE_INVALID;
        }
        else {rand_pte_addr_type[2] == PTE_VALID;}

        // level 1
        if((rand_pte_type == INVALID_2M_ROOT_PAGE || rand_pte_type == INVALID_2M_LEAF_PAGE) &&
           (rand_pte_except == PTE_ADDR_PMA_ACCESS_FAULT || rand_pte_except == PTE_ADDR_PMP_ACCESS_FAULT)){
            rand_pte_addr_type[1] == PTE_INVALID;
        }
        else {rand_pte_addr_type[1] == PTE_VALID;}

        // level 0
        if((                                         rand_pte_type == INVALID_4K_LEAF_PAGE) &&
           (rand_pte_except == PTE_ADDR_PMA_ACCESS_FAULT || rand_pte_except == PTE_ADDR_PMP_ACCESS_FAULT)){
            rand_pte_addr_type[0] == PTE_INVALID;
        }
        else {rand_pte_addr_type[0] == PTE_VALID;}
    }
    /////////////////////////////////////////////////////////
constraint pte_lv2_c{
        if(rand_pte_type != INVALID_1G_ROOT_PAGE && rand_pte_type != INVALID_1G_LEAF_PAGE){
            if(rand_pte_type == VALID_1G_LEAF_PAGE){
                rand_pbmt[2] inside{0,1};   // NONE override/IO_IDEM
                rand_pte_v[2] == 1;
                rand_pte_a[2] == 1;
                if(req_addr_type == LS_VALID || req_addr_type == LS_INVALID || req_addr_type == AMO_VALID || req_addr_type == AMO_INVALID || req_addr_type == RESERVED){
                    rand_pte_d[2] == 1;
                    rand_pte_w[2] == 1;
                    rand_pte_r[2] == 1;
                    if(link_reserved_seg_alloc_flag){rand_pte_x[2] == 1;}
                }
                else if(req_addr_type == LOAD_VALID || req_addr_type == LOAD_INVALID){
                    rand_pte_r[2] == 1;
                }
                else if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID){
                    rand_pte_x[2] == 1;
                    {rand_pte_w[2], rand_pte_r[2]} != 2'b10;
                }
                if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID || req_addr_type == RESERVED && link_reserved_seg_alloc_flag/*S_EXCEPT_HANDLE*/){
                    if(req_mode == U_MODE               ){rand_pte_u[2]== 1;}
                    else{rand_pte_u[2] ==0;}
                }
                else{
                    if(req_mode == U_MODE || mstatus_sum){rand_pte_u[2]== 1;}
                    else{rand_pte_u[2] ==0;}
                }
            }
            else {
                rand_pte_v[2] == 1;
                rand_pbmt[2] == 0;
                (rand_pte_w[2] | rand_pte_r[2] | rand_pte_x[2]) == 0;
            }//valid 1G root
        }
        else if(rand_pte_type == INVALID_1G_ROOT_PAGE ){
            if(rand_pte_except == ROOT_PTE_PBMT_NONE_ZERO) {rand_pbmt[2] inside{1,2,3};}
            else if(rand_pte_except == PTE_INVALID_PAGE_FAULT){rand_pte_v[2] == 0 || rand_pte_r[2] == 0 && rand_pte_w[2] == 1;}
        }
        else if(rand_pte_type == INVALID_1G_LEAF_PAGE){
            if(rand_pte_except == LEAF_PTE_PBMT_3) {rand_pbmt[2] == 3;}
            else if(rand_pte_except == PTE_INVALID_PAGE_FAULT){rand_pte_v[2] == 0 || rand_pte_r[2] == 0 && rand_pte_w[2] == 1;}
            else if(rand_pte_except == LEAF_PTE_U_MISMATCH){
                if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID){
                    if(req_mode == U_MODE               ) {rand_pte_u[2] == 0;}
                    else {rand_pte_u[2] == 1;}
                }
                else {
                    if(req_mode == U_MODE || mstatus_sum) {rand_pte_u[2] == 0;}
                    else {rand_pte_u[2] == 1;}
                }
            }
            else if(rand_pte_except == LEAF_PTE_A_INVALID) {rand_pte_a[2] == 0;}
            else if(rand_pte_except == LEAF_PTE_R_INVALID) {rand_pte_r[2] == 0;}
            else if(rand_pte_except == LEAF_PTE_DW_INVALID){rand_pte_d[2] == 0 || rand_pte_w[2] == 0;}
            else if(rand_pte_except == LEAF_PTE_X_INVALID) {rand_pte_x[2] == 0;}
        }
    }
    /////////////////////////////////////////////////////////
 constraint pte_lv1_c{
        if(rand_pte_type != INVALID_2M_ROOT_PAGE && rand_pte_type != INVALID_2M_LEAF_PAGE){
            if(rand_pte_type == VALID_2M_LEAF_PAGE){
                rand_pbmt[1] inside{0,1};   // NONE override/IO_IDEM
                rand_pte_v[1] == 1;
                rand_pte_a[1] == 1;
                if(req_addr_type == LS_VALID || req_addr_type == LS_INVALID || req_addr_type == AMO_VALID || req_addr_type == AMO_INVALID || req_addr_type == RESERVED){
                    rand_pte_d[1] == 1;
                    rand_pte_w[1] == 1;
                    rand_pte_r[1] == 1;
                    if(link_reserved_seg_alloc_flag){rand_pte_x[1] == 1;}
                }
                else if(req_addr_type == LOAD_VALID || req_addr_type == LOAD_INVALID){
                    rand_pte_r[1] == 1;
                }
                else if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID){
                    rand_pte_x[1] == 1;
                    {rand_pte_w[1], rand_pte_r[1]} != 2'b10;
                }
                if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID || req_addr_type == RESERVED && link_reserved_seg_alloc_flag){
                    if(req_mode == U_MODE               ){rand_pte_u[1]== 1;}
                    else{rand_pte_u[1] ==0;}
                }
                else{
                    if(req_mode == U_MODE || mstatus_sum){rand_pte_u[1]== 1;}
                    else{rand_pte_u[1] ==0;}
                }
            }
            else {
                rand_pte_v[1] == 1;
                rand_pbmt[1] == 0;
                (rand_pte_w[1] | rand_pte_r[1] | rand_pte_x[1]) == 0;
            }//valid 2M root
        }
        else if(rand_pte_type == INVALID_2M_ROOT_PAGE ){
            if(rand_pte_except == ROOT_PTE_PBMT_NONE_ZERO) {rand_pbmt[1] inside{1,2,3};}
            else if(rand_pte_except == PTE_INVALID_PAGE_FAULT){rand_pte_v[1] == 0 || rand_pte_r[1] == 0 && rand_pte_w[1] == 1;}
        }
        else if(rand_pte_type == INVALID_2M_LEAF_PAGE){
            if(rand_pte_except == LEAF_PTE_PBMT_3) {rand_pbmt[1] == 3;}
            else if(rand_pte_except == PTE_INVALID_PAGE_FAULT){rand_pte_v[1] == 0 || rand_pte_r[1] == 0 && rand_pte_w[1] == 1;}
            else if(rand_pte_except == LEAF_PTE_U_MISMATCH){
                if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID){
                    if(req_mode == U_MODE               ) {rand_pte_u[1] == 0;}
                    else {rand_pte_u[1] == 1;}
                }
                else {
                    if(req_mode == U_MODE || mstatus_sum) {rand_pte_u[1] == 0;}
                    else {rand_pte_u[1] == 1;}
                }
            }
            else if(rand_pte_except == LEAF_PTE_A_INVALID) {rand_pte_a[1] == 0;}
            else if(rand_pte_except == LEAF_PTE_R_INVALID) {rand_pte_r[1] == 0;}
            else if(rand_pte_except == LEAF_PTE_DW_INVALID){rand_pte_d[1] == 0 || rand_pte_w[1] == 0;}
            else if(rand_pte_except == LEAF_PTE_X_INVALID) {rand_pte_x[1] == 0;}
        }
    }
    /////////////////////////////////////////////////////////
  constraint pte_lv0_c{
        if(rand_pte_type == VALID_4K_LEAF_PAGE){
            rand_pbmt[0] inside{0,1};   // NONE override/IO_IDEM
            rand_pte_v[0] == 1;
            rand_pte_a[0] == 1;
            if(req_addr_type == LS_VALID || req_addr_type == LS_INVALID || req_addr_type == AMO_VALID || req_addr_type == AMO_INVALID || req_addr_type == RESERVED){
                rand_pte_d[0] == 1;
                rand_pte_w[0] == 1;
                rand_pte_r[0] == 1;
                if(link_reserved_seg_alloc_flag){rand_pte_x[0] == 1;}
            }
            else if(req_addr_type == LOAD_VALID || req_addr_type == LOAD_INVALID){
                rand_pte_r[0] == 1;
            }
            else if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID){
                rand_pte_x[0] == 1;
                {rand_pte_w[0], rand_pte_r[0]} != 2'b10;
            }
            if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID || req_addr_type == RESERVED && link_reserved_seg_alloc_flag){
                if(req_mode == U_MODE               ){rand_pte_u[0]== 1;}
                else{rand_pte_u[0] ==0;}
            }
            else{
                if(req_mode == U_MODE || mstatus_sum){rand_pte_u[0]== 1;}
                else{rand_pte_u[0] ==0;}
            }
        }
        else if(rand_pte_type == INVALID_4K_LEAF_PAGE){
            if(rand_pte_except == LEAF_PTE_PBMT_3) {rand_pbmt[0] == 3;}
            else if(rand_pte_except == PTE_INVALID_PAGE_FAULT){rand_pte_v[0] == 0 || rand_pte_r[0] == 0 && rand_pte_w[0] == 1;}
            else if(rand_pte_except == LEAF_PTE_U_MISMATCH){
                if(req_addr_type == FETCH_VALID || req_addr_type == FETCH_INVALID){
                    if(req_mode == U_MODE               ) {rand_pte_u[0] == 0;}
                    else {rand_pte_u[0] == 1;}
                }
                else {
                    if(req_mode == U_MODE || mstatus_sum) {rand_pte_u[0] == 0;}
                    else {rand_pte_u[0] == 1;}
                }
            }
            else if(rand_pte_except == LEAF_PTE_A_INVALID) {rand_pte_a[0] == 0;}
            else if(rand_pte_except == LEAF_PTE_R_INVALID) {rand_pte_r[0] == 0;}
            else if(rand_pte_except == LEAF_PTE_DW_INVALID){rand_pte_d[0] == 0 || rand_pte_w[0] == 0;}
            else if(rand_pte_except == LEAF_PTE_X_INVALID) {rand_pte_x[0] == 0;}
        }
    }

               function bit[63:0] get_vaddr(bit[39:0] paddr,int addr_space_log);
        bit[63:0] vaddr;
        bit[63:0] pte[3];

        $fwrite(addr_space_log,"\t- pte type = %0s, pte_except = %0s \n",rand_pte_type,rand_pte_except);
        //pte 1G
        if(pte_alloc[2])  begin
            if(!pte_addr_alloc[2])
                pte_addr[2] = pte_base_addr + page_1G_pte_info_q[page_1G_index_id].vpn2*8;
            if(pte_level < 2) pte[2] = {1'b0,rand_pbmt[2],23'b0,pte_addr[1][39:12],2'b0,
                rand_pte_d[2],rand_pte_a[2],rand_pte_g[2],rand_pte_u[2],rand_pte_x[2],rand_pte_w[2],rand_pte_r[2],rand_pte_v[2]};
            else pte[2] = {1'b0,rand_pbmt[2],5'b0,paddr[39:30],20'b0,
                rand_pte_d[2],rand_pte_a[2],rand_pte_g[2],rand_pte_u[2],rand_pte_x[2],rand_pte_w[2],rand_pte_r[2],rand_pte_v[2]};

            page_1G_pte_info_q[page_1G_index_id].pte_addr = pte_addr[2];
            page_1G_pte_info_q[page_1G_index_id].pte = pte[2];
            $fwrite(addr_space_log,"\t- 1G pte alloc : %0p\t\n",page_1G_pte_info_q[page_1G_index_id]);
        end
        else begin
            pte_addr[2] = page_1G_pte_info_q[page_1G_index_id].pte_addr;
            pte[2] = page_1G_pte_info_q[page_1G_index_id].pte;
            $fwrite(addr_space_log,"\t- 1G pte Hit : %0p\t\n",page_1G_pte_info_q[page_1G_index_id]);
        end

        if(pte_alloc[1]) begin
            if(!pte_addr_alloc[1])
                pte_addr[1] = page_1G_pte_info_q[page_1G_index_id].pte[54:10] * pagesize + page_2M_pte_info_q[page_2M_index_id].vpn1*8;
            else pte_addr[1] = pte_addr[1] + page_2M_pte_info_q[page_2M_index_id].vpn1*8;
            if(pte_level < 1) pte[1] = {1'b0,rand_pbmt[1],23'b0,pte_addr[0][39:12],2'b0,
                rand_pte_d[1],rand_pte_a[1],rand_pte_g[1],rand_pte_u[1],rand_pte_x[1],rand_pte_w[1],rand_pte_r[1],rand_pte_v[1]};
            else pte[1] = {1'b0,rand_pbmt[1],14'b0,paddr[39:21],11'b0,
                rand_pte_d[1],rand_pte_a[1],rand_pte_g[1],rand_pte_u[1],rand_pte_x[1],rand_pte_w[1],rand_pte_r[1],rand_pte_v[1]};
            page_2M_pte_info_q[page_2M_index_id].pte_addr = pte_addr[1];
            page_2M_pte_info_q[page_2M_index_id].pte = pte[1];
            $fwrite(addr_space_log,"\t- 2M pte alloc : %0p\t\n",page_2M_pte_info_q[page_2M_index_id]);
        end
        else if(pte_level < 2)begin
            pte_addr[1] = page_2M_pte_info_q[page_2M_index_id].pte_addr;
            pte[1] = page_2M_pte_info_q[page_2M_index_id].pte;
            $fwrite(addr_space_log,"\t- 2M pte Hit : %0p\t\n",page_2M_pte_info_q[page_2M_index_id]);
        end

        if(pte_alloc[0]) begin
            if(!pte_addr_alloc[0])
                pte_addr[0] = page_2M_pte_info_q[page_2M_index_id].pte[54:10] * pagesize + page_4K_pte_info_q[page_4K_index_id].vpn0 * 8;
            else
                pte_addr[0] = pte_addr[0] + page_4K_pte_info_q[page_4K_index_id].vpn0 * 8;
            pte[0] = {1'b0,rand_pbmt[0],23'b0,paddr[39:12],2'b0,
            rand_pte_d[0],rand_pte_a[0],rand_pte_g[0],rand_pte_u[0],rand_pte_x[0],rand_pte_w[0],rand_pte_r[0],rand_pte_v[0]};
            page_4K_pte_info_q[page_4K_index_id].pte_addr = pte_addr[0];
            page_4K_pte_info_q[page_4K_index_id].pte = pte[0];
            $fwrite(addr_space_log,"\t- 4K pte alloc : %0p\t\n",page_4K_pte_info_q[page_4K_index_id]);
        end
 if(rand_pte_type == VALID_1G_LEAF_PAGE || rand_pte_type == INVALID_1G_ROOT_PAGE || rand_pte_type == INVALID_1G_LEAF_PAGE)begin
            vaddr = {page_1G_pte_info_q[page_1G_index_id].vpn2,paddr[29:0]};
            page_1G_pte_info_q[page_1G_index_id].vaddr = {vaddr[63:30],30'b0};
            page_1G_pte_info_q[page_1G_index_id].paddr = {paddr[39:30],30'b0};
        end
        else if(rand_pte_type == VALID_2M_LEAF_PAGE || rand_pte_type == INVALID_2M_ROOT_PAGE || rand_pte_type == INVALID_2M_LEAF_PAGE)begin
            vaddr = {page_1G_pte_info_q[page_1G_index_id].vpn2,page_2M_pte_info_q[page_2M_index_id].vpn1,paddr[20:0]};
            page_2M_pte_info_q[page_2M_index_id].vaddr = {vaddr[63:21],21'b0};
            page_2M_pte_info_q[page_2M_index_id].paddr = {paddr[39:21],21'b0};
        end
        else begin//if(rand_pte_type == VALID_4K_LEAF_PAGE)
            vaddr = {page_1G_pte_info_q[page_1G_index_id].vpn2,page_4K_pte_info_q[page_4K_index_id].vpn1,page_4K_pte_info_q[page_4K_index_id].vpn0,paddr[11:0]};
            page_4K_pte_info_q[page_4K_index_id].vaddr = {vaddr[63:12],12'b0};
            page_4K_pte_info_q[page_4K_index_id].paddr = {paddr[39:12],12'b0};
        end

        if(vaddr[38]) vaddr[63:39] = 'h1ffffff;

        for(int i=3-pte_level;i>0;i--)begin
            $fwrite(addr_space_log,"\t- pte lv%0d addr\t:%h; pte = %0h\n",3-i,pte_addr[3-i], pte[3-i]);
        end
        $fwrite(addr_space_log,"\t- page info: pa[%0h] -> va[%0h]\t\n",paddr,vaddr);
        return vaddr;
    endfunction
  function bit [2:0] get_pte_attr(int addr_space_log);

        int find_index_q[$];
        int rand_index_id;
        bit[8:0] vpn2,vpn1,vpn0;

        pte_alloc = 0;
        pte_addr_alloc = 0;
        page_1G_index_id = 0;
        page_2M_index_id = 0;
        page_4K_index_id = 0;
        ///////////////////////////////////////////////////// 
            //$fwrite(addr_space_log,"- rand pte addr_type [2] = %0s",rand_pte_addr_type[2]);
            //$fwrite(addr_space_log,"- rand pte addr_type [1] = %0s",rand_pte_addr_type[1]);
            //$fwrite(addr_space_log,"- rand pte addr_type [0] = %0s",rand_pte_addr_type[0]);
        //TODO: INVALID LEAF, INVALID ROOT
        if(rand_pte_type == VALID_1G_LEAF_PAGE || rand_pte_type == INVALID_1G_LEAF_PAGE)begin    //alloc a 1G leaf info
            page_1G_index_id = alloc_1G_pte(rand_pte_type);
            pte_alloc[2] = 1;
        end
        else if(rand_pte_type == INVALID_1G_ROOT_PAGE)begin
            find_index_q = page_1G_pte_info_q.find_index with(item.pte_type == rand_pte_type && item.pte_except == rand_pte_except);
            if(find_index_q.size() !=0)begin
                page_1G_index_id = $urandom_range(find_index_q.size()-1);
                page_1G_index_id = find_index_q[page_1G_index_id];
            end
            else begin  //alloc 1G page 
                page_1G_index_id = alloc_1G_pte(rand_pte_type);
                pte_alloc[2] = 1;
            end
        end
        else begin  // look up a valid 1G root info
            find_index_q = page_1G_pte_info_q.find_index with(item.pte_type == VALID_1G_ROOT_PAGE && item.next_level_cnt !=0 &&
                                                             ((item.pte_except == rand_pte_except) ||
                                                             (item.pte_except !== PTE_ADDR_PMA_ACCESS_FAULT && item.pte_except !== PTE_ADDR_PMP_ACCESS_FAULT &&
                                                              rand_pte_except !== PTE_ADDR_PMA_ACCESS_FAULT && rand_pte_except !== PTE_ADDR_PMP_ACCESS_FAULT
                                                             ))
                                                             );
                                                             //(item.pte_type == rand_pte_type && item.pte_except == rand_pte_except));
            if(find_index_q.size() !=0)begin
                page_1G_index_id = $urandom_range(find_index_q.size()-1);
                page_1G_index_id = find_index_q[page_1G_index_id];
            end
            else begin  //alloc 1G root page 
                page_1G_index_id = alloc_1G_pte(VALID_1G_ROOT_PAGE);
                pte_alloc[2] = 1;
                $fwrite(addr_space_log,"\t- debug :1G pte vpn2 = %0h, vpn1 = %0h, vpn0 = %0h \n",vpn2,vpn1,vpn0);
                $fwrite(addr_space_log,"\t- debug :%0d, 1G pte %0p \n",page_1G_index_id,page_1G_pte_info_q[page_1G_index_id]);
            end
            vpn2 = page_1G_pte_info_q[page_1G_index_id].vpn2;
            ///////////////////////////////////////////////////// 
            if(req_addr_type == RESERVED && !link_reserved_seg_alloc_flag) vpn1 =0;
            else vpn1  = 512 - (page_1G_pte_info_q[page_1G_index_id].next_level_cnt-1);
            if(rand_pte_type == VALID_2M_LEAF_PAGE || rand_pte_type == INVALID_2M_LEAF_PAGE)begin    //alloc a valid 2M leaf info
                page_2M_index_id = alloc_2M_pte(rand_pte_type,vpn2,vpn1);
                page_1G_pte_info_q[page_1G_index_id].next_level_cnt = page_1G_pte_info_q[page_1G_index_id].next_level_cnt - 1;
                pte_alloc[1] = 1;
            end
 else if(rand_pte_type == INVALID_2M_ROOT_PAGE)begin
                find_index_q = page_2M_pte_info_q.find_index with(item.pte_type ==  rand_pte_type && item.pte_except == rand_pte_except);
                if(find_index_q.size() !=0)begin
                    page_2M_index_id = $urandom_range(find_index_q.size()-1);
                    page_2M_index_id = find_index_q[page_2M_index_id];
                    vpn1  = page_2M_pte_info_q[page_2M_index_id].vpn1;// if hit .no alloc 2M
                end
                else begin  //alloc 2M invalid page 
                    pte_alloc[1] = 1;
                    page_2M_index_id = alloc_2M_pte(rand_pte_type,vpn2,vpn1);
                    page_1G_pte_info_q[page_1G_index_id].next_level_cnt = page_1G_pte_info_q[page_1G_index_id].next_level_cnt - 1;
                end
            end
            else begin  // look up a valid 2M root info
                find_index_q = page_2M_pte_info_q.find_index with(item.pte_type == VALID_2M_ROOT_PAGE && item.next_level_cnt !=0);
                if(find_index_q.size() !=0)begin
                    page_2M_index_id = $urandom_range(find_index_q.size()-1);
                    page_2M_index_id = find_index_q[page_2M_index_id];
                    vpn1  = page_2M_pte_info_q[page_2M_index_id].vpn1;// if hit .no alloc 2M
                end
                else begin  //alloc 2M root page 
                    pte_alloc[1] = 1;
                    page_2M_index_id = alloc_2M_pte(VALID_2M_ROOT_PAGE,vpn2,vpn1);
                    page_1G_pte_info_q[page_1G_index_id].next_level_cnt = page_1G_pte_info_q[page_1G_index_id].next_level_cnt - 1;
                end
                ///////////////////////////////////////////////////// 
                if(req_addr_type == RESERVED && !link_reserved_seg_alloc_flag) vpn0 = 0;
                else
                vpn0  = 512-(page_2M_pte_info_q[page_2M_index_id].next_level_cnt-1);
                pte_alloc[0] = 1;
                page_4K_index_id = alloc_4K_pte(addr_space_log,rand_pte_type,vpn2,vpn1,vpn0);
                page_2M_pte_info_q[page_2M_index_id].next_level_cnt = page_2M_pte_info_q[page_2M_index_id].next_level_cnt - 1;
            end
        end
        pte_addr_alloc[1] = pte_alloc[1] && pte_alloc[2];
        pte_addr_alloc[0] = pte_alloc[0] && pte_alloc[1];
                $fwrite(addr_space_log,"\t- debug :pte_addr_alloc = %0h \n",pte_addr_alloc);
        return pte_addr_alloc;
    endfunction

  function void post_randomize();
        case(rand_pte_type)
            VALID_1G_ROOT_PAGE, INVALID_1G_ROOT_PAGE,
            VALID_1G_LEAF_PAGE, INVALID_1G_LEAF_PAGE    : pte_level = 2;
            VALID_2M_ROOT_PAGE, INVALID_2M_ROOT_PAGE,
            VALID_2M_LEAF_PAGE, INVALID_2M_LEAF_PAGE    : pte_level = 1;
            VALID_4K_LEAF_PAGE, INVALID_4K_LEAF_PAGE    : pte_level = 0;
        endcase
    endfunction

    function int alloc_1G_pte(pte_type_e pte_type);
        page_1G_pte_info_s  page_1G_pte_info;
        int q_size;
        q_size = page_1G_pte_info_q.size();
        page_1G_pte_info.pte_type = pte_type;
        case(pte_type)
            VALID_1G_LEAF_PAGE  :  begin
                page_1G_pte_info.addr_type = req_addr_type;
                page_1G_pte_info.pte_except = NONE_PTE_EXCEPT;
                page_1G_pte_info.next_level_cnt = 0;  //there are 0 2M page in next level
            end
            INVALID_1G_LEAF_PAGE ,INVALID_1G_ROOT_PAGE :  begin
                page_1G_pte_info.addr_type = req_addr_type;
                page_1G_pte_info.pte_except = rand_pte_except;
                page_1G_pte_info.next_level_cnt = 0;  //there are 0 2M page in next level
            end
            VALID_1G_ROOT_PAGE  :  begin
                page_1G_pte_info.pte_except = NONE_PTE_EXCEPT;
                page_1G_pte_info.next_level_cnt = 512;  //there are 512 2M page in next level
                if(rand_pte_except == PTE_ADDR_PMA_ACCESS_FAULT || rand_pte_except == PTE_ADDR_PMP_ACCESS_FAULT) page_1G_pte_info.pte_except = rand_pte_except;
            end
            //default:error
        endcase
        page_1G_pte_info.vpn2 = rand_vpn2;
        //$display("pte_base_addr = %0h, pte_addr[2] = %0h,rand_vpn2*8=%0h",pte_base_addr,pte_addr[2],rand_vpn2*8);
        //page_1G_pte_info.pte_addr = pte_addr[2];
        page_1G_pte_info_q.push_back(page_1G_pte_info);
        disabled_vpn2_q.push_back(rand_vpn2);

        return q_size;
    endfunction

  function int alloc_2M_pte(pte_type_e pte_type,bit[8:0] vpn2,bit[8:0]vpn1);
        page_2M_pte_info_s  page_2M_pte_info;
        int   q_size;
        q_size = page_2M_pte_info_q.size();
        page_2M_pte_info.pte_type = pte_type;
        case(pte_type)
            VALID_2M_LEAF_PAGE  :  begin
                page_2M_pte_info.addr_type = req_addr_type;
                page_2M_pte_info.pte_except = NONE_PTE_EXCEPT;
                page_2M_pte_info.next_level_cnt = 0;  //there are 0 2M page in next level
            end
            INVALID_2M_LEAF_PAGE,INVALID_2M_ROOT_PAGE  :  begin
                page_2M_pte_info.addr_type = req_addr_type;
                page_2M_pte_info.pte_except = rand_pte_except;
                page_2M_pte_info.next_level_cnt = 0;  //there are 0 2M page in next level
            end
            VALID_2M_ROOT_PAGE  :  begin
                page_2M_pte_info.pte_except = NONE_PTE_EXCEPT;
                page_2M_pte_info.next_level_cnt = 512;  //there are 512 2M page in next level
            end
        endcase
        page_2M_pte_info.vpn2 = vpn2;
        page_2M_pte_info.vpn1 = vpn1;
        page_2M_pte_info_q.push_back(page_2M_pte_info);

        return q_size;
    endfunction
    function int alloc_4K_pte(int addr_space_log,pte_type_e pte_type,bit [8:0] vpn2, bit[8:0] vpn1,bit[8:0]vpn0);
        page_4K_pte_info_s  page_4K_pte_info;
        int q_size;

        q_size = page_4K_pte_info_q.size();
        page_4K_pte_info.addr_type = req_addr_type;
        page_4K_pte_info.pte_type = pte_type;
        page_4K_pte_info.pte_except = rand_pte_except;
        page_4K_pte_info.vpn0 = vpn0;
        page_4K_pte_info.vpn1 = vpn1;
        page_4K_pte_info.vpn2 = vpn2;
        if(vpn2 == 'h1c9)
        $fwrite(addr_space_log,"\t-%0d 11 debug :4K pte %0p \n",q_size,page_4K_pte_info);

        page_4K_pte_info_q.push_back(page_4K_pte_info);
        return q_size;
    endfunction

    function void data_out(int file);
        foreach(page_1G_pte_info_q[i])begin
            $fwrite(file,"@%0h\n",page_1G_pte_info_q[i].pte_addr >> 2);
            $fwrite(file,"%8h\n",page_1G_pte_info_q[i].pte[31:0]);
            $fwrite(file,"%8h\n",page_1G_pte_info_q[i].pte[63:32]);
            if(page_1G_pte_info_q[i].pte_addr == 0)begin
            $display("ERROR: 1G pte[%0d]: %0p",i,page_1G_pte_info_q[i]);
            $finish();
            end
        end
        foreach(page_2M_pte_info_q[i])begin
            $fwrite(file,"@%0h\n",page_2M_pte_info_q[i].pte_addr>> 2);
            $fwrite(file,"%8h\n",page_2M_pte_info_q[i].pte[31:0]);
            $fwrite(file,"%8h\n",page_2M_pte_info_q[i].pte[63:32]);
            if(page_2M_pte_info_q[i].pte_addr == 0)begin
            $display("ERROR: 2M pte: %0p",page_2M_pte_info_q[i]);
            $finish();
            end
        end
        foreach(page_4K_pte_info_q[i])begin
            $fwrite(file,"@%0h\n",page_4K_pte_info_q[i].pte_addr>> 2);
            $fwrite(file,"%8h\n",page_4K_pte_info_q[i].pte[31:0]);
            $fwrite(file,"%8h\n",page_4K_pte_info_q[i].pte[63:32]);
            if(page_4K_pte_info_q[i].pte_addr == 0)begin
            $display("ERROR: 4K pte: %0p",page_4K_pte_info_q[i]);
            $finish();
            end
        end
    endfunction
    function bit       get_paddr(bit[63:0] vaddr);
        bit hit;
        bit[39:0] paddr;
        hit = 0;
        foreach(page_1G_pte_info_q[i])begin
            if(page_1G_pte_info_q[i].next_level_cnt == 0 && page_1G_pte_info_q[i].vaddr[63:30] == vaddr[63:30])begin
//            $display("vaddr = %0h,pte_info_vaddr=%0h",vaddr[63:30],page_1G_pte_info_q[i].vaddr[63:30]);
                paddr = page_1G_pte_info_q[i].paddr + vaddr[29:0];
                hit = 1;
                break;
            end
        end
        if(hit == 0)begin
            foreach(page_2M_pte_info_q[i])begin
                if(page_2M_pte_info_q[i].next_level_cnt == 0 && page_2M_pte_info_q[i].vaddr[63:21] == vaddr[63:21])begin
                    paddr = page_2M_pte_info_q[i].paddr + vaddr[20:0];
                    hit = 1;
                    break;
                end
            end
        end
        if(hit == 0)begin
            foreach(page_4K_pte_info_q[i])begin
                if(page_4K_pte_info_q[i].vaddr[63:12] == vaddr[63:12])begin
                    paddr = page_4K_pte_info_q[i].paddr + vaddr[11:0];
                    hit = 1;
                    break;
                end
            end
        end
//        if(hit==0)begin
//            $display("ERROR: get paddr fail!!:va= %0h",vaddr);
//            $finish();
//        end
        return hit;
    endfunction
endclass : pte_generator



                                                              
