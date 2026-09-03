// ============================================================================
// Filename             : axi_transaction.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_TRANSACTION_SV
`define AXI_TRANSACTION_SV

class axi_read_address_event #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    typedef axi_read_address_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]   arid;
    bit [ADDR_WIDTH-1:0] araddr;
    bit [7:0]                arlen;
    bit [2:0]                arsize;
    axi_burst_e              arburst;
    bit                      arlock;
    bit [3:0]                arcache;
    bit [2:0]                arprot;
    bit [3:0]                arqos;
    bit [3:0]                arregion;
    bit [USER_WIDTH-1:0] aruser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(arid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(araddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(arsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_e, arburst, UVM_DEFAULT)
        `uvm_field_int(arlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(arcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(aruser, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_read_address_event");
        super.new(name);
    endfunction : new
endclass : axi_read_address_event

class axi_read_data_event #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    typedef axi_read_data_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]    rid;
    bit [DATA_WIDTH-1:0]  rdata;
    bit [DATA_BYTES-1:0]  rdata_valid_mask;
    axi_resp_e                rresp;
    bit                       rlast;
    bit [USER_WIDTH-1:0]  ruser;
    int unsigned              beat_index;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(rid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(rdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(rdata_valid_mask, UVM_DEFAULT | UVM_BIN)
        `uvm_field_enum(axi_resp_e, rresp, UVM_DEFAULT)
        `uvm_field_int(rlast, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(ruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(beat_index, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_read_data_event");
        super.new(name);
    endfunction : new
endclass : axi_read_data_event

class axi_write_address_event #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    typedef axi_write_address_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]   awid;
    bit [ADDR_WIDTH-1:0] awaddr;
    bit [7:0]                awlen;
    bit [2:0]                awsize;
    axi_burst_e              awburst;
    bit                      awlock;
    bit [3:0]                awcache;
    bit [2:0]                awprot;
    bit [3:0]                awqos;
    bit [3:0]                awregion;
    bit [USER_WIDTH-1:0] awuser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(awid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awaddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(awsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_e, awburst, UVM_DEFAULT)
        `uvm_field_int(awlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(awcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awuser, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_write_address_event");
        super.new(name);
    endfunction : new
endclass : axi_write_address_event

class axi_write_data_event #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_write_data_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [DATA_WIDTH-1:0]  wdata;
    bit [STRB_WIDTH-1:0]  wstrb;
    bit                       wlast;
    bit [USER_WIDTH-1:0]      wuser;
    int unsigned              beat_index;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(wdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(wstrb, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(wlast, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(wuser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(beat_index, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_write_data_event");
        super.new(name);
    endfunction : new
endclass : axi_write_data_event

class axi_write_response_event #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    typedef axi_write_response_event #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0] bid;
    axi_resp_e             bresp;
    bit [USER_WIDTH-1:0]    buser;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(bid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum(axi_resp_e, bresp, UVM_DEFAULT)
        `uvm_field_int(buser, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "axi_write_response_event");
        super.new(name);
    endfunction : new
endclass : axi_write_response_event

class axi_read_transaction #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    localparam int DATA_BYTES = DATA_WIDTH / 8;
    typedef axi_burst_math #(ADDR_WIDTH, DATA_BYTES) burst_math_t;
    typedef axi_read_transaction #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]   arid;
    bit [ADDR_WIDTH-1:0] araddr;
    bit [7:0]                arlen;
    bit [2:0]                arsize;
    axi_burst_e              arburst;
    bit                      arlock;
    bit [3:0]                arcache;
    bit [2:0]                arprot;
    bit [3:0]                arqos;
    bit [3:0]                arregion;
    bit [USER_WIDTH-1:0] aruser;
    bit [ID_WIDTH-1:0]   rid;
    bit [DATA_WIDTH-1:0] rdata[];
    bit [1:0]                rresp[];
    bit [USER_WIDTH-1:0] ruser[];
    bit                      read_done;
    int unsigned             beat_count;
    // Raw accepted-transfer timestamps are retained as bus event metadata;
    // they are not the formal cycle-based performance metrics below.
    time                     ar_handshake_time;
    time                     r_handshake_time[];
    bit                      performance_valid;
    longint unsigned         read_first_latency_cycles;
    longint unsigned         ar_handshake_latency_cycles;
    longint unsigned         read_transaction_latency_cycles;
    longint unsigned         r_inter_beat_bubble_cycles[];
    int unsigned             r_inter_beat_nonzero_bubble_count;
    longint unsigned         r_inter_beat_bubble_total_cycles;
    longint unsigned         r_inter_beat_bubble_max_cycles;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(arid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(araddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(arsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_e, arburst, UVM_DEFAULT)
        `uvm_field_int(arlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(arcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(arregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(aruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(rid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(rdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(rresp, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(ruser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(read_done, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(beat_count, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(ar_handshake_time, UVM_DEFAULT | UVM_TIME)
        `uvm_field_array_int(r_handshake_time, UVM_DEFAULT | UVM_TIME)
        `uvm_field_int(performance_valid, UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_int(read_first_latency_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(ar_handshake_latency_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(read_transaction_latency_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_array_int(r_inter_beat_bubble_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(r_inter_beat_nonzero_bubble_count, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(r_inter_beat_bubble_total_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(r_inter_beat_bubble_max_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "axi_read_transaction");
        super.new(name);
        performance_valid = 1'b0;
        read_first_latency_cycles = 0;
        ar_handshake_latency_cycles = 0;
        read_transaction_latency_cycles = 0;
        r_inter_beat_nonzero_bubble_count = 0;
        r_inter_beat_bubble_total_cycles = 0;
        r_inter_beat_bubble_max_cycles = 0;
    endfunction : new

    function bit [ADDR_WIDTH-1:0] get_beat_addr(int unsigned beat_idx);
        return burst_math_t::get_beat_addr(
            araddr, arlen, arsize, arburst, beat_idx);
    endfunction : get_beat_addr

    function bit [DATA_BYTES-1:0] get_beat_rdata_valid_mask(int unsigned beat_idx);
        return burst_math_t::get_byte_lane_mask(
            araddr, arlen, arsize, arburst, beat_idx);
    endfunction : get_beat_rdata_valid_mask
endclass : axi_read_transaction

class axi_write_transaction #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_sequence_item;
    localparam int STRB_WIDTH = DATA_WIDTH / 8;
    typedef axi_burst_math #(ADDR_WIDTH, STRB_WIDTH) burst_math_t;
    typedef axi_write_transaction #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;

    bit [ID_WIDTH-1:0]   awid;
    bit [ADDR_WIDTH-1:0] awaddr;
    bit [7:0]                awlen;
    bit [2:0]                awsize;
    axi_burst_e              awburst;
    bit                      awlock;
    bit [3:0]                awcache;
    bit [2:0]                awprot;
    bit [3:0]                awqos;
    bit [3:0]                awregion;
    bit [USER_WIDTH-1:0] awuser;
    bit [DATA_WIDTH-1:0] wdata[];
    bit [STRB_WIDTH-1:0] wstrb[];
    bit [USER_WIDTH-1:0] wuser[];
    bit [ID_WIDTH-1:0]   bid;
    axi_resp_e               bresp;
    bit [USER_WIDTH-1:0]     buser;
    bit                      write_done;
    int unsigned             beat_count;
    // Raw accepted-transfer timestamps remain available to protocol-oriented
    // consumers; calculated performance outputs use the cycle fields below.
    time                     aw_handshake_time;
    time                     w_handshake_time[];
    time                     b_handshake_time;
    bit                      performance_valid;
    longint unsigned         write_response_latency_cycles;
    longint unsigned         wlast_to_b_latency_cycles;
    longint unsigned         aw_handshake_latency_cycles;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(awid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awaddr, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awlen, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(awsize, UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum(axi_burst_e, awburst, UVM_DEFAULT)
        `uvm_field_int(awlock, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(awcache, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awprot, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awqos, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awregion, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(awuser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(wdata, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(wstrb, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(wuser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(bid, UVM_DEFAULT | UVM_HEX)
        `uvm_field_enum(axi_resp_e, bresp, UVM_DEFAULT)
        `uvm_field_int(buser, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(write_done, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(beat_count, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(aw_handshake_time, UVM_DEFAULT | UVM_TIME)
        `uvm_field_array_int(w_handshake_time, UVM_DEFAULT | UVM_TIME)
        `uvm_field_int(b_handshake_time, UVM_DEFAULT | UVM_TIME)
        `uvm_field_int(performance_valid, UVM_DEFAULT | UVM_BIN | UVM_NOCOMPARE)
        `uvm_field_int(write_response_latency_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(wlast_to_b_latency_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(aw_handshake_latency_cycles, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "axi_write_transaction");
        super.new(name);
        performance_valid = 1'b0;
        write_response_latency_cycles = 0;
        wlast_to_b_latency_cycles = 0;
        aw_handshake_latency_cycles = 0;
    endfunction : new

    function bit [ADDR_WIDTH-1:0] get_beat_addr(int unsigned beat_idx);
        return burst_math_t::get_beat_addr(
            awaddr, awlen, awsize, awburst, beat_idx);
    endfunction : get_beat_addr

    function bit [STRB_WIDTH-1:0] get_beat_wstrb_mask(int unsigned beat_idx);
        return burst_math_t::get_byte_lane_mask(
            awaddr, awlen, awsize, awburst, beat_idx);
    endfunction : get_beat_wstrb_mask
endclass : axi_write_transaction

`endif
