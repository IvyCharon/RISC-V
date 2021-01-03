# RISC-V CPU

MS108-Computer System(1) homework.

A 5-stage pipeline CPU that implements RV32I with Verilog HDL.

### Performance on FPGA

Frequency: 100MHz

WNS:  -0.276ns

| Test case      | Time(s)    |
| -------------- | ---------- |
| array_test1    | 0.015625   |
| array_test2    | 0.015625   |
| basicopt1      | 0.015625   |
| bulgarian      | 1.046875   |
| expr           | 0.000000   |
| gcd            | 0.015625   |
| hanoi          | 2.359375   |
| heart          | 657.937500 |
| lvalue2        | 0.000000   |
| magic          | 0.031250   |
| manyarguments  | 0.000000   |
| multiarray     | 0.015625   |
| pi             | 1.734375   |
| qsort          | 4.250000   |
| queens         | 2.187500   |
| statement_test | skipped    |
| superloop      | 0.015625   |
| tak            | 0.046875   |
| testsleep      | 7.000000   |
| uartboom       | 0.390625   |

### Structure

Showed in picture CPU.jpg

### Features

#### basic design 

Use `mem_ctrl` to handle read from/write to RAM, a typical structural hazard.

Use `ctrl` to handle necessary stalls of pipeline. 

Forwarding: in `ex` and `mem`, send data to `id`, achieving full data forwarding.

#### mem_ctrl

- If there is read or write signal at the same time, the sequence is: mem write before mem read before i-cache read.
- To handle io_buffer_full, send a stall signal from `mem_ctrl` to `ctrl` to achieve necessary stall when io_buffer is full.

#### i_cache

- direct-mapped cache
- size: 128 * 4 = 512 Byte

#### branch prediction

A static branch prediction which predicts pc not to jump by default. If there is jump request in `ex`, it will send the address to `pc_reg`, meanwhile send `clear` signal to `if_id` and `id_ex` to clear all regs. 

If instruction is read from memory instead of i-cache, when jump signal is created, this instruction is not totally read yet. At this time, in `mem_ctrl`, the read of the unwanted instruction will be stopped.

### Difficulties

- Stall controller is learned on reference book but I think it is a little chaotic.
- It is a pity that I don't have much time to write BTB and d-cache so I quit it, using the simplest static prediction.

### reference

+ 雷思磊.自己动手写CPU,电子工业出版社,2014
