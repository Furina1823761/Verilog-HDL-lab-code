module bin2bcd (
    input          [15:0]     bin,
    output  reg    [18:0]     bcd   //19位bcd码，万位范围0~6，3位可表示
);

reg     [34:0]     x;
integer     i;
always @(*) begin
    for(i=0;i<35;i=i+1) begin
        x[i] = 0;
    end
    //step1:左移要转化的二进制数3位
    x[18:3] = bin;
    //step2:重复13次，总共左移16位，将16位bin全部移出
    repeat(13) begin
        //step3:如果bcd码当前4位>4，则加3
        if (x[19:16] > 4) begin   
            x[19:16] = x[19:16] + 35'd3;    
        end
        if (x[23:20] > 4) begin
            x[23:20] = x[23:20] + 35'd3;
        end
        if (x[27:24] > 4) begin
            x[27:24] = x[27:24] + 35'd3;
        end
        if (x[31:28] > 4) begin
            x[31:28] = x[31:28] + 35'd3;
        end
        if (x[34:32] > 4) begin
            x[34:32] = x[34:32] + 35'd3;
        end
        //step4:左移1位
        x = x << 1;
    end
    //step5:左移完成后，bcd码在x的高19位
    bcd = x[34:16];
end
endmodule