module RevR0 (
	input wire [31:0] D,
	input wire clear,
	input wire clock,
	input wire enable,
	input BAout,

	output wire [31:0] BusMuxIn-R0
);

wire [31:0] Q
always (@posedge clock)
	begin

		if(clear==1'b1)
			Q <= 32'b0;
		else
			Q <= D;
		assign BusMuxIn-R0 = (!BAout) & Q;
	end

endmodule