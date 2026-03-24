module gate_xnor(
	input  a,
	input  b,
	output y
);
	
assign y = (~a & ~b) | (a & b);
	
endmodule  