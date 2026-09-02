module interleaved_sram #(
  parameter int unsigned SRAM_INDEX = 0,
  parameter int unsigned BANK_COUNT = sram_geometry_pkg::SRAM_BANK_COUNT,
  parameter int unsigned ADDRESS_INTERLEAVE =
    sram_geometry_pkg::SRAM_ADDRESS_INTERLEAVE,
  parameter int unsigned INTERLEAVE_WORDS =
    sram_geometry_pkg::SRAM_INTERLEAVE_GRANULARITY_WORDS,
  parameter int unsigned TOTAL_WORDS =
    sram_geometry_pkg::sram_words(SRAM_INDEX),
  parameter longint unsigned BASE_BYTE_ADDRESS = 0,
  parameter int unsigned BANK_WORDS =
    sram_geometry_pkg::bank_words(SRAM_INDEX, 0),
  parameter int unsigned DATA_WIDTH = sram_geometry_pkg::SRAM_DATA_WIDTH,
  parameter int unsigned BYTE_WIDTH = 8,
  parameter int unsigned GLOBAL_ADDR_WIDTH =
    (TOTAL_WORDS > 1) ? $clog2(TOTAL_WORDS) : 1,
  parameter int unsigned BANK_ADDR_WIDTH =
    (BANK_WORDS > 1) ? $clog2(BANK_WORDS) : 1,
  parameter int unsigned BANK_SEL_WIDTH =
    (BANK_COUNT > 1) ? $clog2(BANK_COUNT) : 1,
  parameter int unsigned BE_WIDTH =
    (DATA_WIDTH + BYTE_WIDTH - 1) / BYTE_WIDTH
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,
  input  logic                         req_i,
  input  logic                         we_i,
  input  logic [GLOBAL_ADDR_WIDTH-1:0] addr_i,
  input  logic [DATA_WIDTH-1:0]        wdata_i,
  input  logic [BE_WIDTH-1:0]          be_i,
  output logic [DATA_WIDTH-1:0]        rdata_o
);
  logic [BANK_COUNT-1:0]                 bank_req;
  logic [BANK_COUNT-1:0][DATA_WIDTH-1:0] bank_rdata;
  logic [BANK_SEL_WIDTH-1:0]             selected_bank;
  logic [BANK_SEL_WIDTH-1:0]             read_bank_q;
  logic [BANK_ADDR_WIDTH-1:0]            selected_row;
  localparam int unsigned WORD_BYTES = (DATA_WIDTH + 7) / 8;

  always_comb begin
    if (ADDRESS_INTERLEAVE != 0) begin
      selected_bank = (addr_i / INTERLEAVE_WORDS) % BANK_COUNT;
      selected_row =
        (addr_i / (INTERLEAVE_WORDS * BANK_COUNT)) * INTERLEAVE_WORDS +
        (addr_i % INTERLEAVE_WORDS);
    end else begin
      selected_bank = addr_i / BANK_WORDS;
      selected_row = addr_i % BANK_WORDS;
    end
    bank_req = '0;
    if (req_i && (addr_i < TOTAL_WORDS) &&
        (selected_row < BANK_WORDS))
      bank_req[selected_bank] = 1'b1;
    rdata_o = bank_rdata[read_bank_q];
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      read_bank_q <= '0;
    else if (req_i && !we_i && (addr_i < TOTAL_WORDS))
      read_bank_q <= selected_bank;
  end

  for (genvar bank = 0; bank < BANK_COUNT; bank++) begin : gen_bank
    localparam int unsigned THIS_BANK_WORDS =
      sram_geometry_pkg::bank_words(SRAM_INDEX, bank);
    logic [0:0]                      req;
    logic [0:0]                      we;
    logic [0:0][BANK_ADDR_WIDTH-1:0] row;
    logic [0:0][DATA_WIDTH-1:0]      wdata;
    logic [0:0][BE_WIDTH-1:0]        be;
    logic [0:0][DATA_WIDTH-1:0]      rdata;

    assign req[0] = bank_req[bank];
    assign we[0] = we_i;
    assign row[0] = selected_row;
    assign wdata[0] = wdata_i;
    assign be[0] = be_i;
    assign bank_rdata[bank] = rdata[0];

    tc_sram #(
      .NumWords    ( THIS_BANK_WORDS ),
      .DataWidth   ( DATA_WIDTH      ),
      .ByteWidth   ( BYTE_WIDTH      ),
      .NumPorts    ( 1               ),
      .Latency     ( 1               ),
      .SimInit     ( "none"          ),
      .PrintSimCfg ( 1'b0            ),
      .ImplKey     ( "generic"       ),
      .AddrWidth   ( BANK_ADDR_WIDTH )
    ) u_sram (
      .clk_i,
      .rst_ni,
      .req_i   ( req   ),
      .we_i    ( we    ),
      .addr_i  ( row   ),
      .wdata_i ( wdata ),
      .be_i    ( be    ),
      .rdata_o ( rdata )
    );

    initial begin
      if (THIS_BANK_WORDS != BANK_WORDS)
        $fatal(1, "SRAM implementation requires equal bank capacities");
      if (ADDRESS_INTERLEAVE != 0)
        $display("SRAM_ADDRESS_BANK sram=%0d bank=%0d rows=%0d mapping=block_interleave first_block_word=%0d block_words=%0d block_stride=%0d path=%m.u_sram.sram",
                 SRAM_INDEX, bank, THIS_BANK_WORDS,
                 bank * INTERLEAVE_WORDS, INTERLEAVE_WORDS,
                 BANK_COUNT * INTERLEAVE_WORDS);
      else
        $display("SRAM_ADDRESS_BANK sram=%0d bank=%0d rows=%0d mapping=contiguous logical_first=%0d logical_last=%0d path=%m.u_sram.sram",
                 SRAM_INDEX, bank, THIS_BANK_WORDS,
                 bank * BANK_WORDS, ((bank + 1) * BANK_WORDS) - 1);
    end
  end

  // Simulation-only, read-only logical SRAM view for Verdi. Element N is the
  // Nth logical word after the selected address mapping; companion arrays show
  // byte address, physical bank, and row within that bank. The data is wired
  // directly to the real tc_sram storage and therefore always reflects it.
