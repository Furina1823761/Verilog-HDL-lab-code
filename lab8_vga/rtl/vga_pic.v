module vga_pic(
input               clk     ,
input               rst_n   ,
input  [9:0]        pix_x   ,
input  [9:0]        pix_y   ,
output [11:0]       rgb     , 
output              valid
);

wire [16:0]         addr;           //ROM 存储 ip 的输入地址
wire [15:0]         data;           //ROM 存储 ip 的输出数据 (RGB565)
reg  [9:0]          pic_x, pic_y;   //图片范围内的 x、 y 轴坐标

reg         v_x, v_y;  //x, y有效
assign      valid = (v_x && v_y)? 1:0;


//RGB565 -> RGB444
assign rgb[3:0]  = data [4:1]; 
assign rgb[7:4]  = data [10:7];
assign rgb[11:8] = data[15:12];


// 图片显示参数设置(100 * 100)时, 图片的显示区域大致为（320±50， 240±50）
parameter H_DISP = 640;
parameter V_DISP = 480;

parameter H_CENTER = H_DISP / 2;
parameter V_CENTER = V_DISP / 2;
parameter X_PIXEL = 256;
parameter Y_PIXEL = 256;

assign      addr  = pic_y * Y_PIXEL + pic_x;

//行有效
always @(posedge clk) begin
    if (pix_x > H_CENTER - X_PIXEL/2 && pix_x <= H_CENTER + X_PIXEL/2) begin
        pic_x <= pix_x - (H_CENTER - X_PIXEL/2 + 1); //这里X_PIXEL少÷2导致图片显示偏移
        v_x <= 1'b1;
    end
    else begin
        pic_x <= 10'b0;
        v_x <= 1'b0;
    end
end

//列有效
always @(posedge clk) begin
    if (pix_y > V_CENTER - Y_PIXEL/2 && pix_y <= V_CENTER + Y_PIXEL/2) begin
        pic_y <= pix_y - (V_CENTER - Y_PIXEL/2 + 1);
        v_y <= 1'b1;
    end
    else begin
        pic_y <= 10'b0;
        v_y <= 1'b0;
    end
end

//实例化 ROM 存储 ip
pic_rom u_pic_rom (
  .clka     (clk    ),    // input wire clka
  .addra    (addr   ),    // input wire [16 : 0] addra
  .douta    (data   )     // output wire [15 : 0] douta
);
endmodule