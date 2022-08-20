// Module Name: Ctrl
// Project Name: CSE141L
// control decoder (combinational, not clocked)

import Definitions::*;

module Ctrl #(
	parameter W = 8,
	parameter T = 10
) (
	input logic [8:0] Instruction,
	input logic [W-1:0] ALU_Out,
	input logic [W-1:0] RegOutA, RegOutB, // select from register inputs or immediate inputs
	input logic [T-1:0] ProgCtr_p1,
	input logic [W-1:0] mem_out,
	output op_mne ALU_OP, // control ALU operation
	output logic [W-1:0] ALU_A, ALU_B,
	output logic RegWrite, Done_in,
	output logic [3:0] RaddrA, RaddrB, Waddr, 
	output logic [W-1:0] RegInput,
	output logic BranchEZ, BranchNZ, BranchAlways,
	output logic write_mem
);

	logic [7:0] I_Immediate;
	logic [7:0] T_Immediate;
	logic [3:0] A_operand;
	logic [3:0] S_operand;
	logic [3:0] G_operand;

	assign I_Immediate = Instruction[7:0];
	assign T_Immediate = Instruction[2:0];
	assign A_operand = Instruction[3:0];
	assign S_operand = {1'b1, Instruction[2:0]};
	assign G_operand = {1'b0, Instruction[2:0]};

	always_comb begin
		// default values for an invalid NOP instruction, proper NOP instruction encoded as a LSH by 0
		ALU_OP = NOP;
		ALU_A = RegOutA;
		ALU_B = RegOutB;
		RegWrite = 'b1;
		Done_in = 'b0;
		RaddrA = 'b0;
		RaddrB = 'b0;
		Waddr = 'b0;
		RegInput = ALU_Out;
		BranchEZ = 'b0;
		BranchNZ = 'b0;
		BranchAlways = 'b0;
		write_mem = 'b0;
		casez(Instruction[8:4])
			'b1_????: begin // LDI
				ALU_A = I_Immediate;
			end
			'b0_0000: begin // PUT
				Waddr = A_operand;
			end
			'b0_0001: begin // GET
				RaddrA = A_operand;
			end
			'b0_0010: begin // LDW
				RaddrA = S_operand;
				RegInput = mem_out;
			end
			'b0_0011: begin // STW
				RaddrA = S_operand;
				RegWrite = 'b0;
				write_mem = 'b1;
			end
			'b0_0100: begin // NXT
				if(S_operand == 'd8 || S_operand == 'd9 || S_operand == 'd10) begin
					ALU_OP = SUB;
					ALU_B = 'b1;
				end
				else if (S_operand == 'd11 || S_operand == 'd12 || S_operand == 'd13) begin
					ALU_OP = ADD;
					ALU_B = 'b1;
				end
				else ALU_OP = NOP;
				RaddrA = S_operand;
				Waddr = S_operand;
			end
			'b0_0101: begin //CLB
				ALU_OP = CLB;
				RaddrA = G_operand;
				Waddr = G_operand;
			end
			'b0_0110: begin // ADD
				ALU_OP = ADD;
				RaddrA = A_operand;
			end
			'b0_0111: begin // AND
				ALU_OP = AND;
				RaddrA = A_operand;
			end
			'b0_1000: begin // LSH
				ALU_OP = LSH;
				ALU_A = T_Immediate;
			end
			'b0_1001: begin // RXR
				ALU_OP = RXOR;
				RaddrA = A_operand;
			end
			'b0_1010: begin // XOR
				ALU_OP = XOR;
				RaddrA = A_operand;
			end
			'b0_1011: begin // DNE
				Done_in = 'b1;
			end
			'b0_1100: begin // JNZ
				RegWrite = 'b0;
				RaddrA = G_operand;
				BranchNZ = 'b1;
			end
			'b0_1101: begin // JEZ
				RegWrite = 'b0;
				RaddrA = G_operand;
				BranchEZ = 'b1;
			end
			'b0_1110: begin // JMP
				RegWrite = 'b0;
				RaddrA = G_operand;
				BranchAlways = 'b1;
			end
			'b0_1111: begin // JAL
				RaddrA = G_operand;
				Waddr = 'd14; // write to link register specifically
				RegInput = ProgCtr_p1[7:0]; // write the value pc+4
				BranchAlways = 'b1;
			end
			default: begin
				RegWrite = 'b0;
			end
		endcase
	end

endmodule

