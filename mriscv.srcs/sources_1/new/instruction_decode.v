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
	input clk, reset,

	input [31:0] instr,

	output reg is_store,
	output reg is_load,

	output reg is_branch,
	output reg is_jump,
	output reg is_link,
	output reg is_reg,

	output reg is_alu,
	output reg [31:0] operand_a,
	output reg [31:0] operand_b,
	output [4:0] dest,

	output [2:0] func3,
	output func7,

	/* register */
	input [31:0] rdata1,
	input [31:0] rdata2,

	output [4:0] raddr1,
	output [4:0] raddr1
);
	wire [31:0] rs1, rs2;

	assign raddr1 = instr[19:15];
	assign raddr2 = instr[24:20];

	assign rs1 = rdata1;
	assign rs2 = rdata2;

	assign func3 = instr[14:12];
	assign func7 = instr[30];

	assign dest = instr[11:7];

	/* instr decode */
	always @(posedge clk) begin
		if (!reset) begin
			operator = instr[6:0];
			is_store = 1'b0;
			is_load = 1'b0;

			is_branch = 1'b0;
			is_jump = 1'b0;
			is_rel = 1'b0;

			is_alu = 1'b0;

			case (instr[6:0]) begin
				/* R-type: register-register */
				7'b0110011: begin
					operand_a = rs1;
					operand_b = rs2;
					is_alu = 1'b1;
				end
				/* I-type: short immediates, loads */
				7'b1100111 || 7'b0000011 || 7'b0010011 || 7'b0001111 || 7'b1110011: begin
					operand_a = rs1;
					operand_b = {{20{instr[31]}}, instr[31:20]};
					case (instr[6:0]) begin
						7'b0000011: begin
							is_load = 1'b1;
						end
						/* jalr */
						7'b1100111: begin
							is_jump = 1'b1;
							is_reg = 1'b1;
						end
						7'b0010011: begin
							is_alu = 1'b1;
							/* is shift operation? operand_b = shamt */
							if (func3 == 3'b001 || func3 == 3'b101) begin
								operand_b = instr[24:20];
							end
						end
					endcase
				end
				/* S-type: stores */
				7'b0100011: begin
					is_store = 1'b1;
					operand_a = instr[19:15] + {{20{instr[31]}}, instr[31:25], instr[11:7]};
					operand_b = rs2;
				end
				/* B-type: conditional branches */
				7'b1100011: begin
					is_branch = 1'b1;
				end
				/* U-type: long immediates */
				7'b0110111 || 7'b0010111: begin
					operand_a = {instr[31:12], 12'b000000000000};
					is_load = 1'b1;
				end
				/* J-type: unconditional jumps */
				7'b1101111: begin
					operand_a = {11'b00000000000, instr[31], instr[19:12], instr[20], instr[30:21]}
					is_jump = 1'b1;
				end
				default: ; /* unknown opcode */
			endcase
		end
	end
endmodule
