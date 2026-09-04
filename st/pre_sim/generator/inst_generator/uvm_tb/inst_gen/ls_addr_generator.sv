//----------------------------------------------------------------------
// ls_addr_generator
//   访存合法地址独立生成器，不走 addr_space_gen（无 PMA/PMP/PTE/link 表）。
//   VA=PA。ITCM 只给取指，这里只管 DTCM / Share 上的 load/store/AMO。
//
// 使用顺序：
//   1) get_ls_addr()  在窗内抽 EA，拆成 base_val + imm12，写 GPR
//   2) bind_base()    记下这条 base 对应的窗口，供后续 load/store 用
//   3) get_ls_imm()   在「窗口 ∩ imm12 可达」里再抽 EA，imm = ea - base
//   4) ls_imm_fix()   线性 seq 等指定 imm 时，检查 base+imm 是否仍在窗内
//
// 不越界原则：先裁 EA，再反推 imm，而不是先随机 12bit 再碰运气。
//----------------------------------------------------------------------
class ls_addr_generator extends uvm_object;
    share_layout_e  share_layout;
    tcm_hart_e      hart;
    bit[63:0]       dtcm_base;
    bit[63:0]       share_base;
    // 已写入 GPR 的 base：用 base_val 找回窗口，供 get_ls_imm / ls_imm_fix
    ls_addr_s       bound_base[$];

    `uvm_object_utils_begin(ls_addr_generator)
        `uvm_field_enum(share_layout_e, share_layout, UVM_DEFAULT)
        `uvm_field_enum(tcm_hart_e, hart, UVM_DEFAULT)
        `uvm_field_int(dtcm_base, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(share_base, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new (string name = "ls_addr_generator");
        super.new(name);
        share_layout = SHARE_RAND_3CORE;
        hart         = HART_MU;
        dtcm_base    = `DTCM_BASE;
        share_base   = `SHARE_BASE;
    endfunction : new

    // 换一批 base 前清空绑定。ls_base_config_seq 每次配 base 都会调。
    function void reset_bases();
        bound_base.delete();
    endfunction

    // SW_PARTITION 下一 user 内三个 hart 槽的起始偏移（不含 share_base/user_id）。
    // MU='h0, VU=`HART_SLOT(='h2A0), DTE=`HART_SLOT*2(='h540)。槽长 `HART_SLOT。
    function bit[63:0] hart_slot_base();
        case(hart)
            HART_MU : return 'h0;
            HART_VU : return `HART_SLOT;
            HART_DTE: return `HART_SLOT * 2;
            default : return 'h0;
        endcase
    endfunction

    //------------------------------------------------------------------
    // get_window
    //   半开区间 [win_lo, win_hi)。所有 EA / base 都相对这个窗。
    //
    //   DTCM:
    //     每 hart 物理 4KB，VA 相同。[dtcm_base, dtcm_base+`DTCM_SIZE)
    //     默认 dtcm_base='h0。取指走 ITCM 同 VA，访存走 DTCM。
    //
    //   SHARE_RAND_3CORE:
    //     整段 Share [share_base, share_base+`SHARE_SIZE)，默认 ['h8000,'h10000)
    //     生成器给绝对 PA，三核可争用。
    //
    //   SHARE_SW_PARTITION:
    //     软件布局：share_base + user_id*`USER_STRIDE + HART_BASE + hart_off
    //     生成器只返回 hart 槽 [HART_BASE, HART_BASE+`HART_SLOT)
    //     镜像里不含 share_base / user_id，运行时由各 user 自己加基址。
    //------------------------------------------------------------------
    function void get_window(ls_mem_type_e mem_type, output bit[63:0] win_lo, output bit[63:0] win_hi);
        if(mem_type == LS_MEM_DTCM)begin
            win_lo = dtcm_base;
            win_hi = dtcm_base + `DTCM_SIZE;
        end
        else if(share_layout == SHARE_SW_PARTITION)begin
            win_lo = hart_slot_base();
            win_hi = win_lo + `HART_SLOT;
        end
        else begin
            win_lo = share_base;
            win_hi = share_base + `SHARE_SIZE;
        end
    endfunction

    //------------------------------------------------------------------
    // rand_ea
    //   在窗内随机一个对齐的有效地址（访问起始地址）。
    //   hi = win_hi - access_size：8 字节访问时 EA 最大到 win_hi-'h8，
    //   避免「起始地址在窗内、访问跨出窗外」。
    //   lo/hi 再按 align 对齐后，在 [lo, hi] 上均匀抽。
    //------------------------------------------------------------------
    function bit[63:0] rand_ea(bit[63:0] win_lo, bit[63:0] win_hi, int unsigned align, int unsigned access_size);
        bit[63:0] lo, hi, span, idx;
        if(align == 0) align = 1;
        if(access_size == 0) access_size = align;
        lo = (win_lo + align - 1) / align * align;
        hi = win_hi - access_size;
        hi = hi / align * align;
        if(hi < lo) return lo;
        span = (hi - lo) / align;
        idx  = $urandom_range(span);
        return lo + idx * align;
    endfunction

    //------------------------------------------------------------------
    // split_addr
    //   把已合法的 ea 拆成  ea = base_val + sext(imm12)
    //   写 base 时只用非负 imm（0 ~ 'h7ff），这样：
    //     - base_val = ea - off 一定 ≤ ea，且 ≥ win_lo（off 被 ea-win_lo 卡住）
    //     - imm 一定落在 I-type 正数范围，硬件 sext 后就是 +off
    //   例：DTCM win_lo='h0, ea='h20 → max_pos 收成 'h20，不会拆出负 base。
    //   max_pos==0（ea 贴着窗底，或对齐后没有可拆余量）→ base=ea, imm=0。
    //------------------------------------------------------------------
    function void split_addr(bit[63:0] ea, bit[63:0] win_lo, int unsigned align,
                             output bit[63:0] base_val, output bit[11:0] imm);
        int unsigned max_pos, off;
        max_pos = 'h7ff;
        if(ea > win_lo && (ea - win_lo) < max_pos)
            max_pos = ea - win_lo;
        if(align > 1)
            max_pos = max_pos / align * align;
        if(max_pos == 0)begin
            base_val = ea;
            imm      = 'h0;
            return;
        end
        off      = $urandom_range(max_pos / (align == 0 ? 1 : align)) * align;
        base_val = ea - off;
        imm      = off[11:0];
    endfunction

    //------------------------------------------------------------------
    // get_ls_addr
    //   给 ls_base_config 配一条 base：选存储、抽 EA、拆 base+imm。
    //
    //   AMO_* : 指令没有 imm12，rs1 就是 EA → 只进 Share，base_val=ea, imm=0
    //   其它  : DTCM / Share 各 50%；再 split_addr
    //
    //   返回的 win_lo/win_hi 必须 bind 下来，后面 get_ls_imm 靠它裁边界，
    //   不能只记住 base_val（一个 imm12 盖不住整段 4KB/32KB）。
    //------------------------------------------------------------------
    function ls_addr_s get_ls_addr(addr_type_e addr_type, int unsigned align, int unsigned access_size);
        ls_addr_s a;
        bit[63:0] win_lo, win_hi;
        a.addr_type = addr_type;
        if(addr_type == AMO_VALID || addr_type == AMO_INVALID)
            a.mem_type = LS_MEM_SHARE;
        else
            a.mem_type = ($urandom_range(1)) ? LS_MEM_DTCM : LS_MEM_SHARE;
        if(align == 0) align = 1;
        if(access_size == 0) access_size = align;
        get_window(a.mem_type, win_lo, win_hi);
        a.win_lo = win_lo;
        a.win_hi = win_hi;
        a.ea     = rand_ea(win_lo, win_hi, align, access_size);
        if(addr_type == AMO_VALID || addr_type == AMO_INVALID)begin
            a.base_val = a.ea;
            a.imm      = 'h0;
        end
        else
            split_addr(a.ea, win_lo, align, a.base_val, a.imm);
        return a;
    endfunction

    function void bind_base(ls_addr_s a);
        bound_base.push_back(a);
    endfunction

    // ls_s.vaddr 存的是当时写入 GPR 的 base_val。按值找回窗口。
    // 找不到：退回第一条已绑定 base；再没有则造一段 [base, base+'h800)，
    // 避免 get_ls_imm 空指针，但窗口可能不准（正常路径都会 bind）。
    function ls_addr_s find_bound(bit[63:0] base_val);
        ls_addr_s a;
        foreach(bound_base[i])begin
            if(bound_base[i].base_val == base_val)
                return bound_base[i];
        end
        if(bound_base.size() != 0)
            return bound_base[0];
        a.base_val = base_val;
        a.win_lo   = base_val;
        a.win_hi   = base_val + 'h800;
        return a;
    endfunction

    //------------------------------------------------------------------
    // get_ls_imm
    //   某条 load/store 已经选好 rs1（ls_s.vaddr == 该 GPR 的 base_val）。
    //   在下列三个区间的交集里随机 EA，再 imm = ea - base：
    //
    //     ① 窗口        [win_lo, win_hi - size)
    //     ② imm12 可达  有符号: [base-'h800, base+'h7ff]
    //                    无符号 load(lbu/lhu/lwu): 只用非负 [base, base+'h7ff]
    //     ③ 对齐        再按 align_bytes 对齐
    //
    //   例：DTCM [0,'h1000), base='hF00
    //     若直接 +'h7ff → 'h16FF 出窗，ea_max 被收到 'h1000-size。
    //   交集为空则退回对齐后的 base（等价 imm=0）。
    //
    //   ls_addr_misalign：在已裁 EA 上再加 1..align-1，可能轻轻越窗，
    //   只给 invalid_* 测非对齐；合法 load 约束 ls_addr_misalign_en==0。
    //------------------------------------------------------------------
    function bit[11:0] get_ls_imm(addr_structure_s ls_s, ops_gen_config ops_gen_cfg);
        ls_addr_s     b;
        bit[63:0]     ea, ea_min, ea_max;
        int unsigned  align, size, span, idx;
        bit signed [12:0] simm;
        align = (ops_gen_cfg.align_bytes == 0) ? 1 : ops_gen_cfg.align_bytes;
        size  = align;
        b     = find_bound(ls_s.vaddr);
        ea_min = b.win_lo;
        if(!ops_gen_cfg.ls_inst_unsigned)begin
            if(b.base_val > 'h800 && (b.base_val - 'h800) > ea_min)
                ea_min = b.base_val - 'h800;
        end
        else if(b.base_val > ea_min)
            ea_min = b.base_val;
        ea_max = b.base_val + 'h7ff;
        if(ea_max > (b.win_hi - size))
            ea_max = b.win_hi - size;
        ea_min = (ea_min + align - 1) / align * align;
        ea_max = ea_max / align * align;
        if(ea_max < ea_min)
            ea = (b.base_val / align) * align;
        else begin
            span = (ea_max - ea_min) / align;
            idx  = $urandom_range(span);
            ea   = ea_min + idx * align;
        end
        if(ops_gen_cfg.ls_addr_misalign && align > 1)
            ea = ea + ($urandom_range(align - 2) + 1);
        simm = ea - b.base_val;
        return simm[11:0];
    endfunction

    //------------------------------------------------------------------
    // ls_imm_fix
    //   调用方指定了 imm（如 linear stride），检查
    //     ea = base_val + sext(imm12)  是否落在绑定窗口内。
    //   越界则返回 0，load/store 的 override 路径会改调 get_ls_imm 重抽。
    //------------------------------------------------------------------
    function bit ls_imm_fix(bit[31:0] ls_imm, ref addr_structure_s ls_s);
        ls_addr_s b;
        bit[63:0] ea;
        bit signed [11:0] imm12;
        b     = find_bound(ls_s.vaddr);
        imm12 = ls_imm[11:0];
        ea    = b.base_val + imm12;
        return (ea >= b.win_lo) && (ea < b.win_hi);
    endfunction
endclass
