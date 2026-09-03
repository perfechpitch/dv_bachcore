// ============================================================================
// Filename             : axi_vip_virtual_sequencer.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_VIP_VIRTUAL_SEQUENCER_SV
`define AXI_VIP_VIRTUAL_SEQUENCER_SV

// Reusable Test-facing handle container exported by axi_multi_env. It preserves
// cfg/Agent indexing and owns the completion FIFOs used by Tests. No virtual
// sequence runs here; Tests directly start the selected Master leaf Sequence.
class axi_vip_virtual_sequencer extends
    uvm_sequencer #(uvm_sequence_item);
    axi_multi_env_config cfg;

    axi_master_read_sequencer_default_t  master_read_sequencers[];
    axi_master_write_sequencer_default_t master_write_sequencers[];

    // The Master monitors publish a complete transaction only after an
    // accepted RLAST or B.  Only active Master leaves need completion FIFOs;
    // passive slots intentionally remain null.
    uvm_tlm_analysis_fifo #(axi_master_read_transaction_t)
        master_read_completion_fifos[];
    uvm_tlm_analysis_fifo #(axi_master_write_transaction_t)
        master_write_completion_fifos[];

    `uvm_component_utils(axi_vip_virtual_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (cfg == null) begin
            `uvm_fatal("AXI_VSQR_NOCFG",
                {"cfg must be assigned before build for: ",
                 get_full_name()})
        end

        master_read_sequencers = new[cfg.master_read_cfgs.size()];
        master_read_completion_fifos =
            new[cfg.master_read_cfgs.size()];
        foreach (cfg.master_read_cfgs[i]) begin
            if (cfg.master_read_cfgs[i] == null) begin
                `uvm_fatal("AXI_VSQR_CFG", $sformatf(
                    "Master Read cfg %0d is null", i))
            end
            if (cfg.master_read_cfgs[i].is_active == UVM_ACTIVE) begin
                master_read_completion_fifos[i] = new(
                    $sformatf("master_read_completion_fifo_%0d", i), this);
            end
        end

        master_write_sequencers = new[cfg.master_write_cfgs.size()];
        master_write_completion_fifos =
            new[cfg.master_write_cfgs.size()];
        foreach (cfg.master_write_cfgs[i]) begin
            if (cfg.master_write_cfgs[i] == null) begin
                `uvm_fatal("AXI_VSQR_CFG", $sformatf(
                    "Master Write cfg %0d is null", i))
            end
            if (cfg.master_write_cfgs[i].is_active == UVM_ACTIVE) begin
                master_write_completion_fifos[i] = new(
                    $sformatf("master_write_completion_fifo_%0d", i), this);
            end
        end
    endfunction : build_phase
endclass : axi_vip_virtual_sequencer

`endif
