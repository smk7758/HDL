module register (
	input clk , rst, cload,
	input [2:0] asel, bsel, csel,
	input [7:0] cin,
	output [7:0] aout, bout
);

	// D F F E 制 御 用 の 配 線
	wire [7:0] rout0 , rout1 , rout2 , rout3, rout4 , rout5 , rout6 , rout7	;
	wire rena0 , rena1 , rena2 , rena3,rena4 , rena5 , rena6 , rena7	;
	
	// r e g i s t e r の 出 力 制 御 用 関 数
	function [7:0] select_out;
		input [2:0] _sel;
		begin
			if ( _sel == 3'b000 ) select_out = rout0 ;
			else if ( _sel == 3'b001 ) select_out = rout1 ;
			else if ( _sel == 3'b010 ) select_out = rout2 ;
			else if ( _sel == 3'b011 ) select_out = rout3 ;
			else if ( _sel == 3'b100 ) select_out = rout4 ;
			else if ( _sel == 3'b101 ) select_out = rout5 ;
			else if ( _sel == 3'b110 ) select_out = rout6 ;
			else if ( _sel == 3'b111 ) select_out = rout7 ;
			else select_out = 8'b0;
		end
	endfunction

	// D F F E の 制 御 用 関 数
	function [2:0] select_ena;
		input _load;
		input [2:0] _sel;
		begin
			if ( _load == 1'b1) begin
				case ( _sel )
					3'b000 : select_ena = 8'b00000001 ;
					3'b001 : select_ena = 8'b00000010 ;
					3'b010 : select_ena = 8'b00000100 ;
					3'b011 : select_ena = 8'b00001000 ;
					3'b100 : select_ena = 8'b00010000 ;
					3'b101 : select_ena = 8'b00100000 ;
					3'b110 : select_ena = 8'b01000000 ;
					3'b111 : select_ena = 8'b10000000 ;
				endcase
			end else begin
				select_ena = 8'b0 ;
			end
		end
	endfunction

	// 8 - b i t の D F F E を 4 つ 作 成
	generate
		genvar i;
		for (i = 0; i < 8; i = i+1) begin : gen
			dffe r0(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst ),
				.prn(1'b1) ,
				.ena(rena0),
				.q(rout0[i])
			);

			dffe r1(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst),
				.prn(1'b1),
				.ena(rena1),
				.q(rout1[i])
			);

			dffe r2(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst),
				.prn(1'b1),
				.ena(rena2),
				.q(rout2[i])
			);

			dffe r3(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst),
				.prn(1'b1),
				.ena(rena3),
				.q(rout3[i])
			);
			
			dffe r4(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst ),
				.prn(1'b1) ,
				.ena(rena4),
				.q(rout4[i])
			);

			dffe r5(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst),
				.prn(1'b1),
				.ena(rena5),
				.q(rout5[i])
			);

			dffe r6(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst),
				.prn(1'b1),
				.ena(rena6),
				.q(rout6[i])
			);

			dffe r7(
				.d(cin[i]),
				.clk(clk),
				.clrn(!rst),
				.prn(1'b1),
				.ena(rena7),
				.q(rout7[i])
			);
		end
	endgenerate

	// 配 線
	assign aout = select_out ( asel ); // a o u t の 接 続
	assign bout = select_out ( bsel ); // b o u t の 接 続
	assign {rena3 , rena2 , rena1 , rena0 } = select_ena(cload , csel);
endmodule
