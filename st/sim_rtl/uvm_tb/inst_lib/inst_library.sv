class inst_library extends uvm_object;

    inst_set_e support_inst_set[$];

    // RV32I
    `INST_DECLARATION(fence)
    `INST_DECLARATION(ecall)
    `INST_DECLARATION(ebreak)
    `INST_DECLARATION(add)
    `INST_DECLARATION(addi)
    `INST_DECLARATION(and)
    `INST_DECLARATION(andi)
    `INST_DECLARATION(auipc)
    `INST_DECLARATION(beq)
    `INST_DECLARATION(bge)
    `INST_DECLARATION(bgeu)
    `INST_DECLARATION(blt)
    `INST_DECLARATION(bltu)
    `INST_DECLARATION(bne)
    `INST_DECLARATION(jal)
    `INST_DECLARATION(jalr)
    `INST_DECLARATION(lui)
    `INST_DECLARATION(ori)
    `INST_DECLARATION(sll)
    `INST_DECLARATION(slli)
    `INST_DECLARATION(slt)
    `INST_DECLARATION(sltu)
    `INST_DECLARATION(slti)
    `INST_DECLARATION(sltiu)
    `INST_DECLARATION(sra)
    `INST_DECLARATION(srai)
    `INST_DECLARATION(srl)
    `INST_DECLARATION(srli)
    `INST_DECLARATION(sub)
    `INST_DECLARATION(xor)
    `INST_DECLARATION(xori)
    `INST_DECLARATION(or)
    `INST_DECLARATION(lb)
    `INST_DECLARATION(lbu)
    `INST_DECLARATION(lh)
    `INST_DECLARATION(lhu)
    `INST_DECLARATION(lw)
    `INST_DECLARATION(sb)
    `INST_DECLARATION(sh)
    `INST_DECLARATION(sw)

    // RV32M
    `INST_DECLARATION(div)
    `INST_DECLARATION(divu)
    `INST_DECLARATION(rem)
    `INST_DECLARATION(remu)
    `INST_DECLARATION(mul)
    `INST_DECLARATION(mulh)
    `INST_DECLARATION(mulhu)
    `INST_DECLARATION(mulhsu)

    // RV32A
    `INST_DECLARATION(amoadd_w)
    `INST_DECLARATION(amoand_w)
    `INST_DECLARATION(amoxor_w)
    `INST_DECLARATION(amoor_w)
    `INST_DECLARATION(amomin_w)
    `INST_DECLARATION(amominu_w)
    `INST_DECLARATION(amomax_w)
    `INST_DECLARATION(amomaxu_w)
    `INST_DECLARATION(amoswap_w)
    `INST_DECLARATION(lr_w)
    `INST_DECLARATION(sc_w)

    // RV32C
    `INST_DECLARATION(c_addi4spn)
    `INST_DECLARATION(c_nop)
    `INST_DECLARATION(c_addi)
    `INST_DECLARATION(c_li)
    `INST_DECLARATION(c_addi16sp)
    `INST_DECLARATION(c_lui)
    `INST_DECLARATION(c_srli)
    `INST_DECLARATION(c_srai)
    `INST_DECLARATION(c_andi)
    `INST_DECLARATION(c_sub)
    `INST_DECLARATION(c_xor)
    `INST_DECLARATION(c_or)
    `INST_DECLARATION(c_and)
    `INST_DECLARATION(c_slli)
    `INST_DECLARATION(c_mv)
    `INST_DECLARATION(c_add)
    `INST_DECLARATION(c_j)
    `INST_DECLARATION(c_jal)
    `INST_DECLARATION(c_beqz)
    `INST_DECLARATION(c_bnez)
    `INST_DECLARATION(c_jr)
    `INST_DECLARATION(c_jalr)
    `INST_DECLARATION(c_lw)
    `INST_DECLARATION(c_sw)
    `INST_DECLARATION(c_lwsp)
    `INST_DECLARATION(c_swsp)
    `INST_DECLARATION(c_ebreak)

    `CUSTOM_INST_DECLARATION(dsaw)
    `CUSTOM_INST_DECLARATION(dsawi)
    `CUSTOM_INST_DECLARATION(dsar)
    `CUSTOM_INST_DECLARATION(dsari)

    `uvm_object_utils(inst_library)

    riscv_inst inst_queue[$];
    int queue_size;
    int inst_exe_log;

    function new(string name="inst_library");
        super.new(name);
    endfunction : new

    extern virtual function void inst_queue_gen();
    extern virtual function void do_inst(
        ref csr_library csr_lib,
        ref dsa_mmio_library dsa_mmio_lib,
        ref reg_data_s gpr_s,
        ref mem_library mem_lib,
        bit [31:0] inst,
        ref core_state_s core_state
    );

endclass : inst_library

function void inst_library::do_inst(
    ref csr_library csr_lib,
    ref dsa_mmio_library dsa_mmio_lib,
    ref reg_data_s gpr_s,
    ref mem_library mem_lib,
    bit [31:0] inst,
    ref core_state_s core_state
);
    bit find_inst;

    find_inst = 1'b0;

    for(int i=0; i<queue_size; i++) begin
        if(inst_queue[i].inst_match(inst)) begin
            if(core_state.except == NONE_EXCEPT)
                inst_queue[i].inst_exe(inst, csr_lib, dsa_mmio_lib, gpr_s, mem_lib, core_state);

            find_inst = 1'b1;
            break;
        end
    end

    if(!find_inst)
        core_state.except = ILLEGAL_INST;
endfunction : do_inst

function void inst_library::inst_queue_gen();
    inst_queue.delete();

    if(RV32I inside support_inst_set)
        `RV32I_INST_REF_CREATE

    if(RV32M inside support_inst_set)
        `RV32M_INST_REF_CREATE

    if(RV32A inside support_inst_set)
        `RV32A_INST_REF_CREATE

    if(RV32C inside support_inst_set)
        `RV32C_INST_REF_CREATE

    if(CUSTOM inside support_inst_set)
        `CUSTOM_INST_REF_CREATE

    queue_size = inst_queue.size();
endfunction : inst_queue_gen