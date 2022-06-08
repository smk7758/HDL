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

// pc
/* こ こ で ， p c に 接 続 さ れ る 信 号 線 を 宣 言 */
wire pc_in_ena; // pc_inを有効にするかどうか
wire [7:0] pc_in, pc_out; // TODO
pc p(
	clk,
	rst,
	fetcha ^ fetchb, // inc H // TODO
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
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [2:0] _opcode_third;
	input [7:0] _operand
	input _cflag, _zflag;

	begin
		if (/* JC～JMPまで */ _opcode_first == 3'001) begin
			if (/* JMP */ _opcode_second == 2'b11) assign_pc_in = {1'b1, }
			else begin
				
			end
			// assign_alu_ctrl = {1'b1, _opcode_second};
		end
		else assign_alu_ctrl = 3'b0;
	end
endfunction

assign {pc_in_ena, pc_in} = assign_alu_ctrl(opcode_first, opcode_second, opcode_third, operand, cflag, zflag);


// register
/* こ こ で ， r e g i s t e r に 接 続 さ れ る 信 号 線 を 宣 言 */
wire cload;
wire [2:0] asel, bsel, csel;
wire [7:0] cin, aout, bout;
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
//	input [2:0] asel, bsel, csel,
//	input [7:0] cin,
//	output [7:0] aout, bout
//);

// assign asel = opcode_third;

// TODO: now

function [7:0] assign_cin;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [7:0] _data_out, _alu_out

	begin
		if (/* LD: loadのとき*/ _opcode_first == 3'000 && _opcode_second == 2'b01) assign_cin = _data_out;
		else if (/* ALUの計算のとき */_opcode_first == 3'b100) assign_cin = _alu_out;
		else assign_cin = 8'b0;
	end
endfunction
assign cin = assign_cin(opcode_first, opcode_second, data_out, alu_out);

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

// RAMの読み書き位置をどのように指定するか → カウンタ回路を使用

// アドレスバスのselect
function [7:0] select_addr;
	input _rst, _fetcha, _fetchb, _execa;
	input [7:0] _pc_out, _ira;
	
	begin
		if (_rst == 1'b1) select_addr = 8'b1;
		else if (_fetcha ^ _fetchb == 1'b1) select_addr = _pc_out;
		else if (_execa == 1'b1) select_addr = _ira;
		else select_addr = 8'b0;
	end
endfunction

assign addr = select_addr( rst, fetcha , fetchb , execa, pc_out, ira_out);

// データバスのselect
function [7:0] select_data_in;
	input _execa;
	input [7:0] _irb;
	
	begin
		if (_execa == 1'b1) select_data_in = _irb;
		else select_data_in = 8'b0;
	end
endfunction

assign data_in = select_data_in( execa, irb );

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

function [7:0] assign_data_in;
	input [2:0] _opcode_first;
	input [1:0] _opcode_second;
	input [7:0] _ira

	begin
		if (/* ST: storeのとき*/ _opcode_first == 3'000 && _opcode_second == 2'b10) assign_data_in = _ira_out;
		else assign_data_in = 8'b0;
	end
endfunction
assign data_in = assign_data_in(opcode_first, opcode_second, ira);

wire [7:0] opcode, operand;
// fetchaでopcode, fetchbでoperandを入れる
assign opcode = ira; // TODO: 正しい？
assign operand = irb;

// alu
/* こ こ で ， a l u に 接 続 さ れ る 信 号 線 を 宣 言 */
wire alu_ena;
wire [1:0] alu_ctrl;

wire [7:0] alu_ain, alu_bin;
assign alu_ain = aout;
assign alu_bin = bout;

wire cflag, zflag; // output

wire [7:0] alu_out;

alu a(
	clk, rst,
	alu_ena, alu_ctrl,
	alu_ain, alu_bin,
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
		if (_opcode_first == 3'100) assign_alu_ctrl = {1'b1, _opcode_second};
		else assign_alu_ctrl = 3'b0;
	end
endfunction

assign {alu_ena, alu_ctrl} = assign_alu_ctrl(opcode_first, opcode_second);

endmodule
