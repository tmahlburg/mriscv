/*
 * write_back_tb.v: Test bench for write_back.v
 * author: Till Mahlburg
 * year: 2022
 * license: ISC
 *
 */

`timescale 1 ns / 1 ps

module write_back_tb ();
	reg reset, clk;

	reg [31:0] result;
	reg [4:0] dest;
	reg [31:0] next_pc;

	wire w_en;
	wire [31:0] wdata, rdata;
	wire [4:0] waddr;
	reg [4:0] raddr;

	wire [31:0] pc;

	integer pass;
	integer fail;

	integer clk_period;

	/* adjust according to the number of test cases */
	localparam tests = 5;

	write_back #(
		.STACK_ADDR(1000)
	)
	dut (
		.clk(clk),
		.reset(reset),
		.result(result),
		.dest(dest),
		.next_pc(next_pc),
		.pc(pc),
		.w_en(w_en),
		.wdata(wdata),
		.waddr(waddr)
	);

	regs regs(
		.clk(clk),
		.w_en(w_en),
		.waddr(waddr),
		.wdata(wdata),
		.raddr1(raddr),
		.rdata1(rdata)
	);

	initial begin
		$dumpfile("write_back_tb.vcd");
		$dumpvars(0, write_back_tb);

		reset = 0;

		pass = 0;
		fail = 0;

		clk_period = 10;
		clk = 0;

		#(clk_period);
		reset = 1;
		#(clk_period);

		/* TEST CASES */
		if ((pc == 1000) && (w_en == 0) && (wdata == 0) && (waddr == 0)) begin
			$display("PASSED: reset");
			pass = pass + 1;
		end else begin
			$display("FAILED: reset");
			fail = fail + 1;
		end

		reset = 0;
		next_pc = 5;
		result = 1000;
		dest = 5;
		raddr = 5;

		#(clk_period);

		if ((pc == 5) && (waddr == 5) && (w_en == 1) && (wdata == 1000)) begin
			$display("PASSED: expose result to register");
			pass = pass + 1;
		end else begin
			$display("FAILED: expose result to register");
			fail = fail + 1;
		end

		next_pc = 10;
		result = 50;
		dest = 31;

		#(clk_period);

		if (rdata == 1000) begin
			$display("PASSED: result in register");
			pass = pass + 1;
		end else begin
			$display("FAILED: result in register");
			fail = fail + 1;
		end

		#(clk_period);

		if ((pc == 10) && (waddr == 31) && (w_en == 1) && (wdata == 50)) begin
			$display("PASSED: changed values");
			pass = pass + 1;
		end else begin
			$display("FAILED: changed values");
			fail = fail + 1;
		end

		raddr = dest;

		#(clk_period);

		if (rdata == 50) begin
			$display("PASSED: changed values in registers");
			pass = pass + 1;
		end else begin
			$display("FAILED: changed values in registers");
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
