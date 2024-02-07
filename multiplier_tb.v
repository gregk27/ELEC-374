`timescale 1ns/10ps

module multiplier_tb();

reg clock;
reg start;
reg [31:0] multiplicand;
reg [31:0] multiplier;
wire [31:0] product_low;
wire [31:0] product_high;
wire finished;

reg [63:0] expectedProduct;

multiplier mult(
    .clk(clock),
    .start(start),
    .multiplicand(multiplicand),
    .product_lo(product_low),
    .product_hi(product_high),
    .finished(finished)
);

initial begin
    clock = 0;
    forever #5 clock = ~clock;
    end

initial begin
    start = 0;
    multiplicand = 0;
    multiplier = 0;
    #10;
    // test 1
    multiplicand = 32'd15;
    multiplier = 32'd15;
    expectedProduct = 64'd225;
    #10;
    start = 1;
    #10;
    start = 0;
    wait(finished);
    
    $finish;
end

endmodule
