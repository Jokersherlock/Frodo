`define A_LOAD_PATH "F:/project/Frodo/sim/RAM/data/A.hex"
`define B_LOAD_PATH "F:/project/Frodo/sim/RAM/data/B.hex"
`define C_LOAD_PATH "F:/project/Frodo/sim/RAM/data/C.hex"
`define A_STORE_PATH "F:/project/Frodo/sim/ram_data_output/A_output.txt"
`define B_STORE_PATH "F:/project/Frodo/sim/ram_data_output/B_output.txt"
`define C_STORE_PATH "F:/project/Frodo/sim/ram_data_output/C_output.txt"
`define TIME 10000
`timescale 1ps/1ps
`include "../rtl/Control/matCtrl.v"
`include "../rtl/Control/AddrLUT.v"
`include "../rtl/Macs/Macs.v"
`include "../rtl/Macs/PE.v"
`include "../sim/RAM/sync_ram.v"
module tb_matCtrl;

    reg clk,rstn;
    wire [11:0] mem0_addr_0,mem0_addr_1,mem1_addr_0,mem1_addr_1;
    wire mem0_wr_en_0,mem0_wr_en_1,mem1_wr_en_0,mem1_wr_en_1;
    wire [63:0] mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1;

// 例化ram
    sync_ram #(
    .ADDR_WIDTH(12),
    .DATA_WIDTH(64),
    .DEPTH(1024),
    .LOAD_FILE_PATH(`A_LOAD_PATH),
    .STORE_FILE_PATH(`A_STORE_PATH),
    .TIME(`TIME)
    ) ram_A (
        .clk(clk),
        .rstn(rstn),
        .wr_en(mem0_wr_en_0),
        .rd_en(~mem0_wr_en_0),
        .addr(mem0_addr_0),
        .din(64'b0),
        .dout(mem0_rd_data_0)
    );

    sync_ram #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(64),
        .DEPTH(1024),
        .LOAD_FILE_PATH(`B_LOAD_PATH),
        .STORE_FILE_PATH(`B_STORE_PATH),
        .TIME(`TIME)
        ) ram_B (
            .clk(clk),
            .rstn(rstn),
            .wr_en(mem0_wr_en_1),
            .rd_en(~mem0_wr_en_1),
            .addr(mem0_addr_1),
            .din(64'b0),
            .dout(mem0_rd_data_1)
        );

    sync_ram #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(64),
        .DEPTH(1024),
        .LOAD_FILE_PATH(`C_LOAD_PATH),
        .STORE_FILE_PATH(`C_STORE_PATH),
        .TIME(`TIME)
        ) ram_C (
            .clk(clk),
            .rstn(rstn),
            .wr_en(mem1_wr_en_0),
            .rd_en(~mem1_wr_en_0),
            .addr(mem1_addr_0),
            .din(64'b0),
            .dout(mem1_rd_data_0)
        );
    
// 仿真需要给的信号
    reg [26:0]  inst;
    reg inst_valid;
    wire [15:0] A_data,B_data_0,B_data_1,B_data_2,B_data_3;
    wire [15:0] C_data_0,C_data_1,C_data_2,C_data_3;
    wire [15:0] D_data_0,D_data_1,D_data_2,D_data_3;
    wire macs_valid,mac_mode,macs_signal,macs_en;

    Macs  u_Macs (
    .clk                     ( clk       ),
    .rstn                    ( rstn      ),
    .A                       ( A_data         ),
    .B_0                     ( B_data_0       ),
    .B_1                     ( B_data_1       ),
    .B_2                     ( B_data_2       ),
    .B_3                     ( B_data_3       ),
    .C_0                     ( C_data_0       ),
    .C_1                     ( C_data_1       ),
    .C_2                     ( C_data_2       ),
    .C_3                     ( C_data_3       ),
    .en                      ( macs_en        ),
    .mode                    ( macs_mode      ),
    .signal                  ( macs_signal    ),

    .valid                   ( macs_valid     ),
    .result_0                ( D_data_0  ),
    .result_1                ( D_data_1  ),
    .result_2                ( D_data_2  ),
    .result_3                ( D_data_3  )
);




    matCtrl#(
            .INST_WIDTH ( 27 ),
            .ADDR_WIDTH ( 12 )
    )
        u_matCtrl (
            .clk                     ( clk              ),
            .rstn                    ( rstn             ),
            .inst                    ( inst             ),
            .inst_valid              ( inst_valid       ),
            .mem0_rd_data_0          ( mem0_rd_data_0   ),
            .mem0_rd_data_1          ( mem0_rd_data_1   ),
            .mem1_rd_data_0          ( mem1_rd_data_0   ),
            .mem1_rd_data_1          ( mem1_rd_data_1   ),
            .D_data_0                ( D_data_0         ),
            .D_data_1                ( D_data_1         ),
            .D_data_2                ( D_data_2         ),
            .D_data_3                ( D_data_3         ),
            .macs_valid              ( macs_valid       ),

            .mem0_addr_0             ( mem0_addr_0      ),
            .mem0_addr_1             ( mem0_addr_1      ),
            .mem1_addr_0             ( mem1_addr_0      ),
            .mem1_addr_1             ( mem1_addr_1      ),
            .mem0_wr_en_0            ( mem0_wr_en_0     ),
            .mem0_wr_en_1            ( mem0_wr_en_1     ),
            .mem1_wr_en_0            ( mem1_wr_en_0     ),
            .mem1_wr_en_1            ( mem1_wr_en_1     ),
            .A_data                  ( A_data           ),
            .B_data_0                ( B_data_0         ),
            .B_data_1                ( B_data_1         ),
            .B_data_2                ( B_data_2         ),
            .B_data_3                ( B_data_3         ),
            .C_data_0                ( C_data_0         ),
            .C_data_1                ( C_data_1         ),
            .C_data_2                ( C_data_2         ),
            .C_data_3                ( C_data_3         ),
            // .mem0_wr_data_0          ( mem0_wr_data_0   ),
            // .mem0_wr_data_1          ( mem0_wr_data_1   ),
            // .mem1_wr_data_0          ( mem1_wr_data_0   ),
            // .mem1_wr_data_1          ( mem1_wr_data_1   ),
            .macs_mode               ( macs_mode        ),
            .macs_signal             ( macs_signal      ),
            .macs_en                 ( macs_en          )
        );
    parameter PERIOD = 10;

    initial
        begin
            forever #(PERIOD/2)  clk=~clk;
        end

    initial
        begin
            #(PERIOD*2) rstn  =  1;
        end

    initial begin
        $dumpfile("wave/matCtrl.vcd");
        $dumpvars(0, tb_matCtrl);
        clk = 1;
        rstn = 0;
        #40
        inst_valid = 1;
        inst = 27'b100_0000_0001_0010_1000_0001_0001;
        #`TIME
        $finish;
    end


endmodule