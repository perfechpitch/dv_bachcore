`ifndef REG_BLOCKS_SVH
`define REG_BLOCKS_SVH

// 定义操作记录结构体
typedef struct {
    string          reg_name;
    int             addr;
    string          op_type; // "WRITE" 或 "READ"
    bit [31:0]      data;
    time            op_time;
} reg_history_s;

// define link struct
typedef struct {
    int             field_idx;
    string          trigger_fname;
    string          link_fname;
    int             trigger_data;
    int             link_data;
} link_info_s;

// 字段属性枚举
typedef enum int {
    REG_RO,
    REG_ROE,
    REG_WO,
    REG_RW,
    REG_W1C,
    REG_W1S,
    REG_WC,
    REG_WS,
    REG_RC,
    REG_RS,
    REG_WOC,
    REG_WOS,
    REG_WRC,   // Write, Read Clear
    REG_WRS,   // Write, Read Set
    REG_WSRC,  // Write Set, Read Clear
    REG_WCRS,  // Write Clear, Read Set
    REG_W1T,   // Write 1 to Toggle
    REG_W0C,   // Write 0 to Clear
    REG_W0S,   // Write 0 to Set
    REG_W0T    // Write 0 to Toggle
} field_attr_e;

typedef struct {
    int           reg_id; 
    int           field_idx;
    field_attr_e  attr;
} field_info_s;

