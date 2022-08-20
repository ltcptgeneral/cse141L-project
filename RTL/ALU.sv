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

	always_comb begin
		case(ALU_OP)
			NOP: Out = A; // pass A to out
			CLB: Out = {1'b0, A[6:0]}; // set MSB of A to 0
			ADD: Out = A + B; // add A to B
			SUB: Out = A - B; // subtract B from A
			ORR: Out = A | B; // bitwise OR between A and B
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
