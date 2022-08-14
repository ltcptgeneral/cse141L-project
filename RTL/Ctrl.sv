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

	assign ALU_B = RegOutB;

	always_comb begin
		// default values for an invalid NOP instruction, proper NOP instruction encoded as a LSH by 0
		ALU_OP = NOP;
		ALU_A = RegOutA;
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
		casez(Instruction)
			'b1_????_????: begin // LDI
				ALU_A = I_Immediate;
			end
			'b0_0000_????: begin // PUT
				Waddr = A_operand;
			end
			'b0_0001_????: begin // GET
				RaddrA = A_operand;
			end
			'b0_0010_0???: begin // LDW
				RaddrA = S_operand;
				RegInput = mem_out;
			end
			'b0_0010_1???: begin // STW
				RaddrA = S_operand;
				RegWrite = 'b0;
				write_mem = 'b1;
			end
			'b0_0011_0???: begin // N?T
				if(S_operand == 'd8 || S_operand == 'd9 || S_operand == 'd10) ALU_OP = DEC;
				else if (S_operand == 'd11 || S_operand == 'd12 || S_operand == 'd13) ALU_OP = INC;
				else ALU_OP = NOP;
				RaddrA = S_operand;
				Waddr = S_operand;
			end
			'b0_0011_1???: begin //CLB
				ALU_OP = CLB;
				RaddrA = G_operand;
				Waddr = G_operand;
			end
			'b0_0100_????: begin // ADD
				ALU_OP = ADD;
				RaddrB = A_operand;
			end
			'b0_0101_????: begin // SUB
				ALU_OP = SUB;
				RaddrB = A_operand;
			end
			'b0_0110_????: begin // ORR
				ALU_OP = ORR;
				RaddrB = A_operand;
			end
			'b0_0111_????: begin // AND
				ALU_OP = AND;
				RaddrB = A_operand;
			end
			'b0_1000_0???: begin // LSH
				ALU_OP = LSH;
				ALU_A = T_Immediate;
			end
			'b0_1000_1???: begin // PTY
				ALU_OP = RXOR_7;
				RaddrA = G_operand;
			end
			'b0_1001_????: begin // CHK
				ALU_OP = RXOR_8;
				RaddrA = A_operand;
			end
			'b0_1010_????: begin // XOR
				ALU_OP = XOR;
				RaddrB = A_operand;
			end
			'b0_1011_????: begin // DNE
				Done_in = 'b1;
			end
			'b0_1110_0???: begin // JNZ
				RegWrite = 'b0;
				RaddrA = G_operand;
				BranchNZ = 'b1;
			end
			'b0_1110_1???: begin // JEZ
				RegWrite = 'b0;
				RaddrA = G_operand;
				BranchEZ = 'b1;
			end
			'b0_1111_0???: begin // JMP
				RegWrite = 'b0;
				RaddrA = G_operand;
				BranchAlways = 'b1;
			end
			'b0_1111_1???: begin // JAL
				RaddrA = G_operand;
				Waddr = 'd14; // write to link register specifically
				RegInput = ProgCtr_p1; // write the value pc+4
				BranchAlways = 'b1;
			end
		endcase
	end

endmodule

