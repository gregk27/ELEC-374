`timescale 1ns/10ps
module booth_multiplier_tb();

reg clock;
reg [3:0] present_state;

reg [31:0] multiplicand, multiplier;
reg [31:0] product_lo, product_hi;

// Expected results are not directly wired in the test bench,
// but you can manually verify them based on the $display outputs.
// reg [63:0] expectedResult; // Not directly used, for manual verification

// Instantiate the Booth Multiplier Module
multiplier booth_mul_inst(
    .multiplicand(multiplicand), 
    .multiplier(multiplier), 
    .product_lo(product_lo), 
    .product_hi(product_hi)
);

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4;
			 
initial begin
    clock = 0;
    present_state = init;
end

// Generate clock signal
always #10 clock = ~clock;

// State transitions on the negative edge of the clock
always @(negedge clock) begin
    present_state = present_state + 1;
end

// Define the behavior for each state
always @(present_state) begin
    case(present_state)
        init: begin
            multiplicand <= 0; multiplier <= 0;
        end
        T0: begin
            // Test case 1
            multiplicand <= 32'd3; multiplier <= 32'd2; // 3 * 2 = 6
            
        end
        T1: begin
            // Test case
            multiplicand <= 32'd10; multiplier <= 32'b1011; //-5 * 10 = -50
            
        end
        T2: begin
            // Test case 3
            multiplicand <= 32'b1001; multiplier<= 32'b1010; // -4 * -6 == 24
			end
         
	endcase
end
endmodule