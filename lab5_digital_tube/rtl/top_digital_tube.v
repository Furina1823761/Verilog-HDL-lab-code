module top_digital_tube (
input               clk     ,
input               rst     ,
input   [15:0]      switch  ,
output  [7:0]       segs1   ,   //段选
output  [7:0]       segs2   ,   //段选
output  [7:0]       seg_sel      //片选
);
wire    [18:0]      bcd     ;
assign segs2 = segs1;
bin2bcd u_bin2bcd (
    .bin(switch ),
    .bcd(bcd    )
);

segs_disp u_segs_disp (
    .clk    (clk    ),
    .rst    (rst    ),
    .bcd    (bcd    ),
    .segs   (segs1  ),
    .seg_sel(seg_sel)
);

endmodule