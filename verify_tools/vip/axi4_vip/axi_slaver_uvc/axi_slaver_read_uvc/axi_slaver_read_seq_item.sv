// ============================================================================
// Filename             : axi_slaver_read_seq_item.sv
// Author               : kippy xyz
// Created On           : 2026-07-08
// Last Modified        :
// Update Count         :
// Description          : AXI read slaver transaction items and extension shell.
// ============================================================================
`ifndef AXI_SLAVER_READ_SEQ_ITEM_SV
`define AXI_SLAVER_READ_SEQ_ITEM_SV

class axi_slaver_read_ar_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_slaver_read_ar_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]                  arid;
    bit [ADDR_WIDTH-1:0]                araddr;
    bit [7:0]                       arlen;
    bit [2:0]                       arsize;
    axi_slaver_read_burst_e                arburst;
    bit                             arlock;
    bit [3:0]                       arcache;
    bit [2:0]                       arprot;
    bit [3:0]                       arqos;
    bit [3:0]                       arregion;
    bit [USER_WIDTH-1:0]                aruser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (arid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (araddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int  (arsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum (axi_slaver_read_burst_e, arburst, UVM_DEFAULT)
        `uvm_field_int  (arlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int  (arcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (arregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (aruser, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_read_ar_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_slaver_read_ar_seq_item

class axi_slaver_read_r_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends uvm_sequence_item;
    typedef axi_slaver_read_r_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]                  rid;
    bit [DATA_WIDTH-1:0]                rdata;
    axi_slaver_read_resp_e                 rresp;
    bit                             rlast;
    bit [USER_WIDTH-1:0]                ruser;
    int unsigned                    beat_index;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (rid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (rdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum (axi_slaver_read_resp_e, rresp, UVM_DEFAULT)
        `uvm_field_int  (rlast, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int  (ruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int  (beat_index, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_read_r_seq_item");
        super.new(name);
    endfunction : new
endclass : axi_slaver_read_r_seq_item

class axi_slaver_read_base_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends uvm_sequence_item;
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    typedef axi_burst_math #(ADDR_WIDTH, DATA_BYTES) burst_math_t;
    typedef axi_slaver_read_base_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]                  arid;
    bit [ADDR_WIDTH-1:0]                araddr;
    bit [7:0]                       arlen;
    bit [2:0]                       arsize;
    axi_slaver_read_burst_e                arburst;
    bit                             arlock;
    bit [3:0]                       arcache;
    bit [2:0]                       arprot;
    bit [3:0]                       arqos;
    bit [3:0]                       arregion;
    bit [USER_WIDTH-1:0]                aruser;

    bit [ID_WIDTH-1:0]                  rid;
    bit [DATA_WIDTH-1:0]                rdata[];
    bit [1:0]                       rresp[];
    bit [USER_WIDTH-1:0]                ruser[];
    bit                             read_done;
    int unsigned                    beat_count;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int       (arid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (araddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (arlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int       (arsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum      (axi_slaver_read_burst_e, arburst, UVM_DEFAULT)
        `uvm_field_int       (arlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (arcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (arprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (arqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (arregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (aruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (rid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (rdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (rresp, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int (ruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int       (read_done, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int       (beat_count, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_read_base_seq_item");
        super.new(name);
    endfunction : new

    function bit [ADDR_WIDTH-1:0] get_beat_addr(int unsigned beat_idx);
        return burst_math_t::get_beat_addr(
            araddr, arlen, arsize, axi_burst_e'(arburst), beat_idx);
    endfunction : get_beat_addr

    function bit [DATA_BYTES-1:0] get_beat_rdata_valid_mask(int unsigned beat_idx);
        return burst_math_t::get_byte_lane_mask(
            araddr, arlen, arsize, axi_burst_e'(arburst), beat_idx);
    endfunction : get_beat_rdata_valid_mask

    function bit [DATA_WIDTH-1:0] get_beat_rdata_valid_data_mask(int unsigned beat_idx);
        return burst_math_t::get_data_lane_mask(
            araddr, arlen, arsize, axi_burst_e'(arburst), beat_idx);
    endfunction : get_beat_rdata_valid_data_mask
endclass : axi_slaver_read_base_seq_item

class axi_slaver_read_seq_item #(
    int unsigned ID_WIDTH   = AXI_SLAVER_READ_ID_WIDTH,
    int unsigned ADDR_WIDTH = AXI_SLAVER_READ_ADDR_WIDTH,
    int unsigned DATA_WIDTH = AXI_SLAVER_READ_DATA_WIDTH,
    int unsigned USER_WIDTH = AXI_SLAVER_READ_USER_WIDTH
) extends axi_slaver_read_base_seq_item #(
    ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH);
    typedef axi_slaver_read_seq_item #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    // The reactive Driver records the cfg-selected AR-to-R delay here for
    // transaction visibility. This item is not consumed as a response policy.
    int unsigned ar_r_delay;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int  (ar_r_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "axi_slaver_read_seq_item");
        super.new(name);
    endfunction : new

endclass : axi_slaver_read_seq_item
`endif
