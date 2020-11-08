`timescale 1ns / 1ps

module min_sopc(
    input wire clk,
    input wire rst
    );

    wire [`AddrLen - 1 : 0] rom_addr;
    wire rom_ce;
    wire [`InstLen - 1 : 0] inst;

    cpu cpu0(
        .clk_in(clk),
        .rst_in(rst),
        .rom_data_i(inst),
        .rom_addr_o(rom_addr),
        .rom_ce_o(rom_ce)
    );
    rom rom0(
        .ce(rom_ce),
        .addr(rom_addr),
        .inst(inst)
    );

endmodule
