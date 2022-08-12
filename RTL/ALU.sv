// Create Date:    2018.10.15
// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision 2022.04.30
// Additional Comments: 
//   combinational (unclocked) ALU
import definitions::*;			    // includes package "definitions"
module ALU #(parameter W=8)(
  input        [W-1:0] InputA,      // data inputs
                       InputB,
  input                SC_in,       // shift or carry in
  input        [  2:0] OP,		    // ALU opcode, part of microcode
  output logic [W-1:0] Out,		    // or:  output reg [7:0] OUT,
  output logic         PF,          // reduction parity
  output logic         Zero,        // output = zero flag
  output logic         SC_out       // shift or carry out
// you may provide additional status flags as inputs, if desired
    );								    
	 
  op_mne op_mnemonic;			         // type enum: used for convenient waveform viewing

// InputA = current LFSR state
// InputB = tap_pattern	
  always_comb begin
    Out = 0; 
    SC_out = 0;                           // No Op = default
    case(OP)
      kADD : {SC_out,Out} = {1'b0,InputA} + InputB;      // add 
      kLSH : {SC_out,Out} = {InputA[7:0],SC_in};  // shift left, fill in with SC_in 
           // for logical left shift, tie SC_in = 0
 	  kRSH : {Out,SC_out} = {SC_in, InputA[7:0]};  // shift right
 	  kXOR : Out = InputA ^ InputB;      // exclusive OR
      kAND : Out = InputA & InputB;      // bitwise AND
    endcase
  end

  always_comb							  // assign Zero = !Out;
    case(Out)
      'b0     : Zero = 1'b1;
	  default : Zero = 1'b0;
    endcase

  always_comb
    PF = ^Out;  // Out[7]^Out[6]^...^Out[0]           // reduction XOR 

  always_comb
    op_mnemonic = op_mne'(OP);			 // displays operation name in waveform viewer

endmodule


				  /*     InputA=10101010    SC_in = 1
               kLSH   Out = 01010101        
*/