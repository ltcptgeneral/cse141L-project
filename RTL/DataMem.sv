// Module Name: DataMem
// Project Name: CSE141L
// control decoder (combinational, not clocked)

module DataMem #(parameter W=8, A=8) (				// do not change W=8
  input                 Clk,
                        Reset,		 // initialization
                        WriteEn,	 // write enable
  input       [A-1:0]   DataAddress, // A-bit-wide pointer to 256-deep memory
  input       [W-1:0]   DataIn,      // W-bit-wide data path, also
  output logic[W-1:0]   DataOut
);

// 8x256 two-dimensional array -- the memory itself
logic [W-1:0] core[2**A];

// reads are combinational
always_comb
  DataOut = core[DataAddress];

// writes are sequential
always_ff @ (posedge Clk)
  /*
  // Reset response is needed only for initialization.
  // (see inital $readmemh above for another choice)
  //
  // If you do not need to preload your data memory with any constants,
  // you may omit the `if (Reset) ... else` and go straight to `if(WriteEn)`
  */

  if(Reset) begin
    // Preload desired constants into data_mem[128:255]
    //core[128] <= 'b1;
  	//core[129] <= 'hff;  
    //core[130] <= 'd64;
  end 
  else if(WriteEn)                    // store
    // Do the actual writes
    core[DataAddress] <= DataIn;
endmodule
