`timescale 1ps/1ps
`include "../RAM/sync_ram.v"
module tb_sync_ram;

    // sync_ram Parameters
    parameter PERIOD      = 10     ;
    parameter ADDR_WIDTH  = 12     ;
    parameter DATA_WIDTH  = 64     ;
    parameter DEPTH       = 1024    ;
    parameter FILE_PATH   = "F:/project/Frodo/sim/RAM/data/A.hex";

    // sync_ram Inputs
    reg   clk                                  = 0 ;
    reg   rstn                                 = 0 ;
    reg   wr_en                                = 0 ;
    reg   rd_en                                = 0 ;
    reg   [ADDR_WIDTH-1:0]  addr               = 0 ;
    reg   [DATA_WIDTH-1:0]  din                = 0 ;

    // sync_ram Outputs
    wire  [DATA_WIDTH-1:0]  dout               ;
    wire [15:0] data_0,data_1,data_2,data_3;
    assign data_0 = dout[15:0];
    assign data_1 = dout[31:16];
    assign data_2 = dout[47:32];
    assign data_3 = dout[63:48];
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            addr <= 12'b0;
        else begin
            if(rd_en)
                addr <= addr + 12'b1;
        end
    end


    initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        #(PERIOD*2) rstn  =  1;
    end

    sync_ram #(
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DATA_WIDTH ( DATA_WIDTH ),
        .DEPTH      ( DEPTH      ))
    u_sync_ram (
        .clk                     ( clk                     ),
        .rstn                    ( rstn                    ),
        .wr_en                   ( wr_en                   ),
        .rd_en                   ( rd_en                   ),
        .addr                    ( addr    ),
        .din                     ( din     ),

        .dout                    ( dout    )
    );

    initial
    begin
        $dumpfile("ram.vcd");
        $dumpvars(0,tb_sync_ram);
        clk=1;
        rstn=0;
        #40;
        rd_en = 1;
        #1000;
        $finish;
    end

endmodule