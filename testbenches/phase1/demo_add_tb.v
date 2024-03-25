// and datapath_tb.v file: <This is the filename>
`timescale 1ns/10ps
module demo_add_tb();

reg Clock, clear, tbIn;
// Bus input selection lines (device output -> bus input)
reg RFout, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout;
// Register write enable lines
reg RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin;
// Register file selection line
reg [4:0]RFSelect;

reg [31:0] BusMuxInTB;

// ALU
reg start;
wire finished;
reg [5:0]opSelect;
// Memory
reg Read, MDRin, MDRout;
reg [31:0]Mdatain;

reg IncPC; // Unused for now

parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, Reg_load2a = 4'b0011,
    Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, Reg_load3b = 4'b0110, T0 = 4'b0111,
    T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100;

reg [3:0] Present_state = Default;

DataPath DP(
	Clock, clear,
	RFout, PCout, IRout, RYout, RZLOout, RZHIout, MARout, RHIout, RLOout,
	RFin, PCin, IRin, RYin, RZin, MARin, RHIin, RLOin,	
	RFSelect,
    // TODO: Remove these signals
	tbIn, BusMuxInTB,

   //alu signals
   opSelect, start, finished,
   // Data Signals
   Read, MDRin, MDRout, Mdatain
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
			  Reg_load2b : Present_state = Reg_load3a;
			  Reg_load3a : Present_state = Reg_load3b;
			  Reg_load3b : Present_state = T0;
			  T0 : Present_state = T1;
			  T1 : Present_state = T2;
			  T2 : Present_state = T3;
			  T3 : Present_state = T4;
			  T4 : Present_state = T5;
		 endcase
	 end
end

always @(Present_state) // do the required job in each state
begin
	 holdState = 1;
    case (Present_state) // assert the required signals in each clock cycle
        Default: begin
            PCout <= 0; RZLOout <= 0; MDRout <= 0; // initialize the signals
            RFout <= 0; MARin <= 0; RZin <= 0;
            PCin <=0; MDRin <= 0; IRin <= 0; RYin <= 0;
            IncPC <= 0; Read <= 0; opSelect <= 0;
            RFin <= 0; Mdatain <= 32'h00000000;
        end
        Reg_load1a: begin
            Mdatain <= 32'h00000002;
            Read = 0; MDRin = 0; // the first zero is there for completeness
            #10 Read <= 1; MDRin <= 1;
            #15 Read <= 0; MDRin <= 0;
        end
        Reg_load1b: begin
            #5  RFSelect <= 2;
            #5  MDRout <= 1; RFin <= 1;
            #15 MDRout <= 0; RFin <= 0; // initialize R2 with the value $2
        end
        Reg_load2a: begin
            Mdatain <= 32'h00000007;
            #10 Read <= 1; MDRin <= 1;
            #15 Read <= 0; MDRin <= 0;
        end
        Reg_load2b: begin
            #5  RFSelect <= 3;
            #5  MDRout <= 1; RFin <= 1;
            #15 MDRout <= 0; RFin <= 0; // initialize R3 with the value $7
        end
        Reg_load3a: begin
            Mdatain <= 32'h00000018;
            #10 Read <= 1; MDRin <= 1;
            #15 Read <= 0; MDRin <= 0;
        end
        Reg_load3b: begin
            #5  RFSelect <= 1;
            #5  MDRout <= 1; RFin <= 1;
            #15 MDRout <= 0; RFin <= 0; // initialize R1 with the value $24
        end
        T0: begin // see if you need to de-assert these signals
            PCout <= 0; MARin <= 0; IncPC <= 0; RZin <= 0;
        end
        T1: begin
            RZLOout <= 0; PCin <= 1; Read <= 1; MDRin <= 1;
            Mdatain <= 32'h18918000; // opcode for “add R1, R2, R3”
        end
        T2: begin
            MDRout <= 1; IRin <= 1;
				#10 MDRout <= 0;
        end
        T3: begin
            IRin <= 0;
            RFSelect <= 2;
            RFout <= 1; RYin <= 1;
        end
        T4: begin
            RFSelect <= 3;
            RFout <= 1; opSelect <= 5'b00100; RZin <= 1;
				start <= 1;
				#15 start <= 0;
        end
        T5: begin
				RFSelect <= 1;
            RZLOout <= 1; RFin <= 1;
				expectedValue <= 32'd9;
        end
    endcase
	holdState = 0;
	end
endmodule 
