`timescale 1ns / 1ps
`include "config.vh"

module pc_reg(
    input wire clk,
    input wire rst,

    //from id.v
    input wire JumpFlag,
    input wire [`AddrLen - 1 : 0] jump_addr,
    input wire [`StallLen - 1 : 0] stall_flag_id,

    //from register.v/write part
    input wire [`StallLen - 1 : 0] stall_flag_wb,
    
    //to if_id.v
    output reg [`AddrLen - 1 : 0] pc,
    output reg [`StallLen - 1 : 0] stall_flag_o,

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
        if (chip_enable == `ChipDisable || stall_flag_id != `NoStall || stall_flag_wb != `NoStall) begin
            pc <= `ZERO_WORD;
        end
        else if (JumpFlag = `BranchEnable) begin
            pc <= jump_addr;
        end
        else begin
            pc <= pc + 4'h4;
        end

        if(stall_flag_id == `Stall_next_two || stall_flag_wb == `Stall_next_two)
            stall_flag_o = `Stall_next_two;
        else if(stall_flag_id == `Stall_next_one || stall_flag_wb == `Stall_next_one)
            stall_flag_o = `Stall_next_one;
        else stall_flag_o = `NoStall;
    end

endmodule
