module my_add(a,b,ci,s,co);
	input [3:0]a;
	input [3:0]b;
	input ci;
	//input key1;
	//input key2;
	//input key3;
	
	output [3:0]s;
	output co;
	
	wire [3:0] carr;
	assign co = carr[3];
	
	add_full i0(a[0],b[0],ci,		s[0],carr[0]);
	add_full i1(a[1],b[1],carr[0],s[1],carr[1]);
	add_full i2(a[2],b[2],carr[1],s[2],carr[2]);
	add_full i3(a[3],b[3],carr[2],s[3],carr[3]); 
	
endmodule

module add_full(a,b,ci,si,co);
	input a;
	input b;
	input ci;
	output si;
	output co;
	
	assign si = a^b^ci;
	assign co = (a&b)|((a^b)&ci);
	
endmodule
