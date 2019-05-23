`timescale 1ns/1ps

`include "prj_definition.v"
module rc_add_sub_32_tb;

reg [`DATA_INDEX_LIMIT:0] A, B;
reg SnA;
wire [`DATA_INDEX_LIMIT:0] Y;
wire CO;

RC_ADD_SUB_32 inst(.Y(Y), .CO(CO), .A(A), .B(B), .SnA(SnA));

initial 
begin

	A = 0; B = 0; SnA = 0;
#5	$write("A: 0 B:0 SnA:0 | Y: %d CO: %d\n", Y, CO);
#5	A = 0; B = 0; SnA = 1;
#5	$write("A: 0 B:0 SnA:1 | Y: %d CO: %d\n", Y, CO);
#5	A = 8; B = 2; SnA = 0; 
#5	$write("A:8 B:2 SnA:0 | Y: %d CO: %d\n", Y, CO);
#5	A = 20; B = 5; SnA = 1;
#5	$write("A:20 B:5 SnA:1 | Y: %d CO: %d\n", Y, CO);
#5	A = 9000; B = 24; SnA = 1;
#5 	$write("A:9000 B: 24 SnA:1 | Y: %d CO: %d\n", Y, CO);
#5	A = 2; B = 5; SnA = 1;
#5	$write("A:2 B:5 SnA:1 | Y: %d CO: %d\n", Y, CO);
#5	A = 50; B = 50; SnA = 1;
#5	$write("A:50 B:50 SnA:1 | Y: %d CO: %d\n", Y, CO); 
#5	A = 2147483647; B = 4; SnA = 0;
#5	$write("A:2147483647 B:4 SnA:0 | Y: %d CO: %d\n", Y, CO); 
#5
	$stop;

end

endmodule 