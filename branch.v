module BranchLogic(
    input [31:0] PC,
    input [31:0] IR,
    input flag // Flags for zero, nonzero, positive, negative
    output reg [31:0] NewPC
);

reg [31:0] BusMuxIn; 
reg ConIn;
reg temp2;

conff conf(
    BusMuxIn, IR, ConIn, branch
);

always @ (*)
begin
    case(IR[31:27]) // Assuming the branch opcode is in bits 31-27 of the instruction
        5'b10011: // Example opcode for a branch instruction
            begin
                if (branch == 1'b1) // Branch if flag is set
                    NewPC = PC + 1 + IR[18:0]; // Increment PC by the branch offset
                else
                    NewPC = PC + 4; // Continue to the next instruction
            end
        default:
            NewPC = PC + 4; // Default behavior: continue to the next instruction
    endcase
end

endmodule
