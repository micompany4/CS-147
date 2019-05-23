// Name: control_unit.v
// Module: CONTROL_UNIT
// Output: CTRL  : Control signal for data path
//         READ  : Memory read signal
//         WRITE : Memory Write signal
//
// Input:  ZERO : Zero status from ALU
//         CLK  : Clock signal
//         RST  : Reset Signal
//
// Notes: - Control unit synchronize operations of a processor
//          Assign each bit of control signal to control one part of data path
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"
module CONTROL_UNIT(CTRL, READ, WRITE, ZERO, INSTRUCTION, CLK, RST); 
// Output signals
output [`CTRL_WIDTH_INDEX_LIMIT:0]  CTRL;
output READ, WRITE;

// input signals
input ZERO, CLK, RST;
input [`DATA_INDEX_LIMIT:0] INSTRUCTION;
 
// TBD - take action on each +ve edge of clock

endmodule


//------------------------------------------------------------------------------------------
// Module: PROC_SM
// Output: STATE      : State of the processor
//         
// Input:  CLK        : Clock signal
//         RST        : Reset signal
//
// INOUT: MEM_DATA    : Data to be read in from or write to the memory
//
// Notes: - Processor continuously cycle witnin fetch, decode, execute, 
//          memory, write back state. State values are in the prj_definition.v
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
module PROC_SM(STATE,CLK,RST);
// list of inputs
input CLK, RST;
// list of outputs
output [2:0] STATE;

// TBD - take action on each +ve edge of clock
reg [2:0] STATE;
reg [2:0] next_state;


//creates the inital state
initial 
begin
   STATE = 3'bxx;
   next_state = `PROC_FETCH;
end

//reset the state machine 
always @ (negedge RST)
begin
     STATE = 3'bxx;
     next_state = `PROC_FETCH;   
end

//check if the state has changed and if so assign it's next state
always @ (posedge CLK)
begin
     if (STATE === `PROC_FETCH) 
     begin
	next_state = `PROC_DECODE;
     end
     else if (STATE === `PROC_DECODE) 
     begin
	next_state = `PROC_EXE;
     end
     else if (STATE === `PROC_EXE)
     begin
        next_state = `PROC_MEM;
     end
     else if (STATE === `PROC_MEM)
     begin
        next_state = `PROC_WB;
     end
     else if (STATE === `PROC_WB)
     begin
        next_state = `PROC_FETCH;
     end
	
     STATE = next_state;     //changes the state to the next state
	
end


endmodule