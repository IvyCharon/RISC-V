`timescale 1ns / 1ps
`include "config.vh"

module ex_mem(
    input wire clk,
    input wire rst,

    //from ex.v
    input wire [`RegLen - 1 : 0]     ex_rd_data,
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire ex_rd_enable,
    input wire [`AddrLen - 1 : 0]    ex_mem_addr,
    input reg  [`ALU_Len - 1 : 0]    ex_alu_op,
    input reg  [`InstLen - 1 : 0]    ex_mem_wdata,
    input reg  [`StallLen - 1 : 0]   ex_stall_flag,

    //to mem.v
    output reg [`RegLen - 1 : 0]     mem_rd_data,
    output reg [`RegAddrLen - 1 : 0] mem_rd_addr,
    output reg [`AddrLen - 1 : 0]    mem_mem_addr,
    output reg [`ALU_Len - 1 : 0]    mem_alu_op,
    output reg [`InstLen - 1 : 0]    mem_mem_wdata,
    output reg mem_rd_enable,
    output reg [`StallLen - 1 : 0]   mem_stall_flag
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            mem_rd_data <= `ZERO_WORD;
            mem_rd_addr <= `RegAddrLen'h0;
            mem_rd_enable <= `WriteDisable;
            mem_mem_addr <= `ZERO_WORD;
            mem_alu_op <= `NoAlu;
            mem_mem_wdata <= `ZERO_WORD;
            mem_stall_flag <= `NoStall;
        end
        else begin
            mem_rd_data <= ex_rd_data;
            mem_rd_addr <= ex_rd_addr;
            mem_rd_enable <= ex_rd_enable;
            mem_mem_addr <= ex_mem_addr;
            mem_alu_op <= ex_alu_op;
            mem_mem_wdata <= ex_mem_wdata;
            mem_stall_flag <= ex_stall_flag;
        end
    end

endmodule
