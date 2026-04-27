module ram_tb();
parameter BIT_WIDTH = 16;
parameter ADDR_WIDTH = 8;
parameter DEPTH = 1 << ADDR_WIDTH;
wire [BIT_WIDTH-1:0] rData;
reg [BIT_WIDTH-1:0] wData;
reg clk;
reg wEn, rEn;
reg [ADDR_WIDTH-1:0] wAddr;
reg [ADDR_WIDTH-1:0] rAddr;

RAM RAM(
	.wData(wData),
	.rData(rData),
	.wEn(wEn),
	.rEn(rEn),
	.wAddr(wAddr),
	.rAddr(rAddr),
	.clk(clk)
	);
	
initial begin
	clk =0;
	forever #10 clk=~clk;
end

initial begin 
	wData = 16'b0;
	wEn = 1'b0;
	rEn = 1'b0;
	wAddr = 8'b0;
	rAddr = 8'b0;
	
	#40;
	
	wEn = 1'b1;
	wAddr = 8'd0;
	wData = 16'h0000;
	
	#20;
	
	wEn = 1'b1; 
	wAddr = 8'd1;
	wData = 16'h0001;
	
	#20;
	
	wEn = 1'b1;
	wAddr = 8'd2;
	wData = 16'h0010;
	
	#20;
	
	wEn = 1'b1;
	wAddr = 8'd3;
	wData = 16'h0011;
	
	#21;
	
	wEn = 1'b1;
	wAddr = 8'd4;
	wData = 16'h0100;
	
	#39;
	
	wEn = 1'b0;
	wAddr = 8'd0;
	wData = 16'h0000;
	
	#30;
	
	rEn = 1'b1; 
	rAddr = 8'd0;
	
	#20;
	
	rEn = 1'b1; 
	rAddr = 8'd1;
	
	#20;
	
	rEn = 1'b1; 
	rAddr = 8'd2;
	
	#20;
	
	rEn = 1'b1; 
	rAddr = 8'd3;
	
	#20;
	
	rEn = 1'b1; 
	rAddr = 8'd4;
	
	#20;
	
	wEn = 1'b1; 
	rAddr = 8'd5; 
	wAddr = 8'd5; 
	wData = 16'h1111;
end
endmodule