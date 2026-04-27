`timescale 1ns / 1ps
module led_disp_tb();
	reg [15:0] bin;
	reg clk;
	reg rst;
	wire [7:0] select;
	wire [7:0] seg_1;
	wire [7:0] seg_2;
	
	initial begin
		clk = 1'b0 ;
		forever #10 clk = ~clk;
	end
	
	initial begin
		rst = 1'b1 ;
		#20 rst = 1'b0;
		#90_000_000 rst = 1'b0;
	end

	initial begin 
		#5 bin =16'b0010_1100_1010_0001; 
		#30_000_000 bin = 16'b0000_0000_0010_0010;
		#30_000_000 bin = 16'b0111_1011_1101_1110;
	end

	top_digital_tube u_top_digital_tube (
		.clk	(clk),
		.rst	(rst),
		.switch	(bin),
		.segs1	(seg_1),
		.segs2	(seg_2),
		.seg_sel(select)
	);
endmodule
