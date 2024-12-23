`timescale 1ns/1ps
module sha3_256to32(
	input clk,  
	input md_valid_o,
	input reset,
	input [0:1343] dout256,  
    input [2:0] mode_sel_i,	
	output wire [0:63] dout32,
	output wire valid_32
	);
	
reg [5:0]N;
reg [0:63]r_dout32;
reg [0:1343]otemp;
reg q;
reg [5:0]i;
reg valid;

always @(posedge clk)
	if(reset || (i==N) ) begin
		i <= 6'b0;
		q <= 1'b0;
		otemp <= 1344'b0;
		r_dout32 <= 64'b0;		
		end
	else if(md_valid_o) begin
		q <= 1'b1;
		otemp <= dout256;
		end
	else if(q) 
		begin
			r_dout32 <= otemp[0:63];
			otemp <= {otemp[63:1343],64'b0};
			i <= i + 1'b1;
		end
	else;		

always @(posedge clk)
	begin
		case(mode_sel_i)
			3'd0:    N=6'd21;     //1344,SHAKE128
			3'd1:    N=6'd17;     //1088,SHAKE256
			3'd2:    N=6'd8;      //512, SHA3-512
			3'd3:    N=6'd6;      //384, SHA3-384
			3'd4:    N=6'd4;      //256, SHA3-256
			3'd5:    N=6'd4;      //224, SHA3-224
			default: N=6'd8;      //256
		endcase
		if(reset) valid <= 1'b0;
		else if(i==(N-1)) valid <= 1'b1;
		else valid <= 1'b0;
	end

assign valid_32 = valid;
assign dout32 = r_dout32;

endmodule