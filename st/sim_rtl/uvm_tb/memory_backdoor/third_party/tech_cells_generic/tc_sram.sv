// Copyright (c) 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// Author: Wolfgang Roenninger <wroennin@ethz.ch>
// Description: Functional module of a generic SRAM
//
// Upstream: https://github.com/pulp-platform/tech_cells_generic
// Modified by this project on 2026-08-11: upstream comments were shortened
// and long display/assertion lines were reformatted; the interface and
// functional SRAM behavior are retained.

module tc_sram #(
  parameter int unsigned NumWords     = 32'd1024,
  parameter int unsigned DataWidth    = 32'd128,
  parameter int unsigned ByteWidth    = 32'd8,
  parameter int unsigned NumPorts     = 32'd2,
  parameter int unsigned Latency      = 32'd1,
  parameter              SimInit      = "none",
  parameter bit          PrintSimCfg  = 1'b0,
  parameter              ImplKey      = "none",
  parameter              FPGAImplKey  = "auto",
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o
);
`ifdef SYNTHESIS
  `define TC_GENERIC_SRAM_SYNTHESIS
`elsif TARGET_SYNTHESIS
  `define TC_GENERIC_SRAM_SYNTHESIS
`endif

`ifndef TC_GENERIC_SRAM_SYNTHESIS
  data_t sram [NumWords-1:0];
  addr_t [NumPorts-1:0] r_addr_q;
  data_t init_val[NumWords-1:0];

  // pragma translate_off
  function automatic data_t random_init_word();
    random_init_word = '0;
    for (int unsigned b = 0; b < DataWidth; b += 32) begin
      random_init_word = (random_init_word << 32) | data_t'($urandom());
    end
  endfunction

  initial begin : proc_sram_init
    for (int unsigned i = 0; i < NumWords; i++) begin
      unique case (SimInit)
        "zeros":  init_val[i] = '0;
        "ones":   init_val[i] = '1;
        "random": init_val[i] = random_init_word();
        default:  init_val[i] = 'x;
      endcase
    end
  end
  // pragma translate_on

  data_t [NumPorts-1:0][Latency-1:0] rdata_q, rdata_d;
  if (Latency == 32'd0) begin : gen_no_read_lat
    for (genvar i = 0; i < NumPorts; i++) begin : gen_port
      assign rdata_o[i] = (req_i[i] && !we_i[i]) ?
                          sram[addr_i[i]] : sram[r_addr_q[i]];
    end
  end else begin : gen_read_lat
    always_comb begin
      for (int unsigned i = 0; i < NumPorts; i++) begin
        rdata_o[i] = rdata_q[i][0];
        for (int unsigned j = 0; j < (Latency-1); j++) begin
          rdata_d[i][j] = rdata_q[i][j+1];
        end
        rdata_d[i][Latency-1] = (req_i[i] && !we_i[i]) ?
                                sram[addr_i[i]] : sram[r_addr_q[i]];
      end
    end
  end

  if (SimInit == "none") begin
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        for (int i = 0; i < NumPorts; i++) begin
          r_addr_q[i] <= {AddrWidth{1'b0}};
        end
      end else begin
        for (int unsigned i = 0; i < NumPorts; i++) begin
          if (Latency != 0) begin
            for (int unsigned j = 0; j < Latency; j++) begin
              rdata_q[i][j] <= rdata_d[i][j];
            end
          end
        end
        for (int unsigned i = 0; i < NumPorts; i++) begin
          if (req_i[i]) begin
            if (we_i[i]) begin
              for (int unsigned j = 0; j < BeWidth; j++) begin
                if (be_i[i][j]) begin
                  sram[addr_i[i]][j*ByteWidth+:ByteWidth] <=
                    wdata_i[i][j*ByteWidth+:ByteWidth];
                end
              end
            end else begin
              r_addr_q[i] <= addr_i[i];
            end
          end
        end
      end
    end
  end else begin
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        sram <= init_val;
        for (int i = 0; i < NumPorts; i++) begin
          r_addr_q[i] <= {AddrWidth{1'b0}};
          if (Latency != 32'd0) begin
            for (int unsigned j = 0; j < Latency; j++) begin
              rdata_q[i][j] <= init_val[{AddrWidth{1'b0}}];
            end
          end
        end
      end else begin
        for (int unsigned i = 0; i < NumPorts; i++) begin
          if (Latency != 0) begin
            for (int unsigned j = 0; j < Latency; j++) begin
              rdata_q[i][j] <= rdata_d[i][j];
            end
          end
        end
        for (int unsigned i = 0; i < NumPorts; i++) begin
          if (req_i[i]) begin
            if (we_i[i]) begin
              for (int unsigned j = 0; j < BeWidth; j++) begin
                if (be_i[i][j]) begin
                  sram[addr_i[i]][j*ByteWidth+:ByteWidth] <=
                    wdata_i[i][j*ByteWidth+:ByteWidth];
                end
              end
            end else begin
              r_addr_q[i] <= addr_i[i];
            end
          end
        end
      end
    end
  end

  // pragma translate_off
`ifndef VERILATOR
`ifndef TARGET_SYNTHESIS
  initial begin: p_assertions
    assert ($bits(addr_i)  == NumPorts * AddrWidth) else $fatal(1, "AddrWidth problem on `addr_i`");
    assert ($bits(wdata_i) == NumPorts * DataWidth) else $fatal(1, "DataWidth problem on `wdata_i`");
    assert ($bits(be_i)    == NumPorts * BeWidth)   else $fatal(1, "BeWidth problem on `be_i`");
    assert ($bits(rdata_o) == NumPorts * DataWidth) else $fatal(1, "DataWidth problem on `rdata_o`");
    assert (NumWords  >= 32'd1) else $fatal(1, "NumWords has to be > 0");
    assert (DataWidth >= 32'd1) else $fatal(1, "DataWidth has to be > 0");
    assert (ByteWidth >= 32'd1) else $fatal(1, "ByteWidth has to be > 0");
    assert (NumPorts  >= 32'd1) else $fatal(1, "The number of ports must be at least 1!");
  end

  initial begin: p_sim_hello
    if (PrintSimCfg) begin
      $display("tc_sram instance=%m ports=%0d words=%0d data_width=%0d latency=%0d sim_init=%0s",
               NumPorts, NumWords, DataWidth, Latency, SimInit);
    end
  end

  for (genvar i = 0; i < NumPorts; i++) begin : gen_assertions
    assert property (@(posedge clk_i) disable iff (!rst_ni)
        (req_i[i] |-> (addr_i[i] < NumWords))) else
      $warning("Request address %0h not mapped, port %0d", addr_i[i], i);
  end
`endif
`endif
  // pragma translate_on
`else
  (* sram_num_words = NumWords, sram_data_width = DataWidth,
     sram_byte_width = ByteWidth, sram_num_ports = NumPorts,
     sram_latency = Latency, sram_impl_key = ImplKey *)
  tc_sram_blackbox #(
    .NumWords     ( NumWords     ),
    .DataWidth    ( DataWidth    ),
    .ByteWidth    ( ByteWidth    ),
    .NumPorts     ( NumPorts     ),
    .Latency      ( Latency      ),
    .SimInit      ( SimInit      ),
    .PrintSimCfg  ( PrintSimCfg  ),
    .ImplKey      ( ImplKey      ),
    .FPGAImplKey  ( FPGAImplKey  )
  ) i_tc_sram_blackbox (.*);
`endif
endmodule

(* black_box, syn_black_box = 1 *)
module tc_sram_blackbox #(
  parameter int unsigned NumWords     = 32'd1024,
  parameter int unsigned DataWidth    = 32'd128,
  parameter int unsigned ByteWidth    = 32'd8,
  parameter int unsigned NumPorts     = 32'd2,
  parameter int unsigned Latency      = 32'd1,
  parameter              SimInit      = "none",
  parameter bit          PrintSimCfg  = 1'b0,
  parameter              ImplKey      = "none",
  parameter              FPGAImplKey  = "auto",
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o
);
endmodule
