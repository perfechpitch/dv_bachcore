typedef enum{INT_TEST,FP_TEST,VECTOR_TEST,RAND_TEST}test_mode_e;
typedef enum{SAFE_SEQ_DISABLE,LS_SEQ_DISABLE,BRANCH_SEQ_DISABLE,FLUSH_INST_ENABLE,EXCEPT_INST_ENABLE,
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

    rand int unsigned seq_num = 'd100;
    int gen_file;
    int vmem_file;
    protected bit seq_weight_defaults_saved = 1'b0;
    protected int unsigned default_safe_seq_dist;
    protected int unsigned default_ls_seq_dist;
    protected int unsigned default_branch_seq_dist;
    protected int unsigned default_flush_seq_dist;
    protected int unsigned default_except_seq_dist;
    protected int unsigned default_c_seq_dist;
    protected bit          subseq_weight_defaults_saved = 1'b0;
    protected int unsigned default_safe_int_cal_dist;
    protected int unsigned default_safe_float_cal_dist;
    protected int unsigned default_safe_branch_dist;
    protected int unsigned default_safe_int_ls_dist;
    protected int unsigned default_safe_custom_dsa_dist;
    protected int unsigned default_ls_seq_type_dist[$];
    protected int unsigned default_branch_seq_type_dist[$];

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
        int loop_blt_weight_arg;
        int loop_custom_weight_arg;
        if($value$plusargs("xlen=%d", xlen_arg)) begin
            inst_gen_cfg.xlen = xlen_arg;
        end
        if(inst_gen_cfg.xlen != 32 && inst_gen_cfg.xlen != 64) begin
            `uvm_fatal("XLEN", $sformatf("Unsupported xlen=%0d; only 32 or 64 are legal", inst_gen_cfg.xlen))
        end
        if($test$plusargs("support_custom") && !(CUSTOM inside support_inst_set)) begin
            support_inst_set = new[support_inst_set.size()+1](support_inst_set);
            support_inst_set[support_inst_set.size()-1] = CUSTOM;
        end
        if($value$plusargs("loop_blt_weight=%d", loop_blt_weight_arg))
            branch_seq_cfg.loop_blt_weight = loop_blt_weight_arg;
        if($value$plusargs("loop_custom_weight=%d", loop_custom_weight_arg))
            branch_seq_cfg.loop_custom_weight = loop_custom_weight_arg;
        if(loop_blt_weight_arg < 0 || loop_custom_weight_arg < 0 ||
           (branch_seq_cfg.loop_blt_weight == 0 &&
            branch_seq_cfg.loop_custom_weight == 0))
            `uvm_fatal("LOOP_WEIGHT",
                       $sformatf("illegal loop weights: blt=%0d custom=%0d",
                                 branch_seq_cfg.loop_blt_weight,
                                 branch_seq_cfg.loop_custom_weight))
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
            if (test_feature[i] == LS_BASE_INFO_CONFIRM)      ls_seq_cfg.base_confirm = 1'b1;

            if (test_feature[i] == GPR_FULL_VALID)      inst_gen_cfg.gpr_full_valid = 1'b1;
            if (test_feature[i] == FPR_FULL_VALID)      inst_gen_cfg.fpr_full_valid = 1'b1;
            if (test_feature[i] == DISABLE_4K_PAGE)     addr_space_cfg.page_size_dist[0] = 0;
            if (test_feature[i] == DISABLE_2M_PAGE)     addr_space_cfg.page_size_dist[0] = 0;
            if (test_feature[i] == DISABLE_1G_PAGE)     addr_space_cfg.page_size_dist[0] = 0;

        end
    endfunction

    function int unsigned scenario_weight_value(scenario_weight_e weight);
        case(weight)
            WEIGHT_DISABLE: return 0;
            WEIGHT_LOW:     return 1;
            WEIGHT_MEDIUM:  return 4;
            WEIGHT_HIGH:    return 10;
            default: begin
                `uvm_fatal("SCENARIO_WEIGHT", "invalid scenario weight level")
                return 0;
            end
        endcase
    endfunction

    function void save_default_seq_weights();
        if(seq_weight_defaults_saved)
            return;
        default_safe_seq_dist   = inst_seq_type_cfg.safe_seq_dist;
        default_ls_seq_dist     = inst_seq_type_cfg.ls_seq_dist;
        default_branch_seq_dist = inst_seq_type_cfg.branch_seq_dist;
        default_flush_seq_dist  = inst_seq_type_cfg.flush_seq_dist;
        default_except_seq_dist = inst_seq_type_cfg.except_seq_dist;
        default_c_seq_dist      = inst_seq_type_cfg.c_seq_dist;
        seq_weight_defaults_saved = 1'b1;
    endfunction

    function void restore_default_seq_weights();
        save_default_seq_weights();
        inst_seq_type_cfg.safe_seq_dist   = default_safe_seq_dist;
        inst_seq_type_cfg.ls_seq_dist     = default_ls_seq_dist;
        inst_seq_type_cfg.branch_seq_dist = default_branch_seq_dist;
        inst_seq_type_cfg.flush_seq_dist  = default_flush_seq_dist;
        inst_seq_type_cfg.except_seq_dist = default_except_seq_dist;
        inst_seq_type_cfg.c_seq_dist      = default_c_seq_dist;
    endfunction

    function void save_default_subseq_weights();
        if(subseq_weight_defaults_saved)
            return;
        default_safe_int_cal_dist       = safe_seq_cfg.safe_int_cal_dist;
        default_safe_float_cal_dist     = safe_seq_cfg.safe_float_cal_dist;
        default_safe_branch_dist        = safe_seq_cfg.safe_branch_dist;
        default_safe_int_ls_dist        = safe_seq_cfg.safe_int_ls_dist;
        default_safe_custom_dsa_dist    = safe_seq_cfg.safe_custom_dsa_dist;
        default_ls_seq_type_dist        = ls_seq_cfg.ls_seq_type_dist;
        default_branch_seq_type_dist    = branch_seq_cfg.branch_seq_type_dist;
        subseq_weight_defaults_saved    = 1'b1;
    endfunction

    function void restore_default_subseq_weights();
        save_default_subseq_weights();
        safe_seq_cfg.safe_int_cal_dist       = default_safe_int_cal_dist;
        safe_seq_cfg.safe_float_cal_dist     = default_safe_float_cal_dist;
        safe_seq_cfg.safe_branch_dist        = default_safe_branch_dist;
        safe_seq_cfg.safe_int_ls_dist        = default_safe_int_ls_dist;
        safe_seq_cfg.safe_custom_dsa_dist    = default_safe_custom_dsa_dist;
        ls_seq_cfg.ls_seq_type_dist          = default_ls_seq_type_dist;
        branch_seq_cfg.branch_seq_type_dist  = default_branch_seq_type_dist;
    endfunction

    function bit scenario_subseq_type_enabled(scenario_subseq_type_e subseq_type);
        case(subseq_type)
            SCENARIO_SAFE_FLOAT_CAL:
                return safe_seq_cfg.float_en;
            SCENARIO_SAFE_INT_LS:
                return !safe_seq_cfg.ls_inst_disable;
            SCENARIO_SAFE_CUSTOM_DSA:
                return (CUSTOM inside support_inst_set);
            default:
                return 1'b1;
        endcase
    endfunction

    function void apply_scenario_subseq_weights(scenario_task_info task_info);
        int unsigned value;
        int unsigned safe_total;
        int unsigned ls_total;
        int unsigned branch_total;
        bit safe_configured;
        bit ls_configured;
        bit branch_configured;

        restore_default_subseq_weights();
        if(task_info.subseq_plan.size() == 0)
            return;

        safe_configured   = 1'b0;
        ls_configured     = 1'b0;
        branch_configured = 1'b0;

        foreach(task_info.subseq_plan[i]) begin
            case(task_info.subseq_plan[i].seq_type)
                SAFE_INST_SEQ:   safe_configured   = 1'b1;
                LS_INST_SEQ:     ls_configured     = 1'b1;
                BRANCH_INST_SEQ: branch_configured = 1'b1;
                default:
                    `uvm_fatal("SCENARIO_SUBSEQ_WEIGHT",
                               $sformatf("seq_type=%s has no scenario sub-sequence selector",
                                         task_info.subseq_plan[i].seq_type.name()))
            endcase
        end

        foreach(task_info.subseq_plan[i]) begin
            value = scenario_weight_value(task_info.subseq_plan[i].weight);
            if(value != 0 && !scenario_subseq_type_enabled(task_info.subseq_plan[i].subseq_type))
                `uvm_fatal("SCENARIO_SUBSEQ_WEIGHT",
                           $sformatf("task_id=%0d requests disabled subseq_type=%s",
                                     task_info.task_id,
                                     task_info.subseq_plan[i].subseq_type.name()))

            case(task_info.subseq_plan[i].subseq_type)
                SCENARIO_SAFE_INT_CAL:
                    safe_seq_cfg.safe_int_cal_dist = value;
                SCENARIO_SAFE_FLOAT_CAL:
                    safe_seq_cfg.safe_float_cal_dist = value;
                SCENARIO_SAFE_BRANCH:
                    safe_seq_cfg.safe_branch_dist = value;
                SCENARIO_SAFE_INT_LS:
                    safe_seq_cfg.safe_int_ls_dist = value;
                SCENARIO_SAFE_CUSTOM_DSA:
                    safe_seq_cfg.safe_custom_dsa_dist = value;
                SCENARIO_LS_RAND:
                    ls_seq_cfg.ls_seq_type_dist[0] = value;
                SCENARIO_LS_LINEAR:
                    ls_seq_cfg.ls_seq_type_dist[1] = value;
                SCENARIO_LS_MEMCPY:
                    ls_seq_cfg.ls_seq_type_dist[2] = value;
                SCENARIO_BRANCH_SINGLE:
                    branch_seq_cfg.branch_seq_type_dist[0] = value;
                SCENARIO_BRANCH_LOOP:
                    branch_seq_cfg.branch_seq_type_dist[1] = value;
                SCENARIO_BRANCH_JALR:
                    branch_seq_cfg.branch_seq_type_dist[2] = value;
            endcase

            `uvm_info("SCENARIO_SUBSEQ_WEIGHT",
                      $sformatf("task_id=%0d seq_type=%s subseq_type=%s preference=%s runtime_weight=%0d",
                                task_info.task_id,
                                task_info.subseq_plan[i].seq_type.name(),
                                task_info.subseq_plan[i].subseq_type.name(),
                                task_info.subseq_plan[i].weight.name(), value), UVM_LOW)
        end

        // Unconfigured child selectors keep their platform-randomized default.
        // Only an explicit entry overrides or disables one selector.
        safe_total = safe_seq_cfg.safe_int_cal_dist + safe_seq_cfg.safe_branch_dist;
        if(safe_seq_cfg.float_en)
            safe_total += safe_seq_cfg.safe_float_cal_dist;
        if(!safe_seq_cfg.ls_inst_disable)
            safe_total += safe_seq_cfg.safe_int_ls_dist;
        if(CUSTOM inside support_inst_set)
            safe_total += safe_seq_cfg.safe_custom_dsa_dist;
        ls_total = 0;
        foreach(ls_seq_cfg.ls_seq_type_dist[i])
            ls_total += ls_seq_cfg.ls_seq_type_dist[i];
        branch_total = 0;
        foreach(branch_seq_cfg.branch_seq_type_dist[i])
            branch_total += branch_seq_cfg.branch_seq_type_dist[i];

        if(safe_configured && safe_total == 0)
            `uvm_fatal("SCENARIO_SUBSEQ_WEIGHT",
                       $sformatf("task_id=%0d disables every SAFE sub-sequence", task_info.task_id))
        if(ls_configured && ls_total == 0)
            `uvm_fatal("SCENARIO_SUBSEQ_WEIGHT",
                       $sformatf("task_id=%0d disables every LS sub-sequence", task_info.task_id))
        if(branch_configured && branch_total == 0)
            `uvm_fatal("SCENARIO_SUBSEQ_WEIGHT",
                       $sformatf("task_id=%0d disables every BRANCH sub-sequence", task_info.task_id))
    endfunction

    function bit scenario_seq_type_enabled(inst_seq_type_e seq_type);
        case(seq_type)
            SAFE_INST_SEQ:
                return !inst_seq_type_cfg.safe_seq_disable;
            LS_INST_SEQ:
                return !inst_seq_type_cfg.ls_seq_disable;
            BRANCH_INST_SEQ:
                return !inst_seq_type_cfg.branch_seq_disable;
            FLUSH_INST_SEQ:
                return inst_seq_type_cfg.flush_seq_enable;
            EXCEPT_INST_SEQ:
                return inst_seq_type_cfg.except_seq_enable;
            C_INST_SEQ:
                return (RVC inside support_inst_set);
            default:
                return 1'b0;
        endcase
    endfunction

    // Single runtime path from scenario preferences to the generator configs.
    // The environment already shares these config object handles downstream.
    function void apply_scenario_seq_weights(scenario_task_info task_info);
        int unsigned value;
        int unsigned total_weight;

        restore_default_seq_weights();
        if(task_info.seq_select_mode == SCENARIO_SEQ_AUTO)
            return;
        if(task_info.seq_plan.size() == 0)
            return;

        foreach(task_info.seq_plan[i]) begin
            value = scenario_weight_value(task_info.seq_plan[i].weight);
            if((value != 0) && !scenario_seq_type_enabled(task_info.seq_plan[i].seq_type))
                `uvm_fatal("SCENARIO_WEIGHT",
                           $sformatf("task_id=%0d requests disabled seq_type=%s",
                                     task_info.task_id, task_info.seq_plan[i].seq_type.name()))
            case(task_info.seq_plan[i].seq_type)
                SAFE_INST_SEQ:   inst_seq_type_cfg.safe_seq_dist   = value;
                LS_INST_SEQ:     inst_seq_type_cfg.ls_seq_dist     = value;
                BRANCH_INST_SEQ: inst_seq_type_cfg.branch_seq_dist = value;
                FLUSH_INST_SEQ:  inst_seq_type_cfg.flush_seq_dist  = value;
                EXCEPT_INST_SEQ: inst_seq_type_cfg.except_seq_dist = value;
                C_INST_SEQ:      inst_seq_type_cfg.c_seq_dist      = value;
            endcase
            `uvm_info("SCENARIO_WEIGHT",
                      $sformatf("task_id=%0d seq_type=%s preference=%s runtime_weight=%0d",
                                task_info.task_id, task_info.seq_plan[i].seq_type.name(),
                                task_info.seq_plan[i].weight.name(), value), UVM_LOW)
        end

        // Unconfigured top-level selectors keep their platform-randomized
        // defaults. Only an explicit entry overrides or disables one type.
        total_weight = 0;
        if(scenario_seq_type_enabled(SAFE_INST_SEQ))
            total_weight += inst_seq_type_cfg.safe_seq_dist;
        if(scenario_seq_type_enabled(LS_INST_SEQ))
            total_weight += inst_seq_type_cfg.ls_seq_dist;
        if(scenario_seq_type_enabled(BRANCH_INST_SEQ))
            total_weight += inst_seq_type_cfg.branch_seq_dist;
        if(scenario_seq_type_enabled(FLUSH_INST_SEQ))
            total_weight += inst_seq_type_cfg.flush_seq_dist;
        if(scenario_seq_type_enabled(EXCEPT_INST_SEQ))
            total_weight += inst_seq_type_cfg.except_seq_dist;
        if(scenario_seq_type_enabled(C_INST_SEQ))
            total_weight += inst_seq_type_cfg.c_seq_dist;
        if(total_weight == 0)
            `uvm_fatal("SCENARIO_WEIGHT",
                       $sformatf("task_id=%0d disables every sequence type", task_info.task_id))
    endfunction

    function random_sub_config();
        assert(this.randomize(seq_num) with {seq_num inside {[1:100]};});
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
            if($value$plusargs("task_num=%d",tn)) begin
                if(!(tn inside {[1:8]}))
                    `uvm_fatal("TASK_INFO", $sformatf("+task_num=%0d is illegal; valid range is [1:8]", tn))
                task_info.task_num = tn;
            end
            else begin
                assert(task_info.randomize(task_num));
            end
            // Scenario flows own the global task map and task_info.log.
            if(!$test$plusargs("directed_seq_name") &&
               !$test$plusargs("random_scenario_name"))
                task_info.init();
        end
    endfunction
endclass
