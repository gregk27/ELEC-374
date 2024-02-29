module Select(
    input clock,
    input  [31:0] BusMuxOut,
    input   BAout,
    input  [3:0] Gra, Grb, Grc,
    input   BAout,
    input  reg [31:0] Rout, Rin,
    output wire[15:0] registerIn[15:0],
    output wire[15:0] registersOut[15:0],
    output [31:0] C_sign_extended,
    output wire[31:0] BusMuxIn
    );

reg [15:0] = result;

//Bus into IR (idk how to use IR in verilog)
Ra = BusMuxOut[26:23];
Rb = BusMuxOut[22:19];
Rc = BusMuxOut[18:15];
genvar i;
//Select and Encode Logic
always @ (posedge clock);
    begin
        or(decoderinput, blaL, blaM, blaR)
        and(blaL, Gra, Ra)
        and(blaM, Grb, Rb)
        and(blaR, Grc, Rc)
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
        for(i=0;i<16, i=i+1) begin: 
            registersIn[i] = Rin && result[i];
        end
        for(i=0;i<16, i=i+1) begin: 
            registersOut[i] = (Rout || BAout) && result[i];
        end
    end
endmodule



