module dut #(
  parameter int unsigned DATA_WIDTH = sram_geometry_pkg::SRAM_DATA_WIDTH,
  parameter int unsigned BYTE_WIDTH = 8,
  parameter int unsigned BE_WIDTH =
    (DATA_WIDTH + BYTE_WIDTH - 1) / BYTE_WIDTH,
  parameter int unsigned CHECK_WORD_COUNT =
    sram_geometry_pkg::sram_words(0),
  parameter int unsigned CHECK_ADDRESS_WIDTH =
    (CHECK_WORD_COUNT > 1) ? $clog2(CHECK_WORD_COUNT) : 1
) (
  input  logic                           clk_i,
  input  logic                           rst_ni,
  input  logic                           check_input_valid_i,
  input  logic [CHECK_ADDRESS_WIDTH-1:0] check_input_word_address_i,
  input  logic [DATA_WIDTH-1:0]          check_input_data_i
);

  localparam int unsigned WORD_BYTES =
    (DATA_WIDTH + BYTE_WIDTH - 1) / BYTE_WIDTH;
  // The input is a real DUT interface driven by tb_top. Only DUT result data
  // is retained internally; input history is collected outside the DUT by the
  // verification Operation through uvm_hdl_read on the interface ports.
  logic [DATA_WIDTH-1:0] ref_result_capture_array
    [0:CHECK_WORD_COUNT-1];
  logic                  ref_result_capture_valid
    [0:CHECK_WORD_COUNT-1];

  // Current DUT algorithm is pass-through. Replace this function when the DUT
  // calculation changes; the Reference class is modified independently.
  function automatic logic [DATA_WIDTH-1:0] calculate_word(
    input logic [DATA_WIDTH-1:0] input_value
  );
    return input_value;
  endfunction

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int unsigned index = 0; index < CHECK_WORD_COUNT; index++) begin
        ref_result_capture_array[index] <= '0;
        ref_result_capture_valid[index] <= 1'b0;
      end
    end
    else begin
      if ($isunknown(check_input_valid_i))
        $fatal(1, "DUT check input valid contains X/Z");
      if (check_input_valid_i) begin
        if ($isunknown(check_input_word_address_i) ||
            $isunknown(check_input_data_i))
          $fatal(1, "DUT check input address/data contains X/Z");
        if (check_input_word_address_i >= CHECK_WORD_COUNT)
          $fatal(1, "DUT check input address %0d exceeds %0d words",
                 check_input_word_address_i, CHECK_WORD_COUNT);
        ref_result_capture_array[check_input_word_address_i] <=
          calculate_word(check_input_data_i);
        ref_result_capture_valid[check_input_word_address_i] <= 1'b1;
      end
    end
  end

  // Keep this hierarchy stable: YAML hdl_path entries point through
  // dut.gen_sram[].u_interleaved_sram.gen_bank[].u_sram.sram.
  for (genvar sram = 0;
       sram < sram_geometry_pkg::SRAM_COUNT; sram++) begin : gen_sram
    localparam int unsigned TOTAL_WORDS =
      sram_geometry_pkg::sram_words(sram);
    localparam int unsigned ADDR_WIDTH =
      (TOTAL_WORDS > 1) ? $clog2(TOTAL_WORDS) : 1;
    localparam longint unsigned BASE_BYTE_ADDRESS =
      sram_geometry_pkg::sram_base_word_address(sram) * WORD_BYTES;

    logic [DATA_WIDTH-1:0] unused_rdata;

    // Check operations use the DUT interface and result array above. The SRAM
    // frontdoor remains inactive; initialization access stays in Operation.
    interleaved_sram #(
      .SRAM_INDEX        ( sram ),
      .BANK_COUNT        ( sram_geometry_pkg::SRAM_BANK_COUNT ),
      .ADDRESS_INTERLEAVE( sram_geometry_pkg::SRAM_ADDRESS_INTERLEAVE ),
      .INTERLEAVE_WORDS  ( sram_geometry_pkg::SRAM_INTERLEAVE_GRANULARITY_WORDS ),
      .TOTAL_WORDS       ( TOTAL_WORDS ),
      .BASE_BYTE_ADDRESS ( BASE_BYTE_ADDRESS ),
      .DATA_WIDTH        ( DATA_WIDTH ),
      .BYTE_WIDTH        ( BYTE_WIDTH )
    ) u_interleaved_sram (
      .clk_i   ( clk_i ),
      .rst_ni  ( rst_ni ),
      .req_i   ( 1'b0 ),
      .we_i    ( 1'b0 ),
      .addr_i  ( ADDR_WIDTH'(0) ),
      .wdata_i ( DATA_WIDTH'(0) ),
      .be_i    ( BE_WIDTH'(0) ),
      .rdata_o ( unused_rdata )
    );
  end

  initial begin
    if (sram_geometry_pkg::SRAM_COUNT != 1)
      $fatal(1, "DUT SRAM container requires exactly one SRAM");
    if (sram_geometry_pkg::SRAM_BANK_COUNT != 4)
      $fatal(1, "DUT SRAM container requires four banks per SRAM");
    if ((DATA_WIDTH < 8) || ((DATA_WIDTH % 8) != 0))
      $fatal(1, "DUT DATA_WIDTH must be a positive byte-aligned value");
    if (DATA_WIDTH != sram_geometry_pkg::SRAM_DATA_WIDTH)
      $fatal(1, "DUT DATA_WIDTH does not match YAML SRAM data width");
    if (CHECK_WORD_COUNT != sram_geometry_pkg::sram_words(0))
      $fatal(1, "DUT CHECK_WORD_COUNT does not match YAML SRAM word count");
  end

endmodule
