`timescale 1ns/10ps
module adder_tb();

reg clock;
reg [3:0] present_state;

reg [31:0]a, b;
wire [31:0]result;

reg [31:0] expectedResult;

adder add(
	a, b, result
);

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;
			 
initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin
			a <= 0; b <= 0;
			expectedResult <= 0;
		end
		T0: begin
			a <= 25; b <= 40;
			expectedResult <= 65;
		end
		T1: begin
			a <= -50; b <= -10;
			expectedResult <= -60;
		end
		T2: begin
			a <= -12; b <= 25;
			expectedResult <= 13;
		end
	endcase
end
endmodule
