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
vrf_rd_index_val = 32'h00000000;
vrf_rd_index = vrf_rd_index_val;
vrf_wt_index_val = 32'h00000000;
vrf_wt_index = vrf_wt_index_val;
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
foreach(prf_op[i]) begin
    prf_op_val[i] = 32'h00000000;
    prf_op[i] = prf_op_val[i];
end
foreach(static_type_vl[i]) begin
    static_type_vl_val[i] = 32'h00000000;
    static_type_vl[i] = static_type_vl_val[i];
end
foreach(static_vrf_rd_index[i]) begin
    static_vrf_rd_index_val[i] = 32'h00000000;
    static_vrf_rd_index[i] = static_vrf_rd_index_val[i];
end
foreach(static_vrf_wt_index[i]) begin
    static_vrf_wt_index_val[i] = 32'h00000000;
    static_vrf_wt_index[i] = static_vrf_wt_index_val[i];
end
reg_file_addr_val = 32'h00000000;
reg_file_addr = reg_file_addr_val;
exec_param.config_idx = '0;
exec_param.type_vl.vl = '0;
exec_param.type_vl.data_type = '0;
exec_param.type_vl.round_mode = '0;
exec_param.type_vl.src = PARAM_STATIC;
exec_param.vrf_rd_index.vrf_rd_p0_idx = '0;
exec_param.vrf_rd_index.vrf_rd_p1_idx = '0;
exec_param.vrf_rd_index.src = PARAM_STATIC;
exec_param.vrf_wt_index.vrf_wt_p0_idx = '0;
exec_param.vrf_wt_index.vrf_wt_p1_idx = '0;
exec_param.vrf_wt_index.src = PARAM_STATIC;
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
exec_param.prf_op.vrf_wt_p0_src = '0;
exec_param.prf_op.vrf_wt_p1_src = '0;
exec_param.prf_op.mrf_wt_src = '0;
exec_param.prf_op.srf_wt_en = '0;
trigger_pending = 1'b0;
