module clk_div(
    input               clk     ,   //100Mhz时钟
    input               rst_n   ,
    output  reg         clk_out
);
parameter       CLK_IN_FREQ = 100_000_000;
parameter       BAUD_RATE   = 9600;
parameter       DIV_NUM     = CLK_IN_FREQ / (BAUD_RATE * 2);

reg     [15:0]  div_cnt;  //16位分频计数器

//时钟分频
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_out <= 1'd0;
        div_cnt <= 16'd0;
    end
    else if(div_cnt == DIV_NUM - 1) begin
        div_cnt <= 16'd0;
        clk_out <= ~clk_out;
    end
    else begin
        div_cnt <= div_cnt + 16'd1;
    end
end

endmodule