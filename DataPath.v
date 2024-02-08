module DataPath(
	input wire clock, clear,
	// Bus input selection lines (device output -> bus input)
	input wire RFout, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout,
	// Register write enable lines
	input wire RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin,
	// Register file index to use, if RFin or RFout are high
	input wire [3:0]RFselect,

	input wire TBout,
	input wire [31:0]BusMuxInTB,
	
	// alu requirments
	input wire [5:0]opSelect,
	input wire start,
  	input wire finished,
	
	// Memory Controls
	input wire read, MDRin, MDRout,
	input wire [31:0]Mdatain
);

// Connections from device output to bus input
wire [31:0]BusMuxInRF, BusMuxInPC, BusMuxInIR, BusMuxInRY, BusMuxInRZ, BusMuxInMAR, BusMuxInRHI, BusMuxInRLO, BusMuxInMDR;


wire [31:0]BusMuxOut;

wire [63:0] RZ_temp;


//Devices


// Registers
RegFile RF(clock, clear, RFin, RFselect, BusMuxOut, BusMuxInRF);

// Control
register PC(clear, clock, PCin, BusMuxOut, BusMuxInPC);
register IR(clear, clock, IRin, BusMuxOut, BusMuxInIR);

// Memory
register MAR(clear, clock, MARin, BusMuxOut, BusMuxInMAR);
wire [31:0]MDMux = read ? BusMuxOut : Mdatain;
register MDR(clear, clock, MDRin, MDMux, BusMuxInMDR);


// connecting wire
 
wire [63:0] ALU_Z; 

// ALU
register RY(clear, clock, RYin, BusMuxOut, BusMuxInRY);
register #(64, 64, 64'h0) RZ(clear, clock, RZin, ALU_Z, RZ_temp);
register RHI(clear, clock, RHIin, BusMuxOut, BusMuxInRHI);
register RLO(clear, clock, RLOin, BusMuxOut, BusMuxInRLO);


//Bus
Bus bus(
	// Data In
	BusMuxInTB, BusMuxInRF, BusMuxInPC, BusMuxInIR, BusMuxInRY, BusMuxInRZ, BusMuxInMAR, BusMuxInRHI, BusMuxInRLO, BusMuxInMDR, 
	// Select signals
	TBout, RFout, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout, MDRout,
	// Out	
	BusMuxOut);



// instance of the alu
ALU alu(
	clock,
	opSelect,
	BusMuxInRY,	// A
	BusMuxOut,	//B
	start,
	ALU_Z,	//Z
	finished
);

endmodule
