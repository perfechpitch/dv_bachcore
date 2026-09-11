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
if(macro_inst_trigger.static_dynamic_mask[1]) begin
    exec_param.ld_addr.cm_addr = ld_addr.cm_addr;
    exec_param.ld_addr.src = PARAM_DYNAMIC;
end
else begin
    exec_param.ld_addr.cm_addr = static_ld_addr[exec_param.config_idx].cm_addr;
    exec_param.ld_addr.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[2]) begin
    exec_param.st_addr.cm_addr = st_addr.cm_addr;
    exec_param.st_addr.src = PARAM_DYNAMIC;
end
else begin
    exec_param.st_addr.cm_addr = static_st_addr[exec_param.config_idx].cm_addr;
    exec_param.st_addr.src = PARAM_STATIC;
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
if(macro_inst_trigger.static_dynamic_mask[5]) begin
    exec_param.mrf_rd_index.mrf_rd_p0_idx = mrf_rd_index.mrf_rd_p0_idx;
    exec_param.mrf_rd_index.mrf_rd_p1_idx = mrf_rd_index.mrf_rd_p1_idx;
    exec_param.mrf_rd_index.src = PARAM_DYNAMIC;
end
else begin
    exec_param.mrf_rd_index.mrf_rd_p0_idx = static_mrf_rd_index[exec_param.config_idx].mrf_rd_p0_idx;
    exec_param.mrf_rd_index.mrf_rd_p1_idx = static_mrf_rd_index[exec_param.config_idx].mrf_rd_p1_idx;
    exec_param.mrf_rd_index.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[5]) begin
    exec_param.mrf_wt_index.mrf_wt_idx = mrf_wt_index.mrf_wt_idx;
    exec_param.mrf_wt_index.src = PARAM_DYNAMIC;
end
else begin
    exec_param.mrf_wt_index.mrf_wt_idx = static_mrf_wt_index[exec_param.config_idx].mrf_wt_idx;
    exec_param.mrf_wt_index.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[6]) begin
    exec_param.srf_rd_index_0.srf_rd_p0_idx = srf_rd_index_0.srf_rd_p0_idx;
    exec_param.srf_rd_index_0.srf_rd_p1_idx = srf_rd_index_0.srf_rd_p1_idx;
    exec_param.srf_rd_index_0.srf_rd_p2_idx = srf_rd_index_0.srf_rd_p2_idx;
    exec_param.srf_rd_index_0.srf_rd_p3_idx = srf_rd_index_0.srf_rd_p3_idx;
    exec_param.srf_rd_index_0.src = PARAM_DYNAMIC;
end
else begin
    exec_param.srf_rd_index_0.srf_rd_p0_idx = static_srf_rd_index_0[exec_param.config_idx].srf_rd_p0_idx;
    exec_param.srf_rd_index_0.srf_rd_p1_idx = static_srf_rd_index_0[exec_param.config_idx].srf_rd_p1_idx;
    exec_param.srf_rd_index_0.srf_rd_p2_idx = static_srf_rd_index_0[exec_param.config_idx].srf_rd_p2_idx;
    exec_param.srf_rd_index_0.srf_rd_p3_idx = static_srf_rd_index_0[exec_param.config_idx].srf_rd_p3_idx;
    exec_param.srf_rd_index_0.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[6]) begin
    exec_param.srf_rd_index_1.srf_rd_p4_idx = srf_rd_index_1.srf_rd_p4_idx;
    exec_param.srf_rd_index_1.srf_rd_p5_idx = srf_rd_index_1.srf_rd_p5_idx;
    exec_param.srf_rd_index_1.srf_rd_p6_idx = srf_rd_index_1.srf_rd_p6_idx;
    exec_param.srf_rd_index_1.srf_rd_p7_idx = srf_rd_index_1.srf_rd_p7_idx;
    exec_param.srf_rd_index_1.src = PARAM_DYNAMIC;
end
else begin
    exec_param.srf_rd_index_1.srf_rd_p4_idx = static_srf_rd_index_1[exec_param.config_idx].srf_rd_p4_idx;
    exec_param.srf_rd_index_1.srf_rd_p5_idx = static_srf_rd_index_1[exec_param.config_idx].srf_rd_p5_idx;
    exec_param.srf_rd_index_1.srf_rd_p6_idx = static_srf_rd_index_1[exec_param.config_idx].srf_rd_p6_idx;
    exec_param.srf_rd_index_1.srf_rd_p7_idx = static_srf_rd_index_1[exec_param.config_idx].srf_rd_p7_idx;
    exec_param.srf_rd_index_1.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[6]) begin
    exec_param.srf_wt_index_0.srf_wt_p0_idx = srf_wt_index_0.srf_wt_p0_idx;
    exec_param.srf_wt_index_0.srf_wt_p1_idx = srf_wt_index_0.srf_wt_p1_idx;
    exec_param.srf_wt_index_0.srf_wt_p2_idx = srf_wt_index_0.srf_wt_p2_idx;
    exec_param.srf_wt_index_0.srf_wt_p3_idx = srf_wt_index_0.srf_wt_p3_idx;
    exec_param.srf_wt_index_0.src = PARAM_DYNAMIC;
