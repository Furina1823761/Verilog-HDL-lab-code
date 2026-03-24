/*使用9片三八译码器*/
module decoder_6_64(
    input               E   ,              
    input   [5:0]       A   ,              
    output  [63:0]      Y                  
);
    wire [7:0]  EN; 

    decoder_3_8    U_EN( 
        .E(E        ),
        .A(A[5:3]   ),
        .Y(EN       )     
    );
    genvar      gvr_i; 
    generate 
        for(gvr_i = 0; gvr_i < 8; gvr_i = gvr_i + 1) begin: decode_2_inst
            decoder_3_8 U_decoder_3_8 (
                .E(EN[gvr_i]            ),
                .A(A[2:0]               ),
                .Y(Y[gvr_i*8+7:gvr_i*8] ) 
            );
        end
    endgenerate
endmodule