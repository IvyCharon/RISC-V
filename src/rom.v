`timescale 1ns / 1ps
`include "config.vh"

module rom(
    input wire ce,
    input wire[`AddrLen -1 : 0]  addr, 
    output reg[`InstLen - 1 : 0] inst
    );

    reg[`InstLen : 0] inst_mem[0 : `RAM_SIZE - 1];
    initial begin
        $readmemh("inst.data", inst_mem);
    end
    
    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst = `ZERO_WORD;
        end
        else begin
            inst = inst_mem[addr[17:2]];    //why addr[17:2]?
        end
    end
endmodule
