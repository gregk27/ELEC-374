module Bus (
	//Mux
	input [31:0]BusMuxInTB, BusMuxInRF, BusMuxInPC, BusMuxInIR, BusMuxInRY, BusMuxInRZ, BusMuxInMAR, BusMuxInRHI, BusMuxInRLO, BusMuxInMDR,	BusMuxInImm, BuxMuxInInport,
	//Encoder
	input TBout, RFout, PCout, IRout, RYout, RZout, MARout, RHIout, RLOout, MDRout, Immout, InportOut,

	output wire [31:0]BusMuxOut
);

reg [31:0]q;

always @ (*) begin
	if(TBout) q = BusMuxInTB;
	if(RFout) q = BusMuxInRF;
	if(PCout) q = BusMuxInPC;
	if(IRout) q = BusMuxInIR;
	if(RYout) q = BusMuxInRY;
	if(RZout) q = BusMuxInRZ;
	if(MARout) q = BusMuxInMAR;
	if(RHIout) q = BusMuxInRHI;
	if(RLOout) q = BusMuxInRLO;
	if(MDRout) q = BusMuxInMDR;
	if(Immout) q = BusMuxInImm;
	if(InportOut) q = BuxMuxInInport;
end
assign BusMuxOut = q;
endmodule
