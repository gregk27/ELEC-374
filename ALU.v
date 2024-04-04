module ALU(
	input wire clock,
	input wire [4:0] opcode,
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

// Output register for internally executed bitwise ops
reg [31:0]internal_out;

// Recode the spec opcodes to the ALU select codes which are optimized for bit flags
reg [4:0]_aluSelect;
always @(opcode) begin
	case (opcode)
		5'b00011: _aluSelect <= ADD;
		5'b00100: _aluSelect <= SUB;
		5'b00101: _aluSelect <= SHR;
		5'b00110: _aluSelect <= SHRA;
		5'b00111: _aluSelect <= SHL;
		5'b01000: _aluSelect <= ROR;
		5'b01001: _aluSelect <= ROL;
		5'b01010: _aluSelect <= AND;
		5'b01011: _aluSelect <= OR;
		5'b01100: _aluSelect <= ADD; // addi
		5'b01101: _aluSelect <= AND; // andi
		5'b01110: _aluSelect <= OR;  // ori
		5'b01111: _aluSelect <= MUL;
		5'b10000: _aluSelect <= DIV;
		5'b10001: _aluSelect <= NEG;
		5'b10010: _aluSelect <= NOT;
		default:  _aluSelect <= {5{1'dx}};
endcase
end

// Run on negedge clock to have values ready by the positive edge
always @(clock) begin
	// If start is asserted, clear finished flag and begin setup this cycle
	if(start && !clock) begin
		bCache <= B;
		// First run setup to configure the inputs and outputs to perform the calculation
		case (_aluSelect)
			NOT:  begin internal_out <= ~B;  end
			AND:  begin internal_out <= A&B; end
			OR :  begin internal_out <= A|B; end
			ADD, SUB, NEG: begin
				// Subtract based on bit 0
				subtract <= _aluSelect[0];
				// Mux in adjusted values if negate bit is high
				adder_mux_A <= _aluSelect[1] ? 0 : A;
				adder_mux_B <= _aluSelect[1] ? B : B;
			end
			MUL: begin mul_start <= 1; end
			DIV: begin div_start <= 1; end
			SHL, SHR, ROL, ROR, SHRA, SHLA: begin
				// Right flat in bit 0
				shift_right <= _aluSelect[0];
				// Rotate flag in bit 1
				shift_rotation <= _aluSelect[1];
				// Arithmetic flag in bit 2
				shift_arithmetic <= _aluSelect[2];
			end
		endcase
	end
	// Turn off the mul/div start signals when the input signal has changed
	if (!start) begin
		mul_start <= 0;
		div_start <= 0;
	end
end

always @(start, internal_out, adder_out, mul_finished, div_finished, shift_out) begin
	if (start) begin
		finished <= 0;
	end else begin
		// Once setup is complete, monitor outputs for completion (if applicable)
		case (_aluSelect)
			NOT, AND, OR: begin
				// Bitwise run in 1 cycle, so always ready
				out <= internal_out;
				finished <= 1;
			end
			ADD, SUB, NEG: begin
				// Adder runs in 1 cycle, so always ready
				out <= adder_out;
				finished <= 1;
			end
			MUL: begin
				// Pull start flag low so mul can run
				//mul_start <= 0;
				// Copy over current values
				out <= {mul_hi, mul_lo};
				finished <= mul_finished;
			end
			DIV: begin
				// Pull start flag low so div can run
				//div_start <= 0;
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