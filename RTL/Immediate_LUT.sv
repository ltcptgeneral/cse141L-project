/* CSE141L
   possible lookup table for PC target
   leverage a few-bit pointer to a wider number
   Lookup table acts like a function: here Target = f(Addr);
 in general, Output = f(Input); lots of potential applications 
*/
module Immediate_LUT #(PC_width = 10)(
  input               [ 2:0] addr,
  output logic[PC_width-1:0] datOut
  );

always_comb begin
  datOut = 'h001;	          // default to 1 (or PC+1 for relative)
  case(addr)		   
	2'b00:   datOut = 'hfc;   // -4, i.e., move back 16 lines of machine code
	2'b01:	 datOut = 'h03;
	2'b10:	 datOut = 'h07;
  endcase
end

endmodule


			 // 3fc = 1111111100 -4
			 // PC    0000001000  8
			 //       0000000100  4  