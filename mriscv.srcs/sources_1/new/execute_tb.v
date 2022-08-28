`timescale 1 ns / 1 ps

module execute_tb ();
	reg reset;

	integer pass;
	integer fail;

	/* adjust according to the number of test cases */
	localparam tests = 0;

	execute dut(
	);

	initial begin
		$dumpfile("execute_tb.vcd");
		$dumpvars(0, execute_tb);

		reset = 0;

		pass = 0;
		fail = 0;

		#10;
		reset = 1;
		#10;

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
endmodule
