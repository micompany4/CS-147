// Name: logic.v
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
// 64-bit two's complement
module TWOSCOMP64(Y,A);
//output list
output [63:0] Y;
//input list
input [63:0] A;

// TBD
wire [63:0] invA;
wire CO;


genvar i;
generate
for(i = 0; i < 64; i = i+1)
begin
     not inst1(invA[i], A[i]);
     RC_ADD_SUB_32 inst(.Y(Y), .CO(CO), .A(invA), .B(64'b1), .SnA(1'b0));
end
endgenerate


endmodule

// 32-bit two's complement
module TWOSCOMP32(Y,A);
//output list
output [31:0] Y;
//input list
input [31:0] A;

// TBD
wire [31:0] invA;
wire CO;		//pointless for the twos complement

reg [31:0] one = 32'b1; 
reg signal = 0;

genvar i;
generate
for(i = 0; i < 32; i = i+1)
begin
     not inst1(invA[i], A[i]);
end
endgenerate

RC_ADD_SUB_32 inst(.Y(Y), .CO(CO), .A(invA), .B(one), .SnA(signal));

endmodule

// 32-bit registere +ve edge, Reset on RESET=0
module REG32(Q, D, LOAD, CLK, RESET);
output [31:0] Q;

input CLK, LOAD;
input [31:0] D;
input RESET;

// TBD
genvar r;
generate 
for(r = 0; r < 32; r = r + 1)
begin
	REG1 inst(.Q(Q[r]), .Qbar(1'bz), .D(D[r]), .L(LOAD), .C(CLK), .nP(1'b1), .nR(RESET));
end
endgenerate


endmodule

// 1 bit register +ve edge, 
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module REG1(Q, Qbar, D, L, C, nP, nR);
input D, C, L;
input nP, nR;
output Q,Qbar;

// TBD
wire resQ;			//wire to hold the result of Q
wire resMUX;			//wire to hold the output of the multiplexer
wire finalQ;

buf(resQ, finalQ);
MUX1_2x1 munchy(.Y(resMUX), .I0(resQ), .I1(D), .S(L));
D_FF leFlop(.Q(finalQ), .Qbar(Qbar), .D(resMUX), .C(C), .nP(nP), .nR(nR));
buf(resQ, finalQ);
buf(Q, finalQ);

endmodule

// 1 bit flipflop +ve edge, 
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module D_FF(Q, Qbar, D, C, nP, nR);
input D, C;
input nP, nR;
output Q,Qbar;

// TBD
wire Cbar, DQ, DQbar;
not(Cbar, C);

D_LATCH day(.Q(DQ), .Qbar(DQbar), .D(D), .C(C), .nP(nP), .nR(nR));
SR_LATCH saric(.Q(Q), .Qbar(Qbar), .S(DQ), .R(DQbar), .C(Cbar), .nP(nP), .nR(nR));



endmodule

// 1 bit D latch
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module D_LATCH(Q, Qbar, D, C, nP, nR);
input D, C;
input nP, nR;
output Q,Qbar;

// TBD
wire Dbar, firstRes, secRes, resQ, resQBAR;
not(Dbar, D);
nand(firstRes, D, C);
nand(secRes, C, Dbar);

//check this, is this the proper way of redirecting 
nand(resQ, firstRes, resQBAR, nP);
nand(resQBAR, secRes, resQ, nR);

buf(Q, resQ);
buf(Qbar, resQBAR);

endmodule

// 1 bit SR latch
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module SR_LATCH(Q,Qbar, S, R, C, nP, nR);
input S, R, C;
input nP, nR;
output Q,Qbar;

// TBD
wire firstRes, secRes, resQ, resQBAR, nCLK;

not inv(nCLK, C);

nand first(firstRes, S, nCLK);
nand second(secRes, nCLK, R);
//check to make sure this is correct way of redirection
nand third(resQ, firstRes, resQBAR, nP);
nand fourth(resQBAR, secRes, resQ, nR);

buf(Q, resQ);
buf(Qbar, resQBAR);

endmodule

// 5x32 Line decoder
module DECODER_5x32(D,I);
// output
output [31:0] D;
// input
input [4:0] I;

// TBD
wire invI4;
wire [15:0] out;
wire [3:0] in = I[3:0];
not(invI4, I[4]);

