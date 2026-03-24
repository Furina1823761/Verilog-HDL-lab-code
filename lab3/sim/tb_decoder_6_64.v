`timescale 1ns/1ps

module tb_decoder_6_64 ();
    reg              E;
    reg     [5:0]    A;
    wire    [63:0]    Y;
    
    parameter out_N = 64;

    decoder_6_64 uut(
        .A  (A   ),
        .E  (E   ),
        .Y  (Y   )
    );

    integer     i ;
    initial begin
        A <= 2'b0;
        E <= 1'b0;
     
        for (i = 0; i < out_N; i = i + 1) begin
            #1  A = A + 1;
        end
    end




endmodule