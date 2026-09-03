// ============================================================================
// Filename             : axi_slaver_write_seq_item.sv
// Author               : kippy xyz
// Created On           : 2026-6-30
// Last Modified        :
// Update Count         :
// Description          : AXI write slaver transaction items and extension shell.
// ============================================================================
`ifndef AXI_SLAVER_WRITE_SEQ_ITEM_SV
`define AXI_SLAVER_WRITE_SEQ_ITEM_SV

class axi_slaver_write_aw_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_slaver_write_aw_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]                  awid;
    bit [ADDR_WIDTH-1:0]                awaddr;
    bit [7:0]                              awlen;
    bit [2:0]                              awsize;
    axi_slaver_write_burst_e                awburst;
    bit                                    awlock;
    bit [3:0]                              awcache;
    bit [2:0]                              awprot;
    bit [3:0]                              awqos;
    bit [3:0]                              awregion;
    bit [USER_WIDTH-1:0]                awuser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (awid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awaddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int  (awsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum (axi_slaver_write_burst_e, awburst, UVM_DEFAULT)
        `uvm_field_int  (awlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int  (awcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (awuser, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_write_aw_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_slaver_write_aw_seq_item

class axi_slaver_write_w_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_slaver_write_w_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [DATA_WIDTH-1:0]                wdata;
    bit [STRB_WIDTH-1:0]                wstrb;
    bit                                    wlast;
    bit [USER_WIDTH-1:0]                wuser;
    int unsigned                           beat_index;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int (wdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int (wstrb, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int (wlast, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int (wuser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int (beat_index, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_write_w_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_slaver_write_w_seq_item

class axi_slaver_write_b_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_slaver_write_b_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]                  bid;
    axi_slaver_write_resp_e                 bresp;
    bit [USER_WIDTH-1:0]                buser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (bid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum (axi_slaver_write_resp_e, bresp, UVM_DEFAULT)
        `uvm_field_int  (buser, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_write_b_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_slaver_write_b_seq_item

class axi_slaver_write_base_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends uvm_sequence_item;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;
    typedef axi_slaver_write_base_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]                  awid;
    bit [ADDR_WIDTH-1:0]                awaddr;
    bit [7:0]                              awlen;
    bit [2:0]                              awsize;
    axi_slaver_write_burst_e                awburst;
    bit                                    awlock;
    bit [3:0]                              awcache;
    bit [2:0]                              awprot;
    bit [3:0]                              awqos;
    bit [3:0]                              awregion;
    bit [USER_WIDTH-1:0]                awuser;
    bit [DATA_WIDTH-1:0]                wdata[];
    bit [STRB_WIDTH-1:0]                wstrb[];
    bit [USER_WIDTH-1:0]                wuser[];

    bit [ID_WIDTH-1:0]                  bid;
    axi_slaver_write_resp_e                 bresp;
    bit [USER_WIDTH-1:0]                buser;
    bit                                    write_done;
    int unsigned                           beat_count;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int       (awid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (awaddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (awlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (awsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum      (axi_slaver_write_burst_e, awburst, UVM_DEFAULT)
        `uvm_field_int       (awlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (awcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (awprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (awqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (awregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (awuser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (wdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (wstrb, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (wuser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (bid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum      (axi_slaver_write_resp_e, bresp, UVM_DEFAULT)
        `uvm_field_int       (buser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (write_done, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (beat_count, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_write_base_seq_item");
        super.new(name);
    endfunction : new

    function bit [ADDR_WIDTH-1:0] get_beat_addr(int unsigned beat_idx);
        return burst_math_t::get_beat_addr(
            awaddr, awlen, awsize, axi_burst_e'(awburst), beat_idx);
    endfunction : get_beat_addr

    function bit [STRB_WIDTH-1:0] get_beat_wstrb_mask(int unsigned beat_idx);
        return burst_math_t::get_byte_lane_mask(
            awaddr, awlen, awsize, axi_burst_e'(awburst), beat_idx);
    endfunction : get_beat_wstrb_mask
endclass : axi_slaver_write_base_seq_item

class axi_slaver_write_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_WRITE_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_WRITE_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_WRITE_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_WRITE_USER_WIDTH
) extends axi_slaver_write_base_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH);
    typedef axi_slaver_write_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    // The reactive Driver records the cfg-selected BVALID delay here for
    // transaction visibility. This item is not consumed as a response policy.
    int unsigned b_delay;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (b_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_write_seq_item");
        super.new(name);
    endfunction : new

endclass : axi_slaver_write_seq_item
`endif
