`timescale 1ns / 1ps
`include "config.v"

module ex_mem(
    input wire clk,
    input wire rst,
    input wire [`RegLen - 1 : 0]     ex_rd_data,
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire ex_rd_enable,

    output reg [`RegLen - 1 : 0]     mem_rd_data,
    output reg [`RegAddrLen - 1 : 0] mem_rd_addr,
    output reg mem_rd_enable
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            //TODO: Reset
        end
        else begin
            mem_rd_data <= ex_rd_data;
            mem_rd_addr <= ex_rd_addr;
            mem_rd_enable <= ex_rd_enable;
        end
    end

endmodule
