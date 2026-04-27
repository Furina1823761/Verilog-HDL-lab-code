`timescale 1ns/1ps
module ip_ram_tb();
parameter 					BIT_WIDTH = 4;
parameter 					ADDR_WIDTH = 3;
parameter 					DEPTH = 1 << ADDR_WIDTH;
wire 	[BIT_WIDTH-1:0] 	rData;
reg 	[BIT_WIDTH-1:0] 	wData;
wire 	[BIT_WIDTH-1:0]		doutb;
reg 						clk;
reg 						wEn, rEn, ena;
reg 	[ADDR_WIDTH-1:0] 	wAddr;
reg 	[ADDR_WIDTH-1:0] 	rAddr;


RAM	#(
	.ADDR_WIDTH	(ADDR_WIDTH),
	.BIT_WIDTH	(BIT_WIDTH),
	.DEPTH		(DEPTH)
) u_RAM(
	.wData	(wData),
	.rData	(rData),
	.wEn	(wEn  ),
	.rEn	(rEn  ),
	.wAddr	(wAddr),
	.rAddr	(rAddr),
	.clk	(clk  )
);

SDP_BRAM u_SDP_BRAM (	//A端口：写    B端口：读
  .clka	(clk),    // input wire clka
  .ena	(ena),      // input wire ena
  .wea	(wEn),      // input wire [0 : 0] wea
  .addra(wAddr),  // input wire [2 : 0] addra
  .dina	(wData),    // input wire [3 : 0] dina

  .clkb	(clk),    // input wire clkb
  .enb	(rEn),      // input wire enb
  .addrb(rAddr),  // input wire [2 : 0] addrb
  .doutb(doutb)  // output wire [3 : 0] doutb
);



initial begin
	clk =0;
	forever #10 clk=~clk;
end

initial begin 
	#25;
	wData=4'b0000;
	wAddr=3'b000;
	
	#40;
	wData=4'b0001;
	wAddr=3'b001;
	
	#40;
	wData=4'b0010;
	wAddr=3'b010;
	
	#40;
	wData=4'b0011;
	wAddr=3'b011;
	
	#40;
	wData=4'b0;
	wAddr=3'b0;
	
	#60;
	rAddr=3'b000;
	
	#20;
	rAddr=3'b001;
	
	#40;
	rAddr=3'b010;
	
	#40;
	rAddr=3'b011;
	
	#40;
	rAddr=3'b000;
	
	#60;
	wData=4'b0100;
	wAddr=3'b100;
	rAddr=3'b100;
	
	#80;
	wData=4'b0000;
	wAddr=3'b000;
	rAddr=3'b000;
end

initial begin
	wEn=1'b0;
	rEn=1'b0;
	#45;
	
	wEn=1'b1;
	#20;
	
	wEn=1'b0;
	#20;
	
	wEn=1'b1;
	#20;
	
	wEn=1'b0;
	#20;
	
	wEn=1'b1;
	#20;
	
	wEn=1'b0;
	#20;
	
	wEn=1'b1;
	#20;
	
	wEn=1'b0;
	#60;
	
	
	rEn=1'b1;
	#20;
	
	rEn=1'b0;
	#20;
	
	rEn=1'b1;
	#20;
	
	rEn=1'b0;
	#20;
	
	rEn=1'b1;
	#20;
	
	rEn=1'b0;
	#20;
	
	rEn=1'b1;
	#20;
	
	rEn=1'b0;
	#80;
	
	rEn=1'b1;
	wEn=1'b1;
	#20;
	rEn=1'b0;
	wEn=1'b0;
	#20;
	rEn=1'b1;
	wEn=1'b0;
	#20;
	rEn=1'b0;
	wEn=1'b0;
end
	
initial begin
	ena=1'b0;
	#42;
	ena=1'b1;
	#26;
	ena=1'b0;
	#14;
	ena=1'b1;
	#26;
	ena=1'b0;
	#14;
	ena=1'b1;
	#26;
	ena=1'b0;
	#14;
	ena=1'b1;
	#26;
	ena=1'b0;
	#274;
	
	ena=1'b1;
	#26;
	ena=1'b0;
end
endmodule