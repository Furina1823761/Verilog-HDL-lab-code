module uart_rx (
    input               clk         ,
    input               rst_n       ,
    input               uart_rxd    ,   //接收数据线
    output  reg         uart_rx_done,       
    output  reg [7:0]   uart_rx_data    //接收的数据输出
);

localparam      IDLE        = 0;
localparam      RECEIVE     = 1;
localparam      RECEIVE_END = 2;

reg     [3:0]   cur_st, nxt_st  ;
reg     [3:0]   rx_cnt          ;
reg     [7:0]   data_o_tmp      ;

//第一段状态机
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cur_st <= IDLE; // 复位时进入空闲状态
    else
        cur_st <= nxt_st; // 否则更新为下一个状态
end

//第二段状态机
always @(*) begin
    nxt_st <= cur_st ; // 默认下一个状态为当前状态
    case (cur_st)
        IDLE:
            if (!uart_rxd) nxt_st <= RECEIVE ; //rxd被拉低代表起始位
        RECEIVE:
            if (rx_cnt == 4'd7) nxt_st <= RECEIVE_END ;
        RECEIVE_END:
            nxt_st <= IDLE ;
    endcase
end

//接收计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rx_cnt <= 4'd0;
    else if (cur_st == RECEIVE)
        rx_cnt <= rx_cnt + 4'd1;
    else if (cur_st == IDLE || cur_st == RECEIVE_END)
        rx_cnt <= 4'd0;
    else 
        rx_cnt <= 4'd0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_o_tmp <= 8'd0;
    end
    else if (cur_st == RECEIVE) begin
        data_o_tmp[6:0] <= data_o_tmp[7:1];
        data_o_tmp[7] <= uart_rxd;
    end
end

//第三段状态机
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_rx_data <= 8'd0;
        uart_rx_done <= 1'd0;
    end
    else if (cur_st == RECEIVE_END) begin
        uart_rx_done <= 1'b1;
        uart_rx_data <= data_o_tmp;
    end 
    else begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= uart_rx_data;
    end
end


endmodule