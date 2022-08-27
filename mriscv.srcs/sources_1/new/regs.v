`timescale 1ns / 1ps

module regs (
	input clk, w_en,

	input [4:0] waddr,
	input [4:0] raddr1,
	input [4:0] raddr2,

	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);
	reg [31:0] register [0:31];

	assign rdata1 = raddr1 == 0 ? 0 : register[raddr1];
	assign rdata2 = raddr2 == 0 ? 0 : register[raddr2];

	always @(posedge clk) begin
		if (w_en) begin
			register[waddr] <= wdata;
		end
	end
endmodule
