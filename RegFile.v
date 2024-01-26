module RegFile(
	input wire clock, clear,
	input wire RF_en,
	input wire [3:0]RF_select,
	input wire [31:0]dataIn,
	output wire [31:0]dataOut
);

// One-hot encoding for selected register, when RF_en is 1
wire [15:0]enable = RF_en << RF_select;

// Array of 32-bit wires, one for each register
wire [31:0]regOuts[15:0];

// Actual output is selected from above
assign dataOut = regOuts[RF_select];

// Generate registers procedurally since it's a pain
genvar i;
generate
	for(i = 0; i < 16; i=i+1) begin : registers
		register r(clear, clock, enable[i], dataIn, regOuts[i]);
	end
endgenerate

endmodule