module stage (
	input wire clk , rst , run , halt ,
	output wire waits , fetcha , fetchb , execa , execb
);

	// 現 状 態 保 持 用 の レ ジ ス タ
	reg [4:0] state;
	
	// 状 態 名 の 定 義
	parameter waits_s = 5'b10000,
		fetcha_s = 5'b01000,
		fetchb_s = 5'b00100,
		execa_s = 5'b00010,
		execb_s = 5'b00001;
	
	// 状 態 生 成 回 路
	always @ ( negedge clk or posedge rst ) begin
		if ( rst ) begin
			state <= waits_s ;
		end else begin
			// 現 状 態 と 入 力 信 号 に 応 じ た 状 態 遷 移 の 定 義
			case ( state )
				waits_s : if ( run ) state <= fetcha_s ;
					else state <= waits_s ;
				fetcha_s : state <= fetchb_s ;
				fetchb_s : state <= execa_s ;
				execa_s : state <= execb_s ;
				execb_s : if ( halt ) state <= waits_s ;
					else state <= fetcha_s ;
			endcase
		end
	end
	
	// 現 状 態 を 出 力 信 号 に 接 続
	assign waits = state[4] ,
		fetcha = state[3] ,
		fetchb = state[2] ,
		execa = state[1] ,
		execb = state[0];
endmodule
