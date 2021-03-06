// Name: data_path.v
// Module: DATA_PATH
// Output:  DATA : Data to be written at address ADDR
//          ADDR : Address of the memory location to be accessed
//
// Input:   DATA : Data read out in the read operation
//          CLK  : Clock signal
//          RST  : Reset signal
//
// Notes: - 32 bit processor implementing cs147sec05 instruction set
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"
module DATA_PATH(DATA_OUT, ADDR, ZERO, INSTRUCTION, DATA_IN, CTRL, CLK, RST);

// output list
output [`ADDRESS_INDEX_LIMIT:0] ADDR;
output ZERO;
output [`DATA_INDEX_LIMIT:0] DATA_OUT, INSTRUCTION;

// input list
input [`CTRL_WIDTH_INDEX_LIMIT:0]  CTRL;
input CLK, RST;
input [`DATA_INDEX_LIMIT:0] DATA_IN;

// TBD

//This project was hard and I ran out of time... :(

//===============================================================================
//Use this register in data_path.v as following sample (wire names may be adjusted accordingly your convention of wire naming).


// Program Counter
defparam pc_inst.PATTERN = `INST_START_ADDR;
REG32_PP pc_inst(.Q(pc), .D(pc_3), .LOAD(pc_load), .CLK(CLK), .RESET(RST));

// Stack Pointer
defparam sp_inst.PATTERN = `INIT_STACK_POINTER;
REG32_PP sp_inst(.Q(sp), .D(alu_out), .LOAD(sp_load), .CLK(CLK), .RESET(RST));

//===============================================================================


endmodule
