`include "config.vh"

module If (
    input clk,
    input rst,

    //from pc_reg.v
    input wire [`AddrLen - 1 : 0] pc_i,
    input wire is_jump,

    //to if_id.v
    output reg [`AddrLen - 1 : 0] pc_o,
    output reg [`InstLen - 1 : 0] inst_o,

    //from i_cache.v
    input wire inst_available,
    input wire [`InstLen - 1 : 0] inst,

    //to i_cache.v
    output reg [`AddrLen - 1 : 0] addr,
    output reg is_jump_o

    );

    reg [1:0] check_jump;

    always @(*) begin
        addr <= pc_i;
        pc_o <= pc_i;
        is_jump_o <= check_jump == 2'b00 ? is_jump : 1'b0;
        if(rst) begin
            inst_o     <= `ZERO_WORD;
            pc_o       <= `ZERO_WORD;
            check_jump <= 2'b00;
        end
        else if(inst_available) begin
            inst_o     <= inst;
            pc_o       <= pc_i;
            check_jump <= 2'b00;
        end
        else begin
            inst_o     <= `ZERO_WORD;
            pc_o       <= `ZERO_WORD;
            check_jump <= is_jump ? (check_jump == 2'b00 ? 2'b01 : 2'b10) : 2'b00;
        end
    end
    
endmodule