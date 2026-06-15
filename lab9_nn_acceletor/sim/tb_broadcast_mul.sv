`timescale 1ns/1ps
`include "../parameters.v"
module tb_broadcast_mul();

parameter DATA_WIDTH    = `DATA_WIDTH;
parameter SUM_WIDTH     = `SUM_WIDTH;
parameter PE_ROWS       = `BC_PE_ROWS;    //输出矩阵的行数（矩阵A的行数 M）
parameter PE_COLS       = `BC_PE_COLS;    //输出矩阵的列数（矩阵B的列数 N）
parameter INNER_DIM     = `BC_INNER_DIM;  //内维度 K（矩阵A的列数 = 矩阵B的行数）


reg                  clk;
reg                  rst_n;
reg [DATA_WIDTH-1:0] i_a_col [PE_ROWS];  //输入矩阵A的一列数据
reg [DATA_WIDTH-1:0] i_b_row [PE_COLS];  //输入矩阵B的一行数据
wire [SUM_WIDTH-1:0] o_c [PE_ROWS][PE_COLS];
wire                 o_valid;

reg [$clog2(INNER_DIM + 2) - 1:0] calc_cnt;
reg [DATA_WIDTH-1:0] a_matrix [INNER_DIM][PE_ROWS]; //按列存储矩阵A: a_matrix[k][i] = A[i][k]
reg [DATA_WIDTH-1:0] b_matrix [INNER_DIM][PE_COLS]; //按行存储矩阵B: b_matrix[k][j] = B[k][j]

initial begin
    // A 矩阵 (3×3)，按列存储
    // A = [ 1,  2,  3]   row 0
    //     [ 4,  5,  6]   row 1
    //     [ 7,  8,  9]   row 2
    a_matrix = '{'{1, 4, 7}, // 第0列的元素
               '{2, 5, 8}, // 第1列的元素
               '{3, 6, 9}  // 第2列的元素
              };
    // B 矩阵 (3×3)，按行存储
    // B = [ 9,  8,  7]   row 0
    //     [ 6,  5,  4]   row 1
    //     [ 3,  2,  1]   row 2
    b_matrix = '{'{9, 8, 7}, // 第0行的元素
               '{6, 5, 4}, // 第1行的元素
               '{3, 2, 1}  // 第2行的元素
              };
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
        if(calc_cnt == INNER_DIM + 2 - 1)
            calc_cnt <= 0;
        else
            calc_cnt <= calc_cnt + 1'd1;
    end
end

// 在外积迭代阶段，依次加载矩阵 A 的各列数据
// calc_cnt >= 1 && <= INNER_DIM 即 COMPUTE 阶段，输入 A[:, calc_cnt-1]
// HOLD 和 CLEAR 阶段输入 0，避免错误累加
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < PE_ROWS; i++)
            i_a_col[i] <= 0;
    end
    else begin
        for(int i = 0; i < PE_ROWS; i++)
            i_a_col[i] <= (calc_cnt >= 1 && calc_cnt <= INNER_DIM) ? a_matrix[calc_cnt - 1][i] : 0;
    end
end

// 在外积迭代阶段，依次加载矩阵 B 的各行数据
// calc_cnt >= 1 && <= INNER_DIM 即 COMPUTE 阶段，输入 B[calc_cnt-1, :]
// HOLD 和 CLEAR 阶段输入 0，避免错误累加
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for (int j = 0; j < PE_COLS; j++)
            i_b_row[j] <= 0;
    end
    else begin
        for(int j = 0; j < PE_COLS; j++)
            i_b_row[j] <= (calc_cnt >= 1 && calc_cnt <= INNER_DIM) ? b_matrix[calc_cnt - 1][j] : 0;
    end
end

broadcast_mul_core #(
    .DATA_WIDTH     (`DATA_WIDTH),
    .SUM_WIDTH      (`SUM_WIDTH ),
    .PE_ROWS        (`BC_PE_ROWS),
    .PE_COLS        (`BC_PE_COLS),
    .INNER_DIM      (`BC_INNER_DIM)
) u_broadcast_mul (
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .i_a_col    (i_a_col    ),
    .i_b_row    (i_b_row    ),
    .o_c        (o_c        ),
    .o_valid    (o_valid    )
);

endmodule
