`timescale 1ns/1ns

module tb_uart_loopback ();

parameter  CLK_PERIOD = 10;          // 100MHz -> 10ns
localparam BIT_DELAY  = 104167;      // 9600bps 位周期 (1/9600 ≈ 104166.67ns)

//reg define
reg     sys_clk;
reg     sys_rst_n;
reg     uart_rxd;

//wire define
wire    uart_txd;

initial begin
    sys_clk     <= 1'b0;
    sys_rst_n   <= 1'b0;
    uart_rxd    <= 1'b1;
    #200
    sys_rst_n   <= 1'b1;
    #1000
    // 发送数据 0x55 (LSB first: 1 1 1 0 1 0 1 0)
    uart_rxd <= 1'b0;               // 起始位
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // D0
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // D1
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // D2
    #BIT_DELAY;
    uart_rxd <= 1'b0;               // D3
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // D4
    #BIT_DELAY;
    uart_rxd <= 1'b0;               // D5
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // D6
    #BIT_DELAY;
    uart_rxd <= 1'b0;               // D7
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // 停止位
    #BIT_DELAY;
    uart_rxd <= 1'b1;               // 空闲状态
end

always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

uart_loopback u_uart_loopback(
    .clk    (sys_clk  ),
    .rst_n  (sys_rst_n),
    .uart_rxd (uart_rxd),
    .uart_txd (uart_txd)
);

endmodule