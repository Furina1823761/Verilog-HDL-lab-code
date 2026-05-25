module vga_top(
input               sys_clk , 
input               rst     , 
input               switch  , 
output              hsync   ,
output              vsync   ,
output [3:0]        vga_r   , 
output [3:0]        vga_g   , 
output [3:0]        vga_b   , 
output              led1    ,
output              led2 
);

/*-------------超参数定义---------------*/
//时钟频率
parameter   CLK_IN_FREQ  = 100_000_000;
parameter   CLK_VGA_FREQ = 25_000_000 ;
// 行扫描参数
parameter   H_SYNC      = 96;    //行同步时钟数
parameter   H_BACK      = 48;    //行后沿时钟数
parameter   H_DISP      = 640;    //行有效像素数
parameter   H_FRONT     = 16;    //行前沿时钟数
parameter   H_TOTAL     = 800;   //行总时钟数

//场扫描参数
parameter   V_SYNC      = 2;
parameter   V_BACK      = 33; 
parameter   V_DISP      = 480; 
parameter   V_FRONT     = 10; 
parameter   V_TOTAL     = 525;

//图片显示像素
parameter X_PIXEL = 256;
parameter Y_PIXEL = 256;

wire [11:0]     rgb;
wire            clk_vga;
wire [11:0]     back_rgb, pic_rgb; //分别为背景彩条的 rgb 信号与图片的 rgb 信号
wire            pic_valid; 
wire [9:0]      pix_x,pix_y; 
wire            rst_n; 

assign rst_n = ~rst; 
assign led1 = rst; 

assign led2 = switch; 


assign vga_r = (pic_valid)? pic_rgb[11:8]:back_rgb[11:8];
assign vga_g = (pic_valid)? pic_rgb[ 7:4]:back_rgb[7:4];
assign vga_b = (pic_valid)? pic_rgb[ 3:0]:back_rgb[3:0];

assign rgb = {vga_r, vga_g, vga_b};

vga_clk #(
    .CLK_IN_FREQ(CLK_IN_FREQ),
    .CLK_VGA_FREQ(CLK_VGA_FREQ)
) u_vga_clk(
    .clk        (sys_clk),
    .clk_vga    (clk_vga),
    .rst_n      (rst_n)
);

vga_disp #(
    .H_SYNC     (H_SYNC),
    .H_BACK     (H_BACK),
    .H_DISP     (H_DISP),
    .H_FRONT    (H_FRONT),
    .H_TOTAL    (H_TOTAL),

    .V_SYNC     (V_SYNC),
    .V_BACK     (V_BACK),
    .V_DISP     (V_DISP),
    .V_FRONT    (V_FRONT),
    .V_TOTAL    (V_TOTAL)
) vga_disp(
    .clk        (clk_vga),
    .rst_n      (rst_n),
    .hsync      (hsync),
    .vsync      (vsync),
    .pix_x      (pix_x),
    .pix_y      (pix_y)
);
//负责 vga 显示中，背景彩条信号的输入
vga_rgb vga_rgb(
    .pix_x      (pix_x),
    .pix_y      (pix_y),
    .rst_n      (rst_n),
    .clk        (clk_vga),
    .rgb        (back_rgb)
);
//负责 vga 显示中，图片信号的输入
vga_pic #(
    .H_DISP     (H_DISP),
    .V_DISP     (V_DISP),
    .X_PIXEL    (X_PIXEL),
    .Y_PIXEL    (Y_PIXEL)
) vga_pic(
    .pix_x      (pix_x),
    .pix_y      (pix_y),
    .rst_n      (rst_n),
    .clk        (clk_vga),
    .rgb        (pic_rgb),
    .valid      (pic_valid)
);

endmodule
