# RISC-V CPU

MS108-Computer System(1) homework.

A CPU that implements RV32I with Verilog HDL.

### Performance on FPGA

Frequency: 100mHz

WNS:  -0.231ns

| Test case      | Time(s)    |
| -------------- | ---------- |
| array_test1    | 0.015625   |
| array_test2    | 0.015625   |
| basicopt1      | 0.015625   |
| bulgarian      | 0.937500   |
| expr           | 0.015625   |
| gcd            | 0.000000   |
| hanoi          | 2.484375   |
| heart          | 659.437500 |
| lvalue2        | 0.015625   |
| magic          | 0.000000   |
| manyarguments  | 0.015625   |
| multiarray     | 0.015625   |
| pi             | 1.765625   |
| qsort          | 4.812500   |
| queens         | 2.312500   |
| statement_test | skipped    |
| superloop      | 0.031250   |
| tak            | 0.046875   |
| testsleep      | 7.000000   |
| uartboom       | 0.531250   |

### i_cache

- direct-mapped cache
- 128 * 4 = 512 Byte

### Branch-prediction

A static branch prediction which does not jump by default. If there is jump request in `ex`, it will send the address to `pc_reg`, meanwhile send `clear` signal to `if_id` and `id_ex` to clear all regs.

### Structure

![](https://github.com/IvyCharon/RISC-V/blob/main/CPU.jpg)

### reference

+ 雷思磊.自己动手写CPU,电子工业出版社,2014