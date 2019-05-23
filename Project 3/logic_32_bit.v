// Name: logic_32_bit.v
// Module: 
// Input: 
// Output: 
//
// Notes: Common definitions
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 02, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//

`include "prj_definition.v"

// 32-bit NOR
module NOR32_2x1(Y,A,B);
//output 
output [31:0] Y;
//input
input [31:0] A;
input [31:0] B;

// TBD
genvar i;
generate
for(i = 0; i < `DATA_WIDTH; i = i + 1)
begin 
     nor inst(Y[i], A[i], B[i]);
end
endgenerate


endmodule




// 32-bit AND
module AND32_2x1(Y,A,B);
//output 
output [31:0] Y;
//input
input [31:0] A;
input [31:0] B;

// TBD
genvar i;
generate
for(i = 0; i < `DATA_WIDTH; i = i + 1)
begin 
     and inst(Y[i], A[i], B[i]);
end
endgenerate


endmodule

// 32-bit inverter
module INV32_1x1(Y,A);
//output 
output [31:0] Y;
//input
input [31:0] A;

// TBD
genvar i;
generate
for(i = 0; i < `DATA_WIDTH; i = i + 1)
begin 
     not inst(Y[i], A[i]);
end
endgenerate

endmodule

// 32-bit buffer
module BUF32_1x1(Y,A);
//output 
output [31:0] Y;
//input
input [31:0] A;

// TBD
genvar i;
generate
for(i = 0; i < `DATA_WIDTH; i = i + 1)
begin 
     buf inst(Y[i], A[i]);
end
endgenerate

endmodule

// 32-bit OR
module OR32_2x1(Y,A,B);
//output 
output [31:0] Y;
//input
input [31:0] A;
input [31:0] B;

// TBD
wire [31:0] result;

NOR32_2x1 inst1(.Y(result), .A(A), .B(B));
INV32_1x1 inst2(.Y(Y), .A(result));


endmodule
