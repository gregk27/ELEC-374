`timescale 1ns/10ps
module RAM(
    input wire clock, read, write, 
    input wire [8:0]address, 
    inout wire [31:0]data, 
    output reg finished
);

reg [31:0] mem[0:511];

// Internal temp reg for grabbing data
// Done this way to allow for delay between read and finish
reg [31:0]_data;

// Send value if read is high, otherwise HiZ to get incoming data
assign data = read ? _data : 'bz;

initial $readmemh("ram.ram", mem);

// For much faster preformance, can include read and write
// Quartus compiler requires only posedge for readmemh, modelsim doesn't care
// This is super hacky, mostly just to make sure it works
`ifdef QUARTUS
always @(posedge clock) begin
`else
always @(address, read, write) begin
`endif
    // Assert finished low at the start
    finished = 0;

	if(read) begin
		#1 // Make it take some time
		_data = mem[address];
		finished = 1;
	end else if (write) begin
		#1 // Make it take some time
		mem[address] = data;
		finished = 1;
	end 
end

endmodule