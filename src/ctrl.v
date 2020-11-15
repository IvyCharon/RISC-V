//to handle stall
`timescale 1ns / 1ps
`include "config.vh"

module ctrl (
    input wire rst,

    input wire stallreq_id,

    output reg [5 : 0] stall
    );

    always @ (*) begin
        if(rst == `ResetEnable)
            stall = 6'b000000;
        else if(stallreq_id == `Stop)
            stall = 6'b000111;
        else stall = 6'b000000;
    end

endmodule