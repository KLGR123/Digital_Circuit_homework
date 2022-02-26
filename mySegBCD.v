module mySegBCD (sw, seg0);
	input [3:0] sw;						
	output [8:0] seg0;		 
       
	reg [8:0] seg [9:0];   
	reg [8:0] seg0;	
	
   initial                                                                                                                          //initial和always不同，其中语句只执行一次
	begin
		seg[0] = 9'h3f;                                           
		seg[1] = 9'h06;                                           
		seg[2] = 9'h5b;                                           
		seg[3] = 9'h4f;                                           
		seg[4] = 9'h66;                                           
		seg[5] = 9'h6d;                                           
		seg[6] = 9'h7d;                                           
		seg[7] = 9'h07;                                          
		seg[8] = 9'h7f;                                        
		seg[9] = 9'h6f;                                           
   end
	
	always@(sw)
	begin
		if(sw < 4'b1001)
			seg0 = seg[sw];
		else
			seg0 = seg0;
	end
endmodule

//`timescale 10ns/1ns

//module counter(rst, seg1);
//	input rst;
//	output [8:0]seg1;
//	
//	always@(rst)
//	begin
//		
//	end
//endmodule

