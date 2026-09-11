// AUTO-GENERATED from vu_mmio.json. DO NOT EDIT.

foreach(vrf[i]) vrf[i] = '0;
foreach(mrf[i]) mrf[i] = '0;
foreach(srf[i]) srf[i] = '0;
lu_bypass = '0;
valu0_bypass = '0;
valu1_bypass = '0;
valu2_bypass = '0;
vsfu0_bypass = '0;
vsfu1_bypass = '0;
macro_inst_trigger_val = 32'h00000000;
macro_inst_trigger = macro_inst_trigger_val;
type_vl_val = 32'h00000000;
type_vl = type_vl_val;
ld_addr_val = 32'h00000000;
ld_addr = ld_addr_val;
st_addr_val = 32'h00000000;
st_addr = st_addr_val;
vrf_rd_index_val = 32'h00000000;
vrf_rd_index = vrf_rd_index_val;
vrf_wt_index_val = 32'h00000000;
vrf_wt_index = vrf_wt_index_val;
mrf_rd_index_val = 32'h00000000;
mrf_rd_index = mrf_rd_index_val;
mrf_wt_index_val = 32'h00000000;
mrf_wt_index = mrf_wt_index_val;
srf_rd_index_0_val = 32'h00000000;
srf_rd_index_0 = srf_rd_index_0_val;
srf_rd_index_1_val = 32'h00000000;
srf_rd_index_1 = srf_rd_index_1_val;
srf_wt_index_0_val = 32'h00000000;
srf_wt_index_0 = srf_wt_index_0_val;
srf_wt_index_1_val = 32'h00000000;
srf_wt_index_1 = srf_wt_index_1_val;
foreach(lu_op[i]) begin
    lu_op_val[i] = 32'h00000000;
    lu_op[i] = lu_op_val[i];
end
foreach(su_op[i]) begin
    su_op_val[i] = 32'h00000000;
    su_op[i] = su_op_val[i];
end
foreach(valu0_op[i]) begin
    valu0_op_val[i] = 32'h00000000;
    valu0_op[i] = valu0_op_val[i];
end
foreach(valu1_op[i]) begin
    valu1_op_val[i] = 32'h00000000;
    valu1_op[i] = valu1_op_val[i];
end
foreach(valu2_op[i]) begin
    valu2_op_val[i] = 32'h00000000;
    valu2_op[i] = valu2_op_val[i];
end
foreach(vsfu_op[i]) begin
    vsfu_op_val[i] = 32'h00000000;
    vsfu_op[i] = vsfu_op_val[i];
end
foreach(mexe_op[i]) begin
    mexe_op_val[i] = 32'h00000000;
    mexe_op[i] = mexe_op_val[i];
end
foreach(sexe0_op[i]) begin
    sexe0_op_val[i] = 32'h00000000;
    sexe0_op[i] = sexe0_op_val[i];
end
foreach(sexe1_op[i]) begin
    sexe1_op_val[i] = 32'h00000000;
    sexe1_op[i] = sexe1_op_val[i];
end
foreach(sexe2_op[i]) begin
    sexe2_op_val[i] = 32'h00000000;
    sexe2_op[i] = sexe2_op_val[i];
end
foreach(mask_op[i]) begin
    mask_op_val[i] = 32'h00000000;
    mask_op[i] = mask_op_val[i];
end
foreach(prf_op[i]) begin
    prf_op_val[i] = 32'h00000000;
    prf_op[i] = prf_op_val[i];
end
foreach(static_type_vl[i]) begin
    static_type_vl_val[i] = 32'h00000000;
    static_type_vl[i] = static_type_vl_val[i];
end
foreach(static_ld_addr[i]) begin
    static_ld_addr_val[i] = 32'h00000000;
    static_ld_addr[i] = static_ld_addr_val[i];
end
foreach(static_st_addr[i]) begin
    static_st_addr_val[i] = 32'h00000000;
    static_st_addr[i] = static_st_addr_val[i];
