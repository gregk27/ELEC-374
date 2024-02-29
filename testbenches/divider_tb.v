`timescale 1ns/10ps
module divider_tb();

reg clock;
reg [3:0] present_state;

reg start;
reg [31:0]dividend;
reg [31:0]divisor;
wire [31:0]quotient;
wire [31:0]remainder;
wire finished;

reg [31:0] expectedQuotient;
reg [31:0] expectedRemainder;

divider div(
	clock,
	start,
	dividend,
	divisor,
	quotient,
	remainder,
	finished
);


parameter init = 4'd0, T0 = 4'd1, T1 = 4'd2, T2 = 4'd3;
			 
initial begin clock = 0; present_state = 4'd0; end
always #5 clock = ~clock;
// Tick over when the divider reports finished
always @ (posedge finished) #15 present_state = present_state + 1;


always @(present_state) begin
	case(present_state)
		init: begin
			dividend <= 4; divisor <= 2;
			expectedQuotient <= 2; expectedRemainder <= 0;
			#0 start <= 1;
			#5 start <= 0;
		end
		T0: begin
			dividend <= 27; divisor <= -8;
			expectedQuotient <= -3; expectedRemainder <= 3;
			#0 start <= 1;
			#5 start <= 0;
		end
		T1: begin
			dividend <= -14; divisor <= 4;
			expectedQuotient <= -3; expectedRemainder <= 2;
			#0 start <= 1;
			#5 start <= 0;
		end
		T2: begin
			dividend <= -10; divisor <= -8;
			expectedQuotient <= 1; expectedRemainder <= 2;
			#0 start <= 1;
			#5 start <= 0;
		end
	endcase
end
endmodule