`timescale 1ns / 1ps

module regs (
	input [4:0] raddr1,
	input [4:0] raddr2,

	output reg [31:0] rdata1,
	output reg [31:0] rdata2
);
	reg [31:0] register [0:31];

	/* register x0 is always 0 is riscv */
	assign register[0] = 0;

	assign rdata1 = register[raddr1];
	assign rdata2 = register[raddr2];
endmodule
