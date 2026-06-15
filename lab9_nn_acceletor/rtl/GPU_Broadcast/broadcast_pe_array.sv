/*
    created date: 2026-06-04

    GPU 广播架构 — PE 二维阵列

    连线特点（对比脉动阵列）：
    1. 水平广播总线: a_bus[i] 同时连接到第 i 行的所有 PE
       —— 矩阵 A 第 k 列的元素 A[i][k] 广播到第 i 行所有列
    2. 垂直广播总线: b_bus[j] 同时连接到第 j 列的所有 PE
       —— 矩阵 B 第 k 行的元素 B[k][j] 广播到第 j 列所有行
    3. 无 PE 间级联移位线（无 v_w / h_w 传播）
    4. 所有 PE 共享同一控制信号（同拍工作，非错拍流水线）

    外积数据流: 遍历 k = 0..K-1，每周期并行计算 C += A[:,k] × B[k,:]
*/
`include "../../parameters.v"
module broadcast_pe_array #(
    parameter DATA_WIDTH = `DATA_WIDTH ,
    parameter SUM_WIDTH  = `SUM_WIDTH  ,
    parameter PE_ROWS    = `BC_PE_ROWS , // PE 阵列行数（= 输出矩阵行数 M = A 的行数）
    parameter PE_COLS    = `BC_PE_COLS   // PE 阵列列数（= 输出矩阵列数 N = B 的列数）
)(
    input                       clk                             ,
    input                       rst_n                           ,
    input   [1:0]               ctrl                            , // 全局控制信号，所有 PE 同步
    input   signed [DATA_WIDTH-1:0]    a_bus  [PE_ROWS]               , // 同行广播输入: 矩阵A一列的各行元素
    input   signed [DATA_WIDTH-1:0]    b_bus  [PE_COLS]               , // 同列广播输入: 矩阵B一行的各列元素
    output  signed [SUM_WIDTH-1:0]     results [PE_ROWS][PE_COLS]       // 输出矩阵 C 的全部元素（并行输出）
);

    // 创建 PE 二维矩阵
    // 连线方式:
    //   - a_bus[i] 连接到第 i 行的每一个 PE 的 a_in（水平广播）
    //   - b_bus[j] 连接到第 j 列的每一个 PE 的 b_in（垂直广播）
    genvar i, j;
    generate
        for (i = 0; i < PE_ROWS; i = i + 1) begin : row_gen
            for (j = 0; j < PE_COLS; j = j + 1) begin : col_gen
                broadcast_pe #(
                    .DATA_WIDTH (DATA_WIDTH),
                    .SUM_WIDTH  (SUM_WIDTH )
                ) pe_inst (
                    .clk        ( clk            ),
                    .ctrl       ( ctrl           ),
                    .a_in       ( a_bus[i]       ), // 同行广播: 同一行 PE 接收相同 A 值
                    .b_in       ( b_bus[j]       ), // 同列广播: 同一列 PE 接收相同 B 值
                    .result     ( results[i][j]  )
                );
            end
        end
    endgenerate

endmodule
