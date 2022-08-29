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
	localparam tests = 3;

	localparam clk_period = 10;

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

		pass = 0;
		fail = 0;

		#(clk_period);

		if ((is_store | is_load | is_branch | is_jump | is_reg
			| is_alu | operand_a | operand_b | branch_dest
			| dest | func3 | func7 | raddr1 | raddr2) == 0) begin
			$display("PASSED: reset");
			pass = pass + 1;
		end else begin
			$display("FAILED: reset");
			fail = fail + 1;
		end

		reset = 0;

		/* jal
		 * imm = 2000
		 * rd = x3
		 */
		instr = 32'b0111_1010_0000_1000_0000_0001_1110_1111;

		#(clk_period);

		if (((is_store | is_load | is_branch | is_reg) == 0) && (is_jump == 1'b1) && (operand_a == 2000) && (dest == 3)) begin
			$display("PASSED: jal");
			pass = pass + 1;
		end else begin
			$display("FAILED: jal");
			fail = fail + 1;
		end

		#(clk_period);

		/* jalr
		 * imm = 2000
		 * rd = x2
		 * rs1 = x31
		 */
		instr = 32'b0111_1101_0000_1111_1000_0001_0110_0111;
		waddr = 31;
		wdata = 12345;
		w_en = 1;

		#(clk_period);

		if (((is_store | is_load | is_branch) == 0) && ((is_jump & is_reg) == 1'b1) && (operand_a == 2000) && (operand_b == 12345) && (dest == 2)) begin
			$display("PASSED: jalr");
			pass = pass + 1;
		end else begin
			$display("FAILED: jalr");
			fail = fail + 1;
		end

		#(clk_period);

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
