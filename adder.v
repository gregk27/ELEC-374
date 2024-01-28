// Carry-Lookahead Adder
module adder(input [31:0]A, input [31:0]B, output [31:0] Result);

reg [31:0] Results;
reg [31:0] Generate;
reg [32:0] Propogate;
reg [33:0] LocalCarry;

assign Result = Results;

integer i;

always@(A or B)
	begin
		LocalCarry = 32'd0;
		// Perform these operations first as they can run in parallel
		Generate = A & B;
		Propogate = A | B;
		for(i = 0; i < 32; i = i + 1)
		begin
				LocalCarry[i+1] = (Generate[i] | (Propogate[i] & LocalCarry[i]));
				Results[i] = A[i] ^ B[i] ^ LocalCarry[i];
		end
end
endmodule
