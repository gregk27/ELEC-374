module MemSys (
	input wire clock, clear,
	input wire read, write, MARin, MDRin,
	input wire [31:0]BusMuxOut,
	output wire [31:0]memData,
	output wire finished
);

wire [31:0]MDRDataOut;
wire [31:0]address;

reg read_internal;

wire [31:0]MDMux = read ? memData : BusMuxOut;
assign memData = finished && read_internal ? 32'hz : MDRDataOut;

register MAR(clear, clock, MARin, BusMuxOut, address);
register MDR(clear, clock, MDRin, MDMux, MDRDataOut);
RAM ram(clock, read_internal, write, address, memData, finished);

always @(posedge clock, posedge read, posedge write) begin
	// Keep the read signal to ram asserted until the clock edge to capture it in the register
	// If a write starts before the register can capture it, that would overwrite it anyway so don't need the capture
	read_internal = read & !write;
end

endmodule