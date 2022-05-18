module counter (
	clk , // ク ロ ッ ク
	rst , // リ セ ッ ト
	out // 出 力
	);
	input clk , rst ;
	output [7:0] out ;
	wire [7:0] s, q;
	wire cout ;
	generate
		assign out = q;
		// 2.2.1 で 作 成 し た8 - b i t 全 加 算 器 を 使 用
		fa8 adder (q, 8'b0 , 1'b1 , s, cout );
		
		genvar i;
		for (i =0; i <8; i=i +1) begin: dff8
			// D flip flop の 作 成, DFF
			dff c(
				.d(s[i]) ,
				.clk ( clk ),
				.clrn (!rst), // clear negative
				.prn (1'b1),
				.q(q[i]));
		end
	endgenerate
endmodule
