module countDown(clk, rst, hold, sw, change, led, led2, seg_led_1, seg_led_2); //实现任意数计时器
	input clk, rst;
	input	hold; //按键
	input change;
	input[3:0] sw; //拨码开关
	output reg[8:0] seg_led_1, seg_led_2;
	output led;
	output reg led2;
	reg clk_divided; //时钟信号沿标记
	reg hold_flag; //按键位
	reg back_to_zero_flag = 0; //归零标记
	reg [6:0]seg[9:0];
	reg [3:0]cnt_ge;//个位
	reg [3:0]cnt_shi;//十位
	reg [23:0]cnt;//counter	
	
	parameter PERIOD = 6000000; //1秒
	reg [5:0]N = 6'd24; //计时数
 
	initial //设置seg
	begin
		led2 = 1;
		seg[0] = 7'h3f;	   
		seg[1] = 7'h06;	   
		seg[2] = 7'h5b;	   
		seg[3] = 7'h4f;	   
		seg[4] = 7'h66;	   
		seg[5] = 7'h6d;	   
		seg[6] = 7'h7d;	   
		seg[7] = 7'h07;	   
		seg[8] = 7'h7f;	   
		seg[9] = 7'h6f;
	end

	always@ (posedge clk) //实现1Hz分频
	begin 
		if (!rst == 1) 
		begin
			cnt <= 0;
			clk_divided <= 0; 
			led2 <= 0;
		end
		else 
		begin
			led2 = 1;
			if (cnt < PERIOD-1)
				cnt <= cnt + 1;
			else 
			begin
				cnt <= 0;
				clk_divided <= ~clk_divided; 
			end
		end
	end
 
	always@ (*) //归零位设置
	begin
		if (!rst == 1)
			back_to_zero_flag <= 1;
		else if (((cnt_shi*10) + cnt_ge)== N)
			back_to_zero_flag <= 1;
		else
			back_to_zero_flag <= 0;
	end
 
	always@ (posedge hold) //按键位置
		hold_flag <= ~hold_flag;
 
	always@ (posedge clk_divided or posedge back_to_zero_flag) //实现进位、归零和自加
	begin
		if (back_to_zero_flag == 1) 
		begin
			cnt_ge <= 0;
			cnt_shi <= 0;
		end
		else if (cnt_ge == 9) 
		begin
			cnt_ge <= 0;
			cnt_shi <= cnt_shi + 1; 
		end
		else if (hold_flag == 1) 
		begin
			cnt_ge <= cnt_ge;
		end
		else begin
			cnt_ge <= cnt_ge + 1;
			end
	end
	
	always@ (sw) //挡位切换
	begin
		case(sw)                                              
			4'b0000:	N = 6'd5;                           
			4'b0001:	N = 6'd10;                         
			4'b0010:	N = 6'd20;
			4'b0011:	N = 6'd30;
			4'b0100:	N = 6'd35;
			4'b0101:	N = 6'd40;
			4'b0110: N = 6'd50;
			4'b0111:	N = 6'd60;
			default: N = 6'd24;
		endcase
	end

	always@ (cnt_ge) //个位数码管
	begin
		seg_led_1[8:0] <= {2'b00, seg[cnt_ge]}; 
	end
 
	always@ (cnt_shi) //十位数码管
	begin
		seg_led_2[8:0] <= {2'b00, seg[cnt_shi]};
	end
	
	breath_led u1 (                               
                       .clk (clk),
                       .rst (rst),
							  .w(hold_flag),
                       .led (led)
                       );
endmodule

module breath_led(clk,rst,w,led); //调用呼吸灯模块
 
	input clk;             //系统时钟输入
	input rst;             //复位输出
	input w;
	output led;            //led输出
 
	reg [24:0] cnt1;       //计数器1
	reg [24:0] cnt2;       //计数器2
	reg flag;              //呼吸灯变亮和变暗的标志位
 
	parameter   CNT_NUM = 1200;	//计数器的最大值 period = (1200^2)*2 = 12000000 = 1s
	//产生计数器cnt1
	always@(posedge clk or negedge rst) begin 
		if(!rst) begin
			cnt1<=13'd0;
			end 
                else begin
		     if(cnt1>=CNT_NUM-1) 
                        cnt1<=1'b0;
		     else 
                        cnt1<=cnt1+1'b1; 
                    end
		end
 
	//产生计数器cnt2
	always@(posedge clk or negedge rst) begin 	
		if(!rst) begin
			cnt2<=13'd0;
			flag<=1'b0;
			end 
                else begin
		     if(cnt1==CNT_NUM-1) begin              //当计数器1计满时计数器2开始计数加一或减一
			if(!flag) begin                     //当标志位为0时计数器2递增计数，表示呼吸灯效果由暗变亮
				if(cnt2>=CNT_NUM-1)         //计数器2计满时，表示亮度已最大，标志位变高，之后计数器2开始递减
                                    flag<=1'b1;
				else
                                    cnt2<=cnt2+1'b1;
			end else begin                     //当标志位为高时计数器2递减计数
				if(cnt2<=0)                //计数器2级到0，表示亮度已最小，标志位变低，之后计数器2开始递增
                                    flag<=1'b0;
				else 
                                    cnt2<=cnt2-1'b1;
			end
			end
                            else cnt2<=cnt2;              //计数器1在计数过程中计数器2保持不变
			end
			end
	
	//比较计数器1和计数器2的值产生自动调整占空比输出的信号，输出到led产生呼吸灯效果
	assign	led = (w == 0)?((cnt1<cnt2)?1'b0:1'b1):1'b0;
 
endmodule
