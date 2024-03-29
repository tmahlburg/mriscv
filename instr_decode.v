`timescale 1ns / 1ps


module instr_decode (
	input clk, reset,

	input [31:0] instr,

	output reg is_store,
	output reg is_load,

	output reg is_ui,
	output reg add_pc,

	output reg is_branch,
	output reg is_jump,
	output reg is_reg,

	output reg is_alu,

	output reg [31:0] operand_a,
	output reg [31:0] operand_b,
	output [31:0] branch_dest,
	output [4:0] dest,
	output [2:0] func3,
	output func7,

	/* register */
	input [31:0] rdata1,
	input [31:0] rdata2,

	output [4:0] raddr1,
	output [4:0] raddr2
);
	wire [31:0] rs1, rs2;

	assign raddr1 = reset ? 0 : instr[19:15];
	assign raddr2 = reset ? 0 : instr[24:20];

	assign rs1 = rdata1;
	assign rs2 = rdata2;

	assign func3 = reset ? 0 : instr[14:12];
	assign func7 = reset ? 0 : instr[30];

	assign dest = reset ? 0 : instr[11:7];
	assign branch_dest = reset ? 0 : {{10{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

	/* instr decode */
	always @(posedge clk) begin
		if (reset) begin
			is_store <= 1'b0;
			is_load <= 1'b0;
			is_ui <= 1'b0;
			add_pc <= 1'b0;
			is_branch <= 1'b0;
			is_jump <= 1'b0;
			is_reg <= 1'b0;
			is_alu <= 1'b0;

			operand_a <= 0;
			operand_b <= 0;
		end else begin
			is_store <= 1'b0;
			is_load <= 1'b0;

			is_ui <= 1'b0;
			add_pc <= 1'b0;

			is_branch <= 1'b0;
			is_jump <= 1'b0;
			is_reg <= 1'b0;

			is_alu <= 1'b0;

			case (instr[6:0])
				/* R-type: register-register */
				7'b0110011: begin
					operand_a <= rs1;
					operand_b <= rs2;
					is_alu <= 1'b1;
				end
				/* I-type: short immediates, loads */
				7'b1100111,
				7'b0000011,
				7'b0010011,
				7'b0001111,
				7'b1110011: begin
					operand_a <= rs1;
					operand_b <= {{20{instr[31]}}, instr[31:20]};
					case (instr[6:0])
						7'b0000011: begin
							is_load <= 1'b1;
						end
						/* jalr */
						7'b1100111: begin
							is_jump <= 1'b1;
							is_reg <= 1'b1;
						end
						7'b0010011: begin
							is_alu <= 1'b1;
							/* TODO: shamt[5] != 0 ? illegal */
							/* is shift operation? operand_b = shamt */
							if (func3 == 3'b001 || func3 == 3'b101) begin
								operand_b <= instr[24:20];
							end
						end
					endcase
				end
				/* S-type: stores */
				7'b0100011: begin
					is_store <= 1'b1;
					operand_a <= instr[19:15] + {{20{instr[31]}}, instr[31:25], instr[11:7]};
					operand_b <= rs2;
				end
				/* B-type: conditional branches */
				7'b1100011: begin
					operand_a <= rs1;
					operand_b <= rs2;
					is_branch <= 1'b1;
				end
				/* U-type: long immediates */
				7'b0110111,
				7'b0010111: begin
					operand_a <= {instr[31:12], {12{1'b0}}};
					is_ui <= 1'b1;
					if (instr[6:0] == 7'b0010111) begin
						add_pc <= 1'b1;
					end
				end
				/* J-type: unconditional jumps */
				7'b1101111: begin
					operand_a <= {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
					is_jump <= 1'b1;
				end
				default: ; /* unknown opcode */
			endcase
		end
	end
endmodule
