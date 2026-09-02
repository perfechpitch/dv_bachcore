class base_mem #(int MEM_SIZE_KB=4, bit [31:0] BASE_ADDR=32'h0) extends uvm_object;

    localparam int MEM_SIZE_BYTE = MEM_SIZE_KB * 1024;

    bit [7:0] mem_data [0:MEM_SIZE_BYTE-1];

    read_op_check_s read_op_check_queue[$];
    write_op_check_s write_op_check_queue[$];

    integer mem_log;
    bit log_en;

    `uvm_object_param_utils(base_mem #(MEM_SIZE_KB, BASE_ADDR))

    function new(string name="base_mem", bit log_en=1'b0);
        super.new(name);

        this.log_en = log_en;
        mem_log = 0;
    endfunction : new

    function void set_log(integer log_fd);
        mem_log = log_fd;
    endfunction : set_log

    function void open_log(string log_name);
        if(!log_en)
            return;

        if(mem_log != 0)
            $fclose(mem_log);

        mem_log = $fopen(log_name, "w");

        if(mem_log == 0)
            `uvm_error(get_type_name(), $sformatf(
                "Cannot open memory log file: %s", log_name))
    endfunction : open_log

    // Clear memory and operation check queues.
    function void init();
        foreach(mem_data[i])
            mem_data[i] = '0;

        read_op_check_queue.delete();
        write_op_check_queue.delete();
    endfunction : init

    // Initialize one word without operation checking.
    function void init_data(bit [31:0] addr, bit [31:0] data);
        int unsigned offset;

        offset = addr - BASE_ADDR;

        mem_data[offset+0] = data[7:0];
        mem_data[offset+1] = data[15:8];
        mem_data[offset+2] = data[23:16];
        mem_data[offset+3] = data[31:24];
    endfunction : init_data

    local function int unsigned get_byte_num(bit [1:0] size);
        case(size)
            2'd0: return 1;
            2'd1: return 2;
            2'd2: return 4;
            default: begin
                `uvm_error(get_type_name(), $sformatf(
                    "Unsupported memory access size=%0d", size))
                return 0;
            end
        endcase
    endfunction : get_byte_num

    local function bit [3:0] get_write_mask(bit [1:0] size);
        case(size)
            2'd0: return 4'b0001;
            2'd1: return 4'b0011;
            2'd2: return 4'b1111;
            default: return 4'b0000;
        endcase
    endfunction : get_write_mask

    local function void read_op_check(op_source_e source, bit [31:0] addr);
        read_op_check_s current_op;
        read_op_check_s expect_op;

        current_op.source = source;
        current_op.addr = addr;

        if(read_op_check_queue.size() == 0 ||
           read_op_check_queue[0].source == source) begin
            read_op_check_queue.push_back(current_op);
            return;
        end

        expect_op = read_op_check_queue.pop_front();

        if(expect_op.addr != current_op.addr)
            `uvm_error(get_type_name(), $sformatf(
                "Read operation mismatch: REF/DUT addr=0x%08h/0x%08h",
                source == OP_FROM_REF ? current_op.addr : expect_op.addr,
                source == OP_FROM_REF ? expect_op.addr : current_op.addr))
    endfunction : read_op_check

    local function void write_op_check(
        op_source_e source,
        bit [31:0] addr,
        bit [31:0] data,
        bit [3:0] mask
    );
        write_op_check_s current_op;
        write_op_check_s expect_op;

        current_op.source = source;
        current_op.addr = addr;
        current_op.data = data;
        current_op.mask = mask;

        if(write_op_check_queue.size() == 0 ||
           write_op_check_queue[0].source == source) begin
            write_op_check_queue.push_back(current_op);
            return;
        end

        expect_op = write_op_check_queue.pop_front();

        if(expect_op.addr != current_op.addr)
            `uvm_error(get_type_name(), $sformatf(
                "Write address mismatch: REF/DUT addr=0x%08h/0x%08h",
                source == OP_FROM_REF ? current_op.addr : expect_op.addr,
                source == OP_FROM_REF ? expect_op.addr : current_op.addr))

        if(expect_op.mask != current_op.mask)
            `uvm_error(get_type_name(), $sformatf(
                "Write mask mismatch: REF/DUT mask=0x%0h/0x%0h",
                source == OP_FROM_REF ? current_op.mask : expect_op.mask,
                source == OP_FROM_REF ? expect_op.mask : current_op.mask))

        for(int i=0; i<4; i++) begin
            if(expect_op.mask[i] &&
               current_op.mask[i] &&
               expect_op.data[i*8 +: 8] != current_op.data[i*8 +: 8])
                `uvm_error(get_type_name(), $sformatf(
                    "Write data mismatch byte[%0d]: REF/DUT data=0x%02h/0x%02h",
                    i,
                    source == OP_FROM_REF ?
                        current_op.data[i*8 +: 8] :
                        expect_op.data[i*8 +: 8],
                    source == OP_FROM_REF ?
                        expect_op.data[i*8 +: 8] :
                        current_op.data[i*8 +: 8]))
        end
    endfunction : write_op_check

    // REF memory read.
    // op_check_en=0 is used by instruction FETCH.
    function bit [31:0] read_mem(
        bit [1:0] size,
        bit [31:0] addr,
        bit op_check_en=1'b1
    );
        bit [31:0] rdata;
        int unsigned offset;
        int unsigned byte_num;

        rdata = '0;
        offset = addr - BASE_ADDR;
        byte_num = get_byte_num(size);

        if(byte_num == 0)
            return '0;

        for(int i=0; i<byte_num; i++)
            rdata[i*8 +: 8] = mem_data[offset+i];

        if(op_check_en)
            read_op_check(OP_FROM_REF, addr);

        if(log_en && mem_log)
            $fdisplay(mem_log,
                "[MEM][%s]READ  addr=0x%08h size=%0d data=0x%08h",
                get_name(), addr, size, rdata);

        return rdata;
    endfunction : read_mem

    // REF memory write.
    // Store data uses low-bit-valid format.
    function void write_mem(
        bit [1:0] size,
        bit [31:0] addr,
        bit [31:0] data
    );
        int unsigned offset;
        int unsigned byte_num;
        bit [3:0] mask;

        offset = addr - BASE_ADDR;
        byte_num = get_byte_num(size);
        mask = get_write_mask(size);

        if(byte_num == 0)
            return;

        for(int i=0; i<byte_num; i++)
            mem_data[offset+i] = data[i*8 +: 8];

        write_op_check(OP_FROM_REF, addr, data, mask);

        if(log_en && mem_log)
            $fdisplay(mem_log,
                "[MEM][%s]WRITE addr=0x%08h size=%0d data=0x%08h mask=0x%0h",
                get_name(), addr, size, data, mask);
    endfunction : write_mem

    // DUT LOAD operation.
    function void read_check(bit [31:0] addr);
        read_op_check(OP_FROM_DUT, addr);

        if(log_en && mem_log)
            $fdisplay(mem_log,
                "[MEM][%s]DUT_LOAD  addr=0x%08h",
                get_name(), addr);
    endfunction : read_check

    // DUT STORE operation.
    function void write_check(
        bit [31:0] addr,
        bit [31:0] data,
        bit [3:0] mask
    );
        write_op_check(OP_FROM_DUT, addr, data, mask);

        if(log_en && mem_log)
            $fdisplay(mem_log,
                "[MEM][%s]DUT_STORE addr=0x%08h data=0x%08h mask=0x%0h",
                get_name(), addr, data, mask);
    endfunction : write_check

    function bit op_queue_empty();
        return read_op_check_queue.size() == 0 &&
               write_op_check_queue.size() == 0;
    endfunction : op_queue_empty

endclass : base_mem