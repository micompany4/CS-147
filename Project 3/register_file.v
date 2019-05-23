// Name: register_file.v
// Module: REGISTER_FILE_32x32
// Input:  DATA_W : Data to be written at address ADDR_W
//         ADDR_W : Address of the memory location to be written
//         ADDR_R1 : Address of the memory location to be read for DATA_R1
//         ADDR_R2 : Address of the memory location to be read for DATA_R2
//         READ    : Read signal
//         WRITE   : Write signal
//         CLK     : Clock signal
//         RST     : Reset signal
// Output: DATA_R1 : Data at ADDR_R1 address
//         DATA_R2 : Data at ADDR_R1 address
//
// Notes: - 32 bit word accessible dual read register file having 32 regsisters.
//        - Reset is done at -ve edge of the RST signal
//        - Rest of the operation is done at the +ve edge of the CLK signal
//        - Read operation is done if READ=1 and WRITE=0
//        - Write operation is done if WRITE=1 and READ=0
//        - X is the value at DATA_R* if both READ and WRITE are 0 or 1
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"

// This is going to be +ve edge clock triggered register file.
// Reset on RST=0
module REGISTER_FILE_32x32(DATA_R1, DATA_R2, ADDR_R1, ADDR_R2, 
                            DATA_W, ADDR_W, READ, WRITE, CLK, RST);

// input list
input READ, WRITE, CLK, RST;
input [`DATA_INDEX_LIMIT:0] DATA_W;
input [`REG_ADDR_INDEX_LIMIT:0] ADDR_R1, ADDR_R2, ADDR_W;

// output list
output [`DATA_INDEX_LIMIT:0] DATA_R1;
output [`DATA_INDEX_LIMIT:0] DATA_R2;

// TBD
wire [31:0] firstMux, secMux, outReg, outDecode, andDW;
wire invert;
not(invert, RST);

//decoder for the write address
DECODER_5x32 dedede(.D(outDecode), .I(ADDR_W));

//gets result of passing the results of the decoder and WRITE through an AND gate
genvar a;
generate
for(a = 0; a < 32; a = a + 1)
begin
	and(andDW[a], outDecode[a], WRITE);
end
endgenerate

//generates the outputs from 32 32bit registers
genvar r;
generate
for(r = 0; r < 32; r = r + 1)
begin
	REG32 inst(.Q(outReg[r]), .D(DATA_W[r]), .LOAD(andDW[r]), .CLK(CLK), .RESET(invert));		
end
endgenerate



//multiplexers that take in the results of the 32 32bit registers and makes a selection based on register addresses
MUX32_32x1 instR1(.Y(firstMux), .I0(outReg[0]), .I1(outReg[1]), .I2(outReg[2]), .I3(outReg[3]), .I4(outReg[4]), .I5(outReg[5]), .I6(outReg[6]), .I7(outReg[7]),
                     .I8(outReg[8]), .I9(outReg[9]), .I10(outReg[10]), .I11(outReg[11]), .I12(outReg[12]), .I13(outReg[13]), .I14(outReg[14]), .I15(outReg[15]),
                     .I16(outReg[16]), .I17(outReg[17]), .I18(outReg[18]), .I19(outReg[19]), .I20(outReg[20]), .I21(outReg[21]), .I22(outReg[22]), .I23(outReg[23]),
                     .I24(outReg[24]), .I25(outReg[25]), .I26(outReg[26]), .I27(outReg[27]), .I28(outReg[28]), .I29(outReg[29]), .I30(outReg[30]), .I31(outReg[31]), .S(ADDR_R1));

MUX32_32x1 instR2(.Y(secMux), .I0(outReg[0]), .I1(outReg[1]), .I2(outReg[2]), .I3(outReg[3]), .I4(outReg[4]), .I5(outReg[5]), .I6(outReg[6]), .I7(outReg[7]),
                     .I8(outReg[8]), .I9(outReg[9]), .I10(outReg[10]), .I11(outReg[11]), .I12(outReg[12]), .I13(outReg[13]), .I14(outReg[14]), .I15(outReg[15]),
                     .I16(outReg[16]), .I17(outReg[17]), .I18(outReg[18]), .I19(outReg[19]), .I20(outReg[20]), .I21(outReg[21]), .I22(outReg[22]), .I23(outReg[23]),
                     .I24(outReg[24]), .I25(outReg[25]), .I26(outReg[26]), .I27(outReg[27]), .I28(outReg[28]), .I29(outReg[29]), .I30(outReg[30]), .I31(outReg[31]), .S(ADDR_R2));



//makes the decision for the register data output
MUX32_2x1 inst99(.Y(DATA_R1), .I0(1'bz), .I1(firstMux), .S(READ));
MUX32_2x1 inst44(.Y(DATA_R2), .I0(1'bz), .I1(secMux), .S(READ));

endmodule
