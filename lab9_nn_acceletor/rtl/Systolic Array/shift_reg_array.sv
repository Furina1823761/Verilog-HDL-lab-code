/*   
    created date: 2026-06-01
*/
`include "../../parameters.v"
module pe_array_in_shift_reg_array #(
    parameter DATA_WIDTH = `DATA_WIDTH  , 
    parameter ARRAY_SIZE = `ARRAY_SIZE          //大小由矩阵的内维度决定
) (
    input                    clk            , 
    input   [DATA_WIDTH-1:0] in [ARRAY_SIZE], // 输入数据数组
    output  [DATA_WIDTH-1:0] out [ARRAY_SIZE] // 输出数据数组
);

genvar i;
generate
    for (i = 0; i < ARRAY_SIZE; i++) begin : shift_reg_gen
        shift_reg #(
            .DATA_WIDTH (DATA_WIDTH),
            .DEPTH      (i + 1) //每个寄存器的深度递增，形成不同的延迟，第0行/列延迟一个周期,为了同步？
        ) shift_reg_inst (
            .clk(clk),
            .in(in[i]),
            .out(out[i])
        );
    end
endgenerate

endmodule