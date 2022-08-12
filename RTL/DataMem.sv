// Create Date:    2017.01.25
// Revision:       2022.05.04  made data width parametric
// Design Name:
// Module Name:    DataMem
// single address pointer for both read and write
// CSE141L
module DataMem #(parameter W=8, D=8)(
  input               Clk,
                      Reset,	   // again, note use of Reset for preloads
                      WriteEn,
  input       [D-1:0] DataAddress, // 8-bit-wide pointer to 256-deep memory
  input       [W-1:0] DataIn,	   // 8-bit-wide data path, also
  output logic[W-1:0] DataOut);

  logic [W-1:0] Core[2**D];		   // 8x256 two-dimensional array -- the memory itself

  always_comb                      // reads are combinational
    DataOut = Core[DataAddress];

/* optional way to plant constants into DataMem at startup
    initial 
      $readmemh("dataram_init.list", Core);
*/
  always_ff @ (posedge Clk)		   // writes are sequential
/*( Reset response is needed only for initialization (see inital $readmemh above for another choice)
  if you do not need to preload your data memory with any constants, you may omit the if(Reset) and the else,
  and go straight to if(WriteEn) ...
*/
    if(Reset) begin
// you may initialize your memory w/ constants, if you wish
      for(int i=128;i<256;i++)
	    Core[  i] <= 0;
        Core[ 16] <= 254;          // overrides the 0  ***sample only***
        Core[244] <= 5;			   //    likewise
	end
    else if(WriteEn) 
      Core[DataAddress] <= DataIn;

endmodule
