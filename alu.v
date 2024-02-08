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
	//  Shifts are encoded as 1 1 Arith Rot Right
	SHL 	= 5'b11000,
	SHR 	= 5'b11001,
	ROL 	= 5'b11010,
	ROR 	= 5'b11011,
	SHLA 	= 5'b11100,
	SHRA 	= 5'b11101;

// Inernal status register used to indicate setup phase
reg setup;


reg subtract;
reg [31:0] adder_out;
reg [31:0] negate_mux;
adder add(negate_mux, B, subtract, adder_out);


wire shift_right;
wire shift_rotation;
reg [31:0] shift_out;
shifter shift(A, B, right, rotate, shift_out);
	
always @(A, B, opSelect) begin
	finished <= 0;
	setup <= 1;
end

// Run on negedge clock to have values ready by the positive edge
always @(negedge clock) begin
	if(setup) begin
		setup <= 0;
		// First run setup to configure the inputs and outputs to perform the calculation
		case (opSelect)
			NOT:  begin out <= ~A; finished <= 1; end
			AND:  begin out <= A&B; finished <= 1; end
			OR : begin out <= A|B; finished <= 1; end
			ADD, SUB, NEG: begin
				// Subtract based on bit 0
				subtract <= opSelect[0];
				// Mux in a 0 if negate bit is high
				negate_mux <= opSelect[1] ? 0 : A;
			end
			SHL, SHR, ROL, ROR: begin
				// Right flat in bit 0
				right <= opSelect[0];
				// Rotate flag in bit 1
				rotate <= opSelect[1];
			end
		endcase
	end
	else begin
		// Once setup is complete, monitor outputs for completion (if applicable)
		case (opSelect)
			ADD, SUB, NEG: begin
				// Adder runs in 1 cycle, so always ready
				out <= adder_out;
				finished <= 1;
			end
			SHL, SHR, ROL, ROR: begin
				// Shifter runs in 1 cycle, so always ready
				out <= shift_out;
				finished <= 1;
			end
		endcase
	end
end

// Update output and finished as the data becomes available
always @(negedge clock) begin
	if(!setup) begin

	end
end

endmodule