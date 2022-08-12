module InstFetch_TB();

  logic              Reset  = 1'b1,			
                     Start  = 1'b0,			
                     Clk    = 1'b0,			
                     BranchAbs   = 1'b0,	 
                     BranchRelEn = 1'b0,
                     ALU_flag    = 1'b0;		
  logic        [9:0] Target = 'b1; //10'h3fc;//'1;	  -4 
  wire         [9:0] ProgCtr;     

InstFetch IF1(.*);

always begin 
  #5ns Clk = 1'b1;
  #5ns Clk = 1'b0;
end

initial begin
   #20ns Reset = 1'b0;
   #20ns Start = 1'b1;
   #20ns Start = 1'b0; 
  #120ns BranchAbs = 1'b1;	 // should reset PC to 0
   #30ns BranchAbs = 1'b0;
  #250ns BranchRelEn = 1'b1;
         Target      = 'h3fc;   // -4
   #20ns ALU_flag    = 1'b1;
   #40ns ALU_flag    = 1'b0;		 
  #240ns $stop;
end
			    
endmodule