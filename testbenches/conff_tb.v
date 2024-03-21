`timescale 1ns/10ps
module conff_tb();

reg clock;
reg [3:0] present_state;
reg [31:0]IR;
wire [31:0]BUS;
wire D;

CON_Logic conf(
	IR, BUS, D
);

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;
			 
initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin//testing branch if zero
            IR<=32'b10011000000000000000000000000000;
            BUS<=32'b10011000000000000000000000000000;
		end
		T0: begin//testing branch if nonzero
            IR<=32'b10011000001000000000000000000000;
            IR<=32'b10011000001000000000000000000000;
		end
		T1: begin//testing branch if positive
            IR<=32'b10011000010000000000000000000000;
            BUS<=32'b10011000010000000000000000000000;
		end
		T2: begin//testing branch if negtive
            IR<=32'b10011000011000000000000000000000;
            BUS<=32'b10011000011000000000000000000000;

		end
	endcase
end
endmodule