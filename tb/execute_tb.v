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
	localparam tests = 6;

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

		reset = 0;

		#(clk_period);

		/* load / store: TODO */

		/* branch */

		/* beq -> true */
		is_jump = 1'b0;
		is_reg = 1'b0;
		is_alu = 1'b0;
		is_load = 1'b0;
		is_store = 1'b0;
		is_branch = 1'b1;
		func3 = 3'b000;
		operand_a = 200;
		operand_b = 200;
		curr_pc = 20;
		branch_dest = 20;
		/* target pc: 40 */
		/* dest needed to test, if it is unchanged */
		dest_i = 10;

		#(clk_period);

		if ((next_pc == 40) && (dest_o == 0)) begin
			$display("PASSED: beq, branching");
			pass = pass + 1;
		end else begin
			$display("FAILED: beq, branching");
			fail = fail + 1;
		end

		/* blt -> false */
		func3 = 3'b100;
		operand_a = 100;
		operand_b = -300;
		curr_pc = 40;
		branch_dest = 20;
		/* target pc: 44 (no branch) */

		#(clk_period);

		if ((next_pc == 44) && (dest_o == 0)) begin
			$display("PASSED: blt, not branching");
			pass = pass + 1;
		end else begin
			$display("FAILED: blt, not branching");
			fail = fail + 1;
		end

		/* bge -> true */
		func3 = 3'b101;
		operand_a = 100;
		operand_b = 100;
		curr_pc = 12;
		branch_dest = 16;
		/* target pc = 28 */

		#(clk_period);

		if ((next_pc == 28) && (dest_o == 0)) begin
			$display("PASSED: bge, branching");
			pass = pass + 1;
		end else begin
			$display("FAILED: bge, branching");
			fail = fail + 1;
		end

		/* bltu -> false */
		func3 = 3'b110;
		operand_a = 2200000000;
		operand_b = 10;
		curr_pc = 20;
		branch_dest = 400;
		/* target_pc = 24 (no branch) */

		#(clk_period);

		if ((next_pc == 24) && (dest_o == 0)) begin
			$display("PASSED: bltu, not branching");
			pass = pass + 1;
		end else begin
			$display("FAILED: bltu, not branching");
			fail = fail + 1;
		end

		/* jump */

		/* jal */
		is_branch = 1'b0;
		is_jump = 1'b1;
		operand_a = 20000;
		dest_i = 31;
		curr_pc = 20;

		#(clk_period);

		if ((result == 24) && (next_pc == 20020) && (dest_o == 31)) begin
			$display("PASSED: jal");
			pass = pass + 1;
		end else begin
			$display("FAILED: jal");
			fail = fail + 1;
		end


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
