module fa8 (
a, // 入 力 信 号
b, // 入 力 信 号
cin , // キ ャ リ ー イ ン
s, // 出 力 信 号
cout // キ ャ リ ー ア ウ ト
);
parameter width = 8; // bit幅, 定数の宣言に使用．今回は，8-bit 全加算器なので「8」を設定．
input [width-1:0] a, b;
input cin ; // 0 ビット目の全加算器への入力
output [width-1:0] s;
output cout ; //  7 ビット目の全加算器からの出力
wire [width:0] c; // モ ジ ュ ー ル 内 部 で の c i n と c o u t の 結 線 用
// モジュール内で使用する信号線を定義．今回は，8 つの全加算器の cin と cout の結線に使用．
assign c [0] = cin ; // c i nをc [0] に 接 続
assign cout = c [8]; // c [8] を c o u t に 接 続
generate
// 繰り返し処理や分岐処理によるモジュールの実装．今回は，8つの全加算器の作成に使用．begin には固有の修飾子が必要であり，gen fa8 としている．
	genvar i;
	// f a を 8 つ 作 成
	for (i =0; i< width; i=i +1) begin : gen_fa8 // 適当な修飾子
		// モ ジ ュ ー ル の 宣 言 は 以 下 の よ う に 行 う
		// -> モ ジ ュ ー ル 名 イ ン ス タ ン ス 名( 引 数)
		// c[i] を c i n に 接 続 ， c [i +1] を c o u t に 接 続 す る こ と で ，
		// c[i +1] が 次 の f a の c i n に 接 続 さ れ る
		fa fa0 (a[i], b[i], c[i] , s[i] , c[i +1]);
	end
endgenerate
endmodule
