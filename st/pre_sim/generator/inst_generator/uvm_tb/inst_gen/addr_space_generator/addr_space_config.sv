class addr_space_config extends uvm_object;
    rand bit[39:0] pool_start_paddr[4];

    rand int unsigned page_size_dist[$];
    rand int unsigned pma_type_dist[$];
    bit[3:0] map_mode;
    bit pmp_except_en = 1;

    `uvm_object_utils_begin(addr_space_config)
        `uvm_field_sarray_int(pool_start_paddr, UVM_DEFAULT)
        `uvm_field_sarray_int(page_size_dist, UVM_DEFAULT)
        `uvm_field_sarray_int(pma_type_dist, UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "addr_space_config");
      super.new(name);
    endfunction : new
    
    constraint page_size_dist_c{
        page_size_dist.size() == 3;
        foreach(page_size_dist[i]){
            page_size_dist[i] inside{[0:100]};
        }
        page_size_dist.sum() == 100;
    }
    constraint pma_type_dist_c{
        pma_type_dist.size() == 4;
        foreach(pma_type_dist[i]){
            pma_type_dist[i] inside{[0:100]};
        }
        (pma_type_dist[0] + pma_type_dist[1]) !=0;//for reserved seg
        pma_type_dist.sum() == 100;
    }
    constraint pool_start_paddr_c{
        foreach(pool_start_paddr[i]){
            pool_start_paddr[i][37:0] == 0;
        }

        pool_start_paddr[0][39:38] inside {0,1,2,3};//memory seg pool
        pool_start_paddr[1][39:38] inside {0,1,2,3};//io idem seg pool
        pool_start_paddr[2][39:38] inside {1,2,3};//io unidem seg pool
        pool_start_paddr[3][39:38] inside {1,2,3};//invalid seg pool
        unique{pool_start_paddr};

    }
    

endclass 
