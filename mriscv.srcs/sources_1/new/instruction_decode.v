`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 21.07.2022 11:45:49
// Design Name:
// Module Name: instruction_decode
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module instruction_decode (
	input clk, resetn,

	input [31:0] instr,

	output reg [31:0] operator,
	output reg is_mem,
	output reg [31:0] operand_a,
	output reg [31:0] operand_b,
	output reg [4:0] dest
);
	always @(posedge clk) begin
		operator = instr[6:0];
		is_mem = 1'b0;
		case (instr[6:0])
			/* R-type: register-register */
			7'b0110011: begin
				dest = instr[11:7];
				/* operand_a_reg = instr[19:15] */
				/* operand_b_reg = instr[24:20] */
			end
			/* I-type: short immediates, loads */
			7'b1100111 || 7'b0000011 || 7'b0010011 || 7'b0001111 || 7'b1110011: begin
				if (instr[6:0] == 7'b0000011) begin
					is_mem = 1'b1;
				end
				dest = instr[11:7];
				/* operand_a_reg  = instr[19:15] */
				operand_b = {{20{instr[31]}}, instr[31:20]};
			end
			/* S-type: stores */
			7'b0100011: begin
				is_mem = 1'b1;
				/* operand_a_reg = instr[19:15] /* + immediate */
				/* operand_b_reg = instr[24:19] */
			end
			/* B-type: conditional branches */
			7'b1100011: ; /* TODO */
			/* U-type: long immediates */
			7'b0110111 || 7'b0010111: begin
				dest = instr[11:7];
				operand_a = {instr[31:12], 12'b000000000000};
			end
			/* J-type: unconditional jumps */
			7'b1101111: begin
				dest = instr[11:7];

				operand_a = {11'b00000000000, instr[31], instr[19:12], instr[20], instr[30:21]}
			end
			default: ;
		endcase
	end

endmodule
