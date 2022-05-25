module pc(
	input clk,
		rst,
		inc, // Hのとき、out = outo(クロックの立ち上がり直前の out の出力値)+1
		load, // H, inc = Lのとき、out = in
	input [7:0] in,
	output [7:0] out
);
	// 入 力 信 号 の セ レ ク ト 用 の 配 線
	wire [7:0] d;
	wire e;

	// dffe の イ ネ ー ブ ル 信 号
	assign e = inc | load ;
	generate
		genvar i;
		for (i =0; i <8; i=i+1) begin: gen
			// D F F E を 8 つ 作 成 ．D Flip Flop with Enable, DFFE
			// 入 力 と 出 力 の 信 号 の 各 ビ ッ ト を 接 続 ．
			dffe c(
			.d(d[i]) ,
			.clk ( clk ),
			.clrn (! rst ),
			.prn (1'b1) ,
			.ena (e),
			.q(out[i]));
		end
	endgenerate

	function [7:0] judge_d ;
		input _load , _inc ;
		input [7:0] _in , _out ;
		begin
			if ( _load == 1'b1) begin
				judge_d = _in ;
			end else if ( _inc == 1'b1) begin
				judge_d = _out + 8'b00000001 ;
			end else begin
				judge_d = 8'bx;
			end
		end
	endfunction

	// l o a d 信 号 と i n c 信 号 に 応 じ た 入 力 信 号 の 定 義
	assign d = judge_d (load , inc , in , out );
endmodule
