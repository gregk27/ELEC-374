module conff(
    input [31:0] BusMuxIn, 
     input [31:0] IR,
    input ConIn, 
    output branch
); 


reg temp, temp2;
reg [1:0] BusMuxInIR; 
integer i;


    

always @ (BusMuxIn) begin

BusMuxInIR = IR[20:19]; 
    
    case(BusMuxInIR)
            2'b00:begin
                    if(BusMuxIn == 32'b0)begin
                        temp <= 1;
                    end
                    else
                    temp <= 0;
                    end
                
                2'b01:begin
                    if(BusMuxIn != 32'b0)begin
                        temp <= 1;
                    end
                    end
                
                2'b10:begin
                    if(BusMuxIn[31] == 1'b0)begin
                        temp <= 1;
                    end
                    end
                
                2'b11:begin
                    if(BusMuxIn[31] == 1'b1)begin
                        temp <= 1;
                    end
                    end
            
        endcase
          
    end
    
always @ (ConIn) begin
	temp2 <= temp;
end
	
	assign branch = temp2;




endmodule 
