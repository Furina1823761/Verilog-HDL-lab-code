module RAM  #(
    parameter BIT_WIDTH     = 4,
    parameter ADDR_WIDTH    = 3,
    parameter DEPTH         = 1 << ADDR_WIDTH)
(
    input	                        clk     ,
    input                           wEn     , 
    input                           rEn     ,
    input       [ADDR_WIDTH-1:0]    wAddr   ,
    input       [ADDR_WIDTH-1:0]    rAddr   ,
    input       [BIT_WIDTH-1:0]     wData   ,
    output reg  [BIT_WIDTH-1:0]     rData
);
	
reg     [BIT_WIDTH-1:0]     memreg [0:DEPTH-1];

always @ (posedge clk)begin
	if (wEn) begin
		memreg[wAddr] <= wData;
	end
end

always @ (posedge clk) begin
	if (rEn) begin
		rData <= memreg[rAddr];
	end
end

endmodule