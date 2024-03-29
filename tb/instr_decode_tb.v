`timescale 1ns / 1ps

module instr_decode_tb ();
	reg clk, reset;

	reg [31:0] instr;

	wire is_store, is_load;

	wire is_ui, add_pc;

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
	localparam tests = 9;

	localparam clk_period = 10;

	instr_decode dut (
		.clk(clk),
		.reset(reset),
		.instr(instr),
		.is_store(is_store),
		.is_load(is_load),
		.is_ui(is_ui),
		.add_pc(add_pc),
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
		.clk(clk),
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

		if ((is_store | is_load
			| is_ui | add_pc
			| is_branch | is_jump | is_reg
			| is_alu
			| operand_a | operand_b | branch_dest | dest
			| func3	| func7 | raddr1 | raddr2) == 0) begin
			$display("PASSED: reset");
			pass = pass + 1;
		end else begin
			$display("FAILED: reset");
			fail = fail + 1;
		end

		reset = 0;

		/* jal:
		 * imm = 2000
		 * rd = x3
		 */
		instr = 32'b0111_1101_0000_0000_0000_0001_1110_1111;

		#(clk_period);

		if (((is_store | is_load | is_ui | add_pc | is_branch | is_reg | is_alu) == 0)
			&& (is_jump == 1'b1)
			&& (operand_a == 2000)
			&& (dest == 3)) begin
			$display("PASSED: jal");
			pass = pass + 1;
		end else begin
			$display("FAILED: jal");
			fail = fail + 1;
		end

		waddr = 31;
		wdata = 12345;
		w_en = 1;

		#(clk_period);

		w_en = 0;
		/* jalr:
		 * imm = 2000
		 * rd = x2 (12345)
		 * rs1 = x31
		 */
		instr = 32'b0111_1101_0000_1111_1000_0001_0110_0111;

		#(clk_period);

		if (((is_store | is_load | is_ui | add_pc | is_branch | is_alu) == 0)
			&& ((is_jump & is_reg) == 1'b1)
			&& (operand_a == 12345)
			&& (operand_b == 2000)
			&& (dest == 2)) begin
			$display("PASSED: jalr");
			pass = pass + 1;
		end else begin
			$display("FAILED: jalr");
			fail = fail + 1;
		end

		w_en = 1;
		waddr = 15;
		wdata = 9876;

		#(clk_period);

		waddr = 14;
		wdata = 4567;

		#(clk_period);

		w_en = 0;
		/* beq:
		 * imm = 2000
		 * rs1 = x15 (9876)
		 * rs2 = x14 (4567)
		 */
		instr = 32'b0111_1100_1110_0111_1000_1000_0110_0011;

		#(clk_period);

		if (((is_store | is_load | is_ui | add_pc | is_jump | is_reg | is_alu) == 0)
			&& (is_branch == 1'b1)
			&& (operand_a == 9876)
			&& (operand_b == 4567)
			&& (branch_dest == 2000)
			&& (func3 == 3'b000)) begin
			$display("PASSED: beq");
			pass = pass + 1;
		end else begin
			$display("FAILED: beq");
			fail = fail + 1;
		end

		/* bne, blt, bge, bltu, bgeu: mostly equivalent to beq */

		/* lb, lh, lw, lbu, lhu: TODO */
		/* sb, sh, sw: TODO */

		w_en = 1;
		waddr = 5;
		wdata = 10;

		#(clk_period);

		w_en = 0;
		/* andi:
		 * imm: -2000
		 * rs1: x5 (10)
		 * rd: x31
		 * func3: 111
		 */
		instr = 32'b1000_0011_0000_0010_1111_1111_1001_0011;

		#(clk_period);

		if (((is_store | is_load | is_ui | add_pc | is_jump | is_reg | is_branch) == 0)
			&& (is_alu == 1'b1)
			&& (operand_a == 10)
			&& ($signed(operand_b) == -2000)
			&& (dest == 31)
			&& (func3 == 3'b111)) begin
			$display("PASSED: andi");
			pass = pass + 1;
		end else begin
			$display("FAILED: andi");
			fail = fail + 1;
		end

		/* addi, slti, sltiu, xori, ori:
		 * mostly equivalent to andi
		 */

	    w_en = 1;
	    waddr = 3;
	    wdata = 5000;

		#(clk_period);

	    w_en = 0;
	    /* srai:
	     * func7: 1
	     * shamt: 10
	     * rs1: 3 (5000)
	     * func3: 101
	     * rd: 13
	     */
		instr = 32'b0100_0000_1010_0001_1101_0110_1001_0011;

		#(clk_period);

		if (((is_store | is_load | is_ui | add_pc | is_jump | is_reg | is_branch) == 0)
			&& (is_alu == 1'b1)
			&& (operand_a == 5000)
			&& (operand_b == 10)
			&& (dest == 13)
			&& (func7 == 1'b1)
			&& (func3 == 3'b101)) begin
			$display("PASSED: srai");
			pass = pass + 1;
		end else begin
			$display("FAILED: srai");
			fail = fail + 1;
		end

	    /* slli, srli: mostly equivalent to srai */

		w_en = 1;
		waddr = 20;
		wdata = 900;

		#(clk_period);

		waddr = 21;
		wdata = 2000;

		#(clk_period);

		w_en = 0;
		/* add:
		 * f7: 0
		 * rs2: 21(2000)
		 * rs1: 20(900)
		 * func3: 000
		 * rd: 29
		 */
		instr = 32'b0000_0001_0101_1010_0000_1110_1011_0011;

		#(clk_period);

		if (((is_store | is_load | is_ui | add_pc | is_jump | is_reg | is_branch) == 0)
			&& (is_alu == 1'b1)
			&& (operand_a == 900)
			&& (operand_b == 2000)
			&& (dest == 29)
			&& (func7 == 1'b0)
			&& (func3 == 3'b000)) begin
			$display("PASSED: add");
			pass = pass + 1;
		end else begin
			$display("FAILED: add");
			fail = fail + 1;
		end

		/* sub, sll, xor, srl, sra, or, and, slt, sltu: mostly equivalent to add */

		/* lui
		 * imm: 4096
		 * rd: 5
		 */
		 instr = 32'b0000_0000_0000_0000_0001_0010_1011_0111;

		 #(clk_period);

		if (((is_store | is_load | add_pc | is_jump | is_reg | is_branch | is_alu) == 0)
			&& (is_ui == 1'b1)
			&& (operand_a == 4096)
			&& (dest == 5)) begin
			$display("PASSED: lui");
			pass = pass + 1;
		end else begin
			$display("FAILED: lui");
			fail = fail + 1;
		end

		/* auipc
		 * imm: 8192
		 * rd: 2
		 */
		instr = 32'b0000_0000_0000_0000_0010_0001_0001_0111;

		#(clk_period);

		if (((is_store | is_load | is_jump | is_reg | is_branch | is_alu) == 0)
			&& ((is_ui & add_pc) == 1)
			&& (operand_a == 8192)
			&& (dest == 2)) begin
			$display("PASSED: auipc");
			pass = pass + 1;
		end else begin
			$display("FAILED: auipc");
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
