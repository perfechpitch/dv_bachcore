// AUTO-GENERATED from vu_mmio.json. DO NOT EDIT.

if(!mmio_hit && (addr == MACRO_INST_TRIGGER_BASE_ADDR)) begin
    macro_inst_trigger_val = data;
    macro_inst_trigger = data;
    inst_trigger = 1'b1;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == TYPE_VL_BASE_ADDR)) begin
    type_vl_val = data;
    type_vl = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == LD_ADDR_BASE_ADDR)) begin
    ld_addr_val = data;
    ld_addr = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ST_ADDR_BASE_ADDR)) begin
    st_addr_val = data;
    st_addr = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_RD_INDEX_BASE_ADDR)) begin
    vrf_rd_index_val = data;
    vrf_rd_index = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_WT_INDEX_BASE_ADDR)) begin
    vrf_wt_index_val = data;
    vrf_wt_index = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MRF_RD_INDEX_BASE_ADDR)) begin
    mrf_rd_index_val = data;
    mrf_rd_index = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MRF_WT_INDEX_BASE_ADDR)) begin
    mrf_wt_index_val = data;
    mrf_wt_index = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SRF_RD_INDEX_0_BASE_ADDR)) begin
    srf_rd_index_0_val = data;
    srf_rd_index_0 = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SRF_RD_INDEX_1_BASE_ADDR)) begin
    srf_rd_index_1_val = data;
    srf_rd_index_1 = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SRF_WT_INDEX_0_BASE_ADDR)) begin
    srf_wt_index_0_val = data;
    srf_wt_index_0 = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SRF_WT_INDEX_1_BASE_ADDR)) begin
    srf_wt_index_1_val = data;
    srf_wt_index_1 = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= LU_OP_BASE_ADDR) && (addr <= LU_OP_END_ADDR) && (((addr - LU_OP_BASE_ADDR) % LU_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - LU_OP_BASE_ADDR) / LU_OP_STRIDE;
    lu_op_val[reg_idx] = data;
    lu_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= SU_OP_BASE_ADDR) && (addr <= SU_OP_END_ADDR) && (((addr - SU_OP_BASE_ADDR) % SU_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - SU_OP_BASE_ADDR) / SU_OP_STRIDE;
    su_op_val[reg_idx] = data;
    su_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= VALU0_OP_BASE_ADDR) && (addr <= VALU0_OP_END_ADDR) && (((addr - VALU0_OP_BASE_ADDR) % VALU0_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - VALU0_OP_BASE_ADDR) / VALU0_OP_STRIDE;
    valu0_op_val[reg_idx] = data;
    valu0_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= VALU1_OP_BASE_ADDR) && (addr <= VALU1_OP_END_ADDR) && (((addr - VALU1_OP_BASE_ADDR) % VALU1_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - VALU1_OP_BASE_ADDR) / VALU1_OP_STRIDE;
    valu1_op_val[reg_idx] = data;
    valu1_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= VALU2_OP_BASE_ADDR) && (addr <= VALU2_OP_END_ADDR) && (((addr - VALU2_OP_BASE_ADDR) % VALU2_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - VALU2_OP_BASE_ADDR) / VALU2_OP_STRIDE;
    valu2_op_val[reg_idx] = data;
    valu2_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= VSFU_OP_BASE_ADDR) && (addr <= VSFU_OP_END_ADDR) && (((addr - VSFU_OP_BASE_ADDR) % VSFU_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - VSFU_OP_BASE_ADDR) / VSFU_OP_STRIDE;
    vsfu_op_val[reg_idx] = data;
    vsfu_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= MEXE_OP_BASE_ADDR) && (addr <= MEXE_OP_END_ADDR) && (((addr - MEXE_OP_BASE_ADDR) % MEXE_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - MEXE_OP_BASE_ADDR) / MEXE_OP_STRIDE;
    mexe_op_val[reg_idx] = data;
    mexe_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= SEXE0_OP_BASE_ADDR) && (addr <= SEXE0_OP_END_ADDR) && (((addr - SEXE0_OP_BASE_ADDR) % SEXE0_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - SEXE0_OP_BASE_ADDR) / SEXE0_OP_STRIDE;
    sexe0_op_val[reg_idx] = data;
    sexe0_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= SEXE1_OP_BASE_ADDR) && (addr <= SEXE1_OP_END_ADDR) && (((addr - SEXE1_OP_BASE_ADDR) % SEXE1_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - SEXE1_OP_BASE_ADDR) / SEXE1_OP_STRIDE;
    sexe1_op_val[reg_idx] = data;
    sexe1_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= SEXE2_OP_BASE_ADDR) && (addr <= SEXE2_OP_END_ADDR) && (((addr - SEXE2_OP_BASE_ADDR) % SEXE2_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - SEXE2_OP_BASE_ADDR) / SEXE2_OP_STRIDE;
    sexe2_op_val[reg_idx] = data;
    sexe2_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= MASK_OP_BASE_ADDR) && (addr <= MASK_OP_END_ADDR) && (((addr - MASK_OP_BASE_ADDR) % MASK_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - MASK_OP_BASE_ADDR) / MASK_OP_STRIDE;
    mask_op_val[reg_idx] = data;
    mask_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= PRF_OP_BASE_ADDR) && (addr <= PRF_OP_END_ADDR) && (((addr - PRF_OP_BASE_ADDR) % PRF_OP_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - PRF_OP_BASE_ADDR) / PRF_OP_STRIDE;
    prf_op_val[reg_idx] = data;
    prf_op[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_TYPE_VL_BASE_ADDR) && (addr <= STATIC_TYPE_VL_END_ADDR) && (((addr - STATIC_TYPE_VL_BASE_ADDR) % STATIC_TYPE_VL_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_TYPE_VL_BASE_ADDR) / STATIC_TYPE_VL_STRIDE;
    static_type_vl_val[reg_idx] = data;
    static_type_vl[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_LD_ADDR_BASE_ADDR) && (addr <= STATIC_LD_ADDR_END_ADDR) && (((addr - STATIC_LD_ADDR_BASE_ADDR) % STATIC_LD_ADDR_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_LD_ADDR_BASE_ADDR) / STATIC_LD_ADDR_STRIDE;
    static_ld_addr_val[reg_idx] = data;
    static_ld_addr[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_ST_ADDR_BASE_ADDR) && (addr <= STATIC_ST_ADDR_END_ADDR) && (((addr - STATIC_ST_ADDR_BASE_ADDR) % STATIC_ST_ADDR_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_ST_ADDR_BASE_ADDR) / STATIC_ST_ADDR_STRIDE;
    static_st_addr_val[reg_idx] = data;
    static_st_addr[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_VRF_RD_INDEX_BASE_ADDR) && (addr <= STATIC_VRF_RD_INDEX_END_ADDR) && (((addr - STATIC_VRF_RD_INDEX_BASE_ADDR) % STATIC_VRF_RD_INDEX_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_VRF_RD_INDEX_BASE_ADDR) / STATIC_VRF_RD_INDEX_STRIDE;
    static_vrf_rd_index_val[reg_idx] = data;
    static_vrf_rd_index[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_VRF_WT_INDEX_BASE_ADDR) && (addr <= STATIC_VRF_WT_INDEX_END_ADDR) && (((addr - STATIC_VRF_WT_INDEX_BASE_ADDR) % STATIC_VRF_WT_INDEX_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_VRF_WT_INDEX_BASE_ADDR) / STATIC_VRF_WT_INDEX_STRIDE;
    static_vrf_wt_index_val[reg_idx] = data;
    static_vrf_wt_index[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_MRF_RD_INDEX_BASE_ADDR) && (addr <= STATIC_MRF_RD_INDEX_END_ADDR) && (((addr - STATIC_MRF_RD_INDEX_BASE_ADDR) % STATIC_MRF_RD_INDEX_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_MRF_RD_INDEX_BASE_ADDR) / STATIC_MRF_RD_INDEX_STRIDE;
    static_mrf_rd_index_val[reg_idx] = data;
    static_mrf_rd_index[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_MRF_WT_INDEX_BASE_ADDR) && (addr <= STATIC_MRF_WT_INDEX_END_ADDR) && (((addr - STATIC_MRF_WT_INDEX_BASE_ADDR) % STATIC_MRF_WT_INDEX_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_MRF_WT_INDEX_BASE_ADDR) / STATIC_MRF_WT_INDEX_STRIDE;
    static_mrf_wt_index_val[reg_idx] = data;
    static_mrf_wt_index[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_SRF_RD_INDEX_0_BASE_ADDR) && (addr <= STATIC_SRF_RD_INDEX_0_END_ADDR) && (((addr - STATIC_SRF_RD_INDEX_0_BASE_ADDR) % STATIC_SRF_RD_INDEX_0_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_SRF_RD_INDEX_0_BASE_ADDR) / STATIC_SRF_RD_INDEX_0_STRIDE;
    static_srf_rd_index_0_val[reg_idx] = data;
    static_srf_rd_index_0[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_SRF_RD_INDEX_1_BASE_ADDR) && (addr <= STATIC_SRF_RD_INDEX_1_END_ADDR) && (((addr - STATIC_SRF_RD_INDEX_1_BASE_ADDR) % STATIC_SRF_RD_INDEX_1_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_SRF_RD_INDEX_1_BASE_ADDR) / STATIC_SRF_RD_INDEX_1_STRIDE;
    static_srf_rd_index_1_val[reg_idx] = data;
    static_srf_rd_index_1[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_SRF_WT_INDEX_0_BASE_ADDR) && (addr <= STATIC_SRF_WT_INDEX_0_END_ADDR) && (((addr - STATIC_SRF_WT_INDEX_0_BASE_ADDR) % STATIC_SRF_WT_INDEX_0_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_SRF_WT_INDEX_0_BASE_ADDR) / STATIC_SRF_WT_INDEX_0_STRIDE;
    static_srf_wt_index_0_val[reg_idx] = data;
    static_srf_wt_index_0[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && ((addr >= STATIC_SRF_WT_INDEX_1_BASE_ADDR) && (addr <= STATIC_SRF_WT_INDEX_1_END_ADDR) && (((addr - STATIC_SRF_WT_INDEX_1_BASE_ADDR) % STATIC_SRF_WT_INDEX_1_STRIDE) == 0))) begin
    int unsigned reg_idx;
    reg_idx = (addr - STATIC_SRF_WT_INDEX_1_BASE_ADDR) / STATIC_SRF_WT_INDEX_1_STRIDE;
    static_srf_wt_index_1_val[reg_idx] = data;
    static_srf_wt_index_1[reg_idx] = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == REG_FILE_ADDR_BASE_ADDR)) begin
    reg_file_addr_val = data;
    reg_file_addr = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MACRO_INST_LEFT_BASE_ADDR)) begin
    macro_inst_left_val = data;
    macro_inst_left = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == STATUS_BASE_ADDR)) begin
    status_val = data;
    status = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ERROR_CODE_BASE_ADDR)) begin
    error_code_val = data;
    error_code = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ERROR_INFO_BASE_ADDR)) begin
    error_info_val = data;
    error_info = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SNAPSHOT_ADDR_BASE_ADDR)) begin
    snapshot_addr_val = data;
    snapshot_addr = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SNAPSHOT_DATA_BASE_ADDR)) begin
    snapshot_data_val = data;
    snapshot_data = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == PROFILE_CTRL_BASE_ADDR)) begin
    profile_ctrl_val = data;
    profile_ctrl = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == PROF_RUN_CYCLE_LO_BASE_ADDR)) begin
    prof_run_cycle_lo_val = data;
    prof_run_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == PROF_RUN_CYCLE_HI_BASE_ADDR)) begin
    prof_run_cycle_hi_val = data;
    prof_run_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == TOTAL_BUSY_CYCLE_LO_BASE_ADDR)) begin
    total_busy_cycle_lo_val = data;
    total_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == TOTAL_BUSY_CYCLE_HI_BASE_ADDR)) begin
    total_busy_cycle_hi_val = data;
    total_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CFG_WR_NUM_LO_BASE_ADDR)) begin
    cfg_wr_num_lo_val = data;
    cfg_wr_num_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CFG_WR_NUM_HI_BASE_ADDR)) begin
    cfg_wr_num_hi_val = data;
    cfg_wr_num_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CFG_WR_STALL_CYCLE_LO_BASE_ADDR)) begin
    cfg_wr_stall_cycle_lo_val = data;
    cfg_wr_stall_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CFG_WR_STALL_CYCLE_HI_BASE_ADDR)) begin
    cfg_wr_stall_cycle_hi_val = data;
    cfg_wr_stall_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MACRO_INST_TOTAL_NUM_LO_BASE_ADDR)) begin
    macro_inst_total_num_lo_val = data;
    macro_inst_total_num_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MACRO_INST_TOTAL_NUM_HI_BASE_ADDR)) begin
    macro_inst_total_num_hi_val = data;
    macro_inst_total_num_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MACRO_INST_RETIRE_NUM_LO_BASE_ADDR)) begin
    macro_inst_retire_num_lo_val = data;
    macro_inst_retire_num_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MACRO_INST_RETIRE_NUM_HI_BASE_ADDR)) begin
    macro_inst_retire_num_hi_val = data;
    macro_inst_retire_num_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISQ_FULL_CYCLE_LO_BASE_ADDR)) begin
    isq_full_cycle_lo_val = data;
    isq_full_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISQ_FULL_CYCLE_HI_BASE_ADDR)) begin
    isq_full_cycle_hi_val = data;
    isq_full_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_FENCE_CYCLE_LO_BASE_ADDR)) begin
    issue_stall_fence_cycle_lo_val = data;
    issue_stall_fence_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_FENCE_CYCLE_HI_BASE_ADDR)) begin
    issue_stall_fence_cycle_hi_val = data;
    issue_stall_fence_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_BCAST_CYCLE_LO_BASE_ADDR)) begin
    issue_stall_bcast_cycle_lo_val = data;
    issue_stall_bcast_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_BCAST_CYCLE_HI_BASE_ADDR)) begin
    issue_stall_bcast_cycle_hi_val = data;
    issue_stall_bcast_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_DEP_CYCLE_LO_BASE_ADDR)) begin
    issue_stall_dep_cycle_lo_val = data;
    issue_stall_dep_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_DEP_CYCLE_HI_BASE_ADDR)) begin
    issue_stall_dep_cycle_hi_val = data;
    issue_stall_dep_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_EU_CYCLE_LO_BASE_ADDR)) begin
    issue_stall_eu_cycle_lo_val = data;
    issue_stall_eu_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STALL_EU_CYCLE_HI_BASE_ADDR)) begin
    issue_stall_eu_cycle_hi_val = data;
    issue_stall_eu_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STARVE_CYCLE_LO_BASE_ADDR)) begin
    issue_starve_cycle_lo_val = data;
    issue_starve_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == ISSUE_STARVE_CYCLE_HI_BASE_ADDR)) begin
    issue_starve_cycle_hi_val = data;
    issue_starve_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == LU_BUSY_CYCLE_LO_BASE_ADDR)) begin
    lu_busy_cycle_lo_val = data;
    lu_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == LU_BUSY_CYCLE_HI_BASE_ADDR)) begin
    lu_busy_cycle_hi_val = data;
    lu_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_LD_REQ_NUM_LO_BASE_ADDR)) begin
    cm_ld_req_num_lo_val = data;
    cm_ld_req_num_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_LD_REQ_NUM_HI_BASE_ADDR)) begin
    cm_ld_req_num_hi_val = data;
    cm_ld_req_num_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_LD_STALL_CYCLE_LO_BASE_ADDR)) begin
    cm_ld_stall_cycle_lo_val = data;
    cm_ld_stall_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_LD_STALL_CYCLE_HI_BASE_ADDR)) begin
    cm_ld_stall_cycle_hi_val = data;
    cm_ld_stall_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SU_BUSY_CYCLE_LO_BASE_ADDR)) begin
    su_busy_cycle_lo_val = data;
    su_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SU_BUSY_CYCLE_HI_BASE_ADDR)) begin
    su_busy_cycle_hi_val = data;
    su_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_ST_REQ_NUM_LO_BASE_ADDR)) begin
    cm_st_req_num_lo_val = data;
    cm_st_req_num_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_ST_REQ_NUM_HI_BASE_ADDR)) begin
    cm_st_req_num_hi_val = data;
    cm_st_req_num_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_ST_STALL_CYCLE_LO_BASE_ADDR)) begin
    cm_st_stall_cycle_lo_val = data;
    cm_st_stall_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == CM_ST_STALL_CYCLE_HI_BASE_ADDR)) begin
    cm_st_stall_cycle_hi_val = data;
    cm_st_stall_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VALU0_BUSY_CYCLE_LO_BASE_ADDR)) begin
    valu0_busy_cycle_lo_val = data;
    valu0_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VALU0_BUSY_CYCLE_HI_BASE_ADDR)) begin
    valu0_busy_cycle_hi_val = data;
    valu0_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VALU1_BUSY_CYCLE_LO_BASE_ADDR)) begin
    valu1_busy_cycle_lo_val = data;
    valu1_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VALU1_BUSY_CYCLE_HI_BASE_ADDR)) begin
    valu1_busy_cycle_hi_val = data;
    valu1_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VALU2_BUSY_CYCLE_LO_BASE_ADDR)) begin
    valu2_busy_cycle_lo_val = data;
    valu2_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VALU2_BUSY_CYCLE_HI_BASE_ADDR)) begin
    valu2_busy_cycle_hi_val = data;
    valu2_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VSFU0_BUSY_CYCLE_LO_BASE_ADDR)) begin
    vsfu0_busy_cycle_lo_val = data;
    vsfu0_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VSFU0_BUSY_CYCLE_HI_BASE_ADDR)) begin
    vsfu0_busy_cycle_hi_val = data;
    vsfu0_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VSFU1_BUSY_CYCLE_LO_BASE_ADDR)) begin
    vsfu1_busy_cycle_lo_val = data;
    vsfu1_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VSFU1_BUSY_CYCLE_HI_BASE_ADDR)) begin
    vsfu1_busy_cycle_hi_val = data;
    vsfu1_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MEXE_BUSY_CYCLE_LO_BASE_ADDR)) begin
    mexe_busy_cycle_lo_val = data;
    mexe_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MEXE_BUSY_CYCLE_HI_BASE_ADDR)) begin
    mexe_busy_cycle_hi_val = data;
    mexe_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SEXE_BUSY_CYCLE_LO_BASE_ADDR)) begin
    sexe_busy_cycle_lo_val = data;
    sexe_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == SEXE_BUSY_CYCLE_HI_BASE_ADDR)) begin
    sexe_busy_cycle_hi_val = data;
    sexe_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_RD_P0_BUSY_CYCLE_LO_BASE_ADDR)) begin
    vrf_rd_p0_busy_cycle_lo_val = data;
    vrf_rd_p0_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_RD_P0_BUSY_CYCLE_HI_BASE_ADDR)) begin
    vrf_rd_p0_busy_cycle_hi_val = data;
    vrf_rd_p0_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_RD_P1_BUSY_CYCLE_LO_BASE_ADDR)) begin
    vrf_rd_p1_busy_cycle_lo_val = data;
    vrf_rd_p1_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_RD_P1_BUSY_CYCLE_HI_BASE_ADDR)) begin
    vrf_rd_p1_busy_cycle_hi_val = data;
    vrf_rd_p1_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_WT_P0_BUSY_CYCLE_LO_BASE_ADDR)) begin
    vrf_wt_p0_busy_cycle_lo_val = data;
    vrf_wt_p0_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_WT_P0_BUSY_CYCLE_HI_BASE_ADDR)) begin
    vrf_wt_p0_busy_cycle_hi_val = data;
    vrf_wt_p0_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_WT_P1_BUSY_CYCLE_LO_BASE_ADDR)) begin
    vrf_wt_p1_busy_cycle_lo_val = data;
    vrf_wt_p1_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == VRF_WT_P1_BUSY_CYCLE_HI_BASE_ADDR)) begin
    vrf_wt_p1_busy_cycle_hi_val = data;
    vrf_wt_p1_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MRF_WT_BUSY_CYCLE_LO_BASE_ADDR)) begin
    mrf_wt_busy_cycle_lo_val = data;
    mrf_wt_busy_cycle_lo = data;
    mmio_hit = 1'b1;
end
if(!mmio_hit && (addr == MRF_WT_BUSY_CYCLE_HI_BASE_ADDR)) begin
    mrf_wt_busy_cycle_hi_val = data;
    mrf_wt_busy_cycle_hi = data;
    mmio_hit = 1'b1;
end
