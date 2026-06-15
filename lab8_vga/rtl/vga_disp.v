module vga_disp (
    input           clk     ,
    input           rst_n   ,
    output          hsync   ,  //行同步信号
    output          vsync   ,  //场同步信号
    output          de      ,  //data enable
    output [9:0]    pix_x   ,
    output [9:0]    pix_y   
);

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

/*行扫描*/
reg [9:0]   hcnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hcnt <= 10'b0;
    end
    else if (hcnt == H_TOTAL - 6'd1) begin
        hcnt <= 10'b0;
    end
    else begin
        hcnt <= hcnt + 10'd1;
    end
end

/*列扫描*/
reg [9:0]   vcnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        vcnt <= 10'd0;
    end
    else if (hcnt == H_TOTAL - 10'd1) begin   // 扫描完一行

        if (vcnt == V_TOTAL - 10'd1) begin
            vcnt <= 10'd0;
        end
        else begin
            vcnt <= vcnt + 10'd1;
        end
            
    end
    else begin      //未扫描完一行
        vcnt <= vcnt;
    end
end

//有效像素信号定义
wire    hvalid; //行有效
wire    vvalid; //场有效

assign hvalid = (hcnt >= H_SYNC+ H_BACK 
                && hcnt < H_SYNC+ H_BACK + H_DISP);   //行计数值落在有效像素区间
assign vvalid = (vcnt >= V_SYNC + V_BACK
                && vcnt < V_SYNC + V_BACK + V_DISP);   //列计数值落在有效像素区间


// 场同步，行同步信号 output 
assign hsync = (hcnt > H_SYNC- 1);    //行同步时拉低，其余时候为高
assign vsync = (vcnt > V_SYNC - 1);


//测试显示 , 
// wire [11:0]     rgb;

// assign vga_r = rgb[11:8]; //将 rgb 信号的[11:8]部分作为 R 信号
// assign vga_g = rgb[7:4];  //将 rgb 信号的[7:4]部分作为 G 信号
// assign vga_b = rgb[3:0];  //将 rgb 信号的[3:0]部分作为 B 信号



/*****************vga 扫描输出信号**********/
assign pix_x = de ? (hcnt - (H_SYNC + H_BACK)) : 10'h0;
assign pix_y = de ? (vcnt - (V_SYNC + V_BACK)) : 10'h0;
assign de  = hvalid && vvalid;
// assign rgb = de ? {hcnt , vcnt} : 0 ;

endmodule