`timescale 1ns / 1ps

module min_sopc_test();
    reg CLOCK_50, rst;

    //50MHz
    initial begin 
        CLOCK_50 = 1'b0; 
        forever #10 CLOCK_50 = ~CLOCK_50; 
    end

    initial begin
        rst = `ResetEnable;
        #30 rst = `ResetDisable;
        #200 $stop;
    end

    min_sopc cpu(.clk(CLOCK_50), .rst(rst));

endmodule
