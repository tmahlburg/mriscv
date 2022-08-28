`timescale 1ns / 1ps

module instr_decode_tb ();
	reg clk, reset;

	reg [31:0] instr;

	wire is_store, is_load;

	wire is_branch, is_jump, is_reg;

	wire is_alu;

	wire [31:0] operand_a, operand_b;
	wire [31:0] branch_dest;
	wire [4:0] dest;
	wire [2:0] func3;
	wire func7;

	wire [31:0] rdata1;
	wire [31:0] rdata2;

	wire [4:0] raddr1;
	wire [4:0] raddr2;

	integer pass;
	integer fail;

	/* adjust according to the number of test cases */
	localparam tests = 1;

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

	reg w_en;
	reg [4:0] waddr;
	reg [31:0] wdata;

	regs regs (
		.w_en(w_en),
		.raddr1(raddr1),
		.raddr2(raddr2),
		.waddr(waddr),
		.rdata1(rdata1),
		.rdata2(rdata2),
		.wdata(wdata)
	);

	initial begin
		$dumpfile("instr_decode_tb.vcd");
		$dumpvars(0, instr_decode_tb);

		reset = 1;
		clk = 0;
		clk_period = 10;

		pass = 0;
		fail = 0;

		#10;

		if ((is_store | is_load | is_branch | is_jump | is_reg
			| is_alu | operand_a | operand_b | branch_dest
			| dest | func3 | func7 | raddr1 | raddr2) == 0) begin
			$display("PASSED: reset");
			pass = pass + 1;
		end else begin
			$display("FAILED: reset");
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
