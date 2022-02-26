`timescale 1 ns/ 1 ns 
module JK_8421_tb;
reg clk=0,RST=1;
wire[3:0]Q; //监测输出
JK_8421 UUT(clk,RST,Q);
initial#1 RST=0;
always#1 clk<=~clk;
endmodule
