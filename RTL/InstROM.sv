// Module Name: InstFetch
// Project Name: CSE141L
// Description: instruction ROM module for use with InstFetch

module InstROM #(parameter A=10, W=9) (
	input logic [A-1:0] InstAddress,
	output logic[W-1:0] InstOut
);
	// declare 2-dimensional array, W bits wide, 2**A words deep
	logic[W-1:0] inst_rom[2**A];
	assign InstOut = inst_rom[InstAddress];
 
	// use readmemb to read ascii 0 and 1 representation of binary values from text file
	initial begin
		$readmemb("machine_code.txt",inst_rom);
	end

endmodule
