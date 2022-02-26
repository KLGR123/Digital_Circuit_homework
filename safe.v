module debounce (clk,rst,key,key_pulse); //按键防抖模块
 
	input clk;
	input rst;
	input key;
	
	output key_pulse;//按键动作产生的脉冲
 
	reg key_1st_pre;//存储上一时刻触发的按键值
	reg key_1st;//当前时刻触发的按键值
 
	wire key_edge;//检测到按键由高到低变化时产生一个高脉冲
 
	always@(posedge clk or negedge rst)begin
		if(!rst)
		begin
			key_1st_pre <= 1'b1;//初始化为1
			key_1st <= 1'b1;
		end
		else begin
			key_1st <= key;//key_1st 当前时刻的key值
			key_1st_pre <= key_1st;//key_1st_pre存储的是前一个时钟的key的值
		end
	end
 
	assign key_edge = key_1st_pre & (~key_1st);
		//脉冲边沿检测（当key检测到下降沿时,key_edge产生一个时钟周期(1/12us)的高电平）
 
	reg [17:0] cnt;//产生延时所用的计数器.系统时钟12MHz,一个时钟周期1/12us,要延时20ms左右,即18位计数器（存储位数足够）
 
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
			cnt <= 18'h0;
		else if(key_edge)//检测到key_edge 计数器清零
			cnt <= 18'h0;
		else//开始计数
			cnt <= cnt + 1'h1;
	end
 
	reg key_2nd_pre;//延时后检测电平寄存器变量
	reg key_2nd;
 
	always@(posedge clk or negedge rst)begin
		if(!rst)
			key_2nd <= 1'b1;
		else if(cnt==18'h3ffff)//对应20ms左右
			key_2nd <= key;//将延时后的按键状态赋值给key_2nd
	end
 
	always@(posedge clk or negedge rst)begin
		if(!rst)
			key_2nd_pre <= 1'b1;
		else
			key_2nd_pre <= key_2nd;
	end
	//如果按键状态变低产生一个时钟的高脉冲.如果按键状态是高 按键无效
	assign key_pulse = key_2nd_pre & (~key_2nd);
 
endmodule

module safe(clk,rst,key,sw_pwd,led,sega,segb); //保险箱实现模块
 
	input clk;
	input rst;
	input key;//确认键
	input [3:0] sw_pwd;//四路拨动开关，输入密码
	
	output [1:0] led;//指示灯
	output [8:0] sega;//数码管
	output [8:0] segb;
 
	parameter password = 4'b1001;//密码
	
	reg [1:0] sgn;//两位指示灯信号,对应两路6指示灯(一红一绿)
	reg [8:0] seg [3:0];//9位宽信号,用来储存数码管数字显示数据
	reg [8:0] seg_data [1:0];//数码管显示信号寄存器
	reg [1:0] cnt;//计数器,用以统计错误次数
	reg lock;//程序锁,避免次数用完后或者密码正确之后的误操作

	wire cfm_dbs;//消抖后的确认脉冲
 
	initial begin
	seg[0] <= 9'h3f;//数码管显示数字0信号
	seg[1] <= 9'h06;//数字1信号
	seg[2] <= 9'h5b;//数字2信号
	seg[3] <= 9'h4f;//数字3信号
	seg_data[0] <= 9'h3f;//数码管初始显示数字0
	seg_data[1] <= 9'h3f;
	cnt <= 2'b11;//计数器初始值为3
	end
 
	always @ (posedge clk or negedge rst)//时钟边沿触发或复位按键触发
	begin
		if(!rst)
		begin
			sgn <= 2'b11;//两灯均灭
			seg_data[0] <= seg[3];//显示数字3
			seg_data[1] <= seg[0];//显示数字0
			cnt <= 2'b11;//计数器复位到3
			lock <= 1'b1;//开锁
			end
		else if(cfm_dbs && lock)//按下确认键,此处用的消抖后的脉冲信号 若程序锁已锁,代码不再被执行
		begin
			if(sw_pwd == password)
			begin//密码正确
				sgn <= 2'b10;//绿灯亮
				seg_data[0] <= 9'h77;//密码输入正确 显示两个0
				seg_data[1] <= 9'h39;
				lock <= 0;//程序锁死,防止解锁成功后还能进行操作
				end
			else if(cnt == 2'b11)
			begin//密码错误
				sgn <= 2'b01;//红灯亮
				seg_data[0] <= seg[2];//数码管显示数字2
				cnt <= 2'b10;//计数器移至2
				end
			else if(cnt == 2'b10) 
			begin
				sgn <= 2'b01;//红灯亮
				seg_data[0] <= seg[1];//数码管显示数字1
				cnt <= 2'b01;//计数器移至1
				end
			else if(cnt == 2'b01)
			begin
				sgn <= 2'b00;//红灯和绿灯同时亮
				seg_data[0] <= seg[0];//数码管显示数字0
				lock <= 0;//程序锁死，操作错误过多
				end
			end
	end
 
	assign led = sgn;//绿灯亮 密码正确 红灯反之
	assign sega = seg_data[0];//第一根数码管通过输入信号变化改变数值
	assign segb = seg_data[1];//第二根数码管显示数字0
 
	debounce key_dbs (
		//调用消抖
		.clk (clk),
		.rst (rst),
		.key (key),
		.key_pulse (cfm_dbs));
 
endmodule
