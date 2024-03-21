module BranchLogic(
    input [31:0] PC,
    input [31:0] IR,
    input flag // Flags for zero, nonzero, positive, negative
    output reg [31:0] NewPC
);

reg [31:0] BusMuxIn; 
reg ConIn;
reg temp2;
wire D;

CON_Logic conf(
    IR, BusMuxIn, D
);

always @ (*)
begin
    if (D == 1'b1) // Branch if flag is set
        PC = PC + 1 + IR[18:0]; // Increment PC by the branch offset
    else
        PC = PC + 4; // Continue to the next instruction
end

assign NewPC = PC
endmodule
