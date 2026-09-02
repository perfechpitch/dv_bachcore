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
if(!mmio_hit && (addr == REG_FILE_ADDR_BASE_ADDR)) begin
    reg_file_addr_val = data;
    reg_file_addr = data;
    mmio_hit = 1'b1;
end
