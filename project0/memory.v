module memory (
	input clk, rst, run, 
	output waits, fetcha, fetchb, execa, execb,
	output [7:0] addr, // 現在のアドレスバスの値を出力 
		data_in, // 入力データバスの値を出力
		data_out, // 出力データバスの値を出力
		ira, irb
);

	wire [7:0] pc_out;
//	wire pc_inc;

	// ス テ ー ジ 制 御 部
	// module stage (
	//	input wire clk , rst , run , halt ,
	//	output wire waits , fetcha , fetchb , execa , execb
	//);
	stage s(
		clk,
		rst,
		run,
		1'b0,
		waits,
		fetcha,
		fetchb,
		execa,
		execb
	);


	// プ ロ グ ラ ム カ ウ ン タ
	//module pc(
	//	input clk , rst , inc , load ,
	//	input [7:0] in ,
	//	output [7:0] out
	//);
	pc p(
		clk,
		rst,
		fetcha + fetchb, // inc H
		1'b0, // load
		8'b0, // in
		pc_out // out
	);
	
	// 命令レジスタ ira: インストラクションレジスタ
	function [7:0] select_ira;
		input _fetcha;
		input [7:0] _data_out;
		if (_fetcha == 1'b1) select_ira = _data_out;
//		else select_ira = 
	endfunction
	assign ira = select_ira(fetcha, data_out);
	
	wire [7:0] out_ira;
	generate
		genvar i;
		for (i = 0; i < 8; i = i+1) begin: genira
			// D F F E を 8 つ 作 成 ．D Flip Flop with Enable, DFFE
			// 入 力 と 出 力 の 信 号 の 各 ビ ッ ト を 接 続 ．
			dffe c(
				.d(ira[i]) , // 入力信号（1-bit）
				.clk(clk), // クロック信号（1-bit）
				.clrn(!rst), // clear negative：負論理で定義されたクリア（1-bit）
				.prn(1'b1), // preset negative：負論理で定義されたプリセット（1-bit）
				.ena(fatcha), // enable
				.q(out_ira[i]) // 
			);
		end
	endgenerate
	

	// 命令レジスタ irb
	function [7:0] select_irb;
		input _fetchb;
		input _data_out;
		if (_fetchb == 1'b1) select_irb = _data_out;
	endfunction
	assign irb = select_irb(fetchb, data_out);
	
	wire [7:0] out_irb;
	generate
		for (i = 0; i < 8; i = i+1) begin: genirb
		// D F F E を 8 つ 作 成 ．D Flip Flop with Enable, DFFE
		// 入 力 と 出 力 の 信 号 の 各 ビ ッ ト を 接 続 ．
		dffe c(
			.d(irb[i]) , // 入力信号（1-bit）
			.clk(clk), // クロック信号（1-bit）
			.clrn(!rst), // clear negative：負論理で定義されたクリア（1-bit）
			.prn(1'b1), // preset negative：負論理で定義されたプリセット（1-bit）
			.ena(fatchb), // enable
			.q(out_irb[i]) // 
		);
		end
	endgenerate

	// ア ド レ ス バ ス の セ レ ク ト
	function [7:0] select_addr;
		input _fetcha, _fetchb, _execa;
		input [7:0] _pc_out, _out_ira;
		
		begin
			if (/* 条 件 */ _fetcha + _fetchb == 1'b1) select_addr = _pc_out;
			else if (_execa == 1'b1) select_addr = _out_ira;
			else select_addr = 8'b0;
		end
	endfunction

	// ア ド レ ス バ ス を 条 件 に 応 じ て 接 続
	assign addr = select_addr( fetcha , fetchb , execa, pc_out, out_ira);
	
		// ア ド レ ス バ ス の セ レ ク ト
	function [7:0] select_data_in;
		input _execa;
		input [7:0] _out_irb;
		
		begin
			if (_execa == 1'b1) select_data_in = _out_irb;
			else select_data_in = 8'b0;
		end
	endfunction

	// ア ド レ ス バ ス を 条 件 に 応 じ て 接 続
	assign data_in = select_data_in( execa, out_irb );
	
	
	// RAM たち下がり時
	// module ram ( address , clock , data , rden , wren , q);
	ram r(
		addr,
		clk,
		data_in, // data
		fetcha ^ fetchb, // read enable
		execa, // write enable
		data_out // q: data_out
	);
	
//	assign pc_out_ = pc_out_;
endmodule
