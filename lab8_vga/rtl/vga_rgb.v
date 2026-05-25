module vga_rgb (
input                   clk     ,
input                   rst_n   ,
input       [9:0]       pix_x   ,
input       [9:0]       pix_y   ,
output reg  [11:0]      rgb   
);

always @(posedge clk) begin
    if (pix_x < 10'd80) begin
        rgb <= 12'd0; //当 pix_x 在[0， 80）范围内，输出黑色
    end
    else if (pix_x < 10'd160) begin
        rgb <= 12'd585; //当 pix_x 在[80， 160）范围内，输出蓝色
    end
    else if (pix_x < 10'd240) begin
        rgb <= 12'd1170; //当 pix_x 在[160,240)范围内，输出绿色
    end
    else if (pix_x < 10'd320) begin
        rgb <= 12'd1755; //当 pix_x 在[240,320)范围内，输出浅蓝色
    end
    else if (pix_x < 10'd400) begin
        rgb <= 12'd2340; //当 pix_x 在[320,400)范围内，输出红色
    end
    else if (pix_x < 10'd480) begin
        rgb <= 12'd2925; //当 pix_x 在[400,480)范围内，输出紫色
    end
    else if (pix_x < 10'd560) begin
        rgb <= 12'd3510; //当 pix_x 在[480,560)范围内，输出黄色
    end
    else begin
        rgb <= 12'd4095; //当 pix_x 在其他范围内，输出白色
    end
end

endmodule