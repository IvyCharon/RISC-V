`timescale 1ns / 1ps

module pc_reg(
    input wire clk,
    input wire rst,
    output reg [`AddrLen - 1 : 0] pc,
    output reg chip_enable
    );

    always @ (posedge clk) begin
        if (rst == `ResetEnable)
            chip_enable <= `ChipDisable;
        else
            chip_enable <= `ChipEnable;
    end

    always @ (posedge clk) begin
        if (chip_enable == `ChipDisable) begin
            pc <= `ZERO_WORD;
        end
        else begin
            pc <= pc + 4'h4;
        end
    end

endmodule
