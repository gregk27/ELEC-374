module ALU(
	input wire clock,
	input wire [5:0] opSelect,
	input wire [31:0] A,
	input wire [31:0] B,
	output reg [64:0] out,
	output reg finished
);

initial finished <= 0;

parameter
	NOT	= 5'b00001,
	AND	= 5'b00010,
	OR 	= 5'b00011,
	// LSB used as sub flag, 2nd bit used as negate flag
	ADD	= 5'b00100,
	SUB	= 5'b00101,
	NEG	= 5'b00111,
	MUL	= 5'b01000,
	DIV 	= 5'b01001,
	//  Shifts are encoded as 1 1 Arith Rot Left
	SHL 	= 5'b11000,
	SHR 	= 5'b11001,
	ROL 	= 5'b11010,
	ROR 	= 5'b11011,
	SHRA 	= 5'b11100,
	SHLA 	= 5'b11101;
	
always @(A, B, opSelect) begin
	finished <= 0;
	case (opSelect)
		NOT: out <= ~A; finished <= 1;
		AND: out <= A&B; finished <= 1;
		OR : out <= A|B; finished <= 1;
	endcase
end
endmodule