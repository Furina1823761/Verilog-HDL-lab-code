module uart_tx (
    input           clk         ,
    input           rst_n       ,
    input           uart_tx_en  ,    
    input   [7:0]   uart_tx_data,

    output  reg     uart_txd    

);
localparam      IDLE        = 0;
localparam      SEND_START  = 1; //发送起始位
localparam      SEND_DATA   = 2; //发送数据
localparam      SEND_END    = 3; //发送停止位

reg [3:0]       cur_st, nxt_st;   // 定义状态转换变量
reg [3:0]       tx_cnt;            // 定义发送计数器
reg [7:0]       data_o_tmp;

//第一段状态机
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cur_st <= IDLE; // 复位时进入空闲状态
    else
        cur_st <= nxt_st; // 否则更新为下一个状态
end
//第二段状态机
always @(*) begin
    nxt_st <= cur_st;
    case (cur_st)
        IDLE:
            if (uart_tx_en)
                nxt_st <= SEND_START ;

        SEND_START:
            nxt_st <= SEND_DATA ;
        SEND_DATA:
            if (tx_cnt == 4'd7)
                nxt_st <= SEND_END ; 
        SEND_END:
            if (uart_tx_en)
                nxt_st <= SEND_START ;
        default:
            nxt_st <= IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tx_cnt <= 4'd0;
    else if (cur_st == SEND_DATA)
        tx_cnt <= tx_cnt + 4'd1;
    else if (cur_st == IDLE || cur_st == SEND_END)
        tx_cnt <= 4'd0;
end

always @(posedge clk) begin
    if (cur_st == SEND_START)
        data_o_tmp <= uart_tx_data;
    else if (cur_st <= SEND_DATA)
        data_o_tmp[6:0] <= data_o_tmp[7:1];
end

always @(posedge clk) begin
    if (cur_st == SEND_START)
        uart_txd <= 1'd0;
    else if (cur_st == SEND_DATA)
        uart_txd <= data_o_tmp[0];
    else if (cur_st == SEND_END)
        uart_txd <= 1'd1;
    else 
        uart_txd <= 1'd1;
end


endmodule