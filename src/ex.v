`timescale 1ns / 1ps
`include "config.vh"

module ex(
    input wire rst,

    //from id_ex.v
    input wire [`RegLen - 1 : 0] reg1,
    input wire [`RegLen - 1 : 0] reg2,
    input wire [`RegLen - 1 : 0] Imm,
    input wire [`RegAddrLen - 1 : 0] rd,
    input wire rd_enable,
    input wire [`ALU_Len - 1 : 0]    alu_op,
    input wire [`Jump_Len - 1 : 0]   jump_op,
    input wire [`Branch_Len - 1 : 0] branch_op,
    input wire [`AddrLen - 1 : 0]    jump_addr1,

    //to ex_mem.v
    output reg [`AddrLen - 1 : 0]  mem_addr_o,
    output reg [`InstLen - 1 : 0]  mem_wdata_o,
    //also to id.v for forwarding
    output reg [`RegLen - 1 : 0]     rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr,
    output reg rd_enable_o,
    output reg [`ALU_Len - 1 : 0]  alu_op_o,

    output reg ifid_clear,
    output reg idex_clear,

    //to pc_reg.v
    output reg jump_flag,
    output reg [`AddrLen - 1 : 0] jump_addr
    
    );

    reg [`RegLen - 1 : 0] res;

    //Do the calculation
    always @ (*) begin
        alu_op_o    <= alu_op;
        mem_wdata_o <= reg2;
        if (rst == `ResetEnable) begin
            res <= `ZERO_WORD;
            alu_op_o <= `NoAlu;
            mem_wdata_o <= `ZERO_WORD;
        end
        else begin
            jump_flag <= 1'b0;
            jump_addr <= `ZERO_WORD;
            case (alu_op)
                `LUI         : res <= reg2;
                `AUIPC       : res <= reg1 + reg2;
                `ADD,`ADDI   : res <= reg1 + reg2;
                `SUB         : res <= reg1 - reg2;
                `SLL,`SLLI   : res <= reg1 << reg2[4:0];
                `SLT,`SLTI   : res <= $signed(reg1) < $signed(reg2) ? 32'b1 : 32'b0;
                `XOR,`XORI   : res <= reg1 ^ reg2;
                `OR,`ORI     : res <= reg1 | reg2;
                `AND,`ANDI   : res <= reg1 & reg2;
                `SRL,`SRLI   : res <= reg1 >> reg2[4:0];
                `SRA,`SRAI   : res <= $signed(reg1) >> reg2[4:0];
                `SLTU,`SLTIU : res <= reg1 < reg2 ? 1 : 0;
                
                //具体取位数操作在MEM进行
                `LB          : res <= reg1 + reg2;
                `LH          : res <= reg1 + reg2;
                `LW          : res <= reg1 + reg2;
                `LBU         : res <= reg1 + reg2;
                `LHU         : res <= reg1 + reg2;

                `SB          : res <= reg1 + Imm;
                `SH          : res <= reg1 + Imm;
                `SW          : res <= reg1 + Imm;

                `JUMP        : begin
                    case (jump_op)
                        `JAL  : begin
                            res <= reg1 + 4;
                            jump_flag <= 1'b1;
                            jump_addr <= jump_addr1 + Imm;
                        end
                        `JALR :  begin
                            res <= reg1 + 4;
                            jump_flag <= 1'b1;
                            jump_addr <= jump_addr1 + Imm;
                        end
                        default: begin
                            res <= `ZERO_WORD;
                            jump_flag <= 1'b0;
                            jump_addr <= `ZERO_WORD;
                        end
                    endcase
                end

                `BRANCH      : begin
                    case (branch_op)
                        `BEQ  : begin
                            jump_flag <= (reg1 == reg2) ? `JumpEnable : `JumpDisable;
                            jump_addr <= (reg1 == reg2) ? jump_addr1 + Imm : `ZERO_WORD;
                        end
                        `BNE  : begin
                            jump_flag <= (reg1 != reg2) ? `JumpEnable : `JumpDisable;
                            jump_addr <= (reg1 != reg2) ? jump_addr1 + Imm : `ZERO_WORD;
                        end
                        `BLT  : begin
                            jump_flag <= ($signed(reg1) < $signed(reg2)) ? `JumpEnable : `JumpDisable;
                            jump_addr <= ($signed(reg1) < $signed(reg2)) ? jump_addr1 + Imm : `ZERO_WORD;
                        end
                        `BGE  : begin
                            jump_flag <= ($signed(reg1) >= $signed(reg2)) ? `JumpEnable : `JumpDisable;
                            jump_addr <= ($signed(reg1) >= $signed(reg2)) ? jump_addr1 + Imm : `ZERO_WORD;
                        end
                        `BLTU : begin
                            jump_flag <= (reg1 < reg2) ? `JumpEnable : `JumpDisable;
                            jump_addr <= (reg1 < reg2) ? jump_addr1 + Imm : `ZERO_WORD;
                        end
                        `BGEU : begin
                            jump_flag <= (reg1 >= reg2) ? `JumpEnable : `JumpDisable;
                            jump_addr <= (reg1 >= reg2) ? jump_addr1 + Imm : `ZERO_WORD;
                        end
                        default: begin
                            jump_flag <= 1'b0;
                            jump_addr <= `ZERO_WORD;
                        end
                    endcase
                end

                default:
                    res <= `ZERO_WORD;
            endcase
        end
    end

    //Determine the output
    always @ (*) begin
        if (rst == `ResetEnable) begin
            rd_enable_o <= `WriteDisable;
            rd_addr     <= `ZERO_WORD;
            rd_data_o   <= `ZERO_WORD;
            mem_addr_o  <= `ZERO_WORD;
        end
        else begin 
            rd_addr <= rd;
            rd_enable_o <= rd_enable;
            case (alu_op)
                `BRANCH: begin
                    rd_data_o  <= `ZERO_WORD;
                    mem_addr_o <= `ZERO_WORD;
                end
                `LB,`LH,`LW,`LBU,`LHU,`SB,`SH,`SW: begin
                    mem_addr_o <= res;
                    rd_data_o  <= `ZERO_WORD;
                end
                default: begin
                    rd_data_o  <= res;
                    mem_addr_o <= `ZERO_WORD;
                end
            endcase
        end
    end

    always @ (*) begin
        if(jump_flag) begin
            ifid_clear = 1'b1;
            idex_clear = 1'b1;
        end
        else begin
            ifid_clear = 1'b0;
            idex_clear = 1'b0;
        end
    end
endmodule
