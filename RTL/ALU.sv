// Module Name: ALU
// Project Name: CSE141L
// Description: combinational (unclocked) ALU

import Definitions::*;

module ALU #(parameter W=8)(
	input [W-1:0] A, B, // data inputs
	input op_mne ALU_OP, // ALU opcode, part of microcode
	output logic [W-1:0] Out, // data output
	output logic Zero // zero flag
);

	logic [W-1:0] AdderA, AdderB;
	logic CIN;
	logic [W:0] AdderResult;

	carry_lookahead_adder #(.N(W)) c (
		.A(AdderA),
		.B(AdderB),
		.CIN(CIN),
		.result(AdderResult)
	);

	always_comb begin
		AdderA = A;
		AdderB = B;
		CIN = 'b0;
		case(ALU_OP)
			NOP: Out = A; // pass A to out
			CLB: Out = {1'b0, A[6:0]}; // set MSB of A to 0
			ADD: Out = AdderResult[W-1:0]; // add A to B
			SUB: begin // subtract B from A
				AdderB = ~B;
				CIN = 'b1;
				Out = AdderResult[W-1:0]; 
			end
			AND: Out = A & B; // bitwise AND between A and B
			LSH: Out = B << A; // shift B by A bits (limitation of control)
			RXOR_7: Out = ^(A[6:0]); // perform reduction XOR of lower 7 bits of A
			RXOR_8: Out = ^(A[7:0]); // perform reduction XOR of lower 8 bits of A
			XOR: Out = A ^ B; // bitwise XOR between A and B
			default: Out = 'bx; // flag illegal ALU_OP values
		endcase
		Zero = Out == 0;
	end
endmodule

module carry_lookahead_adder #(parameter N=16) (
	input logic[N-1:0] A, B,
	input logic CIN,
	output logic[N:0] result
);

	logic[N-1:-1] carry;
	logic[N-1:0] p, g;
	genvar i;
	generate
		assign carry[-1] = CIN;
		for(i = 0; i < N; i++) begin : fa_loop
			fulladder f(.a(A[i]), .b(B[i]), .cin(carry[i-1]), .sum(result[i]), .cout());
			assign g[i] = A[i] & B[i];
			assign p[i] = A[i] | B[i];
			assign carry[i] = g[i] | (p[i] & carry[i-1]);
		end : fa_loop
		assign result[N] = carry[N-1];
	endgenerate
  
endmodule: carry_lookahead_adder

module fulladder(
	input logic a, b, cin, 
	output logic sum, cout
);
	logic p, q;  
	assign p = a ^ b;
	assign q = a & b;
	assign sum = p ^ cin;
	assign cout = q | (p & cin);
endmodule: fulladder