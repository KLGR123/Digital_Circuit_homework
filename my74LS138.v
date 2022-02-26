module my74LS138(Y, A, G1, G2); //74LS138译码器的实现
	input [2:0]A;
	input G1, G2;
	output [7:0]Y;
	
	reg [7:0]Y;
	wire G;
	assign G = G1 & ~G2;
	
	always@(A or G1 or G2)
	begin
		if(G)
			case(A)
			3'd0: Y = 8'b11111110;
			3'd1: Y = 8'b11111101;
			3'd2: Y = 8'b11111011;
			3'd3: Y = 8'b11110111;
			3'd4: Y = 8'b11101111;
			3'd5: Y = 8'b11011111;
			3'd6: Y = 8'b10111111;
			3'd7: Y = 8'b01111111;
			endcase
		else
			Y = 8'b11111111;
	end
endmodule

//把38译码器的3个数据输入端当作全加器的3个输入端A B Ci
//38译码器的3个使能端全部置于正常状态保持工作
//8个输出对应于8个最小项
//故根据真值表将38译码器的8个输出与两个全加器所需的输出S Co相对应

module full_add(A,B,Ci,S,Co);
	input A, B, Ci;
	output S, Co;
	
	wire [7:0]Y;
	reg S, Co;
	wire G1, G2;
	
	my74LS138 u1(.Y(Y), .A({A, B, Ci}), .G1(1), .G2(0));
	
	always@(Y)
	begin
		case(Y)
		8'b11111110: S <= 0; 
		8'b11111110: Co <= 0; 
		
		8'b11111101: S <= 1; 
		8'b11111101: Co <= 0;
		
		8'b11111011: S <= 1; 
		8'b11111011: Co <= 0;
		
		8'b11110111: S <= 0;
		8'b11110111: Co = 1;
		
		8'b11101111: S = 1;
		8'b11101111: Co = 0;
		
		8'b11011111: S = 0;
		8'b11011111: Co = 1;
		
		8'b10111111: S = 0;	
		8'b10111111: Co = 1;
		
		8'b01111111: S = 1;	
		8'b01111111: Co = 1;
		endcase
	end
endmodule
