`timescale 1ns / 1ps
`include "config.v"

module mem(
    input rst,
    input wire [`RegLen - 1 : 0]     rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire rd_enable_i,

    output reg [`RegLen - 1 : 0]     rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o
    );

    always @ (*) begin
        if (rst == `ResetEnable) begin
            rd_data_o = `ZERO_WORD;
            rd_addr_o = `RegAddrLen'h0;
            rd_enable_o = `WriteDisable;
        end
        else begin
            rd_data_o = rd_data_i;
            rd_addr_o = rd_addr_i;
            rd_enable_o = rd_enable_i;
        end
    end

endmodule
