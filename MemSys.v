module MemSys (
	input wire clock, clear,
	input wire read, write, MARin, MDRin,
	input wire [31:0]BusMuxOut,
	output wire [31:0]memData,
	output wire finished
);

wire [31:0]address;

reg [31:0]MDR = 0;

wire [31:0]MDMux = read ? memData : BusMuxOut;
assign memData = finished && read ? 32'hz : MDR;

register MAR(clear, clock, MARin, BusMuxOut, address);
RAM ram(clock, read, write, address, memData, finished);

// MDR is implemented as an async register because waiting for it was causing a mess
always @(clear, MDRin, MDMux) begin
	if(clear) MDR = 0;
	else if (MDRin)	MDR = MDMux;
end

endmodule