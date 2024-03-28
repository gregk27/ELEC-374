module conff(
    input [31:0] BusMuxIn, 
    input [31:0] IR, 
    input ConIn, 
    output branch
); 


reg temp, temp2;
reg [3:0] BusMuxInIR; 
integer i; 



always @ (IR, BusMuxIn) begin

	BusMuxInIR = IR[20:19]; 
	temp <= 0;
	for (i = 0; i < 32; i = i + 1) begin
		temp = temp || BusMuxIn[i];
	end
	
	if (BusMuxInIR == 2'b00) begin
		if (!temp) begin
			temp2 = 1'b1;
		end
		 
	end 
	else if (BusMuxInIR == 2'b01) begin 
		 if (temp) begin
			temp2 = 1'b1;
		end

	end 
	else if (BusMuxInIR == 2'b10) begin 
		 if(BusMuxIn[31] == 1'b0) begin
			temp2 = 1'b1;
		end
 
	end 
	else if (BusMuxInIR == 2'b11) begin 
		 if(BusMuxIn[31] == 1'b1) begin
			temp2 = 1'b1;
		end
		 
	end 
	else begin
		temp2 = 1'b0;
	end 
	
end

always @ (posedge ConIn) begin
	if (!temp2) begin
		temp2 = 1'b0;
	end
	else if (temp2) begin
		temp2 = 1'b1;
	
assign branch = temp2;


endmodule 