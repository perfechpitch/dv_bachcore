class pma_config_generator extends uvm_object;

    bit [39:0]      seg_start_addr[4];
    bit [39:0]      seg_end_addr[4];
    rand bit        seg_pma_window_overlap[4];
    rand bit unsigned [6:0]   seg_pma_window_num[4];
    rand bit[39:0]  rand_seg_start_addr[$];
    rand bit[39:0]  rand_seg_end_addr[$];
    rand bit[2:0]   rand_seg_pma_attr[$];
    rand bit[3:0]   rand_window_index[$];
    
    pma_window_s pma_window[pma_window_num];

    int cfg_file;


    `uvm_object_utils_begin(pma_config_generator)
        `uvm_field_sarray_int(seg_start_addr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(seg_end_addr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(seg_pma_window_overlap,UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(seg_pma_window_num,UVM_DEFAULT|UVM_DEC)
        `uvm_field_sarray_int(rand_seg_start_addr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(rand_seg_end_addr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(rand_seg_pma_attr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_sarray_int(rand_window_index,UVM_DEFAULT|UVM_HEX)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "pma_config_generator");
        super.new(name);
        cfg_file = $fopen(($psprintf("./pma_cfg.dat")),"w");
    endfunction : new

    constraint pma_window_c{
        seg_pma_window_num.sum() <= pma_window_num;
        foreach(seg_pma_window_num[i]){
            seg_pma_window_num[i] inside{[1:pma_window_num]};
            if(seg_pma_window_overlap[i]) {seg_pma_window_num[i] > 1;}
        }
        rand_seg_pma_attr.size()  == seg_pma_window_num.sum();
        rand_seg_start_addr.size()== seg_pma_window_num.sum();
        rand_seg_end_addr.size()  == seg_pma_window_num.sum();
        rand_window_index.size()  == seg_pma_window_num.sum();

        unique{rand_window_index};
        foreach(rand_window_index[i]){
            rand_window_index[i] inside{[0:pma_window_num-1]};
        }
    }
   constraint pma_attr_c{
        foreach(rand_seg_pma_attr[i]){
            if(i< seg_pma_window_num[memory_seg_index]){
                rand_seg_pma_attr[i] == 'b111;
                if(i == 0){
                    rand_seg_start_addr[i] == seg_start_addr[memory_seg_index];
                    rand_seg_end_addr[i] == seg_end_addr[memory_seg_index];
                }
                else {
                    rand_seg_start_addr[i] >= seg_start_addr[memory_seg_index];
                    rand_seg_start_addr[i] <= seg_end_addr[memory_seg_index];
                    rand_seg_end_addr[i] >= seg_start_addr[memory_seg_index];
                    rand_seg_end_addr[i] <= seg_end_addr[memory_seg_index];
                }
            }
            else if(i< seg_pma_window_num[memory_seg_index] + seg_pma_window_num[io_idem_seg_index]){
                if(i == seg_pma_window_num[memory_seg_index]){
                    rand_seg_pma_attr[i] == 'b101;
                    rand_seg_start_addr[i] == seg_start_addr[io_idem_seg_index];
                    rand_seg_end_addr[i] == seg_end_addr[io_idem_seg_index];
                }
                else{
                    rand_seg_pma_attr[i] inside{'b101, 'b111};
                    rand_seg_start_addr[i] >= seg_start_addr[io_idem_seg_index];
                    rand_seg_start_addr[i] <= seg_end_addr[io_idem_seg_index];
                    rand_seg_end_addr[i] >= seg_start_addr[io_idem_seg_index];
                    rand_seg_end_addr[i] <= seg_end_addr[io_idem_seg_index];
                }
            }
            else if(i< seg_pma_window_num[memory_seg_index] + seg_pma_window_num[io_idem_seg_index]+seg_pma_window_num[io_unidem_seg_index]){
                if(i == seg_pma_window_num[memory_seg_index]+ seg_pma_window_num[io_idem_seg_index]){
                    rand_seg_pma_attr[i] == 'b001;
                    rand_seg_start_addr[i] == seg_start_addr[io_unidem_seg_index];
                    rand_seg_end_addr[i] == seg_end_addr[io_unidem_seg_index];
                }
                else{
                    rand_seg_pma_attr[i] inside{'b001,'b011,'b101,'b111};
                    rand_seg_start_addr[i] >= seg_start_addr[io_unidem_seg_index];
                    rand_seg_start_addr[i] <= seg_end_addr[io_unidem_seg_index];
                    rand_seg_end_addr[i] >= seg_start_addr[io_unidem_seg_index];
                    rand_seg_end_addr[i] <= seg_end_addr[io_unidem_seg_index];
                }
            }
            //else if(i> seg_pma_window_num[memory_seg_index] + seg_pma_window_num[io_idem_seg_index]+seg_pma_window_num[io_unidem_seg_index]){
            else{
               if(i == seg_pma_window_num[memory_seg_index]+ seg_pma_window_num[io_idem_seg_index]+seg_pma_window_num[io_unidem_seg_index]){
                    rand_seg_pma_attr[i] == 'b000;
                    rand_seg_start_addr[i] == seg_start_addr[invalid_seg_index];
                    rand_seg_end_addr[i] == seg_end_addr[invalid_seg_index];
                }
                else{
                    rand_seg_pma_attr[i] inside{['d0:'d7]};
                    rand_seg_start_addr[i] >= seg_start_addr[invalid_seg_index];
                    rand_seg_start_addr[i] <= seg_end_addr[invalid_seg_index];
                    rand_seg_end_addr[i] >= seg_start_addr[invalid_seg_index];
                    rand_seg_end_addr[i] <= seg_end_addr[invalid_seg_index];
                }
            }
        }
    }

    function void pre_randomize();
        //for(int i=0; i<4; i++)begin
        //    $display("seg index = %0h, start addr = %0h ,end_addr = %0h",i,seg_start_addr[i],seg_end_addr[i]);
        //end
    endfunction
    function void post_randomize();
        //$display("sum is %0d",pma_window_num);
        //for(int i=0; i<4; i++)begin
        //    $display("seg pma window num[%0d] = %0h",i,seg_pma_window_num[i]);
        //end
for(int i=0; i<seg_pma_window_num.sum();i++)begin
            pma_window[i].start_addr        = rand_seg_start_addr[i];
            pma_window[i].end_addr          = rand_seg_end_addr[i];
            pma_window[i].pma_window_index  = rand_window_index[i];
            pma_window[i].pma_attr          = rand_seg_pma_attr[i];
            $display("pma_window[%0d]: %0p",i,pma_window[i]);
            $fwrite(cfg_file,"%8h\n",'hbc0+rand_window_index[i]*4);//window start csr addr
            $fwrite(cfg_file,"%8h\n",pma_window[i].start_addr);
            $fwrite(cfg_file,"%8h\n",pma_window[i].end_addr);
            $fwrite(cfg_file,"%8h\n",pma_window[i].pma_attr);
        end
    endfunction

endclass : pma_config_generator

