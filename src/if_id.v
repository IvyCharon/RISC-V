`timescale 1ns / 1ps
`include "config.v"

module if_id(
    input wire clk, 
    input wire rst,
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] if_inst,

    output reg [`AddrLen - 1 : 0] id_pc,
    output reg [`InstLen - 1 : 0] id_inst
    );
    
    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            id_pc <= `ZERO_WORD;
            id_inst <= `ZERO_WORD;
        end
        else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule
