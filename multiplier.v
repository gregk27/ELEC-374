module multiplier(multiplicand, multiplier, product_lo, product_hi);

input [31:0] multiplicand, multiplier;
output [31:0] product_lo, product_hi;

reg [63:0] product; // Use a single product register to simplify operations
reg [31:0] product_hi, acc;
reg [32:0] extended_multiplier;
integer i;

always @(multiplicand or multiplier) begin
    acc = 32'd0;
    product_hi = 32'd0;
    extended_multiplier = {multiplier, 1'b0}; // Extend multiplier by 1 bit for bit-pair recoding

    for(i = 0; i < 32; i = i + 1) begin
        case (extended_multiplier[2:0])
            3'b001, 3'b010: begin
                product = product + {32'b0, multiplicand}; // +1
            end
            3'b011: begin
                product = product + {31'b0, multiplicand, 1'b0}; // +2
            end
            3'b100: begin
                product = product - {31'b0, multiplicand, 1'b0}; // -2
            end
            3'b101, 3'b110: begin
                product = product - {32'b0, multiplicand}; // -1
            end
            
            default: ; // Do nothing for 000, 111
        endcase
        // maintain sign
        product = {product[63], product} >> 1;
        extended_multiplier = extended_multiplier >> 1; // Align extended_multiplier for next iteration
    end
    
    product_hi = product[63:32];
    acc = product[31:0];
end

assign product_lo = acc; // Output the lower 32 bits
assign product_hi = product_hi; // Output the upper 32 bits

endmodule
