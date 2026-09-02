interface axi4_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4
) (
  input logic aclk,
  input logic aresetn
);
  logic [ID_WIDTH-1:0]     awid;
  logic [ADDR_WIDTH-1:0]   awaddr;
  logic [7:0]              awlen;
  logic [2:0]              awsize;
  logic [1:0]              awburst;
  logic                    awvalid;
  logic                    awready;

  logic [DATA_WIDTH-1:0]   wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                    wlast;
  logic                    wvalid;
  logic                    wready;

  logic [ID_WIDTH-1:0]     bid;
  logic [1:0]              bresp;
  logic                    bvalid;
  logic                    bready;

  logic [ID_WIDTH-1:0]     arid;
  logic [ADDR_WIDTH-1:0]   araddr;
  logic [7:0]              arlen;
  logic [2:0]              arsize;
  logic [1:0]              arburst;
  logic                    arvalid;
  logic                    arready;

  logic [ID_WIDTH-1:0]     rid;
  logic [DATA_WIDTH-1:0]   rdata;
  logic [1:0]              rresp;
  logic                    rlast;
  logic                    rvalid;
  logic                    rready;

  modport master (
    input  aclk, aresetn,
    output awid, awaddr, awlen, awsize, awburst, awvalid,
    output wdata, wstrb, wlast, wvalid,
    output bready,
    output arid, araddr, arlen, arsize, arburst, arvalid,
    output rready,
    input  awready, wready, bid, bresp, bvalid,
    input  arready, rid, rdata, rresp, rlast, rvalid
  );

  modport slave (
    input  aclk, aresetn,
    input  awid, awaddr, awlen, awsize, awburst, awvalid,
    input  wdata, wstrb, wlast, wvalid,
    input  bready,
    input  arid, araddr, arlen, arsize, arburst, arvalid,
    input  rready,
    output awready, wready, bid, bresp, bvalid,
    output arready, rid, rdata, rresp, rlast, rvalid
  );
endinterface
