module memory (
	input clk, rst, run,
	output waits, fetcha, fetchb, execa, execb,
	output [7:0] addr, // 現在のアドレスバスの値を出力 
		data_in, // 入力データバスの値を出力
		data_out // 出力データバスの値を出力
//		, pc_out_
);

	wire [7:0] pc_out;
//	wire pc_inc;

	// ス テ ー ジ 制 御 部
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
// module stage (
//	input wire clk , rst , run , halt ,
//	output wire waits , fetcha , fetchb , execa , execb
//);

	// プ ロ グ ラ ム カ ウ ン タ
	pc p(
		clk,
		rst,
		fetcha + fetchb, // inc H
		1'b0, // load
		8'b0, // in
		pc_out // out
	);
//module pc(
//	input clk , rst , inc , load ,
//	input [7:0] in ,
//	output [7:0] out
//);

	// RAM
	ram r(
		addr,
		clk,
		data_in, // data ??
		fetcha + fetchb, // read enable
		1'b0, // write enable
		data_out // q: data_out
	);
// module ram ( address , clock , data , rden , wren , q);
	
	// ア ド レ ス バ ス の セ レ ク ト
	function [7:0] select_addr;
		input _fetcha;
		input _fetchb;
		input [7:0] _pc_out;
		
		begin
			if (/* 条 件 */ fetcha + fetchb == 1'b1) select_addr = _pc_out;
			else select_addr = 8'b0;
		end
	endfunction

	// ア ド レ ス バ ス を 条 件 に 応 じ て 接 続
	assign addr = select_addr( fetcha , fetchb , pc_out );

	// pcの動作 inc
//	function set_pc_inc;
//		input fetcha, fetchb, execa, execb;
//		
//		if (fetcha == 1'b1) set_pc_inc = 1'b1;
//		else if (fetchb == 1'b1) set_pc_inc = 1'b1;
//		else if (execa == 1'b0) set_pc_inc = 1'b0;
//		else if (execb == 1'b0) set_pc_inc = 1'b0;
//		else set_pc_inc = 1'b0;
//	endfunction
//	
//	assign pc_inc = set_pc_inc( fetcha, fetchb, execa, execb );
//	
//	assign pc_out_ = pc_out_;
endmodule
