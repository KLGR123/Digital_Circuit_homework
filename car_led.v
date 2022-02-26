
//设计一个汽车尾灯自动控制系统
//要求：根据汽车行驶状态自动控制汽车尾灯
//直行：尾灯不亮
//右转：右侧尾灯亮而且按秒闪烁，左侧尾灯不亮
//左转：左侧尾灯亮而且按秒闪烁，右侧尾灯不亮
//临时停车或故障：两侧尾灯同时快速闪烁

//注：用三色LED代表左右汽车尾灯
//用拨码开关控制汽车行驶状态
//还可以考虑用七段数码管和单色LED显示汽车状态

//0000 直行
//0001 左转
//0010 右转
//0011 停车或故障

module car_led(clk, rst, sw, left, right);
	input clk, rst; //时钟和启动键
	input [3:0]sw; //状态输入
	output reg left; //左转向灯
	output reg right; //右转向灯
	
	parameter PERIOD = 6000000; //1秒
	reg [23:0]cnt;//counter
	reg clk_divided; //分频时钟
	
	initial
	begin
		left = 0;
		right = 0;
		cnt <= 0;
	end
	
	always@ (posedge clk or negedge rst) //实现1Hz分频
	begin 
		if (!rst) 
		begin
			cnt <= 0;
			clk_divided <= 0;
		end
		else 
		begin
			if (cnt < PERIOD-1)
				cnt <= cnt + 1;
			else 
			begin
				cnt <= 0;
				clk_divided <= ~clk_divided; 
			end
		end
	end
	
	always@(posedge clk)
	begin
	  if(sw == 4'b0000) //直行
			case(clk_divided)
				 1'd0: {left, right} <= 2'b11;
				 1'd1: {left, right} <= 2'b11;
			endcase
	  else if(sw == 4'b0001) //左转
			case(clk_divided)
				 1'd0: {left, right} <= 2'b01;
				 1'd1: {left, right} <= 2'b11;
			endcase
	  else if(sw == 4'b0010) //右转
			case(clk_divided)
				 1'd0: {left, right} <= 2'b10;
				 1'd1: {left, right} <= 2'b11;
			endcase
	  else if(sw == 4'b0011) //倒车或紧急
			case(clk_divided)
				 1'd0: {left, right} <= 2'b10;
				 1'd1: {left, right} <= 2'b01;
			endcase
	  else //一般情况
			case(clk_divided)
				 1'd0: {left, right} <= 2'b00;
				 1'd1: {left, right} <= 2'b00;
			endcase
	end

endmodule

