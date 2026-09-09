// ============================================================================
// Filename             : inst_gen_if.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_INTERFACE_SV
`define INST_GEN_INTERFACE_SV
`ifndef REG_WIDTH
    `define REG_WIDTH 64
`endif
`ifndef IMM_WIDTH
    `define IMM_WIDTH 32
`endif
`ifndef INST_TYPE_WIDTH
    `define INST_TYPE_WIDTH 1
`endif
interface inst_gen_if(input bit clk,input bit reset);
    logic                       vld;
    logic                       rdy;
    logic [`INST_TYPE_WIDTH-1:0]inst_type;
    logic [31:0]                vinst;
    logic [31:0]                minst;
    logic [`REG_WIDTH-1:0]      rs1_data;
    logic [`REG_WIDTH-1:0]      rs2_data;
    logic [`IMM_WIDTH-1:0]      imm;

    clocking drv_cb@(posedge clk);
        input                   reset;
        input                   rdy;
        input                   vld;
        input                   inst_type;
        input                   vinst;
        input                   minst;
        input                   rs1_data;
        input                   rs2_data;
        input                   imm;
    endclocking

    clocking mon_cb@(posedge clk);
        input                   reset;
        input                   rdy;
        input                   vld;
        input                   inst_type;
        input                   vinst;
        input                   minst;
        input                   rs1_data;
        input                   rs2_data;
        input                   imm;
    endclocking

   
    modport DRV(
        output  rdy,
        input   vld,
        input   inst_type,
        input   vinst,
        input   minst,
        input   rs1_data,
        input   rs2_data,
        input   imm
    );

    modport MON(
        output  rdy,
        output  vld,
        output  inst_type,
        output  vinst,
        output  minst,
        output  rs1_data,
        output  rs2_data,
        output  imm
    );
endinterface : inst_gen_if
`endif
