/*   
    created date: 2026-06-01
*/
`include "../../parameters.v"
module pe #(
    parameter DATA_WIDTH    = `DATA_WIDTH   , 
    parameter SUM_WIDTH     = `SUM_WIDTH        
) (
    input                   clk     , 
    input  [1:0]            ctrl    , //控制信号
    input  [DATA_WIDTH-1:0] v_in    ,
    input  [DATA_WIDTH-1:0] h_in    ,
    input  [SUM_WIDTH-1:0]  s_h_in  ,

    output [DATA_WIDTH-1:0] v_out   , 
    output [DATA_WIDTH-1:0] h_out   , 
    output [SUM_WIDTH-1:0]  s_h_out 
);
// PE工作模式
localparam  CLEAR = 2'd0; 
localparam  O_S   = 2'd1;    //乘累加
localparam  MOV_H = 2'd2;  //横向移动

//乘加位宽，例程位宽定义存在问题，sum的位宽小于add，在后续赋值会发生截断
localparam MUL_WIDTH = 2 * DATA_WIDTH; //乘法结果位宽<=数据位宽的两倍

//水平、垂直寄存器
reg  [DATA_WIDTH-1:0]           v, h;
reg  [SUM_WIDTH-1:0]            s;

//乘加
wire [MUL_WIDTH-1 :0]           mul;
wire [SUM_WIDTH-1 :0]           add;  //加法位宽与sum相同，所需位宽与输入矩阵大小有关，可在parameters.v中定义
assign mul = h_in * v_in;
assign add = mul + s;  //这里在计算时需要确保add的位宽足够大以避免溢出

always @(posedge clk) begin
    case (ctrl)
        CLEAR: begin
            v <= 0;
            h <= 0;
            s <= 0;
        end
        O_S: begin
            v <= v_in;
            h <= h_in;
            s <= add;
        end
        MOV_H: begin
            v <= 0;
            h <= 0;
            s <= s_h_in; 
        end
        default: begin
            v <= v;
            h <= h;
            s <= s;
        end
    endcase
end

assign  v_out   = v;
assign  h_out   = h;
assign  s_h_out = s;

endmodule