class my_block extends uvm_component;
    `uvm_component_utils(my_block)
    
    my_reg          regs[$];
    int             map[int];
    int             name_map[string];
    int             size_q[$];
    field_info_s    field_map[string];
    
    reg_history_s   history[$];

    function new(string name = "my_block", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void add_size_q(int size);
        size_q.push_back(size);
    endfunction

    function bit get_size_exception(int size);
        if (size_q.size() == 0) begin
            return 0;
        end else begin
            foreach (size_q[i]) begin
                if (size_q[i] == size) begin
                    return 1;
                end
            end
            return 0;
        end
    endfunction

    function void create_reg(string name, int addr, int data, string hdl_path=""); 
        int id = regs.size();

        map[addr]      = id;
        name_map[name] = addr;
        regs.push_back(new(name)); 
    
        regs[id].addr         = addr;
        regs[id].name         = name;
        regs[id].rst_data     = data;
        regs[id].rst_reg();
        
        if (hdl_path != "") begin
            regs[id].hdl_path = hdl_path;
        end
    endfunction

    function void create_field(int addr, string name, int start_bit, int end_bit, field_attr_e field_attr);
        if (map.exists(addr)) begin
            int id = map[addr];
            int current_num = regs[id].field.size(); 
            regs[id].add_field(current_num, name, start_bit, end_bit, field_attr);
            begin
                field_info_s info;
                info.reg_id    = id; 
                info.field_idx = current_num;
                info.attr      = field_attr;
                field_map[name] = info; 
            end
        end else begin
            `uvm_error("ADD_FIELD_ADDR_ERR", $sformatf("Register address ['h%0h] does not exist for field '%s'!", addr, name))
        end
    endfunction

    function void add_link_field(string name, string link_name, int trigger_data, int link_data); 
        link_info_s info;
        if (!field_map.exists(name)) begin
            `uvm_error("ADD_LINK_TRIGGER_ERR", $sformatf("Trigger field '%s' does not exist!", name))
            return;
        end
        if (!field_map.exists(link_name)) begin
            `uvm_error("ADD_LINK_TARGET_ERR", $sformatf("Link field '%s' does not exist!", link_name))
            return;
        end
        int reg_id         = field_map[name].reg_id;
        int field_idx      = field_map[name].field_idx;
        info.field_idx     = field_idx;
        info.trigger_fname = name;
        info.link_fname    = link_name;
        info.trigger_data  = trigger_data;
        info.link_data     = link_data;
        regs[reg_id].link_field.push_back(info);
    endfunction
    
    function void write_link_field(int addr, int wdata);
        int id = map[addr];
        int trigger_data;
        foreach (regs[id].link_field[j]) begin
            int field_idx = regs[id].link_field[j].field_idx;
            trigger_data = regs[id].field[field_idx].get_field_data(wdata);
            if(regs[id].link_field[j].trigger_data == trigger_data) begin
                hw_write_field(regs[id].link_field[j].link_fname,regs[id].link_field[j].link_data);
            end
        end
    endfunction

    function void rst_reg();
        for(int i=0; i<regs.size(); i++) begin
            if(regs.exists(i)) begin
                regs[i].rst_reg();
            end else begin
                //`uvm_error("",$sformatf("\nreg[%0p] is null",addr_e));
                `uvm_error("RST_ID_NOT_FOUND", $sformatf("Register ID [%0d] is missing in dense array!", i))
            end
        end
    endfunction
    
    // 软件读 读整个reg
    function int read_reg(int addr);
        int rdata = 0;
        if (map.exists(addr)) begin
            int id = map[addr];
            rdata = regs[id].read_reg(); 
            record_history(regs[id].get_name(), addr, "READ_REG", rdata);
        end else begin
            `uvm_error("READ_ADDR_NOT_MAPPED", $sformatf("Address ['h%0h] is not mapped in this block!", addr))
        end
        return rdata;
    endfunction

    // 软件写 写整个reg
    function void write_reg(int addr, int data);
        if (map.exists(addr)) begin
            int id = map[addr];
            regs[id].write_reg(data);
            if (regs[id].link_field.size() > 0) begin
                write_link_field(addr, data);
            end
            record_history(regs[id].get_name(), addr, "WRITE_REG", data);
        end else begin
            `uvm_error("WRITE_ADDR_NOT_MAPPED", $sformatf("Address ['h%0h] is not mapped for write!", addr))
        end
    endfunction


    // 硬件更新是物理信号驱动，强制覆盖触发器，不进行属性校验
    // 硬件读 整个reg
    function int hw_read_reg(string name);
        if (!name_map.exists(name)) begin
            `uvm_error("HW_READ_REG_ERR", $sformatf("Register '%s' not mapped!", name))
            return 0;
        end
        return regs[map[name_map[name]]].hw_read(-1); // 传-1代表整字采样
    endfunction

    // 硬件读 指定域段 
    function int hw_read_field(string fname);
        if (field_map.exists(fname)) begin
            int id  = field_map[fname].reg_id; 
            int idx = field_map[fname].field_idx; 
            return regs[id].hw_read(idx);  // 干净的 O(1) 调用
        end else begin
            `uvm_error("HW_READ_FIELD_NOT_FOUND", $sformatf("Field '%s' not mapped!", fname))
            return 0;
        end
    endfunction

    // 硬件写整个reg
    function void hw_write_reg(string name, int data);
        if (!name_map.exists(name)) begin
            `uvm_error("HW_WRITE_REG_ERR", $sformatf("Register '%s' not mapped!", name))
            return;
        end
        // 物理信号驱动，直接覆盖底层 data 触发器
        regs[map[name_map[name]]].data = data;
    endfunction

    // 硬件写 指定域段 
    function void hw_write_field(string fname, int data);
        if (field_map.exists(fname)) begin
            int id  = field_map[fname].reg_id; 
            int idx = field_map[fname].field_idx; 
            regs[id].hw_write(idx, data);
        end else begin
            `uvm_error("HW_WRITE_FIELD_NOT_FOUND", $sformatf("Field '%s' not mapped!", fname))
        end
    endfunction

    //后门读
    function int backdoor_read_reg(string name);
        int rdata = 0;
        if (!name_map.exists(name)) begin
            `uvm_error("BD_READ_REG_NOT_FOUND", $sformatf("Register '%s' not mapped for backdoor read!", name))
            return 0;
        end
        int addr = name_map[name];
        int id = map[addr];
        rdata = regs[id].backdoor_read();
        record_history(regs[id].get_name(), addr, "BACKDOOR_READ", rdata);
        return rdata;
    endfunction
    
    //后门写
    function void backdoor_write_reg(string name, int data);
        if (!name_map.exists(name)) begin
            `uvm_error("BD_WRITE_REG_NOT_FOUND", $sformatf("Register '%s' not mapped for backdoor write!", name))
            return;
        end
        int addr = name_map[name];
        int id = map[addr];
        regs[id].backdoor_write(data);
        record_history(regs[id].get_name(), addr, "BACKDOOR_WRITE", data);
    endfunction
    

    // 异常前序判定  总线读写寄存器前调用（判断是否异常，异常则不进行读写）
    // ==========================================================
    // 读异常前序判定
    // ==========================================================
    function bit predict_read_exception(string name);
        if (!name_map.exists(name)) begin
            `uvm_error("READ_EXCEPTION_REG_NOT_FOUND", $sformatf("Register '%s' does not exist in this block!", name))
            return 1;
        end
        return regs[map[name_map[name]]].gen_read_exception();
    endfunction

    // ==========================================================
    // 写异常前序判定
    // ==========================================================
    function bit predict_write_exception(string name);
        if (!name_map.exists(name)) begin
            `uvm_error("WRITE_EXCEPTION_REG_NOT_FOUND", $sformatf("Register '%s' does not exist in this block!", name))
            return 1;
        end
        return regs[map[name_map[name]]].gen_write_exception();
    endfunction

    // ==========================================================
    // 比较单个reg，后门读取 RTL 真实值与模型镜像比对
    // ==========================================================
    function compare_reg(string name);
        if (!name_map.exists(name)) begin
            `uvm_error("COMP_REG_NOT_FOUND", $sformatf("Register '%s' not mapped for backdoor compare!", name))
            return;
        end
        regs[map[name_map[name]]].compare_data();
    endfunction
    
    //比较整个reg_block
    function bit compare_reg_block();
        bit all_match = 1;
        string failed_regs[$]; 
        
        `uvm_info("COMPARE_START", "==================================================", UVM_LOW)
        `uvm_info("COMPARE_START", "      STARTING GLOBAL REGISTER COMPARE      ", UVM_LOW)
        `uvm_info("COMPARE_START", "==================================================", UVM_LOW)
        
        foreach (regs[idx]) begin
            if (!regs[idx].compare_data()) begin
                all_match = 0;
                failed_regs.push_back(regs[idx].get_name());
            end
        end
        
        if (all_match) begin
            `uvm_info("COMPARE_PASS", ">>> GLOBAL BACKDOOR AUDIT RESULT: [ SUCCESS ] <<<", UVM_LOW)
        end else begin
            `uvm_error("COMPARE_FAIL", ">>> GLOBAL BACKDOOR AUDIT RESULT: [ FAILED ]  <<<")
            foreach(failed_regs[i]) begin
                `uvm_error("COMPARE_SUMMARY", $sformatf("Found Mismatch in Register: %s", failed_regs[i]))
            end
        end
        `uvm_info("COMPARE_END", "==================================================", UVM_LOW)
        return all_match;
    endfunction
    
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        // 整个测试激励发完、仿真即将挂起前的 check_phase，自动触发！
        void'(this.compare_reg_block());
    endfunction

    // 内部记录函数 
    function void record_history(string name, int addr, string op, int data);  
        reg_history_s item;
        item.reg_name = name;
        item.addr     = addr;
        item.op_type  = op;
        item.data     = data;
        item.op_time  = $time;
        history.push_back(item);
    endfunction

    // 最终的打印函数 顶层report_phase调用
    function void report_reg_stats();
        string s; 
        
        // 打印开头先回车 (\n)
        s = "\n==========================================================\n";
        s = {s, "            REGISTER ACCESS HISTORY REPORT                \n"};
        s = {s, "==========================================================\n"};
        s = {s, $sformatf("%-10s | %-28s | %-8s | %-15s | %-8s\n", "TIME", "REG_NAME", "ADDR", "TYPE", "DATA")};
        s = {s, "----------------------------------------------------------\n"};
        
        foreach (history[i]) begin
            s = {s, $sformatf("%-10t | %-28s | %-8h | %-15s | %-8h\n", 
                history[i].op_time, history[i].reg_name, history[i].addr, history[i].op_type, history[i].data)};
        end
        s = {s, "=========================================================="};

        `uvm_info("REG_HISTORY", s, UVM_LOW)
    endfunction

