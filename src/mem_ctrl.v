//put in riscv_top.v
`include "config.vh"

module mem_ctrl(
    input clk,
    input rst,

    //from mem.v
    input wire mem_write,
    input wire mem_read,
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
    output reg wr   //0 for read, 1 for write

    );




    
endmodule