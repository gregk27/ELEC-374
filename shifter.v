module shifter(input [31:0]in, input [7:0]shift, input right, input rotate, input arithmetic, output [31:0]out);

reg [31:0]result;
reg [31:0]lowBits;
reg [31:0]highBits;
reg [7:0] shiftTmp;

assign out = result;

always @(*) begin
	
	lowBits = in & {32{right | rotate}};
	// If arithmetic is set, then all high bits should be in[32]
	// SHLA is possible input config, but does normal left shift
	highBits = (in & {32{~right | rotate}}) | {32{right & arithmetic & in[31]}};
	
	shiftTmp = right ? ~shift : shift;

	case(shiftTmp)
	// Positive versions used for LShift, negatives for RShift
		0, 8'b11011110: result = in;
		1, 8'b11011111: result = {highBits[30:0], lowBits[31]};
		2, 8'b11100000: result = {highBits[29:0], lowBits[31:30]};
		3, 8'b11100001: result = {highBits[28:0], lowBits[31:29]};
		4, 8'b11100010: result = {highBits[27:0], lowBits[31:28]};
		5, 8'b11100011: result = {highBits[26:0], lowBits[31:27]};
		6, 8'b11100100: result = {highBits[25:0], lowBits[31:26]};
		7, 8'b11100101: result = {highBits[24:0], lowBits[31:25]};
		8, 8'b11100110: result = {highBits[23:0], lowBits[31:24]};
		9, 8'b11100111: result = {highBits[22:0], lowBits[31:23]};
		10, 8'b11101000: result = {highBits[21:0], lowBits[31:22]};
		11, 8'b11101010: result = {highBits[20:0], lowBits[31:21]};
		12, 8'b11101011: result = {highBits[19:0], lowBits[31:20]};
		13, 8'b11101100: result = {highBits[18:0], lowBits[31:19]};
		14, 8'b11101101: result = {highBits[17:0], lowBits[31:18]};
		15, 8'b11101110: result = {highBits[16:0], lowBits[31:17]};
		16, 8'b11101111: result = {highBits[15:0], lowBits[31:16]};
		17, 8'b11110000: result = {highBits[14:0], lowBits[31:15]};
		18, 8'b11110001: result = {highBits[13:0], lowBits[31:14]};
		19, 8'b11110010: result = {highBits[12:0], lowBits[31:13]};
		20, 8'b11110011: result = {highBits[11:0], lowBits[31:12]};
		21, 8'b11110100: result = {highBits[10:0], lowBits[31:11]};
		22, 8'b11110101: result = {highBits[09:0], lowBits[31:10]};
		23, 8'b11110110: result = {highBits[08:0], lowBits[31:09]};
		24, 8'b11110111: result = {highBits[07:0], lowBits[31:08]};
		25, 8'b11111000: result = {highBits[06:0], lowBits[31:07]};
		26, 8'b11111001: result = {highBits[05:0], lowBits[31:06]};
		27, 8'b11111010: result = {highBits[04:0], lowBits[31:05]};
		28, 8'b11111011: result = {highBits[03:0], lowBits[31:04]};
		29, 8'b11111100: result = {highBits[02:0], lowBits[31:03]};
		30, 8'b11111101: result = {highBits[01:0], lowBits[31:02]};
		31, 8'b11111110: result = {highBits[0], lowBits[31:01]};
		32, 8'b11111111: result = lowBits;
		default: result = -1;
	endcase

end


endmodule