// Module Name: Flags
// Project Name: CSE141L
// Description: flag registers

module Flags (
    input logic Clk, Reset, WriteEn, start,
    input logic Zero_in, Done_in,
    output logic Zero_out, Done_out
);

    logic Zero, Done;

    assign Zero_out = Zero;
	assign Done_out = Done;

    always_ff @(posedge Clk) begin
        if(Reset) begin
            Zero <= 'b0;
			Done <= 'b1; // default Done to halt machine
        end
        else if (start) begin
			Zero <= Zero_in;
			Done <= 'b0;
		end
		else if (WriteEn) begin
			Zero <= Zero_in;
			Done <= Done_in;
		end
    end

endmodule