module uart_loopback(
    input           rst_n       ,
    input           clk         ,
    input           uart_rxd    ,
    output          uart_txd    ,
    output          uart_tx_en    //发送确认信号
);
wire    [7:0]   dataparal; //输入信号
wire            clk_9600;

parameter   CLK_IN_FREQ = 100_000_000;
parameter   BAUD_RATE   = 115200;
uart_rx u_uart_rx(
    .clk            (clk_9600    ),
    .rst_n          (rst_n       ),
    .uart_rxd       (uart_rxd    ),
    .uart_rx_done   (uart_tx_en  ),
    .uart_rx_data   (dataparal   )
);
uart_tx u_uart_tx(
    .clk            (clk_9600    ),
    .rst_n          (rst_n       ),
    .uart_tx_en     (uart_tx_en  ),
    .uart_tx_data   (dataparal   ),
    .uart_txd       (uart_txd    )
);
clk_div #(
    .CLK_IN_FREQ    (CLK_IN_FREQ ),
    .BAUD_RATE      (BAUD_RATE   )
) u_clk(
    .clk            (clk         ),
    .rst_n          (rst_n       ),
    .clk_out        (clk_9600    )
);
// 例化各模块并连接
endmodule