`timescale 1ns / 1ps
`include "config.vh"

module mem_wb(
    input clk,
    input rst,

    //from mem.v
    input wire [`RegLen - 1 : 0]     mem_rd_data,
    input wire [`RegAddrLen - 1 : 0] mem_rd_addr,
    input wire mem_rd_enable,
    input reg  [`StallLen - 1 : 0]   mem_stall_flag,

    //to register.v
    output reg [`RegLen - 1 : 0]     wb_rd_data,
    output reg [`RegAddrLen - 1 : 0] wb_rd_addr,
    output reg wb_rd_enable,
    output reg [`StallLen - 1 : 0]   wb_stall_flag
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            wb_rd_data    <= `ZERO_WORD;
            wb_rd_addr    <= `RegAddrLen'h0;
            wb_rd_enable  <= `WriteDisable;
            wb_stall_flag <= `NoStall;
        end
        else begin
            wb_rd_data    <= mem_rd_data;
            wb_rd_addr    <= mem_rd_addr;
            wb_rd_enable  <= mem_rd_enable;
            wb_stall_flag <= mem_stall_flag;
        end
    end
endmodule
