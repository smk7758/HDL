// 全加算回路
/*
各1-bitのa, b, cinを入力として，
各1-bitのs, coutを出力する．
*/
//module fa(a, b, cin , s, cout );
//input a, b, cin;
//output s, cout;
module fa(
input a, b, cin ,
output s, cout
);
assign s = a ^ b ^ cin;
assign cout = (a & b) | (b & cin ) | ( cin & a);
endmodule
