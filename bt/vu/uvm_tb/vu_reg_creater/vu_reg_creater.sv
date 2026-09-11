//------------------------------------------------------------------------------
// File         : vu_reg_creater.sv
// Description  : Auto-generated UVM component. Instantiates reg VIP and
//                creates registers / fields from the register spreadsheet.
// Source       : vu_reg.xlsx
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
    m_my_block.create_field(32'h00000004, "TYPE_VL_RESERVED_31_21", 21, 31, REG_RO);
    m_my_block.create_field(32'h00000004, "TYPE_VL_NAN_INF_EN", 20, 20, REG_RW);

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
    m_my_block.create_field(32'h0000001C, "MRF_wt_index_MRF_WT_IDX", 0, 15, REG_RW);
    m_my_block.create_field(32'h0000001C, "MRF_wt_index_RESERVED_31_16", 16, 31, REG_RO);

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
    m_my_block.create_field(32'h0000002C, "SRF_wt_index_1_RESERVED_23_16", 16, 23, REG_RO);
    m_my_block.create_field(32'h0000002C, "SRF_wt_index_1_RESERVED_31_24", 24, 31, REG_RO);


    //----- 静态配置寄存器组 -----
    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("LU_op_g%s", idx_str);
      reg_addr = 32'h00001000 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_STRIDE_RUN", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_STRIDE_SKIP", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_24", reg_name), 24, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("SU_op_g%s", idx_str);
      reg_addr = 32'h00001004 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_MXFP8_SCALE_ROUND", reg_name), 16, 16, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_17", reg_name), 17, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("VALU0_op_g%s", idx_str);
      reg_addr = 32'h00001008 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC3_SEL", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("VALU1_op_g%s", idx_str);
      reg_addr = 32'h0000100C + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC3_SEL", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("VALU2_op_g%s", idx_str);
      reg_addr = 32'h00001010 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC3_SEL", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("VSFU_op_g%s", idx_str);
      reg_addr = 32'h00001014 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_VSFU0_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VSFU0_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VSFU1_OPCODE", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VSFU1_SRC1_SEL", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("MEXE_op_g%s", idx_str);
      reg_addr = 32'h00001018 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_24", reg_name), 24, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("SEXE0_op_g%s", idx_str);
      reg_addr = 32'h0000101C + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_24", reg_name), 24, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("SEXE1_op_g%s", idx_str);
      reg_addr = 32'h00001020 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_24", reg_name), 24, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("SEXE2_op_g%s", idx_str);
      reg_addr = 32'h00001024 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_OPCODE", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC1_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRC2_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_24", reg_name), 24, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("mask_op_g%s", idx_str);
      reg_addr = 32'h00001028 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_VALU0_MASK_SEL", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VALU1_MASK_SEL", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VALU2_MASK_SEL", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_24", reg_name), 24, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("PRF_op_g%s", idx_str);
      reg_addr = 32'h0000102C + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_VRF_WT_P0_SRC", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VRF_WT_P1_SRC", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_MRF_WT_SRC", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_EN", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_TYPE_VL_g%s", idx_str);
      reg_addr = 32'h00001030 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_VL", reg_name), 0, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_DATA_TYPE", reg_name), 16, 16, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_ROUND_MODE", reg_name), 17, 19, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_20", reg_name), 20, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_LD_addr_g%s", idx_str);
      reg_addr = 32'h00001034 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_CM_ADDR", reg_name), 0, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_ST_addr_g%s", idx_str);
      reg_addr = 32'h00001038 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_CM_ADDR", reg_name), 0, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_VRF_rd_index_g%s", idx_str);
      reg_addr = 32'h0000103C + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_VRF_RD_P0_IDX", reg_name), 0, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VRF_RD_P1_IDX", reg_name), 16, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_VRF_wt_index_g%s", idx_str);
      reg_addr = 32'h00001040 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_VRF_WT_P0_IDX", reg_name), 0, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_VRF_WT_P1_IDX", reg_name), 16, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_MRF_rd_index_g%s", idx_str);
      reg_addr = 32'h00001044 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_MRF_RD_P0_IDX", reg_name), 0, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_MRF_RD_P1_IDX", reg_name), 16, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_MRF_wt_index_g%s", idx_str);
      reg_addr = 32'h00001048 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_MRF_WT_IDX", reg_name), 0, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_16", reg_name), 16, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_SRF_rd_index_0_g%s", idx_str);
      reg_addr = 32'h0000104C + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P0_IDX", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P1_IDX", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P2_IDX", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P3_IDX", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_SRF_rd_index_1_g%s", idx_str);
      reg_addr = 32'h00001050 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P4_IDX", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P5_IDX", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P6_IDX", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_RD_P7_IDX", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_SRF_wt_index_0_g%s", idx_str);
      reg_addr = 32'h00001054 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_P0_IDX", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_P1_IDX", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_P2_IDX", reg_name), 16, 23, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_P3_IDX", reg_name), 24, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("static_SRF_wt_index_1_g%s", idx_str);
      reg_addr = 32'h00001058 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_P4_IDX", reg_name), 0, 7, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_SRF_WT_P5_IDX", reg_name), 8, 15, REG_RW);
      m_my_block.create_field(reg_addr, $sformatf("%s_RESERVED_31_16", reg_name), 16, 31, REG_RO);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("INF_REPLACE_VALUE_g%s", idx_str);
      reg_addr = 32'h0000105C + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_INF_REPLACE_VALUE", reg_name), 0, 31, REG_RW);
    end

    for (int i = 0; i < 8; i++) begin
      string idx_str;
      string reg_name;
      int unsigned reg_addr;
      idx_str = $sformatf("%0d", i);
      reg_name = $sformatf("NAN_REPLACE_VALUE_g%s", idx_str);
      reg_addr = 32'h00001060 + i * 32'h00000100;
      m_my_block.create_reg(reg_name, reg_addr, 32'h00000000, make_hdl_path(reg_name));
      m_my_block.create_field(reg_addr, $sformatf("%s_NAN_REPLACE_VALUE", reg_name), 0, 31, REG_RW);
    end


    //----- DSA-RF 读写寄存器 -----
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
    m_my_block.create_field(32'h00003008, "error_code_CFG_ERROR", 1, 1, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_RF_IDX_ERROR", 2, 2, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_CM_ADDR_ERROR", 3, 3, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_NAN_ERROR", 4, 4, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_VRF_ECC_ERROR", 5, 5, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_MRF_ECC_ERROR", 6, 6, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_SRF_ECC_ERROR", 7, 7, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_CM_ECC_ERROR", 8, 8, REG_RO);
    m_my_block.create_field(32'h00003008, "error_code_RESERVED_31_9", 9, 31, REG_RO);

    m_my_block.create_reg("error_info", 32'h0000300C, 32'h00000000, make_hdl_path("error_info"));
    m_my_block.create_field(32'h0000300C, "error_info_USER_ID", 0, 15, REG_RO);
    m_my_block.create_field(32'h0000300C, "error_info_STREAM_ID", 16, 19, REG_RO);
    m_my_block.create_field(32'h0000300C, "error_info_CONFIG_IDX", 20, 22, REG_RO);
    m_my_block.create_field(32'h0000300C, "error_info_RESERVED_23_23", 23, 23, REG_RO);
    m_my_block.create_field(32'h0000300C, "error_info_ERR_UNIT", 23, 26, REG_RO);
    m_my_block.create_field(32'h0000300C, "error_info_FIRST_ERR", 27, 30, REG_RO);
    m_my_block.create_field(32'h0000300C, "error_info_VALID", 31, 31, REG_RO);

    m_my_block.create_reg("snapshot_addr", 32'h00003010, 32'h00000000, make_hdl_path("snapshot_addr"));
    m_my_block.create_field(32'h00003010, "snapshot_addr_SNAP_IDX", 0, 3, REG_RW);
    m_my_block.create_field(32'h00003010, "snapshot_addr_SNAP_SEL", 4, 11, REG_RW);
    m_my_block.create_field(32'h00003010, "snapshot_addr_RESERVED_31_12", 12, 31, REG_RO);

    m_my_block.create_reg("snapshot_data", 32'h00003014, 32'h00000000, make_hdl_path("snapshot_data"));
    m_my_block.create_field(32'h00003014, "snapshot_data_SNAP_DATA", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_err_info", 32'h00003018, 32'h00000000, make_hdl_path("vrf_err_info"));
    m_my_block.create_field(32'h00003018, "vrf_err_info_USER_ID", 0, 15, REG_RO);
    m_my_block.create_field(32'h00003018, "vrf_err_info_RF_ERR_IDX", 16, 24, REG_RO);
    m_my_block.create_field(32'h00003018, "vrf_err_info_RESERVED_30_25", 25, 30, REG_RO);
    m_my_block.create_field(32'h00003018, "vrf_err_info_VALID", 31, 31, REG_RO);

    m_my_block.create_reg("mrf_err_info", 32'h0000301C, 32'h00000000, make_hdl_path("mrf_err_info"));
    m_my_block.create_field(32'h0000301C, "mrf_err_info_USER_ID", 0, 15, REG_RO);
    m_my_block.create_field(32'h0000301C, "mrf_err_info_RF_ERR_IDX", 16, 24, REG_RO);
    m_my_block.create_field(32'h0000301C, "mrf_err_info_RESERVED_30_25", 25, 30, REG_RO);
    m_my_block.create_field(32'h0000301C, "mrf_err_info_VALID", 31, 31, REG_RO);

    m_my_block.create_reg("srf_err_info", 32'h00003020, 32'h00000000, make_hdl_path("srf_err_info"));
    m_my_block.create_field(32'h00003020, "srf_err_info_USER_ID", 0, 15, REG_RO);
    m_my_block.create_field(32'h00003020, "srf_err_info_RF_ERR_IDX", 16, 24, REG_RO);
    m_my_block.create_field(32'h00003020, "srf_err_info_RESERVED_30_25", 25, 30, REG_RO);
    m_my_block.create_field(32'h00003020, "srf_err_info_VALID", 31, 31, REG_RO);

    m_my_block.create_reg("cm_err_info", 32'h00003024, 32'h00000000, make_hdl_path("cm_err_info"));
    m_my_block.create_field(32'h00003024, "cm_err_info_USER_ID", 0, 15, REG_RO);
    m_my_block.create_field(32'h00003024, "cm_err_info_DIR", 16, 16, REG_RO);
    m_my_block.create_field(32'h00003024, "cm_err_info_RESERVED_30_17", 17, 30, REG_RO);
    m_my_block.create_field(32'h00003024, "cm_err_info_VALID", 31, 31, REG_RO);

    m_my_block.create_reg("cm_err_addr", 32'h00003028, 32'h00000000, make_hdl_path("cm_err_addr"));
    m_my_block.create_field(32'h00003028, "cm_err_addr_CM_ERR_ADDR", 0, 31, REG_RO);

    m_my_block.create_reg("nan_err_info", 32'h0000302C, 32'h00000000, make_hdl_path("nan_err_info"));
    m_my_block.create_field(32'h0000302C, "nan_err_info_USER_ID", 0, 15, REG_RO);
    m_my_block.create_field(32'h0000302C, "nan_err_info_RESERVED_30_16", 16, 30, REG_RO);
    m_my_block.create_field(32'h0000302C, "nan_err_info_VALID", 31, 31, REG_RO);


    //----- Profile 寄存器 -----
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

    m_my_block.create_reg("vsfu0_busy_cycle_lo", 32'h000040B0, 32'h00000000, make_hdl_path("vsfu0_busy_cycle_lo"));
    m_my_block.create_field(32'h000040B0, "vsfu0_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vsfu0_busy_cycle_hi", 32'h000040B4, 32'h00000000, make_hdl_path("vsfu0_busy_cycle_hi"));
    m_my_block.create_field(32'h000040B4, "vsfu0_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vsfu1_busy_cycle_lo", 32'h000040B8, 32'h00000000, make_hdl_path("vsfu1_busy_cycle_lo"));
    m_my_block.create_field(32'h000040B8, "vsfu1_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vsfu1_busy_cycle_hi", 32'h000040BC, 32'h00000000, make_hdl_path("vsfu1_busy_cycle_hi"));
    m_my_block.create_field(32'h000040BC, "vsfu1_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mexe_busy_cycle_lo", 32'h000040C0, 32'h00000000, make_hdl_path("mexe_busy_cycle_lo"));
    m_my_block.create_field(32'h000040C0, "mexe_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mexe_busy_cycle_hi", 32'h000040C4, 32'h00000000, make_hdl_path("mexe_busy_cycle_hi"));
    m_my_block.create_field(32'h000040C4, "mexe_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("sexe_busy_cycle_lo", 32'h000040C8, 32'h00000000, make_hdl_path("sexe_busy_cycle_lo"));
    m_my_block.create_field(32'h000040C8, "sexe_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("sexe_busy_cycle_hi", 32'h000040CC, 32'h00000000, make_hdl_path("sexe_busy_cycle_hi"));
    m_my_block.create_field(32'h000040CC, "sexe_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p0_busy_cycle_lo", 32'h000040D0, 32'h00000000, make_hdl_path("vrf_rd_p0_busy_cycle_lo"));
    m_my_block.create_field(32'h000040D0, "vrf_rd_p0_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p0_busy_cycle_hi", 32'h000040D4, 32'h00000000, make_hdl_path("vrf_rd_p0_busy_cycle_hi"));
    m_my_block.create_field(32'h000040D4, "vrf_rd_p0_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p1_busy_cycle_lo", 32'h000040D8, 32'h00000000, make_hdl_path("vrf_rd_p1_busy_cycle_lo"));
    m_my_block.create_field(32'h000040D8, "vrf_rd_p1_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_rd_p1_busy_cycle_hi", 32'h000040DC, 32'h00000000, make_hdl_path("vrf_rd_p1_busy_cycle_hi"));
    m_my_block.create_field(32'h000040DC, "vrf_rd_p1_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p0_busy_cycle_lo", 32'h000040E0, 32'h00000000, make_hdl_path("vrf_wt_p0_busy_cycle_lo"));
    m_my_block.create_field(32'h000040E0, "vrf_wt_p0_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p0_busy_cycle_hi", 32'h000040E4, 32'h00000000, make_hdl_path("vrf_wt_p0_busy_cycle_hi"));
    m_my_block.create_field(32'h000040E4, "vrf_wt_p0_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p1_busy_cycle_lo", 32'h000040E8, 32'h00000000, make_hdl_path("vrf_wt_p1_busy_cycle_lo"));
    m_my_block.create_field(32'h000040E8, "vrf_wt_p1_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("vrf_wt_p1_busy_cycle_hi", 32'h000040EC, 32'h00000000, make_hdl_path("vrf_wt_p1_busy_cycle_hi"));
    m_my_block.create_field(32'h000040EC, "vrf_wt_p1_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mrf_wt_busy_cycle_lo", 32'h000040F0, 32'h00000000, make_hdl_path("mrf_wt_busy_cycle_lo"));
    m_my_block.create_field(32'h000040F0, "mrf_wt_busy_cycle_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("mrf_wt_busy_cycle_hi", 32'h000040F4, 32'h00000000, make_hdl_path("mrf_wt_busy_cycle_hi"));
    m_my_block.create_field(32'h000040F4, "mrf_wt_busy_cycle_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("nan_replace_cnt_lo", 32'h000040F8, 32'h00000000, make_hdl_path("nan_replace_cnt_lo"));
    m_my_block.create_field(32'h000040F8, "nan_replace_cnt_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("nan_replace_cnt_hi", 32'h000040FC, 32'h00000000, make_hdl_path("nan_replace_cnt_hi"));
    m_my_block.create_field(32'h000040FC, "nan_replace_cnt_hi_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("inf_replace_cnt_lo", 32'h00004100, 32'h00000000, make_hdl_path("inf_replace_cnt_lo"));
    m_my_block.create_field(32'h00004100, "inf_replace_cnt_lo_COUNT", 0, 31, REG_RO);

    m_my_block.create_reg("inf_replace_cnt_hi", 32'h00004104, 32'h00000000, make_hdl_path("inf_replace_cnt_hi"));
    m_my_block.create_field(32'h00004104, "inf_replace_cnt_hi_COUNT", 0, 31, REG_RO);

  endfunction

endclass
