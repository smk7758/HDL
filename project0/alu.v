module alu (
	input clk , rst , ena ,
	input [1:0] ctrl ,
	input [7:0] ain , bin ,
	output cflag , zflag ,
	output [7:0] sout
);

	wire cffd , zffd ;

	dffe cff (
	.d( cffd ),
	. clk ( clk ) ,
	. clrn (! rst ) ,
	. prn (1 ’ b1),
	. ena ( ena ) ,
	.q( cflag ));

	dffe zff (
	.d( zffd ),
	.clk ( clk ) ,
	.clrn (! rst ) ,
	.prn (1 ’ b1),
	.ena ( ena ) ,
	.q( zflag ));

	function [8:0] calculation ;
		input [1:0] _ctrl ;
		input [7:0] _ain ;
		input [7:0] _bin ;

		begin
			case ( _ctrl )
			// イ ン ク リ メ ン ト
			2 ’ b00 : calculation = {1 ’b0 , _ain } + 9 ’ b000000001 ;
			// デ ク リ メ ン ト
			2 ’ b01 : calculation = {1 ’b0 , _ain } - 9 ’ b000000001 ;
			// 加 算
			2 ’ b10 : calculation = {1 ’b0 , _ain } + {1 ’b0 , _bin };
			// 減 算
			2 ’ b11 : calculation = {1 ’b0 , _ain } - {1 ’b0 , _bin };
			endcase
		end
	endfunction
	assign {cffd , sout } = calculation (ctrl , ain , bin );
	assign zffd = ( cffd == 1 ’b0 && sout == 8 ’b0) ? 1 ’b1 : 1 ’b0;

endmodule
