`timescale 1ns/10ps
module ALU_tb();

// Operation selects from alu
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


reg clock;
reg [4:0] present_state;

reg [0:5]opSelect;
reg [31:0]A;
reg [31:0]B;
reg start;
wire [63:0]out;
wire finished;

reg [63:0] expectedOut;
wire[31:0] out_32 = out[31:0];
wire[31:0] expectedOut_32 = expectedOut[31:0];

ALU alu(
	clock,
	opSelect,
	A,
	B,
	start,
	out,
	finished
);


parameter init = 5'd0,
	T_NOT  = 5'd1,
	T_AND  = 5'd2,
	T_OR   = 5'd3,
	T_ADD  = 5'd4,
	T_SUB  = 5'd5,
	T_NEG  = 5'd6,
	T_MUL  = 5'd7,
	T_DIV  = 5'd8,
	T_SHL  = 5'd9,
	T_SHR  = 5'd10,
	T_ROL  = 5'd11,
	T_ROR  = 5'd12,
	T_SHLA = 5'd13,
	T_SHRA = 5'd14;

// Manually tick over from init to NOT, as it won't happen automatically
initial begin clock = 0; present_state = 5'd0; #1 present_state = 5'd1; end
always #5 clock = ~clock;
// Tick over when the divider reports finished
always @ (posedge finished) #5 present_state = present_state + 1;


always @(present_state) begin
	case(present_state)
		T_NOT: begin
			opSelect <= NOT;
			A <= {32{1'b1}}; B <= 0;
			expectedOut <= 0;
			// Assert start until negedge passed
			#1 start <= 1;
			@(negedge clock) #1 start <= 0;
		end
		T_AND: begin
			opSelect <= AND;
			A <= {16{1'b1}}; B <= {16{2'b10}};
			expectedOut <= {8{2'b10}};
			// Assert start until negedge passed
			#1 start <= 1;
			@(negedge clock) #1 start <= 0;
		end
		T_OR: begin
			opSelect <= OR;
			A <= {16{1'b1}}; B <= {16{2'b10}};
			expectedOut <= {{8{2'b10}}, {16{1'b1}}};
			// Assert start until negedge passed
			#1 start <= 1;
			@(negedge clock) #1 start <= 0;
		end
	endcase
end
endmodule