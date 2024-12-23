`timescale 1ns / 1ns
`include "../rtl/adder_frodo.v"

module tb_adder_frodo;

  // Inputs
  reg clk;
  reg reset;
  reg en;
  reg [15:0] in_a;
  reg [15:0] in_b;
  reg [15:0] in_c;

  // Outputs
  wire [15:0] out_d;

  // Instantiate the DUT (Device Under Test)
  ADDER_FRODO UUT (
    .clk(clk),
    .reset(reset),
    .en(en),
    .in_a(in_a),
    .in_b(in_b),
    .in_c(in_c),
    .out_d(out_d)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;  // Clock period = 10 ns (100 MHz)
  end

  // Stimulus block
  initial begin
    $dumpfile("adder_frodo.vcd");
    $dumpvars(0, tb_adder_frodo);
    // Initialize signals
    clk = 0;
    reset = 0;
    en = 0;
    in_a = 16'h0000;
    in_b = 16'h0000;
    in_c = 16'h0000;

    // Apply reset
    #10 reset = 1;  // Assert reset
    #10 reset = 0;  // De-assert reset

    // Test case 1: 15 * 3 + 5
    // in_a = 15, in_b = 3, in_c = 5
    #10;
    in_a = 16'h000F;  // 15 in decimal
    in_b = 16'h0003;  // 3 in decimal
    in_c = 16'h0005;  // 5 in decimal
    en = 1;  // Enable the operation

    // Wait for some time and disable the enable signal
    #100 en = 0;

    // Test case 2: 8 * 7 + 12
    // in_a = 8, in_b = 7, in_c = 12
    #10;
    in_a = 16'h0008;  // 8 in decimal
    in_b = 16'h0007;  // 7 in decimal
    in_c = 16'h000C;  // 12 in decimal
    en = 1;  // Enable the operation

    // Wait for some time and disable the enable signal
    #100 en = 0;

    // Test case 3: 0 * 0 + 0
    // in_a = 0, in_b = 0, in_c = 0
    #10;
    in_a = 16'h0000;  // 0 in decimal
    in_b = 16'h0000;  // 0 in decimal
    in_c = 16'h0000;  // 0 in decimal
    en = 1;  // Enable the operation

    // Wait for some time and disable the enable signal
    #100 en = 0;

    // Test case 4: 65535 * 1 + 1000
    // in_a = 65535, in_b = 1, in_c = 1000
    #10;
    in_a = 16'hFFFF;  // 65535 in decimal
    in_b = 16'h0001;  // 1 in decimal
    in_c = 16'h03E8;  // 1000 in decimal
    en = 1;  // Enable the operation

    // Wait for some time and disable the enable signal
    #100 en = 0;

    // Test case 5: 0 * 1 + 0
    #10;
    in_a = 16'h0000;  // 0 in decimal
    in_b = 16'h0001;  // 1 in decimal
    in_c = 16'h0000;  // 0 in decimal
    en = 1;  // Enable the operation

    // Wait for some time and disable the enable signal
    #100 en = 0;

    // End of testbench
    #20;
    $finish;
  end

  // Monitor outputs
//   initial begin
//     $monitor("Time = %0t, in_a = %h, in_b = %h, in_c = %h, out_d = %h", 
//               $time, in_a, in_b, in_c, out_d);
//   end

endmodule
