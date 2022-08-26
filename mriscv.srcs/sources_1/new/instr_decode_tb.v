`timescale 1ns / 1ps

module instr_decode_tb ();
	reg clk, reset;

	reg [31:0] instr;

	wire is_store, is_load;

	wire is_branch, is_jump, is_reg;

	wire is_alu;

	wire [31:0] operand_a, wire [31:0] operand_b;
	reg [31:0] branch_dest;
	reg [4:0] dest;
	reg [2:0] func3;
	reg func7;

	reg [31:0] rdata1;
	reg [31:0] rdata2;

	reg [4:0] raddr1;
	reg [4:0] raddr2;


	integer pass_count;
	integer fail_count;

	localparam test_count = 0;

	reg [31:0] clk_period;

	instr_decode dut (
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
		.dest(dest),
		.func3(func3),
		.func7(func7),
		.rdata1(rdata1),
		.rdata2(rdata2),
		.raddr1(raddr1),
		.raddr2(raddr2)
	);


	initial begin
		$dumpfile("instr_decode_tb.vcd");
		$dumpvars(0, instr_decode_tb);


		$display("%0d/%0d PASSED", pass_count, (total + 1));
		$finish;
	end

	always #(clk_period / 2.0) clk <= ~clk;

endmodule
