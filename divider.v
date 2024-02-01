module divider(
	input wire clock,
	input wire start,
	input wire [31:0]dividend,
	input wire [31:0]divisor,
	output wire [31:0]quotient,
	output wire [31:0]remainder,
	output reg finished
);


// Large register for remaindor and qotient to allow shifting
reg [32:0] compute_remain;
reg [31:0] compute_quotient;
// Pre-computed positive and negative divisor
reg [32:0] divisor_pos;
reg [32:0] divisor_neg;
// Current step count
reg [5:0] count;
// Flag indicating if output needs to be negated
reg needsComp;

assign quotient = compute_quotient;
assign remainder = compute_remain;

initial finished <= 0;

always @(posedge clock, posedge start) begin
	if(start) begin
		compute_remain <= 33'd0;
		// Ensure dividend is negative
		compute_quotient <= dividend[31] ? -dividend : dividend;
		// Divisor_pos should be absolute value of divisor, neg should be negative abs
		divisor_pos <= divisor[31] ? -divisor : divisor;
		divisor_neg <= divisor[31] ? divisor : -divisor;
		// Sign-extend divisor, pos/neg should be enfocred so can just use 0/1
		divisor_pos[32] <= 0;
		divisor_neg[32] <= 1;
		// If either one is negative, then output should be negative
		needsComp = divisor[31] ^ dividend[31];
		// Setup control flags
		count <= 0;
		finished <= 0;
	end
	// Stop when division is done after 32 iterations
	else if(count != 32) begin
			// Shift left
			compute_remain = compute_remain << 1;
			compute_remain[0] = compute_quotient[31];
			compute_quotient = compute_quotient << 1;
			
			// If A < 0, subtract. Otherwise add
			compute_remain = compute_remain  + (compute_remain[32] ? divisor_pos : divisor_neg);

			// Set q0 bit
			compute_quotient[0] = ~compute_remain[32];
			// Increment control counter
			count = count + 1;
	end
	else if (count == 32) begin
		if(compute_remain[32]) begin
			compute_remain = compute_remain + divisor_pos;
		end
		if(needsComp) begin
			compute_quotient = -compute_quotient;
		end
		finished <= 1;
	end
end


endmodule