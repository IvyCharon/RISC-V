`include "config.vh"

module if (
    input clk,
    input rst,

    //from pc_reg.v
    input wire [`AddrLen - 1 : 0] pc_i,

    //to if_id.v
    output reg [`AddrLen - 1 : 0] pc_o,
    output reg [`InstLen - 1 : 0] inst_o,

    //from mem(wait to be changed to i-cahce)
    input wire inst_available,
    input wire inst,


    );

    always @(*) begin
        if(rst) begin
            inst_o = `ZERO_WORD;
        end 
        else if(pc_i == `ZERO_WORD) begin
            inst_o = `ZERO_WORD;
        end
        else if(inst_available) begin
            inst_o = inst;
        end
        else begin
            inst_o = `ZERO_WORD;
        end
    end

    always @(*) begin
       if(rst) begin
           
       end 
       else if(pc_i == `ZERO_WORD) begin
           
       end
    end
    
endmodule