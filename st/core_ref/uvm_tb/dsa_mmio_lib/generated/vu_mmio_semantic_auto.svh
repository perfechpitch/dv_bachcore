// AUTO-GENERATED from vu_mmio.json. DO NOT EDIT.

function string get_write_desc(bit [31:0] addr, bit [31:0] data);
    if(addr == MACRO_INST_TRIGGER_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_TRIGGER[0x%08h] <= 0x%08h {STATIC_DYNAMIC_MASK=%0d, CONFIG_IDX=%0d, EVENT_EN=%0d, STREAM_ID_OVERRIDE=%0d, STREAM_ID=%0d, MACRO_INST_FENCE=%0d, DATA_BROADCAST=%0d}", addr, data, data[7:0], data[10:8], data[16], data[17], data[21:18], data[24], data[25]);
    end
    if(addr == TYPE_VL_BASE_ADDR) begin
        return $sformatf("VU.TYPE_VL[0x%08h] <= 0x%08h {VL=%0d, DATA_TYPE=%0d, ROUND_MODE=%0d}", addr, data, data[15:0], data[16], data[19:17]);
    end
    if(addr == LD_ADDR_BASE_ADDR) begin
        return $sformatf("VU.LD_ADDR[0x%08h] <= 0x%08h {CM_ADDR=%0d}", addr, data, data[31:0]);
    end
    if(addr == ST_ADDR_BASE_ADDR) begin
        return $sformatf("VU.ST_ADDR[0x%08h] <= 0x%08h {CM_ADDR=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_INDEX_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_INDEX[0x%08h] <= 0x%08h {VRF_RD_P0_IDX=%0d, VRF_RD_P1_IDX=%0d}", addr, data, data[15:0], data[31:16]);
    end
    if(addr == VRF_WT_INDEX_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_INDEX[0x%08h] <= 0x%08h {VRF_WT_P0_IDX=%0d, VRF_WT_P1_IDX=%0d}", addr, data, data[15:0], data[31:16]);
    end
    if(addr == MRF_RD_INDEX_BASE_ADDR) begin
        return $sformatf("VU.MRF_RD_INDEX[0x%08h] <= 0x%08h {MRF_RD_P0_IDX=%0d, MRF_RD_P1_IDX=%0d}", addr, data, data[15:0], data[31:16]);
    end
    if(addr == MRF_WT_INDEX_BASE_ADDR) begin
        return $sformatf("VU.MRF_WT_INDEX[0x%08h] <= 0x%08h {MRF_WT_IDX=%0d}", addr, data, data[15:0]);
    end
    if(addr == SRF_RD_INDEX_0_BASE_ADDR) begin
        return $sformatf("VU.SRF_RD_INDEX_0[0x%08h] <= 0x%08h {SRF_RD_P0_IDX=%0d, SRF_RD_P1_IDX=%0d, SRF_RD_P2_IDX=%0d, SRF_RD_P3_IDX=%0d}", addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if(addr == SRF_RD_INDEX_1_BASE_ADDR) begin
        return $sformatf("VU.SRF_RD_INDEX_1[0x%08h] <= 0x%08h {SRF_RD_P4_IDX=%0d, SRF_RD_P5_IDX=%0d, SRF_RD_P6_IDX=%0d, SRF_RD_P7_IDX=%0d}", addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if(addr == SRF_WT_INDEX_0_BASE_ADDR) begin
        return $sformatf("VU.SRF_WT_INDEX_0[0x%08h] <= 0x%08h {SRF_WT_P0_IDX=%0d, SRF_WT_P1_IDX=%0d, SRF_WT_P2_IDX=%0d, SRF_WT_P3_IDX=%0d}", addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if(addr == SRF_WT_INDEX_1_BASE_ADDR) begin
        return $sformatf("VU.SRF_WT_INDEX_1[0x%08h] <= 0x%08h {SRF_WT_P4_IDX=%0d, SRF_WT_P5_IDX=%0d}", addr, data, data[7:0], data[15:8]);
    end
    if((addr >= LU_OP_BASE_ADDR) && (addr <= LU_OP_END_ADDR) && (((addr - LU_OP_BASE_ADDR) % LU_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - LU_OP_BASE_ADDR) / LU_OP_STRIDE;
        return $sformatf("VU.LU_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, STRIDE_RUN=%0d, STRIDE_SKIP=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SU_OP_BASE_ADDR) && (addr <= SU_OP_END_ADDR) && (((addr - SU_OP_BASE_ADDR) % SU_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SU_OP_BASE_ADDR) / SU_OP_STRIDE;
        return $sformatf("VU.SU_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC_SEL=%0d, MXFP8_SCALE_ROUND=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[16]);
    end
    if((addr >= VALU0_OP_BASE_ADDR) && (addr <= VALU0_OP_END_ADDR) && (((addr - VALU0_OP_BASE_ADDR) % VALU0_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VALU0_OP_BASE_ADDR) / VALU0_OP_STRIDE;
        return $sformatf("VU.VALU0_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d, SRC3_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= VALU1_OP_BASE_ADDR) && (addr <= VALU1_OP_END_ADDR) && (((addr - VALU1_OP_BASE_ADDR) % VALU1_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VALU1_OP_BASE_ADDR) / VALU1_OP_STRIDE;
        return $sformatf("VU.VALU1_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d, SRC3_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= VALU2_OP_BASE_ADDR) && (addr <= VALU2_OP_END_ADDR) && (((addr - VALU2_OP_BASE_ADDR) % VALU2_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VALU2_OP_BASE_ADDR) / VALU2_OP_STRIDE;
        return $sformatf("VU.VALU2_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d, SRC3_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= VSFU_OP_BASE_ADDR) && (addr <= VSFU_OP_END_ADDR) && (((addr - VSFU_OP_BASE_ADDR) % VSFU_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VSFU_OP_BASE_ADDR) / VSFU_OP_STRIDE;
        return $sformatf("VU.VSFU_OP[%0d][0x%08h] <= 0x%08h {VSFU0_OPCODE=%0d, VSFU0_SRC1_SEL=%0d, VSFU1_OPCODE=%0d, VSFU1_SRC1_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= MEXE_OP_BASE_ADDR) && (addr <= MEXE_OP_END_ADDR) && (((addr - MEXE_OP_BASE_ADDR) % MEXE_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - MEXE_OP_BASE_ADDR) / MEXE_OP_STRIDE;
        return $sformatf("VU.MEXE_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SEXE0_OP_BASE_ADDR) && (addr <= SEXE0_OP_END_ADDR) && (((addr - SEXE0_OP_BASE_ADDR) % SEXE0_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SEXE0_OP_BASE_ADDR) / SEXE0_OP_STRIDE;
        return $sformatf("VU.SEXE0_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SEXE1_OP_BASE_ADDR) && (addr <= SEXE1_OP_END_ADDR) && (((addr - SEXE1_OP_BASE_ADDR) % SEXE1_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SEXE1_OP_BASE_ADDR) / SEXE1_OP_STRIDE;
        return $sformatf("VU.SEXE1_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SEXE2_OP_BASE_ADDR) && (addr <= SEXE2_OP_END_ADDR) && (((addr - SEXE2_OP_BASE_ADDR) % SEXE2_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SEXE2_OP_BASE_ADDR) / SEXE2_OP_STRIDE;
        return $sformatf("VU.SEXE2_OP[%0d][0x%08h] <= 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= MASK_OP_BASE_ADDR) && (addr <= MASK_OP_END_ADDR) && (((addr - MASK_OP_BASE_ADDR) % MASK_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - MASK_OP_BASE_ADDR) / MASK_OP_STRIDE;
        return $sformatf("VU.MASK_OP[%0d][0x%08h] <= 0x%08h {VALU0_MASK_SEL=%0d, VALU1_MASK_SEL=%0d, VALU2_MASK_SEL=%0d, VSFU0_MASK_SEL=%0d, VSFU1_MASK_SEL=%0d}", reg_idx, addr, data, data[1:0], data[3:2], data[5:4], data[7:6], data[9:8]);
    end
    if((addr >= PRF_OP_BASE_ADDR) && (addr <= PRF_OP_END_ADDR) && (((addr - PRF_OP_BASE_ADDR) % PRF_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - PRF_OP_BASE_ADDR) / PRF_OP_STRIDE;
        return $sformatf("VU.PRF_OP[%0d][0x%08h] <= 0x%08h {VRF_WT_P0_SRC=%0d, VRF_WT_P1_SRC=%0d, MRF_WT_SRC=%0d, SRF_WT_EN=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_TYPE_VL_BASE_ADDR) && (addr <= STATIC_TYPE_VL_END_ADDR) && (((addr - STATIC_TYPE_VL_BASE_ADDR) % STATIC_TYPE_VL_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_TYPE_VL_BASE_ADDR) / STATIC_TYPE_VL_STRIDE;
        return $sformatf("VU.STATIC_TYPE_VL[%0d][0x%08h] <= 0x%08h {VL=%0d, DATA_TYPE=%0d, ROUND_MODE=%0d}", reg_idx, addr, data, data[15:0], data[16], data[19:17]);
    end
    if((addr >= STATIC_LD_ADDR_BASE_ADDR) && (addr <= STATIC_LD_ADDR_END_ADDR) && (((addr - STATIC_LD_ADDR_BASE_ADDR) % STATIC_LD_ADDR_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_LD_ADDR_BASE_ADDR) / STATIC_LD_ADDR_STRIDE;
        return $sformatf("VU.STATIC_LD_ADDR[%0d][0x%08h] <= 0x%08h {CM_ADDR=%0d}", reg_idx, addr, data, data[31:0]);
    end
    if((addr >= STATIC_ST_ADDR_BASE_ADDR) && (addr <= STATIC_ST_ADDR_END_ADDR) && (((addr - STATIC_ST_ADDR_BASE_ADDR) % STATIC_ST_ADDR_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_ST_ADDR_BASE_ADDR) / STATIC_ST_ADDR_STRIDE;
        return $sformatf("VU.STATIC_ST_ADDR[%0d][0x%08h] <= 0x%08h {CM_ADDR=%0d}", reg_idx, addr, data, data[31:0]);
    end
    if((addr >= STATIC_VRF_RD_INDEX_BASE_ADDR) && (addr <= STATIC_VRF_RD_INDEX_END_ADDR) && (((addr - STATIC_VRF_RD_INDEX_BASE_ADDR) % STATIC_VRF_RD_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_VRF_RD_INDEX_BASE_ADDR) / STATIC_VRF_RD_INDEX_STRIDE;
        return $sformatf("VU.STATIC_VRF_RD_INDEX[%0d][0x%08h] <= 0x%08h {VRF_RD_P0_IDX=%0d, VRF_RD_P1_IDX=%0d}", reg_idx, addr, data, data[15:0], data[31:16]);
    end
    if((addr >= STATIC_VRF_WT_INDEX_BASE_ADDR) && (addr <= STATIC_VRF_WT_INDEX_END_ADDR) && (((addr - STATIC_VRF_WT_INDEX_BASE_ADDR) % STATIC_VRF_WT_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_VRF_WT_INDEX_BASE_ADDR) / STATIC_VRF_WT_INDEX_STRIDE;
        return $sformatf("VU.STATIC_VRF_WT_INDEX[%0d][0x%08h] <= 0x%08h {VRF_WT_P0_IDX=%0d, VRF_WT_P1_IDX=%0d}", reg_idx, addr, data, data[15:0], data[31:16]);
    end
    if((addr >= STATIC_MRF_RD_INDEX_BASE_ADDR) && (addr <= STATIC_MRF_RD_INDEX_END_ADDR) && (((addr - STATIC_MRF_RD_INDEX_BASE_ADDR) % STATIC_MRF_RD_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_MRF_RD_INDEX_BASE_ADDR) / STATIC_MRF_RD_INDEX_STRIDE;
        return $sformatf("VU.STATIC_MRF_RD_INDEX[%0d][0x%08h] <= 0x%08h {MRF_RD_P0_IDX=%0d, MRF_RD_P1_IDX=%0d}", reg_idx, addr, data, data[15:0], data[31:16]);
    end
    if((addr >= STATIC_MRF_WT_INDEX_BASE_ADDR) && (addr <= STATIC_MRF_WT_INDEX_END_ADDR) && (((addr - STATIC_MRF_WT_INDEX_BASE_ADDR) % STATIC_MRF_WT_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_MRF_WT_INDEX_BASE_ADDR) / STATIC_MRF_WT_INDEX_STRIDE;
        return $sformatf("VU.STATIC_MRF_WT_INDEX[%0d][0x%08h] <= 0x%08h {MRF_WT_IDX=%0d}", reg_idx, addr, data, data[15:0]);
    end
    if((addr >= STATIC_SRF_RD_INDEX_0_BASE_ADDR) && (addr <= STATIC_SRF_RD_INDEX_0_END_ADDR) && (((addr - STATIC_SRF_RD_INDEX_0_BASE_ADDR) % STATIC_SRF_RD_INDEX_0_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_RD_INDEX_0_BASE_ADDR) / STATIC_SRF_RD_INDEX_0_STRIDE;
        return $sformatf("VU.STATIC_SRF_RD_INDEX_0[%0d][0x%08h] <= 0x%08h {SRF_RD_P0_IDX=%0d, SRF_RD_P1_IDX=%0d, SRF_RD_P2_IDX=%0d, SRF_RD_P3_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_SRF_RD_INDEX_1_BASE_ADDR) && (addr <= STATIC_SRF_RD_INDEX_1_END_ADDR) && (((addr - STATIC_SRF_RD_INDEX_1_BASE_ADDR) % STATIC_SRF_RD_INDEX_1_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_RD_INDEX_1_BASE_ADDR) / STATIC_SRF_RD_INDEX_1_STRIDE;
        return $sformatf("VU.STATIC_SRF_RD_INDEX_1[%0d][0x%08h] <= 0x%08h {SRF_RD_P4_IDX=%0d, SRF_RD_P5_IDX=%0d, SRF_RD_P6_IDX=%0d, SRF_RD_P7_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_SRF_WT_INDEX_0_BASE_ADDR) && (addr <= STATIC_SRF_WT_INDEX_0_END_ADDR) && (((addr - STATIC_SRF_WT_INDEX_0_BASE_ADDR) % STATIC_SRF_WT_INDEX_0_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_WT_INDEX_0_BASE_ADDR) / STATIC_SRF_WT_INDEX_0_STRIDE;
        return $sformatf("VU.STATIC_SRF_WT_INDEX_0[%0d][0x%08h] <= 0x%08h {SRF_WT_P0_IDX=%0d, SRF_WT_P1_IDX=%0d, SRF_WT_P2_IDX=%0d, SRF_WT_P3_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_SRF_WT_INDEX_1_BASE_ADDR) && (addr <= STATIC_SRF_WT_INDEX_1_END_ADDR) && (((addr - STATIC_SRF_WT_INDEX_1_BASE_ADDR) % STATIC_SRF_WT_INDEX_1_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_WT_INDEX_1_BASE_ADDR) / STATIC_SRF_WT_INDEX_1_STRIDE;
        return $sformatf("VU.STATIC_SRF_WT_INDEX_1[%0d][0x%08h] <= 0x%08h {SRF_WT_P4_IDX=%0d, SRF_WT_P5_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8]);
    end
    if(addr == REG_FILE_ADDR_BASE_ADDR) begin
        return $sformatf("VU.REG_FILE_ADDR[0x%08h] <= 0x%08h {RF_ADDR=%0d, RF_SEL=%0d}", addr, data, data[15:0], data[17:16]);
    end
    if(addr == MACRO_INST_LEFT_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_LEFT[0x%08h] <= 0x%08h {MACRO_INST_LEFT=%0d}", addr, data, data[31:0]);
    end
    if(addr == STATUS_BASE_ADDR) begin
        return $sformatf("VU.STATUS[0x%08h] <= 0x%08h {BUSY=%0d, ISQ_FULL=%0d, ISQ_EMPTY=%0d, ERROR_FLAG=%0d}", addr, data, data[0], data[1], data[2], data[3]);
    end
    if(addr == ERROR_CODE_BASE_ADDR) begin
        return $sformatf("VU.ERROR_CODE[0x%08h] <= 0x%08h {REG_ADDR_ERROR=%0d, CFG_ERROR=%0d, RF_IDX_ERROR=%0d, CM_ADDR_ERROR=%0d, CM_RESP_ERROR=%0d, DATA_CVT_ERROR=%0d}", addr, data, data[0], data[2], data[3], data[4], data[5], data[6]);
    end
    if(addr == ERROR_INFO_BASE_ADDR) begin
        return $sformatf("VU.ERROR_INFO[0x%08h] <= 0x%08h {STATIC_DYNAMIC_MASK=%0d, CONFIG_IDX=%0d, ERR_UNIT=%0d, FIRST_ERR=%0d, VALID=%0d}", addr, data, data[7:0], data[10:8], data[15:12], data[18:16], data[19]);
    end
    if(addr == SNAPSHOT_ADDR_BASE_ADDR) begin
        return $sformatf("VU.SNAPSHOT_ADDR[0x%08h] <= 0x%08h {SNAP_IDX=%0d, SNAP_SEL=%0d}", addr, data, data[3:0], data[11:4]);
    end
    if(addr == SNAPSHOT_DATA_BASE_ADDR) begin
        return $sformatf("VU.SNAPSHOT_DATA[0x%08h] <= 0x%08h {SNAP_DATA=%0d}", addr, data, data[31:0]);
    end
    if(addr == PROFILE_CTRL_BASE_ADDR) begin
        return $sformatf("VU.PROFILE_CTRL[0x%08h] <= 0x%08h {RUN=%0d, CLEAR=%0d}", addr, data, data[0], data[1]);
    end
    if(addr == PROF_RUN_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.PROF_RUN_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == PROF_RUN_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.PROF_RUN_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == TOTAL_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.TOTAL_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == TOTAL_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.TOTAL_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_NUM_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_NUM_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_STALL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_STALL_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_STALL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_STALL_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_TOTAL_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_TOTAL_NUM_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_TOTAL_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_TOTAL_NUM_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_RETIRE_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_RETIRE_NUM_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_RETIRE_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_RETIRE_NUM_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISQ_FULL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISQ_FULL_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISQ_FULL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISQ_FULL_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_FENCE_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_FENCE_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_FENCE_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_FENCE_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_BCAST_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_BCAST_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_BCAST_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_BCAST_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_DEP_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_DEP_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_DEP_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_DEP_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_EU_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_EU_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_EU_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_EU_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STARVE_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STARVE_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STARVE_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STARVE_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == LU_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.LU_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == LU_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.LU_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_REQ_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_REQ_NUM_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_REQ_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_REQ_NUM_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_STALL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_STALL_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_STALL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_STALL_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SU_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.SU_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SU_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.SU_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_REQ_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_REQ_NUM_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_REQ_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_REQ_NUM_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_STALL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_STALL_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_STALL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_STALL_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VALU0_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VALU0_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VALU1_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VALU1_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU2_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VALU2_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU2_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VALU2_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VSFU0_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VSFU0_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VSFU1_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VSFU1_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MEXE_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.MEXE_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MEXE_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.MEXE_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SEXE_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.SEXE_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SEXE_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.SEXE_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P0_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P0_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P1_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P1_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P0_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P0_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P1_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P1_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MRF_WT_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.MRF_WT_BUSY_CYCLE_LO[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MRF_WT_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.MRF_WT_BUSY_CYCLE_HI[0x%08h] <= 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == REG_FILE_DATA_BASE_ADDR) begin
        return $sformatf("VU.REG_FILE_DATA[0x%08h] <= 0x%08h", addr, data);
    end
    return $sformatf("[VU_MMIO] W addr=0x%08h data=0x%08h", addr, data);
endfunction : get_write_desc

function string get_read_desc(bit [31:0] addr, bit [31:0] data);
    if(addr == MACRO_INST_TRIGGER_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_TRIGGER[0x%08h] => 0x%08h {STATIC_DYNAMIC_MASK=%0d, CONFIG_IDX=%0d, EVENT_EN=%0d, STREAM_ID_OVERRIDE=%0d, STREAM_ID=%0d, MACRO_INST_FENCE=%0d, DATA_BROADCAST=%0d}", addr, data, data[7:0], data[10:8], data[16], data[17], data[21:18], data[24], data[25]);
    end
    if(addr == TYPE_VL_BASE_ADDR) begin
        return $sformatf("VU.TYPE_VL[0x%08h] => 0x%08h {VL=%0d, DATA_TYPE=%0d, ROUND_MODE=%0d}", addr, data, data[15:0], data[16], data[19:17]);
    end
    if(addr == LD_ADDR_BASE_ADDR) begin
        return $sformatf("VU.LD_ADDR[0x%08h] => 0x%08h {CM_ADDR=%0d}", addr, data, data[31:0]);
    end
    if(addr == ST_ADDR_BASE_ADDR) begin
        return $sformatf("VU.ST_ADDR[0x%08h] => 0x%08h {CM_ADDR=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_INDEX_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_INDEX[0x%08h] => 0x%08h {VRF_RD_P0_IDX=%0d, VRF_RD_P1_IDX=%0d}", addr, data, data[15:0], data[31:16]);
    end
    if(addr == VRF_WT_INDEX_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_INDEX[0x%08h] => 0x%08h {VRF_WT_P0_IDX=%0d, VRF_WT_P1_IDX=%0d}", addr, data, data[15:0], data[31:16]);
    end
    if(addr == MRF_RD_INDEX_BASE_ADDR) begin
        return $sformatf("VU.MRF_RD_INDEX[0x%08h] => 0x%08h {MRF_RD_P0_IDX=%0d, MRF_RD_P1_IDX=%0d}", addr, data, data[15:0], data[31:16]);
    end
    if(addr == MRF_WT_INDEX_BASE_ADDR) begin
        return $sformatf("VU.MRF_WT_INDEX[0x%08h] => 0x%08h {MRF_WT_IDX=%0d}", addr, data, data[15:0]);
    end
    if(addr == SRF_RD_INDEX_0_BASE_ADDR) begin
        return $sformatf("VU.SRF_RD_INDEX_0[0x%08h] => 0x%08h {SRF_RD_P0_IDX=%0d, SRF_RD_P1_IDX=%0d, SRF_RD_P2_IDX=%0d, SRF_RD_P3_IDX=%0d}", addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if(addr == SRF_RD_INDEX_1_BASE_ADDR) begin
        return $sformatf("VU.SRF_RD_INDEX_1[0x%08h] => 0x%08h {SRF_RD_P4_IDX=%0d, SRF_RD_P5_IDX=%0d, SRF_RD_P6_IDX=%0d, SRF_RD_P7_IDX=%0d}", addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if(addr == SRF_WT_INDEX_0_BASE_ADDR) begin
        return $sformatf("VU.SRF_WT_INDEX_0[0x%08h] => 0x%08h {SRF_WT_P0_IDX=%0d, SRF_WT_P1_IDX=%0d, SRF_WT_P2_IDX=%0d, SRF_WT_P3_IDX=%0d}", addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if(addr == SRF_WT_INDEX_1_BASE_ADDR) begin
        return $sformatf("VU.SRF_WT_INDEX_1[0x%08h] => 0x%08h {SRF_WT_P4_IDX=%0d, SRF_WT_P5_IDX=%0d}", addr, data, data[7:0], data[15:8]);
    end
    if((addr >= LU_OP_BASE_ADDR) && (addr <= LU_OP_END_ADDR) && (((addr - LU_OP_BASE_ADDR) % LU_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - LU_OP_BASE_ADDR) / LU_OP_STRIDE;
        return $sformatf("VU.LU_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, STRIDE_RUN=%0d, STRIDE_SKIP=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SU_OP_BASE_ADDR) && (addr <= SU_OP_END_ADDR) && (((addr - SU_OP_BASE_ADDR) % SU_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SU_OP_BASE_ADDR) / SU_OP_STRIDE;
        return $sformatf("VU.SU_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC_SEL=%0d, MXFP8_SCALE_ROUND=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[16]);
    end
    if((addr >= VALU0_OP_BASE_ADDR) && (addr <= VALU0_OP_END_ADDR) && (((addr - VALU0_OP_BASE_ADDR) % VALU0_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VALU0_OP_BASE_ADDR) / VALU0_OP_STRIDE;
        return $sformatf("VU.VALU0_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d, SRC3_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= VALU1_OP_BASE_ADDR) && (addr <= VALU1_OP_END_ADDR) && (((addr - VALU1_OP_BASE_ADDR) % VALU1_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VALU1_OP_BASE_ADDR) / VALU1_OP_STRIDE;
        return $sformatf("VU.VALU1_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d, SRC3_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= VALU2_OP_BASE_ADDR) && (addr <= VALU2_OP_END_ADDR) && (((addr - VALU2_OP_BASE_ADDR) % VALU2_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VALU2_OP_BASE_ADDR) / VALU2_OP_STRIDE;
        return $sformatf("VU.VALU2_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d, SRC3_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= VSFU_OP_BASE_ADDR) && (addr <= VSFU_OP_END_ADDR) && (((addr - VSFU_OP_BASE_ADDR) % VSFU_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - VSFU_OP_BASE_ADDR) / VSFU_OP_STRIDE;
        return $sformatf("VU.VSFU_OP[%0d][0x%08h] => 0x%08h {VSFU0_OPCODE=%0d, VSFU0_SRC1_SEL=%0d, VSFU1_OPCODE=%0d, VSFU1_SRC1_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= MEXE_OP_BASE_ADDR) && (addr <= MEXE_OP_END_ADDR) && (((addr - MEXE_OP_BASE_ADDR) % MEXE_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - MEXE_OP_BASE_ADDR) / MEXE_OP_STRIDE;
        return $sformatf("VU.MEXE_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SEXE0_OP_BASE_ADDR) && (addr <= SEXE0_OP_END_ADDR) && (((addr - SEXE0_OP_BASE_ADDR) % SEXE0_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SEXE0_OP_BASE_ADDR) / SEXE0_OP_STRIDE;
        return $sformatf("VU.SEXE0_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SEXE1_OP_BASE_ADDR) && (addr <= SEXE1_OP_END_ADDR) && (((addr - SEXE1_OP_BASE_ADDR) % SEXE1_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SEXE1_OP_BASE_ADDR) / SEXE1_OP_STRIDE;
        return $sformatf("VU.SEXE1_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= SEXE2_OP_BASE_ADDR) && (addr <= SEXE2_OP_END_ADDR) && (((addr - SEXE2_OP_BASE_ADDR) % SEXE2_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - SEXE2_OP_BASE_ADDR) / SEXE2_OP_STRIDE;
        return $sformatf("VU.SEXE2_OP[%0d][0x%08h] => 0x%08h {OPCODE=%0d, SRC1_SEL=%0d, SRC2_SEL=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16]);
    end
    if((addr >= MASK_OP_BASE_ADDR) && (addr <= MASK_OP_END_ADDR) && (((addr - MASK_OP_BASE_ADDR) % MASK_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - MASK_OP_BASE_ADDR) / MASK_OP_STRIDE;
        return $sformatf("VU.MASK_OP[%0d][0x%08h] => 0x%08h {VALU0_MASK_SEL=%0d, VALU1_MASK_SEL=%0d, VALU2_MASK_SEL=%0d, VSFU0_MASK_SEL=%0d, VSFU1_MASK_SEL=%0d}", reg_idx, addr, data, data[1:0], data[3:2], data[5:4], data[7:6], data[9:8]);
    end
    if((addr >= PRF_OP_BASE_ADDR) && (addr <= PRF_OP_END_ADDR) && (((addr - PRF_OP_BASE_ADDR) % PRF_OP_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - PRF_OP_BASE_ADDR) / PRF_OP_STRIDE;
        return $sformatf("VU.PRF_OP[%0d][0x%08h] => 0x%08h {VRF_WT_P0_SRC=%0d, VRF_WT_P1_SRC=%0d, MRF_WT_SRC=%0d, SRF_WT_EN=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_TYPE_VL_BASE_ADDR) && (addr <= STATIC_TYPE_VL_END_ADDR) && (((addr - STATIC_TYPE_VL_BASE_ADDR) % STATIC_TYPE_VL_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_TYPE_VL_BASE_ADDR) / STATIC_TYPE_VL_STRIDE;
        return $sformatf("VU.STATIC_TYPE_VL[%0d][0x%08h] => 0x%08h {VL=%0d, DATA_TYPE=%0d, ROUND_MODE=%0d}", reg_idx, addr, data, data[15:0], data[16], data[19:17]);
    end
    if((addr >= STATIC_LD_ADDR_BASE_ADDR) && (addr <= STATIC_LD_ADDR_END_ADDR) && (((addr - STATIC_LD_ADDR_BASE_ADDR) % STATIC_LD_ADDR_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_LD_ADDR_BASE_ADDR) / STATIC_LD_ADDR_STRIDE;
        return $sformatf("VU.STATIC_LD_ADDR[%0d][0x%08h] => 0x%08h {CM_ADDR=%0d}", reg_idx, addr, data, data[31:0]);
    end
    if((addr >= STATIC_ST_ADDR_BASE_ADDR) && (addr <= STATIC_ST_ADDR_END_ADDR) && (((addr - STATIC_ST_ADDR_BASE_ADDR) % STATIC_ST_ADDR_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_ST_ADDR_BASE_ADDR) / STATIC_ST_ADDR_STRIDE;
        return $sformatf("VU.STATIC_ST_ADDR[%0d][0x%08h] => 0x%08h {CM_ADDR=%0d}", reg_idx, addr, data, data[31:0]);
    end
    if((addr >= STATIC_VRF_RD_INDEX_BASE_ADDR) && (addr <= STATIC_VRF_RD_INDEX_END_ADDR) && (((addr - STATIC_VRF_RD_INDEX_BASE_ADDR) % STATIC_VRF_RD_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_VRF_RD_INDEX_BASE_ADDR) / STATIC_VRF_RD_INDEX_STRIDE;
        return $sformatf("VU.STATIC_VRF_RD_INDEX[%0d][0x%08h] => 0x%08h {VRF_RD_P0_IDX=%0d, VRF_RD_P1_IDX=%0d}", reg_idx, addr, data, data[15:0], data[31:16]);
    end
    if((addr >= STATIC_VRF_WT_INDEX_BASE_ADDR) && (addr <= STATIC_VRF_WT_INDEX_END_ADDR) && (((addr - STATIC_VRF_WT_INDEX_BASE_ADDR) % STATIC_VRF_WT_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_VRF_WT_INDEX_BASE_ADDR) / STATIC_VRF_WT_INDEX_STRIDE;
        return $sformatf("VU.STATIC_VRF_WT_INDEX[%0d][0x%08h] => 0x%08h {VRF_WT_P0_IDX=%0d, VRF_WT_P1_IDX=%0d}", reg_idx, addr, data, data[15:0], data[31:16]);
    end
    if((addr >= STATIC_MRF_RD_INDEX_BASE_ADDR) && (addr <= STATIC_MRF_RD_INDEX_END_ADDR) && (((addr - STATIC_MRF_RD_INDEX_BASE_ADDR) % STATIC_MRF_RD_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_MRF_RD_INDEX_BASE_ADDR) / STATIC_MRF_RD_INDEX_STRIDE;
        return $sformatf("VU.STATIC_MRF_RD_INDEX[%0d][0x%08h] => 0x%08h {MRF_RD_P0_IDX=%0d, MRF_RD_P1_IDX=%0d}", reg_idx, addr, data, data[15:0], data[31:16]);
    end
    if((addr >= STATIC_MRF_WT_INDEX_BASE_ADDR) && (addr <= STATIC_MRF_WT_INDEX_END_ADDR) && (((addr - STATIC_MRF_WT_INDEX_BASE_ADDR) % STATIC_MRF_WT_INDEX_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_MRF_WT_INDEX_BASE_ADDR) / STATIC_MRF_WT_INDEX_STRIDE;
        return $sformatf("VU.STATIC_MRF_WT_INDEX[%0d][0x%08h] => 0x%08h {MRF_WT_IDX=%0d}", reg_idx, addr, data, data[15:0]);
    end
    if((addr >= STATIC_SRF_RD_INDEX_0_BASE_ADDR) && (addr <= STATIC_SRF_RD_INDEX_0_END_ADDR) && (((addr - STATIC_SRF_RD_INDEX_0_BASE_ADDR) % STATIC_SRF_RD_INDEX_0_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_RD_INDEX_0_BASE_ADDR) / STATIC_SRF_RD_INDEX_0_STRIDE;
        return $sformatf("VU.STATIC_SRF_RD_INDEX_0[%0d][0x%08h] => 0x%08h {SRF_RD_P0_IDX=%0d, SRF_RD_P1_IDX=%0d, SRF_RD_P2_IDX=%0d, SRF_RD_P3_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_SRF_RD_INDEX_1_BASE_ADDR) && (addr <= STATIC_SRF_RD_INDEX_1_END_ADDR) && (((addr - STATIC_SRF_RD_INDEX_1_BASE_ADDR) % STATIC_SRF_RD_INDEX_1_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_RD_INDEX_1_BASE_ADDR) / STATIC_SRF_RD_INDEX_1_STRIDE;
        return $sformatf("VU.STATIC_SRF_RD_INDEX_1[%0d][0x%08h] => 0x%08h {SRF_RD_P4_IDX=%0d, SRF_RD_P5_IDX=%0d, SRF_RD_P6_IDX=%0d, SRF_RD_P7_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_SRF_WT_INDEX_0_BASE_ADDR) && (addr <= STATIC_SRF_WT_INDEX_0_END_ADDR) && (((addr - STATIC_SRF_WT_INDEX_0_BASE_ADDR) % STATIC_SRF_WT_INDEX_0_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_WT_INDEX_0_BASE_ADDR) / STATIC_SRF_WT_INDEX_0_STRIDE;
        return $sformatf("VU.STATIC_SRF_WT_INDEX_0[%0d][0x%08h] => 0x%08h {SRF_WT_P0_IDX=%0d, SRF_WT_P1_IDX=%0d, SRF_WT_P2_IDX=%0d, SRF_WT_P3_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8], data[23:16], data[31:24]);
    end
    if((addr >= STATIC_SRF_WT_INDEX_1_BASE_ADDR) && (addr <= STATIC_SRF_WT_INDEX_1_END_ADDR) && (((addr - STATIC_SRF_WT_INDEX_1_BASE_ADDR) % STATIC_SRF_WT_INDEX_1_STRIDE) == 0)) begin
        int unsigned reg_idx;
        reg_idx = (addr - STATIC_SRF_WT_INDEX_1_BASE_ADDR) / STATIC_SRF_WT_INDEX_1_STRIDE;
        return $sformatf("VU.STATIC_SRF_WT_INDEX_1[%0d][0x%08h] => 0x%08h {SRF_WT_P4_IDX=%0d, SRF_WT_P5_IDX=%0d}", reg_idx, addr, data, data[7:0], data[15:8]);
    end
    if(addr == REG_FILE_ADDR_BASE_ADDR) begin
        return $sformatf("VU.REG_FILE_ADDR[0x%08h] => 0x%08h {RF_ADDR=%0d, RF_SEL=%0d}", addr, data, data[15:0], data[17:16]);
    end
    if(addr == MACRO_INST_LEFT_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_LEFT[0x%08h] => 0x%08h {MACRO_INST_LEFT=%0d}", addr, data, data[31:0]);
    end
    if(addr == STATUS_BASE_ADDR) begin
        return $sformatf("VU.STATUS[0x%08h] => 0x%08h {BUSY=%0d, ISQ_FULL=%0d, ISQ_EMPTY=%0d, ERROR_FLAG=%0d}", addr, data, data[0], data[1], data[2], data[3]);
    end
    if(addr == ERROR_CODE_BASE_ADDR) begin
        return $sformatf("VU.ERROR_CODE[0x%08h] => 0x%08h {REG_ADDR_ERROR=%0d, CFG_ERROR=%0d, RF_IDX_ERROR=%0d, CM_ADDR_ERROR=%0d, CM_RESP_ERROR=%0d, DATA_CVT_ERROR=%0d}", addr, data, data[0], data[2], data[3], data[4], data[5], data[6]);
    end
    if(addr == ERROR_INFO_BASE_ADDR) begin
        return $sformatf("VU.ERROR_INFO[0x%08h] => 0x%08h {STATIC_DYNAMIC_MASK=%0d, CONFIG_IDX=%0d, ERR_UNIT=%0d, FIRST_ERR=%0d, VALID=%0d}", addr, data, data[7:0], data[10:8], data[15:12], data[18:16], data[19]);
    end
    if(addr == SNAPSHOT_ADDR_BASE_ADDR) begin
        return $sformatf("VU.SNAPSHOT_ADDR[0x%08h] => 0x%08h {SNAP_IDX=%0d, SNAP_SEL=%0d}", addr, data, data[3:0], data[11:4]);
    end
    if(addr == SNAPSHOT_DATA_BASE_ADDR) begin
        return $sformatf("VU.SNAPSHOT_DATA[0x%08h] => 0x%08h {SNAP_DATA=%0d}", addr, data, data[31:0]);
    end
    if(addr == PROFILE_CTRL_BASE_ADDR) begin
        return $sformatf("VU.PROFILE_CTRL[0x%08h] => 0x%08h {RUN=%0d, CLEAR=%0d}", addr, data, data[0], data[1]);
    end
    if(addr == PROF_RUN_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.PROF_RUN_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == PROF_RUN_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.PROF_RUN_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == TOTAL_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.TOTAL_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == TOTAL_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.TOTAL_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_NUM_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_NUM_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_STALL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_STALL_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CFG_WR_STALL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.CFG_WR_STALL_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_TOTAL_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_TOTAL_NUM_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_TOTAL_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_TOTAL_NUM_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_RETIRE_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_RETIRE_NUM_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MACRO_INST_RETIRE_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.MACRO_INST_RETIRE_NUM_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISQ_FULL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISQ_FULL_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISQ_FULL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISQ_FULL_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_FENCE_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_FENCE_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_FENCE_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_FENCE_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_BCAST_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_BCAST_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_BCAST_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_BCAST_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_DEP_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_DEP_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_DEP_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_DEP_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_EU_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_EU_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STALL_EU_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STALL_EU_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STARVE_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STARVE_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == ISSUE_STARVE_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.ISSUE_STARVE_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == LU_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.LU_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == LU_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.LU_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_REQ_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_REQ_NUM_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_REQ_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_REQ_NUM_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_STALL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_STALL_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_LD_STALL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_LD_STALL_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SU_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.SU_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SU_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.SU_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_REQ_NUM_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_REQ_NUM_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_REQ_NUM_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_REQ_NUM_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_STALL_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_STALL_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == CM_ST_STALL_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.CM_ST_STALL_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VALU0_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VALU0_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VALU1_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VALU1_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU2_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VALU2_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VALU2_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VALU2_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VSFU0_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VSFU0_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VSFU1_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VSFU1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VSFU1_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MEXE_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.MEXE_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MEXE_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.MEXE_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SEXE_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.SEXE_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == SEXE_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.SEXE_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P0_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P0_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P1_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_RD_P1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_RD_P1_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P0_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P0_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P0_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P0_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P1_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P1_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == VRF_WT_P1_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.VRF_WT_P1_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MRF_WT_BUSY_CYCLE_LO_BASE_ADDR) begin
        return $sformatf("VU.MRF_WT_BUSY_CYCLE_LO[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == MRF_WT_BUSY_CYCLE_HI_BASE_ADDR) begin
        return $sformatf("VU.MRF_WT_BUSY_CYCLE_HI[0x%08h] => 0x%08h {COUNT=%0d}", addr, data, data[31:0]);
    end
    if(addr == REG_FILE_DATA_BASE_ADDR) begin
        return $sformatf("VU.REG_FILE_DATA[0x%08h] => 0x%08h", addr, data);
    end
    return $sformatf("[VU_MMIO] R addr=0x%08h data=0x%08h", addr, data);
endfunction : get_read_desc
