`timescale 1ns / 1ps

module top_tb();
reg         sys_clk,rst_n;
wire        uart_rxd,uart_txd;
reg         cal_key;
wire        rxd_t,txd_t,uart_rx_done;
wire [7:0]  data_i;
reg  [7:0]  data_o;
reg         uart_tx_en;
wire        clk;
wire [7:0]  uart_tx_data;
assign      uart_tx_data = data_o;
initial begin
    sys_clk = 0;
end

always #10 sys_clk = ~sys_clk;


initial begin
    rst_n = 1'b0;
    #888888 rst_n = 1'b1;
end

initial begin
    uart_tx_en = 0;
    #730 data_o = 8;uart_tx_en = 1;
    #2291000 data_o = 7;
    #2080400 data_o = 6;
    #2080400 data_o = 5;
    #2080400 data_o = 4;
    #2080400 data_o = 3;
    #2080400 data_o = 2;
    #2080400 data_o = 1;
    #2080400 data_o = 0;uart_tx_en = 0;
end

initial begin
    cal_key = 0;
    #18930005 cal_key = 1;
    #2000000 cal_key = 0;
end


top_send u_top_send(
    .uart_rxd       (uart_rxd),
    .uart_txd       (uart_txd),
    .sys_clk        (sys_clk ),
    .rst_n          (rst_n   ),
    .begin_key      (1'b0),
    .cal_key        (cal_key)
);

assign uart_rxd = txd_t;      // 外部 tx 驱动 top_send 的 rx 输入
assign rxd_t   = uart_txd;    // top_send 的 tx 输出 → 外部 rx 监测

clk_div clk_div_uart(
    .clk        (sys_clk),
    .rst_n      (rst_n),
    .clk_out    (clk)
);

uart_tx u1_uart_tx(
    .clk            (clk         ),
    .rst_n          (rst_n       ),
    .uart_tx_en     (uart_tx_en  ),
    .uart_tx_data   (uart_tx_data),
    .uart_tx_busy   (),
    .uart_txd       (txd_t       )
);

uart_rx u1_uart_rx(
    .clk            (clk         ),
    .rst_n          (rst_n       ),
    .begin_key      (),
    .uart_rxd       (rxd_t       ),
    .r_number       (),
    .uart_rx_done   (uart_rx_done),
    .uart_rx_data   (data_i      )
);

endmodule