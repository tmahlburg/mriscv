`timescale 1ns / 1ps

module regs_tb();
	integer pass;
	integer fail;

	/* adjust according to number of test cases */
	localparam tests = 8;

	reg clk, w_en;
	integer clk_period;
	reg [4:0] raddr1, raddr2, waddr;
	wire [31:0] rdata1, rdata2;
	reg [31:0] wdata;

	regs dut (
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
		$dumpfile("regs_tb.vcd");
		$dumpvars(0, regs_tb);

		clk = 0;
		clk_period = 10;

		w_en = 0;
		raddr1 = 0;
		raddr2 = 0;
		waddr = 0;
		wdata = 0;

		pass = 0;
		fail = 0;

		#10;

		if (rdata1 === 0 && rdata2 === 0) begin
			$display("PASSED: x0 is zero on startup");
			pass = pass + 1;
		end else begin
			$display("FAILED: x0 is zero on startup");
			fail = fail + 1;
		end

		w_en = 0;
		waddr = 1;
		wdata = 1000;
		raddr1 = 1;

		#10;

		if (rdata1 !== 1000) begin
			$display("PASSED: only write if w_en = 1");
			pass = pass + 1;
		end else begin
			$display("FAILED: only write if w_en = 1");
			fail = fail + 1;
		end

		w_en = 1;

		#10;

		if (rdata1 === 1000) begin
			$display("PASSED: write/read on x1");
			pass = pass + 1;
		end else begin
			$display("FAILED: write/read on x1");
			fail = fail + 1;
		end

		if (rdata2 === 0) begin
			$display("PASSED: first and second read bus independent");
			pass = pass + 1;
		end else begin
			$display("FAILED: first and second read bus independent");
			fail = fail + 1;
		end

		waddr = 0;
		raddr1 = 0;

		#10;

		if (rdata1 === 0) begin
			$display("PASSED: x0 always zero");
			pass = pass + 1;
		end else begin
			$display("FAILED: x0 always zero");
			fail = fail + 1;
		end

		w_en = 0;
		wdata = 2000;
		waddr = 1;
		raddr1 = 1;

		#10;

		if (rdata1 === 1000) begin
			$display("PASSED: can't change register if w_en = 0");
			pass = pass + 1;
		end else begin
			$display("FAILED: can't change register if w_en = 0");
			fail = fail + 1;
		end

		w_en = 1;

		#10;

		if (rdata1 === 2000) begin
			$display("PASSED: can change register content");
			pass = pass + 1;
		end else begin
			$display("FAILED: can change register content");
			fail = fail + 1;
		end

		waddr = 31;
		raddr2 = 31;

		#10;

		if (rdata2 === 2000) begin
			$display("PASSED: x31 working as highest register");
			pass = pass + 1;
		end else begin
			$display("FAILED: x31 working as highest register");
			fail = fail + 1;
		end

		/* evaluate tests */
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
