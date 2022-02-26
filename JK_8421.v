module JK  //JK触发器
(input clk
,input RST
,input J
,input K
,output reg Q
);
always@(negedge clk)
if(RST)
	Q<=0;
else
	case({J,K})
	2'b00:Q<=Q;
	2'b01:Q<=1'b0;
	2'b10:Q<=1'b1;
	2'b11:Q<=~Q;
	endcase
endmodule

module JK_8421 //例化和连接
(input clk
,input RST
,output[3:0]Q
);
//实现异步电路的特征方程
JK FFI(clk,RST,1,1,Q[0]);
JK FFII(Q[0],RST,~Q[3],~Q[3],Q[1]);
JK FFIII(Q[1],RST,1,1,Q[2]);
JK FFIV(Q[0],RST,Q[1]&Q[2],Q[3],Q[3]);
endmodule
