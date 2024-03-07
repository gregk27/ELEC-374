`timescale 1ns/10ps
module RAM_tb();

reg clock;
reg read, write;
reg [8:0]address;
wire [31:0]data_wire;
wire finished;

RAM ram(
   clock,
	read, write,
	address,
	data_wire,
	finished
);

reg [3:0]present_state;
reg [31:0]data;
assign data_wire = data;

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;

initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin
            read <= 0; write <= 0;
            address <= 0;
            data <= 0;
		end
		T0: begin
            address <= 5;
            data <= 32'hABCDEF01;
            #5 write <= 1;
            #10 write <= 0;
		end
		T1: begin
            address <= 5;
            data <= 32'hz;
            #5 read <= 1;
            #10 read <= 0;
		end
		T2: begin
            address <= 32;
            data <= 32'h12345678;
            #5 write <= 1;
			   @(posedge finished) write <= 0;
            #5 read <= 1;
		end
	endcase
end
endmodule
