// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0]  Instruction,	   // machine code
  input[ 7:0]  DatMemAddr,
  output logic Jump     ,
               BranchEn ,
			   RegWrEn  ,	   // write to reg_file (common)
			   MemWrEn  ,	   // write to mem (store only)
			   LoadInst	,	   // mem or ALU to reg_file ?
               PCTarg   ,
			   tapSel   ,
			   Ack		       // "done w/ program"
//  output logic[2:0]  ALU_inst
  );

/* ***** All numerical values are completely arbitrary and for illustration only *****
*/

// ALU commands
//assign ALU_inst = Instruction[2:0]; 

// STR commands only -- write to data_memory
assign MemWrEn = Instruction[8:6]==3'b110;

// all but STR and NOOP (or maybe CMP or TST) -- write to reg_file
assign RegWrEn = Instruction[8:7]!=2'b11;

// route data memory --> reg_file for loads
//   whenever instruction = 9'b110??????; 
assign LoadInst = Instruction[8:6]==3'b110;  // calls out load specially

assign tapSel = LoadInst &&	 DatMemAddr=='d62;
// jump enable command to program counter / instruction fetch module on right shift command
// equiv to simply: assign Jump = Instruction[2:0] == kRSH;
always_comb
  if(Instruction[2:0] ==  kRSH)
    Jump = 1;
  else
    Jump = 0;

// branch every time instruction = 9'b?????1111;
assign BranchEn = &Instruction[3:0];

// whenever branch or jump is taken, PC gets updated or incremented from "Target"
//  PCTarg = 2-bit address pointer into Target LUT  (PCTarg in --> Target out
assign PCTarg  = Instruction[3:2];

// reserve instruction = 9'b111111111; for Ack
assign Ack = &Instruction;

endmodule

