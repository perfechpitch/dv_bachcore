class reg_generator extends uvm_object;
    bit [4:0] regs[$];
    rand bit [4:0] rand_reg;
    bit [4:0] disable_regs[$];
    `uvm_object_utils_begin(reg_generator)
        `uvm_field_sarray_int (regs  ,               UVM_DEFAULT)
        `uvm_field_int (rand_reg  ,               UVM_DEFAULT)
        `uvm_field_sarray_int (disable_regs  ,               UVM_DEFAULT)
    `uvm_object_utils_end


    // new - constructor
    function new (string name = "reg_generator");
      super.new(name);
    endfunction : new

    constraint reg_c{
        rand_reg inside{regs};
       !(rand_reg inside{disable_regs});
    }

    function void post_randomize();
        disable_regs.push_back(rand_reg);
    endfunction

    function void free_reg();
        disable_regs.delete();
    endfunction
endclass
class vreg_generator extends reg_generator;
    bit [3:0] emul=1;// rand reg must align with align width,default 1
    bit vm;
    bit [4:0] vreg_group;
    `uvm_object_utils_begin(vreg_generator)
        `uvm_field_int (emul  ,             UVM_DEFAULT)
        `uvm_field_int (vreg_group  ,       UVM_DEFAULT)
        `uvm_field_int (vm  ,               UVM_DEFAULT)
    `uvm_object_utils_end


    // new - constructor
    function new (string name = "vreg_generator");
      super.new(name);
    endfunction : new

    function void pre_randomize();
        case(emul)
            0: vreg_group = 1;
            1: vreg_group = 2;
            2: vreg_group = 4;
            3: vreg_group = 8;
            default: vreg_group = 1;
        endcase
    endfunction

    constraint vreg_c{
        vm ==0 -> rand_reg != 0;
        rand_reg%vreg_group == 0;
    }


