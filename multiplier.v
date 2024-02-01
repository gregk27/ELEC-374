module multiplier(multiplicand, multiplier, product_lo, product_hi);

input [31:0] multiplicand, multiplier;
output [31:0] product_lo, product_hi;

reg[31: 0] acc, product_hi;
reg[32:0] extended_multiplier;
integer i;

always @(multiplicand or multiplier) begin
    acc = 32'd0;
    product_hi = 32'd0;
    extended_multiplier = {multiplier, 1'b0};

    for(i = 0; i < 32; i = i + 1)
    begin
        case (extended_multiplier[1:0])
            2'b01:
            begin
                {product_hi, acc} = {product_hi, acc} + {32'b0, multiplicand}; //might have to send to the adder
            end
            2'b10:
            begin
                {product_hi, acc} = {product_hi, acc} - {32'b0, multiplicand}; //might have to send to the adder
            end
            
            default: ; //Do nothing for 00 or 11
        endcase
        //arithmetic right shift to shift the accumulater reg and extended multiplier
        //maintains the sign of the 2 bit complement
        {product_hi, acc, extended_multiplier} = {product_hi[31], product_hi, acc, extended_multiplier} >> 1;

    end
    
end
assign product_lo = acc;//Output the lower 32 bits

//the upper 32 bits remains in product_hi register outside of the module
//the value can be accessed after the multiplication is complete
endmodule
