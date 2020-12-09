// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "config.vh"

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
    input  wire					rdy_in,			// ready signal, pause cpu when low

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

	wire rst = rst_in | (!rdy_in);

	wire stallreq_id, stallreq_for_jump, stallreq_if, stallreq_mem;
	wire [5:0] stall;

	//id -> pc_reg
	wire JumpFlag;
	wire [`AddrLen - 1 : 0] jump_addr;

	//pc -> if
	wire [`AddrLen - 1 : 0] pc;

	//if -> if_id
	wire [`AddrLen - 1 : 0] pc_iffd;
	wire [`InstLen - 1 : 0] inst_iffd;

	//if_id -> id
	wire [`AddrLen - 1 : 0] pc_ifdd;
	wire [`AddrLen - 1 : 0] inst_ifdd;

	//id -> pc_reg
	wire jump_flag_dp;
	wire [`AddrLen - 1 : 0] jump_addr_dp;

	//id -> id_ex
	wire [`RegLen - 1 : 0] reg1_de;
	wire [`RegLen - 1 : 0] reg2_de;
	wire [`RegLen - 1 : 0] imm_de;
	wire [`RegLen - 1 : 0] rd_de;
	wire rd_enable_de;
	wire [`ALU_Len - 1 : 0] alu_op_de;
	wire [`Jump_Len - 1 : 0] jump_op_de;
	wire [`Branch_Len - 1 : 0] branch_op_de;
	wire [`AddrLen - 1 : 0] jump_addr1_de;

	//id_ex -> ex
	wire [`RegLen - 1 : 0] reg1_dee;
	wire [`RegLen - 1 : 0] reg2_dee;
	wire [`RegLen - 1 : 0] imm_dee;
	wire [`RegLen - 1 : 0] rd_dee;
	wire rd_enable_dee;
	wire [`ALU_Len - 1 : 0] alu_op_dee;
	wire [`Jump_Len - 1 : 0] jump_op_dee;
	wire [`Branch_Len - 1 : 0] branch_op_dee;
	wire [`AddrLen - 1 : 0] jump_addr1_dee;

	//ex -> id/ex_mem
	wire [`RegAddrLen - 1 : 0] ex_rd_addr;
	wire ex_rd_write;
	wire [`RegLen - 1 : 0] ex_rd_data;
	wire [`ALU_Len - 1 : 0] ex_alu_op;

	//ex -> mem
	wire [`AddrLen - 1 : 0] mem_addr_eem;
	wire [`InstLen - 1 : 0] mem_wdata_eem;

	//ex_mem -> mem
	wire [`RegLen - 1 : 0] rd_data_emm;
	wire [`RegAddrLen - 1 : 0] rd_addr_emm;
	wire [`AddrLen - 1 : 0] mem_addr_emm;
	wire [`ALU_Len - 1 : 0] alu_op_emm;
	wire [`InstLen - 1 : 0] mem_wdata_emm;
	wire rd_enable_emm;

	//mem -> id/mem_wb
	wire [`RegAddrLen - 1 : 0] mem_rd_addr;
	wire mem_rd_write;
	wire [`RegLen - 1 : 0] mem_rd_data;

	//mem_wb -> register
	wire [`RegLen - 1 : 0] wb_rd_data;
	wire [`RegAddrLen - 1 : 0] wb_rd_addr;
	wire wb_rd_enable;

	//register -> id
	wire [`RegLen - 1 : 0] reg1_data;
	wire [`RegLen - 1 : 0] reg2_data;

	//id -> register
	wire [`RegAddrLen - 1 : 0] reg1_addr;
	wire reg1_read;
	wire [`RegAddrLen - 1 : 0] reg2_addr;
	wire reg2_read;

	//i_cache -> if
	wire inst_available_if;
	wire [`InstLen - 1 : 0] inst_if;

	//if -> i_cache
	wire [`AddrLen - 1 : 0] addr_if;

	//mem -> mem_ctrl
	wire [`InstLen - 1 : 0] wdata_m_mc;
	wire [`AddrLen - 1 : 0] addr_m_mc;
	wire [`memwType - 1 : 0] mem_type_m_mc;
	wire rw_m_mc;
	wire mem_enable_m_mc;

	//i_cache -> mem_ctrl
	wire inst_needed;
	wire [`AddrLen - 1 : 0] inst_addr_im;

	//mem_ctrl -> i_cache
	wire [`InstLen - 1 : 0] inst_mi;
	wire inst_enable_mi;
	wire mem_busy;

	//mem_ctrl -> mem
	wire [`InstLen - 1 : 0] data_mc_m;
	wire data_enable_mc_m;
	wire icache_busy;

	ctrl ctrl0 (
		.rst(rst),

		.stallreq_id(stallreq_id),
		.stallreq_for_jump(stallreq_for_jump),
		.stallreq_if(stallreq_if),
		.stallreq_mem(stallreq_mem),

		.stall(stall)
	);

	pc_reg pc_reg0 (
		.clk(clk_in),
		.rst(rst),

		.stall(stall),

		.JumpFlag(JumpFlag),
		.jump_addr(jump_addr),

		.pc(pc)
	);

	If if0 (
		.clk(clk_in),
		.rst(rst),

		.pc_i(pc),

		.pc_o(pc_iffd),
		.inst_o(inst_iffd),

		.inst_available(inst_available_if),
		.inst(inst_if),

		.addr(addr_if)

	);

	if_id if_id0 (
		.clk(clk_in),
		.rst(rst),

		.stall(stall),

		.if_pc(pc_iffd),
		.if_inst(inst_iffd),

		.id_pc(pc_ifdd),
		.id_inst(inst_ifdd)
	);

	id id0 (
		.rst(rst),

		.pc(pc_ifdd),
		.inst(inst_ifdd),

		.ex_rd_addr(ex_rd_addr),
		.ex_rd_write(ex_rd_write),
		.ex_rd_data(ex_rd_data),

		.ex_alu_op(ex_alu_op),

		.mem_rd_addr(mem_rd_addr),
		.mem_rd_write(mem_rd_write),
		.mem_rd_data(mem_rd_data),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		.reg1_addr_o(reg1_addr),
		.reg1_read_enable(reg1_read),
		.reg2_addr_o(reg2_addr),
		.reg2_read_enable(reg2_read),

		.reg1(reg1_de),
		.reg2(reg2_de),
		.Imm(imm_de),
		.rd(rd_de),
		.rd_enable(rd_enable_de),
		.alu_op(alu_op_de),
		.jump_op(jump_op_de),
		.branch_op(branch_op_de),
		.jump_addr1(jump_addr1_de),

		.stallreq(stallreq_id)

	);

	id_ex id_ex0 (
		.clk(clk_in),
		.rst(rst),

		.stall(stall),

		.id_reg1(reg1_de),
		.id_reg2(reg2_de),
		.id_Imm(imm_de),
		.id_rd(rd_de),
		.id_rd_enable(rd_enable_de),
		.id_alu_op(alu_op_de),
		.id_jump_op(jump_op_de),
		.id_branch_op(branch_op_de),
		.id_jump_addr1(jump_addr1_de),

		.ex_reg1(reg1_dee),
		.ex_reg2(reg2_dee),
		.ex_Imm(imm_dee),
		.ex_rd(rd_dee),
		.ex_rd_enable(rd_enable_dee),
		.ex_alu_op(alu_op_dee),
		.ex_jump_op(jump_op_dee),
		.ex_branch_op(branch_op_dee),
		.ex_jump_addr1(jump_addr1_dee)
	);

	ex ex0 (
		.rst(rst),

		.reg1(reg1_dee),
		.reg2(reg2_dee),
		.Imm(imm_dee),
		.rd(rd_dee),
		.rd_enable(rd_enable_dee),
		.alu_op(alu_op_dee),
		.jump_op(jump_op_dee),
		.branch_op(branch_op_dee),
		.jump_addr1(jump_addr1_dee),

		.mem_addr_o(mem_addr_eem),
		.mem_wdata_o(mem_wdata_eem),
		.rd_data_o(ex_rd_data),
		.rd_addr(ex_rd_addr),
		.rd_enable_o(ex_rd_write),
		.alu_op_o(ex_alu_op),

		.jump_flag(JumpFlag),
		.jump_addr(jump_addr),

		.stallreq_jump(stallreq_for_jump)
	);

	ex_mem ex_mem0 (
		.clk(clk_in),
		.rst(rst),

		.stall(stall),

		.ex_rd_data(ex_rd_data),
		.ex_rd_addr(ex_rd_addr),
		.ex_rd_enable(ex_rd_write),
		.ex_mem_addr(mem_addr_eem),
		.ex_alu_op(ex_alu_op),
		.ex_mem_wdata(mem_wdata_eem),

		.mem_rd_data(rd_data_emm),
		.mem_rd_addr(rd_addr_emm),
		.mem_mem_addr(mem_addr_emm),
		.mem_alu_op(alu_op_emm),
		.mem_mem_wdata(mem_wdata_emm),
		.mem_rd_enable(rd_enable_emm)

	);

	mem mem0 (
		.rst(rst),

		.rd_data_i(rd_data_emm),
		.rd_addr_i(rd_addr_emm),
		.mem_addr_i(mem_addr_emm),
		.mem_wdata_i(mem_wdata_emm),
		.alu_op(alu_op_emm),
		.rd_enable_i(rd_enable_emm),

		.mem_data(data_mc_m),
		.mem_data_enable(data_enable_mc_m),
		.icache_busy(icache_busy),

		.rd_data_o(mem_rd_data),
		.rd_addr_o(mem_rd_addr),
		.rd_enable_o(mem_rd_write),

		.mem_wdata_o(wdata_m_mc),
		.mem_addr_o(addr_m_mc),
		.mem_type(mem_type_m_mc),
		.mem_rw(rw_m_mc),
		.mem_enable(mem_enable_m_mc),

		.stallreq(stallreq_mem)

	);

	mem_wb mem_wb0 (
		.clk(clk_in),
		.rst(rst),

		.stall(stall),

		.mem_rd_data(mem_rd_data),
		.mem_rd_addr(mem_rd_addr),
		.mem_rd_enable(mem_rd_write),

		.wb_rd_data(wb_rd_data),
		.wb_rd_addr(wb_rd_addr),
		.wb_rd_enable(wb_rd_enable)

	);

	register register0 (
		.clk(clk_in),
		.rst(rst),
		
		.write_enable(wb_rd_enable),
		.write_addr(wb_rd_addr),
		.write_data(wb_rd_data),

		.read_enable1(reg1_read),
		.read_addr1(reg1_addr),
		.read_data1(reg1_data),

		.read_enable2(reg2_read),
		.read_addr2(reg2_addr),
		.read_data2(reg2_data)
	);

	i_cache i_cache0 (
		.clk(clk_in),
		.rst(rst),

		.inst_addr_i(addr_if),

		.inst(inst_if),
		.inst_available_o(inst_available_if),

		.inst_mem(inst_mi),
		.inst_enable_i(inst_enable_mi),
		.mem_busy(mem_busy),

		.inst_needed(inst_needed),
		.inst_addr_to_mem(inst_addr_im),

		.stallreq(stallreq_if)

	);

	mem_ctrl mem_ctrl0 (
		.clk(clk_in),
		.rst(rst),

		.mem_rw(rw_m_mc),
		.mem_enable(mem_enable_m_mc),
		.mem_data_addr(addr_m_mc),
		.mem_data_i(wdata_m_mc),
		.mem_type(mem_type_m_mc),

		.icache_needed(inst_needed),
		.icache_addr(inst_addr_im),

		.mem_busy(mem_busy),
		.icache_busy(icache_busy),

		.mem_data_o(data_mc_m),
		.mem_data_enable(data_enable_mc_m),

		.inst_o(inst_mi),
		.inst_data_enable(inst_enable_mi),

		.ram_data_i(mem_din),

		.ram_addr(mem_a),
		.ram_data(mem_dout),
		.ram_rw(mem_wr)

	);

endmodule
