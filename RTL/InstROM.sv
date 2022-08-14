// Create Date:    15:50:22 10/02/2019 
// Design Name: 
// Module Name:    InstROM 
// Project Name:   CSE141L
// Tool versions: 
// Description: Verilog module -- instruction ROM template	
//	 preprogrammed with instruction values (see case statement)
//
// Revision: 2021.08.08
//
// A = program counter width
// W = machine code width -- do not change for CSE141L
module InstROM #(parameter A=12, W=9) (
  input       [A-1:0] InstAddress,
  output logic[W-1:0] InstOut);
	 
// (usually recommended) expression
//   need $readmemh or $readmemb to initialize all of the elements
// This version will work best with assemblers, but you can try the alternative starting line 33
// This version is also by far the easiest if you have a long program scrip.  
// declare 2-dimensional array, W bits wide, 2**A words deep
  logic[W-1:0] inst_rom[2**A];
  always_comb InstOut = inst_rom[InstAddress];
 
  initial begin		                  // load from external text file
  	$readmemb("machine_code.txt",inst_rom);
  end 
  
// Sample instruction format: 
//   {3bit opcode, 3bit rs or rt, 3bit rt, immediate, or branch target}
//   then use LUT to map 3 bits to 10 for branch target, 8 for immediate	 

/* alternative to code shown below, which may be simpler -- either is fine
  always_comb begin 
	InstOut = 'b0000000000;        // default
	case (InstAddress)
//opcode = 0 lhw, rs = 0, rt = 1
      0 : InstOut = 'b0000000001;  // load from address at reg 0 to reg 1  
// opcode = 1 addi, rs/rt = 1, immediate = 1
     
      1 : InstOut = 'b0001001001;  // addi reg 1 and 1
		
// opcode = 2 shw, rs = 0, rt = 1
      2 : InstOut = 'b0010000001;  // sw reg 1 to address in reg 0
		
// opcode = 3 beqz, rs = 1, target = 1
      3 : InstOut = 'b0011001001;  // beqz reg1 to absolute address 1
		
// opcode = 15 halt
      4 : InstOut = '1;  // equiv to 10'b1111111111 or 'b1111111111    halt
// (default case already covered by opening statement)
    endcase
  end
*/

endmodule
