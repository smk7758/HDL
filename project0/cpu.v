module cpu (
	input clk, rst, run, halt,
	output [7:0] addr, data_in, data_out,
	output waits, fetcha, fetchb, execa, execb
);

// stage
/* こ こ で ， s t a g e に 接 続 さ れ る 信 号 線 を 宣 言 */
stage s(
	clk, rst, run, halt,
	waits, fetcha, fetchb, execa, execb
);
//module stage (
//	input wire clk , rst , run , halt ,
//	output wire waits , fetcha , fetchb , execa , execb
//);

wire [7:0] pc_in, pc_out;

// pc
/* こ こ で ， p c に 接 続 さ れ る 信 号 線 を 宣 言 */
	pc p(
		clk,
		rst,
		fetcha ^ fetchb, // inc H
		1'b0, // load
		pc_in, // in
		pc_out // out
	);
//module pc(
//	input clk,
//		rst,
//		inc, // Hのとき、out = outo(クロックの立ち上がり直前の out の出力値)+1
//		load, // H, inc = Lのとき、out = in
//	input [7:0] in,
//	output [7:0] out
//);

wire cload;
wire [3:0] asel, bsel, csel;
wire [7:0] cin, aout, bout;

// register
/* こ こ で ， r e g i s t e r に 接 続 さ れ る 信 号 線 を 宣 言 */
register r(
	clk, rst,
	cload,
	asel, bsel, csel,
	cin,
	aout, bout // out
);
//module register (
//	input clk , rst,
//			 cload,
//	input [3:0] asel, bsel, csel,
//	input [7:0] cin,
//	output [7:0] aout, bout
//);

wire rden, wren;

// ram
/* こ こ で ， r a m に 接 続 さ れ る 信 号 線 を 宣 言 */
ram m(
	addr, clk, 
	data_in,
	rden, wren,
	data_out
);
//	// RAM たち下がり時
//	// module ram ( address , clock , data , rden , wren , q);
//	ram r(
//		addr,
//		clk,
//		data_in, // data
//		fetcha ^ fetchb, // read enable
//		execa, // write enable
//		data_out // q: data_out
//	);

//rden = fetch_a ^ fetch_b;
//wren
// 状態が execa もしくは execb のとき，opcode に応じて読み込みか書き込みか決まる（例えば，LD か ST か）

//assign {rden, wren} = assign_ram( fetcha, fetchb, execa, execb, opcode );

wire alu_ena;
wire [1:0] alu_ctrl;
wire [7:0] alu_ain, alu_bin;
wire cflag, zflag;
wire [7:0] sout;

// alu
/* こ こ で ， a l u に 接 続 さ れ る 信 号 線 を 宣 言 */
alu a(
	clk, rst,
	alu_ena, alu_ctrl,
	cflag, zflag,
	sout
);
//module alu (
//	input clk , rst , ena ,
//	input [1:0] ctrl ,
//	input [7:0] ain , bin ,
//	output cflag , zflag ,
//	output [7:0] sout // 出力
//);

endmodule
