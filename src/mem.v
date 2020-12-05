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

    //from mem_ctrl
    input wire [`InstLen - 1 : 0]    mem_data,
    input wire mem_data_enable,
    input wire icache_busy,
    
    //to mem_wb.v
    //also to id.v for forwarding
    output reg [`RegLen - 1 : 0]     rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o,

    //to mem_ctrl
    output reg [`InstLen - 1 : 0]  mem_wdata_o,
    output reg [`AddrLen - 1 : 0]  mem_addr_o,
    output reg [`memwType - 1 : 0] mem_type,
    output reg mem_rw,
    output reg mem_enable,

    //to ctrl.v
    output reg stallreq
    );

    always @ (*) begin
        if (rst == `ResetEnable) begin
            rd_data_o    <= `ZERO_WORD;
            rd_addr_o    <= `RegAddrLen'h0;
            rd_enable_o  <= `WriteDisable;
            mem_wdata_o  <= `ZERO_WORD;
            mem_addr_o   <= `ZERO_WORD;
            mem_type     <= `No_mem_type;
            mem_rw       <= 1'b0;
            mem_enable   <= 1'b0;
            stallreq     <= `NoStall;
        end
        else if (icache_busy) begin
            rd_data_o    <= `ZERO_WORD;
            rd_addr_o    <= `RegAddrLen'h0;
            rd_enable_o  <= `WriteDisable;
            mem_wdata_o  <= `ZERO_WORD;
            mem_addr_o   <= `ZERO_WORD;
            mem_type     <= `No_mem_type;
            mem_rw       <= 1'b0;
            mem_enable   <= 1'b0;
            stallreq     <= `Stall;
        end
        else if(alu_op == `LB || alu_op == `LH || alu_op == `LW || alu_op == `LBU || alu_op == `LHU) begin
            if(mem_data_enable) begin
                mem_wdata_o  <= `ZERO_WORD;
                mem_addr_o   <= `ZERO_WORD;
                mem_type     <= `No_mem_type;
                mem_rw       <= `read;
                mem_enable   <= 1'b0;
                rd_addr_o    <= rd_addr_i;
                rd_enable_o  <= rd_enable_i; 
                case (alu_op)
                    `LB : rd_data_o       <= {{24{mem_data[7]}},mem_data[7:0]};
                    `LH : rd_data_o       <= {{16{mem_data[15]}},mem_data[15:0]};
                    `LW : rd_data_o       <= mem_data;
                    `LBU: rd_data_o       <= {{24{1'b0}},mem_data[7:0]};
                    `LHU: rd_data_o       <= {{16{1'b0}},mem_data[15:0]};
                    default: rd_data_o    <= rd_data_i;
                endcase
                stallreq <= `NoStall;
            end
            else begin
                mem_wdata_o <= `ZERO_WORD;
                mem_addr_o  <= mem_addr_i;
                mem_rw      <= `read;
                mem_enable  <= 1'b1;
                if(alu_op == `LB || alu_op == `LBU)
                    mem_type <= `b;
                if(alu_op == `LH || alu_op == `LHU)
                    mem_type <= `h;
                if(alu_op == `LW)
                    mem_type <= `w;
                stallreq     <= `Stall;
                rd_enable_o  <= 1'b0;
                rd_addr_o    <= rd_addr_i;
                rd_data_o    <= `ZERO_WORD;
            end
        end
        else if(alu_op == `SB || alu_op == `SH || alu_op == `SW) begin
            if(mem_data_enable) begin
                mem_enable  <= 1'b0;
                mem_rw      <= 1'b0;
                mem_addr_o  <= `ZERO_WORD;
                mem_wdata_o <= `ZERO_WORD;
                mem_type    <= `No_mem_type;
                rd_enable_o <= 1'b0;
                rd_addr_o   <= `Zero_Reg;
                rd_data_o   <= `ZERO_WORD;
                stallreq    <= `NoStall;
            end
            else begin
                mem_enable  <= 1'b1;
                mem_rw      <= `write;
                mem_addr_o  <= mem_addr_i;
                case (alu_op)
                    `SB : begin
                        mem_wdata_o  <= {{24{1'b0}},mem_wdata_i[7:0]};
                        mem_type     <= `b;
                    end
                    `SH : begin
                        mem_wdata_o  <= {{16{1'b0}},mem_wdata_i[15:0]};
                        mem_type     <= `h;
                    end
                    `SW : begin
                        mem_wdata_o  <= mem_wdata_i;
                        mem_type     <= `w;
                    end
                    default: begin
                        mem_wdata_o  <= `ZERO_WORD;
                        mem_type     <= `No_mem_type;
                    end
                endcase
                rd_enable_o <= 1'b0;
                rd_addr_o   <= `Zero_Reg;
                rd_data_o   <= `ZERO_WORD;
                stallreq    <= `Stall;
            end
        end
        else begin
            mem_wdata_o <= `ZERO_WORD;
            mem_addr_o  <= `ZERO_WORD;
            mem_type    <= `No_mem_type;
            mem_rw      <= 1'b0;
            mem_enable  <= 1'b0;
            rd_enable_o <= rd_enable_i;
            rd_addr_o   <= rd_addr_i;
            rd_data_o   <= rd_data_i;
            stallreq    <= `NoStall;
        end
    end

endmodule