endclass

class my_reg extends uvm_component;
    `uvm_component_utils(my_reg)

    string                      name;
    int                         addr;
    int                         rst_data;
    int                         data;  
    string hdl_path; 
    
    my_field                    field[$];
    link_info_s                 link_field[$];
 
    function new(string name = "my_reg", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function rst_reg();
        data = rst_data;
    endfunction
    
    function add_field(int num,string name,int start_bit,int end_bit,field_attr_e field_attr);
        field[num] = new();
        field[num].add_field(name,start_bit,end_bit,field_attr);
    endfunction

    // 软件读：读整个寄存器
    function int read_reg();
        int rdata = 0;
        int field_val = 0;

        foreach (field[j]) begin
            field_val = 0;

            case(field[j].attr)
                REG_RO, REG_ROE, REG_RW, REG_RS, REG_RC, REG_WS, REG_WC, REG_W1C, REG_W1S,
                REG_WRC, REG_WRS, REG_WSRC, REG_WCRS, REG_W1T, REG_W0C, REG_W0S, REG_W0T: begin
                    field_val = (data >> field[j].start_bit) & ((1 << field[j].width) - 1);
                    rdata |= (field_val << field[j].start_bit);
                    if (field[j].attr inside {REG_RC, REG_WRC, REG_WSRC}) begin
                        data &= ~(((1 << field[j].width) - 1) << field[j].start_bit);
                    end
                    else if (field[j].attr inside {REG_RS, REG_WRS, REG_WCRS}) begin
                        data |= (((1 << field[j].width) - 1) << field[j].start_bit);
                    end
                end
                REG_WO, REG_WOC, REG_WOS: begin
                    `uvm_error("READ_FAILED", $sformatf("Register %s: Field %s is %s (Non-readable).", get_name(), field[j].field_name, field[j].attr.name()))
                    field_val = 0;
                end
                default: begin
                    field_val = 0;
                    rdata |= (field_val << field[j].start_bit);
                end
            endcase
        end

        return rdata;
    endfunction

    //软件写
    function void write_reg(int wdata);
        foreach (field[j]) begin
            for (int i = field[j].start_bit; i <= field[j].end_bit; i++) begin
                bit bit_to_write = wdata[i]; // 直接从整字 wdata 中取第 i 位

                case (field[j].attr)
                    REG_ROE: begin
                        `uvm_error("WRITE_FAILED", $sformatf("Register %s: Field %s is %s .", get_name(), field[j].field_name, field[j].attr.name()))
                    end
                    REG_WO, REG_RW, REG_WRS, REG_WRC: begin
                        data[i] = bit_to_write;
                    end
                    REG_WC, REG_WOC, REG_WCRS: begin
                        data[i] = 0; // 写入即清零
                    end
                    REG_WS, REG_WOS, REG_WSRC: begin
                        data[i] = 1; // 写入即置 1
                    end
                    REG_W0C: begin
                        if (bit_to_write == 0) data[i] = 0;
                    end
                    REG_W0S: begin
                        if (bit_to_write == 0) data[i] = 1;
                    end
                    REG_W0T: begin
                        if (bit_to_write == 0) data[i] = ~data[i];
                    end
                    REG_W1C: begin
                        if (bit_to_write == 1) data[i] = 0;
                    end
                    REG_W1S: begin
                        if (bit_to_write == 1) data[i] = 1;
                    end
                    REG_W1T: begin
                        if (bit_to_write == 1) data[i] = ~data[i];
                    end
                    REG_RO, REG_RC, REG_RS: ; // 写忽略，只读属性
                    default: ;
                endcase
            end
        end
    endfunction

    //读异常行为
    function bit gen_read_exception();
        foreach (field[j]) begin
            case (field[j].attr)
                REG_WO, REG_WOC, REG_WOS: begin
                    return 1; 
                end
                default: ; // 其他属性（RW, RO, RCLR 等）皆可安全读取
            endcase
        end
        return 0; 
    endfunction

    //写异常行为
    function bit gen_write_exception();
        foreach (field[j]) begin
            case (field[j].attr)
                REG_ROE: begin
                    return 1; 
                end
                default: ; // 其他属性（RO(写不报异常), RW, WO, W1C, WOC 等）皆允许总线写注入
            endcase
        end
        return 0; 
    endfunction

    // 硬件写
    function void hw_write(int idx, int hw_field_data);
        if (idx >= 0 && idx < field.size()) begin
            `uvm_info("HW_FIELD_UPDATE", $sformatf("Register %s: Hardware forcing Field %s (idx:%0d) to 'h%0h", 
                      get_name(), field[idx].field_name, idx, hw_field_data), UVM_HIGH)
            
            for (int i = field[idx].start_bit; i <= field[idx].end_bit; i++) begin
                data[i] = hw_field_data[i - field[idx].start_bit]; 
            end
        end else begin
            `uvm_error("HW_IDX_ERR", $sformatf("Register %s: Invalid Field index %0d!", get_name(), idx))
        end
    endfunction

    // 硬件读
    function int hw_read(int idx = -1);
        if (idx == -1) begin
            `uvm_info("HW_GLOBAL_READ", $sformatf("Register %s: Hardware sampled global value 'h%0h", get_name(), this.data), UVM_HIGH)
            return this.data;
        end       
        if (idx >= 0 && idx < field.size()) begin
            int width = field[idx].width;
            int hw_field_data = (this.data >> field[idx].start_bit) & ((1 << width) - 1);
            `uvm_info("HW_FIELD_READ", $sformatf("Register %s: Hardware sampled Field %s (idx:%0d) = 'h%0h", 
                      get_name(), field[idx].field_name, idx, hw_field_data), UVM_HIGH)
            return hw_field_data;
        end else begin
            `uvm_error("HW_IDX_ERR", $sformatf("Register %s: Invalid Field index %0d!", get_name(), idx))
            return 0;
        end
    endfunction

    // 后门写功能
    function void backdoor_write(int wdata);
        if (hdl_path == "") begin
            `uvm_error("BD_WRITE_NO_PATH", $sformatf("Register %s has no HDL path configured!", get_name()))
            return;
        end
        // 使用 UVM 内置的后门赋值函数（利用 DPI 改变 RTL 信号值）
        if (!uvm_hdl_deposit(hdl_path, wdata)) begin    //VCS 编译时需要加上：-debug_access+all 或 -timescale=1ns/1ps -apply_protect 等权限开启参数。 Xcelium 编译时需要加上：-access +rwc。
            `uvm_error("BD_WRITE_FAILED", $sformatf("Backdoor write to %s failed! Path: %s", get_name(), hdl_path))
        end else begin
            `uvm_info("BD_WRITE", $sformatf("Backdoor WRITE to %s | Path: %s | Data: 'h%0h", get_name(), hdl_path, wdata), UVM_HIGH)
            this.data = wdata; 
        end
     endfunction

    // 后门读功能
    function int backdoor_read();
        int rdata;        
        if (hdl_path == "") begin
            `uvm_error("BD_READ_NO_PATH", $sformatf("Register %s has no HDL path configured!", get_name()))
            return 0;
        end
        if (!uvm_hdl_read(hdl_path, rdata)) begin
            `uvm_error("BD_READ_FAILED", $sformatf("Backdoor read from %s failed! Path: %s", get_name(), hdl_path))
            return 0;
        end else begin
            `uvm_info("BD_READ", $sformatf("Backdoor READ from %s | Path: %s | Data: 'h%0h", get_name(), hdl_path, rdata), UVM_HIGH)
            this.data = rdata; 
            return rdata;
        end
    endfunction

    // ==========================================================
    // 核心函数：后门数据 vs 模型镜像 自动比对
    // ==========================================================
    function bit compare_data();
        int dut_rtl_data;
        bit is_match = 1;

        if (this.hdl_path == "") begin
            `uvm_error("BD_COMP_NO_PATH", $sformatf("Register %s has no HDL path configured!", get_name()))
            return 0;
        end

        if (!uvm_hdl_read(this.hdl_path, dut_rtl_data)) begin
            `uvm_error("BD_COMP_READ_FAIL", $sformatf("Backdoor read failed from RTL for %s! Path: %s", get_name(), this.hdl_path))
            return 0;
        end

        if (dut_rtl_data !== this.data) begin
            is_match = 0;
            `uvm_error("BD_COMP_MISMATCH", $sformatf(
                "=== BACKDOOR MISMATCH DETECTED ===\nRegister          : %s (Addr: 'h%0h)\n[DUT RTL Physical]: 'h%0h\n[Model Mirror Exp]: 'h%0h", 
                get_name(), this.addr, dut_rtl_data, this.data
            ))

            foreach (field[j]) begin
                int width = field[j].end_bit - field[j].start_bit + 1;
                int mask  = (1 << width) - 1;
                // 按位域提取
                int f_dut  = (dut_rtl_data >> field[j].start_bit) & mask;
                int f_mod  = (this.data     >> field[j].start_bit) & mask;
                
                if (f_dut !== f_mod) begin
                    `uvm_info("BD_COMP_DETAIL", $sformatf(
                        "  -> Field Mismatch! Name: %-15s [%0d:%0d] | RTL Physical: 'h%0h | Model Mirror: 'h%0h", 
                        field[j].field_name, field[j].end_bit, field[j].start_bit, f_dut, f_mod
                    ), UVM_LOW)
                end
            end
        end else begin
            `uvm_info("BD_COMP_PASS", $sformatf("Backdoor Check Passed for %s (Addr: 'h%0h). Value: 'h%0h", get_name(), this.addr, dut_rtl_data), UVM_HIGH)
        end

        return is_match;
    endfunction
    // function string convert2string();
    //     return $sformatf(
    //         "REG_ITEM op=%s addr=0x%08h wdata=0x%08h rdata=0x%08h field=%s [%0d:%0d] attr=%s",
    //         op.name(), addr, wdata, rdata, field_name, start_bit, end_bit, field_attr.name()
    //     );
    // endfunction
endclass

class my_field extends uvm_component;
    `uvm_component_utils(my_field)
    
    // --------------------------
    // 寄存器字段信息（你要的字段描述）
    // --------------------------
    string          field_name;
    int             start_bit;
    int             end_bit;
    int             width;
    field_attr_e    attr;

    
    function new(string name="my_field", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void add_field(string name, int start_b, int end_b, field_attr_e field_attr);
        field_name = name;
        start_bit  = start_b;
        end_bit    = end_b;
        width      = end_bit - start_bit + 1;
        attr       = field_attr;
    endfunction

    function int get_field_data(int wdata);
        return (wdata >> start_bit) & ((1 << width) - 1);
    endfunction
endclass
`endif