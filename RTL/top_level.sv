// Module Name: top_level
// Project Name: CSE141L
// Description: top level RTL for processor

import Definitions::*;

module top_level(
	input clk, init, req,
	output logic ack
);

	parameter T=10;
	parameter W=8;

	logic [8:0] Instruction;
	logic [W-1:0] ALU_Out; 
	logic [W-1:0] RegOutA, RegOutB; // select from register inputs or immediate inputs
	logic [T-1:0] ProgCtr_p1;
	logic [W-1:0] mem_out;
	op_mne ALU_OP; // control ALU operation
	logic [W-1:0] ALU_A, ALU_B;
	logic RegWrite, Done_in;
	logic [3:0] RaddrA, RaddrB, Waddr;
	logic [W-1:0] RegInput;
	logic BranchEZ, BranchNZ, BranchAlways;
	logic write_mem;
	logic Zero_in, Zero_out;
	logic Done_out;
	logic [T-1:0] ProgCtr;

	Ctrl control (.*);

	ALU alu (
		.A(ALU_A),
		.B(ALU_B),
		.ALU_OP(ALU_OP),
		.Out(ALU_Out),
		.Zero(Zero_in)
	);

	InstFetch pc (
		.Clk(clk),
		.Reset(init),
		.BranchEZ(BranchEZ),
		.BranchNZ(BranchNZ),
		.BranchAlways(BranchAlways),
		.Zero(Zero_out),
		.Done(Done_out),
		.Target(ALU_A),
		.ProgCtr(ProgCtr),
		.ProgCtr_p1(ProgCtr_p1)
	);

	RegFile regfile (
		.Clk(clk),
		.Reset(init),
		.WriteEn(RegWrite),
		.RaddrA(RaddrA),
		.RaddrB(RaddrB),
		.Waddr(Waddr),
		.DataIn(RegInput),
		.Zero_in(Zero_in),
		.Done_in(Done_in),
		.start(req),
		.DataOutA(RegOutA),
		.DataOutB(RegOutB),
		.Zero_out(Zero_out),
		.Done_out(Done_out)
	);

	DataMem DM (
		.Clk(clk),
		.Reset(init),
		.WriteEn(write_mem),
		.DataAddress(ALU_Out),
		.DataIn(RegOutB),
		.DataOut(mem_out)
	);

	InstROM rom (
		.InstAddress(ProgCtr),
		.InstOut(Instruction)
	);

	assign ack = Done_out;

endmodule

