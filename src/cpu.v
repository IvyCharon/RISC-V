// RISCV32I CPU top module
// port modification allowed for debugging purposes
/*
// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end

endmodule

*/
`include "config.vh"

module cpu(
	input  wire                    clk_in,			// system clock signal
    input  wire                    rst_in,			// reset signal
	input  wire                    rdy_in,			//ready signal, pause cpu when low

    input  wire [`RegLen - 1 : 0]  rom_data_i,

    output wire [`InstLen - 1 : 0] rom_addr_o,
    output wire 				   rom_ce_o,

	input wire [`InstLen - 1 : 0]  ram_data_i,

	output wire [`InstLen - 1 : 0]  ram_wdata_o,
    output wire [`AddrLen - 1 : 0]  ram_waddr_o,
    output wire [`memwType - 1 : 0] ram_write_type,
    output wire ram_write,
    output wire ram_read
    );

	assign rom_addr_o = pc;

	//pc_reg -> if_id
	wire [`AddrLen - 1 : 0]  pc;
    wire [`StallLen - 1 : 0] stall_flag_pc_ifd;

	//id -> id_ex
	wire [`RegLen - 1 : 0]	   id_reg1_o;
    wire [`RegLen - 1 : 0]	   id_reg2_o;
    wire [`RegLen - 1 : 0]     id_Imm_o;
    wire [`RegLen - 1 : 0] 	   id_rd_o;
    wire 					   id_rd_enable_o;
    wire [`ALU_Len - 1 : 0]    id_alu_op_o;
    wire [`Jump_Len - 1 : 0]   id_jump_op_o;
    wire [`Branch_Len - 1 : 0] id_branch_op_o;
    wire [`AddrLen - 1 ：0]    id_addr_for_rd_o;
    wire [`StallLen - 1 : 0]   id_stall_flag_o;

	//id -> pc_reg
	wire 					 pc_jump_flag;
    wire [`AddrLen - 1 : 0]  pc_jump_addr;
    wire [`StallLen - 1 : 0] stall_flag_to_pc;

	//if_id -> id
	wire [`AddrLen - 1 : 0]  id_pc_i;
    wire [`InstLen - 1 : 0]  id_inst_i;
    wire [`StallLen - 1 : 0] id_stall_flag_i;

	//ex_id -> ex
	wire [`RegLen - 1 : 0] ex_reg1;
    wire [`RegLen - 1 : 0] ex_reg2;
    wire [`RegLen - 1 : 0] ex_Imm;
    wire [`RegLen - 1 : 0] ex_rd;
    wire ex_rd_enable;
    wire [`ALU_Len - 1 : 0]    ex_alu_op;
    wire [`Jump_Len - 1 : 0]   ex_jump_op;
    wire [`Branch_Len - 1 : 0] ex_branch_op;
    wire [`AddrLen - 1 ：0]    ex_addr_for_rd;
    wire [`StallLen - 1 : 0]   ex_stall_flag;

	//ex -> ex_mem
	wire [`RegLen - 1 : 0]     ex_rd_data_i;
    wire [`RegAddrLen - 1 : 0] ex_rd_addr_i;
    wire ex_rd_enable_i;
    wire [`AddrLen - 1 : 0]  ex_mem_addr_i;
    wire [`ALU_Len - 1 : 0]  ex_alu_op_i;
    wire [`InstLen - 1 : 0]  ex_mem_wdata_i;
    wire [`StallLen - 1 : 0] ex_stall_flag_i;

	//ex_mem -> mem
	wire [`RegLen - 1 : 0]     mem_rd_data_i;
    wire [`RegAddrLen - 1 : 0] mem_rd_addr_i;
    wire [`AddrLen - 1 : 0]    mem_mem_addr_i;
    wire [`ALU_Len - 1 : 0]    mem_alu_op_i;
    wire [`InstLen - 1 : 0]    mem_mem_wdata_i;
    wire mem_rd_enable_i;
    wire [`StallLen - 1 : 0]   mem_stall_flag_i;

	//mem -> mem_wb
	wire [`RegLen - 1 : 0]     mem_rd_data_o;
    wire [`RegAddrLen - 1 : 0] mem_rd_addr_o;
    wire mem_rd_enable_o;
    wire [`StallLen - 1 : 0]   mem_stall_flag_o;

	//mem_wb -> register
	wire [`RegLen - 1 : 0]     wb_rd_data_i;
    wire [`RegAddrLen - 1 : 0] wb_rd_addr_i;
    wire wb_rd_enable_i;
    wire [`StallLen - 1 : 0]   wb_stall_flag_i;

	//register -> pc_reg
	wire [`StallLen - 1 : 0]   reg_stall_flag_o;

	//id -> register
	wire [`RegAddrLen - 1 : 0] reg1_addr_o,
    wire [`RegLen - 1 : 0]     reg1_read_enable,
    wire [`RegAddrLen - 1 : 0] reg2_addr_o,
    wire [`RegLen - 1 : 0]     reg2_read_enable,

	//register -> id
	wire [`RegLen - 1 : 0]  reg1_data_i,
    wire [`RegLen - 1 : 0]  reg2_data_i,

	//Instantiation
	pc_reg pc_reg0(
    	.clk(clk_in),
		.rst(rst_in),

    	//from id.v
    	.JumpFlag(pc_jump_flag),
    	.jump_addr(pc_jump_addr),
    	.stall_flag_id(stall_flag_to_pc),

    	//from register.v/write part
    	.stall_flag_wb(reg_stall_flag_o),
    
    	//to if_id.v
    	.pc(pc),
    	.stall_flag_o(stall_flag_pc_ifd),

    	//to what?
    	.reg chip_enable(rom_ce_o)
    );

	if_id if_id0(
    	.clk(clk_in), 
    	.rst(rst_in),

    	//from pc_reg.v
    	.if_pc(pc),
    	.if_inst(rom_data_i),
    	.stall_flag(stall_flag_pc_ifd),

    	//to id.v
    	.id_pc(id_pc_i),
    	.id_inst(id_inst_i),
    	.stall_flag_o(id_stall_flag_i)
    );

	id id0(
    	.rst(rst_in),

    	//from if_id.v
    	.pc(id_pc_i),
    	.inst(id_inst_i),
    	.stall_flag_i(id_stall_flag_i),

    	//from register.v
    	.reg1_data_i(reg1_data_i),
    	.reg2_data_i(reg2_data_i),

    	//to register.v
    	.reg1_addr_o(reg1_addr_o),
    	.reg1_read_enable(reg1_read_enable),
    	.reg2_addr_o(reg2_addr_o),
    	.reg2_read_enable(reg2_read_enable),

    	//to id_ex.v
    	.reg1(id_reg1_o),
    	.reg2(id_reg2_o),
    	.Imm(id_Imm_o),
    	.rd(id_rd_o),
    	.rd_enable(id_rd_enable_o),
    	.alu_op(id_alu_op_o),
    	.jump_op(id_jump_op_o),
    	.branch_op(id_branch_op_o),
    	.addr_for_rd(id_addr_for_rd_o),
    	.stall_flag_o(id_stall_flag_o),

    	//to pc_reg.v
    	.jump_flag(pc_jump_flag),
    	.jump_addr(pc_jump_addr),
    	.stall_flag_to_pc(stall_flag_to_pc)
    );
    
	register register0(
    	.clk(clk_in),
    	.rst(rst_in),

    	//write, form mem_wb.v
    	.write_enable(wb_rd_enable_i),
    	.write_addr(wb_rd_addr_i),
    	.write_data(wb_rd_data_i),
    	.stall_flag(wb_stall_flag_i),

    	//to pc_reg.v
    	.stall_flag_o(reg_stall_flag_o),

    	//read 1, from id.v
    	.read_enable1(reg1_read_enable),   
    	.read_addr1(reg1_addr_o),
    	//to id.v
    	.read_data1(reg1_data_i),

    	//read 2, from id.v
    	.read_enable2(reg2_read_enable),   
    	.read_addr2(reg2_addr_o),
    	//to id.v
    	.read_data2(reg2_data_i)
    );

	id_ex id_ex0(
    	.clk(clk_in),
    	.rst(rst_in),

    	//from id.v
    	.id_reg1(id_reg1_o),
    	.id_reg2(id_reg2_o),
    	.id_Imm(id_Imm_o),
    	.id_rd(id_rd_o),
    	.id_rd_enable(id_rd_enable_o),
    	.id_alu_op(id_alu_op_o),
    	.id_jump_op(id_jump_op_o),
    	.id_branch_op(id_branch_op_o),
    	.id_addr_for_rd(id_addr_for_rd_o),
    	.id_stall_flag(id_stall_flag_o),

    	//to ex.v
    	.ex_reg1(ex_reg1),
    	.ex_reg2(ex_reg2),
    	.ex_Imm(ex_Imm),
    	.ex_rd(ex_rd),
    	.ex_rd_enable(ex_rd_enable),
    	.ex_alu_op(ex_alu_op),
    	.ex_jump_op(ex_jump_op),
    	.ex_branch_op(ex_branch_op),
    	.ex_addr_for_rd(ex_addr_for_rd),
    	.ex_stall_flag(ex_stall_flag)
    );

	ex ex0(
    	.rst(rst_in),

    	//from id_ex.v
    	.reg1(ex_reg1),
    	.reg2(ex_reg2),
    	.Imm(ex_Imm),
    	.rd(ex_rd),
    	.rd_enable(ex_rd_enable),
    	.alu_op(ex_alu_op),
    	.jump_op(ex_jump_op),
    	.branch_op(ex_branch_op),
    	.addr_for_rd(ex_addr_for_rd),
    	.stall_flag(ex_stall_flag),

    	//to ex_mem.v
    	.rd_data_o(ex_rd_data_i),
    	.rd_addr(ex_rd_addr_i),
    	.rd_enable_o(ex_rd_enable_i),
    	.mem_addr_o(ex_mem_addr_i),
    	.alu_op_o(ex_alu_op_i),
    	.mem_wdata_o(ex_mem_wdata_i),
    	.stall_flag_o(ex_stall_flag_i)

    );

	ex_mem ex_mem0(
    	.clk(clk_in),
    	.rst(rst_in),

    	//from ex.v
    	.ex_rd_data(ex_rd_data_i),
    	.ex_rd_addr(ex_rd_addr_i),
    	.ex_rd_enable(ex_rd_enable_i),
    	.ex_mem_addr(ex_mem_addr_i),
    	.ex_alu_op(ex_alu_op_i),
    	.ex_mem_wdata(ex_mem_wdata_i),
    	.ex_stall_flag(ex_stall_flag_i),

    	//to mem.v
    	.mem_rd_data(mem_rd_data_i),
    	.mem_rd_addr(mem_rd_addr_i),
    	.mem_mem_addr(mem_mem_addr_i),
    	.mem_alu_op(mem_alu_op_i),
    	.mem_mem_wdata(mem_mem_wdata_i),
    	.mem_rd_enable(mem_rd_enable_i),
    	.mem_stall_flag(mem_stall_flag_i)
    );
              
	mem mem0(
    	.rst(rst_in),

    	//from ex_mem.v
    	.rd_data_i(mem_rd_data_i),
    	.rd_addr_i(mem_rd_addr_i),
    	.mem_addr_i(mem_mem_addr_i),
    	.mem_wdata_i(mem_mem_wdata_i),
    	.alu_op(mem_alu_op_i),
    	.rd_enable_i(mem_rd_enable_i),
    	.stall_flag(mem_stall_flag_i),

    	//from memory
    	.mem_data(ram_data_i),
    
    	//to mem_wb.v
    	.rd_data_o(mem_rd_data_o),
    	.rd_addr_o(mem_rd_addr_o),
    	.rd_enable_o(mem_rd_enable_o),
    	.stall_flag_o(mem_stall_flag_o),

    	//to memory
    	.mem_wdata_o(mem_wdata_o),
    	.mem_waddr_o(mem_waddr_o),
    	.mem_write_type(mem_write_type),
    	.mem_write(mem_write),
    	.mem_read(mem_read)
    );
        
	mem_wb mem_wb0(
    	.clk(clk_in),
    	.rst(rst_in),

    	//from mem.v
    	.mem_rd_data(mem_rd_data_o),
    	.mem_rd_addr(mem_addr_o),
    	.mem_rd_enable(mem_rd_enable_o),
    	.mem_stall_flag(mem_stall_flag_o),

    	//to register.v
    	.wb_rd_data(wb_rd_data_i),
    	.wb_rd_addr(wb_rd_addr_i),
    	.wb_rd_enable(wb_rd_enable_i),
    	.wb_stall_flag(wb_stall_flag_i)
    );

endmodule