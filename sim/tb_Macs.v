`timescale 1ns / 1ns
`include "../rtl/Macs/Macs.v"
module tb_Macs;

// Testbench signals
reg clk;
reg rstn;
reg [15:0] A;
reg [15:0] B_0, B_1, B_2, B_3;
reg [15:0] C_0, C_1, C_2, C_3;
reg en;
reg mode;
reg signal;

wire valid;
wire [15:0] result_0, result_1, result_2, result_3;

// Instantiate the Macs module
Macs uut (
    .clk(clk),
    .rstn(rstn),
    .A(A),
    .B_0(B_0),
    .B_1(B_1),
    .B_2(B_2),
    .B_3(B_3),
    .C_0(C_0),
    .C_1(C_1),
    .C_2(C_2),
    .C_3(C_3),
    .en(en),
    .mode(mode),
    .signal(signal),
    .valid(valid),
    .result_0(result_0),
    .result_1(result_1),
    .result_2(result_2),
    .result_3(result_3)
);

// Clock generation
always begin
    #5 clk = ~clk;  // 100 MHz clock
end

// Initial block to drive inputs and check outputs
initial begin
    // Initialize signals
    $dumpfile("wave/Macs.vcd");
    $dumpvars(0, tb_Macs);
    clk = 0;
    rstn = 0;
    A = 16'b0;
    B_0 = 16'b0; B_1 = 16'b0; B_2 = 16'b0; B_3 = 16'b0;
    C_0 = 16'b0; C_1 = 16'b0; C_2 = 16'b0; C_3 = 16'b0;
    en = 0;
    mode = 0;
    signal = 0;

    // Apply reset
    #10;
    rstn = 1;

    // Test 1: Multiply mode (matmul) with signal = 0
    A = 16'h3;  // A = 3
    B_0 = 16'h2; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h0; C_1 = 16'h0; C_2 = 16'h0; C_3 = 16'h0;
    en = 1;
    mode = 0;  // matmul mode
    signal = 0;  // normal multiplication
    #20;

    A = 16'h1;  // A = 3
    B_0 = 16'h3; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h4; C_1 = 16'h0; C_2 = 16'h0; C_3 = 16'h0;
    en = 1;
    mode = 0;  // matmul mode
    signal = 0;  // normal multiplication
    #20;

    A = 16'h3;  // A = 3
    B_0 = 16'h4; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h5; C_1 = 16'h0; C_2 = 16'h0; C_3 = 16'h0;
    en = 1;
    mode = 0;  // matmul mode
    signal = 0;  // normal multiplication
    #40;

    A = 16'h3;  // A = 3
    B_0 = 16'h3; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h3; C_1 = 16'h0; C_2 = 16'h0; C_3 = 16'h0;
    en = 1;
    mode = 0;  // matmul mode
    signal = 0;  // normal multiplication
    #20;

    // Test 2: Add mode (matadd)
    A = 16'h3;  // A = 3
    B_0 = 16'h2; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h6; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 1;  // matadd mode
    signal = 0;  // normal addition
    #20;

    A = 16'h5;  // A = 3
    B_0 = 16'h1; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h7; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 1;  // matadd mode
    signal = 0;  // normal addition
    #20;

    A = 16'h2;  // A = 3
    B_0 = 16'h3; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h4; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 1;  // matadd mode
    signal = 0;  // normal addition
    #40;

    A = 16'h6;  // A = 3
    B_0 = 16'h2; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h1; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 1;  // matadd mode
    signal = 0;  // normal addition
    #20;

    // Test 3: Matmul with negative A (signal = 1)
    A = 16'h1;  // A = 3
    B_0 = 16'h3; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h2; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 0;  // matadd mode
    signal = 1;  // normal addition
    #20;

    A = 16'h3;  // A = 3
    B_0 = 16'h5; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h2; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 0;  // matadd mode
    signal = 1;  // normal addition
    #20;

    A = 16'h1;  // A = 3
    B_0 = 16'h2; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h2; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 0;  // matadd mode
    signal = 1;  // normal addition
    #40;

    A = 16'h3;  // A = 3
    B_0 = 16'h3; B_1 = 16'h4; B_2 = 16'h1; B_3 = 16'h5;
    C_0 = 16'h3; C_1 = 16'h6; C_2 = 16'h6; C_3 = 16'h6;
    mode = 0;  // matadd mode
    signal = 1;  // normal addition
    #20;

    // Test 4: Enable pulse for en = 0 and 1 for further test case transitions
    en = 0;
    #10;
    en = 1;
    #10;

    // Test 5: Changing inputs while keeping mode to matadd
    A = 16'h8;
    B_0 = 16'h1; B_1 = 16'h2; B_2 = 16'h3; B_3 = 16'h4;
    C_0 = 16'h7; C_1 = 16'h8; C_2 = 16'h9; C_3 = 16'hA;
    #40;

    // End the simulation
    $finish;
end

// Monitor outputs
// initial begin
//     $monitor("Time=%0t | A=%d | B_0=%d B_1=%d B_2=%d B_3=%d | C_0=%d C_1=%d C_2=%d C_3=%d | Mode=%b | Result: %d %d %d %d | Valid=%b", 
//              $time, A, B_0, B_1, B_2, B_3, C_0, C_1, C_2, C_3, mode, result_0, result_1, result_2, result_3, valid);
// end

endmodule

