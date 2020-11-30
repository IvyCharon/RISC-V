`include "config.vh"

module i_cache (
    input clk,
    input rst,

    //from if.v
    input wire [`AddrLen - 1 : 0] inst_addr_i,

    //to if.v
    output reg [`InstLen - 1 : 0] inst,
    output reg [`AddrLen - 1 : 0] inst_addr_o,
    output reg inst_available_o,

    //from mem_ctrl.v
    input wire [`InstLen - 1 : 0] inst_mem,
    input wire inst_available_i,

    //to mem_ctrl.v
    output reg inst_needed,
    output reg [`AddrLen - 1 : 0] inst_addr_to_mem
    );

    reg [`InstLen - 1 : 0] icache[`i_cache_line - 1 : 0];
    reg [`TagLen - 1 : 0]  tag[`i_cache_line - 1 : 0];
    reg valid[`i_cache_line - 1 : 0];

    wire [6 : 0]  addr_index;
    wire [22 : 0] addr_tag;

    assign addr_index = inst_addr_i[8 : 2];
    assign addr_tag = inst_addr_i[31 : 9];

    always @(*) begin
        if(rst == `ResetEnable) begin
            inst_needed = 0;
            inst_available_o = 0;
        end
        else if(addr_tag == tag[addr_index] && valid[addr_index]) begin  //hit
            inst_needed = 0;
            inst_available_o = 1;
        end
        else begin  //not hit
            inst_needed = 1;
            inst_available_o = 0;
        end
    end
    
    integer i;
    always @(*) begin
        if(rst == `ResetEnable) begin
            for(i = 0; i < i_cache_line; i = i + 1) begin
                valid[i] <= 1'b0;
            end
        end
        else if(inst_available_i) begin
            icache[addr_index] <= inst_mem;
            tag[addr_index] <= addr_tag;
            valid[addr_index] <= 1'b1;
        end
    end
    
endmodule