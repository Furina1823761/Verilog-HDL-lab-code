/*
    created date: 2026-06-04

    GPU 广播架构 — 处理单元 (PE)

    与脉动阵列 PE 的区别：
    1. 无需 v_out / h_out 端口 —— 数据不通过 PE 级联传播
    2. 数据通过广播总线同时到达同行/同列所有 PE
    3. 控制仅需 CLEAR / COMPUTE 两种模式（无需 MOV_H 水平移位）
    4. 每个 PE 完成 C[i][j] = Σ A[i][k] × B[k][j] 的外积累加
*/
`include "../../parameters.v"
module broadcast_pe #(
    parameter DATA_WIDTH    = `DATA_WIDTH   ,
    parameter SUM_WIDTH     = `SUM_WIDTH
) (
    input                       clk      ,
    input   [1:0]               ctrl     , 
    input   signed [DATA_WIDTH-1:0]    a_in     , // 矩阵A的元素输入（来自同行广播总线）
    input   signed [DATA_WIDTH-1:0]    b_in     , // 矩阵B的元素输入（来自同列广播总线）
    output  signed [SUM_WIDTH-1:0]     result     // 外积累加结果 C[i][j]
);

    // PE 工作模式
    localparam  CLEAR   = 2'd0;     
    localparam  COMPUTE = 2'd1;     

    // 乘加位宽
    localparam MUL_WIDTH = 2 * DATA_WIDTH; // 乘法结果位宽 <= 数据位宽的两倍

    // 累加寄存器
    reg  signed [SUM_WIDTH-1:0]            s;

    // 乘加组合逻辑
    wire signed [MUL_WIDTH-1:0]            mul;
    wire signed [SUM_WIDTH-1:0]            add;       // 加法位宽与 s 相同，需在 parameters.v 中确保足够大以避免溢出
    assign mul = a_in * b_in;
    assign add = mul + s;

    always @(posedge clk) begin
        case (ctrl)
            CLEAR: begin
                s <= 0;                          // 新一轮外积累加前清零
            end
            COMPUTE: begin
                s <= add;                        // 乘累加: 累加当前外积项
            end
            default: begin
                s <= s;                          // 保持
            end
        endcase
    end
    assign  result = s;
    
endmodule
