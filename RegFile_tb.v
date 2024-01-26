module RegFile_tb();


reg clock, clear;
reg RF_en;
reg [3:0]RF_select;
reg [31:0]dataIn;
wire [31:0]dataOut;

RegFile rf(
	clock, clear,
	RF_en,
	RF_select,
	dataIn,
	dataOut
);

reg [3:0]present_state;

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;

initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin
			clear <= 1;
			#10 clear <= 0; RF_en <= 0;
		end
		T0: begin
			RF_select <= 2;
			dataIn <= 1234;
			#5 RF_en <= 1;
			#10 RF_en <= 0;
		end
		T1: begin
			RF_select <= 7;
			dataIn <= 5678;
			#5 RF_en <= 1;
			#10 RF_en <= 0;
		end
		T2: begin
			RF_select <= 2;
		end
	endcase
end
endmodule
