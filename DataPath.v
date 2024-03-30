module DataPath(
	input wire clock,reset, stop,
	// alu requirments
  	output wire finished,
	
	// Memory Controls
	output wire memFinished,

	// Counter of instructions executed for debugging
	output wire [15:0]instrCount
);

// Connections from device output to bus input
wire [31:0]BusMuxInRF, BusMuxInPC, BusMuxInIR, BusMuxInRY, BusMuxInRZ, BusMuxInMAR, BusMuxInRHI, BusMuxInRLO, BusMuxInMDR, BusMuxInImm, BusMuxInInport;
wire [31:0]BusMuxOut;
wire [63:0]RZ_out;
wire RFin;
wire [3:0]RFselect;

//set up sigs to be generated by the control logic
wire PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout, Immout, Inportout;
wire RFin_TB, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin, conffin, OutportIn;
wire [4:0]opSelect;
wire start;
wire read, MDRin, MDRout, write, clear;
wire BAout, Gra, Grb, Grc, Rout, Rin, IncPC;
wire branch;

// conff logic
conff con(BusMuxInRF, BusMuxInIR, conffin, branch);

// create an instance of the control unit
controlUnit control(
    clock, reset, stop,
    BusMuxInIR,
	 branch,
	finished,
    opSelect,
    start,
    read, write, clear,
    IncPC, 
    Gra, Grb, Grc, Rin, Rout, BAout, conffin,
    RLOout, RHIout, RZLOout, RZHIout, PCout, MDRout, Immout, Inportout, 
    RLOin, RHIin, PCin, IRin, RYin, RZin, MDRin, MARin, OutportIn,
	RFin, RFout, RFselect,
	instrCount
);

//Devices


// Registers
// Internal selection is testbench override if positive, otherwise generated from opcode
RegFile RF(clock, clear, RFin, BAout, RFselect, BusMuxOut, BusMuxInRF);
Select SE(BusMuxInIR, BAout, Gra, Grb, Grc, Rout, Rin, BusMuxInImm, RFin, RFout, RFselect);

// Control
wire [31:0]newPC;
adder PCAdder(BusMuxInPC, 32'd1, 31'd0, newPC);
register PC(clear, clock, IncPC || PCin, IncPC ? newPC : BusMuxOut, BusMuxInPC);
register IR(clear, clock, IRin, BusMuxOut, BusMuxInIR);



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
	TBout, RFout, PCout, IRout, RYout, RZLOout | RZHIout, MARout, RHIout, RLOout, MDRout, Immout, Inportout,
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
