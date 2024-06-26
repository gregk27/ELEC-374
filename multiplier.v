module multiplier(
    input wire clock,
    input wire start, 
    input wire [31:0] multiplicand,
    input wire [31:0] multiplier,
    output wire [31:0] product_lo,
    output wire [31:0] product_hi,
    output reg finished
);

reg [63:0] product;
reg [32:0] extended_multiplier;
reg [5:0] count;

reg [31:0] multiplicand_pos;

initial finished <= 0;

always @(posedge clock, posedge start) begin
	if(start) begin
		//intilize the product and extended multiplier
   		product <= 64'd0; 
		extended_multiplier <= {multiplier, 1'b0};
		multiplicand_pos <= multiplicand[31] ? -multiplicand : multiplicand;
    	count <= 6'd0;
		count <= 0;
		finished <= 0;
	end else if(count != 32) begin
		case (extended_multiplier[2:0])
			3'b001, 3'b010: product = product + ({32'b0, multiplicand_pos} << count);
            	3'b011: product = product + ({32'b0, multiplicand_pos} << (count + 1));
            	3'b100: product = product - ({32'b0, multiplicand_pos} << (count + 1));
            	3'b101, 3'b110: product = product - ({32'b0, multiplicand_pos} << count);

            	default: ;
        endcase
        	extended_multiplier = extended_multiplier >> 2;
        	count = count + 2;
	end else if (count >= 32 && !finished) begin
		if (multiplicand[31])
			product <= -product;
		finished <= 1;
	end
	
end

assign product_lo = product[31:0];
assign product_hi =product[63:32];


endmodule
