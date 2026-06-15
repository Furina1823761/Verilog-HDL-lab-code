/*   
    created date: 2026-06-15
*/
`include "../../parameters.v"

module BRAM_o_ctrl #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter SUM_WIDTH  = `SUM_WIDTH,
    parameter PE_ROWS    = `PE_ROWS,    
    parameter PE_COLS    = `PE_COLS
)(
    input                       clk         ,
    input                       rst_n       , 
    input [SUM_WIDTH * 3-1:0]   data_in     , 
    input                       in_valid    , 
    input [1:0]                 in_addr     , //需存入的数据信号对应的存储地址信号
    input [4:0]                 o_addr      , //用于从 BRAM_o 取值的取值地址控制信号
    input                       o_en        , //用于从 BRAM_o 取值的取值使能信号
    output reg [7:0]            data_o      , 
    output reg                  data_valid
);

wire [1:0] out_addr;
wire [SUM_WIDTH * 3-1:0] data_out;
wire [1:0]i;
wire [2:0]j;

assign i = o_addr / 6     ; //每一行 3 个 16 位数，分高 8 位低 8 位，因此除以 6
assign j = o_addr - 6 * i ; //每一行 3 个 16 位数，可截取为 6 个 8 位数
assign out_addr = i;

always @(posedge clk) begin
    if (o_en)
        data_valid <= 1'b1 ; //作为 bram 取值的数据信号对应的有效信号，
    else
        data_valid <= 1'b0 ;
end

always@(*) begin
    case(j)
        3'd0:data_o <= data_out[47:40];
        3'd1:data_o <= data_out[39:32];
        3'd2:data_o <= data_out[31:24];
        3'd3:data_o <= data_out[23:16];
        3'd4:data_o <= data_out[15: 8];
        3'd5:data_o <= data_out[ 7: 0];
endcase

end

BRAM_o BRAM_o(
    .clka       (clk),
    .clkb       (clk),
    .ena        (in_v),
    .wea        (in_v),
    .addra      (in_addr),
    .dina       (data_in),
    .enb        (o_en),
    .addrb      (out_addr),
    .doutb      (data_out)
);


endmodule
