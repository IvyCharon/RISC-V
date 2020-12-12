`timescale 1ns / 1ps
`include "config.vh"

module i_cache (
    input clk,
    input rst,

    //from if.v
    input wire [`AddrLen - 1 : 0] inst_addr_i,
    input wire is_jump_i,

    //to if.v
    output reg [`InstLen - 1 : 0] inst,
    output reg inst_available_o,

    //from mem_ctrl.v
    input wire [`InstLen - 1 : 0] inst_mem,
    input wire inst_enable_i,
    input wire mem_busy,

    //to mem_ctrl.v
    output reg inst_needed,
    output reg [`AddrLen - 1 : 0] inst_addr_to_mem,
    output reg is_jump_o,

    //to ctrl.v
    output reg stallreq

    );

    reg [`InstLen - 1 : 0] icache[`i_cache_line - 1 : 0];
    reg [`TagLen - 1 : 0]  tag[`i_cache_line - 1 : 0];
    reg valid[`i_cache_line - 1 : 0];

    wire [6 : 0]  addr_index;
    wire [22 : 0] addr_tag;

    assign addr_index = inst_addr_i[8 : 2];
    assign addr_tag   = inst_addr_i[31 : 9];

    wire hit = (addr_tag == tag[addr_index]) && valid[addr_index];

    always @(*) begin
        if(rst == `ResetEnable) begin
            inst_available_o <= 1'b0;
            inst             <= `ZERO_WORD;
            stallreq         <= `NoStall;
        end
        else if(hit) begin
            inst_available_o <= 1'b1;
            inst             <= icache[addr_index];
            stallreq         <= `NoStall;
        end
        else begin
            inst_available_o <= 1'b0;
            inst             <= `ZERO_WORD;
            stallreq         <= `Stall;
        end
    end

    always @(posedge clk) begin
        if(rst == `ResetEnable) begin
            inst_needed      <= 1'b0;
            inst_addr_to_mem <= `ZERO_WORD;
            is_jump_o        <= 1'b0;
        end
        else begin
            if(hit) begin
                inst_needed      <= 1'b0;
                inst_addr_to_mem <= `ZERO_WORD;
                is_jump_o        <= 1'b0;
            end
            else begin
                if(inst_enable_i || mem_busy) begin
                    inst_needed      <= 1'b0;
                    inst_addr_to_mem <= `ZERO_WORD;
                    is_jump_o        <= 1'b0;
                end
                else begin
                    inst_needed      <= 1'b1;
                    inst_addr_to_mem <= inst_addr_i; 
                    is_jump_o        <= is_jump_i;
                end
            end
        end
    end
    
    integer i;
    always @(posedge clk) begin
        if(rst == `ResetEnable) begin
            for(i = 0; i < `i_cache_line; i = i + 1) begin
                valid[i]  <= 0;
                tag[i]    <= 0;
                icache[i] <= 0;
            end
        end
        else if(inst_enable_i) begin
            icache[addr_index] <= inst_mem;
            tag[addr_index]    <= addr_tag;
            valid[addr_index]  <= 1'b1;
        end
    end
    
endmodule