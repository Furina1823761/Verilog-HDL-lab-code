`timescale 1ns/1ps
`include "../parameters.v"
module tb_matrix_mul();

parameter DATA_WIDTH    = `DATA_WIDTH; 
parameter SUM_WIDTH     = `SUM_WIDTH; 
parameter ARRAY_HEIGHT  = `PE_ROWS; 
parameter ARRAY_WIDTH   = `PE_COLS;


reg                  clk;  
reg                  rst_n;
reg [DATA_WIDTH-1:0] i_h [ARRAY_HEIGHT]; 
reg [DATA_WIDTH-1:0] i_v [ARRAY_WIDTH];
wire [SUM_WIDTH-1:0] o_h [ARRAY_HEIGHT];
wire                 o_valid;

reg [$clog2(4*ARRAY_HEIGHT)-1:0] calc_cnt;
reg [DATA_WIDTH-1:0] a_matrix [ARRAY_WIDTH][ARRAY_HEIGHT]; 

reg [DATA_WIDTH-1:0] b_matrix [ARRAY_HEIGHT][ARRAY_WIDTH];

initial begin
    a_matrix = '{'{1, 2, 3}, // 第一列的元素
                '{4, 5, 6}, // 第二列的元素
                '{7, 8, 9} // 第三列的元素
                }; 
    b_matrix = '{
                '{9, 8, 7}, // 第一行的元素
                '{6, 5, 4}, // 第二行的元素
                '{3, 2, 1} // 第三行的元素
                }; //输入矩阵 b
end

initial begin
    clk = 0; // 初始化时钟为低电平
    rst_n = 0; // 初始化复位信号为低电平（激活复位）
    #100 // 等待 100 个时间单位
    rst_n = 1; // 释放复位信号，开始正常工作
end

always #5 clk = ~clk;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        calc_cnt <= 0; // 复位时计数器清零
    else begin
        if(calc_cnt == 4 * ARRAY_HEIGHT - 1)
            calc_cnt <= 0;
        else
            calc_cnt <= calc_cnt + 1'd1;
    end
end 

// 在计算开始阶段，依次加载矩阵 A 的各行数据
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < ARRAY_HEIGHT; i++)
            i_h[i] <= 0;
    end 
    else begin 
        for(int i = 0; i < ARRAY_HEIGHT; i++)
            i_h[i] <= calc_cnt < ARRAY_WIDTH ?a_matrix[i][calc_cnt] : 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int j = 0; j < ARRAY_WIDTH; j++)
            i_v[j] <= 0;
    end 
    else begin 
        for(int j = 0; j < ARRAY_WIDTH; j++)
            i_v[j] <= calc_cnt < ARRAY_WIDTH ? b_matrix[calc_cnt][j] : 0;
    end
end

matrix_mul_core #(
    .DATA_WIDTH     (`DATA_WIDTH),
    .SUM_WIDTH      (`SUM_WIDTH ),
    .PE_ROWS        (`PE_ROWS   ),
    .PE_COLS        (`PE_COLS   )
) u_matric_mul (
    .clk        (clk    ),
    .rst_n      (rst_n  ),
    .i_h        (i_h    ), 
    .i_v        (i_v    ), 
    .o_h        (o_h    ), 
    .o_valid    (o_valid)
);

endmodule