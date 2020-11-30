`timescale 1ns / 1ps

`define ZERO_WORD  32'h00000000
`define ZeroReg    5'b00000

`define InstLen     32
`define AddrLen     32
`define RegAddrLen  5 
`define RegLen      32
`define RegNum      32

`define ResetEnable   1'b1
`define ResetDisable  1'b0
`define ChipEnable    1'b1
`define ChipDisable   1'b0
`define WriteEnable   1'b1
`define WriteDisable  1'b0
`define ReadEnable    1'b1
`define ReadDisable   1'b0
`define ImmUsed       1'b1
`define ImmNotUsed    1'b0
`define BranchEnable  1'b1
`define BranchDisable 1'b0
`define JumpEnable    1'b1
`define JumpDisable   1'b0

`define RAM_SIZE      100
`define RAM_SIZELOG2  17

//B inst    B-type
`define op_B        7'b1100011
`define op_BEQ      3'b000
`define op_BNE      3'b001
`define op_BLT      3'b100
`define op_BGE      3'b101
`define op_BLTU     3'b110
`define op_BGEU     3'b111

//L inst    I-type
`define op_L        7'b0000011
`define op_LB       3'b000
`define op_LH       3'b001
`define op_LW       3'b010
`define op_LBU      3'b100
`define op_LHU      3'b101

//S inst    S-type
`define op_S        7'b0100011
`define op_SB       3'b000
`define op_SH       3'b001
`define op_SW       3'b010

//I inst    I-type
`define op_I        7'b0010011
`define op_ADDI     3'b000
`define op_SLTI     3'b010
`define op_SLTIU    3'b011
`define op_XORI     3'b100
`define op_ORI      3'b110
`define op_ANDI     3'b111
`define op_SLLI     3'b001
`define op_SRI      3'b101
`define op_SRLI     7'b0000000
`define op_SRAI     7'b0100000

//U J JALR type
`define op_LUI      7'b0110111  //U-type
`define op_AUIPC    7'b0010111  //U-type
`define op_JAL      7'b1101111  //J-type
`define op_JALR     7'b1100111  //I-type

//R inst    R-type
`define op_R        7'b0110011
`define op_ADDorSUB 3'b000
`define op_ADD      7'b0000000
`define op_SUB      7'b0100000
`define op_SLL      3'b001
`define op_SLT      3'b010
`define op_SLTU     3'b011
`define op_XOR      3'b100
`define op_SR       3'b101
`define op_SRL      7'b0000000
`define op_SRA      7'b0100000
`define op_OR       3'b110
`define op_AND      3'b111

//Alu_op
`define ALU_Len 5
`define NoAlu   0
`define JUMP    1
`define BRANCH  2
`define ADDI    3
`define SLTI    4
`define SLTIU   5
`define XORI    6
`define ORI     7
`define ANDI    8
`define SLLI    9
`define SRLI    10
`define SRAI    11
`define LB      12
`define LH      13
`define LW      14
`define LBU     15
`define LHU     16
`define ADD     17
`define SUB     18
`define SLL     19
`define SLT     20
`define XOR     21
`define SRL     22
`define SRA     23
`define OR      24
`define AND     25
`define SB      26
`define SH      27
`define SW      28
`define LUI     29
`define AUIPC   30

//jump inst
`define Jump_Len 2
`define NoJump   0
`define JALR     1
`define JAL      2

//branch unst
`define Branch_Len 3
`define NoBranch   0
`define BEQ        1
`define BNE        2
`define BLT        3
`define BGE        4
`define BLTU       5
`define BGEU       6

//
`define funct3Len  3
`define funct3Zero 0'b000
`define funct7Len  7
`define funct7Zero 0'b0000000

//
`define memwType     2
`define No_mem_write 0
`define sb           1
`define sh           2
`define sw           3

//about i-cache
`define i_cache_line 128 
`define TagLen 22   //index: 8, byte select: 2
