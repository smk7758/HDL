module register (
	input clk , rst , cload ,
	input [1:0] asel , bsel , csel ,
	input [7:0] cin ,
	output [7:0] aout , bout
);

	// D F F E 制 御 用 の 配 線
	wire [7:0] rout0 , rout1 , rout2 , rout3 ;
	wire rena0 , rena1 , rena2 , rena3 ;
	// r e g i s t e r の 出 力 制 御 用 関 数
	function [7:0] select_out ;
		input [1:0] _sel ;
		begin
			if ( _sel == 2'b00 ) select_out = rout0 ;
			else if ( _sel == 2'b01 ) select_out = rout1 ;
			else if ( _sel == 2'b10 ) select_out = rout2 ;
			else if ( _sel == 2'b11 ) select_out = rout3 ;
			else select_out = 8'b0;
		end
	endfunction

	// D F F E の 制 御 用 関 数
	function [3:0] select_ena ;
		input _load ;
		input [1:0] _sel ;
		begin
			if ( _load == 1'b1) begin
				case ( _sel )
					2'b00 : select_ena = 4'b0001 ;
					2'b01 : select_ena = 4'b0010 ;
					2'b10 : select_ena = 4'b0100 ;
					2'b11 : select_ena = 4'b1000 ;
				endcase
			end else begin
				select_ena = 4'b0000 ;
			end
		end
	endfunction

	// 8 - b i t の D F F E を 4 つ 作 成
	generate
		genvar i;
		for (i = 0; i < 8; i = i+1) begin : gen
			dffe r0(
				.d( cin[i]),
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
		end
	endgenerate

	// 配 線
	assign aout = select_out ( asel ); // a o u t の 接 続
	assign bout = select_out ( bsel ); // b o u t の 接 続
	assign {rena3 , rena2 , rena1 , rena0 } = select_ena (cload , csel );
endmodule
