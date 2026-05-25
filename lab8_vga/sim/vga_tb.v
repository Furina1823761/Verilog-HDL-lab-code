`timescale 1ns / 1ps

module vga_tb();
reg         clk,rst;
wire        hsync,vsync;
wire [3:0]  vga_r,vga_g,vga_b;

vga_top u_vga_top(
.sys_clk(clk    ),
.rst    (rst    ),
.hsync  (hsync  ),
.vsync  (vsync  ),
.vga_r  (vga_r  ),
.vga_g  (vga_g  ),
.vga_b  (vga_b  )
);

initial begin
    clk = 1'b0 ;
    rst = 1'b0 ;
    #45;
    rst = 1'b1 ;
    #100;
    rst = 1'b0 ;
end

always #10 clk = ~clk;


endmodule