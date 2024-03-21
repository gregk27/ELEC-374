module Select(
    input [31:0] IR,
    input   BAout,
    input  Gra, Grb, Grc, Rout, Rin,
    output [31:0] C_sign_extended,
    output RFin, RFout, 
	 output [3:0]RFselect
    );
reg [3:0] OPCode, Ra, Rb, Rc;
reg [3:0] decoderinput;
reg [15:0] result;
reg [31:0] C;
reg [15:0] registersIn;
reg [15:0] registersOut;
integer i;
//Select and Encode Logic
always @ (*)
    begin
        OPCode = IR[31:27];
        Ra = IR[26:23];
        Rb = IR[22:19];
        Rc = IR[18:15];    
        decoderinput =  Gra ? Ra :
                       (Grb ? Rb : 
                       (Grc ? Rc : 31'hx));
        
        case(decoderinput)
            4'b0000: result = 16'b0000_0000_0000_0001;
            4'b0001: result = 16'b0000_0000_0000_0010;
            4'b0010: result = 16'b0000_0000_0000_0100;
            4'b0011: result = 16'b0000_0000_0000_1000;
            4'b0100: result = 16'b0000_0000_0001_0000;
            4'b0101: result = 16'b0000_0000_0010_0000;
            4'b0110: result = 16'b0000_0000_0100_0000;
            4'b0111: result = 16'b0000_0000_1000_0000;
            4'b1000: result = 16'b0000_0001_0000_0000;
            4'b1001: result = 16'b0000_0010_0000_0000;
            4'b1010: result = 16'b0000_0100_0000_0000;
            4'b1011: result = 16'b0000_1000_0000_0000;
            4'b1100: result = 16'b0001_0000_0000_0000;
            4'b1101: result = 16'b0010_0000_0000_0000;
            4'b1110: result = 16'b0100_0000_0000_0000;
            4'b1111: result = 16'b1000_0000_0000_0000;
            default: result = 16'b0000_0000_0000_0000; // In case of invalid input
        endcase
        for(i=0;i<16; i=i+1) begin
            registersIn[i] = Rin & result[i];
        end
        for(i=0;i<16; i=i+1) begin
            registersOut[i] = (Rout | BAout) & result[i];
        end
        C = IR[18] ? { {13{1'b1}}, IR[18:0] } : { {13{1'b0}}, IR[18:0] };

    end
    assign RFin = |registersIn;
    assign RFout = |registersOut;
    assign RFselect = decoderinput;
    assign C_sign_extended = C;
endmodule



