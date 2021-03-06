`timescale 1ns/1ps

module shifter_tb;

reg [31:0] D;
reg [4:0] S;
wire [31:0] Y;

reg [7:0] Da;
wire[7:0] Ya;
reg [2:0] Sa;


SHIFT32_L inst(.Y(Y), .D(D), .S(S));
//SHIFT4_L inst(.Y(Ya), .D(Da), .S(Sa));

initial 
begin
	D = 'b11100000000000000000000000000000; S = 'b0;
#5	$write("D: %d \nY: %d\n", D, Y);
#5	D = 'b11100000000000000000000000000000; S = 'b1;
#5	$write("D: %d \nY: %d\n", D, Y);
#5	D = 'b11100000000000000000000000000000; S = 'b11; 
#5	$write("D: %d \nY: %d\n", D, Y);

//	Da = 8'b11111111; Sa = 'b0;
//#5	$write("Da: %d \nYa: %d\n", Da, Ya);
//#5	Da = 8'b11111111; Sa = 'b1;
//#5	$write("Da: %d\nYa: %d\n", Da, Ya);
//#5	Da = 8'b11111111; Sa = 'b10;
//#5	$write("Da: %d\nYa: %d\n", Da, Ya);
//#5	Da = 8'b11111111; Sa = 'b11;
//#5	$write("Da: %d\nYa: %d\n", Da, Ya);

	$stop;
end


endmodule