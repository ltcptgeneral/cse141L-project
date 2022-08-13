// Design Name:    basic_proc
// Module Name:    InstFetch 
// Project Name:   CSE141L
// Description:    instruction fetch (pgm ctr) for processor
//
// Revision:  2021.11.27
// Suggested ProgCtr width 10 t0 12 bits
module InstFetch #(parameter T=10)(	  // PC width -- up to 32, if you like
  input                Reset,		  // reset, init, etc. -- force PC to 0 
                       Start,		  // begin next program in series (request issued by test bench)
                       Clk,			  // PC can change on pos. edges only
                       BranchAbs,	  // jump conditionally to Target value	   
                       BranchRelEn,	  // jump conditionally to Target + PC
                       ALU_flag,	  // flag from ALU, e.g. Zero, Carry, Overflow, Negative (from ARM)
  input        [T-1:0] Target,	      // jump ... "how high?"
  output logic [T-1:0] ProgCtr        // the program counter register itself
  );
	 
// you may wish to use either absolute or relative branching
//   you may use both, but you will need appropriate control bits
// branch/jump is how we handle gosub and return to main
// program counter can clear to 0, increment, or branch
// for unconditional branching, "ALU_flag" input should be driven by 1
  always_ff @(posedge Clk)	           // or just always; always_ff is a linting construct
	if(Reset)
	  ProgCtr <= 0;				       // for first program; want different value for 2nd or 3rd
	else if(Start)					   // hold while start asserted; commence when released
	  ProgCtr <= 0;                    //or <= ProgCtr;   holds at starting value
	else if(BranchAbs && ALU_flag      // unconditional absolute jump
	  ProgCtr <= Target;			   //   how would you make it conditional and/or relative?
	else if(BranchRelEn && ALU_flag)   // conditional relative jump
	  ProgCtr <= Target + ProgCtr;	   //   how would you make it unconditional and/or absolute
	else
	  ProgCtr <= ProgCtr+'b1; 	       // default increment (no need for ARM/MIPS +4 -- why?)

endmodule

