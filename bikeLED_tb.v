`timescale 1ns/1ns

`define clk_period 20000

module bikeLED_tb;

 reg rst;
 reg clk;
 reg BTN7;
 reg BTN6;
 reg BTN5;
 reg BTN3;
 reg _RST;
 
 wire [7:0] row,R_col,duan,DS,G_col;

 bikeLED u1(
 .clk(clk),.rst(rst),.BTN7(BTN7),.BTN6(BTN6),.BTN5(BTN5),.BTN3(BTN3),.row(row),.R_col(R_col),.duan(duan),.DS(DS),._RST(_RST),.G_col(G_col)
 );
 
 initial 
 begin
 rst=0;
 _RST=1;
 clk = 1'b1; //时钟初值为1
 end
 
 always#(`clk_period*50) clk = ~clk; //半个定义的时钟周期以后，clk翻转
 
 initial //产生激励信号 只有rst_n
 begin
 
	BTN3 = 0;BTN7=0;BTN5=0;BTN6=0;
	# (`clk_period*500000);
	BTN3 = 0;BTN7=1;BTN5=0;BTN6=0;
	# (`clk_period*500);
	BTN3 = 0;BTN7=0;BTN5=0;BTN6=0;
	# (`clk_period*500000);
	
	
//	BTN3 = 0;BTN7=0;BTN5=1;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 0;BTN7=0;BTN5=1;BTN6=1;
//	# (`clk_period*500000);
//	BTN3 = 0;BTN7=1;BTN5=0;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 0;BTN7=1;BTN5=0;BTN6=1;
//	# (`clk_period*500000);
//	BTN3 = 0;BTN7=1;BTN5=1;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 0;BTN7=1;BTN5=1;BTN6=1;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=0;BTN5=0;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=0;BTN5=0;BTN6=1;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=0;BTN5=1;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=0;BTN5=1;BTN6=1;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=1;BTN5=0;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=1;BTN5=0;BTN6=1;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=1;BTN5=1;BTN6=0;
//	# (`clk_period*500000);
//	BTN3 = 1;BTN7=1;BTN5=1;BTN6=1;
//	# (`clk_period*500000);
	$stop; //停止
	end

endmodule
