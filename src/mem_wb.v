`timescale 1ns / 1ps
`include "config.vh"

module mem_wb(
    input clk,
    input rst,

    //from ctrl.v
    input wire [5 : 0] stall,

    //from mem.v
    input wire [`RegLen - 1 : 0]     mem_rd_data,
    input wire [`RegAddrLen - 1 : 0] mem_rd_addr,
    input wire mem_rd_enable,

    //to register.v
    output reg [`RegLen - 1 : 0]     wb_rd_data,
    output reg [`RegAddrLen - 1 : 0] wb_rd_addr,
    output reg wb_rd_enable
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            wb_rd_data    <= `ZERO_WORD;
            wb_rd_addr    <= `RegAddrLen'h0;
            wb_rd_enable  <= `WriteDisable;
        end 
        else if (stall[4] && !stall[5]) begin
            wb_rd_data    <= `ZERO_WORD;
            wb_rd_addr    <= `RegAddrLen'h0;
            wb_rd_enable  <= `WriteDisable;
        end
        else if(!stall[4]) begin
            wb_rd_data    <= mem_rd_data;
            wb_rd_addr    <= mem_rd_addr;
            wb_rd_enable  <= mem_rd_enable;
        end
    end
endmodule
