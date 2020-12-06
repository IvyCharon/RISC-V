`include "config.vh"

module If (
    input clk,
    input rst,

    //from pc_reg.v
    input wire [`AddrLen - 1 : 0] pc_i,

    //to if_id.v
    output reg [`AddrLen - 1 : 0] pc_o,
    output reg [`InstLen - 1 : 0] inst_o,

    //from i_cache.v
    input wire inst_available,
    input wire [`InstLen - 1 : 0] inst,

    //to i_cache.v
    output reg [`AddrLen - 1 : 0] addr

    );

    assign addr = pc_i;
    assign pc_o = pc_i;

    always @(*) begin
        if(rst) begin
            inst_o   = `ZERO_WORD;
            pc_o     = `ZERO_WORD;
            if_stall = 1'b0;
        end
        else if(inst_available) begin
            inst_o   = inst;
            pc_o     = pc_i;
            if_stall = 1'b0;
        end
        else begin
            inst_o   = `ZERO_WORD;
            pc_o     = `ZERO_WORD;
            if_stall = 1'b1;
        end
    end
    
endmodule