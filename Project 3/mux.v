// Name: mux.v
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
// 32-bit mux
module MUX32_32x1(Y, I0, I1, I2, I3, I4, I5, I6, I7,
                     I8, I9, I10, I11, I12, I13, I14, I15,
                     I16, I17, I18, I19, I20, I21, I22, I23,
                     I24, I25, I26, I27, I28, I29, I30, I31, S);
// output list
output [31:0] Y;
//input list
input [31:0] I0, I1, I2, I3, I4, I5, I6, I7;
input [31:0] I8, I9, I10, I11, I12, I13, I14, I15;
input [31:0] I16, I17, I18, I19, I20, I21, I22, I23;
input [31:0] I24, I25, I26, I27, I28, I29, I30, I31;
input [4:0] S;

// TBD
wire [31:0] topMux, botMux;
wire [3:0] sp = S[3:0];

MUX32_16x1 first(.Y(topMux), .I0(I0), .I1(I1), .I2(I2), .I3(I3), .I4(I4), .I5(I5), .I6(I6), .I7(I7),
                     .I8(I8), .I9(I9), .I10(I10), .I11(I11), .I12(I12), .I13(I13), .I14(I14), .I15(I15), .S(sp));

MUX32_16x1 second(.Y(botMux), .I0(I16), .I1(I17), .I2(I18), .I3(I19), .I4(I20), .I5(I21), .I6(I22), .I7(I23),
                     .I8(I24), .I9(I25), .I10(I26), .I11(I27), .I12(I28), .I13(I29), .I14(I30), .I15(I31), .S(sp));

MUX32_2x1 third(.Y(Y), .I0(topMux), .I1(botMux), .S(S[4]));

endmodule

// 32-bit 16x1 mux
module MUX32_16x1(Y, I0, I1, I2, I3, I4, I5, I6, I7,
                     I8, I9, I10, I11, I12, I13, I14, I15, S);
// output list
output [31:0] Y;
//input list
input [31:0] I0;
input [31:0] I1;
input [31:0] I2;
input [31:0] I3;
input [31:0] I4;
input [31:0] I5;
input [31:0] I6;
input [31:0] I7;
input [31:0] I8;
input [31:0] I9;
input [31:0] I10;
input [31:0] I11;
input [31:0] I12;
input [31:0] I13;
input [31:0] I14;
input [31:0] I15;
input [3:0] S;

// TBD
//wires to hold outputs of preliminary mux's and first stage signals
wire [31:0] topMux;
wire [31:0] botMux;
wire [2:0] sf = S[2:0];

//declare two 32 bit 8x1 mux's to get the job done
MUX32_8x1 muxA(.Y(topMux), .I0(I0), .I1(I1), .I2(), .I3(I3), .I4(I4), .I5(I5), .I6(I6), .I7(I7), .S(sf));
MUX32_8x1 muxB(.Y(botMux), .I0(I8), .I1(I9), .I2(I10), .I3(I11), .I4(I12), .I5(I13), .I6(I14), .I7(I15), .S(sf));

//create the final 32 bit 2x1 mux to yield the final result
MUX32_2x1 muxC(.Y(Y), .I0(topMux), .I1(botMux), .S(S[3]));

endmodule

// 32-bit 8x1 mux
module MUX32_8x1(Y, I0, I1, I2, I3, I4, I5, I6, I7, S);
// output list
output [31:0] Y;
//input list
input [31:0] I0;
input [31:0] I1;
input [31:0] I2;
input [31:0] I3;
input [31:0] I4;
input [31:0] I5;
input [31:0] I6;
input [31:0] I7;
input [2:0] S;

// TBD
//wires to hold output values and first part signals
wire [31:0] topMux;
wire [31:0] botMux;
wire [1:0] sf = S[1:0];

//create two 32 bit 4x1 mux's and make them go to work
MUX32_4x1 muxA(.Y(topMux), .I0(I0), .I1(I1), .I2(I2), .I3(I3), .S(sf));
MUX32_4x1 muxB(.Y(botMux), .I0(I4), .I1(I5), .I2(I6), .I3(I7), .S(sf));

//the final 32 bit 2x1 mux to produce the final result
MUX32_2x1 muxC(.Y(Y), .I0(topMux), .I1(botMux), .S(S[2]));

endmodule

// 32-bit 4x1 mux
module MUX32_4x1(Y, I0, I1, I2, I3, S);
// output list
output [31:0] Y;
//input list
input [31:0] I0;
input [31:0] I1;
input [31:0] I2;
input [31:0] I3;
input [1:0] S;

// TBD
//wires to hold the value of the first two mux's in the design
wire [31:0] topMux;
wire [31:0] botMux;


//create two 32 bit 2x1 mux's and make them do work
MUX32_2x1 muxA(.Y(topMux), .I0(I0), .I1(I1), .S(S[0]));
MUX32_2x1 muxB(.Y(botMux), .I0(I2), .I1(I3), .S(S[1]));

//combine the results of the two mux's into a final mux to get the output
MUX32_2x1 muxC(.Y(Y), .I0(topMux), .I1(botMux), .S(S[1]));

endmodule

// 32-bit mux
module MUX32_2x1(Y, I0, I1, S);
// output list
output [31:0] Y;
//input list
input [31:0] I0;
input [31:0] I1;
input S;

// TBD
genvar i;
generate
for(i = 0; i < 32; i = i + 1)
begin
	MUX1_2x1 mux(.Y(Y[i]), .I0(I0[i]), .I1(I1[i]), .S(S));

end
endgenerate

endmodule

// 1-bit mux
module MUX1_2x1(Y,I0, I1, S);
//output list
output Y;
//input list
input I0, I1, S;

// TBD
wire firstAnd;
wire secAnd;
wire notS;

not inst2(notS, S);
and inst1(firstAnd, notS, I0);
and inst3(secAnd, S, I1);
or  inst4(Y, secAnd, firstAnd);

endmodule
