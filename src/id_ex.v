`timescale 1ns / 1ps

module id_ex(
    input wire clk,
    input wire rst,
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegLen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input reg [`ALU_Len - 1 : 0]    id_alu_op,
    input reg [`Jump_Len - 1 : 0]   id_jump_op,
    input reg [`Branch_Len - 1 : 0] id_branch_op,

    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegLen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg [`ALU_Len - 1 : 0]    ex_alu_op,
    output reg [`Jump_Len - 1 : 0]   ex_jump_op,
    output reg [`Branch_Len - 1 : 0] ex_branch_op
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            //TODO: ASSIGN ALL OUTPUT WITH NULL EQUIVALENT
        end
        else begin
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_Imm <= id_Imm;
            ex_rd <= id_rd;
            ex_rd_enable <= id_rd_enable;
            ex_alu_op <= id_alu_op;
            ex_jump_op <= id_jump_op;
            ex_branch_op <= id_branch_op;
        end
    end

endmodule
