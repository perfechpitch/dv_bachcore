// ============================================================================
// Filename             : inst_gen_case_sequence.sv
// Author               : kippy
// Created On           : 2026-6-25
// Last Modified        :
// Update Count         :
// Description          : case_type 场景 sequence，注册顺序对应 case_type 0~3
// Source               : fixed template (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after template updates.
// ============================================================================
`ifndef INST_GEN_CASE_SEQUENCE_SV
`define INST_GEN_CASE_SEQUENCE_SV
class inst_gen_case_base_sequence extends inst_gen_base_sequence;
    int unsigned case_type_id;
    inst_gen_base_seq_item inst_q[$];

    function new(string name = "inst_gen_case_base_sequence");
        super.new(name);
    endfunction

    protected function inst_gen_base_seq_item new_inst_tr(vu_inst_seq_item vu_inst);
        inst_gen_base_seq_item inst_tr;
        inst_tr = inst_gen_base_seq_item::type_id::create("inst_tr");
        inst_tr.inst_gen_cfg = p_sequencer.inst_gen_cfg;
        if (!inst_tr.randomize() with {
            inst inside {DSAWI, DSAW};
        }) begin
            `uvm_fatal(get_type_name(), "inst_tr randomize failed")
        end
        return inst_tr;
    endfunction
    protected function void push_inst_tr(
        ref inst_gen_base_seq_item inst_tr,
        input logic [31:0] addr,
        input logic [31:0] data
    );
        if (inst_tr.inst == DSAR) begin
            inst_tr.rs1_data = addr;
        end else if (inst_tr.inst == DSARI) begin
            inst_tr.imm = addr;
        end else begin
            inst_tr.rs1_data = data;
            if (inst_tr.inst == DSAWI) begin
                inst_tr.imm = addr;
            end else begin
                inst_tr.rs2_data = addr;
            end
        end
        inst_q.push_back(inst_tr);
    endfunction

    // vu_inst 随机化完成后，每个偏移寄存器生成一个 inst_tr 入队
    protected function void pack_vu_inst_to_tr(vu_inst_seq_item vu_inst);
        inst_gen_base_seq_item inst_tr;

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0004, vu_inst.pack_type_vl_reg(inst_tr.rs1_data)); // TYPE_VL 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0008, vu_inst.pack_ld_addr_reg(inst_tr.rs1_data)); // LD_addr 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h000C, vu_inst.pack_st_addr_reg(inst_tr.rs1_data)); // ST_addr 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0010, vu_inst.pack_vrf_rd_index_reg(inst_tr.rs1_data)); // VRF_rd_index 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0014, vu_inst.pack_vrf_wt_index_reg(inst_tr.rs1_data)); // VRF_wt_index 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0018, vu_inst.pack_mrf_rd_index_reg(inst_tr.rs1_data)); // MRF_rd_index 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h001C, vu_inst.pack_mrf_wt_index_reg(inst_tr.rs1_data)); // MRF_wt_index 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0020, vu_inst.pack_srf_rd_index_0_reg(inst_tr.rs1_data)); // SRF_rd_index_0 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0024, vu_inst.pack_srf_rd_index_1_reg(inst_tr.rs1_data)); // SRF_rd_index_1 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0028, vu_inst.pack_srf_wt_index_0_reg(inst_tr.rs1_data)); // SRF_wt_index_0 数据

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h002C, vu_inst.pack_srf_wt_index_1_reg(inst_tr.rs1_data)); // SRF_wt_index_1 数据

        for (int unsigned cfg_idx = 0; cfg_idx <= 7; cfg_idx++) begin
            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1000, vu_inst.pack_lu_op_reg(inst_tr.rs1_data)); // LU_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1000, inst_tr.rs1_data); // LU_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1004, vu_inst.pack_su_op_reg(inst_tr.rs1_data)); // SU_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1004, inst_tr.rs1_data); // SU_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1008, vu_inst.pack_valu0_op_reg(inst_tr.rs1_data)); // VALU0_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1008, inst_tr.rs1_data); // VALU0_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h100C, vu_inst.pack_valu1_op_reg(inst_tr.rs1_data)); // VALU1_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h100C, inst_tr.rs1_data); // VALU1_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1010, vu_inst.pack_valu2_op_reg(inst_tr.rs1_data)); // VALU2_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1010, inst_tr.rs1_data); // VALU2_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1014, vu_inst.pack_vsfu_op_reg(inst_tr.rs1_data)); // VSFU_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1014, inst_tr.rs1_data); // VSFU_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1018, vu_inst.pack_mexe_op_reg(inst_tr.rs1_data)); // MEXE_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1018, inst_tr.rs1_data); // MEXE_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h101C, vu_inst.pack_sexe0_op_reg(inst_tr.rs1_data)); // SEXE0_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h101C, inst_tr.rs1_data); // SEXE0_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1020, vu_inst.pack_sexe1_op_reg(inst_tr.rs1_data)); // SEXE1_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1020, inst_tr.rs1_data); // SEXE1_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1024, vu_inst.pack_sexe2_op_reg(inst_tr.rs1_data)); // SEXE2_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1024, inst_tr.rs1_data); // SEXE2_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1028, vu_inst.pack_mask_op_reg(inst_tr.rs1_data)); // mask_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1028, inst_tr.rs1_data); // mask_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h102C, vu_inst.pack_prf_op_reg(inst_tr.rs1_data)); // PRF_op 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h102C, inst_tr.rs1_data); // PRF_op 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1030, vu_inst.pack_static_type_vl_reg(inst_tr.rs1_data)); // static_TYPE_VL 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1030, inst_tr.rs1_data); // static_TYPE_VL 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1034, vu_inst.pack_static_ld_addr_reg(inst_tr.rs1_data)); // static_LD_addr 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1034, inst_tr.rs1_data); // static_LD_addr 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1038, vu_inst.pack_static_st_addr_reg(inst_tr.rs1_data)); // static_ST_addr 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1038, inst_tr.rs1_data); // static_ST_addr 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h103C, vu_inst.pack_static_vrf_rd_index_reg(inst_tr.rs1_data)); // static_VRF_rd_index 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h103C, inst_tr.rs1_data); // static_VRF_rd_index 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1040, vu_inst.pack_static_vrf_wt_index_reg(inst_tr.rs1_data)); // static_VRF_wt_index 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1040, inst_tr.rs1_data); // static_VRF_wt_index 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1044, vu_inst.pack_static_mrf_rd_index_reg(inst_tr.rs1_data)); // static_MRF_rd_index 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1044, inst_tr.rs1_data); // static_MRF_rd_index 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1048, vu_inst.pack_static_mrf_wt_index_reg(inst_tr.rs1_data)); // static_MRF_wt_index 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1048, inst_tr.rs1_data); // static_MRF_wt_index 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h104C, vu_inst.pack_static_srf_rd_index_0_reg(inst_tr.rs1_data)); // static_SRF_rd_index_0 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h104C, inst_tr.rs1_data); // static_SRF_rd_index_0 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1050, vu_inst.pack_static_srf_rd_index_1_reg(inst_tr.rs1_data)); // static_SRF_rd_index_1 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1050, inst_tr.rs1_data); // static_SRF_rd_index_1 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1054, vu_inst.pack_static_srf_wt_index_0_reg(inst_tr.rs1_data)); // static_SRF_wt_index_0 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1054, inst_tr.rs1_data); // static_SRF_wt_index_0 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1058, vu_inst.pack_static_srf_wt_index_1_reg(inst_tr.rs1_data)); // static_SRF_wt_index_1 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h1058, inst_tr.rs1_data); // static_SRF_wt_index_1 数据

            inst_tr = new_inst_tr(vu_inst);
            if (cfg_idx == vu_inst.macro_inst_trigger_config_idx)
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h105C, vu_inst.pack_inf_replace_value_reg(inst_tr.rs1_data)); // INF_REPLACE_VALUE 数据
            else
                push_inst_tr(inst_tr, (cfg_idx * 32'h100) + 32'h105C, inst_tr.rs1_data); // INF_REPLACE_VALUE 数据

        end

        inst_tr = new_inst_tr(vu_inst);
        push_inst_tr(inst_tr, 32'h0000, vu_inst.pack_macro_inst_trigger_reg(inst_tr.rs1_data)); // macro_inst_trigger 数据

    endfunction

    // 按 req.vu_inst_type / src_bypass 选择 cross_N(_bypass)_gen_seq_item
    virtual function void gen_vu_inst();
        vu_inst_seq_item vu_inst;

        case (req.vu_inst_type)
            CROSS_INST_1: begin
                cross_1_gen_seq_item vu_cross;
                vu_cross = cross_1_gen_seq_item::type_id::create("vu_inst");
                vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                if (!vu_cross.randomize()) begin
                    `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                end
                vu_inst = vu_cross;
            end
            CROSS_INST_2: begin
                if (req.src_bypass) begin
                    cross_2_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_2_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_2_gen_seq_item vu_cross;
                    vu_cross = cross_2_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_3: begin
                if (req.src_bypass) begin
                    cross_3_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_3_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_3_gen_seq_item vu_cross;
                    vu_cross = cross_3_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_4: begin
                if (req.src_bypass) begin
                    cross_4_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_4_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_4_gen_seq_item vu_cross;
                    vu_cross = cross_4_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_5: begin
                if (req.src_bypass) begin
                    cross_5_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_5_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_5_gen_seq_item vu_cross;
                    vu_cross = cross_5_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_6: begin
                if (req.src_bypass) begin
                    cross_6_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_6_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_6_gen_seq_item vu_cross;
                    vu_cross = cross_6_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_7: begin
                if (req.src_bypass) begin
                    cross_7_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_7_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_7_gen_seq_item vu_cross;
                    vu_cross = cross_7_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_8: begin
                if (req.src_bypass) begin
                    cross_8_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_8_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_8_gen_seq_item vu_cross;
                    vu_cross = cross_8_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_9: begin
                if (req.src_bypass) begin
                    cross_9_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_9_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_9_gen_seq_item vu_cross;
                    vu_cross = cross_9_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_10: begin
                if (req.src_bypass) begin
                    cross_10_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_10_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_10_gen_seq_item vu_cross;
                    vu_cross = cross_10_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            CROSS_INST_11: begin
                if (req.src_bypass) begin
                    cross_11_bypass_gen_seq_item vu_cross;
                    vu_cross = cross_11_bypass_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst bypass randomize failed")
                    end
                    vu_inst = vu_cross;
                end
                else begin
                    cross_11_gen_seq_item vu_cross;
                    vu_cross = cross_11_gen_seq_item::type_id::create("vu_inst");
                    vu_cross.inst_gen_cfg = p_sequencer.inst_gen_cfg;
                    if (!vu_cross.randomize()) begin
                        `uvm_fatal(get_type_name(), "vu_inst randomize failed")
                    end
                    vu_inst = vu_cross;
                end
            end
            default: begin
                `uvm_fatal(get_type_name(),
                    $sformatf("unsupported vu_inst_type: %0s", req.vu_inst_type.name()))
            end
        endcase

        pack_vu_inst_to_tr(vu_inst);
    endfunction

    protected function inst_gen_base_seq_item new_inst_tr_read(inst_gen_seq_item tr);
        inst_gen_base_seq_item inst_tr;
        inst_tr = inst_gen_base_seq_item::type_id::create("inst_tr");
        inst_tr.inst_gen_cfg = p_sequencer.inst_gen_cfg;
        if (!inst_tr.randomize() with {
            inst == tr.inst;
        }) begin
            `uvm_fatal(get_type_name(), "inst_tr read randomize failed")
        end
        return inst_tr;
    endfunction

    // 按 vu_dsa 寄存器分类分层随机读地址，结果写入 inst_q
    virtual function void gen_vu_read(inst_gen_seq_item tr);
        vu_reg_read_seq_item read_item;
        inst_gen_base_seq_item inst_tr;

        read_item = vu_reg_read_seq_item::type_id::create("read_item");
        read_item.inst_gen_cfg = p_sequencer.inst_gen_cfg;
        if (!read_item.randomize()) begin
            `uvm_fatal(get_type_name(), "vu_reg_read randomize failed")
        end

        inst_tr = new_inst_tr_read(tr);
        push_inst_tr(inst_tr, read_item.reg_read_addr, '0);
    endfunction

    protected function void push_tr_backup(inst_gen_seq_item tr);
        inst_gen_seq_item tr_bak;
        tr_bak = inst_gen_seq_item::type_id::create("tr_bak");
        tr_bak.copy(tr);
        inst_q.push_back(tr_bak);
    endfunction

    protected task send_inst_q();
        inst_gen_base_seq_item item;
        while (inst_q.size() > 0) begin
            item = inst_gen_base_seq_item::type_id::create("item");
            void'(item.copy(inst_q.pop_front()));
            `uvm_create(req)
            req.inst_gen_cfg = p_sequencer.inst_gen_cfg;
            if (!req.randomize()) begin
                `uvm_fatal(get_type_name(), "req randomize failed")
            end
            req.rs1_data = item.rs1_data;
            req.rs2_data = item.rs2_data;
            req.imm      = item.imm;
            req.inst     = item.inst;
            `uvm_send(req)
        end
    endtask

    task rand_send_tr();
        inst_q.delete();
        `uvm_create(req)
        req.inst_gen_cfg = p_sequencer.inst_gen_cfg;
        if (!req.randomize()) begin
            `uvm_fatal(get_type_name(), "req randomize failed")
        end
        if (req.inst_type == VU_INST) begin
            if (req.inst inside {DSAW, DSAWI}) begin
                gen_vu_inst();
            end else if (req.inst inside {DSAR, DSARI}) begin
                gen_vu_read(req);
            end else begin
                `uvm_error(get_type_name(), $sformatf("unsupported VU inst: %0s", req.inst.name()))
            end
        end else begin
            push_tr_backup(req);
        end
        send_inst_q();
    endtask
endclass : inst_gen_case_base_sequence

class inst_gen_sequence extends inst_gen_case_base_sequence;
    `uvm_object_utils(inst_gen_sequence)
    `uvm_add_to_seq_lib(inst_gen_sequence, inst_gen_seq_lib)

    function new(string name = "inst_gen_sequence");
        super.new(name);
        case_type_id = 0;
    endfunction

    virtual task body();
        rand_send_tr();
    endtask
endclass : inst_gen_sequence

class fix_moe_sequence extends inst_gen_case_base_sequence;
    `uvm_object_utils(fix_moe_sequence)
    `uvm_add_to_seq_lib(fix_moe_sequence, inst_gen_seq_lib)

    function new(string name = "fix_moe_sequence");
        super.new(name);
        case_type_id = 1;
    endfunction

    virtual task body();//pending，continue when inst make sure
        p_sequencer.inst_gen_cfg.fix_inst_type_en = 1;
        p_sequencer.inst_gen_cfg.inst_type = MU_INST;
        rand_send_tr();
        p_sequencer.inst_gen_cfg.inst_type = VU_INST;
        rand_send_tr();
    endtask
endclass : inst_gen_case0_sequence

class fix_moe_reduction_sequence extends inst_gen_case_base_sequence;
    `uvm_object_utils(fix_moe_reduction_sequence)
    `uvm_add_to_seq_lib(fix_moe_reduction_sequence, inst_gen_seq_lib)

    function new(string name = "fix_moe_reduction_sequence");
        super.new(name);
        case_type_id = 2;
    endfunction

    virtual task body();//pending，continue when inst make sure
        p_sequencer.inst_gen_cfg.fix_inst_type_en = 1;
        p_sequencer.inst_gen_cfg.inst_type = MU_INST;
        rand_send_tr();
        p_sequencer.inst_gen_cfg.fix_inst_type_en = 1;
        p_sequencer.inst_gen_cfg.inst_type = VU_INST;
        rand_send_tr();
    endtask
endclass : fix_moe_reduction_sequence

class fix_fc0_sequence extends inst_gen_case_base_sequence;
    `uvm_object_utils(fix_fc0_sequence)
    `uvm_add_to_seq_lib(fix_fc0_sequence, inst_gen_seq_lib)

    function new(string name = "fix_fc0_sequence");
        super.new(name);
        case_type_id = 3;
    endfunction

    virtual task body();//pending，continue when inst make sure
        p_sequencer.inst_gen_cfg.fix_inst_type_en = 1;
        p_sequencer.inst_gen_cfg.inst_type = MU_INST;
        rand_send_tr();
        p_sequencer.inst_gen_cfg.fix_inst_type_en = 1;
        p_sequencer.inst_gen_cfg.inst_type = VU_INST;
        rand_send_tr();
    endtask
endclass : fix_fc0_sequence
`endif