end
foreach(static_vrf_rd_index[i]) begin
    static_vrf_rd_index_val[i] = 32'h00000000;
    static_vrf_rd_index[i] = static_vrf_rd_index_val[i];
end
foreach(static_vrf_wt_index[i]) begin
    static_vrf_wt_index_val[i] = 32'h00000000;
    static_vrf_wt_index[i] = static_vrf_wt_index_val[i];
end
foreach(static_mrf_rd_index[i]) begin
    static_mrf_rd_index_val[i] = 32'h00000000;
    static_mrf_rd_index[i] = static_mrf_rd_index_val[i];
end
foreach(static_mrf_wt_index[i]) begin
    static_mrf_wt_index_val[i] = 32'h00000000;
    static_mrf_wt_index[i] = static_mrf_wt_index_val[i];
end
foreach(static_srf_rd_index_0[i]) begin
    static_srf_rd_index_0_val[i] = 32'h00000000;
    static_srf_rd_index_0[i] = static_srf_rd_index_0_val[i];
end
foreach(static_srf_rd_index_1[i]) begin
    static_srf_rd_index_1_val[i] = 32'h00000000;
    static_srf_rd_index_1[i] = static_srf_rd_index_1_val[i];
end
foreach(static_srf_wt_index_0[i]) begin
    static_srf_wt_index_0_val[i] = 32'h00000000;
    static_srf_wt_index_0[i] = static_srf_wt_index_0_val[i];
end
foreach(static_srf_wt_index_1[i]) begin
    static_srf_wt_index_1_val[i] = 32'h00000000;
    static_srf_wt_index_1[i] = static_srf_wt_index_1_val[i];
