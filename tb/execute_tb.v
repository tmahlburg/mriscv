`timescale 1 ns / 1 ps

module execute_tb ();
	reg clk, reset;

	reg is_store, is_load;
	reg is_branch, is_jump, is_reg;
	reg is_alu;

	reg [31:0] operand_a, operand_b, branch_dest;
	reg [4:0] dest_i;
	wire [4:0] dest_o;

	reg [2:0] func3;
	reg func7;

	wire [31:0] result;

	reg [31:0] curr_pc;
	wire [31:0] next_pc;

	integer pass;
	integer fail;

	/* adjust according to the number of test cases */
	localparam tests = 1;

	localparam clk_period = 10;

	execute dut (
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
		.dest_i(dest_i),
		.dest_o(dest_o),
		.func3(func3),
		.func7(func7),
		.result(result),
		.curr_pc(curr_pc),
		.next_pc(next_pc)
	);

	initial begin
		$dumpfile("execute_tb.vcd");
		$dumpvars(0, execute_tb);

		reset = 0;
		clk = 0;

		pass = 0;
		fail = 0;

		#(clk_period);
		reset = 1;
		#(clk_period);

		if ((dest_o == 0) && (result == 0) && (next_pc == 0)) begin
			$display("PASSED: reset");
			pass = pass + 1;
		end else begin
			$display("FAILED: reset");
			fail = fail + 1;
		end

		/* TEST CASES */

		if ((pass + fail) == tests) begin
			$display("PASSED: number of test cases");
			pass = pass + 1;
		end else begin
			$display("FAILED: number of test cases");
			fail = fail + 1;
		end

		$display("%0d/%0d PASSED", pass, (tests + 1));
		$finish;
	end

	always #(clk_period / 2.0) clk <= ~clk;

endmodule
