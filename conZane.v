module CON_Logic(
input wire [31:0]IR, 
input wire [31:0]BUS,
output wire D 
);

    reg [1:0] check_reg;
    reg zero_branch, nonzero_branch, negative_branch, positive_branch, bus_input, bus_msb;
    reg equal_zero_wire, nonzero_wire, negative_wire, positive_wire;
	 
	
    parameter branch_if_zero = 2'b00;
	 parameter branch_if_nonzero = 2'b01;
	 parameter branch_if_positve = 2'b10;
	 parameter branch_if_negative = 2'b11;
	 
	 initial begin
		bus_msb = BUS[31];
		bus_input = ~|BUS;
		check_reg = IR[20:19];
		end

    // decoding logic if IR changes decode and check I assume that CON signal from control unit will serve as enable
    always @(IR)
    begin
        case(check_reg)
            branch_if_zero:
            begin
                zero_branch = 1'b1;
                nonzero_branch = 1'b0;
                negative_branch = 1'b0;
                positive_branch = 1'b0;
            end

            branch_if_nonzero:
            begin
                nonzero_branch = 1'b1;
                zero_branch = 1'b0;
                negative_branch = 1'b0;
                positive_branch = 1'b0;
            end

            branch_if_negative:
            begin
                negative_branch = 1'b1;
                positive_branch = 1'b0;
                zero_branch = 1'b0;
                nonzero_branch = 1'b0;
            end

            branch_if_positve:
            begin
                positive_branch = 1'b1;
                negative_branch = 1'b0;
                zero_branch = 1'b0;
                nonzero_branch = 1'b0;
            end
            
    endcase
    end


	always @(branch_if_zero, branch_if_nonzero, positive_branch, negative_branch)
	begin
		 equal_zero_wire = branch_if_zero & bus_input;
		 nonzero_wire = branch_if_nonzero & (^bus_input);
		 negative_wire = negative_branch & (^bus_msb);
		 positive_wire = positive_branch & bus_msb;
	 end

    assign D = equal_zero_wire ^ nonzero_wire ^ negative_wire ^ positive_wire;
    

endmodule
