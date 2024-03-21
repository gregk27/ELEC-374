
`timescale 1ns / 10ps

module SelectEncode_tb();

reg clock;
reg [3:0] present_state;

// Inputs
reg [31:0] IR;
reg BAout;
reg Gra;
reg Grb;
reg Grc;
reg Rout;
reg Rin;

// Outputs
wire [31:0] C_sign_extended;
wire R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;

reg [31:0] expectedResult;

SelectEncode(
    IR, BAout, Gra, Grb, Grc, Rout, Rin,
);

parameter init = 4'd1, T0 = 4'd2, T1 = 4'd3, T2 = 4'd4, T3 = 4'd5;

initial begin clock = 0; present_state = 4'd0; end
always #10 clock = ~clock;
always @ (negedge clock) present_state = present_state + 1;

always @(present_state) begin
	case(present_state)
    init:begin // need opcode for addi instruction and immediate value +5 (0x05
        BAout<=0;Gra<=0; Grb<=0; Grc<=0;
        Rout<=0;Rin<=0;
        #0 IR<=32'b01100xxxxxxxxxxxxxxxxxxxxxxx0101;
        #5
    end
    T0: begin// need opcode for addi instruction and immediate value -3 (2's complement 0xFFFD)
        BAout<=0;Gra<=0; Grb<=0; Grc<=0;
        Rout<=0;Rin<=0;
        #0 IR<=32'b01100xxxxxxxxxxxxxxxxxxxxxxx1101;
        #5
		end
    T1: begin//ldi
    BAout<=0;Gra<=0; Grb<=0; Grc<=0;
    Rout<=0;Rin<=0;
    #0 IR<=32'00001xxxx0001xxxxxxxxxxxxxxx0101;
    #5
    end
    endcase
end      
endmodule
