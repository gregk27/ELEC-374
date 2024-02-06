module multiplier(
	input wire clk,
	input wire [31:0] multiplicand,
	input wire [31:0] multiplier,
	output reg [31:0] product_lo,
	output reg [31:0] product_hi
);

// use a 64-bit reg for the product and an extra bit for booth recoding
reg [64:0] product;
reg [32:0] extended_multiplier;
integer i;

always @(posedge clk) begin
	product <= 65 'd0; // intilize the product to 0
	product[31:0] <= multiplicand; //place the multiplicand in loweer 32 bits
	extended_multiplier <= {1'b0, multiplier, 1'b0}; //extened the multiplier 
	
	for (i = 0; i < 32; i = i + 2) begin //loop steps by 2 for bit pair recoding
		//Determine action based on the two lsb
		case (extended_multiplier[3:0])
			4'b0001, 4'b0010: product[64:32] <= product[64:32] + multiplicand; //Add multiplicand 
			4'b0100: product[64:32] <= product[64:32] + (multiplicand << 1); //Add 2*multiplicand 
			4'b1011, 4'b1010: product[64:32] <= product[64:32] - multiplicand; //Sub multiplicand 
			4'b1100: product[64:32] <= product[64:32] - (multiplicand << 1); //Sub 2*multiplicand
			
			//No action for 0000 or 1111
			default: ;
		endcase
		
		product <= {product[64], product[64], product[64:2]};
		extended_multiplier <= {extended_multiplier[32], extended_multiplier[32], extended_multiplier[32:2]};
	end 
		
		product_hi <= product[63:32];
		product_lo <= product[31:0];
		end 
		
endmodule 
	
