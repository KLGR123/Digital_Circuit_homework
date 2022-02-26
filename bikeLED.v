module bikeLED(clk,rst,BTN7,BTN6,BTN5,BTN3,row,R_col,duan,DS,_RST,G_col);
input clk,rst,BTN7,BTN6,BTN5,BTN3,_RST; //rst赋BTN2，BTN3正常行驶，BTN7左转，BTN6右转，BTN5右转，BTN6刹车
output row,R_col,duan,DS,G_col;
reg [7:0] row,R_col,G_col; //点阵的行、红灯列和绿灯列显示
reg [2:0] cnt1; //计数器1,用于点阵的行、列扫描
reg [1:0] cnt3; //计数器3,用于分位显示数码管
reg [2:0] sc; //state_current表示现态
reg [2:0] sn; //state_next表示次态
reg clk_1hz; //1HZ(1s)时钟信号
reg clk_scan; //数码管扫描时钟
reg [3:0] ud; //数码管个位数(unit's digit)
reg [3:0] td; //数码管十位数(ten's digit)
reg [3:0] ud_1;
reg [3:0] td_1;
reg [3:0] ud_2;
reg [3:0] td_2;
reg [3:0] ud_3;
reg [3:0] td_3;
reg [7:0] duan; //数码管段码
reg [7:0] DS; //数码管位码
integer count; //1HZ时钟计数器
integer count2; //扫描时钟计数器
parameter s0=3'b000;//全关
parameter s1=3'b001; //行驶状态
parameter s2=3'b010; //左转状态
parameter s3=3'b011; //右转状态
parameter s4=3'b100; //刹车状态
wire key_pulse1; //消抖后的BTN3，前进
wire key_pulse2; //消抖后的BTN7，左转
wire key_pulse3; //消抖后的BTN5，右转
wire key_pulse4; //消抖后的BTN6，刹车
reg [7:0]left_1=8'b0000_1000;//移动数码管显示，便于表示
reg [7:0]left_2=8'b0000_1100;
reg [7:0]left_3=8'b1111_1110;
reg [7:0]left_4=8'b1111_1111;
reg [7:0]left_5=8'b1111_1111;
reg [7:0]left_6=8'b1111_1110;
reg [7:0]left_7=8'b0000_1100;
reg [7:0]left_8=8'b0000_1000;

reg [7:0]right_1=8'b0001_0000;
reg [7:0]right_2=8'b0011_0000;
reg [7:0]right_3=8'b0111_1111;
reg [7:0]right_4=8'b1111_1111;
reg [7:0]right_5=8'b1111_1111;
reg [7:0]right_6=8'b0111_1111;
reg [7:0]right_7=8'b0011_0000;
reg [7:0]right_8=8'b0001_0000;
debounce1  u1 (                    //例化消抖模块1,为BTN3按键消抖        
                       .clk (clk),
                       .rst (rst),
                       .key (BTN3),
                       .key_pulse1 (key_pulse1)
                             ) ;
debounce2  u2 (                    //例化消抖模块2,为BTN7按键消抖           
                       .clk (clk),
                       .rst (rst),
                       .key (BTN7),
                       .key_pulse2 (key_pulse2)
                             ) ;
debounce3  u3 (                    //例化消抖模块3,为BTN5按键消抖           
                       .clk (clk),
                       .rst (rst),
                       .key (BTN5),
                       .key_pulse3 (key_pulse3)
                             ) ;
debounce4  u4 (                    //例化消抖模块4,为BTN6按键消抖           
                       .clk (clk),
                       .rst (rst),
                       .key (BTN6),
                       .key_pulse4 (key_pulse4)
                             ) ;

reg[7:0] cross[7:0]; 
wire x;

breath_led l1(.clk(clk), .rst(sc == s1), .led(x));

always@(x)
begin
	cross[0][3] <= x;
	cross[0][4] <= x;
	cross[1][3] <= x;
	cross[1][4] <= x;
	cross[2][3] <= x;
	cross[2][4] <= x;
	cross[3][0] <= x;
	cross[3][1] <= x;
	cross[3][2] <= x;
	cross[3][3] <= x;
	cross[3][4] <= x;
	cross[3][5] <= x;
	cross[3][6] <= x;
	cross[3][7] <= x;
	cross[4][0] <= x;
	cross[4][1] <= x;
	cross[4][2] <= x;
	cross[4][3] <= x;
	cross[4][4] <= x;
	cross[4][5] <= x;
	cross[4][6] <= x;
	cross[4][7] <= x;
	cross[5][3] <= x;
	cross[5][4] <= x;
	cross[6][3] <= x;
	cross[6][4] <= x;
	cross[7][3] <= x;
	cross[7][4] <= x;
