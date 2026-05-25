module vga_clk (
    input           clk     ,
    input           rst_n   ,
    output  reg     clk_vga
);

parameter   CLK_IN_FREQ = 100_000_000;
parameter   CLK_VGA_FREQ= 25_000_000 ;    
parameter   DIV_NUM     = CLK_IN_FREQ / (CLK_VGA_FREQ * 2);

reg     [DIV_NUM-1:0]   cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= {DIV_NUM{1'b0}};
        clk_vga <= 1'b0;
    end
    else if (cnt == DIV_NUM - 1) begin
        cnt <= 0;
        clk_vga <= ~clk_vga;
    end
    else begin
        cnt <= cnt + 1'b1;
    end
end

endmodule