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

	assign I_Immediate = Instruction[7:0];
	assign T_Immediate = Instruction[2:0];
	assign A_operand = Instruction[3:0];

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
		if(Instruction[8]) begin
			ALU_A = I_Immediate;
		end
		else case(Instruction[7:4])
			'b0000: begin // PUT
				Waddr = A_operand;
			end
			'b0001: begin // GET
				RaddrA = A_operand;
			end
			'b0010: begin // LDW
				RaddrA = A_operand;
				RegInput = mem_out;
			end
			'b0011: begin // STW
				RaddrA = A_operand;
				RegWrite = 'b0;
				write_mem = 'b1;
			end
			'b0100: begin // NXT
				if(A_operand == 'd8 || A_operand == 'd9 || A_operand == 'd10) begin
					ALU_OP = SUB;
					ALU_B = 'b1;
				end
				else if (A_operand == 'd11 || A_operand == 'd12 || A_operand == 'd13) begin
					ALU_OP = ADD;
					ALU_B = 'b1;
				end
				else ALU_OP = NOP;
				RaddrA = A_operand;
				Waddr = A_operand;
			end
			'b0101: begin //CLB
				ALU_OP = CLB;
				RaddrA = A_operand;
				Waddr = A_operand;
			end
			'b0110: begin // ADD
				ALU_OP = ADD;
				RaddrA = A_operand;
			end
			'b0111: begin // AND
				ALU_OP = AND;
				RaddrA = A_operand;
			end
			'b1000: begin // LSH
				ALU_OP = LSH;
				ALU_A = T_Immediate;
			end
			'b1001: begin // RXR
				ALU_OP = RXOR;
				RaddrA = A_operand;
			end
			'b1010: begin // XOR
				ALU_OP = XOR;
				RaddrA = A_operand;
			end
			'b1011: begin // DNE
				Done_in = 'b1;
			end
			'b1100: begin // JNZ
				RegWrite = 'b0;
				RaddrA = A_operand;
				BranchNZ = 'b1;
			end
			'b1101: begin // JEZ
				RegWrite = 'b0;
				RaddrA = A_operand;
				BranchEZ = 'b1;
			end
			'b1110: begin // JMP
				RegWrite = 'b0;
				RaddrA = A_operand;
				BranchAlways = 'b1;
			end
			'b1111: begin // JAL
				RaddrA = A_operand;
				Waddr = 'd14; // write to link register specifically
				RegInput = ProgCtr_p1[7:0]; // write the value pc+4
				BranchAlways = 'b1;
			end
		endcase
	end

endmodule

