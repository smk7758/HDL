module cpu (
	input clk, rst, run, halt,
	output [7:0] addr, data_in, data_out,
	output waits, fetcha, fetchb, execa, execb
	,
//	output [7:0] pc_in, pc_out // TODO: 検証
//	,
	output [7:0] opcode_, operand_ // TODO: 検証
	,
	// output rden, wren // TODO: 検証
	// ,
	output [2:0] asel_, bsel_,
	// output [7:0] aout_
	// ,
	// output [7:0] bout_
//	,
	// output [7:0] cin_ // r[a] (値)  // TODO: 検証
	// ,
	// output [2:0] opcode_third_
	// ,
	output [7:0] alu_out_
	,
	output [7:0] alu_ain_, alu_bin_
	// ,
	// output [2:0] operand_first_, operand_second_
);
//assign opcode_third_ = opcode_third;
assign opcode_ = opcode;
assign operand_ = operand;
assign alu_out_ = alu_out;
// assign {asel_, bsel_} = {asel, bsel};
assign {alu_ain_, alu_bin_} = {alu_ain, alu_bin};
//assign {operand_first_, operand_second_} = {operand_first, operand_second};
assign {aout_, bout_} = {aout, bout};
// assign cin_ = cin;

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

// pc
/* こ こ で ， p c に 接 続 さ れ る 信 号 線 を 宣 言 */
wire pc_in_ena; // pc_inを有効にするかどうか
wire [7:0] pc_in, pc_out;
pc p(
	clk,
	rst,
	fetcha ^ fetchb, // inc H
	pc_in_ena, // load
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

function [8:0] assign_pc_in;
	// input [7:0] pc_in;
	input _rst, _halt;
	input [7:0] _opcode;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [2:0] _opcode_third;
	input [7:0] _operand;
	input _cflag, _zflag;

	begin
		// if (_rst == 1'b1) assign_pc_in = {}
		// if (/* HLT */_opcode == 8'b0 && _halt == 1'b1)
		// 	assign_pc_in = {1'b0, 8'b0}; // 命令を読み込んでから停止
		if (/* JC～JMPまで */ _opcode_first == 3'b001) begin
			if (/* JMP */ _opcode_second == 2'b11 && _opcode_third == 3'b111)
				assign_pc_in = {1'b1, _operand};
			else begin
				// JMPを除く pc_in = m (条件付き)
				// if (/* JC */ _opcode_third == 3'b0_00 && _cflag == 1'b1) assign_pc_in = {1'b1, operand};
				// if (/* JNC */ _opcode_third == 3'b0_01 && _cflag != 1'b1) assign_pc_in = {1'b1, operand};
				// if (/* JZ */ _opcode_third == 3'b0_10 && _zflag == 1'b1) assign_pc_in = {1'b1, operand};
				// if (/* JNC */ _opcode_third == 3'b0_11 && _zflag != 1'b1) assign_pc_in = {1'b1, operand};
				// else
					assign_pc_in = {1'b0, 8'b0};
			end
			// assign_pc_in = {1'b1, _opcode_second};
			end
		else assign_pc_in = {1'b0, 8'b0};
	end
endfunction

// assign {pc_in_ena, pc_in} = assign_pc_in(rst, halt,
// 									opcode, opcode_first, opcode_second, opcode_third,
// 									operand, cflag, zflag
// 									);

assign {pc_in_ena, pc_in} = {1'b0, 8'b0}; // TODO: ?

// register
/* こ こ で ， r e g i s t e r に 接 続 さ れ る 信 号 線 を 宣 言 */
wire cload; // 立ち上がり時にcsel で選択された レジスタに cin の値が記憶される
wire [2:0] asel, bsel, csel; // a (番地)
wire [7:0] aout, bout, cin; // r[a] (値)
register r(
	clk, // TODO: 立ち上がり、立ち下がり
	rst,
	cload,
	asel, bsel, csel,
	cin,
	aout, bout // out
);
//module register (
//	input clk , rst,
//			 cload,
//	input [2:0] asel, bsel, csel,
//	input [7:0] cin,
//	output [7:0] aout, bout
//);

wire [2:0] operand_first, operand_second;
wire [1:0] operand_third; // not using
assign {operand_first, operand_second, operand_third} = operand;

function [8:0] assign_asel_bsel_csel;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [2:0] _opcode_third;
	input [2:0] _operand_first, _operand_second;
	input [1:0] _operand_third;
	input _execa, _execb;

	begin
		if (_execa ^ _execb == 1'b1) begin
			if (/* LD: loadのとき*/ _opcode_first == 3'b000 && _opcode_second == 2'b01)
				assign_asel_bsel_csel = {3'b0, 3'b0, _opcode_third};
				// assign_asel_bsel_csel = {3'b0, 3'b1, _opcode_third}; // TODO: 検証
			if (/* STのとき */ _opcode_first == 3'b000 && _opcode_second == 2'b10)
				assign_asel_bsel_csel = {_opcode_third, 3'b0, 3'b0};
				// assign_asel_bsel_csel = {_opcode_third, 3'b1, 3'b0}; // TODO: 検証
			else if (/* ALUの計算のとき */ _opcode_first == 3'b100) begin
				if (/* INC, DEC */ opcode_second == 2'b00 || opcode_second == 2'b01)
					assign_asel_bsel_csel = {_operand_first, 3'b0, _opcode_third};
				else /* ADD, SUB */
					assign_asel_bsel_csel = {_operand_first, _operand_second, _opcode_third};
					// assign_asel_bsel_csel = {3'b000, 3'b001, _opcode_third}; // TODO:検証
			end
			else assign_asel_bsel_csel = 9'b0;
		end
		else assign_asel_bsel_csel = 9'b0;
	end
endfunction

// assign {asel, bsel, csel} = assign_asel_bsel_csel(opcode_first, opcode_second, opcode_third,
// 	operand_first, operand_second, operand_third,
// 	execa, execb);
assign {asel, bsel, csel} = {6'b000_001, opcode_third};

function [8:0] assign_cload_cin;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [7:0] _data_out, _alu_out;

	begin
		if (/* LD: loadのとき*/ _opcode_first == 3'b000 && _opcode_second == 2'b01)
			assign_cload_cin = {1'b1, _data_out};
		else if (/* ALUの計算のとき */ _opcode_first == 3'b100)
			assign_cload_cin = {1'b1, _alu_out};
		else assign_cload_cin = 9'b0;
	end
endfunction
assign {cload, cin} = assign_cload_cin(opcode_first, opcode_second, data_out, alu_out);




// ram
/* こ こ で ， r a m に 接 続 さ れ る 信 号 線 を 宣 言 */
wire rden, wren;
ram m(
	addr, clk,
	data_in,
	rden, wren,
	data_out // out
);
//	RAM たち下がり時?
//	// module ram ( address , clock , data , rden , wren , q);
//	ram r(
//		addr,
//		clk,
//		data_in, // data
//		fetcha ^ fetchb, // read enable
//		execa, // write enable
//		data_out // q: data_out
//	);

// RAMの読み書き位置をどのように指定するか → カウンタ回路を使用 (pcじゃダメ？)

// アドレスバスのselect
function [7:0] select_addr;
	input _rst, _fetcha, _fetchb, _execa, _execb;
	input [7:0] _pc_out, _operand;
	input [2:0] _opcode;

	begin
		if (_rst == 1'b1) select_addr = 8'b0;
		else if (_fetcha ^ _fetchb == 1'b1) select_addr = _pc_out;
		else if ((_execa ^ _execb == 1'b1) && (opcode[7] == 0)) select_addr = _operand;
		else select_addr = 8'b0;
	end
endfunction

assign addr = select_addr( rst, fetcha , fetchb , execa, execb, pc_out, operand, opcode);

// TODO: now
// データバスのselect
function [7:0] assign_data_in;
	input _execa, _execb;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [7:0] _aout; // aout

	begin
		if (/* ST: storeのとき */ (_execa ^ _execb == 1'b1) 
			&& (_opcode_first == 3'b0 && _opcode_second == 2'b10))
			assign_data_in = _aout;
		else assign_data_in = 8'b0;
	end
endfunction

assign data_in = assign_data_in(execa, execb, opcode_first, opcode_second, aout);
// assign data_in = aout;
// assign data_in = 8'b1111_1111;

// opcodeを分解する
wire [1:0] opcode_second;
wire [2:0] opcode_first, opcode_third;
assign {opcode_first, opcode_second, opcode_third} = opcode;

function [1:0] assign_ram;
	input _fetcha, _fetchb, _execa, _execb;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [2:0] _opcode_third;

	begin
		if (/* on fetch */ _fetcha ^ _fetchb == 1'b1) assign_ram = {1'b1, 1'b0}; // read
		else if (/* on exec */ _execa ^ _execb == 1'b1 && _opcode_first == 3'b000) begin
			// 状態が execa もしくは execb のとき，opcode に応じて読み込みか書き込みか決まる（例えば，LD か ST か）
			case (_opcode_second)
				2'b01: assign_ram = {1'b1, 1'b0}; // LD: load, read
				2'b10: assign_ram = {1'b0, 1'b1}; // ST: store, write
				default: assign_ram = 2'b0;
			endcase
		end
		else assign_ram = 2'b0;
	end
endfunction

assign {rden, wren} = assign_ram( fetcha, fetchb, execa, execb, opcode_first, opcode_second, opcode_third );


//  ～～ opcode, oprand ～～
wire [7:0] opcode, operand;
// fetchaでopcode, fetchbでoperandを入れる

generate
	genvar i;
	for (i = 0; i < 8; i = i+1) begin: genoprge
		// 命令レジスタ ira: インストラクションレジスタ
		// D F F E を 8 つ 作 成 ．D Flip Flop with Enable, DFFE
		// 入 力 と 出 力 の 信 号 の 各 ビ ッ ト を 接 続 ．
		dffe iras(
			.d(data_out[i]) , // 入力信号（1-bit）
			.clk(!clk), // クロック信号（1-bit）// memory → ragister (半クロックずらし)
			.clrn(!rst), // clear negative：負論理で定義されたクリア（1-bit）
			.prn(1'b1), // preset negative：負論理で定義されたプリセット（1-bit）
			.ena(fetcha), // enable
			.q(opcode[i]) // out
		);

		// 命令レジスタ irb
		dffe irbs(
			.d(data_out[i]) , // 入力信号（1-bit）
			.clk(!clk), // クロック信号（1-bit）// memory → ragister (半クロックずらし)
			.clrn(!rst), // clear negative：負論理で定義されたクリア（1-bit）
			.prn(1'b1), // preset negative：負論理で定義されたプリセット（1-bit）
			.ena(fetchb), // enable DFFEのenable（1-bit）
			.q(operand[i]) // out
		);
	end
endgenerate


// alu
/* こ こ で ， a l u に 接 続 さ れ る 信 号 線 を 宣 言 */
wire alu_ena;
wire [1:0] alu_ctrl;

wire [7:0] alu_ain, alu_bin;
// function [15:0] assign_alu_input;
// 	input [7:0] _aout, _bout;
// 	input _execa, _execb;

// 	begin
// 		if (_execa ^ _execb == 1'b1) assign_alu_input = {_aout, _bout};
// 		else assign_alu_input = 16'b0;
// 	end
// endfunction
assign alu_ain = (execa ^ execb == 1'b1) ? aout : 8'b0; // TODO: まだ
assign alu_bin = (execa ^ execb == 1'b1) ? bout : 8'b0; // TODO: まだ
// assign {alu_ain, alu_bin} = {aout, bout};
// assign {alu_ain, alu_bin} = assign_alu_input(aout, bout, execa, execb);
// assign {alu_ain, alu_bin} = {8'b11110000, 8'b11110000};

wire cflag, zflag; // output

wire [7:0] alu_out;

alu a(
	clk, rst,
	alu_ena, alu_ctrl,
	alu_ain, alu_bin,
	// (execa ^ execb == 1'b1) ? aout : 8'b0, // alu_ain
	// (execa ^ execb == 1'b1) ? bout : 8'b0, // alu_bin
	// 8'b0, 8'b0,
	cflag, zflag, // out
	alu_out // sout
);
//module alu (
//	input clk , rst ,
//  		ena ,
//	input [1:0] ctrl ,
//	input [7:0] ain , bin ,
//	output cflag , zflag ,
//	output [7:0] sout // 出力
//);

function [2:0] assign_alu_ctrl;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;

	begin
		if (_opcode_first == 3'b100) assign_alu_ctrl = {1'b1, _opcode_second};
		else assign_alu_ctrl = 3'b0;
	end
endfunction

assign {alu_ena, alu_ctrl} = assign_alu_ctrl(opcode_first, opcode_second);

endmodule