endclass
class base_reg_generator extends reg_generator;
    addr_structure_s    base_addr_info[$];
    `uvm_object_utils_begin(base_reg_generator)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "base_reg_generator");
      super.new(name);
    endfunction : new

    function addr_structure_s get_rand_reg_base_info();
        addr_structure_s addr_info;
        foreach(regs[i])begin
            if(regs[i] == rand_reg) addr_info = base_addr_info[i];
            break;
        end
        return addr_info;
    endfunction

endclass

class register_pool extends uvm_object;
    rand bit [4:0] regs[$];
    rand bit [4:0] fregs[$];
    rand bit [4:0] vregs[$];

    //bit [4:0] vreg_group;

    bit [4:0] branch_regs[$];
    //for ls base
    bit [4:0] base_regs[$];
    // RVC stack-relative load/store always uses x2.  Keep its initialized
    // address metadata separate from the ordinary randomized base pool.
    addr_structure_s sp_base_addr_info;
    bit              sp_base_valid;
    //for vector ls imm
    bit [4:0] imm_regs[$];
    bit [4:0] vector_imm_regs[$];

    register_pool_config cfg;

    reg_generator   gpr_gen;
    reg_generator   fpr_gen;
    base_reg_generator   base_reg_gen;
    reg_generator   imm_reg_gen;

    vreg_generator   vpr_gen;
    vreg_generator   vector_imm_reg_gen;

    csr_config   csr_cfg;
    bit [4:0] reserved_regs[$];
    core_context_pool context_pool;
    protected register_context active_reg_context;
    `uvm_object_utils_begin(register_pool)
        `uvm_field_sarray_int (regs  ,               UVM_DEFAULT)
        `uvm_field_sarray_int (fregs  ,               UVM_DEFAULT)
        `uvm_field_sarray_int (vregs  ,               UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
 function new (string name = "register_pool");
      super.new(name);
      sp_base_valid = 1'b0;
      gpr_gen = new();
      fpr_gen = new();
      vpr_gen = new();
      base_reg_gen = new();
      imm_reg_gen = new();
      vector_imm_reg_gen = new();
    endfunction : new

    function register_context get_context();
        if(context_pool == null)
            `uvm_fatal("REGISTER_CONTEXT", "register_pool has no core_context_pool")
        return context_pool.get_register_context();
    endfunction

    // Save both the facade queues and the mutable state of the one shared set
    // of register-selection algorithms into the active core context.
    function void sync_active_context();
        if(active_reg_context == null)
            return;
        active_reg_context.regs            = regs;
        active_reg_context.fregs           = fregs;
        active_reg_context.vregs           = vregs;
        active_reg_context.branch_regs     = branch_regs;
        active_reg_context.base_regs       = base_regs;
        active_reg_context.sp_base_addr_info = sp_base_addr_info;
        active_reg_context.sp_base_valid   = sp_base_valid;
        active_reg_context.imm_regs        = imm_regs;
        active_reg_context.vector_imm_regs = vector_imm_regs;
        active_reg_context.reserved_regs   = reserved_regs;

        active_reg_context.gpr_gen_ctx.regs         = gpr_gen.regs;
        active_reg_context.gpr_gen_ctx.rand_reg     = gpr_gen.rand_reg;
        active_reg_context.gpr_gen_ctx.disable_regs = gpr_gen.disable_regs;
        active_reg_context.fpr_gen_ctx.regs         = fpr_gen.regs;
        active_reg_context.fpr_gen_ctx.rand_reg     = fpr_gen.rand_reg;
        active_reg_context.fpr_gen_ctx.disable_regs = fpr_gen.disable_regs;
        active_reg_context.base_reg_gen_ctx.regs         = base_reg_gen.regs;
        active_reg_context.base_reg_gen_ctx.rand_reg     = base_reg_gen.rand_reg;
        active_reg_context.base_reg_gen_ctx.disable_regs = base_reg_gen.disable_regs;
        active_reg_context.base_reg_gen_ctx.base_addr_info = base_reg_gen.base_addr_info;
        active_reg_context.imm_reg_gen_ctx.regs         = imm_reg_gen.regs;
        active_reg_context.imm_reg_gen_ctx.rand_reg     = imm_reg_gen.rand_reg;
        active_reg_context.imm_reg_gen_ctx.disable_regs = imm_reg_gen.disable_regs;
        active_reg_context.vpr_gen_ctx.regs         = vpr_gen.regs;
        active_reg_context.vpr_gen_ctx.rand_reg     = vpr_gen.rand_reg;
        active_reg_context.vpr_gen_ctx.disable_regs = vpr_gen.disable_regs;
        active_reg_context.vpr_gen_ctx.emul         = vpr_gen.emul;
        active_reg_context.vpr_gen_ctx.vm           = vpr_gen.vm;
        active_reg_context.vpr_gen_ctx.vreg_group   = vpr_gen.vreg_group;
        active_reg_context.vector_imm_reg_gen_ctx.regs         = vector_imm_reg_gen.regs;
        active_reg_context.vector_imm_reg_gen_ctx.rand_reg     = vector_imm_reg_gen.rand_reg;
        active_reg_context.vector_imm_reg_gen_ctx.disable_regs = vector_imm_reg_gen.disable_regs;
        active_reg_context.vector_imm_reg_gen_ctx.emul         = vector_imm_reg_gen.emul;
        active_reg_context.vector_imm_reg_gen_ctx.vm           = vector_imm_reg_gen.vm;
        active_reg_context.vector_imm_reg_gen_ctx.vreg_group   = vector_imm_reg_gen.vreg_group;
    endfunction

    function void load_context(register_context reg_ctx);
        active_reg_context = reg_ctx;

        if(!reg_ctx.initialized) begin
            regs.delete();
            fregs.delete();
            vregs.delete();
            branch_regs.delete();
            base_regs.delete();
            imm_regs.delete();
            vector_imm_regs.delete();
            reserved_regs.delete();
            sp_base_addr_info = '0;
            sp_base_valid = 1'b0;
            gpr_gen.regs.delete();
            gpr_gen.disable_regs.delete();
            gpr_gen.rand_reg = '0;
            fpr_gen.regs.delete();
            fpr_gen.disable_regs.delete();
            fpr_gen.rand_reg = '0;
            base_reg_gen.regs.delete();
            base_reg_gen.disable_regs.delete();
            base_reg_gen.base_addr_info.delete();
            base_reg_gen.rand_reg = '0;
            imm_reg_gen.regs.delete();
            imm_reg_gen.disable_regs.delete();
            imm_reg_gen.rand_reg = '0;
            vpr_gen.regs.delete();
            vpr_gen.disable_regs.delete();
            vpr_gen.rand_reg = '0;
            vpr_gen.emul = 1;
            vpr_gen.vm = 0;
            vpr_gen.vreg_group = 1;
            vector_imm_reg_gen.regs.delete();
            vector_imm_reg_gen.disable_regs.delete();
            vector_imm_reg_gen.rand_reg = '0;
            vector_imm_reg_gen.emul = 1;
            vector_imm_reg_gen.vm = 0;
            vector_imm_reg_gen.vreg_group = 1;
            if(!this.randomize())
                `uvm_fatal("REGISTER_CONTEXT", "core register context randomize failed")
            reg_ctx.initialized = 1'b1;
            sync_active_context();
        end
        else begin
            regs              = reg_ctx.regs;
            fregs             = reg_ctx.fregs;
            vregs             = reg_ctx.vregs;
            branch_regs       = reg_ctx.branch_regs;
            base_regs         = reg_ctx.base_regs;
            sp_base_addr_info = reg_ctx.sp_base_addr_info;
            sp_base_valid     = reg_ctx.sp_base_valid;
            imm_regs          = reg_ctx.imm_regs;
            vector_imm_regs   = reg_ctx.vector_imm_regs;
            reserved_regs     = reg_ctx.reserved_regs;

            gpr_gen.regs         = reg_ctx.gpr_gen_ctx.regs;
            gpr_gen.rand_reg     = reg_ctx.gpr_gen_ctx.rand_reg;
            gpr_gen.disable_regs = reg_ctx.gpr_gen_ctx.disable_regs;
            fpr_gen.regs         = reg_ctx.fpr_gen_ctx.regs;
            fpr_gen.rand_reg     = reg_ctx.fpr_gen_ctx.rand_reg;
            fpr_gen.disable_regs = reg_ctx.fpr_gen_ctx.disable_regs;
            base_reg_gen.regs         = reg_ctx.base_reg_gen_ctx.regs;
            base_reg_gen.rand_reg     = reg_ctx.base_reg_gen_ctx.rand_reg;
            base_reg_gen.disable_regs = reg_ctx.base_reg_gen_ctx.disable_regs;
            base_reg_gen.base_addr_info = reg_ctx.base_reg_gen_ctx.base_addr_info;
            imm_reg_gen.regs         = reg_ctx.imm_reg_gen_ctx.regs;
            imm_reg_gen.rand_reg     = reg_ctx.imm_reg_gen_ctx.rand_reg;
            imm_reg_gen.disable_regs = reg_ctx.imm_reg_gen_ctx.disable_regs;
            vpr_gen.regs         = reg_ctx.vpr_gen_ctx.regs;
            vpr_gen.rand_reg     = reg_ctx.vpr_gen_ctx.rand_reg;
            vpr_gen.disable_regs = reg_ctx.vpr_gen_ctx.disable_regs;
            vpr_gen.emul         = reg_ctx.vpr_gen_ctx.emul;
            vpr_gen.vm           = reg_ctx.vpr_gen_ctx.vm;
            vpr_gen.vreg_group   = reg_ctx.vpr_gen_ctx.vreg_group;
            vector_imm_reg_gen.regs         = reg_ctx.vector_imm_reg_gen_ctx.regs;
            vector_imm_reg_gen.rand_reg     = reg_ctx.vector_imm_reg_gen_ctx.rand_reg;
            vector_imm_reg_gen.disable_regs = reg_ctx.vector_imm_reg_gen_ctx.disable_regs;
            vector_imm_reg_gen.emul         = reg_ctx.vector_imm_reg_gen_ctx.emul;
            vector_imm_reg_gen.vm           = reg_ctx.vector_imm_reg_gen_ctx.vm;
            vector_imm_reg_gen.vreg_group   = reg_ctx.vector_imm_reg_gen_ctx.vreg_group;
        end
    endfunction

    function void select_active_context();
        register_context next_context;
        next_context = get_context();
        if(next_context == active_reg_context)
            return;
        sync_active_context();
        load_context(next_context);
    endfunction


    constraint reg_c{
        if(cfg.gpr_full_valid){regs.size() == 32;}
        else{
        regs.size() inside{[10:32]};}
        unique{regs};
        foreach(regs[i]){
            regs[i] inside{[0:31]};
        }
    }

    constraint freg_c{
        if(cfg.fpr_full_valid){fregs.size() == 32;}
        else{
        fregs.size() inside{[8:32]};}
        unique{fregs};
        foreach(fregs[i]){
            fregs[i] inside{[0:31]};
        }
    }
    //vreg used for vd is danger
    //vregs contain all regs.because it is limited by vlmul when rand inst
    constraint vreg_c{
        vregs.size() == 32;
        unique{vregs};
    }

    function void pre_randomize();
    endfunction
   function void post_randomize();
        gpr_gen.regs = regs;
        fpr_gen.regs = fregs;
        vpr_gen.regs = vregs;
        base_reg_gen.regs = base_regs;
        imm_reg_gen.regs = imm_regs;
        vector_imm_reg_gen.regs = vector_imm_regs;
     //   foreach(regs[i])begin
     //       $display("reg[%0d] = %0d",i,regs[i]);
     //   end
     //   foreach(fregs[i])begin
     //       $display("freg[%0d] = %0d",i,fregs[i]);
     //   end
     //   foreach(vregs[i])begin
     //       $display("vreg[%0d] = %0d",i,vregs[i]);
     //   end
    endfunction
    function branch_reg_get(bit [4:0] reg_num);
        bit[4:0] tmp;
        int i=0;
        //reg 0 can not be it's special reg cannot be li initial
        while(i<reg_num)begin
            //regs[] need 3 reg at least for rs1, rs2, rd random
            if(regs.size()>3) begin
                tmp = regs.pop_front();
                //gpr0 is always zero, can not used for branch index
                if(tmp !==0 )begin
                    branch_regs.push_back(tmp);
                    i=i+1;
                end
                else regs.push_back(tmp);
            end
            else break;
        end
        gpr_gen.regs = regs;
    endfunction
function branch_reg_free();
        bit[4:0] tmp;
        while(branch_regs.size!==0) begin
            tmp = branch_regs.pop_front();
            regs.push_back(tmp);
        end
        gpr_gen.regs = regs;
    endfunction

    // get some base regs
    function bit[4:0] base_reg_get(bit [4:0] base_num, addr_structure_s base_addr_q[$]);
        bit[4:0] tmp;
        int i=0;
        int c_base_index;
        //clean old base_info
        base_reg_free();
        vector_imm_reg_free();
        sp_base_valid = 1'b0;
        // RV32 C.JAL writes x1 implicitly. Keep the link register out of the
        // ordinary LS base pool so taking C.JAL cannot invalidate LS metadata.
        if(cfg.support_rvc && cfg.xlen == 32) begin
            foreach(regs[j]) begin
                if(regs[j] == 5'd1) begin
                    regs.delete(j);
                    break;
                end
            end
        end
        // x2 is maintained as the RVC stack base and must not be selected as
        // an ordinary destination register after LS base initialization.
        if(cfg.support_rvc) begin
            foreach(regs[j]) begin
                if(regs[j] == 5'd2) begin
                    regs.delete(j);
                    break;
                end
            end
        end
        // When RVC is enabled, reserve one initialized LS base encodable by
        // C.LW/C.SW. If the randomized pool lacks x8..x15, inject x8 only
        // into this per-test pool before it is initialized by the LS sequence.
        if(cfg.support_rvc) begin
            c_base_index = -1;
            foreach(regs[j])
                if((regs[j] inside {[5'd8:5'd15]}) && c_base_index == -1)
                    c_base_index = j;
            if(c_base_index == -1)
                regs.push_front(5'd8);
            else begin
                tmp = regs[c_base_index];
                regs.delete(c_base_index);
                regs.push_front(tmp);
            end
        end
        imm_reg_free();
        //there are 3 ~31 regs in regs[]
        //reg 0 can not be base is because store is disabled in 0x0~0xfff
        while(i<base_num)begin
            if(regs.size()>3) begin
                tmp = regs.pop_front();
                //gpr0 is always zero, can not be ls base
                if(tmp !==0 )begin
                //$display("%0h is put base_regs",tmp);
                    base_regs.push_back(tmp);
                    base_reg_gen.base_addr_info.push_back(base_addr_q[i]);
                    i=i+1;
                end
                else regs.push_back(tmp);
            end
            else break;
        end


        base_reg_gen.regs = base_regs;
        gpr_gen.regs = regs;
        tmp = base_regs.size();
        return tmp;
    endfunction
 function base_reg_free();
        bit[4:0] tmp;

        while(base_regs.size()>0)begin
            tmp = base_regs.pop_front();
            base_reg_gen.base_addr_info.pop_front();
            regs.push_back(tmp);
        end
        gpr_gen.regs = regs;
        base_reg_gen.regs = base_regs;
    endfunction
    //get some imm regs
    function imm_reg_get(bit [4:0] imm_num);
        bit[4:0] tmp;
        //there are 3 ~31 regs in regs[]
        for(int i=0;i<imm_num;i++)begin
            if(regs.size()>3) begin
                tmp = regs.pop_front();
                imm_regs.push_back(tmp);
            end
            else break;
        end
        imm_reg_gen.regs = imm_regs;
        gpr_gen.regs = regs;
    endfunction
    function imm_reg_free();
        bit[4:0] tmp;
        for(int i=0;i<32;i++)begin
            //at least one reg
            if(imm_regs.size>1) begin
                tmp = imm_regs.pop_front();
                regs.push_back(tmp);
            end
            else break;
        end
        gpr_gen.regs = regs;
    endfunction
 function vector_imm_reg_get(bit [4:0] vector_imm_num);
        bit[4:0] tmp;
        int i=0;
        //there are 3 ~31 regs in vregs[]
        //for(int i=0;i<vector_imm_num;i++)begin
        //foreach(vregs[i])
        //$display("before vector imm get: vregs = %0h",vregs[i]);

        //release last time allocate vector imm reg
        foreach(vector_imm_regs[i])begin
            vregs.push_back(vector_imm_regs[i]);
        end
        vector_imm_regs.delete();

        while(i<vector_imm_num)begin
            if(vregs.size()>3) begin
                tmp = vregs.pop_front();
                //vector reg0 is mask reg, make it zero would cause illegal with vm=0
                if(tmp !==0 )begin
                    vector_imm_regs.push_back(tmp);
                    i=i+1;
                end
                else begin
                    vregs.push_back(tmp);
                end
            end
            else break;
        end
        vector_imm_reg_gen.regs = vector_imm_regs;
        vpr_gen.regs = vregs;
        if($test$plusargs("debug_print"))begin
        foreach(vregs[i])
        $display("after vector imm get: vregs = %0h",vregs[i]);
        foreach(vector_imm_regs[i])
        $display("after vector imm get: vimmregs = %0h",vector_imm_regs[i]);
        end
    endfunction
function vector_imm_reg_free();
        bit[4:0] tmp;
        for(int i=0;i<32;i++)begin
            //at least one reg
            if(vector_imm_regs.size>1) begin
                tmp = vector_imm_regs.pop_front();
                vregs.push_back(tmp);
        //        $display("2222 tmp = %0h",tmp);
            end
            else break;
        end
        vpr_gen.regs = vregs;
        //foreach(vregs[i])
        //$display("after vector imm free: vregs = %0h",vregs[i]);
        //foreach(vector_imm_regs[i])
        //$display("after vector imm free: vimmregs = %0h",vector_imm_regs[i]);
    endfunction

    //get_rand_reg - base
    function bit[4:0] get_base_reg();
        bit[4:0] val;
        //$display("11 size = %0d",base_reg_gen.regs.size());
        if(base_regs.size() == 0)begin
            val = 0;    //safe load
        end
        else begin
        `RANDOMIZE_CHECK(base_reg_gen,"ERROR: base reg gen error!!")
            val = base_reg_gen.rand_reg;
        end
        return val;
    endfunction
 //get_rand_reg - base
    function bit[4:0] get_ls_base_reg(ref addr_structure_s ls_s);
        bit[4:0] val;
        int find_index_q[$];
        int rand_index_id;
        //find_index_q = base_reg_gen.base_addr_info.find_index with(ls_s.addr_type == item.addr_type ||
        find_index_q = base_reg_gen.base_addr_info.find_index with(ls_s.addr_type == LOAD_VALID && (item.addr_type == LOAD_VALID || item.addr_type == LS_VALID || item.addr_type == AMO_VALID)||
                                                                   ls_s.addr_type == LS_VALID   && (                                item.addr_type == LS_VALID || item.addr_type == AMO_VALID)||
                                                                   ls_s.addr_type == AMO_VALID  && (                                                              item.addr_type == AMO_VALID)||
                                                                   ls_s.addr_type == LOAD_INVALID   && (item.addr_type == LOAD_INVALID                                                                 ) ||
                                                                   ls_s.addr_type == LS_INVALID     && (item.addr_type == LOAD_INVALID || item.addr_type == LS_INVALID                                 ) ||
                                                                   ls_s.addr_type == AMO_INVALID    && (item.addr_type == LOAD_INVALID || item.addr_type == LS_INVALID || item.addr_type == AMO_INVALID
                                                                                                     || item.vaddr[1:0] !== 0)); // AMO vaddr = base reg val

        if(find_index_q.size() == 0)begin
            foreach(base_reg_gen.base_addr_info[i])begin
                $display("base addr info[%0d]: %0p",i,base_reg_gen.base_addr_info[i]);
            end
            `uvm_error(`gfn,$sformatf("ls inst Base get fail with ls_s = %0p",ls_s));
        end
        else begin
            rand_index_id = $urandom_range(find_index_q.size()-1);
            rand_index_id = find_index_q[rand_index_id];
            val = base_regs[rand_index_id];
            ls_s = base_reg_gen.base_addr_info[rand_index_id];
        end
            //foreach(base_reg_gen.base_addr_info[i])begin
            //    $display("base_addr_info[%0d] : %0p",i,base_reg_gen.base_addr_info[i]);
            //end
            //$display("return ls_s: %0p",ls_s);
        return val;
    endfunction

    function bit is_ls_base_reg(bit[4:0] reg_num);
        if(sp_base_valid && reg_num == 5'd2)
            return 1'b1;
        foreach(base_regs[i])
            if(base_regs[i] == reg_num)
                return 1'b1;
        return 1'b0;
    endfunction

    function void set_ls_sp_base(addr_structure_s ls_s);
        sp_base_addr_info = ls_s;
        sp_base_valid = 1'b1;
    endfunction

    function void clear_ls_sp_base();
        sp_base_valid = 1'b0;
    endfunction

    function bit[4:0] get_ls_sp_base(ref addr_structure_s ls_s);
        if(!sp_base_valid) begin
            `uvm_error(`gfn, "C.LWSP/C.SWSP needs an initialized x2 LS base")
            ls_s = '0;
        end
        else
            ls_s = sp_base_addr_info;
        return 5'd2;
    endfunction

    //get_reserved_reg - gpr, used for except handle temp reg

    // C.LW/C.SW encode rs1' as x8..x15. Select only an already initialized
    // LS base from that register subset, preserving the normal address metadata.
    function bit[4:0] get_ls_c_base_reg(ref addr_structure_s ls_s);
        bit[4:0] val;
        int find_index_q[$];
        int rand_index_id;
        foreach(base_reg_gen.base_addr_info[i]) begin
            if ((base_regs[i] inside {[5'd8:5'd15]}) &&
                ((ls_s.addr_type == LOAD_VALID &&
                  (base_reg_gen.base_addr_info[i].addr_type == LOAD_VALID ||
                   base_reg_gen.base_addr_info[i].addr_type == LS_VALID  ||
                   base_reg_gen.base_addr_info[i].addr_type == AMO_VALID)) ||
                 (ls_s.addr_type == LS_VALID &&
                  (base_reg_gen.base_addr_info[i].addr_type == LS_VALID ||
                   base_reg_gen.base_addr_info[i].addr_type == AMO_VALID))))
                find_index_q.push_back(i);
        end
        if(find_index_q.size() == 0) begin
            `uvm_error(`gfn, "C.LW/C.SW needs an x8..x15 LS base register")
            val = '0;
        end
        else begin
            rand_index_id = find_index_q[$urandom_range(find_index_q.size()-1)];
            val = base_regs[rand_index_id];
            ls_s = base_reg_gen.base_addr_info[rand_index_id];
        end
        return val;
    endfunction

  function bit[4:0] get_reserved_gpr();
        bit[4:0] val;
        val = get_nonezero_gpr(1'b1);
        reserved_regs.push_back(val);
        //delete reserved gpr info  from regs
        foreach(gpr_gen.regs[i])begin
            if(gpr_gen.regs[i] == val)begin
                gpr_gen.regs.delete(i);
                break;
            end
        end

        regs = gpr_gen.regs;
        return val;
    endfunction

    // Keep a dependency register out of all ordinary random GPR selection
    // until the matching consumer has been emitted.  This differs from the
    // per-instruction disable list, which free_reg() clears after every inst.
    function bit[4:0] pin_gpr();
        return get_reserved_gpr();
    endfunction

    function void unpin_gpr(bit[4:0] reg_num);
        bit found;
        found = 1'b0;
        foreach(reserved_regs[i]) begin
            if(reserved_regs[i] == reg_num) begin
                reserved_regs.delete(i);
                found = 1'b1;
                break;
            end
        end
        if(!found)
            `uvm_fatal("REGISTER_PIN",
                       $sformatf("cannot unpin x%0d: register is not pinned", reg_num))
        if(!(reg_num inside {gpr_gen.regs}))
            gpr_gen.regs.push_back(reg_num);
        if(!(reg_num inside {regs}))
            regs.push_back(reg_num);
        sync_active_context();
    endfunction
    //special seq may dont want zero rd
    function bit[4:0] get_nonezero_gpr(bit get_rd);
        bit[4:0] val;

        val = 0;
        while(val==0)begin
            val = get_gpr(get_rd);
        end
        return val;
    endfunction
    //if get gpr is get rd, it can not be base reg
    //else it can from base reg
 function bit[4:0] get_gpr(bit get_rd);
        bit[4:0] val;
        bit get_from_base_reg;
        //foreach(gpr_gen.regs[i])
        //    $display("11 gpr[%0d] = %0d",i,gpr_gen.regs[i]);
        if(get_rd)begin
            if(gpr_gen.disable_regs.size() >= gpr_gen.regs.size())
                gpr_gen.free_reg();
            `RANDOMIZE_CHECK(gpr_gen,"ERROR: gpr reg gen error!!")
            val = gpr_gen.rand_reg;
        end
        else begin
            get_from_base_reg = $random() && !(base_reg_gen.regs.size() == base_reg_gen.disable_regs.size());//when only 1 base reg. it may use twice in inst like sw
            if(get_from_base_reg)begin
                val = get_base_reg();
            end
            else begin
                if(gpr_gen.disable_regs.size() >= gpr_gen.regs.size())
                    gpr_gen.free_reg();
                `RANDOMIZE_CHECK(gpr_gen,"ERROR: gpr reg gen error!!")
                val = gpr_gen.rand_reg;
            end
        end
        return val;
    endfunction
    //get_rand_reg - vector_imm
    function bit[4:0] get_vector_imm_reg(bit [3:0] emul,bit vm);
        bit[4:0] val;
        //$display("vector_imm_reg.size = %0h", vector_imm_reg_gen.regs.size());
        vector_imm_reg_gen.emul = emul;
        //$display("imm_reg.size = %0h", vector_imm_reg_gen.regs.size());
        vector_imm_reg_gen.vm = vm;
        `RANDOMIZE_CHECK(vector_imm_reg_gen,"ERROR: vector imm reg gen error!!")
        val = vector_imm_reg_gen.rand_reg;
        return val;
    endfunction
 //get_rand_reg - imm
    function bit[4:0] get_imm_reg();
        bit[4:0] val;
        `RANDOMIZE_CHECK(imm_reg_gen,"ERROR: imm reg gen error!!")
        val = imm_reg_gen.rand_reg;
        return val;
    endfunction
    //get_rand_reg - fpr
    function bit[4:0] get_fpr();
        bit[4:0] val;
        `RANDOMIZE_CHECK(fpr_gen,"ERROR: fpr reg gen error!!")
        val = fpr_gen.rand_reg;
        return val;
    endfunction
    //get_rand_reg - vpr
    function bit[4:0] get_vpr(bit [3:0] emul,bit vm);
        bit[4:0] val;
        vpr_gen.emul = emul;
        vpr_gen.vm = vm;
        //$display("vpr_reg.size = %0h,vm=%0h,emul=%0h", vpr_gen.regs.size(),vm,emul);
        `RANDOMIZE_CHECK(vpr_gen,"ERROR: vpr reg gen error!!")
        val = vpr_gen.rand_reg;
        return val;
    endfunction
  function void free_reg();
        gpr_gen.free_reg();
        fpr_gen.free_reg();
        vpr_gen.free_reg();
        imm_reg_gen.free_reg();
        vector_imm_reg_gen.free_reg();
//    $display("before base disable reg size = %0d", base_reg_gen.disable_regs.size());
        base_reg_gen.free_reg();
//    $display("after base disable reg size = %0d", base_reg_gen.disable_regs.size());
    endfunction

endclass
