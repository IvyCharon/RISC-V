# RISC-V CPU

MS108-Computer System(1) homework.

A CPU that implements RV32I with Verilog HDL.

### Performance on FPGA

Best frequency is xx with 

| test case      | time    |
| -------------- | ------- |
| array_test1    | 1       |
| array_test2    | 1       |
| basicopt1      | 1       |
| bulgarian      | 1       |
| expr           | 1       |
| gcd            | 1       |
| hanoi          | 1       |
| heart          | 1       |
| lvalue2        | 1       |
| magic          | 1       |
| manyarguments  | 1       |
| multiarray     | 1       |
| pi             | 1       |
| qsort          | 1       |
| queens         | 1       |
| statement_test | skipped |
| superloop      | 1       |
| tak            | 1       |
| testsleep      | 1       |
| uartboom       | 0       |

### icache参数

### 分支预测策略

实现的是静态预测不跳转，当在`ex`阶段发现有跳转需求时，发送跳转指令给`pc_reg`，同时发送`clear`信号给`if_id`和`id_ex`清空数据。

### reference

+ 《自己动手写CPU》