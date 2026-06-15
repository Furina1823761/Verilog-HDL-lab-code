/*
    created date: 2026-06-05
    架构概述：
    1. 数据流: 外积 C = Σ(k=0..K-1) A[:,k] × B[k,:]
       - 每周期输入矩阵 A 的一列（M 个元素）和矩阵 B 的一行（N 个元素）
       - 广播到 PE 阵列 (M×N) 的所有单元并行计算
       - 遍历 K 次外积迭代得到最终结果
    2. 接口说明:
       - i_a_col[i]: 矩阵 A 第 i 行的元素（当前外积迭代列的对应行元素）
       - i_b_row[j]: 矩阵 B 第 j 列的元素（当前外积迭代行的对应列元素）
       - o_c[i][j]: 输出矩阵 C 的元素 C[i][j]
*/
`include "../../parameters.v"
module broadcast_mul_core #(
    parameter DATA_WIDTH = `DATA_WIDTH   ,
    parameter SUM_WIDTH  = `SUM_WIDTH    ,
    parameter PE_ROWS    = `BC_PE_ROWS   , // 矩阵A的行数 = 输出矩阵C的行数 M
    parameter PE_COLS    = `BC_PE_COLS   , // 矩阵B的列数 = 输出矩阵C的列数 N
    parameter INNER_DIM  = `BC_INNER_DIM   // 内维度 K = 矩阵A的列数 = 矩阵B的行数
)(
    input                       clk                             ,
    input                       rst_n                           ,
    input   signed [DATA_WIDTH-1:0]    i_a_col [PE_ROWS]              , // 输入矩阵A的一列数据 (M 个元素)
    input   signed [DATA_WIDTH-1:0]    i_b_row [PE_COLS]              , // 输入矩阵B的一行数据 (N 个元素)
    output  signed [SUM_WIDTH-1:0]     o_c     [PE_ROWS][PE_COLS]     , // 输出矩阵C的结果 (M×N, 并行输出)
    output                      o_valid                          // 计算结果有效指示
);

    // PE 工作模式
    localparam  CLEAR   = 2'd0;     
    localparam  COMPUTE = 2'd1;     

    wire [1:0] ctrl;    

    // 外积迭代控制器
    broadcast_ctrl #(
        .INNER_DIM  (INNER_DIM)
    ) u_broadcast_ctrl (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .ctrl       ( ctrl       ),
        .o_valid    ( o_valid    )
    );

    // PE 二维阵列
    //   同行 PE 共享 a_bus[i]（矩阵A 列元素广播）
    //   同列 PE 共享 b_bus[j]（矩阵B 行元素广播）
    //   K 次外积迭代后并行输出全部结果
    broadcast_pe_array #(
        .DATA_WIDTH (DATA_WIDTH),
        .SUM_WIDTH  (SUM_WIDTH ),
        .PE_ROWS    (PE_ROWS   ),
        .PE_COLS    (PE_COLS   )
    ) u_broadcast_pe_array (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .ctrl       ( ctrl       ),
        .a_bus      ( i_a_col    ),
        .b_bus      ( i_b_row    ),
        .results    ( o_c        )
    );

endmodule
