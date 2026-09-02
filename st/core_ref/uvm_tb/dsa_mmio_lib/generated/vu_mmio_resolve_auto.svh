// AUTO-GENERATED from vu_mmio.json. DO NOT EDIT.

exec_param.config_idx = macro_inst_trigger.config_idx;
if(macro_inst_trigger.static_dynamic_mask[0]) begin
    exec_param.type_vl.vl = type_vl.vl;
    exec_param.type_vl.data_type = type_vl.data_type;
    exec_param.type_vl.round_mode = type_vl.round_mode;
    exec_param.type_vl.src = PARAM_DYNAMIC;
end
else begin
    exec_param.type_vl.vl = static_type_vl[exec_param.config_idx].vl;
    exec_param.type_vl.data_type = static_type_vl[exec_param.config_idx].data_type;
    exec_param.type_vl.round_mode = static_type_vl[exec_param.config_idx].round_mode;
    exec_param.type_vl.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[3]) begin
    exec_param.vrf_rd_index.vrf_rd_p0_idx = vrf_rd_index.vrf_rd_p0_idx;
    exec_param.vrf_rd_index.vrf_rd_p1_idx = vrf_rd_index.vrf_rd_p1_idx;
    exec_param.vrf_rd_index.src = PARAM_DYNAMIC;
end
else begin
    exec_param.vrf_rd_index.vrf_rd_p0_idx = static_vrf_rd_index[exec_param.config_idx].vrf_rd_p0_idx;
    exec_param.vrf_rd_index.vrf_rd_p1_idx = static_vrf_rd_index[exec_param.config_idx].vrf_rd_p1_idx;
    exec_param.vrf_rd_index.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[4]) begin
    exec_param.vrf_wt_index.vrf_wt_p0_idx = vrf_wt_index.vrf_wt_p0_idx;
    exec_param.vrf_wt_index.vrf_wt_p1_idx = vrf_wt_index.vrf_wt_p1_idx;
    exec_param.vrf_wt_index.src = PARAM_DYNAMIC;
end
else begin
    exec_param.vrf_wt_index.vrf_wt_p0_idx = static_vrf_wt_index[exec_param.config_idx].vrf_wt_p0_idx;
    exec_param.vrf_wt_index.vrf_wt_p1_idx = static_vrf_wt_index[exec_param.config_idx].vrf_wt_p1_idx;
    exec_param.vrf_wt_index.src = PARAM_STATIC;
end
exec_param.valu0_op.opcode = valu0_op[exec_param.config_idx].opcode;
exec_param.valu0_op.src1_sel = valu0_op[exec_param.config_idx].src1_sel;
exec_param.valu0_op.src2_sel = valu0_op[exec_param.config_idx].src2_sel;
exec_param.valu0_op.src3_sel = valu0_op[exec_param.config_idx].src3_sel;
exec_param.valu1_op.opcode = valu1_op[exec_param.config_idx].opcode;
exec_param.valu1_op.src1_sel = valu1_op[exec_param.config_idx].src1_sel;
exec_param.valu1_op.src2_sel = valu1_op[exec_param.config_idx].src2_sel;
exec_param.valu1_op.src3_sel = valu1_op[exec_param.config_idx].src3_sel;
exec_param.valu2_op.opcode = valu2_op[exec_param.config_idx].opcode;
exec_param.valu2_op.src1_sel = valu2_op[exec_param.config_idx].src1_sel;
exec_param.valu2_op.src2_sel = valu2_op[exec_param.config_idx].src2_sel;
exec_param.valu2_op.src3_sel = valu2_op[exec_param.config_idx].src3_sel;
exec_param.prf_op.vrf_wt_p0_src = prf_op[exec_param.config_idx].vrf_wt_p0_src;
exec_param.prf_op.vrf_wt_p1_src = prf_op[exec_param.config_idx].vrf_wt_p1_src;
exec_param.prf_op.mrf_wt_src = prf_op[exec_param.config_idx].mrf_wt_src;
exec_param.prf_op.srf_wt_en = prf_op[exec_param.config_idx].srf_wt_en;
