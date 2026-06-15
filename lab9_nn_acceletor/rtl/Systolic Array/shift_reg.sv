/*   
    created date: 2026-06-01
*/
// 移位寄存器模块，实现可调延迟级数的FIFO结构

`include "../../parameters.v"
module shift_reg #(
    parameter DATA_WIDTH    = `DATA_WIDTH, // 数据位宽
    parameter DEPTH         = 1 // 移位寄存器深度（延迟级数）
) (
    input                       clk, 
    input [DATA_WIDTH-1:0]      in, 
    output [DATA_WIDTH-1:0]     out // 输出数据（延迟 DEPTH 个时钟）
);

reg [DATA_WIDTH-1:0] shift_reg [DEPTH];
integer i;
//移位
always @(posedge clk) begin
    for (i = 0; i < DEPTH-1; i++) begin
        shift_reg[i] <= shift_reg[i+1]; 
    end
    shift_reg[DEPTH-1] <= in; 
end

assign out = shift_reg[0];

endmodule