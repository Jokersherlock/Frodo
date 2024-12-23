module sync_ram #(
    parameter ADDR_WIDTH = 12,    // 地址宽度
    parameter DATA_WIDTH = 64,    // 数据宽度
    parameter DEPTH = 256,        // RAM深度
    parameter LOAD_FILE_PATH = "F:/project/Frodo/sim/RAM/data/B.hex", // 文件路径，默认为B.hex
    parameter STORE_FILE_PATH = "ram.txt",
    parameter TIME  = 1000
)(
    input wire clk,               // 时钟信号
    input wire rstn,              // 复位信号（低有效）
    input wire wr_en,             // 写使能
    input wire rd_en,             // 读使能
    input wire [ADDR_WIDTH-1:0] addr,  // 地址输入
    input wire [DATA_WIDTH-1:0] din,   // 数据输入
    output reg [DATA_WIDTH-1:0] dout   // 数据输出
);

    // RAM存储数组
    reg [DATA_WIDTH-1:0] ram [0:DEPTH-1];

    // 通过initial块加载HEX文件中的初始数据
    initial begin
        $readmemh(LOAD_FILE_PATH, ram);  // 从给定的路径加载数据到RAM
    end

    // 同步读操作
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout <= 0;  // 复位时，数据输出为0
        end
        else if (rd_en) begin
            dout <= ram[addr];  // 读取数据
        end
    end

    // 同步写操作
    always @(posedge clk) begin
        if (wr_en) begin
            ram[addr] <= din;  // 写入数据
        end
    end

    integer ram_file;
    integer i;

    initial begin
        // 打开文件进行写操作
        ram_file = $fopen(STORE_FILE_PATH, "w");
        // 等待仿真完成后将RAM数据写入文件
        #TIME;  // 假设仿真运行10000个时钟周期
        for (i = 0; i < DEPTH; i = i + 1) begin
            // 将每个RAM单元的数据输出到文件
            $fwrite(ram_file, "%h\n", ram[i]);
        end
        // 关闭文件
        $fclose(ram_file);
    end



endmodule
