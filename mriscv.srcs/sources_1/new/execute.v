`timescale 1ns / 1ps

module execute (
	input clk, resetn,

	input is_store,
	input is_load,

	input is_branch,
	input is_jump,
	input is_reg,

	input is_alu,

	input [31:0] operand_a,
	input [31:0] operand_b,

	input [4:0] dest_i,
	output reg [4:0] dest_o,

	input [2:0] func3,
	input func7,

	output reg [31:0] result,

	input [31:0] curr_pc,
	output reg [31:0] next_pc
)

	always @(posedge clk) begin
		is_pc = 1'b0;
		dest_i = dest_0;

		case 1'b1 begin
			is_store: ; /* TODO */

			is_load: ; /* TODO */

			is_branch: ; /* TODO */

			is_jump: begin
				result = curr_pc + 4;
				/* when there is no destination specified, register x1 is assumed */
				if (dest_i == 5'b00000) begin
					dest_o = 5'b00001;
				end
				if (is_reg) begin
					next_pc = (operand_a + operand_b) & ~1;
				end else begin
					next_pc = curr_pc + operand_a;
				end
			end

			is_alu: begin
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
					/* left shift */
					3'b001: begin
						result = operand_a << operand_b[4:0];
					end
					/* right shift */
					3'b101: begin
						/* logical */
						if (func7 === 1'b0) begin
							result = operand_a >> operand_b[4:0];
						/* arithmetic */
						end else begin
							result = operand_a >>> operand_b[4:0];
						end
					end
				endcase
			end
		endcase
	end

endmodule
