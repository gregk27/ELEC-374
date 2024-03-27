module DataPath(
	input wire clock, clear,
	// Bus input selection lines (device output -> bus input)
	input wire RFout_TB, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout, Immout, Inportout,
	// Register write enable lines
	input wire RFin_TB, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin, conffin, OutportIn,//enable wire for the conff logic
	// Register file index to use, if RFin or RFout are high
	// Use 5 bits so that high bit can be flag
	input wire [4:0]RFselect_TB,

	input wire TBout,
	input wire [31:0]BusMuxInTB,
	
	// alu requirments
	input wire [5:0]opSelect,
	input wire start,
  	output wire finished,
	
	// Memory Controls
	input wire read, MDRin, MDRout, write,
	output wire memFinished, 
	
	input wire BAout, Gra, Grb, Grc, Rout, Rin, IncPC,
	output wire branch, // indicates if we need to branch or not for conff

	// IO
	input wire device_strobe,
	input wire [31:0]device_in,
	output wire [31:0]device_out
);

// Connections from device output to bus input
wire [31:0]BusMuxInRF, BusMuxInPC, BusMuxInIR, BusMuxInRY, BusMuxInRZ, BusMuxInMAR, BusMuxInRHI, BusMuxInRLO, BusMuxInMDR, BusMuxInImm, BusMuxInInport;



wire [31:0]BusMuxOut;

wire [63:0]RZ_out;

wire RFin;
wire [3:0]RFselect;

//Devices


// Registers
// Internal selection is testbench override if positive, otherwise generated from opcode
wire [3:0]_rfSelect = RFselect_TB[4] ? RFselect[3:0] : RFselect_TB;
RegFile RF(clock, clear, RFin | RFin_TB, _rfSelect, BusMuxOut, BusMuxInRF);
Select SE(BusMuxInIR, BAout, Gra, Grb, Grc, Rout, Rin, BusMuxInImm, RFin, RFout, RFselect);

// Control
wire [31:0]newPC;
adder PCAdder(BusMuxInPC, 32'd1, 31'd0, newPC);
register PC(clear, clock, IncPC || PCin, IncPC ? newPC : BusMuxOut, BusMuxInPC);
register IR(clear, clock, IRin, BusMuxOut, BusMuxInIR);

// conff logic
conff con(BusMuxInRF, BusMuxInIR, conffin, branch);

// Memory
MemSys memory(clock, clear, read, write, MARin, MDRin, BusMuxOut, BusMuxInMDR, memFinished);
 
wire [63:0] ALU_Z; 

// ALU
register RY(clear, clock, RYin, BusMuxOut, BusMuxInRY);
register #(64, 64, 64'h0) RZ(clear, clock, RZin, ALU_Z, RZ_out);
register RHI(clear, clock, RHIin, BusMuxOut, BusMuxInRHI);
register RLO(clear, clock, RLOin, BusMuxOut, BusMuxInRLO);

// Selected between low and high RZ bits to send to the bus
assign BusMuxInRZ = RZLOout ? RZ_out[31:0] : 
						  RZHIout ? RZ_out[62:32] :
						  {32{1'dX}};

// IO Ports
register outport(clear, clock, OutportIn, BusMuxOut, device_out);
register inport(clear, clock, device_strobe, device_in, BusMuxInInport);

//Bus
Bus bus(
	// Data In
	BusMuxInTB, BusMuxInRF, BusMuxInPC, BusMuxInIR, BusMuxInRY, BusMuxInRZ, BusMuxInMAR, BusMuxInRHI, BusMuxInRLO, BusMuxInMDR, BusMuxInImm, BusMuxInInport,
	// Select signals
	TBout, RFout | RFout_TB, PCout, IRout, RYout, RZLOout | RZHIout, MARout, RHIout, RLOout, MDRout, Immout, Inportout,
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
