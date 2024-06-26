module controlUnit (
	input wire clock, reset, stop, 
	input wire [31:0]IR,
	input wire branch,
	input wire ALUFinished,
	output reg [4:0]ALUControl, // send opcodes to configure the alu operations
	output reg start,
	
	// cpu control signals 
	output reg read, write, clear, 
	output reg incPC,
	output reg Gra, Grb, Grc, Rin, Rout, BAout, Conffin, // for instruction operations 
	output reg RLOout, RHIout, RZLOout, RZHIout, PCout, MDRout, Immout, InPortout,
	output reg RLOin, RHIin, PCin, IRin, RYin, RZin, MDRin, MARin, OutPortin,
	
	// for the register file
	inout RFin, RFout, 
	inout [3:0]RFSelect,
	
	// Instruction counter for debugging
	output reg [15:0]instrCount
);

parameter reset_state = 8'h00, 
Inst_fetch0 = 8'h01, Inst_fetch1 = 8'h02, Inst_fetch2 = 8'h03, Inst_fetch3 = 8'h2E,  // move the instruction into the IR
// ld instruction
ld0 = 8'h04, ld1 = 8'h05, ld2 = 8'h06, ld3 = 8'h07, ld4 = 8'h08,

// ldi instruction
ldi0 = 8'h09, ldi1 = 8'h0A, ldi2 = 8'h0B,

// st instruction
st0 = 8'h0C, st1 = 8'h0D, st2 = 8'h0E, st3 = 8'h0F, st4 = 8'h10,

// alu with 2 reg operators 
alu_2_reg0 = 8'h11, alu_2_reg1 = 8'h12, alu_2_reg2 = 8'h13,

// alu with immediate operator 
alu_imm0 = 8'h14, alu_imm1 = 8'h15, alu_imm2 = 8'h16,

// alu for multiplying or dividing
alu_mul_div0 = 8'h17, alu_mul_div1 = 8'h18, alu_mul_div2 = 8'h19, alu_mul_div3 = 8'h1A, alu_mul_div_wait = 8'h2F,

// alu for negation and not ops
alu_n0 = 8'h1B, alu_n1 = 8'h1C,

// branching 
br0 = 8'h1D, br1 = 8'h1E, br2 = 8'h1F, br3 = 8'h20,

//jump return instruction
jr0 = 8'h21, 

// jump and link
jal0 = 8'h22, jal1 = 8'h23, 

// io port instructions
inputPort0 = 8'h24,
outPort0 = 8'h25,

// move from RZ HI and LO instructions
mfhi0 = 8'h26,
mflo0 = 8'h27,

// nop and halt

nop0 = 8'h28, nop1 = 8'h29, nop2 = 8'h2A, nop3 = 8'h2B, nop4 = 8'h2C,

halt = 8'h2D;

// Inst_fetch3 = 8'h2E above
// alu_mul_div_wait = 8'h2F above

reg [7:0]present_state = reset_state;

// Internal signal used to emit a start signal pulse
reg _pulseStart = 0;

// Default ALU value
initial ALUControl <= 0;

// Initialize the instruction counter to 0
initial instrCount <= -1;

// TSB Register controls need continous assignment, which wraps internal vars
reg _RFin, _RFout;
reg [3:0]_RFSelect;

assign RFin = _RFin;
assign RFout = _RFout;
assign RFSelect = _RFSelect;

//set up state transitions, flow through each instruction a based on the first five bits in the IR

