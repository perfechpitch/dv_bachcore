typedef enum{INT_TEST,FP_TEST,VECTOR_TEST,RAND_TEST}test_mode_e;
typedef enum{SAFE_SEQ_DISABLE,LS_SEQ_DISABLE,BRANCH_SEQ_DISABLE,FLUSH_INST_ENABLE,EXCEPT_INST_ENABLE,WFI_INST_ENABLE,
             LS_BASE_INFO_CONFIRM,//default random in every ls seq
             GPR_FULL_VALID,FPR_FULL_VALID,
             DISABLE_4K_PAGE,DISABLE_2M_PAGE,DISABLE_1G_PAGE,
             INT_ACK_DISABLE
             }test_feature_e;
typedef enum{SPIKE_SIM,RISCV_TESTS_SIM,RAND_SIM}sim_mode_e;
class inst_gen_case_config extends uvm_object;
    inst_gen_config    inst_gen_cfg;  //for inst_name
    inst_seq_type_config    inst_seq_type_cfg;  //for seq type gen
    inst_seq_config         flush_seq_cfg;       //for flush seq base info gen

    csr_config              csr_cfg;            //for config before test

    safe_seq_config         safe_seq_cfg;       //for safe seq  gen
    branch_seq_config       branch_seq_cfg;     //for branch seq gen
    ls_seq_config           ls_seq_cfg;         //for ls seq gen
    except_seq_config       except_seq_cfg;     //for except seq gen

    addr_space_config       addr_space_cfg;
    task_info_config        task_info;

    inst_set_e    support_inst_set[] = `SUPPORT_INST_SET;
    mode_e        support_prv_mode[] = `SUPPORT_PRV_MODE;
    csr_set_e     support_csr_set    = `SUPPORT_CSR_SET ;


    //var
    sim_mode_e              sim_mode =RAND_SIM;
    test_mode_e             test_mode=RAND_TEST;
    test_feature_e          test_feature[$];
    bit float_en=1;
    bit global_disable_ls=0;
    bit except_disable = 1;
    bit int_ack_disable = 0;

    int seq_num = 'd100;
    int gen_file;
    int vmem_file;

    `uvm_object_utils_begin(inst_gen_case_config)
        `uvm_field_enum (test_mode_e,   test_mode,  UVM_DEFAULT)
        `uvm_field_enum (sim_mode_e,   sim_mode,  UVM_DEFAULT)
        `uvm_field_int  (seq_num,  UVM_DEFAULT)
        `uvm_field_sarray_enum (test_feature_e,   test_feature,  UVM_DEFAULT)
        `uvm_field_int  (float_en,  UVM_DEFAULT)
        `uvm_field_int  (global_disable_ls,  UVM_DEFAULT)

        `uvm_field_object(csr_cfg, UVM_DEFAULT)
        `uvm_field_object(inst_seq_type_cfg, UVM_DEFAULT)
        `uvm_field_object(safe_seq_cfg, UVM_DEFAULT)
        `uvm_field_object(flush_seq_cfg, UVM_DEFAULT)
        `uvm_field_object(except_seq_cfg, UVM_DEFAULT)
        `uvm_field_object(branch_seq_cfg, UVM_DEFAULT)
        `uvm_field_object(ls_seq_cfg, UVM_DEFAULT)
        `uvm_field_object(except_seq_cfg, UVM_DEFAULT)
        `uvm_field_object(addr_space_cfg, UVM_DEFAULT)
        `uvm_field_object(task_info, UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "inst_gen_case_config");
        string test_name;
        super.new(name);
        inst_gen_cfg        = new();
        inst_seq_type_cfg   = new();
        safe_seq_cfg        = new();
        flush_seq_cfg       = new();
        except_seq_cfg      = new();

        csr_cfg             = new();

        branch_seq_cfg      = new();
        ls_seq_cfg          = new();
        except_seq_cfg          = new();

        addr_space_cfg      = new();
        task_info           = new();
        gen_file = $fopen(($psprintf("./test.S")),"w");
    endfunction : new

    function config_convert();
        string test_mode_string;
        string test_name;
        int xlen_arg;
        if($value$plusargs("xlen=%d", xlen_arg)) begin
            inst_gen_cfg.xlen = xlen_arg;
        end
        if(inst_gen_cfg.xlen != 32 && inst_gen_cfg.xlen != 64) begin
            `uvm_fatal("XLEN", $sformatf("Unsupported xlen=%0d; only 32 or 64 are legal", inst_gen_cfg.xlen))
        end
        if($value$plusargs("seq_num=%d",seq_num))begin
        end
        if($value$plusargs("test_mode=%s",test_mode_string))begin
            case(test_mode_string)
                "INT_TEST"      : test_mode = INT_TEST;
                "FP_TEST"       : test_mode = FP_TEST;
                "VECTOR_TEST"   : test_mode = VECTOR_TEST;
                "RAND_TEST"     : test_mode = RAND_TEST;
            endcase
        end
        if($value$plusargs("except_disable=%0d",except_disable))begin
        end
        if($value$plusargs("int_ack_disable=%0d",int_ack_disable))begin
        end
        if($test$plusargs("support_compress_design"))begin
            except_seq_cfg.disable_misalign_branch = 1;
        end
        if($test$plusargs("global_disable_ls"))begin
            global_disable_ls = 1;
            test_feature.push_back(LS_SEQ_DISABLE);
        end
        begin
            string layout_s;
            string hart_s;
            bit[63:0] base_h;
            if($value$plusargs("share_layout=%s",layout_s))begin
                case(layout_s)
                    "RAND_3CORE"  : ls_seq_cfg.share_layout = SHARE_RAND_3CORE;
                    "SW_PARTITION": ls_seq_cfg.share_layout = SHARE_SW_PARTITION;
                endcase
            end
            if($value$plusargs("hart=%s",hart_s))begin
                case(hart_s)
                    "MU" : ls_seq_cfg.hart = HART_MU;
                    "VU" : ls_seq_cfg.hart = HART_VU;
                    "DTE": ls_seq_cfg.hart = HART_DTE;
                endcase
            end
            if($value$plusargs("dtcm_base=%h",base_h))
                ls_seq_cfg.dtcm_base = base_h;
            if($value$plusargs("share_base=%h",base_h))
                ls_seq_cfg.share_base = base_h;
        end
        if(test_mode == INT_TEST) begin
            float_en = 0;
        end
        else if(test_mode == FP_TEST) begin
        end
        else if(test_mode == VECTOR_TEST) begin
            float_en = 0;
        end
       else begin
            float_en = 1;
        end

        if(!(RV64F inside support_inst_set) && !(RV64D inside support_inst_set)) float_en = 0;

        if(sim_mode == SPIKE_SIM || sim_mode == RISCV_TESTS_SIM)begin
            inst_gen_cfg.vmem_file_gen = 1'b0;
        end
        else begin
            vmem_file = $fopen(($psprintf("./test.vmem")),"w");
        end
        branch_seq_cfg.ls_inst_disable = global_disable_ls;
        safe_seq_cfg.ls_inst_disable = global_disable_ls;
        except_seq_cfg.ls_inst_disable = global_disable_ls;
        inst_gen_cfg.float_en     = float_en;
        ls_seq_cfg.float_en     = float_en;
        safe_seq_cfg.float_en   = float_en;

        inst_gen_cfg.gen_file = gen_file;
        inst_gen_cfg.vmem_file = vmem_file;
        inst_gen_cfg.support_inst_set = support_inst_set;
        inst_gen_cfg.support_prv_mode = support_prv_mode;
    endfunction

    function test_feature_convert();
        foreach(test_feature[i])begin
            if (test_feature[i] == SAFE_SEQ_DISABLE)    inst_seq_type_cfg.safe_seq_disable = 1'b1;
            if (test_feature[i] == BRANCH_SEQ_DISABLE)  inst_seq_type_cfg.branch_seq_disable = 1'b1;
            if (test_feature[i] == LS_SEQ_DISABLE)      inst_seq_type_cfg.ls_seq_disable = 1'b1;

            if (test_feature[i] == FLUSH_INST_ENABLE)    begin
                inst_seq_type_cfg.flush_seq_enable = 1'b1;
                branch_seq_cfg.flush_inst_enable = 1'b1;
                ls_seq_cfg.flush_inst_enable = 1'b1;
            end
            if (test_feature[i] == EXCEPT_INST_ENABLE)  begin
                except_disable = 1'b0;
                inst_seq_type_cfg.except_seq_enable = 1'b1;
                branch_seq_cfg.except_inst_enable = 1'b1;
                ls_seq_cfg.except_inst_enable = 1'b1;
            end
            if(test_feature[i] == INT_ACK_DISABLE)begin
                int_ack_disable = 1'b1;
            end
            if (test_feature[i] == WFI_INST_ENABLE)      begin
                inst_seq_type_cfg.wfi_seq_enable = 1'b1;
                branch_seq_cfg.wfi_inst_enable = 1'b1;
                ls_seq_cfg.wfi_inst_enable = 1'b1;
            end

            if (test_feature[i] == LS_BASE_INFO_CONFIRM)      ls_seq_cfg.base_confirm = 1'b1;

            if (test_feature[i] == GPR_FULL_VALID)      inst_gen_cfg.gpr_full_valid = 1'b1;
            if (test_feature[i] == FPR_FULL_VALID)      inst_gen_cfg.fpr_full_valid = 1'b1;
            if (test_feature[i] == DISABLE_4K_PAGE)     addr_space_cfg.page_size_dist[0] = 0;
            if (test_feature[i] == DISABLE_2M_PAGE)     addr_space_cfg.page_size_dist[0] = 0;
            if (test_feature[i] == DISABLE_1G_PAGE)     addr_space_cfg.page_size_dist[0] = 0;

        end
    endfunction
    function random_sub_config();
        assert(csr_cfg.randomize());
//        ls_seq_cfg.vlmul = csr_cfg.vlmul;// ls seq cfg vreg imm reg num depend on this, it should random first

        assert(safe_seq_cfg.randomize());
        assert(flush_seq_cfg.randomize());
        assert(except_seq_cfg.randomize());
        assert(branch_seq_cfg.randomize());
        assert(ls_seq_cfg.randomize());
        assert(inst_seq_type_cfg.randomize());

        assert(addr_space_cfg.randomize());
        ls_seq_cfg.ls_mode = csr_cfg.ls_mode;
        branch_seq_cfg.program_mode = csr_cfg.program_mode;

        addr_space_cfg.map_mode = csr_cfg.map_mode;
        csr_cfg.except_disable = except_disable;
        csr_cfg.int_ack_disable = int_ack_disable;
        begin
            int unsigned tn;
            if($value$plusargs("task_num=%d",tn))
                task_info.task_num = tn;
            else
                assert(task_info.randomize(task_num));
            task_info.init();
        end
    endfunction
endclass
