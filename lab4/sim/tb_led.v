`timescale 1ns/1ns

module tb_led ();
wire    [7:0]    led;
led u_led(
    .led(led)
);
endmodule