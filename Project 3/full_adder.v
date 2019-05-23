// Name: full_adder.v
// Module: FULL_ADDER
//
// Output: S : Sum
//         CO : Carry Out
//
// Input: A : Bit 1
//        B : Bit 2
//        CI : Carry In
//
// Notes: 1-bit full adder implementaiton.
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"

module FULL_ADDER(S,CO,A,B, CI);
output S,CO;
input A,B, CI;


//TBD
wire firstAddSum;
wire firstCI;
wire secCI;

//first half adder
//xor inst1(S, A, B);
//and inst2(CO, A, B);
HALF_ADDER instFirst(.Y(firstAddSum), .C(firstCI), .A(A), .B(B));


//second half adder
//and inst3(CI, CI, S);
//or  inst4(CO, CO, CI);
HALF_ADDER instSec(.Y(S), .C(secCI), .A(firstAddSum), .B(CI));

//get the final carryout
or instCO(CO, firstCI, secCI);

endmodule;
