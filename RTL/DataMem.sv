// Module Name: DataMem
// Project Name: CSE141L
// data memory, uses block RAM

module DataMem #(parameter W=8, A=8)(
	input logic Clk, // clock
	input logic WriteEn, // '1' indicates write and '0' indicates read
	input logic[W-1:0] DataIn, //data to be written
	input logic[A-1:0] DataAddress, //address for write or read operation
	output logic[W-1:0] DataOut //read data from memory
);
	// Two dimensional memory array
	logic [W-1:0] core[2**A];
	logic [A-1:0] read_addr_t;
	// Synchronous write
	always_ff@(negedge Clk) begin
		if(WriteEn) core[DataAddress] <= DataIn;
		read_addr_t = DataAddress;
	end
	// asynchronous read
	assign DataOut = core[read_addr_t];
endmodule
