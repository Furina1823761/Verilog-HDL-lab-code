`timescale 1ns/1ps

module tb_decoder_2_4 ();
    reg              E;
    reg     [1:0]    A;
    wire    [3:0]    Y;
    
    parameter out_N = 4;

    decoder_2_4 uut(
        .A0(A[0]),
        .A1(A[1]),
        .E (E   ),
        .Y (Y   )
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