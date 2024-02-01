`timescale 1ns/10ps
module multiplier_tb();

reg clock;
reg [3:0] present_state;

reg [31:0]multiplicand, multiplier;

wire [31:0] product_lo, product_hi;

booth_multiplier booth_mul_inst(
    .multiplicand(multiplicand);
    .multiplier(multiplier);
    .product_hi(product_hi);
    .product_lo(product_lo);
);



parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;
			 
initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;
	
always @(present_state) begin
	case(present_state)
		init: begin
            multiplicand <= 0;
			multiplier <= 0;
		end
		T0: begin
			multiplicand <= 32'd2;
            multiplier <= 32'd4;
            //should see an 8 in product lo
		end
		T1: begin
			multiplicand <= 32'd10;
            multiplier <= 32'd4;
            //should see an 40 split between product lo and hi
		end
		T2: begin
			multiplicand <= 32'd-2;
            multiplier <= 32'd4;
            //should see an -8 in product lo
		end
	endcase
end
endmodule