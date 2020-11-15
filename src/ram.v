`timescale 1ns / 1ps
`include "config.vh"

module ram(
        input wire clk,

        input wire [`InstLen - 1 : 0]  ram_wdata_i,
        input wire [`AddrLen - 1 : 0]  ram_waddr_i,
        input wire [`memwType - 1 : 0] ram_write_type,
        input wire ram_write,
        input wire ram_read,

        output reg [`InstLen - 1 : 0] ram_data_o
    );




endmodule