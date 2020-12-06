//to handle stall
`timescale 1ns / 1ps
`include "config.vh"

module ctrl (
    input wire rst,

    //from id.v
    input wire stallreq_id,
    input wire stallreq_for_jump,
    //from i_cahce.v
    input wire stallreq_if,
    //from mem.v
    input wire stallreq_mem,

    //to if_id.v, id_ex.v, ex_mem.v, mem_wb.v
    output reg [5 : 0] stall
    );

    always @ (*) begin
        if(rst == `ResetEnable)
            stall = 6'b000000;
        else if(stallreq_mem == `Stall)
            stall = 6'b011111;
        else if(stallreq_id == `Stall)
            stall = 6'b000111;
        else if(stallreq_if == `Stall)
            stall = 6'b000011;
        else if(stallreq_for_jump == `Stall)
            stall = 6'b000010;
        else stall = 6'b000000;
    end

endmodule