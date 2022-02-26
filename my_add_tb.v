module my_add_tb();
    wire [3:0]s;
    wire cout;
    reg [3:0]a,b;
    reg cin;
	 my_add a1(.a(a),.b(b),.ci(cin),.s(s),.co(cout));
    initial
        begin
            #0; a = 4'b0001; b = 4'b1010; cin = 1'b0;
            #5; a = 4'b0010; b = 4'b1010; cin = 1'b1;
            #5; a = 4'b0010; b = 4'b1110; cin = 1'b0;
            #5; a = 4'b0011; b = 4'b1100; cin = 1'b1;
            #5; a = 4'b0111; b = 4'b1001; cin = 1'b0;
            #5; a = 4'b0001; b = 4'b1100; cin = 1'b1;
            #5; a = 4'b0011; b = 4'b1100; cin = 1'b0;
            #5; a = 4'b0111; b = 4'b1111; cin = 1'b1;
            #5; $stop;
        end
endmodule
