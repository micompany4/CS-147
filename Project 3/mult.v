// Name: mult.v
// Module: MULT32 , MULT32_U
//
// Output: HI: 32 higher bits
//         LO: 32 lower bits
//         
//
// Input: A : 32-bit input
//        B : 32-bit input
//
// Notes: 32-bit multiplication
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"

module MULT32(HI, LO, A, B);
// output list
output [31:0] HI;
output [31:0] LO;
// input list
input [31:0] A;		//multipler
input [31:0] B;		//multiplicand

// TBD
wire signID;
wire [31:0] twosCompMCND;
wire [31:0] twosCompMPLR;
wire [31:0] trueMCND;
wire [31:0] trueMPLR;
wire [31:0] betaHI;
wire [31:0] betaLO;
wire [31:0] trueHI;
wire [31:0] trueLO;
wire [31:0] twosCompHI;
wire [31:0] twosCompLO;
wire [31:0] ansHI, ansLO;

//gets the twos complement of MCND and MPLR
TWOSCOMP32 compMCND(.Y(twosCompMCND), .A(A));
TWOSCOMP32 compMPLR(.Y(twosCompMPLR), .A(B));

//passes the MCND through the multiplexer
MUX32_2x1 muxMCND(.Y(trueMCND), .I0(A), .I1(twosCompMCND), .S(A[31]));

//passes the MLPR thorugh the multiplexer
MUX32_2x1 muxMLPR(.Y(trueMPLR), .I0(B), .I1(twosCompMPLR), .S(B[31]));

//do the math in the 32-bit unsigned multiplier
MULT32_U calc(.HI(betaHI), .LO(betaLO), .A(trueMCND), .B(trueMPLR));

//determines the sign of the product
xor decision(signID, A[31], B[31]);

//okay so here's the confusion part, am I suppose to do this? 
//is there a piece of information that I'm not getting...
TWOSCOMP32 compHI(.Y(twosCompHI), .A(betaHI));
TWOSCOMP32 compLO(.Y(twosCompLO), .A(betaLO));
MUX32_2x1 muxHI(.Y(ansHI), .I0(betaHI), .I1(twosCompHI), .S(signID));
MUX32_2x1 muxLO(.Y(ansLO), .I0(betaLO), .I1(twosCompLO), .S(signID));

BUF32_1x1 instb1(.Y(HI), .A(ansHI));
BUF32_1x1 instb2(.Y(LO), .A(ansLO));

endmodule

module MULT32_U(HI, LO, A, B);
// output list
output [31:0] HI;
output [31:0] LO;
// input list
input [31:0] A;		//multiplier
input [31:0] B;		//multiplicand

// TBD
wire carryO [31:0];		//represents the carry out output from the adder 
wire [31:0] OP2 [31:0];		//the second operation to go into the adders, need 32 32 bit operands

AND32_2x1 firstAnd(.Y(OP2[0]), .A(A), .B({32{B[0]}}));	//that thing at the end there is to make it 32 bit replicated 
buf b0 (carryO[0], 1'b0);
buf b1(LO[0], OP2[0][0]);

//loop to move down the circuit and get a result
genvar r;
generate
for(r = 1; r < 32; r = r + 1)
begin
	wire [31:0] OP1;	//the first operand to go into the adder
	AND32_2x1 leap(.Y(OP1), .A(A), .B({32{B[r]}}));
	RC_ADD_SUB_32 calcu(.Y(OP2[r]), .CO(carryO[r]), .A(OP1), .B({carryO[r-1], {OP2[r-1][31:1]}}), .SnA(1'b0));
	buf b2(LO[r], OP2[r][0]);
end
endgenerate

//assign the hi registers to the last carryO value and op2 value 
BUF32_1x1 instbuff(.Y(HI), .A({carryO[31], {OP2[31][31:1]}}));


endmodule
