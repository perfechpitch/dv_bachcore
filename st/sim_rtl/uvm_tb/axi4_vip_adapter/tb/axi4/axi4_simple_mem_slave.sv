module axi4_simple_mem_slave #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  parameter int DEPTH      = 1024
) (
  axi4_if.slave axi
);
  localparam int STRB_WIDTH = DATA_WIDTH / 8;
  localparam int LEN_WIDTH = $bits(axi.awlen);
  localparam int FULL_SIZE = $clog2(STRB_WIDTH);
  // Demo storage deliberately retains the original modulo-DEPTH address map.
  // There is one outstanding transaction PER DIRECTION, not a 128-entry slave.
  // Simultaneous reads/writes to one word observe its pre-write value.
  logic [DATA_WIDTH-1:0] mem [DEPTH];
  logic [ADDR_WIDTH-1:0] wr_addr;
  logic [ADDR_WIDTH-1:0] rd_addr;
  logic [ID_WIDTH-1:0] wr_id;
  logic [STRB_WIDTH-1:0] wr_lanes;
  int unsigned wr_remaining, rd_remaining;
  int unsigned wr_step, rd_step;
  logic have_aw, wr_reject, wr_error, rd_reject;

  assign axi.awready = axi.aresetn && !have_aw && !axi.bvalid;
  assign axi.wready  = axi.aresetn && have_aw;
  assign axi.arready = axi.aresetn && !axi.rvalid;
  assign axi.buser   = '0;
  assign axi.ruser   = '0;

  initial begin
    if (DEPTH < 1 || DATA_WIDTH < 8 || DATA_WIDTH > 1024 ||
        (DATA_WIDTH & (DATA_WIDTH-1)) != 0 ||
        $bits(axi.awaddr) != ADDR_WIDTH || $bits(axi.araddr) != ADDR_WIDTH ||
        $bits(axi.wdata) != DATA_WIDTH || $bits(axi.awid) != ID_WIDTH ||
        $bits(axi.arid) != ID_WIDTH || $bits(axi.arlen) != LEN_WIDTH)
      $fatal(1, "axi4_simple_mem_slave invalid parameters/interface widths");
  end

  function automatic int unsigned word_index(input logic [ADDR_WIDTH-1:0] addr);
    word_index = (addr >> $clog2(STRB_WIDTH)) % DEPTH;
  endfunction

  function automatic bit address_legal(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [LEN_WIDTH-1:0] len,
    input logic [2:0] size,
    input logic [1:0] burst,
    input logic lock
  );
    int unsigned bytes_per_beat, total_bytes;
    if ($isunknown({addr, len, size, burst, lock})) return 0;
    if (burst != 2'b01 || lock || size > FULL_SIZE) return 0;
    bytes_per_beat = 1 << size;
    // Only naturally aligned single-beat narrow transfers are implemented.
    if ((addr % bytes_per_beat) != 0 || (len != 0 && size != FULL_SIZE)) return 0;
    total_bytes = (int'(len) + 1) * bytes_per_beat;
    if ((addr % 4096) + total_bytes > 4096) return 0;
    return 1;
  endfunction

  function automatic logic [STRB_WIDTH-1:0] allowed_lanes(
    input logic [ADDR_WIDTH-1:0] addr, input logic [2:0] size
  );
    logic [STRB_WIDTH-1:0] mask;
    int unsigned first_lane;
    mask = '0;
    first_lane = addr % STRB_WIDTH;
    for (int lane = 0; lane < STRB_WIDTH; lane++)
      if (lane >= first_lane && lane < first_lane + (1 << size)) mask[lane] = 1'b1;
    return mask;
  endfunction

  always_ff @(posedge axi.aclk or negedge axi.aresetn) begin
    if (!axi.aresetn) begin
      have_aw    <= 1'b0;
      wr_addr    <= '0;
      rd_addr    <= '0;
      wr_id      <= '0;
      wr_lanes   <= '0;
      wr_remaining <= 0;
      rd_remaining <= 0;
      wr_step    <= 0;
      rd_step    <= 0;
      wr_reject  <= 1'b0;
      wr_error   <= 1'b0;
      rd_reject  <= 1'b0;
      axi.bid    <= '0;
      axi.bresp  <= 2'b00;
      axi.bvalid <= 1'b0;
      axi.rid    <= '0;
      axi.rresp  <= 2'b00;
      axi.rlast  <= 1'b0;
      axi.rvalid <= 1'b0;
      axi.rdata  <= '0;
      for (int i = 0; i < DEPTH; i++) begin
        mem[i] <= '0;
      end
    end else begin
      if (axi.awvalid && axi.awready) begin
        wr_addr <= axi.awaddr;
        wr_id <= axi.awid;
        wr_lanes <= allowed_lanes(axi.awaddr, axi.awsize);
        wr_remaining <= int'(axi.awlen) + 1;
        wr_step <= 1 << axi.awsize;
        wr_reject <= !address_legal(axi.awaddr, axi.awlen, axi.awsize, axi.awburst, axi.awlock);
        wr_error <= 1'b0;
        have_aw <= 1'b1;
        if (!address_legal(axi.awaddr, axi.awlen, axi.awsize, axi.awburst, axi.awlock))
          $warning("AXI4_SIMPLE_MEM_REJECT AW addr=%h len=%0d size=%0d burst=%0d lock=%b: only aligned INCR full-width bursts/narrow singles within 4KB", axi.awaddr, axi.awlen, axi.awsize, axi.awburst, axi.awlock);
      end

      if (axi.bvalid && axi.bready) axi.bvalid <= 1'b0;
      if (axi.wvalid && axi.wready) begin
        // A malformed W beat is diagnosed, discarded and remembered in BRESP.
        // Earlier legal beats remain committed; this is not transactional RAM.
        if ((axi.wlast !== (wr_remaining == 1)) || $isunknown(axi.wstrb) ||
            ((axi.wstrb & ~wr_lanes) != '0)) begin
          wr_error <= 1'b1;
          $warning("AXI4_SIMPLE_MEM_REJECT W id=%h remaining=%0d last=%b strb=%h allowed=%h", wr_id, wr_remaining, axi.wlast, axi.wstrb, wr_lanes);
        end else if (!wr_reject && !wr_error) begin
          for (int i = 0; i < STRB_WIDTH; i++) begin
            if (axi.wstrb[i])
              mem[word_index(wr_addr)][8*i +: 8] <= axi.wdata[8*i +: 8];
          end
        end
        if (wr_remaining == 1) begin
          have_aw <= 1'b0;
          axi.bvalid <= 1'b1;
          axi.bid <= wr_id;
          axi.bresp <= (wr_reject || wr_error || (axi.wlast !== 1'b1) ||
                        $isunknown(axi.wstrb) || ((axi.wstrb & ~wr_lanes) != '0)) ? 2'b10 : 2'b00;
        end else begin
          wr_remaining <= wr_remaining - 1;
          wr_addr <= wr_addr + wr_step;
          // Multi-beat transfers are full-width, so every lane stays allowed.
        end
      end

      if (axi.arvalid && axi.arready) begin
        rd_addr    <= axi.araddr;
        rd_remaining <= int'(axi.arlen) + 1;
        rd_step <= 1 << axi.arsize;
        rd_reject <= !address_legal(axi.araddr, axi.arlen, axi.arsize, axi.arburst, axi.arlock);
        axi.rid <= axi.arid;
        axi.rlast <= (axi.arlen == 0);
        if (address_legal(axi.araddr, axi.arlen, axi.arsize, axi.arburst, axi.arlock)) begin
          axi.rdata <= mem[word_index(axi.araddr)];
          axi.rresp <= 2'b00;
        end else begin
          axi.rdata <= '0;
          axi.rresp <= 2'b10;
          $warning("AXI4_SIMPLE_MEM_REJECT AR addr=%h len=%0d size=%0d burst=%0d lock=%b: only aligned INCR full-width bursts/narrow singles within 4KB", axi.araddr, axi.arlen, axi.arsize, axi.arburst, axi.arlock);
        end
        axi.rvalid <= 1'b1;
      end else if (axi.rvalid && axi.rready) begin
        if (rd_remaining == 1) begin
          axi.rvalid <= 1'b0;
          axi.rlast <= 1'b0;
        end else begin
          rd_remaining <= rd_remaining - 1;
          rd_addr <= rd_addr + rd_step;
          axi.rdata <= rd_reject ? '0 : mem[word_index(rd_addr + rd_step)];
          axi.rlast <= (rd_remaining == 2);
        end
      end
    end
  end
endmodule
