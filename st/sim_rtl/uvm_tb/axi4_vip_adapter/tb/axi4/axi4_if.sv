interface axi4_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  // Appended parameters preserve legacy axi4_if #(ADDR, DATA, ID) calls.
  parameter int LEN_WIDTH = 8,
  parameter int QOS_WIDTH = 4,
  parameter int REGION_WIDTH = 4,
  parameter int AWUSER_WIDTH = 0,
  parameter int ARUSER_WIDTH = 0,
  parameter int WUSER_WIDTH = 0,
  parameter int RUSER_WIDTH = 0,
  parameter int BUSER_WIDTH = 0
) (
  input logic aclk,
  input logic aresetn
);
  // Logical width 0 means absent at the DUT boundary. SV storage is still
  // one bit: omit the DUT port or tie its input low; never use [WIDTH-1:0]
  // for these optional fields. Nonzero widths carry all configured bits.
  localparam int QOS_BITS = (QOS_WIDTH > 0) ? QOS_WIDTH : 1;
  localparam int REGION_BITS = (REGION_WIDTH > 0) ? REGION_WIDTH : 1;
  localparam int AWUSER_BITS = (AWUSER_WIDTH > 0) ? AWUSER_WIDTH : 1;
  localparam int ARUSER_BITS = (ARUSER_WIDTH > 0) ? ARUSER_WIDTH : 1;
  localparam int WUSER_BITS = (WUSER_WIDTH > 0) ? WUSER_WIDTH : 1;
  localparam int RUSER_BITS = (RUSER_WIDTH > 0) ? RUSER_WIDTH : 1;
  localparam int BUSER_BITS = (BUSER_WIDTH > 0) ? BUSER_WIDTH : 1;

  initial begin
    if (ADDR_WIDTH < 1 || ID_WIDTH < 1 || LEN_WIDTH < 1 || LEN_WIDTH > 8)
      $fatal(1, "axi4_if requires positive ADDR/ID and LEN_WIDTH in 1..8");
    if (DATA_WIDTH < 8 || DATA_WIDTH > 1024 || (DATA_WIDTH & (DATA_WIDTH-1)) != 0)
      $fatal(1, "axi4_if DATA_WIDTH must be a power of two in 8..1024");
    if ((QOS_WIDTH != 0 && QOS_WIDTH != 4) ||
        (REGION_WIDTH != 0 && REGION_WIDTH != 4) ||
        AWUSER_WIDTH < 0 || ARUSER_WIDTH < 0 || WUSER_WIDTH < 0 ||
        RUSER_WIDTH < 0 || BUSER_WIDTH < 0)
      $fatal(1, "axi4_if invalid optional signal widths");
  end

  logic [ID_WIDTH-1:0]     awid;
  logic [ADDR_WIDTH-1:0]   awaddr;
  logic [LEN_WIDTH-1:0]   awlen;
  logic [2:0]              awsize;
  logic [1:0]              awburst;
  logic                    awlock;
  logic [3:0]              awcache;
  logic [2:0]              awprot;
  logic [QOS_BITS-1:0]      awqos;
  logic [REGION_BITS-1:0]   awregion;
  logic [AWUSER_BITS-1:0] awuser;
  logic                    awvalid;
  logic                    awready;

  logic [DATA_WIDTH-1:0]   wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                    wlast;
  logic [WUSER_BITS-1:0] wuser;
  logic                    wvalid;
  logic                    wready;

  logic [ID_WIDTH-1:0]     bid;
  logic [1:0]              bresp;
  logic [BUSER_BITS-1:0] buser;
  logic                    bvalid;
  logic                    bready;

  logic [ID_WIDTH-1:0]     arid;
  logic [ADDR_WIDTH-1:0]   araddr;
  logic [LEN_WIDTH-1:0]   arlen;
  logic [2:0]              arsize;
  logic [1:0]              arburst;
  logic                    arlock;
  logic [3:0]              arcache;
  logic [2:0]              arprot;
  logic [QOS_BITS-1:0]      arqos;
  logic [REGION_BITS-1:0]   arregion;
  logic [ARUSER_BITS-1:0] aruser;
  logic                    arvalid;
  logic                    arready;

  logic [ID_WIDTH-1:0]     rid;
  logic [DATA_WIDTH-1:0]   rdata;
  logic [1:0]              rresp;
  logic                    rlast;
  logic [RUSER_BITS-1:0] ruser;
  logic                    rvalid;
  logic                    rready;

  modport master (
    input  aclk, aresetn,
    output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
    output wdata, wstrb, wlast, wuser, wvalid,
    output bready,
    output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
    output rready,
    input  awready, wready, bid, bresp, buser, bvalid,
    input  arready, rid, rdata, rresp, rlast, ruser, rvalid
  );

  modport slave (
    input  aclk, aresetn,
    input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
    input  wdata, wstrb, wlast, wuser, wvalid,
    input  bready,
    input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
    input  rready,
    output awready, wready, bid, bresp, buser, bvalid,
    output arready, rid, rdata, rresp, rlast, ruser, rvalid
  );
endinterface
