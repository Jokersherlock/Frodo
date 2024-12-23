module AGU_mac (
    input clk,
    input rstn,

    input [15:0] mac_data_0,
    input [15:0] mac_data_1,
    input [15:0] mac_data_2,
    input [15:0] mac_data_3,  // 来自MAC模块的16bit输入数据

    output [11:0] rd_addr_0,  // 读地址0
    output [11:0] rd_addr_1,  // 读地址1
    output [11:0] rd_addr_2, // 读地址2
    output [11:0] wr_addr,    // 写地址

    input  [63:0] rd_data_0,  // 读数据0,提供为矩阵乘法单元的A
    input  [63:0] rd_data_1,  // 读数据1,提供为矩阵乘法单元的B
    input  [63:0] rd_data_2,  // 读数据2,提供为矩阵乘法单元的C
    output [63:0] wr_data,     // 写数据

    input  shake_valid        // shake有效信号
);

    reg [11:0] i;
    reg [9:0] k_0;
    reg [2:0] k_1;
    reg [9:0] j;

    reg clk_cnt; // 考虑到乘加器2个周期出结果，用于分频

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            clk_cnt <= 0;
        else
            clk_cnt <= ~clk_cnt;
    end

    localparam IDLE = 3'b000;
    localparam I_LOOP = 3'b001;
    localparam K_0_LOOP = 3'b010;
    localparam K_1_LOOP = 3'b011;   
    localparam J_LOOP = 3'b100;
    localparam WAIT = 3'b101;

    reg [2:0] state;
    wire [2:0] next_state;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: next_state = I_LOOP;
        endcase
    end


    
endmodule