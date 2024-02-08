`timescale 1ns/10ps
module datapath_tbv2();
reg clock, clear, tbIn;
// Bus input selection lines (device output -> bus input)
reg RFout, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout;
// Register write enable lines
reg RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin;

reg [3:0]RFSelect;

reg[31:0] BusMuxInTB;

// alu requirments
reg [5:0]opSelect;
reg start;
wire finished;
// Memory Controls
reg read, MDRin, MDRout;
reg [31:0]Mdatain;
DataPath DP(
	clock, clear,
	RFout, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout,
	RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin,	
	RFSelect,
	tbIn, BusMuxInTB,

   //alu signals
   opSelect, start, finished,
	read, MDRin, MDRout, Mdatain
);


reg [7:0] present_state;
parameter init = 8'd1, T0 = 8'd2, T1 = 8'd3, T2 = 8'd4, T3 = 8'd5, T4 = 8'd6;
			 
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
            start <= 0;
		end
		T0: begin
			BusMuxInTB <= 32'd5;    // 5 in R2    
			tbIn <= 1;
			RFSelect <= 2;
			RFin <= 1;
			#15 tbIn <= 0; RFin <= 0;
		end
		T1: begin
			RFSelect <= 2;
         RFout <= 1; // feed R2 into Ry
			tbIn <= 0;
			RYin <= 1;
			#15 tbIn <= 0; RYin <= 0; RFout <= 0;
		end
		T2: begin
			BusMuxInTB <= 32'd4;    // 4 in R3    
			tbIn <= 1;
			
			RFSelect <= 3;
			RFin <= 1;
			#15 tbIn <= 0; RFin <= 0;
		end
		T3: begin
            opSelect = 5'b00100;
			RFSelect <= 3;
			RFout <= 1;
			#15 RFout <= 0;
			
			RZin <= 1;
         #1 start <= 1;
			@(negedge clock) #1 start <= 0;
			@(posedge finished) @(posedge clock) #1 RZin <= 0;
		end
		T4: begin 
			RZLOout <= 1;
		end
	endcase
end
endmodule