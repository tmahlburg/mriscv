`timescale 1 ns / 1 ps

module write_back (
	input clk,
	input reset,

	input [31:0] result,
	input [5:0] dest,
	input [31:0] next_pc,

	output reg [31:0] pc,

	output reg w_en,
	output reg [31:0] wdata,
	output reg [5:0] waddr
);
	always @(posedge clk) begin
		if (reset) begin
			pc <= 0;
			w_en <= 0;
			wdata <= 0;
			waddr <= 0;
		end else begin
			wdata <= result;
			waddr <= dest;
			w_en <= 1'b1;
			pc <= next_pc;
		end
	end

	always @(negedge clk) begin
		if (!reset) begin
			w_en <= 1'b0;
		end
	end
end module
