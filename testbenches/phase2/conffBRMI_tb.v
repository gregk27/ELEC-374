// and datapath_tb.v file: <This is the filename>
`timescale 1ns/10ps
module conffBRMI_tb();

reg Clock, clear, tbIn;
// Bus input selection lines (device output -> bus input)
reg RFout, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout, Immout;
// Register write enable lines
reg RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin, conffin;
// Register file selection line
reg [4:0]RFSelect;

reg [31:0] BusMuxInTB;

// ALU
reg start;
wire finished, memFinished;
reg [5:0]opSelect;
// Memory
reg Read, Write, MDRin, MDRout;

reg BAout, Gra, Grb, Grc, Rout, Rin;

// IO
reg device_strobe, OutportIn, Inportout;
reg [31:0]device_in;
wire [31:0]device_out;

reg IncPC;
// for conff
wire branch;

parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, Reg_load2a = 4'b0011,
    Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, Reg_load3b = 4'b0110, T0 = 4'b0111,
    T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100, T6 = 4'b1101;

reg [3:0] Present_state = Default;

DataPath DP(
	Clock, clear,
	RFout, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout, Immout, Inportout,
	RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin, conffin, OutportIn,	
	RFSelect,
    // TODO: Remove these signals
	tbIn, BusMuxInTB,

   //alu signals
   opSelect, start, finished,
   // Data Signals
   Read, MDRin, MDRout, Write, memFinished,
   // Control signals
   BAout, Gra, Grb, Grc, Rout, Rin, IncPC,
   branch,
   // IO
   device_strobe, device_in, device_out
);

// Flag to pervent state transition while a waiting for a delay
reg holdState = 0;

// Register holding expected value for comparison
reg [31:0]expectedValue = {32{1'dx}};

// add test logic here
initial begin Clock = 0;  end
always #10 Clock = ~Clock;

always @(posedge Clock) // finite state machine; if clock rising-edge
begin
	 if(!holdState) begin
		 case (Present_state)
			  Default : Present_state = Reg_load1a;
			  Reg_load1a : Present_state = Reg_load1b;
			  Reg_load1b : Present_state = Reg_load2a;
			  Reg_load2a : Present_state = Reg_load2b;
			  Reg_load2b : Present_state = T0;
			  T0 : Present_state = T1;
			  T1 : Present_state = T2;
			  T2 : Present_state = T3;
			  T3 : Present_state = T4;
			  T4 : Present_state = T5;
			  T5 : Present_state = T6;
		 endcase
	 end
end

always @(Present_state) // load R5 with 0
begin
	holdState = 1;
    case (Present_state) // assert the required signals in each clock cycle
        Default: begin
            PCout <= 0; RZLOout <= 0; MDRout <= 0; // initialize the signals
            RFout <= 0; MARin <= 0; RZin <= 0;
            PCin <=0; MDRin <= 0; IRin <= 0; RYin <= 0;
            IncPC <= 0; Read <= 0; opSelect <= 0;
            RFin <= 0;
            Gra <= 0; Grb <= 0; Grc <= 0; BAout <= 0; Rin <= 0; Rout <= 0; Immout <= 0; conffin <= 0;
        end
        Reg_load1a: begin
            // Set PC to the start of the test memory
            BusMuxInTB <= 32'd27 - 1;
            tbIn <= 1; PCin <= 1;
        end
        Reg_load1b: begin
            tbIn <= 0; PCin <= 0;
        end
        Reg_load2a: begin
            // Place all 1's into R5
            BusMuxInTB <= -1;
            RFSelect <= 5; RFin <= 1;
            tbIn <= 1;
        end
        Reg_load2b: begin 
            RFin <= 0; RFSelect <= -1;
            tbIn <= 0;
        end
        T0: begin // see if you need to de-assert these signals
            tbIn <= 0;
            PCout <= 0; MARin <= 0; IncPC <= 1; RZin <= 0; conffin <= 0;
            Write <= 0; RZLOout <= 0;
        end
        T1: begin
            // Send PC to MAR, begin read
            PCout <= 1; IncPC <= 0;
            MARin <= 1; Read <= 1; MDRin <= 1;
        end
        T2: begin
            // Pass data to instruction register
            PCout <= 0; MARin <= 0;
            MDRout <= 1; 
            #5 IRin <= 1;
        end
        T3: begin
            MDRout <= 0; IRin <= 0; IncPC <= 1; Rout <= 1;
            Gra <= 1; conffin <= 1;
        end
        T4: begin
            Gra <= 0; Rout <= 0; conffin <= 0; IncPC <= 0;
				PCout <= 1; RYin <= 1;
        end
        T5: begin
				PCout <= 0; RYin <= 0; Immout <= 1; 
				opSelect <= 5'b00100;
            RZin <= 1; start <= 1;
            #10 start <= 0;
        end
		  T6: begin
				Immout <= 0; RZin <= 0;
				if(branch)begin
				RZLOout <= 1; PCin <= 1;
				#20 
				RZLOout <= 0; PCin <= 0;
				end
        end
    endcase
	holdState = 0;
	end
endmodule 