`timescale 1ns / 1ps
`include "config.vh"

module pc_reg(
    input wire clk,
    input wire rst,

    //from ctrl.v
    input wire [5 : 0] stall,

    //from ex.v
    input wire JumpFlag,
    input wire [`AddrLen - 1 : 0]  jump_addr,

    //to if.v
    output reg [`AddrLen - 1 : 0]  pc,
    output reg is_jump
    );

    reg [`AddrLen - 1 : 0] pc_r;

/*
    always @ (posedge clk) begin
        if (rst == `ResetEnable)
            chip_enable <= `ChipDisable;
        else
            chip_enable <= `ChipEnable;
    end
*/

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            pc   <= `ZERO_WORD;
            pc_r <= `ZERO_WORD;
            is_jump <= 1'b0;
        end
        else if (JumpFlag == `BranchEnable) begin
            pc_r <= jump_addr + 4;
            pc   <= jump_addr;
            is_jump <= 1'b1;
        end
        else if (!stall[0]) begin
            pc_r <= pc_r + 4;
            pc   <= pc_r;
            is_jump <= 1'b0;
        end
    end

endmodule
