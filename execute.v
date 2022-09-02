`timescale 1ns / 1ps

module execute (
	input clk, reset,

	input is_store,
	input is_load,

	input is_branch,
	input is_jump,
	input is_reg,

	input is_alu,

	input signed [31:0] operand_a,
	input signed [31:0] operand_b,
	input [31:0] branch_dest,
	input [4:0] dest_i,
	output reg [4:0] dest_o,

	input [2:0] func3,
	input func7,

	output reg [31:0] result,

	input [31:0] curr_pc,
	output reg [31:0] next_pc
);
	/* helper register to check for branch */
	reg branch;

	always @(posedge clk) begin
		if (reset) begin
			dest_o <= 0;
			result <= 0;
			branch <= 1'b0;
			next_pc <= 1'b0;
		end else begin
			dest_o <= dest_i;
			branch <= 1'b0;

			case (1'b1)
				is_store: ; /* TODO */

				is_load: ; /* TODO */

				is_branch: begin
					case (func3)
						/* beq */
						3'b000: branch <= (operand_a == operand_b);
						/* bne */
						3'b001: branch <= (operand_a != operand_b);
						/* blt */
						3'b100: branch <= (operand_a < operand_b);
						/* bge */
						3'b101: branch <= (operand_a >= operand_b);
						/* bltu */
						3'b110: branch <= ($unsigned(operand_a) < $unsigned(operand_b));
						/* bgeu */
						3'b111: branch <= ($unsigned(operand_a) >= $unsigned(operand_b));
					endcase
				end

				is_jump: begin
					result <= curr_pc + 4;
					/* when there is no destination specified, register x1 is assumed */
					if (dest_i == 5'b00000) begin
						dest_o <= 5'b00001;
					end
					if (is_reg) begin
						next_pc <= (operand_a + operand_b) & ~1;
					end else begin
						next_pc <= curr_pc + operand_a;
					end
					branch <= 1'b1;
				end

				is_alu: begin
					case (func3)
						/* add */
						3'b000: begin
							if (func7 === 1'b0) begin
								result <= operand_a + operand_b;
							end else begin
								result <= operand_a - operand_b;
							end
						end
						/* and */
						3'b111: begin
							result <= operand_a & operand_b;
						end
						/* or */
						3'b110: begin
							result <= operand_a | operand_b;
						end
						/* xor */
						3'b100: begin
							result <= operand_a ^ operand_b;
						end
						/* left shift */
						3'b001: begin
							result <= operand_a << operand_b[4:0];
						end
						/* right shift */
						3'b101: begin
							/* logical */
							if (func7 === 1'b0) begin
								result <= operand_a >> operand_b[4:0];
							/* arithmetic */
							end else begin
								result <= operand_a >>> operand_b[4:0];
							end
						end
					endcase
					next_pc <= curr_pc + 4;
				end
			endcase

		end
	end

	/* needed to calculate next_pc in one clock cycle */
	always @* begin
		if (!is_jump) begin
			if (branch) begin
				next_pc = curr_pc + branch_dest;
			end else begin
				next_pc = curr_pc + 4;
			end
		end
	end

endmodule
