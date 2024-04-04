`timescale 1ns/10ps
module phase4_tb();

reg clock, reset, stop, device_strobe;
reg[31:0] device_in;
wire[31:0] device_out;


parameter Default = 5'b00000, T0 = 5'b00001, T1 = 5'b00010, T2 = 5'b00011, T3 = 5'b00100, T4 = 5'b00101, T5 = 5'b00110;

reg[4:0] present_state = Default;

wire aluFinished, memFinished;
wire [15:0]instrCount;

DataPath DP(clock, reset, stop, device_strobe, device_in, aluFinished, memFinished, instrCount, device_out);

initial begin clock = 0;  end
always #10 clock = ~clock;

always @(posedge clock)
begin
case (present_state)
// to load the in port after clear
Default: present_state = T0;
T0: present_state = T4;
T4: present_state = T5;

T5: present_state = T1;
T1: present_state = T2;
T2: present_state = T3;
endcase 
end

always @(present_state)
begin
	reset <= 0; 
	case (present_state)
		T0: begin
			reset <= 0;
		end
		T1: begin
			
		end
		T2: begin
			
		end
		T3: begin
			
		end
		T4: begin
		device_strobe <= 1;
		device_in <= 32'b10000000; //hex 0x80
			
		end
		T5: begin
		device_strobe <= 0;
		end
		
		
	endcase
end 
endmodule 
			