always @(posedge clock, posedge reset) 
begin
	if(reset == 1'b1) present_state = reset_state;
	else 
		case(present_state) 
				reset_state: present_state = Inst_fetch0;
				Inst_fetch0: present_state = Inst_fetch1;
				Inst_fetch1: present_state = Inst_fetch2;
				Inst_fetch2: present_state = Inst_fetch3;
				Inst_fetch3: begin
				case(IR[31:27])
					5'b00000: present_state = ld0;
					5'b00001: present_state = ldi0;
					5'b00010: present_state = st0;
					5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, 5'b01000, 5'b01001, 5'b01010, 5'b01011: present_state = alu_2_reg0;
					5'b01100, 5'b01101, 5'b01110: present_state = alu_imm0;
					5'b01111, 5'b10000: present_state = alu_mul_div0;
					5'b10001, 5'b10010: present_state = alu_n0;
					5'b10011: present_state = br0;
					5'b10100: present_state = jr0;
					5'b10101: present_state = jal0;
					5'b10110: present_state = inputPort0;
					5'b10111: present_state = outPort0;
					5'b11000: present_state = mfhi0;
					5'b11001: present_state = mflo0;
					5'b11010: present_state = nop0;
					5'b11011: present_state = halt;
					endcase
				end
				ld0: present_state = ld1;
				ld1: present_state = ld2;
				ld2: present_state = ld3;
				ld3: present_state = ld4;
				ld4: present_state = Inst_fetch0;	//reached the end of the ld instruction get the next
				
				ldi0: present_state = ldi1;
				ldi1: present_state = ldi2;
				ldi2: present_state = Inst_fetch0;	//reached the end of the ldi instruction get the next
				
				st0: present_state = st1;
				st1: present_state = st2;
				st2: present_state = st3;
				st3: present_state = st4;
				st4: present_state = Inst_fetch0;	//reached the end of the st instruction get the next
				
				alu_2_reg0: present_state = alu_2_reg1;
				alu_2_reg1: present_state = alu_2_reg2;
				alu_2_reg2: present_state = Inst_fetch0;	//reached the end of the 2 reg alu instruction get the next
				
				alu_imm0: present_state = alu_imm1;
				alu_imm1: present_state = alu_imm2;
				alu_imm2: present_state = Inst_fetch0;	//reached the end of the immediate alu instruction get the next
				
				alu_mul_div0: present_state = alu_mul_div1;
				alu_mul_div1: present_state = alu_mul_div_wait;
				alu_mul_div_wait: present_state = ALUFinished ? alu_mul_div2 : alu_mul_div_wait; // Hold in the waiting state until the ALU is done
				alu_mul_div2: present_state = alu_mul_div3;
				alu_mul_div3: present_state = Inst_fetch0;	//reached the end of the mul or div alu instruction get the next
				
				alu_n0: present_state = alu_n1;
				alu_n1: present_state = Inst_fetch0;	//reached the end of the neg or not alu instruction get the next
				
				br0: present_state = br1;
				br1: present_state = br2;
				br2: present_state = br3;
				br3: present_state = Inst_fetch0;	//reached the end of the branch instruction get the next
				
				
				jr0: present_state = nop1;		// the following instructions need to be "extended" using the nop instruction
				jal0: present_state = jal1;
				jal1: present_state = nop2;
				
				inputPort0: present_state = nop1;
				outPort0: present_state = nop1;
				mfhi0: present_state = nop1;
				mflo0: present_state = nop1;
				
				nop0: present_state = nop1;
				nop1: present_state = nop2;
				nop2: present_state = nop3;
				nop3: present_state = nop4;
				nop4: present_state = Inst_fetch0;	//reached the end of the nop instruction get the next
				
				halt: present_state = halt;
				
				endcase
			end
			
// now do the job required for each state
	
always @(present_state) 
begin
	// deassert all the signals at the beginning of each state change
	read <= 0; write <= 0; clear <= 0;
	incPC <= 0; 
	Gra <= 0; Grb <= 0; Grc <= 0; Rin <= 0; Rout <= 0; BAout <= 0; Conffin <= 0;
	RLOout <= 0; RHIout <= 0; RZLOout <= 0; RZHIout <=0 ; PCout <= 0; MDRout <= 0; Immout <= 0; InPortout <= 0;
	RLOin <= 0; RHIin <= 0; PCin <= 0; IRin <= 0; RYin <= 0; RZin <= 0; MDRin <= 0; MARin <= 0; OutPortin <= 0;
	
	// Latch ALU Control so the results are preserved until a new op is requested
	ALUControl <= ALUControl;
	_pulseStart <= 0;
	// branch <= 0; do not reassert branch at every state only set it to 0 on reset might need to update this 

	// Set register controls to high impedance when not asserted
	_RFin <= 'hz; _RFout <= 'hz;
	_RFSelect <= 'hz;
	
	case(present_state) 
	
	reset_state: begin 
		clear <= 1;
		end
		
	// fetching stage
	
	Inst_fetch0: begin
			PCout <= 1; MARin <= 1; incPC <= 1;
		end
		
	Inst_fetch1: begin
			MDRin <= 1; read <= 1; 
			// Increment the instruction counter, done here as it looks better in the waveform
			instrCount = instrCount + 1;
		end
		
	Inst_fetch2: begin
			MDRout <= 1; IRin <= 1;
		end
	
	// ld instruction
	
	ld0: begin
		Rout <= 1; Grb <= 1; BAout <= 1; RYin <= 1;
	end 
	
	ld1: begin // add the immediate 
		Immout <= 1; ALUControl <= 5'b00011; RZin <= 1; _pulseStart <= 1;
	end
	ld2: begin // search for sum in memory  
      RZLOout <= 1; MARin <= 1;
	end	
	ld3: begin // read from addr
		read <= 1; MDRin <= 1;
	end
	ld4: begin // store in Ra
       MDRout <= 1; Gra <= 1; Rin <= 1;
	end
	
	// ldi instruction
	ldi0: begin
		Rout <= 1; Grb <= 1; BAout <= 1; RYin <= 1;
	end 
	ldi1: begin
		Immout <= 1; ALUControl <= 5'b00011; RZin <= 1; _pulseStart <= 1;
	end
	ldi2: begin
      RZLOout <= 1; Gra <= 1; Rin <= 1;
	end
	
	// st instruction
	st0: begin
      Rout <= 1; Grb <= 1; BAout <= 1; RYin <= 1;
	end
	st1: begin
		Immout <= 1; ALUControl <= 5'b00011; RZin <= 1; _pulseStart <= 1;
	end
	st2: begin
      RZLOout <= 1; MARin <= 1;
	end
	st3: begin
      MDRin <= 1; Gra <= 1; Rout <= 1;
	end
	st4: begin
		MDRout <= 1; write <= 1;
	end
	
	// alu_2_reg0 instruction format
	alu_2_reg0: begin //Rb into RY
		Grb <= 1; Rout <= 1; RYin <= 1; 
	end
	alu_2_reg1: begin // Rc into the ALU
		Grc <= 1; Rout <= 1; RZin <= 1; ALUControl <= IR[31:27]; _pulseStart <= 1;
	end
	alu_2_reg2: begin // store result in Ra
		RZLOout <= 1; Gra <= 1; Rin <= 1; 
	end
	
	// immediate alu instruction
	
	alu_imm0: begin // Rb into RY
		Grb <= 1; Rout <= 1; RYin <= 1; 
	end
	alu_imm1: begin // C into the alu
		Immout <= 1; RZin <= 1; ALUControl <= IR[31:27]; _pulseStart <= 1;
	end
	alu_imm2: begin // store result in Ra
		RZLOout <= 1; Gra <= 1; Rin <= 1; 
	end
	
	// mul and div instructions (have to get lo and hi bits out of RZ)
	
	alu_mul_div0: begin // put Ra into RY
		Gra <= 1; Rout <= 1; RYin <= 1; 
	end
	alu_mul_div1: begin // put Rb into the ALU
		Grb <= 1; Rout <= 1; ALUControl <= IR[31:27]; _pulseStart <= 1;		
	end
	alu_mul_div_wait: begin // Ilde state to wait for the calculation to finish
		RZin <= 1;
	end
	alu_mul_div2: begin // move the upper 32 bits into the hi reg
		RZHIout <= 1; RHIin <= 1;
	end
	alu_mul_div3: begin // move the lower 32 bits into the lo reg
		RZLOout <= 1; RLOin <= 1;
	end
	
	// not and negate instructions
	
	alu_n0: begin // send Rb straight into the alu along with the instruction
		// Unary operators don't use RY, instead read straight off datapath to save the clock cycle
		Grb <= 1; Rout <= 1; RZin <= 1; ALUControl <= IR[31:27]; _pulseStart <= 1;	
	end
	alu_n1: begin // store the result in Ra
		RZLOout <= 1; Gra <= 1; Rin <= 1;
	end
	
	// branch instructions 
	br0: begin 
		Gra <= 1; Rout <= 1; Conffin <= 1;
	end 
	br1: begin 
		PCout <= 1; RYin <= 1;
	end 
	br2: begin 
		Immout <= 1; ALUControl <= 5'b00011; RZin <= 1; _pulseStart <= 1;
	end
	br3: begin
		if(branch) begin 
			RZLOout <= 1;
			PCin <= 1;
		end
	end 
	
	// jump instruction
	jr0: begin // ld Ra in the PC
		PCin <= 1; Gra <= 1; Rout <= 1; 
	end
	
	// jump and link instruction
	jal0: begin // store PC in R15
		PCout <= 1; _RFSelect <= 15; _RFin <= 1; 
	end
	jal1: begin // ld Ra into PC
		PCin <= 1; Gra <= 1; Rout <= 1; 
	end
	
	// io port instructions
	inputPort0: begin
		InPortout <= 1; Gra <= 1; Rin <= 1;
	end
	
	outPort0: begin
		OutPortin <= 1; Gra <= 1; Rout <= 1;
	end
	
	// move hi and lo instructions
	
	mfhi0: begin 
		RHIout <= 1; Gra <= 1; Rin <= 1;
	end 
	
	mflo0: begin 
		RLOout <= 1; Gra <= 1; Rin <= 1;
	end 
	
	// no operations for nop
	// do nothing at halt 
	halt: begin
		// dont do nothin
	end

endcase
end 

// Start singal pulser
// Since the start signal needs to go low at the falling edge for the ALU to begin most ops, this will handle that
always @(_pulseStart, clock) begin
	// @(posedge _pulseStart)
	if(_pulseStart && !start)
		start <= 1;
	// @(negedge clock)
	else if(!clock)
		start <= 0;
end

endmodule 
		
	
