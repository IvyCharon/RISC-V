`timescale 1ns / 1ps
`include "config.vh"

module mem(
    input rst,

    //from ex_mem.v
    input wire [`RegLen - 1 : 0]     rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire [`AddrLen - 1 : 0]    mem_addr_i,
    input wire [`InstLen - 1 : 0]    mem_wdata_i,
    input wire [`ALU_Len - 1 : 0]    alu_op,
    input wire rd_enable_i,

    //from memory
    input wire [`InstLen - 1 : 0]    mem_data,
    input wire busy,
    
    //to mem_wb.v
    output reg [`RegLen - 1 : 0]     rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o,

    //to memory
    output reg [`InstLen - 1 : 0]  mem_wdata_o,
    output reg [`AddrLen - 1 : 0]  mem_addr_o,
    output reg [`memwType - 1 : 0] mem_type,
    output reg mem_write,
    output reg mem_read,

    //to ctrl.v
    output reg stallreq
    );

    always @ (*) begin
        if (rst == `ResetEnable) begin
            rd_data_o    = `ZERO_WORD;
            rd_addr_o    = `RegAddrLen'h0;
            rd_enable_o  = `WriteDisable;
            mem_wdata_o  = `ZERO_WORD;
            mem_addr_o   = `ZERO_WORD;
            mem_type     = `No_mem_type;
            mem_write    = `WriteDisable;
            mem_read     = `ReadDisable;
            stallreq     = `NoStall;
        end
        else if (busy) begin
            rd_data_o    = `ZERO_WORD;
            rd_addr_o    = `RegAddrLen'h0;
            rd_enable_o  = `WriteDisable;
            mem_wdata_o  = `ZERO_WORD;
            mem_addr_o   = `ZERO_WORD;
            mem_type     = `No_mem_type;
            mem_write    = `WriteDisable;
            mem_read     = `ReadDisable;
            stallreq     = `Stall;
        end
        else begin
            rd_addr_o    = rd_addr_i;
            rd_enable_o  = rd_enable_i; 
            case (alu_op)
                `LB : begin
                    rd_data_o    = {{24{mem_data[7]}},mem_data[7:0]};
                    mem_addr_o   = mem_addr_i;                    
                    mem_write    = `WriteDisable;
                    mem_read     = `ReadEnable;
                    mem_wdata_o  = `ZERO_WORD;
                    mem_type     = `b;
                end
                `LW : begin
                    rd_data_o    = mem_data;
                    mem_addr_o   = mem_addr_i;
                    mem_write    = `WriteDisable;
                    mem_read     = `ReadEnable;
                    mem_wdata_o  = `ZERO_WORD;
                    mem_type     = `w;
                end
                `LH : begin
                    rd_data_o    = {{16{mem_data[15]}},mem_data[15:0]};
                    mem_addr_o   = mem_addr_i;
                    mem_write    = `WriteDisable;
                    mem_read     = `ReadEnable;
                    mem_wdata_o  = `ZERO_WORD;
                    mem_type     = `h;
                end
                `LBU: begin
                    rd_data_o    = {{24{1'b0}},mem_data[7:0]};
                    mem_addr_o   = mem_addr_i;
                    mem_write    = `WriteDisable;
                    mem_read     = `ReadEnable;
                    mem_wdata_o  = `ZERO_WORD;
                    mem_type     = `b;
                end
                `LHU: begin
                    rd_data_o    = {{16{1'b0}},mem_data[15:0]};
                    mem_addr_o   = mem_addr_i;
                    mem_write    = `WriteDisable;
                    mem_read     = `ReadEnable;
                    mem_wdata_o  = `ZERO_WORD;
                    mem_type     = `h;
                end
                `SB : begin
                    mem_addr_o   = mem_addr_i;
                    mem_wdata_o  = {{24{1'b0}},mem_wdata_i[7:0]};
                    mem_type     = `b;
                    mem_write    = `WriteEnable;
                    mem_read     = `ReadDisable;
                    rd_addr_o    = `ZERO_WORD;
                    stallreq     = `NoStall;
                end
                `SH : begin
                    mem_addr_o   = mem_addr_i;
                    mem_wdata_o  = {{16{1'b0}},mem_wdata_i[15:0]};
                    mem_type     = `h;
                    mem_write    = `WriteEnable;
                    mem_read     = `ReadDisable;
                    rd_addr_o    = `ZERO_WORD;
                    stallreq     = `NoStall;
                end
                `SW : begin
                    mem_addr_o   = mem_addr_i;
                    mem_wdata_o  = mem_wdata_i;
                    mem_type     = `w;
                    mem_write    = `WriteEnable;
                    mem_read     = `ReadDisable;
                    rd_addr_o    = `ZERO_WORD;
                    stallreq     = `NoStall;
                end
                default: begin
                    rd_data_o    = rd_data_i;  
                    mem_wdata_o  = `ZERO_WORD;
                    mem_addr_o   = mem_addr_i;
                    mem_type     = `No_mem_type;
                    mem_write    = `WriteDisable;
                    mem_read     = `ReadDisable;
                    stallreq     = `NoStall;
                end  
            endcase
        end
    end

endmodule
