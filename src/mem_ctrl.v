//put in riscv_top.v
`include "config.vh"

module mem_ctrl(
    input clk,
    input rst,

    //from mem.v
    input wire mem_write,
    input wire [`AddrLen - 1 : 0] mem_data_addr,
    input wire [`InstLen - 1 : 0] mem_data_i,
    input wire [`memwType - 1 : 0] mem_write_type

    );


    
endmodule