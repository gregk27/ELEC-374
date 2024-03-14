module ThirtyTwoBitFlipFlop (
	input wire [31:0] D,
	input wire clear,
	input wire clock,
	input wire enable,

	output wire [31:0] Q
);

always (@posedge clock)
	begin

		if(clear==1'b1)
			Q <= 32'b0;
		else
			Q <= D;
	end
	
