module axi4_simple_mem_slave #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  parameter int DEPTH      = 1024
) (
  axi4_if.slave axi
);
  localparam int STRB_WIDTH = DATA_WIDTH / 8;
  logic [DATA_WIDTH-1:0] mem [DEPTH];
  logic [ADDR_WIDTH-1:0] wr_addr;
  logic [ADDR_WIDTH-1:0] rd_addr;
  logic                  have_aw;

  assign axi.awready = axi.aresetn;
  assign axi.wready  = axi.aresetn && have_aw;
  assign axi.arready = axi.aresetn && !axi.rvalid;
  assign axi.bid     = '0;
  assign axi.bresp   = 2'b00;
  assign axi.rid     = '0;
  assign axi.rresp   = 2'b00;
  assign axi.rlast   = axi.rvalid;

  function automatic int unsigned word_index(input logic [ADDR_WIDTH-1:0] addr);
    word_index = (addr >> $clog2(STRB_WIDTH)) % DEPTH;
  endfunction

  always_ff @(posedge axi.aclk or negedge axi.aresetn) begin
    if (!axi.aresetn) begin
      have_aw    <= 1'b0;
      wr_addr    <= '0;
      rd_addr    <= '0;
      axi.bvalid <= 1'b0;
      axi.rvalid <= 1'b0;
      axi.rdata  <= '0;
      for (int i = 0; i < DEPTH; i++) begin
        mem[i] <= '0;
      end
    end else begin
      if (axi.awvalid && axi.awready) begin
        wr_addr <= axi.awaddr;
        have_aw <= 1'b1;
      end

      if (axi.wvalid && axi.wready) begin
        for (int i = 0; i < STRB_WIDTH; i++) begin
          if (axi.wstrb[i]) begin
            mem[word_index(wr_addr)][8*i +: 8] <= axi.wdata[8*i +: 8];
          end
        end
        have_aw    <= 1'b0;
        axi.bvalid <= 1'b1;
      end else if (axi.bvalid && axi.bready) begin
        axi.bvalid <= 1'b0;
      end

      if (axi.arvalid && axi.arready) begin
        rd_addr    <= axi.araddr;
        axi.rdata  <= mem[word_index(axi.araddr)];
        axi.rvalid <= 1'b1;
      end else if (axi.rvalid && axi.rready) begin
        axi.rvalid <= 1'b0;
      end
    end
  end
endmodule
