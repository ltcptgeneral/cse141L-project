// Module Name: RegFile
// Project Name: CSE141L
// Description: register file

module RegFile #(parameter W=8, D=4)(		 // W = data path width (leave at 8); D = address pointer width
	input logic Clk, Reset, WriteEn,
	input logic [D-1:0] RaddrA, RaddrB, Waddr, // read anad write address pointers
	input logic [W-1:0] DataIn, // data to be written
	input logic start, // start signal from testbench
	output logic [W-1:0] DataOutA, DataOutB // data to read out
);

	logic [W-1:0] Registers[2**D]; // 2^D registers of with W

	// combination read
	assign DataOutA = Registers[RaddrA];
	assign DataOutB = Registers[RaddrB];

	// sequential (clocked) writes 
	always_ff @ (posedge Clk) begin
		if (Reset) begin // reset all registers to 0 when reset
			for(int i=0; i<2**D; i++) begin
				Registers[i] <= 'h0;
			end
		end
		else if (start) begin
			Registers[Waddr] <= DataIn;
		end
		else if (WriteEn) begin
			Registers[Waddr] <= DataIn;
		end
	end

endmodule
