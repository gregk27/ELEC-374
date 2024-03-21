module ALU(
	input wire clock,
	input wire [5:0] opSelect,
	input wire [31:0] A,
	input wire [31:0] B,
	input wire start,
	output reg [63:0] out,
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

// Cache the value coming from the bus as it may be corrupted when outputs change, causing issues with some modules
reg [31:0] bCache;
	
reg subtract;
wire [31:0] adder_out;
reg [31:0] adder_mux_A, adder_mux_B;
adder add(adder_mux_A, adder_mux_B, subtract, adder_out);


reg shift_right;
reg shift_rotation;
reg shift_arithmetic;
wire [31:0] shift_out;
shifter shift(A, bCache[7:0], shift_right, shift_rotation, shift_arithmetic, shift_out);


reg mul_start;
wire mul_finished;
wire [31:0] mul_lo, mul_hi;
multiplier mul(clock, mul_start, A, bCache, mul_lo, mul_hi, mul_finished);

reg div_start;
wire div_finished;
wire [31:0] quotient, remainder;
divider div(clock, div_start, A, bCache, quotient, remainder, div_finished);

reg canFinish;

// Run on negedge clock to have values ready by the positive edge
// NOTE: This breaks the finished signal, for now the ALU is clocked only
always @(clock, adder_out, mul_finished, div_finished) begin
	// NOTE: This breaks the finished signal, for now the ALU is clocked only
	canFinish = 1;
	// If start is asserted, clear finished flag and begin setup this cycle
	if(start && !clock) begin
		bCache <= B;
		finished = 0;
		// First run setup to configure the inputs and outputs to perform the calculation
		case (opSelect)
			NOT:  begin out <= ~A; finished <= 1; end
			AND:  begin out <= A&B; finished <= 1; end
			OR : begin out <= A|B; finished <= 1; end
			ADD, SUB, NEG: begin
				// Subtract based on bit 0
				subtract <= opSelect[0];
				// Mux in adjusted values if negate bit is high
				adder_mux_A <= opSelect[1] ? 0 : A;
				adder_mux_B <= opSelect[1] ? A : B;
			end
			MUL: mul_start <= 1;
			DIV: div_start <= 1;
			SHL, SHR, ROL, ROR, SHRA, SHLA: begin
				// Right flat in bit 0
				shift_right <= opSelect[0];
				// Rotate flag in bit 1
				shift_rotation <= opSelect[1];
				// Arithmetic flag in bit 2
				shift_arithmetic <= opSelect[2];
			end
		endcase
	end
	if (canFinish) begin
		// Once setup is complete, monitor outputs for completion (if applicable)
		case (opSelect)
			ADD, SUB, NEG: begin
				// Adder runs in 1 cycle, so always ready
				out <= adder_out;
				finished <= 1;
			end
			MUL: begin
				// Pull start flag low so mul can run
				mul_start <= 0;
				// Copy over current values
				out <= {mul_hi, mul_lo};
				finished <= mul_finished;
			end
			DIV: begin
				// Pull start flag low so div can run
				div_start <= 0;
				// Copy over current values
				out <= {remainder, quotient};
				finished <= div_finished;
			end
			SHL, SHR, ROL, ROR, SHRA, SHLA: begin
				// Shifter runs in 1 cycle, so always ready
				out <= shift_out;
				finished <= 1;
			end
		endcase
	end
end

endmodule