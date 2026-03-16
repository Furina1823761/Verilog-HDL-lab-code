`timescale 1 ns/100 ps
module tb_gate_xor();
	reg ain;
	reg bin;
	reg gold;
	wire result;
	wire trace;
	
	gate_xor DUT(
		.a(ain),
		.b(bin),
		.y(result)
    );
		
	initial begin
		#10 ain=0;bin=0;gold=0;
		#10 ain=0;bin=1;gold=1;
		#10 ain=1;bin=0;gold=1;
		#10 ain=1;bin=1;gold=0;
		end
		
	assign trace = (result & gold)+(~result & ~gold);
	
endmodule