//------------------------------------------------------------------------------
// File         : vu_reg_creater.sv
// Description  : Auto-generated UVM component. Instantiates reg VIP and
//                creates registers / fields from the register spreadsheet.
// Source       : vu_dsa.xlsx
// Included by  : vu_reg_creater_pkg.sv
// Generator    : gen_reg_creater.py
// DO NOT EDIT  : re-run the generator after register-table updates.
//------------------------------------------------------------------------------

class vu_reg_creater extends uvm_component;
  `uvm_component_utils(vu_reg_creater)

  my_block m_my_block;
  string          hdl_path_prefix;

  function new(string name = "vu_reg_creater", uvm_component parent = null);
    super.new(name, parent);
    hdl_path_prefix = "";
  endfunction

  virtual function string make_hdl_path(string reg_name);
    if (hdl_path_prefix.len() == 0)
      return "";
    return {hdl_path_prefix, ".", reg_name};
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(string)::get(this, "", "hdl_path_prefix", hdl_path_prefix));
    m_my_block = my_block::type_id::create("m_my_block", this);
    create_registers();
  endfunction

  // create_reg  : create_reg(string name, int addr, int data, string hdl_path="")
  // create_field: create_field(int addr, string name, int start_bit, int end_bit, field_attr_e field_attr)
  virtual function void create_registers();

    //----- 动态参数寄存器 -----
    m_my_block.create_reg("macro_inst_trigger", 32'h00000000, 32'h00000000, make_hdl_path("macro_inst_trigger"));
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_STATIC_DYNAMIC_MASK", 0, 7, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_CONFIG_IDX", 8, 10, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_RESERVED_15_11", 11, 15, REG_RO);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_EVENT_EN", 16, 16, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_STREAM_ID_OVERRIDE", 17, 17, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_STREAM_ID", 18, 21, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_RESERVED_23_22", 22, 23, REG_RO);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_MACRO_INST_FENCE", 24, 24, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_DATA_BROADCAST", 25, 25, REG_RW);
    m_my_block.create_field(32'h00000000, "macro_inst_trigger_RESERVED_31_26", 26, 31, REG_RO);

    m_my_block.create_reg("TYPE_VL", 32'h00000004, 32'h00000000, make_hdl_path("TYPE_VL"));
    m_my_block.create_field(32'h00000004, "TYPE_VL_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00000004, "TYPE_VL_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00000004, "TYPE_VL_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00000004, "TYPE_VL_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("LD_addr", 32'h00000008, 32'h00000000, make_hdl_path("LD_addr"));
    m_my_block.create_field(32'h00000008, "LD_addr_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("ST_addr", 32'h0000000C, 32'h00000000, make_hdl_path("ST_addr"));
    m_my_block.create_field(32'h0000000C, "ST_addr_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("VRF_rd_index", 32'h00000010, 32'h00000000, make_hdl_path("VRF_rd_index"));
    m_my_block.create_field(32'h00000010, "VRF_rd_index_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00000010, "VRF_rd_index_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("VRF_wt_index", 32'h00000014, 32'h00000000, make_hdl_path("VRF_wt_index"));
    m_my_block.create_field(32'h00000014, "VRF_wt_index_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00000014, "VRF_wt_index_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("MRF_rd_index", 32'h00000018, 32'h00000000, make_hdl_path("MRF_rd_index"));
    m_my_block.create_field(32'h00000018, "MRF_rd_index_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00000018, "MRF_rd_index_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("MRF_wt_index", 32'h0000001C, 32'h00000000, make_hdl_path("MRF_wt_index"));
    m_my_block.create_field(32'h0000001C, "MRF_wt_index_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000001C, "MRF_wt_index_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("SRF_rd_index_0", 32'h00000020, 32'h00000000, make_hdl_path("SRF_rd_index_0"));
    m_my_block.create_field(32'h00000020, "SRF_rd_index_0_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00000020, "SRF_rd_index_0_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00000020, "SRF_rd_index_0_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00000020, "SRF_rd_index_0_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("SRF_rd_index_1", 32'h00000024, 32'h00000000, make_hdl_path("SRF_rd_index_1"));
    m_my_block.create_field(32'h00000024, "SRF_rd_index_1_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00000024, "SRF_rd_index_1_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00000024, "SRF_rd_index_1_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00000024, "SRF_rd_index_1_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("SRF_wt_index_0", 32'h00000028, 32'h00000000, make_hdl_path("SRF_wt_index_0"));
    m_my_block.create_field(32'h00000028, "SRF_wt_index_0_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00000028, "SRF_wt_index_0_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00000028, "SRF_wt_index_0_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00000028, "SRF_wt_index_0_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("SRF_wt_index_1", 32'h0000002C, 32'h00000000, make_hdl_path("SRF_wt_index_1"));
    m_my_block.create_field(32'h0000002C, "SRF_wt_index_1_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000002C, "SRF_wt_index_1_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000002C, "SRF_wt_index_1_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000002C, "SRF_wt_index_1_SRF_WT_P7_IDX", 24, 31, REG_RW);


    //----- 静态参数寄存器 -----
    m_my_block.create_reg("LU_op_g0", 32'h00001000, 32'h00000000, make_hdl_path("LU_op_g0"));
    m_my_block.create_field(32'h00001000, "LU_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001000, "LU_op_g0_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g0", 32'h00001004, 32'h00000000, make_hdl_path("SU_op_g0"));
    m_my_block.create_field(32'h00001004, "SU_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001004, "SU_op_g0_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001004, "SU_op_g0_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001004, "SU_op_g0_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g0", 32'h00001008, 32'h00000000, make_hdl_path("VALU0_op_g0"));
    m_my_block.create_field(32'h00001008, "VALU0_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001008, "VALU0_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001008, "VALU0_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001008, "VALU0_op_g0_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g0", 32'h0000100C, 32'h00000000, make_hdl_path("VALU1_op_g0"));
    m_my_block.create_field(32'h0000100C, "VALU1_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000100C, "VALU1_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000100C, "VALU1_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000100C, "VALU1_op_g0_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g0", 32'h00001010, 32'h00000000, make_hdl_path("VALU2_op_g0"));
    m_my_block.create_field(32'h00001010, "VALU2_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001010, "VALU2_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001010, "VALU2_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001010, "VALU2_op_g0_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g0", 32'h00001014, 32'h00000000, make_hdl_path("VSFU_op_g0"));
    m_my_block.create_field(32'h00001014, "VSFU_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001014, "VSFU_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001014, "VSFU_op_g0_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g0", 32'h00001018, 32'h00000000, make_hdl_path("MEXE_op_g0"));
    m_my_block.create_field(32'h00001018, "MEXE_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001018, "MEXE_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001018, "MEXE_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001018, "MEXE_op_g0_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g0", 32'h0000101C, 32'h00000000, make_hdl_path("SEXE0_op_g0"));
    m_my_block.create_field(32'h0000101C, "SEXE0_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000101C, "SEXE0_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000101C, "SEXE0_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000101C, "SEXE0_op_g0_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g0", 32'h00001020, 32'h00000000, make_hdl_path("SEXE1_op_g0"));
    m_my_block.create_field(32'h00001020, "SEXE1_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001020, "SEXE1_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001020, "SEXE1_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001020, "SEXE1_op_g0_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g0", 32'h00001024, 32'h00000000, make_hdl_path("SEXE2_op_g0"));
    m_my_block.create_field(32'h00001024, "SEXE2_op_g0_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001024, "SEXE2_op_g0_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001024, "SEXE2_op_g0_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001024, "SEXE2_op_g0_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g0", 32'h00001028, 32'h00000000, make_hdl_path("mask_op_g0"));
    m_my_block.create_field(32'h00001028, "mask_op_g0_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001028, "mask_op_g0_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001028, "mask_op_g0_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001028, "mask_op_g0_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001028, "mask_op_g0_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g0", 32'h0000102C, 32'h00000000, make_hdl_path("PRF_op_g0"));
    m_my_block.create_field(32'h0000102C, "PRF_op_g0_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000102C, "PRF_op_g0_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000102C, "PRF_op_g0_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000102C, "PRF_op_g0_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g0", 32'h00001030, 32'h00000000, make_hdl_path("static_TYPE_VL_g0"));
    m_my_block.create_field(32'h00001030, "static_TYPE_VL_g0_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001030, "static_TYPE_VL_g0_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001030, "static_TYPE_VL_g0_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001030, "static_TYPE_VL_g0_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g0", 32'h00001034, 32'h00000000, make_hdl_path("static_LD_addr_g0"));
    m_my_block.create_field(32'h00001034, "static_LD_addr_g0_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g0", 32'h00001038, 32'h00000000, make_hdl_path("static_ST_addr_g0"));
    m_my_block.create_field(32'h00001038, "static_ST_addr_g0_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g0", 32'h0000103C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g0"));
    m_my_block.create_field(32'h0000103C, "static_VRF_rd_index_g0_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000103C, "static_VRF_rd_index_g0_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g0", 32'h00001040, 32'h00000000, make_hdl_path("static_VRF_wt_index_g0"));
    m_my_block.create_field(32'h00001040, "static_VRF_wt_index_g0_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001040, "static_VRF_wt_index_g0_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g0", 32'h00001044, 32'h00000000, make_hdl_path("static_MRF_rd_index_g0"));
    m_my_block.create_field(32'h00001044, "static_MRF_rd_index_g0_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001044, "static_MRF_rd_index_g0_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g0", 32'h00001048, 32'h00000000, make_hdl_path("static_MRF_wt_index_g0"));
    m_my_block.create_field(32'h00001048, "static_MRF_wt_index_g0_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001048, "static_MRF_wt_index_g0_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g0", 32'h0000104C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g0"));
    m_my_block.create_field(32'h0000104C, "static_SRF_rd_index_0_g0_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000104C, "static_SRF_rd_index_0_g0_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000104C, "static_SRF_rd_index_0_g0_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000104C, "static_SRF_rd_index_0_g0_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g0", 32'h00001050, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g0"));
    m_my_block.create_field(32'h00001050, "static_SRF_rd_index_1_g0_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001050, "static_SRF_rd_index_1_g0_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001050, "static_SRF_rd_index_1_g0_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001050, "static_SRF_rd_index_1_g0_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g0", 32'h00001054, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g0"));
    m_my_block.create_field(32'h00001054, "static_SRF_wt_index_0_g0_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001054, "static_SRF_wt_index_0_g0_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001054, "static_SRF_wt_index_0_g0_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001054, "static_SRF_wt_index_0_g0_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g0", 32'h00001058, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g0"));
    m_my_block.create_field(32'h00001058, "static_SRF_wt_index_1_g0_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001058, "static_SRF_wt_index_1_g0_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001058, "static_SRF_wt_index_1_g0_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001058, "static_SRF_wt_index_1_g0_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g1", 32'h00001100, 32'h00000000, make_hdl_path("LU_op_g1"));
    m_my_block.create_field(32'h00001100, "LU_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001100, "LU_op_g1_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g1", 32'h00001104, 32'h00000000, make_hdl_path("SU_op_g1"));
    m_my_block.create_field(32'h00001104, "SU_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001104, "SU_op_g1_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001104, "SU_op_g1_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001104, "SU_op_g1_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g1", 32'h00001108, 32'h00000000, make_hdl_path("VALU0_op_g1"));
    m_my_block.create_field(32'h00001108, "VALU0_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001108, "VALU0_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001108, "VALU0_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001108, "VALU0_op_g1_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g1", 32'h0000110C, 32'h00000000, make_hdl_path("VALU1_op_g1"));
    m_my_block.create_field(32'h0000110C, "VALU1_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000110C, "VALU1_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000110C, "VALU1_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000110C, "VALU1_op_g1_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g1", 32'h00001110, 32'h00000000, make_hdl_path("VALU2_op_g1"));
    m_my_block.create_field(32'h00001110, "VALU2_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001110, "VALU2_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001110, "VALU2_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001110, "VALU2_op_g1_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g1", 32'h00001114, 32'h00000000, make_hdl_path("VSFU_op_g1"));
    m_my_block.create_field(32'h00001114, "VSFU_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001114, "VSFU_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001114, "VSFU_op_g1_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g1", 32'h00001118, 32'h00000000, make_hdl_path("MEXE_op_g1"));
    m_my_block.create_field(32'h00001118, "MEXE_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001118, "MEXE_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001118, "MEXE_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001118, "MEXE_op_g1_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g1", 32'h0000111C, 32'h00000000, make_hdl_path("SEXE0_op_g1"));
    m_my_block.create_field(32'h0000111C, "SEXE0_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000111C, "SEXE0_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000111C, "SEXE0_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000111C, "SEXE0_op_g1_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g1", 32'h00001120, 32'h00000000, make_hdl_path("SEXE1_op_g1"));
    m_my_block.create_field(32'h00001120, "SEXE1_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001120, "SEXE1_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001120, "SEXE1_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001120, "SEXE1_op_g1_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g1", 32'h00001124, 32'h00000000, make_hdl_path("SEXE2_op_g1"));
    m_my_block.create_field(32'h00001124, "SEXE2_op_g1_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001124, "SEXE2_op_g1_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001124, "SEXE2_op_g1_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001124, "SEXE2_op_g1_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g1", 32'h00001128, 32'h00000000, make_hdl_path("mask_op_g1"));
    m_my_block.create_field(32'h00001128, "mask_op_g1_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001128, "mask_op_g1_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001128, "mask_op_g1_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001128, "mask_op_g1_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001128, "mask_op_g1_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g1", 32'h0000112C, 32'h00000000, make_hdl_path("PRF_op_g1"));
    m_my_block.create_field(32'h0000112C, "PRF_op_g1_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000112C, "PRF_op_g1_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000112C, "PRF_op_g1_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000112C, "PRF_op_g1_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g1", 32'h00001130, 32'h00000000, make_hdl_path("static_TYPE_VL_g1"));
    m_my_block.create_field(32'h00001130, "static_TYPE_VL_g1_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001130, "static_TYPE_VL_g1_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001130, "static_TYPE_VL_g1_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001130, "static_TYPE_VL_g1_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g1", 32'h00001134, 32'h00000000, make_hdl_path("static_LD_addr_g1"));
    m_my_block.create_field(32'h00001134, "static_LD_addr_g1_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g1", 32'h00001138, 32'h00000000, make_hdl_path("static_ST_addr_g1"));
    m_my_block.create_field(32'h00001138, "static_ST_addr_g1_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g1", 32'h0000113C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g1"));
    m_my_block.create_field(32'h0000113C, "static_VRF_rd_index_g1_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000113C, "static_VRF_rd_index_g1_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g1", 32'h00001140, 32'h00000000, make_hdl_path("static_VRF_wt_index_g1"));
    m_my_block.create_field(32'h00001140, "static_VRF_wt_index_g1_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001140, "static_VRF_wt_index_g1_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g1", 32'h00001144, 32'h00000000, make_hdl_path("static_MRF_rd_index_g1"));
    m_my_block.create_field(32'h00001144, "static_MRF_rd_index_g1_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001144, "static_MRF_rd_index_g1_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g1", 32'h00001148, 32'h00000000, make_hdl_path("static_MRF_wt_index_g1"));
    m_my_block.create_field(32'h00001148, "static_MRF_wt_index_g1_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001148, "static_MRF_wt_index_g1_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g1", 32'h0000114C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g1"));
    m_my_block.create_field(32'h0000114C, "static_SRF_rd_index_0_g1_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000114C, "static_SRF_rd_index_0_g1_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000114C, "static_SRF_rd_index_0_g1_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000114C, "static_SRF_rd_index_0_g1_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g1", 32'h00001150, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g1"));
    m_my_block.create_field(32'h00001150, "static_SRF_rd_index_1_g1_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001150, "static_SRF_rd_index_1_g1_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001150, "static_SRF_rd_index_1_g1_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001150, "static_SRF_rd_index_1_g1_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g1", 32'h00001154, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g1"));
    m_my_block.create_field(32'h00001154, "static_SRF_wt_index_0_g1_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001154, "static_SRF_wt_index_0_g1_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001154, "static_SRF_wt_index_0_g1_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001154, "static_SRF_wt_index_0_g1_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g1", 32'h00001158, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g1"));
    m_my_block.create_field(32'h00001158, "static_SRF_wt_index_1_g1_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001158, "static_SRF_wt_index_1_g1_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001158, "static_SRF_wt_index_1_g1_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001158, "static_SRF_wt_index_1_g1_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g2", 32'h00001200, 32'h00000000, make_hdl_path("LU_op_g2"));
    m_my_block.create_field(32'h00001200, "LU_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001200, "LU_op_g2_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g2", 32'h00001204, 32'h00000000, make_hdl_path("SU_op_g2"));
    m_my_block.create_field(32'h00001204, "SU_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001204, "SU_op_g2_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001204, "SU_op_g2_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001204, "SU_op_g2_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g2", 32'h00001208, 32'h00000000, make_hdl_path("VALU0_op_g2"));
    m_my_block.create_field(32'h00001208, "VALU0_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001208, "VALU0_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001208, "VALU0_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001208, "VALU0_op_g2_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g2", 32'h0000120C, 32'h00000000, make_hdl_path("VALU1_op_g2"));
    m_my_block.create_field(32'h0000120C, "VALU1_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000120C, "VALU1_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000120C, "VALU1_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000120C, "VALU1_op_g2_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g2", 32'h00001210, 32'h00000000, make_hdl_path("VALU2_op_g2"));
    m_my_block.create_field(32'h00001210, "VALU2_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001210, "VALU2_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001210, "VALU2_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001210, "VALU2_op_g2_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g2", 32'h00001214, 32'h00000000, make_hdl_path("VSFU_op_g2"));
    m_my_block.create_field(32'h00001214, "VSFU_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001214, "VSFU_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001214, "VSFU_op_g2_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g2", 32'h00001218, 32'h00000000, make_hdl_path("MEXE_op_g2"));
    m_my_block.create_field(32'h00001218, "MEXE_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001218, "MEXE_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001218, "MEXE_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001218, "MEXE_op_g2_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g2", 32'h0000121C, 32'h00000000, make_hdl_path("SEXE0_op_g2"));
    m_my_block.create_field(32'h0000121C, "SEXE0_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000121C, "SEXE0_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000121C, "SEXE0_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000121C, "SEXE0_op_g2_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g2", 32'h00001220, 32'h00000000, make_hdl_path("SEXE1_op_g2"));
    m_my_block.create_field(32'h00001220, "SEXE1_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001220, "SEXE1_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001220, "SEXE1_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001220, "SEXE1_op_g2_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g2", 32'h00001224, 32'h00000000, make_hdl_path("SEXE2_op_g2"));
    m_my_block.create_field(32'h00001224, "SEXE2_op_g2_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001224, "SEXE2_op_g2_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001224, "SEXE2_op_g2_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001224, "SEXE2_op_g2_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g2", 32'h00001228, 32'h00000000, make_hdl_path("mask_op_g2"));
    m_my_block.create_field(32'h00001228, "mask_op_g2_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001228, "mask_op_g2_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001228, "mask_op_g2_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001228, "mask_op_g2_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001228, "mask_op_g2_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g2", 32'h0000122C, 32'h00000000, make_hdl_path("PRF_op_g2"));
    m_my_block.create_field(32'h0000122C, "PRF_op_g2_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000122C, "PRF_op_g2_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000122C, "PRF_op_g2_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000122C, "PRF_op_g2_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g2", 32'h00001230, 32'h00000000, make_hdl_path("static_TYPE_VL_g2"));
    m_my_block.create_field(32'h00001230, "static_TYPE_VL_g2_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001230, "static_TYPE_VL_g2_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001230, "static_TYPE_VL_g2_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001230, "static_TYPE_VL_g2_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g2", 32'h00001234, 32'h00000000, make_hdl_path("static_LD_addr_g2"));
    m_my_block.create_field(32'h00001234, "static_LD_addr_g2_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g2", 32'h00001238, 32'h00000000, make_hdl_path("static_ST_addr_g2"));
    m_my_block.create_field(32'h00001238, "static_ST_addr_g2_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g2", 32'h0000123C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g2"));
    m_my_block.create_field(32'h0000123C, "static_VRF_rd_index_g2_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000123C, "static_VRF_rd_index_g2_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g2", 32'h00001240, 32'h00000000, make_hdl_path("static_VRF_wt_index_g2"));
    m_my_block.create_field(32'h00001240, "static_VRF_wt_index_g2_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001240, "static_VRF_wt_index_g2_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g2", 32'h00001244, 32'h00000000, make_hdl_path("static_MRF_rd_index_g2"));
    m_my_block.create_field(32'h00001244, "static_MRF_rd_index_g2_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001244, "static_MRF_rd_index_g2_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g2", 32'h00001248, 32'h00000000, make_hdl_path("static_MRF_wt_index_g2"));
    m_my_block.create_field(32'h00001248, "static_MRF_wt_index_g2_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001248, "static_MRF_wt_index_g2_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g2", 32'h0000124C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g2"));
    m_my_block.create_field(32'h0000124C, "static_SRF_rd_index_0_g2_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000124C, "static_SRF_rd_index_0_g2_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000124C, "static_SRF_rd_index_0_g2_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000124C, "static_SRF_rd_index_0_g2_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g2", 32'h00001250, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g2"));
    m_my_block.create_field(32'h00001250, "static_SRF_rd_index_1_g2_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001250, "static_SRF_rd_index_1_g2_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001250, "static_SRF_rd_index_1_g2_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001250, "static_SRF_rd_index_1_g2_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g2", 32'h00001254, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g2"));
    m_my_block.create_field(32'h00001254, "static_SRF_wt_index_0_g2_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001254, "static_SRF_wt_index_0_g2_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001254, "static_SRF_wt_index_0_g2_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001254, "static_SRF_wt_index_0_g2_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g2", 32'h00001258, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g2"));
    m_my_block.create_field(32'h00001258, "static_SRF_wt_index_1_g2_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001258, "static_SRF_wt_index_1_g2_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001258, "static_SRF_wt_index_1_g2_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001258, "static_SRF_wt_index_1_g2_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g3", 32'h00001300, 32'h00000000, make_hdl_path("LU_op_g3"));
    m_my_block.create_field(32'h00001300, "LU_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001300, "LU_op_g3_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g3", 32'h00001304, 32'h00000000, make_hdl_path("SU_op_g3"));
    m_my_block.create_field(32'h00001304, "SU_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001304, "SU_op_g3_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001304, "SU_op_g3_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001304, "SU_op_g3_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g3", 32'h00001308, 32'h00000000, make_hdl_path("VALU0_op_g3"));
    m_my_block.create_field(32'h00001308, "VALU0_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001308, "VALU0_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001308, "VALU0_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001308, "VALU0_op_g3_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g3", 32'h0000130C, 32'h00000000, make_hdl_path("VALU1_op_g3"));
    m_my_block.create_field(32'h0000130C, "VALU1_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000130C, "VALU1_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000130C, "VALU1_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000130C, "VALU1_op_g3_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g3", 32'h00001310, 32'h00000000, make_hdl_path("VALU2_op_g3"));
    m_my_block.create_field(32'h00001310, "VALU2_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001310, "VALU2_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001310, "VALU2_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001310, "VALU2_op_g3_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g3", 32'h00001314, 32'h00000000, make_hdl_path("VSFU_op_g3"));
    m_my_block.create_field(32'h00001314, "VSFU_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001314, "VSFU_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001314, "VSFU_op_g3_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g3", 32'h00001318, 32'h00000000, make_hdl_path("MEXE_op_g3"));
    m_my_block.create_field(32'h00001318, "MEXE_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001318, "MEXE_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001318, "MEXE_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001318, "MEXE_op_g3_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g3", 32'h0000131C, 32'h00000000, make_hdl_path("SEXE0_op_g3"));
    m_my_block.create_field(32'h0000131C, "SEXE0_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000131C, "SEXE0_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000131C, "SEXE0_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000131C, "SEXE0_op_g3_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g3", 32'h00001320, 32'h00000000, make_hdl_path("SEXE1_op_g3"));
    m_my_block.create_field(32'h00001320, "SEXE1_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001320, "SEXE1_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001320, "SEXE1_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001320, "SEXE1_op_g3_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g3", 32'h00001324, 32'h00000000, make_hdl_path("SEXE2_op_g3"));
    m_my_block.create_field(32'h00001324, "SEXE2_op_g3_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001324, "SEXE2_op_g3_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001324, "SEXE2_op_g3_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001324, "SEXE2_op_g3_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g3", 32'h00001328, 32'h00000000, make_hdl_path("mask_op_g3"));
    m_my_block.create_field(32'h00001328, "mask_op_g3_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001328, "mask_op_g3_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001328, "mask_op_g3_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001328, "mask_op_g3_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001328, "mask_op_g3_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g3", 32'h0000132C, 32'h00000000, make_hdl_path("PRF_op_g3"));
    m_my_block.create_field(32'h0000132C, "PRF_op_g3_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000132C, "PRF_op_g3_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000132C, "PRF_op_g3_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000132C, "PRF_op_g3_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g3", 32'h00001330, 32'h00000000, make_hdl_path("static_TYPE_VL_g3"));
    m_my_block.create_field(32'h00001330, "static_TYPE_VL_g3_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001330, "static_TYPE_VL_g3_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001330, "static_TYPE_VL_g3_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001330, "static_TYPE_VL_g3_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g3", 32'h00001334, 32'h00000000, make_hdl_path("static_LD_addr_g3"));
    m_my_block.create_field(32'h00001334, "static_LD_addr_g3_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g3", 32'h00001338, 32'h00000000, make_hdl_path("static_ST_addr_g3"));
    m_my_block.create_field(32'h00001338, "static_ST_addr_g3_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g3", 32'h0000133C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g3"));
    m_my_block.create_field(32'h0000133C, "static_VRF_rd_index_g3_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000133C, "static_VRF_rd_index_g3_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g3", 32'h00001340, 32'h00000000, make_hdl_path("static_VRF_wt_index_g3"));
    m_my_block.create_field(32'h00001340, "static_VRF_wt_index_g3_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001340, "static_VRF_wt_index_g3_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g3", 32'h00001344, 32'h00000000, make_hdl_path("static_MRF_rd_index_g3"));
    m_my_block.create_field(32'h00001344, "static_MRF_rd_index_g3_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001344, "static_MRF_rd_index_g3_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g3", 32'h00001348, 32'h00000000, make_hdl_path("static_MRF_wt_index_g3"));
    m_my_block.create_field(32'h00001348, "static_MRF_wt_index_g3_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001348, "static_MRF_wt_index_g3_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g3", 32'h0000134C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g3"));
    m_my_block.create_field(32'h0000134C, "static_SRF_rd_index_0_g3_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000134C, "static_SRF_rd_index_0_g3_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000134C, "static_SRF_rd_index_0_g3_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000134C, "static_SRF_rd_index_0_g3_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g3", 32'h00001350, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g3"));
    m_my_block.create_field(32'h00001350, "static_SRF_rd_index_1_g3_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001350, "static_SRF_rd_index_1_g3_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001350, "static_SRF_rd_index_1_g3_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001350, "static_SRF_rd_index_1_g3_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g3", 32'h00001354, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g3"));
    m_my_block.create_field(32'h00001354, "static_SRF_wt_index_0_g3_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001354, "static_SRF_wt_index_0_g3_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001354, "static_SRF_wt_index_0_g3_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001354, "static_SRF_wt_index_0_g3_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g3", 32'h00001358, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g3"));
    m_my_block.create_field(32'h00001358, "static_SRF_wt_index_1_g3_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001358, "static_SRF_wt_index_1_g3_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001358, "static_SRF_wt_index_1_g3_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001358, "static_SRF_wt_index_1_g3_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g4", 32'h00001400, 32'h00000000, make_hdl_path("LU_op_g4"));
    m_my_block.create_field(32'h00001400, "LU_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001400, "LU_op_g4_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g4", 32'h00001404, 32'h00000000, make_hdl_path("SU_op_g4"));
    m_my_block.create_field(32'h00001404, "SU_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001404, "SU_op_g4_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001404, "SU_op_g4_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001404, "SU_op_g4_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g4", 32'h00001408, 32'h00000000, make_hdl_path("VALU0_op_g4"));
    m_my_block.create_field(32'h00001408, "VALU0_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001408, "VALU0_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001408, "VALU0_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001408, "VALU0_op_g4_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g4", 32'h0000140C, 32'h00000000, make_hdl_path("VALU1_op_g4"));
    m_my_block.create_field(32'h0000140C, "VALU1_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000140C, "VALU1_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000140C, "VALU1_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000140C, "VALU1_op_g4_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g4", 32'h00001410, 32'h00000000, make_hdl_path("VALU2_op_g4"));
    m_my_block.create_field(32'h00001410, "VALU2_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001410, "VALU2_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001410, "VALU2_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001410, "VALU2_op_g4_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g4", 32'h00001414, 32'h00000000, make_hdl_path("VSFU_op_g4"));
    m_my_block.create_field(32'h00001414, "VSFU_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001414, "VSFU_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001414, "VSFU_op_g4_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g4", 32'h00001418, 32'h00000000, make_hdl_path("MEXE_op_g4"));
    m_my_block.create_field(32'h00001418, "MEXE_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001418, "MEXE_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001418, "MEXE_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001418, "MEXE_op_g4_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g4", 32'h0000141C, 32'h00000000, make_hdl_path("SEXE0_op_g4"));
    m_my_block.create_field(32'h0000141C, "SEXE0_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000141C, "SEXE0_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000141C, "SEXE0_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000141C, "SEXE0_op_g4_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g4", 32'h00001420, 32'h00000000, make_hdl_path("SEXE1_op_g4"));
    m_my_block.create_field(32'h00001420, "SEXE1_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001420, "SEXE1_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001420, "SEXE1_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001420, "SEXE1_op_g4_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g4", 32'h00001424, 32'h00000000, make_hdl_path("SEXE2_op_g4"));
    m_my_block.create_field(32'h00001424, "SEXE2_op_g4_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001424, "SEXE2_op_g4_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001424, "SEXE2_op_g4_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001424, "SEXE2_op_g4_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g4", 32'h00001428, 32'h00000000, make_hdl_path("mask_op_g4"));
    m_my_block.create_field(32'h00001428, "mask_op_g4_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001428, "mask_op_g4_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001428, "mask_op_g4_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001428, "mask_op_g4_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001428, "mask_op_g4_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g4", 32'h0000142C, 32'h00000000, make_hdl_path("PRF_op_g4"));
    m_my_block.create_field(32'h0000142C, "PRF_op_g4_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000142C, "PRF_op_g4_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000142C, "PRF_op_g4_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000142C, "PRF_op_g4_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g4", 32'h00001430, 32'h00000000, make_hdl_path("static_TYPE_VL_g4"));
    m_my_block.create_field(32'h00001430, "static_TYPE_VL_g4_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001430, "static_TYPE_VL_g4_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001430, "static_TYPE_VL_g4_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001430, "static_TYPE_VL_g4_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g4", 32'h00001434, 32'h00000000, make_hdl_path("static_LD_addr_g4"));
    m_my_block.create_field(32'h00001434, "static_LD_addr_g4_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g4", 32'h00001438, 32'h00000000, make_hdl_path("static_ST_addr_g4"));
    m_my_block.create_field(32'h00001438, "static_ST_addr_g4_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g4", 32'h0000143C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g4"));
    m_my_block.create_field(32'h0000143C, "static_VRF_rd_index_g4_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000143C, "static_VRF_rd_index_g4_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g4", 32'h00001440, 32'h00000000, make_hdl_path("static_VRF_wt_index_g4"));
    m_my_block.create_field(32'h00001440, "static_VRF_wt_index_g4_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001440, "static_VRF_wt_index_g4_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g4", 32'h00001444, 32'h00000000, make_hdl_path("static_MRF_rd_index_g4"));
    m_my_block.create_field(32'h00001444, "static_MRF_rd_index_g4_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001444, "static_MRF_rd_index_g4_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g4", 32'h00001448, 32'h00000000, make_hdl_path("static_MRF_wt_index_g4"));
    m_my_block.create_field(32'h00001448, "static_MRF_wt_index_g4_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001448, "static_MRF_wt_index_g4_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g4", 32'h0000144C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g4"));
    m_my_block.create_field(32'h0000144C, "static_SRF_rd_index_0_g4_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000144C, "static_SRF_rd_index_0_g4_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000144C, "static_SRF_rd_index_0_g4_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000144C, "static_SRF_rd_index_0_g4_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g4", 32'h00001450, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g4"));
    m_my_block.create_field(32'h00001450, "static_SRF_rd_index_1_g4_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001450, "static_SRF_rd_index_1_g4_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001450, "static_SRF_rd_index_1_g4_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001450, "static_SRF_rd_index_1_g4_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g4", 32'h00001454, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g4"));
    m_my_block.create_field(32'h00001454, "static_SRF_wt_index_0_g4_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001454, "static_SRF_wt_index_0_g4_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001454, "static_SRF_wt_index_0_g4_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001454, "static_SRF_wt_index_0_g4_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g4", 32'h00001458, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g4"));
    m_my_block.create_field(32'h00001458, "static_SRF_wt_index_1_g4_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001458, "static_SRF_wt_index_1_g4_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001458, "static_SRF_wt_index_1_g4_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001458, "static_SRF_wt_index_1_g4_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g5", 32'h00001500, 32'h00000000, make_hdl_path("LU_op_g5"));
    m_my_block.create_field(32'h00001500, "LU_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001500, "LU_op_g5_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g5", 32'h00001504, 32'h00000000, make_hdl_path("SU_op_g5"));
    m_my_block.create_field(32'h00001504, "SU_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001504, "SU_op_g5_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001504, "SU_op_g5_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001504, "SU_op_g5_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g5", 32'h00001508, 32'h00000000, make_hdl_path("VALU0_op_g5"));
    m_my_block.create_field(32'h00001508, "VALU0_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001508, "VALU0_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001508, "VALU0_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001508, "VALU0_op_g5_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g5", 32'h0000150C, 32'h00000000, make_hdl_path("VALU1_op_g5"));
    m_my_block.create_field(32'h0000150C, "VALU1_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000150C, "VALU1_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000150C, "VALU1_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000150C, "VALU1_op_g5_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g5", 32'h00001510, 32'h00000000, make_hdl_path("VALU2_op_g5"));
    m_my_block.create_field(32'h00001510, "VALU2_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001510, "VALU2_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001510, "VALU2_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001510, "VALU2_op_g5_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g5", 32'h00001514, 32'h00000000, make_hdl_path("VSFU_op_g5"));
    m_my_block.create_field(32'h00001514, "VSFU_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001514, "VSFU_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001514, "VSFU_op_g5_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g5", 32'h00001518, 32'h00000000, make_hdl_path("MEXE_op_g5"));
    m_my_block.create_field(32'h00001518, "MEXE_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001518, "MEXE_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001518, "MEXE_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001518, "MEXE_op_g5_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g5", 32'h0000151C, 32'h00000000, make_hdl_path("SEXE0_op_g5"));
    m_my_block.create_field(32'h0000151C, "SEXE0_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000151C, "SEXE0_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000151C, "SEXE0_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000151C, "SEXE0_op_g5_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g5", 32'h00001520, 32'h00000000, make_hdl_path("SEXE1_op_g5"));
    m_my_block.create_field(32'h00001520, "SEXE1_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001520, "SEXE1_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001520, "SEXE1_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001520, "SEXE1_op_g5_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g5", 32'h00001524, 32'h00000000, make_hdl_path("SEXE2_op_g5"));
    m_my_block.create_field(32'h00001524, "SEXE2_op_g5_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001524, "SEXE2_op_g5_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001524, "SEXE2_op_g5_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001524, "SEXE2_op_g5_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g5", 32'h00001528, 32'h00000000, make_hdl_path("mask_op_g5"));
    m_my_block.create_field(32'h00001528, "mask_op_g5_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001528, "mask_op_g5_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001528, "mask_op_g5_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001528, "mask_op_g5_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001528, "mask_op_g5_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g5", 32'h0000152C, 32'h00000000, make_hdl_path("PRF_op_g5"));
    m_my_block.create_field(32'h0000152C, "PRF_op_g5_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000152C, "PRF_op_g5_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000152C, "PRF_op_g5_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000152C, "PRF_op_g5_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g5", 32'h00001530, 32'h00000000, make_hdl_path("static_TYPE_VL_g5"));
    m_my_block.create_field(32'h00001530, "static_TYPE_VL_g5_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001530, "static_TYPE_VL_g5_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001530, "static_TYPE_VL_g5_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001530, "static_TYPE_VL_g5_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g5", 32'h00001534, 32'h00000000, make_hdl_path("static_LD_addr_g5"));
    m_my_block.create_field(32'h00001534, "static_LD_addr_g5_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g5", 32'h00001538, 32'h00000000, make_hdl_path("static_ST_addr_g5"));
    m_my_block.create_field(32'h00001538, "static_ST_addr_g5_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g5", 32'h0000153C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g5"));
    m_my_block.create_field(32'h0000153C, "static_VRF_rd_index_g5_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000153C, "static_VRF_rd_index_g5_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g5", 32'h00001540, 32'h00000000, make_hdl_path("static_VRF_wt_index_g5"));
    m_my_block.create_field(32'h00001540, "static_VRF_wt_index_g5_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001540, "static_VRF_wt_index_g5_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g5", 32'h00001544, 32'h00000000, make_hdl_path("static_MRF_rd_index_g5"));
    m_my_block.create_field(32'h00001544, "static_MRF_rd_index_g5_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001544, "static_MRF_rd_index_g5_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g5", 32'h00001548, 32'h00000000, make_hdl_path("static_MRF_wt_index_g5"));
    m_my_block.create_field(32'h00001548, "static_MRF_wt_index_g5_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001548, "static_MRF_wt_index_g5_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g5", 32'h0000154C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g5"));
    m_my_block.create_field(32'h0000154C, "static_SRF_rd_index_0_g5_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000154C, "static_SRF_rd_index_0_g5_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000154C, "static_SRF_rd_index_0_g5_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000154C, "static_SRF_rd_index_0_g5_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g5", 32'h00001550, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g5"));
    m_my_block.create_field(32'h00001550, "static_SRF_rd_index_1_g5_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001550, "static_SRF_rd_index_1_g5_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001550, "static_SRF_rd_index_1_g5_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001550, "static_SRF_rd_index_1_g5_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g5", 32'h00001554, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g5"));
    m_my_block.create_field(32'h00001554, "static_SRF_wt_index_0_g5_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001554, "static_SRF_wt_index_0_g5_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001554, "static_SRF_wt_index_0_g5_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001554, "static_SRF_wt_index_0_g5_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g5", 32'h00001558, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g5"));
    m_my_block.create_field(32'h00001558, "static_SRF_wt_index_1_g5_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001558, "static_SRF_wt_index_1_g5_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001558, "static_SRF_wt_index_1_g5_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001558, "static_SRF_wt_index_1_g5_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g6", 32'h00001600, 32'h00000000, make_hdl_path("LU_op_g6"));
    m_my_block.create_field(32'h00001600, "LU_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001600, "LU_op_g6_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g6", 32'h00001604, 32'h00000000, make_hdl_path("SU_op_g6"));
    m_my_block.create_field(32'h00001604, "SU_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001604, "SU_op_g6_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001604, "SU_op_g6_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001604, "SU_op_g6_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g6", 32'h00001608, 32'h00000000, make_hdl_path("VALU0_op_g6"));
    m_my_block.create_field(32'h00001608, "VALU0_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001608, "VALU0_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001608, "VALU0_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001608, "VALU0_op_g6_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g6", 32'h0000160C, 32'h00000000, make_hdl_path("VALU1_op_g6"));
    m_my_block.create_field(32'h0000160C, "VALU1_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000160C, "VALU1_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000160C, "VALU1_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000160C, "VALU1_op_g6_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g6", 32'h00001610, 32'h00000000, make_hdl_path("VALU2_op_g6"));
    m_my_block.create_field(32'h00001610, "VALU2_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001610, "VALU2_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001610, "VALU2_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001610, "VALU2_op_g6_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g6", 32'h00001614, 32'h00000000, make_hdl_path("VSFU_op_g6"));
    m_my_block.create_field(32'h00001614, "VSFU_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001614, "VSFU_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001614, "VSFU_op_g6_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g6", 32'h00001618, 32'h00000000, make_hdl_path("MEXE_op_g6"));
    m_my_block.create_field(32'h00001618, "MEXE_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001618, "MEXE_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001618, "MEXE_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001618, "MEXE_op_g6_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g6", 32'h0000161C, 32'h00000000, make_hdl_path("SEXE0_op_g6"));
    m_my_block.create_field(32'h0000161C, "SEXE0_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000161C, "SEXE0_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000161C, "SEXE0_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000161C, "SEXE0_op_g6_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g6", 32'h00001620, 32'h00000000, make_hdl_path("SEXE1_op_g6"));
    m_my_block.create_field(32'h00001620, "SEXE1_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001620, "SEXE1_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001620, "SEXE1_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001620, "SEXE1_op_g6_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g6", 32'h00001624, 32'h00000000, make_hdl_path("SEXE2_op_g6"));
    m_my_block.create_field(32'h00001624, "SEXE2_op_g6_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001624, "SEXE2_op_g6_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001624, "SEXE2_op_g6_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001624, "SEXE2_op_g6_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g6", 32'h00001628, 32'h00000000, make_hdl_path("mask_op_g6"));
    m_my_block.create_field(32'h00001628, "mask_op_g6_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001628, "mask_op_g6_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001628, "mask_op_g6_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001628, "mask_op_g6_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001628, "mask_op_g6_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g6", 32'h0000162C, 32'h00000000, make_hdl_path("PRF_op_g6"));
    m_my_block.create_field(32'h0000162C, "PRF_op_g6_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000162C, "PRF_op_g6_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000162C, "PRF_op_g6_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000162C, "PRF_op_g6_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g6", 32'h00001630, 32'h00000000, make_hdl_path("static_TYPE_VL_g6"));
    m_my_block.create_field(32'h00001630, "static_TYPE_VL_g6_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001630, "static_TYPE_VL_g6_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001630, "static_TYPE_VL_g6_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001630, "static_TYPE_VL_g6_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g6", 32'h00001634, 32'h00000000, make_hdl_path("static_LD_addr_g6"));
    m_my_block.create_field(32'h00001634, "static_LD_addr_g6_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g6", 32'h00001638, 32'h00000000, make_hdl_path("static_ST_addr_g6"));
    m_my_block.create_field(32'h00001638, "static_ST_addr_g6_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g6", 32'h0000163C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g6"));
    m_my_block.create_field(32'h0000163C, "static_VRF_rd_index_g6_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000163C, "static_VRF_rd_index_g6_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g6", 32'h00001640, 32'h00000000, make_hdl_path("static_VRF_wt_index_g6"));
    m_my_block.create_field(32'h00001640, "static_VRF_wt_index_g6_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001640, "static_VRF_wt_index_g6_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g6", 32'h00001644, 32'h00000000, make_hdl_path("static_MRF_rd_index_g6"));
    m_my_block.create_field(32'h00001644, "static_MRF_rd_index_g6_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001644, "static_MRF_rd_index_g6_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g6", 32'h00001648, 32'h00000000, make_hdl_path("static_MRF_wt_index_g6"));
    m_my_block.create_field(32'h00001648, "static_MRF_wt_index_g6_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001648, "static_MRF_wt_index_g6_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g6", 32'h0000164C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g6"));
    m_my_block.create_field(32'h0000164C, "static_SRF_rd_index_0_g6_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000164C, "static_SRF_rd_index_0_g6_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000164C, "static_SRF_rd_index_0_g6_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000164C, "static_SRF_rd_index_0_g6_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g6", 32'h00001650, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g6"));
    m_my_block.create_field(32'h00001650, "static_SRF_rd_index_1_g6_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001650, "static_SRF_rd_index_1_g6_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001650, "static_SRF_rd_index_1_g6_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001650, "static_SRF_rd_index_1_g6_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g6", 32'h00001654, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g6"));
    m_my_block.create_field(32'h00001654, "static_SRF_wt_index_0_g6_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001654, "static_SRF_wt_index_0_g6_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001654, "static_SRF_wt_index_0_g6_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001654, "static_SRF_wt_index_0_g6_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g6", 32'h00001658, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g6"));
    m_my_block.create_field(32'h00001658, "static_SRF_wt_index_1_g6_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001658, "static_SRF_wt_index_1_g6_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001658, "static_SRF_wt_index_1_g6_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001658, "static_SRF_wt_index_1_g6_SRF_WT_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("LU_op_g7", 32'h00001700, 32'h00000000, make_hdl_path("LU_op_g7"));
    m_my_block.create_field(32'h00001700, "LU_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001700, "LU_op_g7_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("SU_op_g7", 32'h00001704, 32'h00000000, make_hdl_path("SU_op_g7"));
    m_my_block.create_field(32'h00001704, "SU_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001704, "SU_op_g7_SRC_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001704, "SU_op_g7_MXFP8_SCALE_ROUND", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001704, "SU_op_g7_RESERVED_31_17", 17, 31, REG_RW);

    m_my_block.create_reg("VALU0_op_g7", 32'h00001708, 32'h00000000, make_hdl_path("VALU0_op_g7"));
    m_my_block.create_field(32'h00001708, "VALU0_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001708, "VALU0_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001708, "VALU0_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001708, "VALU0_op_g7_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU1_op_g7", 32'h0000170C, 32'h00000000, make_hdl_path("VALU1_op_g7"));
    m_my_block.create_field(32'h0000170C, "VALU1_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000170C, "VALU1_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000170C, "VALU1_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000170C, "VALU1_op_g7_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VALU2_op_g7", 32'h00001710, 32'h00000000, make_hdl_path("VALU2_op_g7"));
    m_my_block.create_field(32'h00001710, "VALU2_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001710, "VALU2_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001710, "VALU2_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001710, "VALU2_op_g7_SRC3_SEL", 24, 31, REG_RW);

    m_my_block.create_reg("VSFU_op_g7", 32'h00001714, 32'h00000000, make_hdl_path("VSFU_op_g7"));
    m_my_block.create_field(32'h00001714, "VSFU_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001714, "VSFU_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001714, "VSFU_op_g7_RESERVED_31_16", 16, 31, REG_RW);

    m_my_block.create_reg("MEXE_op_g7", 32'h00001718, 32'h00000000, make_hdl_path("MEXE_op_g7"));
    m_my_block.create_field(32'h00001718, "MEXE_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001718, "MEXE_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001718, "MEXE_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001718, "MEXE_op_g7_RESERVED_31_24", 24, 31, REG_RW);

    m_my_block.create_reg("SEXE0_op_g7", 32'h0000171C, 32'h00000000, make_hdl_path("SEXE0_op_g7"));
    m_my_block.create_field(32'h0000171C, "SEXE0_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000171C, "SEXE0_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000171C, "SEXE0_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000171C, "SEXE0_op_g7_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE1_op_g7", 32'h00001720, 32'h00000000, make_hdl_path("SEXE1_op_g7"));
    m_my_block.create_field(32'h00001720, "SEXE1_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001720, "SEXE1_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001720, "SEXE1_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001720, "SEXE1_op_g7_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("SEXE2_op_g7", 32'h00001724, 32'h00000000, make_hdl_path("SEXE2_op_g7"));
    m_my_block.create_field(32'h00001724, "SEXE2_op_g7_OPCODE", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001724, "SEXE2_op_g7_SRC1_SEL", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001724, "SEXE2_op_g7_SRC2_SEL", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001724, "SEXE2_op_g7_RESERVED_31_24", 24, 31, REG_RO);

    m_my_block.create_reg("mask_op_g7", 32'h00001728, 32'h00000000, make_hdl_path("mask_op_g7"));
    m_my_block.create_field(32'h00001728, "mask_op_g7_VALU0_MASK_SEL", 0, 1, REG_RW);
    m_my_block.create_field(32'h00001728, "mask_op_g7_VALU1_MASK_SEL", 2, 3, REG_RW);
    m_my_block.create_field(32'h00001728, "mask_op_g7_VALU2_MASK_SEL", 4, 5, REG_RW);
    m_my_block.create_field(32'h00001728, "mask_op_g7_VSFU_MASK_SEL", 6, 7, REG_RW);
    m_my_block.create_field(32'h00001728, "mask_op_g7_RESERVED_31_8", 8, 31, REG_RO);

    m_my_block.create_reg("PRF_op_g7", 32'h0000172C, 32'h00000000, make_hdl_path("PRF_op_g7"));
    m_my_block.create_field(32'h0000172C, "PRF_op_g7_VRF_WT_P0_SRC", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000172C, "PRF_op_g7_VRF_WT_P1_SRC", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000172C, "PRF_op_g7_MRF_WT_SRC", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000172C, "PRF_op_g7_SRF_WT_EN", 24, 31, REG_RW);

    m_my_block.create_reg("static_TYPE_VL_g7", 32'h00001730, 32'h00000000, make_hdl_path("static_TYPE_VL_g7"));
    m_my_block.create_field(32'h00001730, "static_TYPE_VL_g7_VL", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001730, "static_TYPE_VL_g7_DATA_TYPE", 16, 16, REG_RW);
    m_my_block.create_field(32'h00001730, "static_TYPE_VL_g7_ROUND_MODE", 17, 19, REG_RW);
    m_my_block.create_field(32'h00001730, "static_TYPE_VL_g7_RESERVED_31_20", 20, 31, REG_RO);

    m_my_block.create_reg("static_LD_addr_g7", 32'h00001734, 32'h00000000, make_hdl_path("static_LD_addr_g7"));
    m_my_block.create_field(32'h00001734, "static_LD_addr_g7_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_ST_addr_g7", 32'h00001738, 32'h00000000, make_hdl_path("static_ST_addr_g7"));
    m_my_block.create_field(32'h00001738, "static_ST_addr_g7_CM_ADDR", 0, 31, REG_RW);

    m_my_block.create_reg("static_VRF_rd_index_g7", 32'h0000173C, 32'h00000000, make_hdl_path("static_VRF_rd_index_g7"));
    m_my_block.create_field(32'h0000173C, "static_VRF_rd_index_g7_VRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000173C, "static_VRF_rd_index_g7_VRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_VRF_wt_index_g7", 32'h00001740, 32'h00000000, make_hdl_path("static_VRF_wt_index_g7"));
    m_my_block.create_field(32'h00001740, "static_VRF_wt_index_g7_VRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001740, "static_VRF_wt_index_g7_VRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_rd_index_g7", 32'h00001744, 32'h00000000, make_hdl_path("static_MRF_rd_index_g7"));
    m_my_block.create_field(32'h00001744, "static_MRF_rd_index_g7_MRF_RD_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001744, "static_MRF_rd_index_g7_MRF_RD_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_MRF_wt_index_g7", 32'h00001748, 32'h00000000, make_hdl_path("static_MRF_wt_index_g7"));
    m_my_block.create_field(32'h00001748, "static_MRF_wt_index_g7_MRF_WT_P0_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h00001748, "static_MRF_wt_index_g7_MRF_WT_P1_IDX", 16, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_0_g7", 32'h0000174C, 32'h00000000, make_hdl_path("static_SRF_rd_index_0_g7"));
    m_my_block.create_field(32'h0000174C, "static_SRF_rd_index_0_g7_SRF_RD_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h0000174C, "static_SRF_rd_index_0_g7_SRF_RD_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h0000174C, "static_SRF_rd_index_0_g7_SRF_RD_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h0000174C, "static_SRF_rd_index_0_g7_SRF_RD_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_rd_index_1_g7", 32'h00001750, 32'h00000000, make_hdl_path("static_SRF_rd_index_1_g7"));
    m_my_block.create_field(32'h00001750, "static_SRF_rd_index_1_g7_SRF_RD_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001750, "static_SRF_rd_index_1_g7_SRF_RD_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001750, "static_SRF_rd_index_1_g7_SRF_RD_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001750, "static_SRF_rd_index_1_g7_SRF_RD_P7_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_0_g7", 32'h00001754, 32'h00000000, make_hdl_path("static_SRF_wt_index_0_g7"));
    m_my_block.create_field(32'h00001754, "static_SRF_wt_index_0_g7_SRF_WT_P0_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001754, "static_SRF_wt_index_0_g7_SRF_WT_P1_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001754, "static_SRF_wt_index_0_g7_SRF_WT_P2_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001754, "static_SRF_wt_index_0_g7_SRF_WT_P3_IDX", 24, 31, REG_RW);

    m_my_block.create_reg("static_SRF_wt_index_1_g7", 32'h00001758, 32'h00000000, make_hdl_path("static_SRF_wt_index_1_g7"));
    m_my_block.create_field(32'h00001758, "static_SRF_wt_index_1_g7_SRF_WT_P4_IDX", 0, 7, REG_RW);
    m_my_block.create_field(32'h00001758, "static_SRF_wt_index_1_g7_SRF_WT_P5_IDX", 8, 15, REG_RW);
    m_my_block.create_field(32'h00001758, "static_SRF_wt_index_1_g7_SRF_WT_P6_IDX", 16, 23, REG_RW);
    m_my_block.create_field(32'h00001758, "static_SRF_wt_index_1_g7_SRF_WT_P7_IDX", 24, 31, REG_RW);


    //----- DSA-RF读写寄存器 -----
    m_my_block.create_reg("reg_file_addr", 32'h00002000, 32'h00000000, make_hdl_path("reg_file_addr"));
    m_my_block.create_field(32'h00002000, "reg_file_addr_RF_ADDR", 0, 15, REG_RW);
    m_my_block.create_field(32'h00002000, "reg_file_addr_RF_SEL", 16, 17, REG_RW);
    m_my_block.create_field(32'h00002000, "reg_file_addr_RESERVED_31_18", 18, 31, REG_RO);

    m_my_block.create_reg("reg_file_data", 32'h00002004, 32'h00000000, make_hdl_path("reg_file_data"));
    m_my_block.create_field(32'h00002004, "reg_file_data_RF_DATA", 0, 31, REG_RW);


    //----- 状态寄存器 -----
    m_my_block.create_reg("macro_inst_left", 32'h00003000, 32'h00000000, make_hdl_path("macro_inst_left"));
    m_my_block.create_field(32'h00003000, "macro_inst_left_MACRO_INST_LEFT", 0, 31, REG_RO);

    m_my_block.create_reg("status", 32'h00003004, 32'h00000000, make_hdl_path("status"));
    m_my_block.create_field(32'h00003004, "status_BUSY", 0, 0, REG_RO);
    m_my_block.create_field(32'h00003004, "status_ISQ_FULL", 1, 1, REG_RO);
    m_my_block.create_field(32'h00003004, "status_ISQ_EMPTY", 2, 2, REG_RO);
    m_my_block.create_field(32'h00003004, "status_ERROR_FLAG", 3, 3, REG_RO);
    m_my_block.create_field(32'h00003004, "status_RESERVED_31_4", 4, 31, REG_RO);

    m_my_block.create_reg("error_code", 32'h00003008, 32'h00000000, make_hdl_path("error_code"));
    m_my_block.create_field(32'h00003008, "error_code_REG_ADDR_ERROR", 0, 0, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_RESERVED_1_1", 1, 1, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_CFG_ERROR", 2, 2, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_RF_IDX_ERROR", 3, 3, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_CM_ADDR_ERROR", 4, 4, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_CM_RESP_ERROR", 5, 5, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_DATA_CVT_ERROR", 6, 6, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_RESERVED_31_7", 7, 31, REG_RO);


    //----- profile -----
    m_my_block.create_reg("profile_ctrl", 32'h00004000, 32'h00000000, make_hdl_path("profile_ctrl"));
    m_my_block.create_field(32'h00004000, "profile_ctrl_RUN", 0, 0, REG_RW);
    m_my_block.create_field(32'h00004000, "profile_ctrl_CLEAR", 1, 1, REG_RW);
    m_my_block.create_field(32'h00004000, "profile_ctrl_RESERVED_31_2", 2, 31, REG_RO);

    m_my_block.create_reg("prof_run_cycle_lo", 32'h00004008, 32'h00000000, make_hdl_path("prof_run_cycle_lo"));
    m_my_block.create_field(32'h00004008, "prof_run_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("prof_run_cycle_hi", 32'h0000400C, 32'h00000000, make_hdl_path("prof_run_cycle_hi"));
    m_my_block.create_field(32'h0000400C, "prof_run_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("total_busy_cycle_lo", 32'h00004010, 32'h00000000, make_hdl_path("total_busy_cycle_lo"));
    m_my_block.create_field(32'h00004010, "total_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("total_busy_cycle_hi", 32'h00004014, 32'h00000000, make_hdl_path("total_busy_cycle_hi"));
    m_my_block.create_field(32'h00004014, "total_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cfg_wr_num_lo", 32'h00004018, 32'h00000000, make_hdl_path("cfg_wr_num_lo"));
    m_my_block.create_field(32'h00004018, "cfg_wr_num_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cfg_wr_num_hi", 32'h0000401C, 32'h00000000, make_hdl_path("cfg_wr_num_hi"));
    m_my_block.create_field(32'h0000401C, "cfg_wr_num_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cfg_wr_stall_cycle_lo", 32'h00004020, 32'h00000000, make_hdl_path("cfg_wr_stall_cycle_lo"));
    m_my_block.create_field(32'h00004020, "cfg_wr_stall_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cfg_wr_stall_cycle_hi", 32'h00004024, 32'h00000000, make_hdl_path("cfg_wr_stall_cycle_hi"));
    m_my_block.create_field(32'h00004024, "cfg_wr_stall_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("macro_inst_total_num_lo", 32'h00004028, 32'h00000000, make_hdl_path("macro_inst_total_num_lo"));
    m_my_block.create_field(32'h00004028, "macro_inst_total_num_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("macro_inst_total_num_hi", 32'h0000402C, 32'h00000000, make_hdl_path("macro_inst_total_num_hi"));
    m_my_block.create_field(32'h0000402C, "macro_inst_total_num_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("macro_inst_retire_num_lo", 32'h00004030, 32'h00000000, make_hdl_path("macro_inst_retire_num_lo"));
    m_my_block.create_field(32'h00004030, "macro_inst_retire_num_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("macro_inst_retire_num_hi", 32'h00004034, 32'h00000000, make_hdl_path("macro_inst_retire_num_hi"));
    m_my_block.create_field(32'h00004034, "macro_inst_retire_num_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("isq_full_cycle_lo", 32'h00004038, 32'h00000000, make_hdl_path("isq_full_cycle_lo"));
    m_my_block.create_field(32'h00004038, "isq_full_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("isq_full_cycle_hi", 32'h0000403C, 32'h00000000, make_hdl_path("isq_full_cycle_hi"));
    m_my_block.create_field(32'h0000403C, "isq_full_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_fence_cycle_lo", 32'h00004040, 32'h00000000, make_hdl_path("issue_stall_fence_cycle_lo"));
    m_my_block.create_field(32'h00004040, "issue_stall_fence_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_fence_cycle_hi", 32'h00004044, 32'h00000000, make_hdl_path("issue_stall_fence_cycle_hi"));
    m_my_block.create_field(32'h00004044, "issue_stall_fence_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_bcast_cycle_lo", 32'h00004048, 32'h00000000, make_hdl_path("issue_stall_bcast_cycle_lo"));
    m_my_block.create_field(32'h00004048, "issue_stall_bcast_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_bcast_cycle_hi", 32'h0000404C, 32'h00000000, make_hdl_path("issue_stall_bcast_cycle_hi"));
    m_my_block.create_field(32'h0000404C, "issue_stall_bcast_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_dep_cycle_lo", 32'h00004050, 32'h00000000, make_hdl_path("issue_stall_dep_cycle_lo"));
    m_my_block.create_field(32'h00004050, "issue_stall_dep_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_dep_cycle_hi", 32'h00004054, 32'h00000000, make_hdl_path("issue_stall_dep_cycle_hi"));
    m_my_block.create_field(32'h00004054, "issue_stall_dep_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_eu_cycle_lo", 32'h00004058, 32'h00000000, make_hdl_path("issue_stall_eu_cycle_lo"));
    m_my_block.create_field(32'h00004058, "issue_stall_eu_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_stall_eu_cycle_hi", 32'h0000405C, 32'h00000000, make_hdl_path("issue_stall_eu_cycle_hi"));
    m_my_block.create_field(32'h0000405C, "issue_stall_eu_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_starve_cycle_lo", 32'h00004060, 32'h00000000, make_hdl_path("issue_starve_cycle_lo"));
    m_my_block.create_field(32'h00004060, "issue_starve_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("issue_starve_cycle_hi", 32'h00004064, 32'h00000000, make_hdl_path("issue_starve_cycle_hi"));
    m_my_block.create_field(32'h00004064, "issue_starve_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("lu_busy_cycle_lo", 32'h00004068, 32'h00000000, make_hdl_path("lu_busy_cycle_lo"));
    m_my_block.create_field(32'h00004068, "lu_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("lu_busy_cycle_hi", 32'h0000406C, 32'h00000000, make_hdl_path("lu_busy_cycle_hi"));
    m_my_block.create_field(32'h0000406C, "lu_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_ld_req_num_lo", 32'h00004070, 32'h00000000, make_hdl_path("cm_ld_req_num_lo"));
    m_my_block.create_field(32'h00004070, "cm_ld_req_num_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_ld_req_num_hi", 32'h00004074, 32'h00000000, make_hdl_path("cm_ld_req_num_hi"));
    m_my_block.create_field(32'h00004074, "cm_ld_req_num_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_ld_stall_cycle_lo", 32'h00004078, 32'h00000000, make_hdl_path("cm_ld_stall_cycle_lo"));
    m_my_block.create_field(32'h00004078, "cm_ld_stall_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_ld_stall_cycle_hi", 32'h0000407C, 32'h00000000, make_hdl_path("cm_ld_stall_cycle_hi"));
    m_my_block.create_field(32'h0000407C, "cm_ld_stall_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("su_busy_cycle_lo", 32'h00004080, 32'h00000000, make_hdl_path("su_busy_cycle_lo"));
    m_my_block.create_field(32'h00004080, "su_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("su_busy_cycle_hi", 32'h00004084, 32'h00000000, make_hdl_path("su_busy_cycle_hi"));
    m_my_block.create_field(32'h00004084, "su_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_st_req_num_lo", 32'h00004088, 32'h00000000, make_hdl_path("cm_st_req_num_lo"));
    m_my_block.create_field(32'h00004088, "cm_st_req_num_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_st_req_num_hi", 32'h0000408C, 32'h00000000, make_hdl_path("cm_st_req_num_hi"));
    m_my_block.create_field(32'h0000408C, "cm_st_req_num_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_st_stall_cycle_lo", 32'h00004090, 32'h00000000, make_hdl_path("cm_st_stall_cycle_lo"));
    m_my_block.create_field(32'h00004090, "cm_st_stall_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("cm_st_stall_cycle_hi", 32'h00004094, 32'h00000000, make_hdl_path("cm_st_stall_cycle_hi"));
    m_my_block.create_field(32'h00004094, "cm_st_stall_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("valu0_busy_cycle_lo", 32'h00004098, 32'h00000000, make_hdl_path("valu0_busy_cycle_lo"));
    m_my_block.create_field(32'h00004098, "valu0_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("valu0_busy_cycle_hi", 32'h0000409C, 32'h00000000, make_hdl_path("valu0_busy_cycle_hi"));
    m_my_block.create_field(32'h0000409C, "valu0_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("valu1_busy_cycle_lo", 32'h000040A0, 32'h00000000, make_hdl_path("valu1_busy_cycle_lo"));
    m_my_block.create_field(32'h000040A0, "valu1_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("valu1_busy_cycle_hi", 32'h000040A4, 32'h00000000, make_hdl_path("valu1_busy_cycle_hi"));
    m_my_block.create_field(32'h000040A4, "valu1_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("valu2_busy_cycle_lo", 32'h000040A8, 32'h00000000, make_hdl_path("valu2_busy_cycle_lo"));
    m_my_block.create_field(32'h000040A8, "valu2_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("valu2_busy_cycle_hi", 32'h000040AC, 32'h00000000, make_hdl_path("valu2_busy_cycle_hi"));
    m_my_block.create_field(32'h000040AC, "valu2_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vsfu_busy_cycle_lo", 32'h000040B0, 32'h00000000, make_hdl_path("vsfu_busy_cycle_lo"));
    m_my_block.create_field(32'h000040B0, "vsfu_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vsfu_busy_cycle_hi", 32'h000040B4, 32'h00000000, make_hdl_path("vsfu_busy_cycle_hi"));
    m_my_block.create_field(32'h000040B4, "vsfu_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mexe_busy_cycle_lo", 32'h000040B8, 32'h00000000, make_hdl_path("mexe_busy_cycle_lo"));
    m_my_block.create_field(32'h000040B8, "mexe_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mexe_busy_cycle_hi", 32'h000040BC, 32'h00000000, make_hdl_path("mexe_busy_cycle_hi"));
    m_my_block.create_field(32'h000040BC, "mexe_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("sexe_busy_cycle_lo", 32'h000040C0, 32'h00000000, make_hdl_path("sexe_busy_cycle_lo"));
    m_my_block.create_field(32'h000040C0, "sexe_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("sexe_busy_cycle_hi", 32'h000040C4, 32'h00000000, make_hdl_path("sexe_busy_cycle_hi"));
    m_my_block.create_field(32'h000040C4, "sexe_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p0_busy_cycle_lo", 32'h000040C8, 32'h00000000, make_hdl_path("vrf_rd_p0_busy_cycle_lo"));
    m_my_block.create_field(32'h000040C8, "vrf_rd_p0_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p0_busy_cycle_hi", 32'h000040CC, 32'h00000000, make_hdl_path("vrf_rd_p0_busy_cycle_hi"));
    m_my_block.create_field(32'h000040CC, "vrf_rd_p0_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p1_busy_cycle_lo", 32'h000040D0, 32'h00000000, make_hdl_path("vrf_rd_p1_busy_cycle_lo"));
    m_my_block.create_field(32'h000040D0, "vrf_rd_p1_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p1_busy_cycle_hi", 32'h000040D4, 32'h00000000, make_hdl_path("vrf_rd_p1_busy_cycle_hi"));
    m_my_block.create_field(32'h000040D4, "vrf_rd_p1_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p0_busy_cycle_lo", 32'h000040D8, 32'h00000000, make_hdl_path("vrf_wt_p0_busy_cycle_lo"));
    m_my_block.create_field(32'h000040D8, "vrf_wt_p0_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p0_busy_cycle_hi", 32'h000040DC, 32'h00000000, make_hdl_path("vrf_wt_p0_busy_cycle_hi"));
    m_my_block.create_field(32'h000040DC, "vrf_wt_p0_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p1_busy_cycle_lo", 32'h000040E0, 32'h00000000, make_hdl_path("vrf_wt_p1_busy_cycle_lo"));
    m_my_block.create_field(32'h000040E0, "vrf_wt_p1_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p1_busy_cycle_hi", 32'h000040E4, 32'h00000000, make_hdl_path("vrf_wt_p1_busy_cycle_hi"));
    m_my_block.create_field(32'h000040E4, "vrf_wt_p1_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mrf_wt_busy_cycle_lo", 32'h000040E8, 32'h00000000, make_hdl_path("mrf_wt_busy_cycle_lo"));
    m_my_block.create_field(32'h000040E8, "mrf_wt_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mrf_wt_busy_cycle_hi", 32'h000040EC, 32'h00000000, make_hdl_path("mrf_wt_busy_cycle_hi"));
    m_my_block.create_field(32'h000040EC, "mrf_wt_busy_cycle_hi_COUNT", 0, 31, REG_RO);

  endfunction

endclass
