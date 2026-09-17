//----------------------------------------------------------------------
// data_init_generator
//   Records data required by semantic instruction sequences and writes it to
//   the independent data_init.vmem using the platform's DTCM/Share mapping.
//   First stage supports aligned word initialization for LW-to-Use.
//----------------------------------------------------------------------
class data_init_generator extends uvm_object;
    ls_addr_config    cfg;
    core_context_pool context_pool;
    protected int     data_init_file;
    protected bit[31:0] init_words[bit[31:0]];

    `uvm_object_utils(data_init_generator)

    function new(string name = "data_init_generator");
        super.new(name);
    endfunction

    function void open_file(string file_name = "./data_init.vmem");
        if(data_init_file)
            `uvm_fatal("DATA_INIT", "data init output file is already open")
        data_init_file = $fopen(file_name, "w");
        if(!data_init_file)
            `uvm_fatal("DATA_INIT",
                       $sformatf("cannot open data init output file: %s",
                                 file_name))
    endfunction

    function void close_file();
        if(data_init_file) begin
            $fclose(data_init_file);
            data_init_file = 0;
        end
    endfunction

    function bit[31:0] to_global_addr(ls_addr_s access);
        int unsigned core_index;
        bit[63:0] offset;
        if(cfg == null || context_pool == null)
            `uvm_fatal("DATA_INIT", "data_init_generator is not configured")
        core_index = context_pool.get_active_context().core_index;
        case(access.mem_type)
            LS_MEM_DTCM: begin
                if(access.ea < cfg.dtcm_base[core_index] ||
                   access.ea >= cfg.dtcm_base[core_index] + cfg.dtcm_size[core_index])
                    `uvm_fatal("DATA_INIT",
                               $sformatf("DTCM EA 0x%0h is outside core %0d window",
                                         access.ea, core_index))
                offset = access.ea - cfg.dtcm_base[core_index];
                return cfg.dtcm_global_base[core_index] + offset;
            end
            LS_MEM_SHARE: begin
                // SHARE_RAND_3CORE uses absolute RV addresses.  The software
                // partition layout uses an offset inside the shared image.
                if(cfg.share_layout == SHARE_SW_PARTITION)
                    offset = access.ea;
                else begin
                    if(access.ea < cfg.share_base ||
                       access.ea >= cfg.share_base + cfg.share_size)
                        `uvm_fatal("DATA_INIT",
                                   $sformatf("Share EA 0x%0h is outside configured window",
                                             access.ea))
                    offset = access.ea - cfg.share_base;
                end
                return cfg.share_global_base + offset;
            end
        endcase
    endfunction

    // If a random request reuses an initialized address, preserve the first
    // value so every load from that static image observes a consistent word.
    // A directed fixed-value conflict is an error because both expectations
    // cannot be satisfied by one initial memory image.
    function bit[31:0] init_word(ls_addr_s access,
                                 bit[31:0] requested_data,
                                 bit        fixed_data = 1'b0);
        bit[31:0] global_addr;
        bit[31:0] word_index;
        bit[31:0] resolved_data;
        global_addr = to_global_addr(access);
        if(global_addr[1:0] != 2'b00)
            `uvm_fatal("DATA_INIT",
                       $sformatf("word data init address 0x%08h is not aligned",
                                 global_addr))
        word_index = global_addr >> 2;
        if(init_words.exists(word_index)) begin
            resolved_data = init_words[word_index];
            if(fixed_data && resolved_data != requested_data)
                `uvm_fatal("DATA_INIT",
                           $sformatf("conflicting fixed data at global address 0x%08h: old=0x%08h new=0x%08h",
                                     global_addr, resolved_data, requested_data))
        end
        else begin
            resolved_data = requested_data;
            init_words[word_index] = resolved_data;
            if(!data_init_file)
                `uvm_fatal("DATA_INIT", "data_init.vmem is not open")
            $fwrite(data_init_file, "@%0h\n%08h\n", word_index, resolved_data);
        end
        `uvm_info("DATA_INIT",
                  $sformatf("core=%0d mem=%s ea=0x%08h global=0x%08h data=0x%08h",
                            context_pool.get_active_context().core_index,
                            access.mem_type.name(), access.ea[31:0],
                            global_addr, resolved_data), UVM_LOW)
        return resolved_data;
    endfunction
endclass
