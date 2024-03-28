
`timescale 1ns / 1ps

module SelectEncode_tb;

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

    // Instantiate the Unit Under Test (UUT)
    Select uut (
        .IR(IR), 
        .BAout(BAout), 
        .Gra(Gra), 
        .Grb(Grb), 
        .Grc(Grc), 
        .Rout(Rout), 
        .Rin(Rin), 
        .C_sign_extended(C_sign_extended), 
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in), .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in), .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in), .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out), .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out)
    );

    initial begin
        // Initialize Inputs
        IR = 0;
        BAout = 0;
        Gra = 0;
        Grb = 0;
        Grc = 0;
        Rout = 0;
        Rin = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Test Case 1: Positive Immediate Value
        // Assuming opcode for addi instruction and immediate value +5 (0x05)
        IR = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_0101; // x represents don't care for this example
        #10; // Wait for the simulation
        
        // Test Case 2: Negative Immediate Value
        // Assuming opcode for addi instruction and immediate value -3 (2's complement 0xFFFD)
        IR = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_1101; // x represents don't care for this example
        #10; // Wait for the simulation

        // Additional test cases can be added here

    end
      
endmodule
