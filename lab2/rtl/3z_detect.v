module zero3_detecting(
	input 			clk			,
	input 			rst			,
	input 			bitin		,
	output 	reg 	indicator	
);

	reg [1:0]	cstate,	nstate;

	parameter s0=2'b00, s1=2'b01, s2=2'b10, s3=2'b11;

	always @(posedge clk or negedge rst) begin 
		if (rst == 1'b0)
			cstate <= s0;
		else 
			cstate <= nstate;
	end

	always @(*) begin
		case (cstate)
			s0: begin if (bitin == 1'b0) nstate = s1; else nstate = s0; end
			s1: begin if (bitin == 1'b0) nstate = s2; else nstate = s0; end
			s2: begin if (bitin == 1'b0) nstate = s3; else nstate = s0; end
			s3: begin if (bitin == 1'b0) nstate = s3; else nstate = s0; end
			default: nstate = s0;
		endcase
	end

	always @(*)begin
		case (cstate)
			s0: indicator = 1'b0;
			s1: indicator = 1'b0;
			s2: indicator = 1'b0;
			s3: indicator = 1'b1;
			default: indicator =1'b0;
		endcase
	end
	
endmodule