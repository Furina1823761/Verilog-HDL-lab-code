/*   
    created date: 2026-06-01
*/
`include "../../parameters.v"
module matrix_mul_core #(
    parameter DATA_WIDTH = `DATA_WIDTH ,
    parameter SUM_WIDTH  = `SUM_WIDTH  ,
    parameter PE_ROWS    = `PE_ROWS    , //矩阵A的行数
    parameter PE_COLS    = `PE_COLS      //矩阵B的列数，二者决定了输出矩阵（PE）的行列数
)(
    input                      clk                         ,
    input                      rst_n                       ,
    input [DATA_WIDTH-1:0]     i_h [PE_ROWS]               , // 输入矩阵A的行数据
    input [DATA_WIDTH-1:0]     i_v [PE_COLS]               , // 输入矩阵B的列数据
    output [SUM_WIDTH-1:0]     o_h  [PE_ROWS]              , // 输出矩阵C的结果
    output                     o_valid                     
);

// PE工作模式
localparam  CLEAR = 2'd0; 
localparam  O_S   = 2'd1;    //乘累加
localparam  MOV_H = 2'd2;    //横向移动

//经过移位寄存后的数据，输入进PE_array中
wire [DATA_WIDTH-1:0] v_in [PE_ROWS]; 
wire [DATA_WIDTH-1:0] h_in [PE_COLS]; 

reg [1:0] ctrl [PE_ROWS][PE_COLS]; // 控制信号，定义每个PE的操作

// 前 3 * PE_ROWS 个周期：输出固定模式（进行乘加运算），

// 这里似乎认为矩阵A的行列数是相等的？ 但在神经网络中，输入矩阵和权重矩阵都不能保证是方阵。
//真正的周期数应该是 3* 内维度(Inner Dimension) + 矩阵B的col数，与矩阵A的行数无关
//Inner列输入需要Inner个周期（pipline），移位需要2*Inner个周期

// 后 PE_COLS 个周期：水平移动模式（输出结果）
// 共需要log cnt位来表示cnt种情况 
reg [$clog2(3 * PE_ROWS + PE_COLS) - 1:0] calc_cnt;
reg     r_vld;

//计时器
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        calc_cnt <= 0; 
    else begin
        if(calc_cnt == 3*PE_ROWS + PE_COLS - 1) 
            calc_cnt <= 0; 
        else
            calc_cnt <= calc_cnt + 1'd1;
    end 
end

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        for (int i = 0; i < PE_ROWS; i++) begin
            for (int j = 0; j < PE_COLS; j++)
                ctrl[i][j] <= CLEAR;
        end
    end
    else begin
        for (int i = 0; i < PE_ROWS; i++) begin
            for (int j = 0; j < PE_COLS; j++) 
                ctrl[i][j] <= calc_cnt < 3 * PE_ROWS ? O_S : MOV_H;
        end
    end
end 

//输出有效
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        r_vld <= 1'b0; 
    else 
        r_vld = calc_cnt >= 3 * PE_ROWS ? 1'b1 : 1'b0;
end

assign o_valid = r_vld;


pe_array_in_shift_reg_array #(
    .DATA_WIDTH     (`DATA_WIDTH),
    .ARRAY_SIZE     (`ARRAY_SIZE)
    ) u_h_pe_array_in_shift_reg_array (
    .clk        (clk    ),
    .in         (i_h    ),
    .out        (h_in   )
);

//垂直
pe_array_in_shift_reg_array #(
    .DATA_WIDTH     (`DATA_WIDTH),
    .ARRAY_SIZE     (`ARRAY_SIZE)
    ) u_v_pe_array_in_shift_reg_array (
    .clk        (clk    ),
    .in         (i_v    ),
    .out        (v_in   )
);
pe_array #(
    .DATA_WIDTH     (`DATA_WIDTH), 
    .SUM_WIDTH      (`SUM_WIDTH ),
    .PE_ROWS        (`PE_ROWS   ), 
    .PE_COLS        (`PE_COLS   )
) u_pe_array (
    .clk        (clk    ), 
    .v_in       (v_in   ),
    .h_in       (h_in   ),
    .ctrl       (ctrl   ),
    .s_h_out    (o_h    ) 
);

endmodule