module top_send(
    input               sys_clk     ,
    input               rst_n       , //100M 系统时钟，与高电平复位 rst_n 信号
    input               uart_rxd    , 
    input               begin_key   ,
    input               cal_key     , //begin_key 为存值地址刷新按键， cal_key
    output reg [7:0]    led         , //上板后用于实现当前存值地址显示
    output              uart_txd    ,
    output              cal_led     , //与 cal_key（取值处理与发送按键）相接
    output [3:0]        out_led       //上板后用于是信号取值处理与发送状态显示
);

parameter       CLK_IN_FREQ = 100_000_000;
parameter       BAUD_RATE   = 9600;

wire        clk; //符合 9600 波特率的时钟信号
wire [1:0]  cur_st;

wire        uart_rx_done;

wire [7:0]  data_i,data_o,ram_data; //数据信号
wire [3:0]  r_number; //uart_receiver 模块的接收计数信号
wire        uart_tx_busy;
wire        uart_tx_en;     // uart_tx 发送使能
wire [7:0]  uart_tx_data;   // uart_tx 发送数据

wire [3:0]  ram_addrb; //bram 的取值地址信号
wire        ram_enb; //bram 的取值使能信号
wire        data_valid; //bram 读数据有效信号

assign cal_led = ~cal_key;
assign out_led[1:0] = cur_st;
assign out_led[2] = ram_enb;
assign out_led[3] = uart_tx_en;

always @(*)begin
    case(r_number)
        4'b000: led = 8'b00000001;
        4'b001: led = 8'b00000011;
        4'b010: led = 8'b00000111;
        4'b011: led = 8'b00001111;
        4'b100: led = 8'b00011111;
        4'b101: led = 8'b00111111;
        4'b110: led = 8'b01111111;
        4'b111: led = 8'b11111111;
        default: led = 8'b00000000;
    endcase
end

clk_div #(
    .CLK_IN_FREQ    (CLK_IN_FREQ),
    .BAUD_RATE      (BAUD_RATE  )
) u_clk_div( 
    .clk            (sys_clk),
    .rst_n          (rst_n),
    .clk_out        (clk)
);

uart_rx u_uart_rx(
    .clk            (clk         ),
    .rst_n          (rst_n       ),
    .begin_key      (begin_key   ),
    .uart_rxd       (uart_rxd    ),
    .r_number       (r_number    ),
    .uart_rx_done   (uart_rx_done),
    .uart_rx_data   (data_i      )
);

uart_tx u_uart_tx(
    .clk            (clk         ),
    .rst_n          (rst_n       ),
    .uart_tx_en     (uart_tx_en  ),
    .uart_tx_data   (uart_tx_data),
    .uart_tx_busy   (uart_tx_busy),
    .uart_txd       (uart_txd    )
);

send_ctrl u_send_ctrl(
    .clk            (clk         ),
    .sys_clk        (sys_clk     ),
    .rst_n          (rst_n       ),
    .cal_key        (cal_key     ),
    .data           (ram_data    ),
    .uart_tx_busy   (uart_tx_busy),
    .data_valid     (data_valid  ),
    .ram_addrb      (ram_addrb   ),
    .ram_enb        (ram_enb     ),
    .uart_tx_data   (uart_tx_data),
    .uart_tx_en     (uart_tx_en  ),
    .cur_st         (cur_st      )   
);

BRAM_ctrl u_BRAM_ctrl(
    .clk            (clk         ),
    .sys_clk        (sys_clk     ),
    .rst_n          (rst_n       ),
    .data_in        (data_i      ),
    .uart_rx_done   (uart_rx_done),
    .r_number       (r_number    ),
    .enb            (ram_enb     ),
    .addrb          (ram_addrb   ),
    .data_out       (ram_data    ),
    .data_valid     (data_valid  )
);
endmodule