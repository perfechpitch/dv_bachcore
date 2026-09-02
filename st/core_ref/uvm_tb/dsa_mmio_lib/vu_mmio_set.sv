class vu_mmio_set extends uvm_object;

    `uvm_object_utils(vu_mmio_set)

    protected int log_fd = 0;

    `include "generated/vu_mmio_decl_auto.svh"

    function new(string name = "vu_mmio_set");
        super.new(name);
    endfunction

    protected function void mmio_log(string msg);
        if(log_fd != 0)
            $fwrite(log_fd, "%s", msg);
    endfunction

    function void set_log(int fd);
        log_fd = fd;
    endfunction

    function void reset_mmio();
        `include "generated/vu_mmio_reset_auto.svh"
    endfunction

    function void resolve_exec_param();
        `include "generated/vu_mmio_resolve_auto.svh"

        mmio_log($sformatf(
            "[VU_MMIO] trigger cfg=%0d vl=%0d type=%0d round=%0d valu0_op=%02h valu1_op=%02h valu2_op=%02h\n",
            exec_param.config_idx,
            exec_param.type_vl.vl,
            exec_param.type_vl.data_type,
            exec_param.type_vl.round_mode,
            exec_param.valu0_op.opcode,
            exec_param.valu1_op.opcode,
            exec_param.valu2_op.opcode
        ));
    endfunction

    function bit pop_trigger(ref vu_exec_param_s param);
        if(!trigger_pending)
            return 1'b0;

        param = exec_param;
        trigger_pending = 1'b0;
        return 1'b1;
    endfunction

    function void write(bit [31:0] addr, bit [31:0] data);
        bit mmio_hit;
        bit inst_trigger;

        mmio_hit = 1'b0;
        inst_trigger = 1'b0;

        mmio_log($sformatf(
            "[VU_MMIO] W addr=0x%08h data=0x%08h\n",
            addr,
            data
        ));

        if(addr == REG_FILE_DATA_BASE_ADDR) begin
            reg_file_data_write(data);

            mmio_hit = 1'b1;
        end

        `include "generated/vu_mmio_write_auto.svh"

        if(!mmio_hit)
            `uvm_error("VU_MMIO", $sformatf(
                "unknown MMIO write addr=0x%08h data=0x%08h",
                addr,
                data
            ))

        if(inst_trigger) begin
            resolve_exec_param();
            trigger_pending = 1'b1;
        end
    endfunction

    function bit [31:0] read(bit [31:0] addr);
        bit mmio_hit;
        bit [31:0] data;

        mmio_hit = 1'b0;
        data = 32'h0;

        if(addr == REG_FILE_DATA_BASE_ADDR) begin
            data = reg_file_data_read();
            mmio_hit = 1'b1;
        end

        `include "generated/vu_mmio_read_auto.svh"

        if(!mmio_hit)
            `uvm_error("VU_MMIO", $sformatf(
                "unknown MMIO read addr=0x%08h",
                addr
            ))

        mmio_log($sformatf(
            "[VU_MMIO] R addr=0x%08h data=0x%08h\n",
            addr,
            data
        ));

        return data;
    endfunction

    protected function void reg_file_data_write(bit [31:0] data);
        bit [15:0] byte_addr;
        int unsigned entry_idx;
        int unsigned word_idx;

        byte_addr = reg_file_addr.rf_addr & 16'hfffc;

        case(reg_file_addr.rf_sel)
            2'b00: begin
                entry_idx = (byte_addr / 128) % 512;
                word_idx = (byte_addr % 128) / 4;
                vrf[entry_idx][word_idx*32 +: 32] = data;
            end
            2'b01: begin
                byte_addr = byte_addr % 16'h1000;
                entry_idx = (byte_addr / 8) % 512;
                word_idx = (byte_addr % 8) / 4;
                mrf[entry_idx][word_idx*32 +: 32] = data;
            end
            2'b10: begin
                byte_addr = byte_addr % 16'h0100;
                entry_idx = (byte_addr / 4) % 64;
                srf[entry_idx] = data;
            end
            default: begin
                // RF_SEL=2'b11 error handling is intentionally not modeled yet.
            end
        endcase
    endfunction

    protected function bit [31:0] reg_file_data_read();
        bit [15:0] byte_addr;
        bit [31:0] data;
        int unsigned entry_idx;
        int unsigned word_idx;

        byte_addr = reg_file_addr.rf_addr & 16'hfffc;
        data = 32'h0;

        case(reg_file_addr.rf_sel)
            2'b00: begin
                entry_idx = (byte_addr / 128) % 512;
                word_idx = (byte_addr % 128) / 4;
                data = vrf[entry_idx][word_idx*32 +: 32];
            end
            2'b01: begin
                byte_addr = byte_addr % 16'h1000;
                entry_idx = (byte_addr / 8) % 512;
                word_idx = (byte_addr % 8) / 4;
                data = mrf[entry_idx][word_idx*32 +: 32];
            end
            2'b10: begin
                byte_addr = byte_addr % 16'h0100;
                entry_idx = (byte_addr / 4) % 64;
                data = srf[entry_idx];
            end
            default: begin
                data = 32'h0;
            end
        endcase

        return data;
    endfunction

    function bit [1023:0] read_vrf_entry(int unsigned entry_idx);
        return vrf[entry_idx % 512];
    endfunction

    function void write_vrf_entry(
        int unsigned entry_idx,
        bit [1023:0] data
    );
        vrf[entry_idx % 512] = data;
    endfunction

    function bit [31:0] read_srf_entry(int unsigned entry_idx);
        return srf[entry_idx % 64];
    endfunction

    function bit [1023:0] get_lu_bypass();
        return lu_bypass;
    endfunction

    function void set_lu_bypass(bit [1023:0] data);
        lu_bypass = data;
    endfunction

    function bit [1023:0] get_valu_bypass(int unsigned valu_id);
        case(valu_id)
            0: return valu0_bypass;
            1: return valu1_bypass;
            2: return valu2_bypass;
            default: return '0;
        endcase
    endfunction

    function void set_valu_bypass(
        int unsigned valu_id,
        bit [1023:0] data
    );
        case(valu_id)
            0: valu0_bypass = data;
            1: valu1_bypass = data;
            2: valu2_bypass = data;
            default: begin
            end
        endcase
    endfunction

    function bit [1023:0] get_vsfu_bypass(int unsigned vsfu_id);
        case(vsfu_id)
            0: return vsfu0_bypass;
            1: return vsfu1_bypass;
            default: return '0;
        endcase
    endfunction

    function void set_vsfu_bypass(
        int unsigned vsfu_id,
        bit [1023:0] data
    );
        case(vsfu_id)
            0: vsfu0_bypass = data;
            1: vsfu1_bypass = data;
            default: begin
            end
        endcase
    endfunction

endclass