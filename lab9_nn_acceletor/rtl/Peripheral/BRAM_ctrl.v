module BRAM_ctrl(
    input           clk         ,        //分频后的，串口使用的时钟
    input           sys_clk     ,    //未分频，系统时钟
    input           rst_n       , 
    input [7:0]     data_in     , 
    input           uart_rx_done, //由 uart_receiver 输出的数据有效信号
    input [3:0]     r_number    , //uart_receiver 模块的接收计数信号，
    input           enb         , //用于 bram 取值的使能信号
    input [3:0]     addrb       , //用于 bram 取值的地址信号
    output [7:0]    data_out    , //bram 取值的数据信号
    output reg      data_valid    //bram 取值的数据信号对应的有效信号
);
// a->ram输入   b->ram输出
wire ena,wea;

wire [3:0]addra;
wire [7:0]dina;
assign ena = uart_rx_done; 
assign wea = uart_rx_done; 

assign dina = data_in;
assign addra = r_number - 1;


always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        data_valid <= 1'b0;
    else begin
        if (enb)
            data_valid <= 1'b1 ; //给data_valid打一拍，和读出的数据同步
        else
            data_valid <= 1'b0 ;
    end
    
end
BRAM BRAM(
    .clka   ( sys_clk  ),
    .ena    ( ena      ),
    .wea    ( wea      ),
    .addra  ( addra    ),
    .dina   ( dina     ),
    .clkb   ( clk      ),
    .enb    ( enb      ),
    .addrb  ( addrb    ),
    .doutb  ( data_out )
);
endmodule