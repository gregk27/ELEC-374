`timescale 1ns/10ps
module datapath_tb();
reg clock, clear, tbIn;
// Bus input selection lines (device output -> bus input)
reg RFout, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout;
// Register write enable lines
reg RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin;

reg [3:0]RFSelect;

reg[31:0] BusMuxInTB;

DataPath DP(
	clock, clear,
	RFout, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout,
	RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin,
	RFSelect,
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
			RFin <= 0;
			RFout <= 0;
			RFSelect <= 0;
			BusMuxInTB <= 32'd0;
		end
		T0: begin
			BusMuxInTB <= 32'd5;
			tbIn <= 1;
			RFin <= 1;
			RFSelect <= 2; // Register R2
			#15 tbIn <= 0; RFin <= 0;
		end
		T1: begin
			BusMuxInTB <= 32'd12;
			tbIn <= 1;
			RFin <= 1;
			RFSelect <= 3; // Register R3
			#15 tbIn <= 0; RFin <= 0;
		end
		T2: begin
			RFout <= 1;
			RFSelect <= 2; // Register R2
			#15 RFout <= 0;
		end
		T3: begin
			RFout <= 1;
			RFSelect <= 3; // Register R3
			#15 RFout <= 0;
		end
	endcase
end
endmodule