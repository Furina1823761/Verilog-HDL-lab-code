/*   
    created date: 2026-06-01
*/
`include "../../parameters.v"
module pe_array #(
    parameter DATA_WIDTH = `DATA_WIDTH ,
    parameter SUM_WIDTH  = `SUM_WIDTH  ,
    parameter PE_ROWS    = `PE_ROWS    ,
    parameter PE_COLS    = `PE_COLS    
)(
    input                      clk                         , 
    input [DATA_WIDTH-1:0]     v_in [PE_ROWS]              ,
    input [DATA_WIDTH-1:0]     h_in [PE_COLS]              ,   
    input [1:0]                ctrl [PE_ROWS] [PE_COLS]    , // 控制信号，定义每个PE的操作
    output [SUM_WIDTH-1:0]     s_h_out [PE_COLS]             //水平输出矩阵计算结果
);

wire [DATA_WIDTH-1:0] v_w [PE_ROWS + 1][PE_COLS];
wire [DATA_WIDTH-1:0] h_w [PE_ROWS][PE_COLS + 1];
wire [SUM_WIDTH-1:0] s_h_w [PE_ROWS][PE_COLS + 1];

//创建PE二维矩阵
genvar i, j;
generate
    for(i = 0; i < PE_ROWS; i = i + 1) begin : row_gen
        assign h_w[i][0] = h_in[i];     //连接每一行的输入
        assign s_h_w[i][0] = {SUM_WIDTH{1'b0}}; //水平输出矩阵的第一列初始化为0
        assign s_h_out[i] = s_h_w[i][PE_COLS];

        for(j = 0; j < PE_COLS; j = j + 1) begin : col_gen
            assign v_w[0][j] = v_in[j]; //连接每一列的输入

            pe #(
                .DATA_WIDTH(DATA_WIDTH),
                .SUM_WIDTH(SUM_WIDTH)
            ) pe_inst (
                .clk        ( clk            ),
                .v_in       ( v_w[i][j]      ),
                .h_in       ( h_w[i][j]      ),
                .s_h_in     ( s_h_w[i][j]    ),
                .ctrl       ( ctrl[i][j]     ),
                .v_out      ( v_w[i+1][j]    ),
                .h_out      ( h_w[i][j+1]    ),
                .s_h_out    ( s_h_w[i][j+1]  )
            );
        end
    end
endgenerate       

endmodule