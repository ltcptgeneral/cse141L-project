// team name     quarter  
module TopLevel(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );


  InstFetch IF1 (		       // this is the program counter module
	.Reset        (Reset   ) ,  // reset to 0
	.Start        (Start   ) ,  // SystemVerilog shorthand for .grape(grape) is just .grape 
	.Clk          (Clk     ) ,  //    here, (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs    (Jump    ) ,  // jump enable
	.BranchRelEn  (BranchEn) ,  // branch enable
	.ALU_flag	  (Zero    ) ,  // 
    .Target       (PCTarg  ) ,  // "where to?" or "how far?" during a jump or branch
	.ProgCtr      (PgmCtr  )	   // program count = index to instruction memory
	);	

  LUT LUT1(.Addr         (TargSel ) ,
           .Target       (PCTarg  )
    );


// instruction ROM -- holds the machine code pointed to by program counter
  InstROM #(.W(9),.A(10)) IR1(
	.InstAddress  (PgmCtr     ) , 
	.InstOut      (Instruction)
	);

		// in place   c = a+c    ADD R0 R1 R0
// reg file
	RegFile #(.W(8),.D(3)) RF1 (			  // D(3) makes this 8 elements deep
		.Clk       	  ,
		.WriteEn   (RegWrEn)    , 
		.RaddrA    (Instruction[5:3]),  //3'b0      //concatenate with 0 to give us 4 bits
		.RaddrB    (Instruction[2:0]), 	// (Instruction[2:0]+1);
		.Waddr     (Instruction[5:3]), 	//3'b0      // mux above
		.DataIn    (RegWriteValue) , 
// outputs
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 )
	);

    ALU ALU1  (
	  .InputA  (InA),
	  .InputB  (InB), 
	  .SC_in   (PFq),
	  .OP      (Instruction[8:6]),
// outputs
	  .Out     (ALU_out),//regWriteValue),
      .PF      (PF),
	  .Zero	                         // status flag; may have others, if desired
	  );

    always @(posedge Clk)
     PFq <= PF;


	DataMem DM1(  
// inputs
		.Clk 		  (Clk)		 ,
		.Reset		  (Reset)	 ,
		.DataAddress  (ReadA)    , 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
// outputs
		.DataOut      (MemReadValue) 
	);







endmodule