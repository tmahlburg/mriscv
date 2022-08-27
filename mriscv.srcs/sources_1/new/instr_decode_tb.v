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

	/* adjust according to the number of test cases */
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

	regs regs (
		.raddr1(raddr1),
		.raddr2(raddr2),
		.rdata1(rdata1),
		.rdata2(rdata2)
	);

	initial begin
		$dumpfile("instr_decode_tb.vcd");
		$dumpvars(0, instr_decode_tb);

		reset = 0;
		clk = 0;
		clk_period = 10;

		pass_count = 0;
		fail_count = 0;

		if ((pass_count + fail_count) == total) begin
			$display("PASSED: number of test cases");
			pass_count = pass_count + 1;
		end else begin
			$display("FAILED: number of test cases");
			fail_count = fail_count + 1;
		end

		$display("%0d/%0d PASSED", pass_count, (test_count + 1));
		$finish;
	end

	always #(clk_period / 2.0) clk <= ~clk;

endmodule
