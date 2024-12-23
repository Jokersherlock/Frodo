module AGU (      //想不到叫什么其他名字了
    input        clk,
    input        rstn,
    
    input [1:0]  mode,
    input        change_enable,

    input [3:0]  target_index,
    input [3:0]  source_index_0,
    input [3:0]  source_index_1,   // 操作矩阵索引

    // 来自ram或者shake模块的数据，以及写入ram的数据
    input [63:0] rd_data_0,
    input [63:0] rd_data_1, 
    input [63:0] rd_data_2,
    output [63:0] wr_data,

    output [12:0] rd_addr_0,
    output [12:0] rd_addr_1,
    output [12:0] rd_addr_2,
    output [12:0] wr_addr,

    // mac的计算结果
    input [15:0] mac_data_0,
    input [15:0] mac_data_1,
    input [15:0] mac_data_2,
    input [15:0] mac_data_3,

    output [15:0] mac_A,
    output [63:0] mac_B,
    output [63:0] mac_C

);


    // 先考虑矩阵乘法的地址生成，再考虑进行复用


    // 循环变量
    reg [11:0] i;
    reg [9:0] k_0;
    reg [2:0] k_1;
    reg [9:0] j;

    // 循环变量的上界，由mode和输入决定，组合逻辑实现
    wire [11:0] i_ceil;
    wire [9:0] k_0_ceil;
    wire [2:0] k_1_ceil;
    wire [9:0] j_ceil; 

    localparam I_LOOP = 3'b000;
    localparam K_0_LOOP = 3'b001;
    localparam K_1_LOOP = 3'b010;   
    localparam J_LOOP = 3'b011;

    
    
    



    
endmodule