`timescale 1 ns / 1 ps

module write_back #(
	parameter [31:0] STACK_ADDR = 0
) (
	input clk,
	input reset,

	input [31:0] result,
	input [4:0] dest,
	input [31:0] next_pc,

	output reg [31:0] pc,

	output reg w_en,
	output reg [31:0] wdata,
	output reg [4:0] waddr
);

	always @(posedge clk) begin
		if (reset) begin
			pc <= STACK_ADDR;
			w_en <= 0;
			wdata <= 0;
			waddr <= 0;
		end else begin
			w_en <= 1'b1;
			wdata <= result;
			waddr <= dest;
			pc <= next_pc;
		end
	end

endmodule
