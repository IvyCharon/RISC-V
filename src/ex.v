`timescale 1ns / 1ps

module ex(
    input wire rst,

    input wire [`RegLen - 1 : 0] reg1,
    input wire [`RegLen - 1 : 0] reg2,
    input wire [`RegLen - 1 : 0] Imm,
    input wire [`RegLen - 1 : 0] rd,
    input wire rd_enable,

    input reg [`ALU_Len - 1 : 0]    alu_op,
    input reg [`Jump_Len - 1 : 0]   jump_op,
    input reg [`Branch_Len - 1 : 0] branch_op

    output reg [`RegLen - 1 : 0]     rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr,
    output reg rd_enable_o
    );

    reg [`RegLen - 1 : 0] res;

    //Do the calculation
    always @ (*) begin
        if (rst == `ResetEnable) begin
            res = `ZERO_WORD;
        end
        else begin
            case (alu_op)
                `ADDI:  res = reg1 + Imm; 
                `SLTI:  res = $signed(reg1) < $signed(Imm) ? 32'b1 : 32'b0;
                `SLTIU: res = reg1 < Imm ? 32'b1 : 32'b0;
                `XORI:  res = reg1 ^ Imm;
                `ORI:   res = reg1 | Imm;
                `ANDI:  res = reg1 & Imm;
                `SLLI:  res = reg1 << reg2[4:0];
                `SRLI:  res = reg1 >> reg2[4:0];
                `SRAI:  res = $signed(reg1) >> reg2[4:0];

                `ADD:   res = reg1 + reg2;
                `SUB:   res = reg1 - reg2;
                `SLL:   res = reg1 << reg2[4:0];
                `SLT:   res = $signed(reg1) < $signed(reg2) ? 1 : 0;
                `XOR:   res = reg1 ^ reg2;
                `OR:    res = reg1 | reg2;
                `AND:   res = reg1 & reg2;
                `SRL:   res = reg1 >> reg2[4:0];
                `SRA:   res = $signed(reg1) >> reg2[4:0];

                `LB: 
                `LH:
                `LW:
                `LBU:
                `LHU:

                `SB:
                `SH:
                `SW:

                `LUI:   res = Imm;
                `AUIPC: //pc+Imm
                //where to find pc? stored in reg1?

                `JUMP:
                `BRANCH:

                default:
                    res = `ZERO_WORD;
            endcase
        end
    end

    //Determine the output
    always @ (*) begin
        if (rst == `ResetEnable) begin
            rd_enable_o = `WriteDisable;
        end
        else begin 
            rd_addr = rd;
            rd_enable_o = rd_enable;
            case (alu_op)
                `BRANCH: rd_data_o = `ZERO_WORD;
                `SB:     rd_data_o = `ZERO_WORD;
                `SH:     rd_data_o = `ZERO_WORD;
                `SW:     rd_data_o = `ZERO_WORD;
                default: rd_data_o = res;
            endcase
        end
    end
endmodule
