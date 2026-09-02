class dsa_mem_library extends uvm_object;

    core_mem core;
    matrix_mem matrix;
    scale_mem #(CORE_SCALE_MEM_SIZE_KB, CORE_SCALE_MEM_BASE) core_scale;
    scale_mem #(MATRIX_SCALE_MEM_SIZE_KB, MATRIX_SCALE_MEM_BASE) matrix_scale;

    bit log_en;
    int dsa_type;

    `uvm_object_utils(dsa_mem_library)

    function new(string name="dsa_mem_library", bit log_en=1'b0);
        super.new(name);

        this.log_en = log_en;
        core = new("core_mem", log_en);
        matrix = new("matrix_mem", log_en);
        core_scale = new("core_scale_mem", log_en);
        matrix_scale = new("matrix_scale_mem", log_en);
        dsa_type = 0;
    endfunction : new

    function void set_type(int t);
        dsa_type = t;
    endfunction : set_type

    function void set_log(integer log_fd);
        core.set_log(log_fd);
        matrix.set_log(log_fd);
        core_scale.set_log(log_fd);
        matrix_scale.set_log(log_fd);
    endfunction : set_log

    function bit [31:0] core_local_to_global(bit [31:0] local_addr);
        return CORE_MEM_BASE + local_addr;
    endfunction : core_local_to_global

    function bit [31:0] matrix_local_to_global(bit [31:0] local_addr);
        return MATRIX_MEM_BASE + local_addr;
    endfunction : matrix_local_to_global

    function bit [31:0] core_scale_to_global(bit [31:0] core_local_addr);
        return CORE_SCALE_MEM_BASE + (core_local_addr >> 5);
    endfunction : core_scale_to_global

    function bit [31:0] matrix_scale_to_global(bit [31:0] matrix_local_addr);
        return MATRIX_SCALE_MEM_BASE + (matrix_local_addr >> 3);
    endfunction : matrix_scale_to_global

    function bit is_dsa_addr(bit [31:0] addr);
        return in_region(addr, CORE_MEM_REGION) ||
               in_region(addr, CORE_SCALE_MEM_REGION) ||
               in_region(addr, MATRIX_MEM_REGION) ||
               in_region(addr, MATRIX_SCALE_MEM_REGION);
    endfunction : is_dsa_addr

    function void init(string file);
        int fd;
        int ret;
        string line;
        bit [31:0] addr;
        bit [31:0] data;

        fd = $fopen(file, "r");
        if(fd == 0) begin
            `uvm_error(get_type_name(), $sformatf(
                "Cannot open DSA memory init file: %s", file))
            return;
        end

        addr = '0;
        while($fgets(line, fd)) begin
            if($sscanf(line, "@%h", addr) == 1)
                continue;

            ret = $sscanf(line, "%h", data);
            if(ret != 1)
                continue;

            if(in_region(addr, CORE_MEM_REGION))
                core.init_data(addr, data);
            else if(in_region(addr, CORE_SCALE_MEM_REGION))
                core_scale.init_data(addr, data);
            else if(in_region(addr, MATRIX_MEM_REGION))
                matrix.init_data(addr, data);
            else if(in_region(addr, MATRIX_SCALE_MEM_REGION))
                matrix_scale.init_data(addr, data);

            addr += 4;
        end

        $fclose(fd);
    endfunction : init

    function bit [31:0] read_core(bit [1:0] size, bit [31:0] local_addr);
        return core.read_mem(size, core_local_to_global(local_addr), 1'b0);
    endfunction : read_core

    function void write_core(bit [1:0] size, bit [31:0] local_addr, bit [31:0] data);
        core.write_mem(size, core_local_to_global(local_addr), data);
    endfunction : write_core

    function bit [31:0] read_matrix(bit [1:0] size, bit [31:0] local_addr);
        return matrix.read_mem(size, matrix_local_to_global(local_addr), 1'b0);
    endfunction : read_matrix

    function void write_matrix(bit [1:0] size, bit [31:0] local_addr, bit [31:0] data);
        matrix.write_mem(size, matrix_local_to_global(local_addr), data);
    endfunction : write_matrix

    function bit [31:0] read_core_scale(bit [1:0] size, bit [31:0] core_local_addr);
        return core_scale.read_mem(size, core_scale_to_global(core_local_addr), 1'b0);
    endfunction : read_core_scale

    function void write_core_scale(bit [1:0] size, bit [31:0] core_local_addr, bit [31:0] data);
        core_scale.write_mem(size, core_scale_to_global(core_local_addr), data);
    endfunction : write_core_scale

    function bit [31:0] read_matrix_scale(bit [1:0] size, bit [31:0] matrix_local_addr);
        return matrix_scale.read_mem(size, matrix_scale_to_global(matrix_local_addr), 1'b0);
    endfunction : read_matrix_scale

    function void write_matrix_scale(bit [1:0] size, bit [31:0] matrix_local_addr, bit [31:0] data);
        matrix_scale.write_mem(size, matrix_scale_to_global(matrix_local_addr), data);
    endfunction : write_matrix_scale

    function bit [31:0] dte_read(bit [1:0] size, bit [31:0] addr);
        if(in_region(addr, CORE_MEM_REGION))
            return core.read_mem(size, addr, 1'b0);
        if(in_region(addr, CORE_SCALE_MEM_REGION))
            return core_scale.read_mem(size, addr, 1'b0);
        if(in_region(addr, MATRIX_MEM_REGION))
            return matrix.read_mem(size, addr, 1'b0);
        if(in_region(addr, MATRIX_SCALE_MEM_REGION))
            return matrix_scale.read_mem(size, addr, 1'b0);

        `uvm_error(get_type_name(), $sformatf(
            "Illegal DSA memory read address: 0x%08h", addr))
        return '0;
    endfunction : dte_read

    function void dte_write(bit [1:0] size, bit [31:0] addr, bit [31:0] data);
        if(in_region(addr, CORE_MEM_REGION))
            core.write_mem(size, addr, data);
        else if(in_region(addr, CORE_SCALE_MEM_REGION))
            core_scale.write_mem(size, addr, data);
        else if(in_region(addr, MATRIX_MEM_REGION))
            matrix.write_mem(size, addr, data);
        else if(in_region(addr, MATRIX_SCALE_MEM_REGION))
            matrix_scale.write_mem(size, addr, data);
        else
            `uvm_error(get_type_name(), $sformatf(
                "Illegal DSA memory write address: 0x%08h", addr))
    endfunction : dte_write

    // Block APIs preserve VU/MU/DTE architectural transaction widths.
    function void read_core_block(bit [31:0] local_addr, int unsigned byte_num,
                                  ref bit [7:0] data[]);
        core.read_block(core_local_to_global(local_addr), byte_num, data);
    endfunction : read_core_block

    function void write_core_block(bit [31:0] local_addr, bit [7:0] data[]);
        core.write_block(core_local_to_global(local_addr), data);
    endfunction : write_core_block

    function void read_matrix_block(bit [31:0] local_addr, int unsigned byte_num,
                                    ref bit [7:0] data[]);
        matrix.read_block(matrix_local_to_global(local_addr), byte_num, data);
    endfunction : read_matrix_block

    function void write_matrix_block(bit [31:0] local_addr, bit [7:0] data[]);
        matrix.write_block(matrix_local_to_global(local_addr), data);
    endfunction : write_matrix_block

    function void read_core_scale_block(bit [31:0] core_local_addr,
                                        int unsigned byte_num,
                                        ref bit [7:0] data[]);
        core_scale.read_block(core_scale_to_global(core_local_addr), byte_num, data);
    endfunction : read_core_scale_block

    function void write_core_scale_block(bit [31:0] core_local_addr,
                                         bit [7:0] data[]);
        core_scale.write_block(core_scale_to_global(core_local_addr), data);
    endfunction : write_core_scale_block

    function void read_matrix_scale_block(bit [31:0] matrix_local_addr,
                                          int unsigned byte_num,
                                          ref bit [7:0] data[]);
        matrix_scale.read_block(matrix_scale_to_global(matrix_local_addr), byte_num, data);
    endfunction : read_matrix_scale_block

    function void write_matrix_scale_block(bit [31:0] matrix_local_addr,
                                           bit [7:0] data[]);
        matrix_scale.write_block(matrix_scale_to_global(matrix_local_addr), data);
    endfunction : write_matrix_scale_block

    function void dte_read_block(bit [31:0] addr, int unsigned byte_num,
                                 ref bit [7:0] data[]);
        if(in_region(addr, CORE_MEM_REGION))
            core.read_block(addr, byte_num, data);
        else if(in_region(addr, CORE_SCALE_MEM_REGION))
            core_scale.read_block(addr, byte_num, data);
        else if(in_region(addr, MATRIX_MEM_REGION))
            matrix.read_block(addr, byte_num, data);
        else if(in_region(addr, MATRIX_SCALE_MEM_REGION))
            matrix_scale.read_block(addr, byte_num, data);
        else begin
            data = new[0];
            `uvm_error(get_type_name(), $sformatf(
                "Illegal DSA memory block read address: 0x%08h", addr))
        end
    endfunction : dte_read_block

    function void dte_write_block(bit [31:0] addr, bit [7:0] data[]);
        if(in_region(addr, CORE_MEM_REGION))
            core.write_block(addr, data);
        else if(in_region(addr, CORE_SCALE_MEM_REGION))
            core_scale.write_block(addr, data);
        else if(in_region(addr, MATRIX_MEM_REGION))
            matrix.write_block(addr, data);
        else if(in_region(addr, MATRIX_SCALE_MEM_REGION))
            matrix_scale.write_block(addr, data);
        else
            `uvm_error(get_type_name(), $sformatf(
                "Illegal DSA memory block write address: 0x%08h", addr))
    endfunction : dte_write_block

endclass : dsa_mem_library
