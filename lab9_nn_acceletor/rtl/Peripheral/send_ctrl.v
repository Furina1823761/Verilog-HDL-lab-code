module send_ctrl (
    input               clk          ,
    input               sys_clk      , //低电平复位信号，时钟等
    input               rst_n        ,
    input               cal_key      , //取值处理与发送按键
    input [7:0]         data         , //bram 取值输出的数据信号
    input               uart_tx_busy , //是否在发送状态
    input               data_valid   ,
    output reg [3:0]    ram_addrb    , //bram 取值所需的地址信号
    output reg          ram_enb      , //bram 取值所需的使能信号
    output reg [7:0]    uart_tx_data , 
    output reg          uart_tx_en   , 
    output reg [1:0]    cur_st      
);

localparam IDLE = 0, READY = 1 ,SEND_START = 2, SEND_END = 3; 
reg [1:0] nxt_st; 
reg [4:0] send_count; 
reg cal_key_state;

always @(posedge clk) begin
    if (~rst_n)
        cal_key_state <= 1'b0 ;
    else if(cal_key && cur_st == IDLE)
        cal_key_state <= 1'b1 ;
    else
        cal_key_state <= 1'b0 ;    
end

//第一段状态机
always @(posedge clk) begin
    if (~rst_n)
        cur_st <= IDLE ;
    else
        cur_st <= nxt_st ;
end

//第二段状态机
always @(*) begin
    nxt_st <= cur_st;
    case (cur_st)
    IDLE:
        if(cal_key != 1 && uart_tx_busy == 0 && cal_key_state)begin 
            nxt_st <= READY;
        end
    READY: 
        if(data_valid)begin
            nxt_st <= SEND_START;
        end
        else 
            nxt_st <= READY;
    SEND_START:
        if(uart_tx_en)begin 
            nxt_st <= SEND_END; 
        end
        else 
            nxt_st <= SEND_START;
    SEND_END:
        if(send_count == 0 && uart_tx_busy == 0)begin //结束发送
            nxt_st <= IDLE;
        end
        else if(send_count != 0 && uart_tx_busy == 0)begin  //未发送完成
            nxt_st <= READY;
        end
        else
            nxt_st <= SEND_END;
    default:
        nxt_st <= IDLE;
    endcase
end

//第三段状态机
always @(posedge clk) begin
    if (cur_st == IDLE)begin 
        ram_addrb   <= 4'd0;
        ram_enb     <= 1'd0;
        uart_tx_data<= 8'd0;
        uart_tx_en   <= 1'd0;
        send_count  <= 5'd7; 
    end
    else if (cur_st == READY)begin
        ram_addrb <= send_count; 
        ram_enb <= 1;
    end
    else if(cur_st == SEND_START)begin
        uart_tx_data <= data;
        uart_tx_en <= 1;
    end
    else if(cur_st == SEND_END)begin 
        uart_tx_en <= 0;
        if(uart_tx_busy == 0)begin
            send_count <= send_count - 5'd1;
        end
    end
end

endmodule