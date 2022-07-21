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

	output [31:0] operator,
	output [31:0] operand_a,
	output [31:0] operand_b,
	output [4:0] dest
);
	reg [3:0] type = 0;

	always @(posedge clk) begin
		operator = instr[6:0];
		case (instr[6:0])
			/* R-type: register-register */
			7'b0110011: type = 1;
			/* I-type: short immediates, loads */
			7'b1100111 || 7'b0000011 || 7'b0010011 || 7'b0001111 || 7'b1110011: type = 2;
			/* S-type: stores */
			7'b0100011: type = 3;
			/* B-type: conditional branches */
			7'b1100011: type = 4;
			/* U-type: long immediates */
			7'b0110111 || 7'b0010111: begin
				dest = instr[11:7];
				operand_a[31:12] = instr[31:12];
				operand_a[11:0] = 0;
			end
			/* J-type: unconditional jumps */
			7'b1101111: begin
				dest = instr[11:7];
				operand_a[31:21] = 0;
				operand_a[20] = instr[31];
				operand_a[19:12] = instr[19:12];
				operand_a[11] = instr[20];
				operand_a[10:1] = instr[30:21];
			end
		endcase
	end

endmodule
