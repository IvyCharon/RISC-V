//to handle stall
`timescale 1ns / 1ps
`include "config.vh"

module ctrl (
    input wire rst,

    input wire stallreq_id,
    input wire stallreq_if,
    input wire stallreq_mem,

    input wire stallreq_for_jump,

    output reg [5 : 0] stall
    );

    always @ (*) begin
        if(rst == `ResetEnable)
            stall = 6'b000000;
        else if(stallreq_mem == `Stop)
            stall = 6'b011111;
        else if(stallreq_id == `Stop)
            stall = 6'b000111;
        else if(stallreq_if == `Stop)
            stall = 6'b000011;
        else if(stallreq_for_jump == `Stop)
            stall = 6'b000010;
        else stall = 6'b000000;
    end

endmodule