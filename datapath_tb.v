`timescale 1ns/10ps
module datapath_tb();
reg clock, clear, tbIn;
// Bus input selection lines (device output -> bus input)
reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout;
// Register write enable lines
reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin;

reg[31:0] BusMuxInTB;

DataPath DP(
	clock, clear,
	R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout,
	R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin,
	tbIn, BusMuxInTB
);

reg [7:0] present_state;
parameter init = 8'd1, T0 = 8'd2, T1 = 8'd3, T2 = 8'd4, T3 = 8'd5;
			 
initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;


always @(present_state) begin
	case(present_state)
		init: begin
			clear <= 1;
			#15 clear <= 0;
			tbIn <= 0;
			R2in <= 0;
			R2out <= 0;
			BusMuxInTB <= 32'd0;
		end
		T0: begin
			BusMuxInTB <= 32'd5;
			tbIn <= 1;
			R2in <= 1;
			#15 tbIn <= 0; R2in <= 0;
		end
		T1: begin
			BusMuxInTB <= 32'd12;
			tbIn <= 1;
			R3in <= 1;
			#15 tbIn <= 0; R3in <= 0;
		end
		T2: begin
			R2out <= 1;
			#15 R2out <= 0;
		end
		T3: begin
			R3out <= 1;
			#15 R3out <= 0;
		end
	endcase
end
endmodule