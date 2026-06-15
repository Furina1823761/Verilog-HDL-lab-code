`timescale 1ns/1ps

module vga_test_tb ();

reg         clk;
reg         rst_n;
wire        hsync,vsync;
wire [3:0]  vga_r,vga_g,vga_b;

parameter   PERIED = 20;
    
vga_test u_vga_test(
    .clk    (clk  ),
    .rst_n  (rst_n),
    .hsync  (hsync),
    .vsync  (vsync),
    .vga_r  (vga_r),
    .vga_g  (vga_g),
    .vga_b  (vga_b)
);

always #(PERIED/2)  clk = ~clk;

initial begin
    clk <= 1'b0;

    rst_n <= 1'b1;
    #45 rst_n <= 1'b0;
    #100 rst_n <= 1'b1;

end

endmodule