end
else begin
    exec_param.srf_wt_index_0.srf_wt_p0_idx = static_srf_wt_index_0[exec_param.config_idx].srf_wt_p0_idx;
    exec_param.srf_wt_index_0.srf_wt_p1_idx = static_srf_wt_index_0[exec_param.config_idx].srf_wt_p1_idx;
    exec_param.srf_wt_index_0.srf_wt_p2_idx = static_srf_wt_index_0[exec_param.config_idx].srf_wt_p2_idx;
    exec_param.srf_wt_index_0.srf_wt_p3_idx = static_srf_wt_index_0[exec_param.config_idx].srf_wt_p3_idx;
    exec_param.srf_wt_index_0.src = PARAM_STATIC;
end
if(macro_inst_trigger.static_dynamic_mask[6]) begin
    exec_param.srf_wt_index_1.srf_wt_p4_idx = srf_wt_index_1.srf_wt_p4_idx;
    exec_param.srf_wt_index_1.srf_wt_p5_idx = srf_wt_index_1.srf_wt_p5_idx;
    exec_param.srf_wt_index_1.src = PARAM_DYNAMIC;
end
else begin
    exec_param.srf_wt_index_1.srf_wt_p4_idx = static_srf_wt_index_1[exec_param.config_idx].srf_wt_p4_idx;
    exec_param.srf_wt_index_1.srf_wt_p5_idx = static_srf_wt_index_1[exec_param.config_idx].srf_wt_p5_idx;
    exec_param.srf_wt_index_1.src = PARAM_STATIC;
end
exec_param.lu_op.opcode = lu_op[exec_param.config_idx].opcode;
exec_param.lu_op.stride_run = lu_op[exec_param.config_idx].stride_run;
exec_param.lu_op.stride_skip = lu_op[exec_param.config_idx].stride_skip;
exec_param.su_op.opcode = su_op[exec_param.config_idx].opcode;
exec_param.su_op.src_sel = su_op[exec_param.config_idx].src_sel;
exec_param.su_op.mxfp8_scale_round = su_op[exec_param.config_idx].mxfp8_scale_round;
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
exec_param.vsfu_op.vsfu0_opcode = vsfu_op[exec_param.config_idx].vsfu0_opcode;
exec_param.vsfu_op.vsfu0_src1_sel = vsfu_op[exec_param.config_idx].vsfu0_src1_sel;
exec_param.vsfu_op.vsfu1_opcode = vsfu_op[exec_param.config_idx].vsfu1_opcode;
exec_param.vsfu_op.vsfu1_src1_sel = vsfu_op[exec_param.config_idx].vsfu1_src1_sel;
exec_param.mexe_op.opcode = mexe_op[exec_param.config_idx].opcode;
exec_param.mexe_op.src1_sel = mexe_op[exec_param.config_idx].src1_sel;
exec_param.mexe_op.src2_sel = mexe_op[exec_param.config_idx].src2_sel;
exec_param.sexe0_op.opcode = sexe0_op[exec_param.config_idx].opcode;
exec_param.sexe0_op.src1_sel = sexe0_op[exec_param.config_idx].src1_sel;
exec_param.sexe0_op.src2_sel = sexe0_op[exec_param.config_idx].src2_sel;
exec_param.sexe1_op.opcode = sexe1_op[exec_param.config_idx].opcode;
exec_param.sexe1_op.src1_sel = sexe1_op[exec_param.config_idx].src1_sel;
exec_param.sexe1_op.src2_sel = sexe1_op[exec_param.config_idx].src2_sel;
exec_param.sexe2_op.opcode = sexe2_op[exec_param.config_idx].opcode;
exec_param.sexe2_op.src1_sel = sexe2_op[exec_param.config_idx].src1_sel;
exec_param.sexe2_op.src2_sel = sexe2_op[exec_param.config_idx].src2_sel;
exec_param.mask_op.valu0_mask_sel = mask_op[exec_param.config_idx].valu0_mask_sel;
exec_param.mask_op.valu1_mask_sel = mask_op[exec_param.config_idx].valu1_mask_sel;
exec_param.mask_op.valu2_mask_sel = mask_op[exec_param.config_idx].valu2_mask_sel;
exec_param.prf_op.vrf_wt_p0_src = prf_op[exec_param.config_idx].vrf_wt_p0_src;
exec_param.prf_op.vrf_wt_p1_src = prf_op[exec_param.config_idx].vrf_wt_p1_src;
exec_param.prf_op.mrf_wt_src = prf_op[exec_param.config_idx].mrf_wt_src;
exec_param.prf_op.srf_wt_en = prf_op[exec_param.config_idx].srf_wt_en;
