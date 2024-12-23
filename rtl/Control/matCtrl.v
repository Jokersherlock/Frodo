module matCtrl
#(  
    parameter   INST_WIDTH = 27,
    parameter   ADDR_WIDTH = 12
) 
(
    input                           clk,
    input                           rstn,

    input       [INST_WIDTH-1:0]    inst, // instruction
    input                           inst_valid, // instruction valid

    // 读出mem的数据
    input       [63:0]              mem0_rd_data_0,
    input       [63:0]              mem0_rd_data_1,
    input       [63:0]              mem1_rd_data_0,
    input       [63:0]              mem1_rd_data_1,

    output reg  [ADDR_WIDTH-1:0]    mem0_addr_0,
    output reg  [ADDR_WIDTH-1:0]    mem0_addr_1,
    output reg  [ADDR_WIDTH-1:0]    mem1_addr_0,
    output reg  [ADDR_WIDTH-1:0]    mem1_addr_1,

    output reg                      mem0_wr_en_0,
    output reg                      mem0_wr_en_1,
    output reg                      mem1_wr_en_0,
    output reg                      mem1_wr_en_1,


    // 来自mac的数据
    output reg  [15:0]              A_data,
    output reg  [15:0]              B_data_0,
    output reg  [15:0]              B_data_1,
    output reg  [15:0]              B_data_2,
    output reg  [15:0]              B_data_3,
    output reg  [15:0]              C_data_0,
    output reg  [15:0]              C_data_1,
    output reg  [15:0]              C_data_2,
    output reg  [15:0]              C_data_3,
    input       [15:0]              D_data_0,
    input       [15:0]              D_data_1,
    input       [15:0]              D_data_2,
    input       [15:0]              D_data_3,

    // 写入mem的数据，需要选择
    output      [63:0]              mem0_wr_data_0,
    output      [63:0]              mem0_wr_data_1,
    output      [63:0]              mem1_wr_data_0,
    output      [63:0]              mem1_wr_data_1,

    input                           macs_valid, // macs数据有效
    output                          macs_mode,  // macs模式，0为乘法，1为加法
    output                          macs_signal, // macs符号信号，0为正，1为负
    output reg                      macs_en    // macs使能信号
);  

    parameter IDLE      = 3'b000;  //待机状态
    parameter IF        = 3'b001;  // 指令取值阶段
    parameter ID        = 3'b010;  // 指令译码阶段
    parameter ROW       = 3'b011;  // 左矩阵行号增加阶段
    parameter COL       = 3'b100;  // 左矩阵列号增加阶段,同时读取左矩阵的数据
    parameter BIA       = 3'b101;  // 左矩阵块内偏移量增加阶段
    parameter COMP      = 3'b110;  // 计算阶段，右矩阵地址累加
    parameter FINISH    = 3'b111;  // 完成状态


    reg [2:0] state, next_state;
    reg [INST_WIDTH-1:0] inst_reg;

    reg [ADDR_WIDTH+1:0] A_addr, B_addr, C_addr;

    reg [3:0] lut_index; // 查表索引
    reg [1:0] lut_cnt;   // 查表计数
    wire [ADDR_WIDTH+1:0] lut_addr; // 查表地址
    
    reg A_width_flag,B_width_flag; // 左右矩阵位宽标志位,0为16位，1位8位


    // macs 控制信号
    assign macs_mode = inst_reg[INST_WIDTH-2:INST_WIDTH-3];
    assign macs_signal = inst_reg[INST_WIDTH-15];

    always @(*) begin
        if(state == COMP)begin
            macs_en = 1'b1;
        end
        else begin
            macs_en = 1'b0;
        end
    end

    reg [10:0] row;
    reg [8:0]  col;
    reg [2:0]  bia; // bias循环的计数器
    reg [8:0]  comp;

    reg [10:0] row_limit;
    reg [8:0]  col_limit;
    wire [2:0]  bia_limit; 
    reg [8:0]  comp_limit;


    // 状态机
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always @(*) begin
        case (state)
            IDLE: begin
                next_state = IF;
            end
            IF: begin
                if(inst_valid)
                    next_state = ID;
                else
                    next_state = IF;
            end
            ID: begin
                if(lut_cnt == 2'b10)
                    next_state = COMP;
                else
                    next_state = ID;
            end
            ROW:begin
                if(row == row_limit)
                    next_state = FINISH;
                else
                    next_state = COMP;
            end
            COL:begin
                if(col == col_limit)
                    next_state = ROW;
                else
                    next_state = COMP;
            end
            BIA:begin
                if(bia == bia_limit)
                    next_state = COL;
                else
                    next_state = COMP;
            end
            COMP:begin
                if(comp == comp_limit)
                    next_state = BIA;
                else 
                    next_state = COMP;
            end
        endcase
    end



    // inst_reg  取指阶段取指
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            inst_reg <= 0;
        end
        else begin
            case (state)
                IF: begin
                    inst_reg <= inst;
                end
            endcase
        end
    end

    // 译码获取循环边界，每个4位，首位是1代表是1344

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            row_limit  <= 11'b0;
            col_limit  <= 9'b0;
           // bia_limit  <= 3'b0;
            comp_limit <= 9'b0;
        end
        else begin
            if(state == ID) begin
                row_limit <= inst_reg[INST_WIDTH-16] ? 11'd15 : {8'b0,inst_reg[INST_WIDTH-17:INST_WIDTH-19]};
                col_limit <= inst_reg[INST_WIDTH-20] ? 11'd335 : {8'b0,inst_reg[INST_WIDTH-21:INST_WIDTH-23]};
                comp_limit <= inst_reg[INST_WIDTH-24] ? 11'd335 : {8'b0,inst_reg[INST_WIDTH-25:INST_WIDTH-27]};
            end
        end
    end

    assign bia_limit = A_width_flag? 3'd7 : 3'd3;  // 有待商榷
    // row_cnt
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            row <= 11'b0;
        end
        else begin
            case (state)
                ID: begin
                    row <= 11'b0;
                end
                ROW: begin
                    if(row == row_limit)begin
                        row <= 11'b0;
                    end
                    else begin
                        row <= row + 11'b1;
                    end
                end
            endcase
        end
    end

    // col_cnt
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            col <= 9'b0;
        end
        else begin
            case (state)
                ID: col <= 9'b0;
                ROW: col<= 9'b0;
                COL: begin
                    if(col == col_limit)begin
                        col <= 9'b0;
                    end
                    else begin
                        col <= col + 9'b1;
                    end
                end
            endcase
        end
    end

    // bia_cnt
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            bia <= 3'b0;
        end
        else begin
            case (state)
                ID: bia <= 3'b0;
                ROW: bia <=3'b0;
                COL: bia <= 3'b0;
                BIA: begin
                    if(bia == bia_limit)begin
                        bia <= 3'b0;
                    end
                    else begin
                        bia <= bia + 3'b1;
                    end
                end
            endcase
        end
    end
    // comp_cnt
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            comp <= 9'b0;
        end
        else begin
            case (state)
                ID: comp <= 9'b0;
                ROW:comp <= 9'b0;
                COL:comp <= 9'b0;
                BIA:comp <= 9'b0;
                COMP:begin
                    if(macs_valid)begin
                        if(comp==comp_limit)begin
                            comp <= 9'b0;
                        end
                        else begin
                            comp <= comp + 9'b1;
                        end
                    end
                end
            endcase
        end
    end


    // decode address
    always @(*) begin
        case (lut_cnt)
            2'b00: lut_index = inst_reg[INST_WIDTH-4:INST_WIDTH-7];
            2'b01: lut_index = inst_reg[INST_WIDTH-8:INST_WIDTH-11];
            2'b10: lut_index = inst_reg[INST_WIDTH-12:INST_WIDTH-15];
            2'b11: lut_index = 13'b0;
        endcase
    end

    always @(*) begin
        case (inst_reg[INST_WIDTH-4:INST_WIDTH-7])
            4'b1111:  A_width_flag = 1'b1;
            default:  A_width_flag = 1'b0; 
        endcase
    end

    always @(*) begin
        case (inst_reg[INST_WIDTH-8:INST_WIDTH-11])
            4'b1111:  B_width_flag = 1'b1;
            default:  B_width_flag = 1'b0; 
        endcase
    end


    AddrLUT u_AddrLUT (
        .index(lut_index),
        .addr(lut_addr)
    );
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            lut_cnt <= 2'b0;
            A_addr <= 14'b0;
            B_addr <= 14'b0;
            C_addr <= 14'b0;
        end
        else begin
            if(state == ID) begin
                lut_cnt <= lut_cnt + 2'b1;
                // case (lut_cnt)
                //     2'b00: A_addr <= lut_addr;
                //     2'b01: B_addr <= lut_addr;
                //     2'b10: C_addr <= lut_addr;
                // endcase
            end
            else
                lut_cnt <= 2'b0;
        end
    end

    // 右矩阵读地址

    reg B_width_cnt; // 右矩阵单次读取计数器
    reg [ADDR_WIDTH+1:0] B_addr_start; // 右矩阵起始地址
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            B_addr <= 13'b0;
            B_width_cnt <= 1'b0;
        end
        else begin
            case (state)
                ID: begin
                    B_width_cnt <= 1'b0;
                    if(lut_cnt == 2'b01)
                        B_addr <= lut_addr;
                end
                // 最内层循环，右矩阵地址每次进行累加，
                COMP: begin
                    if(macs_valid) begin  // macs数据有效时更新地址
                        if(!B_width_flag)begin //数据位宽为16，计算完成地址立即加
                            B_addr <= B_addr + 13'b1;
                        end
                        else begin        //数据位宽为8，每两次计算完成地址加1
                            B_width_cnt <= ~B_width_cnt;
                          if(B_width_cnt)begin
                            B_addr <= B_addr + 13'b1;
                          end
                        end
                    end
                end
                // 当A的一行结束时，B矩阵的首地址需要归位
                ROW: begin
                    B_addr <= B_addr_start;
                    B_width_cnt <= 1'b0; // 也许是冗余代码
                end
            endcase
        end
    end

    // 左矩阵读地址
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            A_addr <= 13'b0;
        end
        else begin
            case (state)
                ID: begin
                    if(lut_cnt == 2'b00)
                        A_addr <= lut_addr;
                end
                // 左矩阵列号增加时地址增加
                COL: begin
                    A_addr <= A_addr + 13'b1;
                end
            endcase
        end
    end

    // 加矩阵读地址，写地址
    reg [ADDR_WIDTH+1:0] C_addr_temp; // C矩阵暂存地址，记录每一行的首地址
    reg [ADDR_WIDTH+1:0] D_addr;   //写地址

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            C_addr <= 13'b0;
        end
        else begin
            case (state)
                ID: begin
                    if(lut_cnt == 2'b10)begin
                        C_addr <= lut_addr;
                        C_addr_temp <= lut_addr;
                    end
                end
                // 最内层循环，每次计算完成C矩阵地址都需要加一（所有C矩阵位宽均为16）
                COMP:begin
                    if(macs_valid)
                        C_addr <= C_addr + 13'b1;
                end
                // 右矩阵一行结束时，C矩阵需要还原行号
                BIA:
                    C_addr <= C_addr_temp;
                // 左矩阵一行结束时，C矩阵到下一行
                ROW:
                    C_addr_temp <= C_addr;
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            D_addr <= 14'b11_1111_1111_1111;
        end
        else begin
            if(state == COMP)
                D_addr <= {C_addr[ADDR_WIDTH+1],~C_addr[ADDR_WIDTH],C_addr[ADDR_WIDTH-1:0]};
        end
    end



    // 将地址转译到对应的RAM
    always @(*) begin
        if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b00) begin
            mem0_addr_0 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b00) begin
            mem0_addr_0 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(C_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b00) begin
            mem0_addr_0 = C_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem0_addr_0 = D_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b01) begin
            mem0_addr_1 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b01) begin
            mem0_addr_1 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(C_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b01) begin
            mem0_addr_1 = C_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem0_addr_1 = D_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b10) begin
            mem1_addr_0 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b10) begin
            mem1_addr_0 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(C_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b10) begin
            mem1_addr_0 = C_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem1_addr_0 = D_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b11) begin
            mem1_addr_1 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b11) begin
            mem1_addr_1 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(C_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b11) begin
            mem1_addr_1 = C_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem1_addr_1 = D_addr[ADDR_WIDTH-1:0];
        end
    end

    // 数据读取
    //A_data
    // reg [63:0] A_data_reg;

    always @(*) begin
        case (A_addr[ADDR_WIDTH+1:ADDR_WIDTH])
            2'b00: begin
                // 位宽为8
                if(A_width_flag)begin
                    case (bia)
                        3'b000: A_data = {{8{mem0_rd_data_0[7]}},mem0_rd_data_0[7:0]};
                        3'b001: A_data = {{8{mem0_rd_data_0[15]}},mem0_rd_data_0[15:8]};
                        3'b010: A_data = {{8{mem0_rd_data_0[23]}},mem0_rd_data_0[23:16]};
                        3'b011: A_data = {{8{mem0_rd_data_0[31]}},mem0_rd_data_0[31:24]};
                        3'b100: A_data = {{8{mem0_rd_data_0[24]}},mem0_rd_data_0[39:32]};
                        3'b101: A_data = {{8{mem0_rd_data_0[47]}},mem0_rd_data_0[47:40]};
                        3'b110: A_data = {{8{mem0_rd_data_0[55]}},mem0_rd_data_0[55:48]};
                        3'b111: A_data = {{8{mem0_rd_data_0[63]}},mem0_rd_data_0[63:56]};
                    endcase
                end
                else begin
                    case (bia)
                        3'b000: A_data = mem0_rd_data_0[15:0];
                        3'b001: A_data = mem0_rd_data_0[31:16];
                        3'b010: A_data = mem0_rd_data_0[47:32];
                        3'b001: A_data = mem0_rd_data_0[63:48];
                        3'b100: A_data = mem0_rd_data_0[15:0];
                        3'b101: A_data = mem0_rd_data_0[31:16];
                        3'b110: A_data = mem0_rd_data_0[47:32];
                        3'b111: A_data = mem0_rd_data_0[63:48];
                    endcase
                end
            end
            2'b01: begin
                // 位宽为8
                if(A_width_flag)begin
                    case (bia)
                        3'b000: A_data = {{8{mem0_rd_data_1[7]}},mem0_rd_data_1[7:0]};
                        3'b001: A_data = {{8{mem0_rd_data_1[15]}},mem0_rd_data_1[15:8]};
                        3'b010: A_data = {{8{mem0_rd_data_1[23]}},mem0_rd_data_1[23:16]};
                        3'b011: A_data = {{8{mem0_rd_data_1[31]}},mem0_rd_data_1[31:24]};
                        3'b100: A_data = {{8{mem0_rd_data_1[39]}},mem0_rd_data_1[39:32]};
                        3'b101: A_data = {{8{mem0_rd_data_1[47]}},mem0_rd_data_1[47:40]};
                        3'b110: A_data = {{8{mem0_rd_data_1[55]}},mem0_rd_data_1[55:48]};
                        3'b111: A_data = {{8{mem0_rd_data_1[63]}},mem0_rd_data_1[63:56]};
                    endcase
                end
                else begin
                    case (bia)
                        3'b000: A_data = mem0_rd_data_1[15:0];
                        3'b001: A_data = mem0_rd_data_1[31:16];
                        3'b010: A_data = mem0_rd_data_1[47:32];
                        3'b001: A_data = mem0_rd_data_1[63:48];
                        3'b100: A_data = mem0_rd_data_1[15:0];
                        3'b101: A_data = mem0_rd_data_1[31:16];
                        3'b110: A_data = mem0_rd_data_1[47:32];
                        3'b111: A_data = mem0_rd_data_1[63:48];
                    endcase
                end
            end
            2'b10: begin
                // 位宽为8
                if(A_width_flag)begin
                    case (bia)
                        3'b000: A_data = {{8{mem1_rd_data_0[7]}},mem1_rd_data_0[7:0]};
                        3'b001: A_data = {{8{mem1_rd_data_0[15]}},mem1_rd_data_0[15:8]};
                        3'b010: A_data = {{8{mem1_rd_data_0[23]}},mem1_rd_data_0[23:16]};
                        3'b011: A_data = {{8{mem1_rd_data_0[31]}},mem1_rd_data_0[31:24]};
                        3'b100: A_data = {{8{mem1_rd_data_0[24]}},mem1_rd_data_0[39:32]};
                        3'b101: A_data = {{8{mem1_rd_data_0[47]}},mem1_rd_data_0[47:40]};
                        3'b110: A_data = {{8{mem1_rd_data_0[55]}},mem1_rd_data_0[55:48]};
                        3'b111: A_data = {{8{mem1_rd_data_0[63]}},mem1_rd_data_0[63:56]};
                    endcase
                end
                else begin
                    case (bia)
                        3'b000: A_data = mem1_rd_data_0[15:0];
                        3'b001: A_data = mem1_rd_data_0[31:16];
                        3'b010: A_data = mem1_rd_data_0[47:32];
                        3'b001: A_data = mem1_rd_data_0[63:48];
                        3'b100: A_data = mem1_rd_data_0[15:0];
                        3'b101: A_data = mem1_rd_data_0[31:16];
                        3'b110: A_data = mem1_rd_data_0[47:32];
                        3'b111: A_data = mem1_rd_data_0[63:48];
                    endcase
                end
            end
            2'b11: begin
                // 位宽为8
                if(A_width_flag)begin
                    case (bia)
                        3'b000: A_data = {{8{mem1_rd_data_1[7]}},mem1_rd_data_1[7:0]};
                        3'b001: A_data = {{8{mem1_rd_data_1[15]}},mem1_rd_data_1[15:8]};
                        3'b010: A_data = {{8{mem1_rd_data_1[23]}},mem1_rd_data_1[23:16]};
                        3'b011: A_data = {{8{mem1_rd_data_1[31]}},mem1_rd_data_1[31:24]};
                        3'b100: A_data = {{8{mem1_rd_data_1[24]}},mem1_rd_data_1[39:32]};
                        3'b101: A_data = {{8{mem1_rd_data_1[47]}},mem1_rd_data_1[47:40]};
                        3'b110: A_data = {{8{mem1_rd_data_1[55]}},mem1_rd_data_1[55:48]};
                        3'b111: A_data = {{8{mem1_rd_data_1[63]}},mem1_rd_data_1[63:56]};
                    endcase
                end
                else begin
                    case (bia)
                        3'b000: A_data = mem1_rd_data_1[15:0];
                        3'b001: A_data = mem1_rd_data_1[31:16];
                        3'b010: A_data = mem1_rd_data_1[47:32];
                        3'b001: A_data = mem1_rd_data_1[63:48];
                        3'b100: A_data = mem1_rd_data_1[15:0];
                        3'b101: A_data = mem1_rd_data_1[31:16];
                        3'b110: A_data = mem1_rd_data_1[47:32];
                        3'b111: A_data = mem1_rd_data_1[63:48];
                    endcase
                end
            end        
        endcase
    end
    

    //B_data

    always @(*) begin
        case (B_addr[ADDR_WIDTH+1:ADDR_WIDTH])
            2'b00: begin
                if(B_width_flag) begin
                    if(!B_width_cnt) begin
                        B_data_0 = {{8{mem0_rd_data_0[7]}},mem0_rd_data_0[7:0]};
                        B_data_1 = {{8{mem0_rd_data_0[15]}},mem0_rd_data_0[15:8]};
                        B_data_2 = {{8{mem0_rd_data_0[23]}},mem0_rd_data_0[23:16]};
                        B_data_3 = {{8{mem0_rd_data_0[31]}},mem0_rd_data_0[31:24]};
                    end
                    else begin
                        B_data_0 = {{8{mem0_rd_data_0[39]}},mem0_rd_data_0[39:32]};
                        B_data_1 = {{8{mem0_rd_data_0[47]}},mem0_rd_data_0[47:40]};
                        B_data_2 = {{8{mem0_rd_data_0[55]}},mem0_rd_data_0[55:48]};
                        B_data_3 = {{8{mem0_rd_data_0[63]}},mem0_rd_data_0[63:56]};
                    end  
                end
                else begin
                    B_data_0 = mem0_rd_data_0[15:0];
                    B_data_1 = mem0_rd_data_0[31:16];
                    B_data_2 = mem0_rd_data_0[47:32];
                    B_data_3 = mem0_rd_data_0[63:48];
                end
            end
            2'b01: begin
                if(B_width_flag) begin
                    if(!B_width_cnt) begin
                        B_data_0 = {{8{mem0_rd_data_1[7]}},mem0_rd_data_1[7:0]};
                        B_data_1 = {{8{mem0_rd_data_1[15]}},mem0_rd_data_1[15:8]};
                        B_data_2 = {{8{mem0_rd_data_1[23]}},mem0_rd_data_1[23:16]};
                        B_data_3 = {{8{mem0_rd_data_1[31]}},mem0_rd_data_1[31:24]};
                    end
                    else begin
                        B_data_0 = {{8{mem0_rd_data_1[39]}},mem0_rd_data_1[39:32]};
                        B_data_1 = {{8{mem0_rd_data_1[47]}},mem0_rd_data_1[47:40]};
                        B_data_2 = {{8{mem0_rd_data_1[55]}},mem0_rd_data_1[55:48]};
                        B_data_3 = {{8{mem0_rd_data_1[63]}},mem0_rd_data_1[63:56]};
                    end  
                end
                else begin
                    B_data_0 = mem0_rd_data_1[15:0];
                    B_data_1 = mem0_rd_data_1[31:16];
                    B_data_2 = mem0_rd_data_1[47:32];
                    B_data_3 = mem0_rd_data_1[63:48];
                end
            end
            2'b10: begin
                if(B_width_flag) begin
                    if(!B_width_cnt) begin
                        B_data_0 = {{8{mem1_rd_data_0[7]}},mem1_rd_data_0[7:0]};
                        B_data_1 = {{8{mem1_rd_data_0[15]}},mem1_rd_data_0[15:8]};
                        B_data_2 = {{8{mem1_rd_data_0[23]}},mem1_rd_data_0[23:16]};
                        B_data_3 = {{8{mem1_rd_data_0[31]}},mem1_rd_data_0[31:24]};
                    end
                    else begin
                        B_data_0 = {{8{mem1_rd_data_0[39]}},mem1_rd_data_0[39:32]};
                        B_data_1 = {{8{mem1_rd_data_0[47]}},mem1_rd_data_0[47:40]};
                        B_data_2 = {{8{mem1_rd_data_0[55]}},mem1_rd_data_0[55:48]};
                        B_data_3 = {{8{mem1_rd_data_0[63]}},mem1_rd_data_0[63:56]};
                    end  
                end
                else begin
                    B_data_0 = mem1_rd_data_0[15:0];
                    B_data_1 = mem1_rd_data_0[31:16];
                    B_data_2 = mem1_rd_data_0[47:32];
                    B_data_3 = mem1_rd_data_0[63:48];
                end
            end
            2'b11: begin
                if(B_width_flag) begin
                    if(!B_width_cnt) begin
                        B_data_0 = {{8{mem1_rd_data_1[7]}},mem1_rd_data_1[7:0]};
                        B_data_1 = {{8{mem1_rd_data_1[15]}},mem1_rd_data_1[15:8]};
                        B_data_2 = {{8{mem1_rd_data_1[23]}},mem1_rd_data_1[23:16]};
                        B_data_3 = {{8{mem1_rd_data_1[31]}},mem1_rd_data_1[31:24]};
                    end
                    else begin
                        B_data_0 = {{8{mem1_rd_data_1[39]}},mem1_rd_data_1[39:32]};
                        B_data_1 = {{8{mem1_rd_data_1[47]}},mem1_rd_data_1[47:40]};
                        B_data_2 = {{8{mem1_rd_data_1[55]}},mem1_rd_data_1[55:48]};
                        B_data_3 = {{8{mem1_rd_data_1[63]}},mem1_rd_data_1[63:56]};
                    end  
                end
                else begin
                    B_data_0 = mem1_rd_data_1[15:0];
                    B_data_1 = mem1_rd_data_1[31:16];
                    B_data_2 = mem1_rd_data_1[47:32];
                    B_data_3 = mem1_rd_data_1[63:48];
                end
            end           
        endcase
    end

    always @(*) begin
        case (C_addr[ADDR_WIDTH+1:ADDR_WIDTH])
            2'b00: begin
                C_data_0 = mem0_rd_data_0[15:0];
                C_data_1 = mem0_rd_data_0[31:16];
                C_data_2 = mem0_rd_data_0[47:32];
                C_data_3 = mem0_rd_data_0[63:48];
            end
            2'b01: begin
                C_data_0 = mem0_rd_data_1[15:0];
                C_data_1 = mem0_rd_data_1[31:16];
                C_data_2 = mem0_rd_data_1[47:32];
                C_data_3 = mem0_rd_data_1[63:48];
            end
            2'b10: begin
                C_data_0 = mem1_rd_data_0[15:0];
                C_data_1 = mem1_rd_data_0[31:16];
                C_data_2 = mem1_rd_data_0[47:32];
                C_data_3 = mem1_rd_data_0[63:48];
            end
            2'b11: begin
                C_data_0 = mem1_rd_data_1[15:0];
                C_data_1 = mem1_rd_data_1[31:16];
                C_data_2 = mem1_rd_data_1[47:32];
                C_data_3 = mem1_rd_data_1[63:48];
            end
        endcase
    end

    // 读写使能信号
    always @(*) begin
        if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH]==2'b00 & state == COMP)
            mem0_wr_en_0 = 1'b1;
        else
            mem0_wr_en_0 = 1'b0;
    end
    always @(*) begin
        if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH]==2'b01 & state == COMP)
            mem0_wr_en_1 = 1'b1;
        else
            mem0_wr_en_1 = 1'b0;
    end
    always @(*) begin
        if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH]==2'b10 & state == COMP)
            mem1_wr_en_0 = 1'b1;
        else
            mem1_wr_en_0 = 1'b0;
    end
    always @(*) begin
        if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH]==2'b11 & state == COMP)
            mem1_wr_en_1 = 1'b1;
        else
            mem1_wr_en_1 = 1'b0;
    end



endmodule