end

initial //初始设定数码管显示90
begin
     ud=4'b1001;
     td=4'b1001;
	  ud_1=4'b0000;
	  td_1=4'b0001;
	  ud_2=4'b0000;
     td_2=4'b0001;
	  ud_3=4'b1001;
	  td_3=4'b0000;
	  
end  
always@(posedge clk or posedge rst) //计数器用于点阵显示
begin
     if(rst)
         cnt1<= 3'b0;
     else
         cnt1<=cnt1+1'b1;
end

always@(posedge clk) //1HZ时钟进程
begin
     if(count==500000) 
         begin
         clk_1hz=~clk_1hz;
         count<=0;
         end
     else
         count<=count+1'b1;
end
always@(posedge clk_1hz ) //倒计时器功能进程 
begin
     
      if(_RST==1)
        begin
			   
            if(ud==4'b0000&&td==4'b000)
               begin
                 ud<=4'b0000;
                 td<=4'b000;
               end
          else if(ud==4'b0000)
               begin
                 ud<=4'b1001;
                 td<=td-1;
               end
           else 
                 ud<=ud-1;
        end    
     
		 else 
		     begin
             ud<=ud;
             td<=td;
           end

end



always@(posedge clk_1hz ) //倒计时器功能进程 
begin
     if(_RST==1&&sc!=s2)
	        begin
                 ud_1<=4'b0000;
                 td_1<=4'b0001;
               end
      else if(sc==s2)
        begin
			   
            if(ud_1==4'b0000&&td_1==4'b0000)
               begin
                 ud_1<=4'b0000;
                 td_1<=4'b0001;
               end
          else if(ud_1==4'b0000)
               begin
                 ud_1<=4'b1001;
                 td_1<=td_1-1;
               end
           else 
                 ud_1<=ud_1-1;
        end    
     
		 else 
		     begin
             ud_1<=ud_1;
             td_1<=td_1;
           end

end


always@(posedge clk_1hz ) //倒计时器功能进程 
begin
     if(_RST==1&&sc!=s3)
	        begin
                 ud_2<=4'b0000;
                 td_2<=4'b0001;
               end
      else if(sc==s3)
        begin
			   
            if(ud_2==4'b0000&&td_2==4'b0000)
               begin
                 ud_2<=4'b0000;
                 td_2<=4'b0001;
               end
          else if(ud_2==4'b0000)
               begin
                 ud_2<=4'b1001;
                 td_2<=td_2-1;
               end
           else 
                 ud_2<=ud_2-1;
        end    
     
		 else 
		     begin
             ud_2<=ud_2;
             td_2<=td_2;
           end

end
always@(posedge clk_1hz ) //倒计时器功能进程 
begin
     if(_RST==1&&sc!=s4)
	        begin
                 ud_3<=4'b0101;
                 td_3<=4'b0000;
               end
      else if(sc==s4)
        begin
			   
            if(ud_3==4'b0000&&td_3==4'b0000)
               begin
                 ud_3<=4'b0101;
                 td_3<=4'b0000;
               end
          else if(ud_3==4'b0000)
               begin
                 ud_3<=4'b1001;
                 td_3<=td_3-1;
               end
           else 
                 ud_3<=ud_3-1;
        end    
     
		 else 
		     begin
             ud_3<=ud_3;
             td_3<=td_3;
           end

end
always@(posedge clk) //数码管扫描时钟产生进程
begin
     if(count2==2000)
         begin
         count2<=0;
         clk_scan<=~clk_scan;
         end
     else
         count2<=count2+1;
end

always @(posedge clk_scan)
begin 
     if(cnt3==2'b11)
         cnt3<=2'b00;
     else
         cnt3<=cnt3+1;
end

always @(ud or td or cnt3)
begin
     if(sc==s0)
     DS<=8'b1111_1111;
     
     else if(cnt3==2'b01)
     begin
         DS<=8'b1111_1101; 
         case(td) //倒计时器十位数显示
             4'b0000:begin duan=8'b0011_1111;end
             4'b0001:begin duan=8'b0000_0110;end
             4'b0010:begin duan=8'b0101_1011;end
             4'b0011:begin duan=8'b0100_1111;end
             4'b0100:begin duan=8'b0110_0110;end
             4'b0101:begin duan=8'b0110_1101;end
             4'b0110:begin duan=8'b0111_1101;end
             4'b0111:begin duan=8'b0000_0111;end
             4'b1000:begin duan=8'b0111_1111;end
             4'b1001:begin duan=8'b0110_1111;end
         endcase
     end
     else if(cnt3==2'b10)
     begin
         DS<=8'b1111_1110; 
         case(ud) //倒计时器个位数显示
             4'b0000:begin duan=8'b0011_1111;end
             4'b0001:begin duan=8'b0000_0110;end
             4'b0010:begin duan=8'b0101_1011;end
             4'b0011:begin duan=8'b0100_1111;end
             4'b0100:begin duan=8'b0110_0110;end
             4'b0101:begin duan=8'b0110_1101;end
             4'b0110:begin duan=8'b0111_1101;end
             4'b0111:begin duan=8'b0000_0111;end
             4'b1000:begin duan=8'b0111_1111;end
             4'b1001:begin duan=8'b0110_1111;end
         endcase
     end
     else if(cnt3==2'b11)
     DS<=8'b1111_1111;
end

always @(posedge clk or posedge rst) 
begin
     if(rst)
         begin
         sc<=s0;
         end
     else
         begin
         sc<=sn; //状态转移设定,不按下复位键时采用非阻塞赋值将次态赋给现态
         end
end
always@(_RST or key_pulse1 or key_pulse2 or key_pulse3 or key_pulse4) //采用状态机描述四个个状态的转移
begin
    case(sc) //对每一个状态可能的次态进行列举,本质上就是状态转移图的代码化
	  s0://全关
	     begin
	         if(_RST==1)
	           sn=s1;
	          else 
	           sn=s0;
	      end
     s1://行驶
         begin
             if(key_pulse1)//关闭
                 sn=s1;
             else if(key_pulse2)//左转按键
                 sn=s2;
             else if(key_pulse3)//右转按键
                 sn=s3;
             else if(ud==4'b0000&&td==4'b0000)
                 sn=s1;
				 else if(key_pulse4)
				     sn=s4;
				 else if (!_RST)
					  sn=s0;
             else
                 sn=s1;
         end
     s2://左转状态
         begin
             if(key_pulse1)//关闭
                 sn=s1;
             else if(key_pulse2)//左转按键
                 sn=s2;
             else if(key_pulse3)//右转按键
                 sn=s3;
             else if(ud_1==4'b0000&&td_1==4'b0000)//倒计时结束回归正常行驶
                 sn=s1;
				 else if(key_pulse4)
				     sn=s4;
				 else if (!_RST)
					  sn=s0;
             else
                 sn=s2;
         end
     s3://右转状态
         begin
             if(key_pulse1)//关闭
                 sn=s1;
             else if(key_pulse2)
                 sn=s2;
             else if(key_pulse3)
                 sn=s3;
             else if(ud_2==4'b0000&&td_2==4'b0000)
                 sn=s1;
				 else if(key_pulse4)
				     sn=s4;
				 else if (!_RST)
					  sn=s0;
             else
                 sn=s3;
         end
     s4://刹车
         begin
             if(key_pulse1)
                 sn=s1;
             else if(key_pulse2)
                 sn=s2;
             else if(key_pulse3)
                 sn=s3;
             else if(ud_3==4'b0000&&td_3==4'b0000)
                 sn=s1;
				 else if(key_pulse4)
				     sn=s4;
				 else if (!_RST)
					  sn=s0;
             else
                 sn=s4;
         end
     
     endcase
end
always@(posedge clk_1hz )//移位寄存器以显示动态
begin
	if(sc==s2)
	begin
left_1<={left_1[0],left_1[7:1]};
left_2<={left_2[0],left_2[7:1]};
left_3<={left_3[0],left_3[7:1]};
left_4<={left_4[0],left_4[7:1]};
left_5<={left_5[0],left_5[7:1]};
left_6<={left_6[0],left_6[7:1]};
left_7<={left_7[0],left_7[7:1]};
left_8<={left_8[0],left_8[7:1]};
   end
   if(sc==s3)
	begin
right_1<={right_1[6:0],right_1[7]};
right_2<={right_2[6:0],right_2[7]};
right_3<={right_3[6:0],right_3[7]};
right_4<={right_4[6:0],right_4[7]};
right_5<={right_5[6:0],right_5[7]};
right_6<={right_6[6:0],right_6[7]};
right_7<={right_7[6:0],right_7[7]};
right_8<={right_8[6:0],right_8[7]};

   end
   
end
always@(posedge clk) //状态机内容的显示
begin
     case(sc)
	      s0://全关
			   begin
				R_col=8'b0000_0000;
				G_col=8'b0000_0000;
				end
         
         s1: //行驶
             begin
                 G_col=8'b0000_0000;
                 case(cnt1)
                     3'b000:begin row<=8'b11111110;R_col<=cross[0]; end
                     3'b001:begin row<=8'b11111101;R_col<=cross[1]; end
                     3'b010:begin row<=8'b11111011;R_col<=cross[2]; end 
                     3'b011:begin row<=8'b11110111;R_col<=cross[3]; end
                     3'b100:begin row<=8'b11101111;R_col<=cross[4]; end
                     3'b101:begin row<=8'b11011111;R_col<=cross[5]; end
                     3'b110:begin row<=8'b10111111;R_col<=cross[6]; end
                     3'b111:begin row<=8'b01111111;R_col<=cross[7]; end
                 endcase    
             end
         s2: //左转，动态显示
             begin
                 R_col=8'b0000_0000;
                 case(cnt1)
                     3'b000:begin row<=8'b11111110;G_col=left_1;end
                     3'b001:begin row<=8'b11111101;G_col=left_2;end
                     3'b010:begin row<=8'b11111011;G_col=left_3;end
                     3'b011:begin row<=8'b11110111;G_col=left_4;end
                     3'b100:begin row<=8'b11101111;G_col=left_5;end
                     3'b101:begin row<=8'b11011111;G_col=left_6;end
                     3'b110:begin row<=8'b10111111;G_col=left_7;end
                     3'b111:begin row<=8'b01111111;G_col=left_8;end
							
                 endcase
             end
         s3: //右转，动态显示
             begin
                 R_col=8'b0000_0000;
                 case(cnt1)
                     3'b000:begin row<=8'b11111110;G_col=right_1;end
                     3'b001:begin row<=8'b11111101;G_col=right_2;end
                     3'b010:begin row<=8'b11111011;G_col=right_3;end
                     3'b011:begin row<=8'b11110111;G_col=right_4;end
                     3'b100:begin row<=8'b11101111;G_col=right_5;end
                     3'b101:begin row<=8'b11011111;G_col=right_6;end
                     3'b110:begin row<=8'b10111111;G_col=right_7;end
                     3'b111:begin row<=8'b01111111;G_col=right_8;end
                 endcase
             end
         s4: //刹车
             begin
                 G_col<=8'b00000000;
                 case(cnt1)
                     3'b000:begin row<=8'b11111110;R_col<=8'b00000000; end
                     3'b001:begin row<=8'b11111101;R_col<=8'b01000010; end
                     3'b010:begin row<=8'b11111011;R_col<=8'b00100100; end 
                     3'b011:begin row<=8'b11110111;R_col<=8'b00011000; end
                     3'b100:begin row<=8'b11101111;R_col<=8'b00011000; end
                     3'b101:begin row<=8'b11011111;R_col<=8'b00100100; end
                     3'b110:begin row<=8'b10111111;R_col<=8'b01000010; end
                     3'b111:begin row<=8'b01111111;R_col<=8'b00000000; end
                 endcase
             end
         
         
     endcase
end
endmodule


module debounce1(clk,rst,key,key_pulse1); //消抖模块1
parameter N  =  1; //要消除的按键的数量
input clk;
input rst;
input [N-1:0] key; //输入的按键                    
output [N-1:0] key_pulse1; //按键动作产生的脉冲    
reg [N-1:0] key_rst_pre; //定义一个寄存器型变量存储上一个触发时的按键值
reg [N-1:0] key_rst; //定义一个寄存器变量储存储当前时刻触发的按键值
wire [N-1:0] key_edge; //检测到按键由高到低变化是产生一个高脉冲
//利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
always @(posedge clk or posedge rst)
     begin
         if(rst) 
         begin
             key_rst <= {N{1'b1}}; //初始化时给key_rst赋值全为1，{}中表示N个1
             key_rst_pre <= {N{1'b1}};
         end
         else 
         begin
             key_rst <= key; //第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
             key_rst_pre <= key_rst; //非阻塞赋值。相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的值
         end    
     end
assign key_edge = (~key_rst_pre) & key_rst; //脉冲边沿检测。当key检测到上升沿时，key_edge产生一个时钟周期的高电平
reg[13:0] cnt; //产生延时所用的计数器，系统时钟1MHz，要延时15ms左右时间，至少需要14位计数器     
//产生20ms延时，当检测到key_edge有效是计数器清零开始计数
always@(posedge clk or posedge rst)
begin
     if(rst)
         cnt <= 14'h0;
     else if(key_edge)
         cnt <= 14'h0;
     else
         cnt <= cnt + 1'h1;
end  
reg [N-1:0] key_sec_pre; //延时后检测电平寄存器变量
reg [N-1:0] key_sec; //延时后检测key，如果按键状态变高产生一个时钟的高脉冲。如果按键状态是低的话说明按键无效
always@(posedge clk or posedge rst)
begin
     if(rst) 
         key_sec <= {N{1'b1}};                
     else if (cnt==14'h3a98)
         key_sec <= key;  
end
always@(posedge clk or posedge rst)
begin
     if(rst)
         key_sec_pre <= {N{1'b1}};
     else                   
         key_sec_pre <= key_sec;             
end      
assign key_pulse1 = (~key_sec_pre) & key_sec;      
endmodule


module debounce2(clk,rst,key,key_pulse2); //消抖模块2
parameter N  =  1; //要消除的按键的数量
input clk;
input rst;
input [N-1:0] key; //输入的按键                    
output [N-1:0] key_pulse2; //按键动作产生的脉冲    
reg [N-1:0] key_rst_pre; //定义一个寄存器型变量存储上一个触发时的按键值
reg [N-1:0] key_rst; //定义一个寄存器变量储存储当前时刻触发的按键值
wire [N-1:0] key_edge; //检测到按键由高到低变化是产生一个高脉冲
//利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
always @(posedge clk or posedge rst)
begin
     if(rst) 
         begin
             key_rst <= {N{1'b1}}; //初始化时给key_rst赋值全为1，{}中表示N个1
             key_rst_pre <= {N{1'b1}};
         end
     else 
         begin
             key_rst <= key; //第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
             key_rst_pre <= key_rst; //非阻塞赋值。相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的值
         end    
     end
assign key_edge = (~key_rst_pre) & key_rst; //脉冲边沿检测。当key检测到上升沿时，key_edge产生一个时钟周期的高电平
reg[13:0] cnt; //产生延时所用的计数器，系统时钟1MHz，要延时15ms左右时间，至少需要14位计数器     
//产生20ms延时，当检测到key_edge有效是计数器清零开始计数
always@(posedge clk or posedge rst)
begin
     if(rst)
         cnt <= 14'h0;
     else if(key_edge)
         cnt <= 14'h0;
     else
          cnt <= cnt + 1'h1;
end  
reg [N-1:0] key_sec_pre; //延时后检测电平寄存器变量
reg [N-1:0] key_sec; //延时后检测key，如果按键状态变高产生一个时钟的高脉冲。如果按键状态是低的话说明按键无效
always@(posedge clk or posedge rst)
begin
     if(rst) 
         key_sec <= {N{1'b1}};                
     else if (cnt==14'h3a98)
         key_sec <= key;  
end
always@(posedge clk or posedge rst)
begin
     if(rst)
         key_sec_pre <= {N{1'b1}};
     else                   
         key_sec_pre <= key_sec;             
end      
assign key_pulse2 = (~key_sec_pre) & key_sec;      
endmodule


module debounce3(clk,rst,key,key_pulse3); //消抖模块1
parameter N  =  1; //要消除的按键的数量
input clk;
input rst;
input [N-1:0] key; //输入的按键                    
output [N-1:0] key_pulse3; //按键动作产生的脉冲    
reg [N-1:0] key_rst_pre; //定义一个寄存器型变量存储上一个触发时的按键值
reg [N-1:0] key_rst; //定义一个寄存器变量储存储当前时刻触发的按键值
wire [N-1:0] key_edge; //检测到按键由高到低变化是产生一个高脉冲
//利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
always @(posedge clk or posedge rst)
begin
     if(rst) 
         begin
             key_rst <= {N{1'b1}}; //初始化时给key_rst赋值全为1，{}中表示N个1
             key_rst_pre <= {N{1'b1}};
         end
     else
         begin
             key_rst <= key; //第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
             key_rst_pre <= key_rst; //非阻塞赋值。相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的值
         end    
     end
assign key_edge = (~key_rst_pre) & key_rst; //脉冲边沿检测。当key检测到上升沿时，key_edge产生一个时钟周期的高电平
reg[13:0] cnt; //产生延时所用的计数器，系统时钟1MHz，要延时15ms左右时间，至少需要14位计数器     
//产生20ms延时，当检测到key_edge有效是计数器清零开始计数
always@(posedge clk or posedge rst)
begin
     if(rst)
         cnt <= 14'h0;
     else if(key_edge)
         cnt <= 14'h0;
     else
         cnt <= cnt + 1'h1;
end  
reg [N-1:0] key_sec_pre; //延时后检测电平寄存器变量
reg [N-1:0] key_sec; //延时后检测key，如果按键状态变高产生一个时钟的高脉冲。如果按键状态是低的话说明按键无效
always@(posedge clk or posedge rst)
begin
     if(rst) 
         key_sec <= {N{1'b1}};                
     else if (cnt==14'h3a98)
         key_sec <= key;  
end
always@(posedge clk or posedge rst)
begin
     if(rst)
          key_sec_pre <= {N{1'b1}};
     else                   
         key_sec_pre <= key_sec;             
end      
assign key_pulse3 = (~key_sec_pre) & key_sec;      
endmodule


module debounce4(clk,rst,key,key_pulse4); //消抖模块1
parameter N  =  1; //要消除的按键的数量
input clk;
input rst;
input [N-1:0] key; //输入的按键                    
output [N-1:0] key_pulse4; //按键动作产生的脉冲    
reg [N-1:0] key_rst_pre; //定义一个寄存器型变量存储上一个触发时的按键值
reg [N-1:0] key_rst; //定义一个寄存器变量储存储当前时刻触发的按键值
wire [N-1:0] key_edge; //检测到按键由高到低变化是产生一个高脉冲
//利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
always @(posedge clk or posedge rst)
begin
     if(rst) 
         begin
             key_rst <= {N{1'b1}}; //初始化时给key_rst赋值全为1，{}中表示N个1
             key_rst_pre <= {N{1'b1}};
         end
     else
         begin
             key_rst <= key; //第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
             key_rst_pre <= key_rst; //非阻塞赋值。相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的值
         end    
end
assign key_edge = (~key_rst_pre) & key_rst; //脉冲边沿检测。当key检测到上升沿时，key_edge产生一个时钟周期的高电平
reg[13:0] cnt; //产生延时所用的计数器，系统时钟1MHz，要延时15ms左右时间，至少需要14位计数器     
//产生20ms延时，当检测到key_edge有效是计数器清零开始计数
always@(posedge clk or posedge rst)
begin
     if(rst)
          cnt <= 14'h0;
     else if(key_edge)
         cnt <= 14'h0;
     else
         cnt <= cnt + 1'h1;
end  
reg [N-1:0] key_sec_pre; //延时后检测电平寄存器变量
reg [N-1:0] key_sec; //延时后检测key，如果按键状态变高产生一个时钟的高脉冲。如果按键状态是低的话说明按键无效
always@(posedge clk or posedge rst)
begin
     if(rst) 
         key_sec <= {N{1'b1}};                
     else if (cnt==14'h3a98)
         key_sec <= key;  
end
always@(posedge clk or posedge rst)
begin
     if(rst)
         key_sec_pre <= {N{1'b1}};
     else                   
         key_sec_pre <= key_sec;             
end      
assign key_pulse4 = (~key_sec_pre) & key_sec;      
endmodule

module breath_led(clk,rst,led);
 
	input clk;             //系统时钟输入
	input rst;             //复位输出
	output led;            //led输出
 
	reg [24:0] cnt1;       //计数器1
	reg [24:0] cnt2;       //计数器2
	reg flag;              //呼吸灯变亮和变暗的标志位
 
	parameter   CNT_NUM = 1224;	//计数器的最大值 period = (1224^2)*2 / 1M = 3s  
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
	assign	led = (cnt1<cnt2)?1'b0:1'b1;

//	assign	led[7][7] = 0;
endmodule