module segs_disp (
input                       clk     ,
input                       rst     ,
input         [18:0]        bcd     ,
output  reg   [7:0]         segs    ,   //段选
output  reg   [7:0]         seg_sel      //片选
);

reg [3:0]   bcd_reg [4:0];  
reg [7:0]   seg_reg [4:0];

//计数器分频，主频100MHZ,分频得到1kHZ的时钟信号
reg [16:0]  cnt;
reg         clk_1kHz;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        cnt <= 17'd0;
        clk_1kHz <= 1'd0;
    end else begin
        if(cnt == 17'd100_000) begin
            clk_1kHz <= ~clk_1kHz;
            cnt <= 17'd0;
        end else begin
            cnt <= cnt + 17'd1;
        end
    end
end

//将19位bcd码分成5个4位的bcd码
always @(*) begin
    bcd_reg[4] = {1'd0,bcd[18:16]};  //万位
    bcd_reg[3] =    bcd[15:12];  //千位
    bcd_reg[2] =    bcd[11:8];   //百位
    bcd_reg[1] =    bcd[7:4];    //十位
    bcd_reg[0] =    bcd[3:0];    //个位
end

//将4位bcd码转换成7段数码管的显示码
integer i;
always @(*) begin
    for(i=0;i<5;i=i+1) begin
        case(bcd_reg[i][3:0])
            4'd0: seg_reg[i] = 8'b0011_1111; //显示0
            4'd1: seg_reg[i] = 8'b0000_0110; //显示1
            4'd2: seg_reg[i] = 8'b0101_1011; //显示2
            4'd3: seg_reg[i] = 8'b0100_1111; //显示3
            4'd4: seg_reg[i] = 8'b0110_0110; //显示4
            4'd5: seg_reg[i] = 8'b0110_1101; //显示5
            4'd6: seg_reg[i] = 8'b0111_1101; //显示6
            4'd7: seg_reg[i] = 8'b0000_0111; //显示7
            4'd8: seg_reg[i] = 8'b0111_1111; //显示8
            4'd9: seg_reg[i] = 8'b0110_1111; //显示9
            default: seg_reg[i] = ~8'hff;//不显示 
        endcase
    end
end


always @(posedge clk) begin
    if (rst) begin
        seg_sel <= 8'b0000_1000;
    end
end
//动态扫描显示
always @(posedge clk_1kHz or posedge rst) begin
if(rst) begin
    seg_sel <= 8'b0000_1000;
end
else begin
    if(seg_sel == 8'b1000_0000)
        seg_sel <= 8'b0000_1000;
    else 
        seg_sel <= seg_sel << 1;            
end
end

//根据当前片选显示对应的段选
always @(*) begin
    case(seg_sel)
        8'b0000_1000: segs = seg_reg[0];
        8'b0001_0000: segs = seg_reg[1];
        8'b0010_0000: segs = seg_reg[2];
        8'b0100_0000: segs = seg_reg[3];
        8'b1000_0000: segs = seg_reg[4];
        default: segs = ~8'hff; //不显示
    endcase
end

endmodule