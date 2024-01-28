// Carry-Lookahead Adder
module adder(input [31:0]A, input [31:0]B, input subtract, output [31:0]Result);

reg [31:0] Results;
reg [31:0] Generate;
reg [32:0] Propogate;
reg [33:0] LocalCarry;

reg [31:0] Btmp;

assign Result = Results;

integer i;

always@(A or B or subtract)
	begin
		// Carry in first bit based on subtract flag
		LocalCarry = 32'd0 | subtract;
		// Negate B based on subtract bit
		Btmp = B ^ {32{subtract}};
		// Perform these operations first as they can run in parallel
		Generate = A & Btmp;
		Propogate = A | Btmp;
		for(i = 0; i < 32; i = i + 1)
		begin
				LocalCarry[i+1] = (Generate[i] | (Propogate[i] & LocalCarry[i]));
				Results[i] = A[i] ^ Btmp[i] ^ LocalCarry[i];
		end
end
endmodule
