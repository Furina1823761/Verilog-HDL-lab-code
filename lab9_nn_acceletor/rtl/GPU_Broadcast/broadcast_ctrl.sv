/*
    created date: 2026-06-04
*/
`include "../../parameters.v"
module broadcast_ctrl #(
    parameter INNER_DIM = `BC_INNER_DIM   // 内维度 K，即外积迭代次数
)(
    input               clk             ,
    input               rst_n           ,
    output  [1:0]       ctrl            , // 组合逻辑输出，与 calc_cnt 同步
    output              o_valid
);

    // PE 工作模式
    localparam  CLEAR   = 2'd0;     // 清零累加器
    localparam  COMPUTE = 2'd1;     // 乘累加

    // 周期计数器: 0 ~ INNER_DIM + 1，共 INNER_DIM + 2 个状态
    /*
    每个完整矩阵乘法的周期分配（共 K + 2 个周期）：
      - 第 0 周期（CLEAR） : 清零所有 PE 的累加器
      - 第 1 ~ K 周期（COMPUTE）: 依次输入 (A[:,0],B[0,:]), (A[:,1],B[1,:]), ...
        每周期完成一次外积累加 C += A[:,k] × B[k,:]
      - 第 K+1 周期: ctrl 保持 COMPUTE（此时输入为 0，累加器不变），o_valid 拉高，结果在 PE 输出端稳定保持一个完整周期
*/
    reg [$clog2(INNER_DIM + 2) - 1:0] calc_cnt;
    reg                                 r_vld;

    // 周期计数器
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            calc_cnt <= 0;
        else begin
            if (calc_cnt == INNER_DIM + 1)
                calc_cnt <= 0;                  // HOLD 结束后回到 CLEAR，开始下一轮
            else
                calc_cnt <= calc_cnt + 1'd1;
        end
    end

    // 控制信号生成（组合逻辑，与 calc_cnt 同步，无寄存器滞后）
    // CLEAR  仅在 calc_cnt == 0 时
    // COMPUTE 在 calc_cnt >= 1 时（包含最后一拍，此时外部输入为 0，累加器不变）
    assign ctrl = (calc_cnt == 0) ? CLEAR : COMPUTE;

    // 输出有效指示
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            r_vld <= 1'b0;
        else
            r_vld <= (calc_cnt == INNER_DIM + 1) ? 1'b1 : 1'b0;
    end

    assign o_valid = r_vld;

endmodule
