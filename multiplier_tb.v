`timescale 1ns/10ps

module multiplier_tb();

reg clk;
reg [3:0] present_state;
reg [31:0] multiplicand, multiplier;
wire [31:0] product_lo, product_hi;

//create the multiplier

multiplier uut (
	.clk(clk),
	.multiplicand(multiplicand),
	.multiplier(multiplier),
	.product_lo(product_lo),
	.product_hi(product_hi)
);

initial begin 
clk = 0;
forever #5 clk = ~clk;
end

initial begin

	multiplicand <= 32'd0;
	multiplier <= 32'd0;
	
	#10;
	
	multiplicand <= 32'd2;
	multiplier <= 32'd4;
	
	#20;
	
	$display("Result %d%d", product_hi, product_lo);
	
	#10
	$finish;
	 
	
	
end

endmodule 
