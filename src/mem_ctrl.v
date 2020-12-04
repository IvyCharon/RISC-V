//put in riscv_top.v
`include "config.vh"

module mem_ctrl(
    input clk,
    input rst,

    //
    input wire jump_signal,

    //from mem.v
    input wire mem_rw,
    input wire mem_enable,
    input wire [`AddrLen - 1 : 0] mem_data_addr,
    input wire [`InstLen - 1 : 0] mem_data_i,
    input wire [`memwType - 1 : 0] mem_type,

    //from i_cache.v
    input wire icache_needed,
    input wire [`AddrLen - 1 : 0] icache_addr,

    //to mem.v
    output reg [`InstLen - 1 : 0] mem_data_o,
    output reg busy,

    //to i_cache.v
    output reg inst_available_o,
    output reg [`InstLen - 1 : 0] inst_icache,

    //from ram.v
    input wire [7 : 0] ram_data_i,

    //to ram.v
    output reg [`AddrLen - 1 : 0] ram_addr,
    output reg [7 : 0] ram_data,
    output reg ram_rw   //0 for read, 1 for write

    );

    reg [2:0] cnt;

    wire [`AddrLen - 1 : 0] addr;
    wire [2:0] num;

    reg [7:0] l_data[3:0];
    reg [7:0] s_data[3:0];

    assign s_data[0] = mem_data_i[7:0];
    assign s_data[1] = mem_data_i[15:8];
    assign s_data[2] = mem_data_i[23:16];
    assign s_data[3] = mem_data_i[31:24];

    always @(*) begin
        if(mem_enable) begin
            addr = mem_data_addr;
            case (mem_type)
                `b : num = 3'b001;
                `h : num = 3'b010;
                `w : num = 3'b100; 
                default: num = 3'b000;
            endcase
            ram_rw = (cnt == num) ? mem_rw : 1'b0;
        end
        else begin
            addr = icache_addr;
            ram_rw = 1'b0;
            if(icache_needed) num = 3'b100;
            else num = 3'b000;
        end
    end

    assign ram_addr = addr + cnt;
    assign ram_data = (cnt = 3'b100) ? `ZEROWORD : s_data[cnt];

    always @(posedge clk) begin
        if(rst == `ResetEnable || (jump_signal && !mem_enable)) begin
            
        end
        else begin
            
        end
    end


    
endmodule