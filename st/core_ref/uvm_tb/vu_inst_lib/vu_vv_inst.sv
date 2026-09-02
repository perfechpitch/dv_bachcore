`define VU_VV_ARITH_INST(NAME, OPCODE, DPI_FUNC) \
    OPCODE: begin \
        if(!resolve_src(mmio, valu_id, op.src1_sel, vrf_rd_p0_idx, \
                        vrf_rd_p1_idx, chunk_idx, src1)) begin \
            if(log_fd != 0) \
                $fwrite(log_fd, \
                    "[VU_INST] VALU%0d chunk=%0d opcode=%02h not executed: invalid src1=%02h\n", \
                    valu_id, chunk_idx, op.opcode, op.src1_sel); \
            return 1'b0; \
        end \
        if(!resolve_src(mmio, valu_id, op.src2_sel, vrf_rd_p0_idx, \
                        vrf_rd_p1_idx, chunk_idx, src2)) begin \
            if(log_fd != 0) \
                $fwrite(log_fd, \
                    "[VU_INST] VALU%0d chunk=%0d opcode=%02h not executed: invalid src2=%02h\n", \
                    valu_id, chunk_idx, op.opcode, op.src2_sel); \
            return 1'b0; \
        end \
        if(log_fd != 0) \
            $fwrite(log_fd, \
                "[VU_INST] VALU%0d chunk=%0d elems=%0d result=", \
                valu_id, chunk_idx, active_elems); \
        for(int unsigned elem = 0; elem < active_elems; elem++) begin \
            result[elem*32 +: 32] = DPI_FUNC( \
                src1[elem*32 +: 32], \
                src2[elem*32 +: 32], \
                round_mode \
            ); \
            if(log_fd != 0) \
                $fwrite(log_fd, "%08h ", result[elem*32 +: 32]); \
        end \
        if(log_fd != 0) \
            $fwrite(log_fd, "\n"); \
        return 1'b1; \
    end

`define VU_VV_ARITH_DISPATCH \
    `VU_VV_ARITH_INST(VADD_VV, `VU_OPCODE_VADD_VV, vu_fp32_add)

class vu_vv_inst;

    static function automatic bit [8:0] wrap_vrf_index(
        input bit [15:0] start_idx,
        input int unsigned chunk_idx
    );
        return 9'(start_idx[8:0] + chunk_idx);
    endfunction : wrap_vrf_index

    static function automatic bit is_self_bypass(
        input vu_valu_id_e valu_id,
        input bit [7:0] src_sel
    );
        return ((valu_id == VU_VALU0) && (src_sel == `VU_SRC_VALU0)) ||
               ((valu_id == VU_VALU1) && (src_sel == `VU_SRC_VALU1)) ||
               ((valu_id == VU_VALU2) && (src_sel == `VU_SRC_VALU2));
    endfunction : is_self_bypass

    static function automatic bit resolve_src(
        input vu_mmio_set mmio,
        input vu_valu_id_e valu_id,
        input bit [7:0] src_sel,
        input bit [15:0] vrf_p0_idx,
        input bit [15:0] vrf_p1_idx,
        input int unsigned chunk_idx,
        output vu_vec_chunk_t data
    );
        bit [8:0] entry_idx;

        data = '0;

        if(is_self_bypass(valu_id, src_sel))
            return 1'b0;

        case(src_sel)
            `VU_SRC_VRF_P0: begin
                entry_idx = wrap_vrf_index(vrf_p0_idx, chunk_idx);
                data = mmio.read_vrf_entry(entry_idx);
                return 1'b1;
            end

            `VU_SRC_VRF_P1: begin
                entry_idx = wrap_vrf_index(vrf_p1_idx, chunk_idx);
                data = mmio.read_vrf_entry(entry_idx);
                return 1'b1;
            end

            `VU_SRC_LU: begin
                data = mmio.get_lu_bypass();
                return 1'b1;
            end

            `VU_SRC_VALU0: begin
                data = mmio.get_valu_bypass(0);
                return 1'b1;
            end

            `VU_SRC_VALU1: begin
                data = mmio.get_valu_bypass(1);
                return 1'b1;
            end

            `VU_SRC_VALU2: begin
                data = mmio.get_valu_bypass(2);
                return 1'b1;
            end

            `VU_SRC_VSFU0: begin
                data = mmio.get_vsfu_bypass(0);
                return 1'b1;
            end

            `VU_SRC_VSFU1: begin
                data = mmio.get_vsfu_bypass(1);
                return 1'b1;
            end

            default:
                return 1'b0;
        endcase
    endfunction : resolve_src

    static function automatic bit execute_chunk(
        input vu_mmio_set mmio,
        input vu_valu_id_e valu_id,
        input vu_valu_op_s op,
        input bit [15:0] vrf_rd_p0_idx,
        input bit [15:0] vrf_rd_p1_idx,
        input int unsigned chunk_idx,
        input int unsigned active_elems,
        input int unsigned round_mode,
        input int log_fd,
        output vu_vec_chunk_t result
    );
        vu_vec_chunk_t src1;
        vu_vec_chunk_t src2;

        result = '0;

        case(op.opcode)
            `VU_OPCODE_NOP: begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] VALU%0d chunk=%0d opcode=%02h NOP\n",
                        valu_id, chunk_idx, op.opcode);
                return 1'b0;
            end

            `VU_VV_ARITH_DISPATCH

            default: begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] VALU%0d chunk=%0d opcode=%02h not executed: unsupported opcode\n",
                        valu_id, chunk_idx, op.opcode);
                return 1'b0;
            end
        endcase
    endfunction : execute_chunk

endclass : vu_vv_inst