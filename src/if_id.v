`timescale 1ns / 1ps
`include "config.vh"

module if_id(
    input wire clk, 
    input wire rst,

    //from pc_reg.v
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] if_inst,
    input wire [`StallLen - 1 : 0] stall_flag,

    //to id.v
    output reg [`AddrLen - 1 : 0] id_pc,
    output reg [`InstLen - 1 : 0] id_inst,
    output reg [`StallLen - 1 : 0] stall_flag_o
    );
    
    always @ (posedge clk) begin
        if (rst == `ResetEnable || stall_flag == `Stall_next_one || stall_flag == `Stall_next_two) begin
            id_pc <= `ZERO_WORD;
            id_inst <= `ZERO_WORD;
        end
        else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
        stall_flag_o = stall_flag;
    end
endmodule
