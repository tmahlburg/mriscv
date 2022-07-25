`timescale 1ns / 1ps

module execute (
	input clk, resetn,

	input is_store,
	input is_load,
	input is_branch,
	input is_alu,
	input is_shift,

	input [31:0] operand_a,
	input [31:0] operand_b,

	input [4:0] dest,

	input [2:0] func3,
	input func7,

	output reg [31:0] result
)

	always @(posedge clk) begin
		case 1'b1 begin
			is_store: ; /* TODO */

			is_load: ; /* TODO */

			is_branch: ; /* TODO */

			is_alu:
				case func3
					/* add */
					3'b000: begin
						if (func7 === 1'b0) begin
							result = operand_a + operand_b;
						end else
							result = operand_a - operand_b;
						end
					end
					/* and */
					3'b111: begin
						result = operand_a & operand_b;
					end
					/* or */
					3'b110: begin
						result = operand_a | operand_b;
					end
					/* xor */
					3'b100: begin
						result = operand_a ^ operand_b;
					end
				endcase

			is_shift:
				case func3:

				endcase
		endcase
	end

endmodule
