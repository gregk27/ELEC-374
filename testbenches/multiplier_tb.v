`timescale 1ns/10ps
module multiplier_tb();

reg clock;
reg [3:0] present_state;

reg start;
reg [31:0]multiplicand;
reg [31:0]multiplier;
wire [31:0]product_lo;
wire [31:0]product_hi;
wire finished;

reg [31:0] expectedProduct;


multiplier mul(
	clock,
	start,
	multiplicand,
	multiplier,
	product_lo,
	product_hi,
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
			multiplier <= 4; multiplicand <= 2;
			expectedProduct <= 8; 
			#0 start <= 1;
			#5 start <= 0;
		end
		T0: begin
			multiplier <= 27; multiplicand <= -8;
			expectedProduct <= -216; 
			#0 start <= 1;
			#5 start <= 0;
		end
		T1: begin
			multiplier <= -14; multiplicand <= 4;
			expectedProduct <= -56; 
			#0 start <= 1;
			#5 start <= 0;
		end
		T2: begin
			multiplier <= -10; multiplicand <= -8;
			expectedProduct <= 80; 
			#0 start <= 1;
			#5 start <= 0;
		end
	endcase
end
endmodule
