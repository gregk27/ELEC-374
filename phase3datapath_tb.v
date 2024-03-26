`timescale 1ns/10ps
module datapath_tb();

reg clock, reset, stop;

parameter Default = 5'b00000, T0 = 5'b00001, T1 = 5'b00010, T2 = 5'b00011, T3 = 5'b00100;

reg[4:0] present_state = Default;

DataPath path(clock, reset, stop);

initial begin clock = 0;  end
always #10 clock = ~clock;

always @(posedge clock)
begin
case (present_state)
Default: present_state = T0;
T0: present_state = T1;
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
		
	endcase
end 
endmodule 
			

