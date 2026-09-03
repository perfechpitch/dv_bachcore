class bus_trans extends uvm_sequence_item;
    rand int                addr;
    rand int                data;
    rand bit                is_write; // 1: 写, 0: 读

    `uvm_object_utils_begin(bus_trans)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="bus_trans");
        super.new(name);
    endfunction
endclass

virtual class base_sequence extends uvm_sequence #(bus_trans);
    
    my_block rm_block; // 此时的 my_block 已经是 uvm_component 了，句柄无缝兼容

    function new(string name="base_sequence");
        super.new(name);
    endfunction

    // 升级后的集成读 Task：跑总线波形 + 抓取实际值 + 联动模型获取期望值 + 前门自动比对
    task reg_read(string reg_name, output int rdata);
        int addr;
        int exp_data; // 新增局部变量，用于存放账本预测的期望值
        bus_trans req;

        rdata = 0;

        // 在发送总线事务前完成寄存器名称与访问权限检查
        if (rm_block == null) begin
            `uvm_error("RM_BLOCK_NULL", "rm_block handle is null, cannot resolve register name.")
            return;
        end
        if (!rm_block.name_map.exists(reg_name)) begin
            `uvm_error("REG_NAME_NOT_FOUND", $sformatf("Register '%s' does not exist in this block!", reg_name))
            return;
        end
        if (rm_block.predict_read_exception(reg_name)) begin
            `uvm_error("REG_READ_NOT_ALLOWED", $sformatf("Register '%s' does not allow read access.", reg_name))
            return;
        end

        addr = rm_block.name_map[reg_name];
        req = bus_trans::type_id::create("req");
        req.addr     = addr;
        req.is_write = 0; // 读操作
        
        // 1. 发送跑腿包给 Driver，消耗时间等待硬件总线返回
        start_item(req);
        finish_item(req);
        
        // 2. 将硬件实际读回的值赋给输出参数
        rdata = req.data;
        
        // 3. 联动寄存器模型
        // 关键修正：read_reg 现在只传地址。它会返回当前期望值，并自动在后台处理读清零(RC)等软件副作用
        exp_data = rm_block.read_reg(addr);

        // 4. 在 Sequence 内部直接完成【前门总线数据】的自动比对
        if (rdata !== exp_data) begin
            `uvm_error("BUS_READ_MISMATCH", $sformatf("=== FRONTDOOR MISMATCH ===\nRegister: %s\nAddress: 'h%0h\n[Bus Actual Data]: 'h%0h\n[Model Exp Data ]: 'h%0h", reg_name, addr, rdata, exp_data))
        end else begin
            `uvm_info("BUS_READ_PASS", $sformatf("Frontdoor Read Pass. Reg: %s | Addr: 'h%0h | Data: 'h%0h", reg_name, addr, rdata), UVM_HIGH)
        end
    endtask

    // 集成写 Task
    task reg_write(string reg_name, int wdata);
        int addr;
        bus_trans req;

        // 在发送总线事务前完成寄存器名称与访问权限检查
        if (rm_block == null) begin
            `uvm_error("RM_BLOCK_NULL", "rm_block handle is null, cannot resolve register name.")
            return;
        end
        if (!rm_block.name_map.exists(reg_name)) begin
            `uvm_error("REG_NAME_NOT_FOUND", $sformatf("Register '%s' does not exist in this block!", reg_name))
            return;
        end
        if (rm_block.predict_write_exception(reg_name)) begin
            `uvm_error("REG_WRITE_NOT_ALLOWED", $sformatf("Register '%s' does not allow write access.", reg_name))
            return;
        end

        addr = rm_block.name_map[reg_name];
        req = bus_trans::type_id::create("req");
        req.addr     = addr;
        req.data     = wdata;
        req.is_write = 1; // 写操作
        
        // 1. 发送写事务，让 Driver 翻转硬件总线
        start_item(req);
        finish_item(req);
        
        // 2. 硬件写完后，同步更新软件模型中的镜像值
        rm_block.write_reg(addr, wdata);
    endtask
endclass
