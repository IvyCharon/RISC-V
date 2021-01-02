`timescale 1ns / 1ps
`include "config.vh"

module id(
    input wire rst,

    //from if_id.v
    input wire [`AddrLen - 1 : 0] pc,
    input wire [`InstLen - 1 : 0] inst,

    //from ex.v
    //to handle forwarding from ex
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire ex_rd_write,
    input wire [`RegLen - 1 : 0] ex_rd_data,

    //from ex.v
    //to judge last instr
    input wire [`ALU_Len - 1 : 0] ex_alu_op,

    //from mem.v
    //to handle forwarding from mem
    input wire [`RegAddrLen - 1 : 0] mem_rd_addr,
    input wire mem_rd_write,
    input wire [`RegLen - 1 : 0] mem_rd_data,

    //from register.v
    input wire [`RegLen - 1 : 0]  reg1_data_i,
    input wire [`RegLen - 1 : 0]  reg2_data_i,

    //to register.v
    output reg [`RegAddrLen - 1 : 0] reg1_addr_o,
    output reg                       reg1_read_enable,
    output reg [`RegAddrLen - 1 : 0] reg2_addr_o,
    output reg                       reg2_read_enable,

    //to id_ex.v
    output reg [`RegLen - 1 : 0] reg1,
    output reg [`RegLen - 1 : 0] reg2,
    output reg [`RegLen - 1 : 0] Imm,
    output reg [`RegAddrLen - 1 : 0] rd,
    output reg rd_enable,
    output reg [`ALU_Len - 1 : 0]    alu_op,
    output reg [`Jump_Len - 1 : 0]   jump_op,
    output reg [`Branch_Len - 1 : 0] branch_op,
    output reg [`AddrLen - 1 : 0]    jump_addr1,

    //to ctrl.v
    output wire stallreq
    );

    wire [`OpLen - 1 : 0] opcode = inst[`OpLen - 1 : 0];
    reg useImmInstead;
    
    //Decode: Get opcode, imm, rd, and the addr of rs1&rs2
    always @ (*) begin
        if (rst == `ResetEnable) begin
            reg1_addr_o <= `ZeroReg;
            reg2_addr_o <= `ZeroReg;
        end
        else begin
            reg1_addr_o <= inst[19 : 15];
            reg2_addr_o <= inst[24 : 20];
        end
    end

    reg [`funct3Len - 1 : 0] funct3;
    reg [`funct7Len - 1 : 0] funct7; 

    reg pre_inst;

    always @(*) begin
        pre_inst         <= (ex_alu_op == `LW || ex_alu_op == `LB || ex_alu_op == `LH || ex_alu_op == `LBU || ex_alu_op == `LHU) ? 1 : 0;
        reg1_read_enable <= `ReadDisable;
        reg2_read_enable <= `ReadDisable;

        Imm       <= `ZERO_WORD;
        rd        <= `ZeroReg;
        rd_enable <= `WriteDisable;

        alu_op    <= `NoAlu;
        jump_op   <= `NoJump;
        branch_op <= `NoBranch;

        case (opcode)
            `op_I: begin                //I-type
                rd               <= inst[11 : 7];
                rd_enable        <= `WriteEnable;
                reg1_read_enable <= `ReadEnable;
                reg2_read_enable <= `ReadDisable;
                Imm              <= { {20{inst[31]}} ,inst[31:20] };
                useImmInstead    <= `ImmUsed;

                funct3 <= inst[14:12];
                funct7 <= inst[31:25];

                jump_op   <= `NoJump;
                branch_op <= `NoBranch;

                case (funct3)
                    `op_ADDI:  alu_op <= `ADDI;
                    `op_SLTI:  alu_op <= `SLTI;
                    `op_SLTIU: alu_op <= `SLTIU;
                    `op_XORI:  alu_op <= `XORI;
                    `op_ORI:   alu_op <= `ORI;
                    `op_ANDI:  alu_op <= `ANDI;
                    `op_SLLI:  alu_op <= `SLLI;
                    `op_SRI: begin
                        case (funct7)
                            `op_SRLI: alu_op <= `SRLI;
                            `op_SRAI: alu_op <= `SRAI;
                            default:  alu_op <= `NoAlu;
                        endcase
                    end
                    default: alu_op <= `NoAlu;
                endcase

            end
            `op_L: begin                //I-type
                rd               <= inst[11 : 7];
                rd_enable        <= `WriteEnable;
                reg1_read_enable <= `ReadEnable;
                reg2_read_enable <= `ReadDisable;
                Imm              <= { {20{inst[31]}} ,inst[31:20] };
                useImmInstead    <= `ImmUsed;

                funct3 <= inst[14:12];
                funct7 <= inst[31:25];

                jump_op   <= `NoJump;
                branch_op <= `NoBranch;

                case (funct3)
                    `op_LH:  alu_op <= `LH;
                    `op_LW:  alu_op <= `LW;
                    `op_LB:  alu_op <= `LB;
                    `op_LBU: alu_op <= `LBU;
                    `op_LHU: alu_op <= `LHU; 
                    default: alu_op <= `NoAlu;
                endcase
                
            end
            `op_JALR: begin             //I-type
                rd               <= inst[11 : 7];
                rd_enable        <= `WriteEnable;
                reg1_read_enable <= `ReadEnable;
                reg2_read_enable <= `ReadDisable;
                Imm              <= { {20{1'b0}} ,inst[31:20] };
                useImmInstead    <= `ImmUsed;

                funct3 <= inst[14:12];
                funct7 <= inst[31:25];

                alu_op <= `JUMP;

                jump_op   <= `JALR;
                branch_op <= `NoBranch;
                
            end
            `op_R: begin                //R-type
                rd               <= inst[11:7];
                rd_enable        <= `WriteEnable;
                reg1_read_enable <= `ReadEnable;
                reg2_read_enable <= `ReadEnable;
                Imm              <= `ZERO_WORD;
                useImmInstead    <= `ImmNotUsed;

                funct3 <= inst[14:12];
                funct7 <= inst[31:25];

                jump_op   <= `NoJump;
                branch_op <= `NoBranch;

                case (funct3)
                    `op_ADDorSUB: begin
                        case (funct7)
                            `op_ADD: alu_op <= `ADD;
                            `op_SUB: alu_op <= `SUB; 
                            default: alu_op <= `NoAlu;
                        endcase
                    end 
                    `op_SLL:  alu_op <= `SLL;
                    `op_SLT:  alu_op <= `SLT;
                    `op_SLTU: alu_op <= `SLTU;
                    `op_XOR:  alu_op <= `XOR;
                    `op_SR: begin
                        case (funct7)
                            `op_SRL: alu_op <= `SRL;
                            `op_SRA: alu_op <= `SRA; 
                            default: alu_op <= `NoAlu;
                        endcase
                    end
                    `op_OR:  alu_op <= `OR;
                    `op_AND: alu_op <= `AND;
                    default: alu_op <= `NoAlu;
                endcase

            end
            `op_B: begin                //B-type
                rd_enable        <= `WriteDisable;
                rd               <= `ZeroReg;
                reg1_read_enable <= `ReadEnable;
                reg2_read_enable <= `ReadEnable;
                Imm              <= { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
                useImmInstead    <= `ImmUsed;

                funct3 <= inst[14:12];
                funct7 <= `funct7Zero;

                alu_op <= `BRANCH;

                case (funct3)
                    `op_BEQ:  branch_op <= `BEQ;
                    `op_BNE:  branch_op <= `BNE;
                    `op_BLT:  branch_op <= `BLT;
                    `op_BGE:  branch_op <= `BGE;
                    `op_BLTU: branch_op <= `BLTU;
                    `op_BGEU: branch_op <= `BGEU;
                    default: begin
                        branch_op <= `NoBranch;
                    end
                endcase
                
            end
            `op_S: begin                //S-type
                rd_enable        <= `WriteDisable;
                rd               <= `ZeroReg;
                reg1_read_enable <= `ReadEnable;
                reg2_read_enable <= `ReadEnable;
                Imm              <= { {20{inst[31]}}, inst[31:25], inst[11:8], inst[7] };
                useImmInstead    <= `ImmUsed;

                funct3 <= inst[14:12];
                funct7 <= `funct7Zero;

                jump_op          <= `NoJump;
                branch_op        <= `NoBranch;

                case (funct3)
                    `op_SB:  alu_op <= `SB;
                    `op_SW:  alu_op <= `SW;
                    `op_SH:  alu_op <= `SH; 
                    default: alu_op <= `NoAlu;
                endcase
                
            end
            `op_LUI: begin              //U-type
                rd_enable        <= `WriteEnable;
                rd               <= inst[11 : 7];
                reg1_read_enable <= `ReadDisable;
                reg2_read_enable <= `ReadDisable;
                Imm              <= { inst[31:12], {12{1'b0}}};
                useImmInstead    <= `ImmUsed;

                alu_op <= `LUI;

                jump_op   <= `NoJump;
                branch_op <= `NoBranch;

                funct3 <= `funct3Zero;
                funct7 <= `funct7Zero;
                
            end
            `op_AUIPC: begin            //U-type
                rd_enable        <= `WriteEnable;
                rd               <= inst[11 : 7];
                reg1_read_enable <= `ReadDisable;
                reg2_read_enable <= `ReadDisable;
                Imm              <= { inst[31:12], {12{1'b0}}};
                useImmInstead    <= `ImmUsed;

                alu_op <= `AUIPC;

                funct3 <= `funct3Zero;
                funct7 <= `funct7Zero;

                jump_op   <= `NoJump;
                branch_op <= `NoBranch;
                
            end
            `op_JAL: begin              //J-type
                rd_enable        <= `WriteEnable;
                rd               <= inst[11:7];
                reg1_read_enable <= `ReadDisable;
                reg2_read_enable <= `ReadDisable;
                Imm              <= { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
                useImmInstead    <= `ImmUsed;

                alu_op <= `JUMP;

                jump_op   <= `JAL;
                branch_op <= `NoBranch;

                funct3 <= `funct3Zero;
                funct7 <= `funct7Zero;
                
            end
            default: begin
                Imm              <= `ZERO_WORD;
                rd_enable        <= `WriteDisable;
                reg1_read_enable <= `ReadDisable;
                reg2_read_enable <= `ReadDisable;
                rd               <= `ZeroReg;
                funct3           <= `funct3Zero;
                funct7           <= `funct7Zero;

                jump_op   <= `NoJump;
                branch_op <= `NoBranch;
                alu_op    <= `NoAlu;
        
                useImmInstead <= `ImmNotUsed;
            end
        endcase
    end

    reg stallreq1;
    reg stallreq2;

    //Get rs1
    always @ (*) begin
        stallreq1 <= 1'b0;
        if (rst == `ResetEnable) begin
            reg1 <= `ZERO_WORD;
        end
        else if(pre_inst && ex_rd_addr == reg1_addr_o && ex_rd_write) begin
            stallreq1 <= 1'b1;
        end
        else if(alu_op == `AUIPC || (alu_op == `JUMP && jump_op == `JAL)) begin
            if(alu_op == `JUMP && jump_op == `JAL) begin
                jump_addr1 <= pc;
            end
            reg1 <= pc;
        end
        else if(reg1_read_enable == `ReadEnable && reg1_addr_o == ex_rd_addr && ex_rd_write == `WriteEnable && reg1_addr_o != `ZeroReg) begin
            if(alu_op == `JUMP && jump_op == `JALR) begin
                jump_addr1 <= ex_rd_data;
                reg1 <= pc;
            end 
            else if(alu_op == `BRANCH) begin
                jump_addr1 <= pc;
                reg1 <= ex_rd_data;
            end
            else begin
                reg1 <= ex_rd_data;
            end
        end
        else if(reg1_read_enable == `ReadEnable && reg1_addr_o == mem_rd_addr && mem_rd_write == `WriteEnable && reg1_addr_o != `ZeroReg) begin
            if(alu_op == `JUMP && jump_op == `JALR) begin
                jump_addr1 <= mem_rd_data;
                reg1 <= pc;
            end 
            else if(alu_op == `BRANCH) begin
                jump_addr1 <= pc;
                reg1 <= mem_rd_data;
            end
            else begin
               reg1 <= mem_rd_data; 
            end
        end
        else if (reg1_read_enable == `ReadDisable) begin
            if(alu_op == `BRANCH) begin
                jump_addr1 <= pc;
            end
            reg1 <= `ZERO_WORD;
        end
        else begin
            if(alu_op == `JUMP && jump_op == `JALR) begin
                jump_addr1 <= reg1_data_i;
                reg1 <= pc;
            end
            else if(alu_op == `BRANCH) begin
                jump_addr1 <= pc;
                reg1 <= reg1_data_i; 
            end
            else begin
               reg1 <= reg1_data_i; 
            end
        end
    end

    //Get rs2
    always @ (*) begin
        stallreq2 <= 1'b0;
        if (rst == `ResetEnable) begin
            reg2 <= `ZERO_WORD;
        end
        else if(pre_inst && ex_rd_addr == reg2_addr_o && ex_rd_write) begin
            stallreq2 <= 1'b1;
        end
        else if(reg2_read_enable == `ReadEnable && reg2_addr_o == ex_rd_addr && ex_rd_write == `WriteEnable && reg2_addr_o != `ZeroReg) begin
            reg2 <= ex_rd_data;
        end
        else if(reg2_read_enable == `ReadEnable && reg2_addr_o == mem_rd_addr && mem_rd_write == `WriteEnable && reg2_addr_o != `ZeroReg) begin
            reg2 <= mem_rd_data;
        end
        else if (reg2_read_enable == `ReadDisable) begin
            if (useImmInstead == `ImmNotUsed) reg2 <= `ZERO_WORD;
            else reg2 <= Imm;
        end
        else begin
            reg2 <= reg2_data_i;
        end
    end

    assign stallreq = stallreq1 | stallreq2;

endmodule
