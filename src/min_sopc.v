`timescale 1ns / 1ps
`include "config.vh"

module min_sopc(
    input wire clk,
    input wire rst
    );

    wire [`AddrLen - 1 : 0] rom_addr;
    wire rom_ce;
    wire [`InstLen - 1 : 0] inst;

    wire [`InstLen - 1 : 0]  ram_wdata_i;
    wire [`AddrLen - 1 : 0]  ram_waddr_i;
    wire [`memwType - 1 : 0] ram_write_type;
    wire ram_write;
    wire ram_read;

    wire [`InstLen - 1 : 0] ram_data_o;
    
    cpu cpu0(
        .clk_in(clk),
        .rst_in(rst),
        .rom_data_i(inst),
        .rom_addr_o(rom_addr),
        .rom_ce_o(rom_ce),

        .ram_wdata_o(ram_wdata_i),
        .ram_waddr_o(ram_waddr_i),
        .ram_write_type(ram_write_type),
        .ram_write(ram_write),
        .ram_read(ram_read)
    );
    
    rom rom0(
        .ce(rom_ce),
        .addr(rom_addr),
        .inst(inst)
    );

    ram ram0(
        .clk(clk_in),

        .ram_wdata_i(ram_waddr_i),
        .ram_waddr_i(ram_waddr_i),
        .ram_write_type(ram_write_type),
        .ram_write(ram_write),
        .ram_read(ram_read),

        .ram_data_o(ram_data_o)
    );

endmodule