end
reg_file_addr_val = 32'h00000000;
reg_file_addr = reg_file_addr_val;
macro_inst_left_val = 32'h00000000;
macro_inst_left = macro_inst_left_val;
status_val = 32'h00000000;
status = status_val;
error_code_val = 32'h00000000;
error_code = error_code_val;
error_info_val = 32'h00000000;
error_info = error_info_val;
snapshot_addr_val = 32'h00000000;
snapshot_addr = snapshot_addr_val;
snapshot_data_val = 32'h00000000;
snapshot_data = snapshot_data_val;
profile_ctrl_val = 32'h00000000;
profile_ctrl = profile_ctrl_val;
prof_run_cycle_lo_val = 32'h00000000;
prof_run_cycle_lo = prof_run_cycle_lo_val;
prof_run_cycle_hi_val = 32'h00000000;
prof_run_cycle_hi = prof_run_cycle_hi_val;
total_busy_cycle_lo_val = 32'h00000000;
total_busy_cycle_lo = total_busy_cycle_lo_val;
total_busy_cycle_hi_val = 32'h00000000;
total_busy_cycle_hi = total_busy_cycle_hi_val;
cfg_wr_num_lo_val = 32'h00000000;
cfg_wr_num_lo = cfg_wr_num_lo_val;
cfg_wr_num_hi_val = 32'h00000000;
cfg_wr_num_hi = cfg_wr_num_hi_val;
cfg_wr_stall_cycle_lo_val = 32'h00000000;
cfg_wr_stall_cycle_lo = cfg_wr_stall_cycle_lo_val;
cfg_wr_stall_cycle_hi_val = 32'h00000000;
cfg_wr_stall_cycle_hi = cfg_wr_stall_cycle_hi_val;
macro_inst_total_num_lo_val = 32'h00000000;
macro_inst_total_num_lo = macro_inst_total_num_lo_val;
macro_inst_total_num_hi_val = 32'h00000000;
macro_inst_total_num_hi = macro_inst_total_num_hi_val;
macro_inst_retire_num_lo_val = 32'h00000000;
macro_inst_retire_num_lo = macro_inst_retire_num_lo_val;
macro_inst_retire_num_hi_val = 32'h00000000;
macro_inst_retire_num_hi = macro_inst_retire_num_hi_val;
isq_full_cycle_lo_val = 32'h00000000;
isq_full_cycle_lo = isq_full_cycle_lo_val;
isq_full_cycle_hi_val = 32'h00000000;
isq_full_cycle_hi = isq_full_cycle_hi_val;
issue_stall_fence_cycle_lo_val = 32'h00000000;
issue_stall_fence_cycle_lo = issue_stall_fence_cycle_lo_val;
issue_stall_fence_cycle_hi_val = 32'h00000000;
issue_stall_fence_cycle_hi = issue_stall_fence_cycle_hi_val;
issue_stall_bcast_cycle_lo_val = 32'h00000000;
issue_stall_bcast_cycle_lo = issue_stall_bcast_cycle_lo_val;
issue_stall_bcast_cycle_hi_val = 32'h00000000;
issue_stall_bcast_cycle_hi = issue_stall_bcast_cycle_hi_val;
issue_stall_dep_cycle_lo_val = 32'h00000000;
issue_stall_dep_cycle_lo = issue_stall_dep_cycle_lo_val;
issue_stall_dep_cycle_hi_val = 32'h00000000;
issue_stall_dep_cycle_hi = issue_stall_dep_cycle_hi_val;
issue_stall_eu_cycle_lo_val = 32'h00000000;
issue_stall_eu_cycle_lo = issue_stall_eu_cycle_lo_val;
issue_stall_eu_cycle_hi_val = 32'h00000000;
issue_stall_eu_cycle_hi = issue_stall_eu_cycle_hi_val;
issue_starve_cycle_lo_val = 32'h00000000;
issue_starve_cycle_lo = issue_starve_cycle_lo_val;
issue_starve_cycle_hi_val = 32'h00000000;
issue_starve_cycle_hi = issue_starve_cycle_hi_val;
lu_busy_cycle_lo_val = 32'h00000000;
lu_busy_cycle_lo = lu_busy_cycle_lo_val;
lu_busy_cycle_hi_val = 32'h00000000;
lu_busy_cycle_hi = lu_busy_cycle_hi_val;
cm_ld_req_num_lo_val = 32'h00000000;
cm_ld_req_num_lo = cm_ld_req_num_lo_val;
cm_ld_req_num_hi_val = 32'h00000000;
cm_ld_req_num_hi = cm_ld_req_num_hi_val;
cm_ld_stall_cycle_lo_val = 32'h00000000;
cm_ld_stall_cycle_lo = cm_ld_stall_cycle_lo_val;
cm_ld_stall_cycle_hi_val = 32'h00000000;
cm_ld_stall_cycle_hi = cm_ld_stall_cycle_hi_val;
su_busy_cycle_lo_val = 32'h00000000;
su_busy_cycle_lo = su_busy_cycle_lo_val;
su_busy_cycle_hi_val = 32'h00000000;
su_busy_cycle_hi = su_busy_cycle_hi_val;
cm_st_req_num_lo_val = 32'h00000000;
cm_st_req_num_lo = cm_st_req_num_lo_val;
cm_st_req_num_hi_val = 32'h00000000;
cm_st_req_num_hi = cm_st_req_num_hi_val;
cm_st_stall_cycle_lo_val = 32'h00000000;
cm_st_stall_cycle_lo = cm_st_stall_cycle_lo_val;
cm_st_stall_cycle_hi_val = 32'h00000000;
cm_st_stall_cycle_hi = cm_st_stall_cycle_hi_val;
valu0_busy_cycle_lo_val = 32'h00000000;
valu0_busy_cycle_lo = valu0_busy_cycle_lo_val;
valu0_busy_cycle_hi_val = 32'h00000000;
valu0_busy_cycle_hi = valu0_busy_cycle_hi_val;
valu1_busy_cycle_lo_val = 32'h00000000;
valu1_busy_cycle_lo = valu1_busy_cycle_lo_val;
valu1_busy_cycle_hi_val = 32'h00000000;
valu1_busy_cycle_hi = valu1_busy_cycle_hi_val;
valu2_busy_cycle_lo_val = 32'h00000000;
valu2_busy_cycle_lo = valu2_busy_cycle_lo_val;
valu2_busy_cycle_hi_val = 32'h00000000;
valu2_busy_cycle_hi = valu2_busy_cycle_hi_val;
vsfu0_busy_cycle_lo_val = 32'h00000000;
vsfu0_busy_cycle_lo = vsfu0_busy_cycle_lo_val;
vsfu0_busy_cycle_hi_val = 32'h00000000;
vsfu0_busy_cycle_hi = vsfu0_busy_cycle_hi_val;
vsfu1_busy_cycle_lo_val = 32'h00000000;
vsfu1_busy_cycle_lo = vsfu1_busy_cycle_lo_val;
vsfu1_busy_cycle_hi_val = 32'h00000000;
vsfu1_busy_cycle_hi = vsfu1_busy_cycle_hi_val;
mexe_busy_cycle_lo_val = 32'h00000000;
mexe_busy_cycle_lo = mexe_busy_cycle_lo_val;
mexe_busy_cycle_hi_val = 32'h00000000;
mexe_busy_cycle_hi = mexe_busy_cycle_hi_val;
sexe_busy_cycle_lo_val = 32'h00000000;
sexe_busy_cycle_lo = sexe_busy_cycle_lo_val;
sexe_busy_cycle_hi_val = 32'h00000000;
sexe_busy_cycle_hi = sexe_busy_cycle_hi_val;
vrf_rd_p0_busy_cycle_lo_val = 32'h00000000;
vrf_rd_p0_busy_cycle_lo = vrf_rd_p0_busy_cycle_lo_val;
vrf_rd_p0_busy_cycle_hi_val = 32'h00000000;
vrf_rd_p0_busy_cycle_hi = vrf_rd_p0_busy_cycle_hi_val;
vrf_rd_p1_busy_cycle_lo_val = 32'h00000000;
vrf_rd_p1_busy_cycle_lo = vrf_rd_p1_busy_cycle_lo_val;
vrf_rd_p1_busy_cycle_hi_val = 32'h00000000;
vrf_rd_p1_busy_cycle_hi = vrf_rd_p1_busy_cycle_hi_val;
vrf_wt_p0_busy_cycle_lo_val = 32'h00000000;
vrf_wt_p0_busy_cycle_lo = vrf_wt_p0_busy_cycle_lo_val;
vrf_wt_p0_busy_cycle_hi_val = 32'h00000000;
vrf_wt_p0_busy_cycle_hi = vrf_wt_p0_busy_cycle_hi_val;
vrf_wt_p1_busy_cycle_lo_val = 32'h00000000;
vrf_wt_p1_busy_cycle_lo = vrf_wt_p1_busy_cycle_lo_val;
vrf_wt_p1_busy_cycle_hi_val = 32'h00000000;
vrf_wt_p1_busy_cycle_hi = vrf_wt_p1_busy_cycle_hi_val;
mrf_wt_busy_cycle_lo_val = 32'h00000000;
mrf_wt_busy_cycle_lo = mrf_wt_busy_cycle_lo_val;
mrf_wt_busy_cycle_hi_val = 32'h00000000;
mrf_wt_busy_cycle_hi = mrf_wt_busy_cycle_hi_val;
exec_param.config_idx = '0;
exec_param.type_vl.vl = '0;
exec_param.type_vl.data_type = '0;
exec_param.type_vl.round_mode = '0;
exec_param.type_vl.src = PARAM_STATIC;
exec_param.ld_addr.cm_addr = '0;
exec_param.ld_addr.src = PARAM_STATIC;
exec_param.st_addr.cm_addr = '0;
exec_param.st_addr.src = PARAM_STATIC;
exec_param.vrf_rd_index.vrf_rd_p0_idx = '0;
exec_param.vrf_rd_index.vrf_rd_p1_idx = '0;
exec_param.vrf_rd_index.src = PARAM_STATIC;
exec_param.vrf_wt_index.vrf_wt_p0_idx = '0;
exec_param.vrf_wt_index.vrf_wt_p1_idx = '0;
exec_param.vrf_wt_index.src = PARAM_STATIC;
exec_param.mrf_rd_index.mrf_rd_p0_idx = '0;
exec_param.mrf_rd_index.mrf_rd_p1_idx = '0;
exec_param.mrf_rd_index.src = PARAM_STATIC;
exec_param.mrf_wt_index.mrf_wt_idx = '0;
exec_param.mrf_wt_index.src = PARAM_STATIC;
exec_param.srf_rd_index_0.srf_rd_p0_idx = '0;
exec_param.srf_rd_index_0.srf_rd_p1_idx = '0;
exec_param.srf_rd_index_0.srf_rd_p2_idx = '0;
exec_param.srf_rd_index_0.srf_rd_p3_idx = '0;
exec_param.srf_rd_index_0.src = PARAM_STATIC;
exec_param.srf_rd_index_1.srf_rd_p4_idx = '0;
exec_param.srf_rd_index_1.srf_rd_p5_idx = '0;
exec_param.srf_rd_index_1.srf_rd_p6_idx = '0;
exec_param.srf_rd_index_1.srf_rd_p7_idx = '0;
exec_param.srf_rd_index_1.src = PARAM_STATIC;
exec_param.srf_wt_index_0.srf_wt_p0_idx = '0;
exec_param.srf_wt_index_0.srf_wt_p1_idx = '0;
exec_param.srf_wt_index_0.srf_wt_p2_idx = '0;
exec_param.srf_wt_index_0.srf_wt_p3_idx = '0;
exec_param.srf_wt_index_0.src = PARAM_STATIC;
exec_param.srf_wt_index_1.srf_wt_p4_idx = '0;
exec_param.srf_wt_index_1.srf_wt_p5_idx = '0;
exec_param.srf_wt_index_1.src = PARAM_STATIC;
exec_param.lu_op.opcode = '0;
exec_param.lu_op.stride_run = '0;
exec_param.lu_op.stride_skip = '0;
exec_param.su_op.opcode = '0;
exec_param.su_op.src_sel = '0;
exec_param.su_op.mxfp8_scale_round = '0;
exec_param.valu0_op.opcode = '0;
exec_param.valu0_op.src1_sel = '0;
exec_param.valu0_op.src2_sel = '0;
exec_param.valu0_op.src3_sel = '0;
exec_param.valu1_op.opcode = '0;
exec_param.valu1_op.src1_sel = '0;
exec_param.valu1_op.src2_sel = '0;
exec_param.valu1_op.src3_sel = '0;
exec_param.valu2_op.opcode = '0;
exec_param.valu2_op.src1_sel = '0;
exec_param.valu2_op.src2_sel = '0;
exec_param.valu2_op.src3_sel = '0;
exec_param.vsfu_op.vsfu0_opcode = '0;
exec_param.vsfu_op.vsfu0_src1_sel = '0;
exec_param.vsfu_op.vsfu1_opcode = '0;
exec_param.vsfu_op.vsfu1_src1_sel = '0;
exec_param.mexe_op.opcode = '0;
exec_param.mexe_op.src1_sel = '0;
exec_param.mexe_op.src2_sel = '0;
exec_param.sexe0_op.opcode = '0;
exec_param.sexe0_op.src1_sel = '0;
exec_param.sexe0_op.src2_sel = '0;
exec_param.sexe1_op.opcode = '0;
exec_param.sexe1_op.src1_sel = '0;
exec_param.sexe1_op.src2_sel = '0;
exec_param.sexe2_op.opcode = '0;
exec_param.sexe2_op.src1_sel = '0;
exec_param.sexe2_op.src2_sel = '0;
exec_param.mask_op.valu0_mask_sel = '0;
exec_param.mask_op.valu1_mask_sel = '0;
exec_param.mask_op.valu2_mask_sel = '0;
exec_param.prf_op.vrf_wt_p0_src = '0;
exec_param.prf_op.vrf_wt_p1_src = '0;
exec_param.prf_op.mrf_wt_src = '0;
exec_param.prf_op.srf_wt_en = '0;
trigger_pending = 1'b0;
