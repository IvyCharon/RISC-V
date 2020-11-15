`timescale 1ns / 1ps
`include "config.vh"

module mem(
    input rst,

    //from ex_mem.v
    input wire [`RegLen - 1 : 0]     rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire [`AddrLen - 1 : 0]    mem_addr_i,
    input reg  [`InstLen - 1 : 0]    mem_wdata_i,
    input reg  [`ALU_Len - 1 : 0]    alu_op,
    input wire rd_enable_i,
    input reg  [`StallLen - 1 : 0]   stall_flag,

    //from memory
    input reg  [`InstLen - 1 : 0]    mem_data,
    
    //to mem_wb.v
    output reg [`RegLen - 1 : 0]     rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o,
    output reg  [`StallLen - 1 : 0] stall_flag_o,

    //to memory
    output reg [`InstLen - 1 : 0]  mem_wdata_o,
    output reg [`AddrLen - 1 : 0]  mem_waddr_o,
    output reg [`memwType - 1 : 0] mem_write_type,
    output reg mem_write,
    output reg mem_read
    );

    always @ (*) begin
        if (rst == `ResetEnable || stall_flag == `Stall_next_one ||stall_flag == `Stall_next_two) begin
            rd_data_o   = `ZERO_WORD;
            rd_addr_o   = `RegAddrLen'h0;
            rd_enable_o = `WriteDisable;
            mem_wdata_o = `ZERO_WORD;
            mem_waddr_o = `ZERO_WORD;
            mem_write_type = `No_mem_write;
            mem_write = `WriteDisable;
            mem_read = `ReadDisable;
            if(stall_flag == `Stall_next_one ||stall_flag == `Stall_next_two) stall_flag_o = stall_flag;
            else stall_flag_o = `NoStall;
        end
        else begin
            rd_addr_o = rd_addr_i;
            rd_enable_o = rd_enable_i; 
            stall_flag_o = `NoStall;
            case (alu_op)
                `LB : begin
                    rd_data_o = {{24{mem_data[7]}},mem_data[7:0]};
                    mem_write = `WriteDisable;
                    mem_read = `ReadEnable;
                    mem_wdata_o = `ZERO_WORD;
                    mem_waddr_o = `ZERO_WORD;
                    mem_write_type = `No_mem_write;
                end
                `LW : begin
                    rd_data_o = mem_data;
                    mem_write = `WriteDisable;
                    mem_read = `ReadEnable;
                    mem_wdata_o = `ZERO_WORD;
                    mem_waddr_o = `ZERO_WORD;
                    mem_write_type = `No_mem_write;
                end
                `LH : begin
                    rd_data_o = {{16{mem_data[15]}},mem_data[15:0]};
                    mem_write = `WriteDisable;
                    mem_read = `ReadEnable;
                    mem_wdata_o = `ZERO_WORD;
                    mem_waddr_o = `ZERO_WORD;
                    mem_write_type = `No_mem_write;
                end
                `LBU: begin
                    rd_data_o = {{24{1'b0}},mem_data[7:0]};
                    mem_write = `WriteDisable;
                    mem_read = `ReadEnable;
                    mem_wdata_o = `ZERO_WORD;
                    mem_waddr_o = `ZERO_WORD;
                    mem_write_type = `No_mem_write;
                end
                `LHU: begin
                    rd_data_o = {{16{1'b0}},mem_data[15:0]};
                    mem_write = `WriteDisable;
                    mem_read = `ReadEnable;
                    mem_wdata_o = `ZERO_WORD;
                    mem_waddr_o = `ZERO_WORD;
                    mem_write_type = `No_mem_write;
                end
                `SB : begin
                    mem_waddr_o = rd_data_i;
                    mem_wdata_o = {{24{1'b0}},mem_wdata_i[7:0]};
                    mem_write_type = `sb;
                    mem_write = `WriteEnable;
                    mem_read = `ReadDisable;
                    rd_addr_o = `ZERO_WORD;
                end
                `SH : begin
                    mem_waddr_o = rd_data_i;
                    mem_wdata_o = {{16{1'b0}},mem_wdata_i[15:0]};
                    mem_write_type = `sh;
                    mem_write = `WriteEnable;
                    mem_read = `ReadDisable;
                    rd_addr_o = `ZERO_WORD;
                end
                `SW : begin
                    mem_waddr_o = rd_data_i;
                    mem_wdata_o = mem_wdata_i;
                    mem_write_type = `sw;
                    mem_write = `WriteEnable;
                    mem_read = `ReadDisable;
                    rd_addr_o = `ZERO_WORD;
                end
                default: begin
                    rd_data_o = rd_data_i;  
                    mem_wdata_o = `ZERO_WORD;
                    mem_waddr_o = `ZERO_WORD;
                    mem_write_type = `No_mem_write;
                    mem_write = `WriteDisable;
                    mem_read = `ReadDisable;
                end  
            endcase
        end
    end

endmodule
