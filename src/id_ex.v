`timescale 1ns / 1ps
`include "config.vh"

module id_ex(
    input wire clk,
    input wire rst,

    //from id.v
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegLen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input wire [`ALU_Len - 1 : 0]    id_alu_op,
    input wire [`Jump_Len - 1 : 0]   id_jump_op,
    input wire [`Branch_Len - 1 : 0] id_branch_op,
    input wire [`AddrLen - 1 ：0]    id_addr_for_rd,
    input wire [`StallLen - 1 : 0]   id_stall_flag,

    //to ex.v
    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegLen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg [`ALU_Len - 1 : 0]    ex_alu_op,
    output reg [`Jump_Len - 1 : 0]   ex_jump_op,
    output reg [`Branch_Len - 1 : 0] ex_branch_op,
    output reg [`AddrLen - 1 ：0]    ex_addr_for_rd
    output reg [`StallLen - 1 : 0]   ex_stall_flag,
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            ex_reg1 <= `ZERO_WORD;
            ex_reg2 <= `ZERO_WORD;
            ex_Imm <= `ZERO_WORD;
            ex_rd <= `ZERO_WORD;
            ex_rd_enable <= `WriteDisable;
            ex_alu_op <= `NoAlu;
            ex_jump_op <= `NoJump;
            ex_branch_op <= `NoBranch;
            ex_addr_for_rd <= `ZERO_WORD;
            ex_stall_flag <= `NoStall;
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
            ex_addr_for_rd <= id_addr_for_rd;
            ex_stall_flag <= id_stall_flag;
        end
    end

endmodule
