module  Macs(
    input               clk,
    input               rstn,
    input   [15:0]      A,
    input   [15:0]      B_0,
    input   [15:0]      B_1,
    input   [15:0]      B_2,
    input   [15:0]      B_3,
    input   [15:0]      C_0,
    input   [15:0]      C_1,
    input   [15:0]      C_2,
    input   [15:0]      C_3,
    input               en,
    input               mode,
    input               signal,
    output              valid,
    output  [15:0]      result_0,
    output  [15:0]      result_1,
    output  [15:0]      result_2,
    output  [15:0]      result_3
);

    localparam matmul = 1'b0;
    localparam matadd = 1'b1;


    wire [15:0]  A_temp;
    assign A_temp = mode==matadd ? 1 : (signal? (~A + 1'b1) : A );

    PE u_PE_0 (
        .clk(clk),
        .rstn(rstn),
        .A(A_temp),
        .B(B_0),
        .C(C_0),
        .en(en),
        .result(result_0),
        .valid(valid)
    );

    PE u_PE_1 (
        .clk(clk),
        .rstn(rstn),
        .A(A_temp),
        .B(B_1),
        .C(C_1),
        .en(en),
        .result(result_1)
    );

    PE u_PE_2 (
        .clk(clk),
        .rstn(rstn),
        .A(A_temp),
        .B(B_2),
        .C(C_2),
        .en(en),
        .result(result_2)
    );

    PE u_PE_3 (
        .clk(clk),
        .rstn(rstn),
        .A(A_temp),
        .B(B_3),
        .C(C_3),
        .en(en),
        .result(result_3)
    );

    
endmodule