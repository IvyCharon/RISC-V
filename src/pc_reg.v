`timescale 1ns / 1ps
`include "config.vh"

module pc_reg(
    input wire clk,
    input wire rst,

    input wire [5 : 0] stall,

    //from id.v
    input wire JumpFlag,
    input wire [`AddrLen - 1 : 0]  jump_addr,

    //to if.v
    output reg [`AddrLen - 1 : 0]  pc,

    //to what?
    output reg chip_enable
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable)
            chip_enable <= `ChipDisable;
        else
            chip_enable <= `ChipEnable;
    end

    always @ (posedge clk) begin
        if (chip_enable == `ChipDisable) begin
            pc <= `ZERO_WORD;
        end
        else if (!stall[0] && JumpFlag = `BranchEnable) begin
            pc <= jump_addr;
        end
        else if(!stall[0]) begin
            pc <= pc + 4'h4;
        end
    end

endmodule
