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

initial $readmemh("RAM_empty.ram", mem);

// Currently just clock to avoid finished staying high
// For much faster preformance, can include read and write
always @(clock) begin
    // Assert finished low at the start
    finished = 0;

    // Perform logic in if block to get desied finished behaviour (high when done, low when working or no-op)
	 if(clock) begin
		 if(read) begin
			  _data = mem[address];
			  finished = 1;
		 end else if (write) begin
			  mem[address] = data;
			  finished = 1;
		 end 
	 end
end

endmodule