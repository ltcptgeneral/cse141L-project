// Module Name: ALU
// Project Name: CSE141L
// Description: register file

module RegFile #(parameter W=8, D=4)(		 // W = data path width (leave at 8); D = address pointer width
	input Clk, Reset, WriteEn,
	input [D-1:0] RaddrA, RaddrB, Waddr, // read anad write address pointers
	input [W-1:0] DataIn, // data to be written
	input Zero_in, Done_in, // since flags are stored in register file, need this as an input
	output logic [W-1:0] DataOutA, DataOutB, // data to read out
	output logic Zero_out, Done_out // output of zero and done flags
);

	logic [W-1:0] Registers[2**D]; // 2^D registers of with W
	logic Zero, Done;

	// combination read
	assign DataOutA = Registers[RaddrA];
	assign DataOutB = Registers[RaddrB];
	assign Zero_out = Zero;
	assign Done_out = Done;

	// sequential (clocked) writes 
	always_ff @ (posedge Clk) begin
		if (Reset) begin // reset all registers to 0 when reset
			for(int i=0; i<2**D; i++) begin
				Registers[i] <= 'h0;
			end
			Zero <= 0;
			Done <= 1; // default Done to halt machine
		end
		else if (WriteEn) begin
			Registers[Waddr] <= DataIn;
			Zero <= Zero_in;
			Done <= Done_in;
		end
	end

endmodule
