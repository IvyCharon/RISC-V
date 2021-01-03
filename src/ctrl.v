//to handle stall
`timescale 1ns / 1ps
`include "config.vh"

module ctrl (
    input wire rst,

    //from id.v
    input wire stallreq_id,
    //from i_cahce.v
    input wire stallreq_if,
    //from mem.v
    input wire stallreq_mem,

    input wire stallreq_mc,

    //to if_id.v, id_ex.v, ex_mem.v, mem_wb.v
    output reg [5 : 0] stall
    );

    always @ (*) begin
        if(rst == `ResetEnable)
            stall <= 6'b000000;
        else if(stallreq_mc == `Stall)
            stall <= 6'b111111;
        else if(stallreq_mem == `Stall)
            stall <= 6'b011111;
        else if(stallreq_id == `Stall)
            stall <= 6'b000111;
        else if(stallreq_if == `Stall)
            stall <= 6'b000011;
        else stall <= 6'b000000;
    end

endmodule