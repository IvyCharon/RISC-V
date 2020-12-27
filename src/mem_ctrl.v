//put in riscv_top.v
`timescale 1ns / 1ps
`include "config.vh"

module mem_ctrl(
    input clk,
    input rst,

    //from mem.v
    input wire mem_rw,
    input wire mem_enable,
    input wire [`AddrLen - 1 : 0]  mem_data_addr,
    input wire [`InstLen - 1 : 0]  mem_data_i,
    input wire [`memwType - 1 : 0] mem_type,

    //from i_cache.v
    input wire icache_needed,
    input wire [`AddrLen - 1 : 0] icache_addr,

    //busy signal
    //to i_cache.v
    output reg mem_busy,
    //to mem.v
    output reg icache_busy,

    //to mem.v
    output reg [`InstLen - 1 : 0] mem_data_o,
    output reg mem_data_enable,

    //to i_cache.v
    output reg [`InstLen - 1 : 0] inst_o,
    output reg inst_data_enable,

    //from ram.v
    input wire [7 : 0] ram_data_i,

    //to ram.v
    output wire [`AddrLen - 1 : 0] ram_addr,
    output wire [7 : 0] ram_data,
    output wire ram_rw   //0 for read, 1 for write

    );

    reg [2:0] cnt;//to remember how much bytes were read/written
    reg [`AddrLen - 1 : 0] raddr;

    wire [`AddrLen - 1 : 0] addr;
    wire [2:0] num;

    reg [7:0] l_data[3:0];
    wire [7:0] s_data[3:0];

    assign s_data[0] = mem_data_i[7:0];
    assign s_data[1] = mem_data_i[15:8];
    assign s_data[2] = mem_data_i[23:16];
    assign s_data[3] = mem_data_i[31:24];

    assign addr = mem_enable ? mem_data_addr : icache_addr;
    assign ram_rw = mem_enable ? ((cnt == num) ? 1'b0 : mem_rw ) : `read;

    assign num = mem_enable ? (mem_type == `b ? (3'b001) : (mem_type == `h ? 3'b010: 3'b100)) : (icache_needed ? 3'b100 : 3'b000);

    assign ram_addr = addr + cnt;
    assign ram_data = (cnt == 3'b100) ? `ZERO_WORD : s_data[cnt];

    always @(*) begin
        if(rst == `ResetEnable) begin
            raddr <= `ZERO_WORD;
        end
        else if(raddr != addr && !ram_rw) begin
            cnt <= 0;
            raddr <= addr;
        end
    end

    always @(posedge clk) begin
        if(rst == `ResetEnable) begin
            cnt              <= 0;
            inst_data_enable <= 0;
            mem_data_enable  <= 0;
            mem_busy         <= 0;
            icache_busy      <= 0;
            mem_data_o       <= `ZERO_WORD;
            inst_o           <= `ZERO_WORD;
            l_data[0]        <= 8'b00000000;
            l_data[1]        <= 8'b00000000;
            l_data[2]        <= 8'b00000000;
            l_data[3]        <= 8'b00000000;
        end
        else if(num != 0 && ram_rw == `read) begin
            if(cnt == 0) begin
                cnt              <= 1;
                inst_data_enable <= 1'b0;
                mem_data_enable  <= 1'b0;
                mem_busy         <= mem_enable;
                icache_busy      <= icache_needed && (! mem_enable);
                mem_data_o       <= `ZERO_WORD;
                inst_o           <= `ZERO_WORD;
            end
            else if(cnt < num) begin
                cnt              <= cnt + 1;
                l_data[cnt - 1]  <= ram_data_i;
            end
            else begin
                if(mem_enable) begin
                    mem_data_enable <= 1'b1;
                    case (mem_type)
                        `b : mem_data_o <= ram_data_i;
                        `h : mem_data_o <= {ram_data_i, l_data[0]};
                        `w : mem_data_o <= {ram_data_i, l_data[2], l_data[1], l_data[0]};
                        default: mem_data_o <= `ZERO_WORD;
                    endcase
                end
                else begin
                    inst_data_enable <= 1'b1;
                    inst_o <= {ram_data_i, l_data[2], l_data[1], l_data[0]};
                end
                cnt <= 0;
            end
        end
        else if(num != 0 && ram_rw == `write) begin
            inst_data_enable <= 1'b0;
            inst_o <= `ZERO_WORD;
            if(cnt + 1 == num) begin
                cnt             <= 0;
                mem_data_enable <= 1'b1;
            end
            else if(cnt == 0) begin
                cnt             <= cnt + 1;
                icache_busy     <= 1'b0;
                mem_busy        <= 1'b1;
                mem_data_enable <= 1'b0;
                mem_data_o      <= `ZERO_WORD;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
        else begin
            cnt              <= 0;
            inst_data_enable <= 0;
            mem_data_enable  <= 0;
            mem_busy         <= 0;
            icache_busy      <= 0;
            mem_data_o       <= `ZERO_WORD;
            inst_o           <= `ZERO_WORD;
            l_data[0]        <= 8'b00000000;
            l_data[1]        <= 8'b00000000;
            l_data[2]        <= 8'b00000000;
            l_data[3]        <= 8'b00000000;
        end
    end

endmodule