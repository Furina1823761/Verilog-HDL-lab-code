module ROM_ctrl (
    input               clk         ,    
    input               ena         ,
    input   [3:0]       addr        ,
    output  [7:0]       dout        ,
    output  reg         data_valid
);

always @(posedge clk) begin 
    if (ena) 
        data_valid <= 1'b1; 
    else 
        data_valid <= 1'b0; 
end

ROM ROM(
    .clka       (clk),
    .ena        (ena),
    .addra      (addr), 
    .douta      (dout) 
);



endmodule