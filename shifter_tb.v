`timescale 1ns/10ps
module shifter_tb();

reg clock;
reg [3:0] present_state;

reg [31:0]num;
reg [7:0]shift;
reg right;
reg rotate;
reg arithmetic;
wire [31:0]result;

reg [31:0] expectedResult;

shifter shiftr(
	num, shift, right, rotate, arithmetic, result
);

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4, T3 = 4'd5;
			 
initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin
			num <= 0; right <= 0; rotate <= 0; arithmetic <= 0;
			#0 shift <= 0; expectedResult <= 0;
			#5 shift <= 1; expectedResult <= 0;
			#5 shift <= 4; expectedResult <= 0;
			#5 shift <= 10; expectedResult <= 0;
		end
		T0: begin
			num <= 32'b101010; right <= 0; rotate <= 0; arithmetic <= 0;
			#0 shift <= 0; expectedResult <= 32'b101010;
			#5 shift <= 1; expectedResult <= 32'b1010100;
			#5 shift <= 4; expectedResult <= 32'b1010100000;
			#5 shift <= 10; expectedResult <= 32'b1010100000000000;
		end
		T1: begin
			num <= 32'b110011; right <= 1; rotate <= 0; arithmetic <= 0;
			#0 shift <= 0; expectedResult <= 32'b110011;
			#5 shift <= 1; expectedResult <= 32'b11001;
			#5 shift <= 4; expectedResult <= 32'b11;
			#5 shift <= 10; expectedResult <= 32'b0;
		end
		T2: begin
			num <= 32'b10101000000000000000000000010101; rotate <= 1; arithmetic <= 0;
			#0 right <= 0; shift <= 4; expectedResult <= 32'b10000000000000000000000101011010;
			#5 right <= 0; shift <= 8; expectedResult <= 32'b00000000000000000001010110101000;
			#5 right <= 1; shift <= 3; expectedResult <= 32'b10110101000000000000000000000010;
			#5 right <= 1; shift <= 7; expectedResult <= 32'b00101011010100000000000000000000;
		end
		T3: begin
			num <= 32'b10101000000000000000000000010101; rotate <= 0; arithmetic <= 1;
			#0 right <= 0; shift <= 4; expectedResult <= 32'b10000000000000000000000101010000;
			#5 right <= 0; shift <= 8; expectedResult <= 32'b00000000000000000001010100000000;
			#5 right <= 1; shift <= 3; expectedResult <= 32'b11110101000000000000000000000010;
			#5 right <= 1; shift <= 7; expectedResult <= 32'b11111111010100000000000000000000;
		end
	endcase
end
endmodule