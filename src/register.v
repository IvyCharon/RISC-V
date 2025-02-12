`timescale 1ns / 1ps
`include "config.vh"

module register(
    input wire clk,
    input wire rst,

    //write, form mem_wb.v
    input wire write_enable,
    input wire [`RegAddrLen - 1 : 0] write_addr,
    input wire [`RegLen - 1 : 0]     write_data,

    //read 1, from id.v
    input wire read_enable1,   
    input wire [`RegAddrLen - 1 : 0] read_addr1,
    //to id.v
    output reg [`RegLen - 1 : 0]     read_data1,

    //read 2, from id.v
    input wire read_enable2,   
    input wire [`RegAddrLen - 1 : 0] read_addr2,
    //to id.v
    output reg [`RegLen - 1 : 0]     read_data2
    );
    
    reg[`RegLen - 1 : 0] regs[`RegNum - 1 : 0];

    integer i;
    
    //write 1
    always @ (posedge clk) begin
        if (rst == `ResetEnable) begin
            for (i = 0;i <= 31; i = i + 1) begin
                regs[i] <= `ZERO_WORD;
            end
        end
        if (rst == `ResetDisable && write_enable == `WriteEnable) begin
            if (write_addr != `RegAddrLen'h0) //not zero register
                regs[write_addr] <= write_data;
        end
    end

    //read 1
    always @ (*) begin
        if (rst == `ResetDisable && read_enable1 == `ReadEnable) begin
            if (read_addr1 == `RegAddrLen'h0)
                read_data1 <= `ZERO_WORD;
            else if (read_addr1 == write_addr && write_enable == `WriteEnable)
                read_data1 <= write_data;    //forwarding for WB -> ID
            else
                read_data1 <= regs[read_addr1];
        end
        else begin
            read_data1 <= `ZERO_WORD;
        end
    end

    //read 2
    always @ (*) begin
        if (rst == `ResetDisable && read_enable2 == `ReadEnable) begin
            if (read_addr2 == `RegAddrLen'h0)
                read_data2 <= `ZERO_WORD;
            else if (read_addr2 == write_addr && write_enable == `WriteEnable)
                read_data2 <= write_data;
            else
                read_data2 <= regs[read_addr2];
        end
        else begin
            read_data2 <= `ZERO_WORD;
        end 
    end

endmodule
