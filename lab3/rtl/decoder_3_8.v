module decoder_3_8(
    input               E   ,              
    input   [2:0]       A   ,              
    output  [7:0]       Y                  
);
    wire [1:0]  EN; 

    genvar      gvr_i; 
    generate 
        for(gvr_i = 0; gvr_i < 2; gvr_i = gvr_i + 1) begin: decode_2_inst
            decoder_2_4 U_decoder_2_4 (
                .A0 (A[0]                   ),
                .A1 (A[1]                   ), 
                .E  (EN[gvr_i] | E          ), 
                .Y  (Y[gvr_i*4+3:gvr_i*4]   )   
            );
        end
    endgenerate

    assign EN[0] = A[2];    
    assign EN[1] = ~A[2];

endmodule