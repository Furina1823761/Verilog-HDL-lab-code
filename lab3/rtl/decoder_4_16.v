module decoder_4_16(
    input               E   ,              
    input   [3:0]       A   ,              
    output  [15:0]      Y                  
);
    wire [3:0]  EN; 

    decoder_2_4    U_EN( 
    .A0 (A[2]   ),
    .A1 (A[3]   ),
    .E  (E      ),
    .Y  (EN     )
    );
    genvar      gvr_i; 
    generate 
        for(gvr_i = 0; gvr_i < 4; gvr_i = gvr_i + 1) begin: decode_2_inst
            decoder_2_4 U_decoder_2_4 (
            .A0 (A[0]                   ),
            .A1 (A[1]                   ), 
            .E  (EN[gvr_i]              ), 
            .Y  (Y[gvr_i*4+3:gvr_i*4]   )   
            );
        end
    endgenerate
endmodule