timescale 1ns / 1ps

module core (
	input clk, reset,

	input [31:0] instr
);

	reg is_store, is_load;
	reg is_branch, is_reg, is_jump;
	reg is_alu;
	reg [31:0] operand_a, operand_b;
	wire [31:0] branch_dest;
	wire [4:0] dest_instr;
	wire [2:0] func3;
	wire func7;

	wire [31:0] rdata1, rdata2;
	wire [4:0] raddr1, raddr2;

	instr_decode instr_decode (
		.clk(clk),
		.reset(reset),

		.instr(instr),

		.is_store(is_store),
		.is_load(is_load),

		.is_branch(is_branch),
		.is_jump(is_jump),
		.is_reg(is_reg),

		.is_alu(is_alu),

		.operand_a(operand_a),
		.operand_b(operand_b),
		.branch_dest(branch_dest),
		.dest(dest_instr),
		.func3(func3),
		.func7(func7),

		.rdata1(rdata1),
		.rdata2(rdata2),
		.raddr1(raddr1),
		.raddr2(raddr2)
	);

	reg [31:0] wdata;
	reg [4:0] waddr;
	reg w_en;

	regs regs (
		.clk(clk),
		.w_en(w_en),
		.wdata(wdata),
		.waddr(waddr),
		.raddr1(raddr1),
		.raddr2(raddr2),
		.rdata1(rdata1),
		.rdata2(rdata2)
	);

	reg [4:0] dest_exec;
	reg [31:0] result;

	reg [31:0] curr_pc, next_pc;

	execute execute (
		.clk(clk),
		.reset(reset),

		.is_store(is_store),
		.is_load(is_load),

		.is_branch(is_branch),
		.is_jump(is_jump),
		.is_reg(is_reg),

		.is_alu(is_alu),

		.operand_a(operand_a),
		.operand_b(operand_b),
		.branch_dest(branch_dest),
		.dest_i(dest_instr),
		.dest_o(dest_exec),
		.func3(func3),
		.func7(func7),

		.result(result),
		.curr_pc(curr_pc),
		.next_pc(next_pc)
	);

endmodule
