`timescale 1ns/10ps
module MemSys_tb();

reg clock, clear;
reg read, write, MARin, MDRin;
reg [31:0]BusMuxOut;
wire [31:0]memData;
wire finished;

MemSys memory(
    clock, clear,
    read, write, MARin, MDRin,
    BusMuxOut,
    memData,
    finished
);

reg [3:0]present_state;
reg holdState = 0;

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;

initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) if(!holdState) present_state = present_state + 1;
	
always @(present_state) begin
    holdState = 1;
	case(present_state)
		init: begin
                  read <= 0; write <= 0;
                  MARin <= 0; MDRin <= 0;
                  BusMuxOut <= 0;
                  clear <= 1;
                  #15 clear <= 0;
                  end
		T0: begin
                  // Set address to 5
                  BusMuxOut <= 5;
                  MARin <= 1;
                  #10 MARin <= 0;
                  // Perform read operation
                  BusMuxOut <= 32'hz;
                  read <= 1;
                  MDRin <= 1;
                  @(posedge finished) read <= 0; MDRin <= 0;
                  end
            T1: begin
                  // Set address to 5
                  BusMuxOut <= 5;
                  MARin <= 1; 
                  #10 MARin <= 0;
                  // Perform write operation
                  BusMuxOut <= 32'hABCDEF01;
                  write <= 1;
                  MDRin <= 1; 
                  @(posedge finished) write <= 0; MDRin <= 0;
                  end
		T2: begin
                  // Set address to 32
                  BusMuxOut <= 32;
                  MARin <= 1; 
                  #10 MARin <= 0;
                  // Perform write operation
                  BusMuxOut <= 32'h12345678;
                  MDRin <= 1;
                  write <= 1;
                  @(posedge finished) write <= 0;
                  #10 read <= 1;
                  @(posedge finished) read <= 0; MDRin <= 0;
		end
	endcase
    holdState = 0;
end
endmodule
