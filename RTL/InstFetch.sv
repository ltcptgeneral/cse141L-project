// Module Name: ALU
// Project Name: CSE141L
// Description: instruction fetch (pgm ctr) for processor

module InstFetch #(parameter T=10, parameter W=8)(	  // T is PC address size, W is the jump target pointer width, which is less
	input logic Clk, Reset, // clock, reset
	input logic BranchEZ, BranchNZ, BranchAlways, Zero, // branch control signals zero from alu signals; brnahc signals will be one hot encoding
	input logic done // Done flag to indicate if the PC should increment at all
	input logic [W-1:0] Target, // jump target pointer
	output logic [T-1:0] ProgCtr_p4 // value of pc+4 for use in JAL instruction itself
);

	logic [T-1:0] PC;

	always_ff @(posedge Clk) begin
		if(Reset) PC <= 0; // if reset, set PC to 0
		else if (BranchAlways) PC <= Target; // if unconditional branch, assign PC to target
		else if (BranchEZ && Zero) PC <= Target; // if branch on zero and zero is true, then assign PC to target
		else if (BranchNZ && !Zero) PC <= Target; // if branch on non zero and zero is false, then assign PC to parget
		else if (!done) PC <= PC + 'b1; // if not a branch but CPU is not done, then 
		else PC <= PC;
	end

endmodule