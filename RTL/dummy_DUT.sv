// skeletal starter code top level of your DUT
module top_level(
  input clk, init, req,
  output logic ack);

  logic mem_wen;
  logic[7:0]  mem_addr,
              mem_in,
			  mem_out;
  logic[11:0] pctr;		  // temporary program counter

// populate with program counter, instruction ROM, reg_file (if used),
//  accumulator (if used), 

DataMem DM(.Clk         (clk), 
           .Reset       (init), 
           .WriteEn     (mem_wen), 
           .DataAddress (mem_addr), 
           .DataIn      (mem_in), 
           .DataOut     (mem_out));


// temporary circuit to provide ack (done) flag to test bench
//   remove or greatly increase the match value once you get a 
//   proper ack 
always @(posedge clk) 
  if(init || req) 
    pctr <= 'h0;
  else  
	pctr <= pctr+'h1;

assign ack = pctr=='h256;  // pctr needed to trigger ack (arbitary time)

endmodule