DECODER_4x16 inst(.D(out), .I(in));

and(D[0], out[0], invI4);
and(D[1], out[1], invI4);
and(D[2], out[2], invI4);
and(D[3], out[3], invI4);
and(D[4], out[4], invI4);
and(D[5], out[5], invI4);
and(D[6], out[6], invI4);
and(D[7], out[7], invI4);
and(D[8], out[8], invI4);
and(D[9], out[9], invI4);
and(D[10], out[10], invI4);
and(D[11], out[11], invI4);
and(D[12], out[12], invI4);
and(D[13], out[13], invI4);
and(D[14], out[14], invI4);
and(D[15], out[15], invI4);
and(D[16], out[0], I[4]);
and(D[17], out[1], I[4]);
and(D[18], out[2], I[4]);
and(D[19], out[3], I[4]);
and(D[20], out[4], I[4]);
and(D[21], out[5], I[4]);
and(D[22], out[6], I[4]);
and(D[23], out[7], I[4]);
and(D[24], out[8], I[4]);
and(D[25], out[9], I[4]);
and(D[26], out[10], I[4]);
and(D[27], out[11], I[4]);
and(D[28], out[12], I[4]);
and(D[29], out[13], I[4]);
and(D[30], out[14], I[4]);
and(D[31], out[15], I[4]);

endmodule

// 4x16 Line decoder
module DECODER_4x16(D,I);
// output
output [15:0] D;
// input
input [3:0] I;

// TBD
wire invI3;
wire [7:0] out;
wire [2:0] in = I[2:0];
not(invI3, I[3]);

DECODER_3x8 dede(.D(out), .I(in));

and(D[0], out[0], invI3);
and(D[1], out[1], invI3);
and(D[2], out[2], invI3);
and(D[3], out[3], invI3);
and(D[4], out[4], invI3);
and(D[5], out[5], invI3);
and(D[6], out[6], invI3);
and(D[7], out[7], invI3);
and(D[8], out[0], I[3]);
and(D[9], out[1], I[3]);
and(D[10], out[2], I[3]);
and(D[11], out[3], I[3]);
and(D[12], out[4], I[3]);
and(D[13], out[5], I[3]);
and(D[14], out[6], I[3]);
and(D[15], out[7], I[3]);

endmodule

// 3x8 Line decoder
module DECODER_3x8(D,I);
// output
output [7:0] D;
// input
input [2:0] I;

//TBD
wire invI2;
wire [3:0] out;
wire [1:0] in = I[1:0];
not(invI2, I[2]);

DECODER_2x4 inst(.D(out), .I(in));

and(D[0], out[0], invI2);
and(D[1], out[1], invI2);
and(D[2], out[2], invI2);
and(D[3], out[3], invI2);
and(D[4], out[0], I[2]);
and(D[5], out[1], I[2]);
and(D[6], out[2], I[2]);
and(D[7], out[3], I[2]);


endmodule

// 2x4 Line decoder
module DECODER_2x4(D,I);
// output
output [3:0] D;
// input
input [1:0] I;

// TBD

wire invI0;
wire invI1;

not(invI0, I[0]);
not(invI1, I[1]);

and inst0(D[0], invI0, invI1);
and inst1(D[1], invI0, I[1]);
and inst2(D[2], I[0], invI1);
and inst3(D[3], I[0], I[1]);


endmodule

//newly added to the logic.v file via Canvas Message
//This is a preset pattern register where preset bit pattern can be passed into it through parameter. 
module REG32_PP(Q, D, LOAD, CLK, RESET);
parameter PATTERN = 32'h00000000;
output [31:0] Q;

input CLK, LOAD;
input [31:0] D;
input RESET;

wire [31:0] qbar;

genvar i;
generate
for(i=0; i<32; i=i+1)
begin : reg32_gen_loop
if (PATTERN[i] == 0)
REG1 reg_inst(.Q(Q[i]), .Qbar(qbar[i]), .D(D[i]), .L(LOAD), .C(CLK), .nP(1'b1), .nR(RESET));
else
REG1 reg_inst(.Q(Q[i]), .Qbar(qbar[i]), .D(D[i]), .L(LOAD), .C(CLK), .nP(RESET), .nR(1'b1));
end
endgenerate

endmodule