`ifndef SYNTHESIS
`ifndef TARGET_SYNTHESIS
  logic [63:0]                  sram_view_byte_address [0:TOTAL_WORDS-1];
  logic [BANK_SEL_WIDTH-1:0]    sram_view_bank         [0:TOTAL_WORDS-1];
  logic [BANK_ADDR_WIDTH-1:0]   sram_view_bank_row     [0:TOTAL_WORDS-1];
  logic [DATA_WIDTH-1:0]        sram_view_data         [0:TOTAL_WORDS-1];

  for (genvar logical_word = 0;
       logical_word < TOTAL_WORDS; logical_word++) begin : gen_sram_view
    localparam int unsigned VIEW_BANK =
      (ADDRESS_INTERLEAVE != 0) ?
        ((logical_word / INTERLEAVE_WORDS) % BANK_COUNT) :
        (logical_word / BANK_WORDS);
    localparam int unsigned VIEW_ROW  =
      (ADDRESS_INTERLEAVE != 0) ?
        ((logical_word / (INTERLEAVE_WORDS * BANK_COUNT)) *
          INTERLEAVE_WORDS + (logical_word % INTERLEAVE_WORDS)) :
        (logical_word % BANK_WORDS);

    assign sram_view_byte_address[logical_word] =
      BASE_BYTE_ADDRESS + (logical_word * WORD_BYTES);
    assign sram_view_bank[logical_word] = VIEW_BANK;
    assign sram_view_bank_row[logical_word] = VIEW_ROW;
    assign sram_view_data[logical_word] =
      gen_bank[VIEW_BANK].u_sram.sram[VIEW_ROW];
  end
`endif
`endif

  initial begin
    if (BANK_COUNT == 0)
      $fatal(1, "BANK_COUNT must be greater than zero");
    if (ADDRESS_INTERLEAVE > 1)
      $fatal(1, "ADDRESS_INTERLEAVE must be 0 or 1");
    if (INTERLEAVE_WORDS == 0)
      $fatal(1, "INTERLEAVE_WORDS must be greater than zero");
    if ((ADDRESS_INTERLEAVE != 0) &&
        ((BANK_WORDS % INTERLEAVE_WORDS) != 0))
      $fatal(1, "Bank depth must be divisible by interleave granularity");
    if (TOTAL_WORDS != (BANK_COUNT * BANK_WORDS))
      $fatal(1, "TOTAL_WORDS must equal BANK_COUNT * BANK_WORDS");
    if ((DATA_WIDTH % 8) != 0)
      $fatal(1, "SRAM byte-address view requires byte-aligned DATA_WIDTH");
    $display("SRAM_ADDRESS_GEOMETRY sram=%0d banks=%0d rows_per_bank=%0d total_words=%0d bytes=%0d address_interleave=%0d interleave_words=%0d mapping=%s instance=%m",
             SRAM_INDEX, BANK_COUNT, BANK_WORDS, TOTAL_WORDS,
             (TOTAL_WORDS * DATA_WIDTH) / 8, ADDRESS_INTERLEAVE,
             INTERLEAVE_WORDS,
             (ADDRESS_INTERLEAVE != 0) ? "block_interleave" : "contiguous");
    $display("SRAM_WAVE_VIEW sram=%0d base_byte_address=0x%0h end_byte_address=0x%0h word_bytes=%0d data=%m.sram_view_data address=%m.sram_view_byte_address bank=%m.sram_view_bank row=%m.sram_view_bank_row",
             SRAM_INDEX, BASE_BYTE_ADDRESS,
             BASE_BYTE_ADDRESS + (TOTAL_WORDS * WORD_BYTES) - 1,
             WORD_BYTES);
  end
endmodule
