// Module Name: Definitions
// Project Name: CSE141L
// Description: contains enumerated ALU operations

package Definitions;

	typedef enum logic[3:0] {
		NOP, // perform a simple value passthrough
		INC, // increment by 1
		DEC, // decrement by 1
		CLB, // clear leading bit
		ADD, // addition
		SUB, // subtraction
		ORR, // bitwise OR
		AND, // bitwise AND
		LSH, // left shift
		RXOR, // reduction xor
		XOR // bitwise XOR
		} op_mne;
    
endpackage // definitions
