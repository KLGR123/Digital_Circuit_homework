`timescale 1 ns/ 1 ns
module countDown_tb;
reg clk;
wire[4:0]CD;
countDown u1 (.clk(clk),.CD(CD));
initial begin
clk=0;
end
always begin
#1 clk<=~clk;
end
endmodule
