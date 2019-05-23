// Name: control_unit.v
// Module: CONTROL_UNIT
// Output: RF_DATA_W  : Data to be written at register file address RF_ADDR_W
//         RF_ADDR_W  : Register file address of the memory location to be written
//         RF_ADDR_R1 : Register file address of the memory location to be read for RF_DATA_R1
//         RF_ADDR_R2 : Registere file address of the memory location to be read for RF_DATA_R2
//         RF_READ    : Register file Read signal
//         RF_WRITE   : Register file Write signal
//         ALU_OP1    : ALU operand 1
//         ALU_OP2    : ALU operand 2
//         ALU_OPRN   : ALU operation code
//         MEM_ADDR   : Memory address to be read in
//         MEM_READ   : Memory read signal
//         MEM_WRITE  : Memory write signal
//         
// Input:  RF_DATA_R1 : Data at ADDR_R1 address
//         RF_DATA_R2 : Data at ADDR_R1 address
//         ALU_RESULT    : ALU output data
//         CLK        : Clock signal
//         RST        : Reset signal
//
// INOUT: MEM_DATA    : Data to be read in from or write to the memory
//
// Notes: - Control unit synchronize operations of a processor
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//  1.1     Oct 19, 2014        Kaushik Patra   kpatra@sjsu.edu         Added ZERO status output
//------------------------------------------------------------------------------------------
`include "prj_definition.v"
module CONTROL_UNIT(MEM_DATA, RF_DATA_W, RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2, RF_READ, RF_WRITE,
                    ALU_OP1, ALU_OP2, ALU_OPRN, MEM_ADDR, MEM_READ, MEM_WRITE,
                    RF_DATA_R1, RF_DATA_R2, ALU_RESULT, ZERO, CLK, RST); 

// Output signals
// Outputs for register file 
output [`DATA_INDEX_LIMIT:0] RF_DATA_W;
output [`ADDRESS_INDEX_LIMIT:0] RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2;
output RF_READ, RF_WRITE;
// Outputs for ALU
output [`DATA_INDEX_LIMIT:0]  ALU_OP1, ALU_OP2;
output  [`ALU_OPRN_INDEX_LIMIT:0] ALU_OPRN;
// Outputs for memory
output [`ADDRESS_INDEX_LIMIT:0]  MEM_ADDR;
output MEM_READ, MEM_WRITE;

// Input signals
input [`DATA_INDEX_LIMIT:0] RF_DATA_R1, RF_DATA_R2, ALU_RESULT;
input ZERO, CLK, RST;

// Inout signal
inout [`DATA_INDEX_LIMIT:0] MEM_DATA;

// State nets
wire [2:0] proc_state;

PROC_SM state_machine(.STATE(proc_state),.CLK(CLK),.RST(RST));

//registers for the register file outputs
reg [`DATA_INDEX_LIMIT:0] RF_DATA_W;
reg [`ADDRESS_INDEX_LIMIT:0] RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2;
reg RF_READ, RF_WRITE;

//registers for ALU outputs
reg [`DATA_INDEX_LIMIT:0]  ALU_OP1, ALU_OP2;
reg [`ALU_OPRN_INDEX_LIMIT:0] ALU_OPRN;

//registers for memory outputs
reg [`ADDRESS_INDEX_LIMIT:0]  MEM_ADDR;
reg MEM_READ, MEM_WRITE;

//register for the inout signal
reg [`DATA_INDEX_LIMIT:0] MEM_DATA;

//register to write data to memory and connect DATA to this register
reg [`DATA_INDEX_LIMIT:0] WR_TO_MEM;
assign MEM_DATA = ((MEM_READ === 1'b1)&&(MEM_WRITE === 1'b0))?{`DATA_WIDTH{1'bz} }:WR_TO_MEM;	


//internal registers for the counter, stack pointer, and current instruction 
reg [`DATA_INDEX_LIMIT:0] PC_REG;	//counter
reg [`DATA_INDEX_LIMIT:0] INST_REG;	//current instruction
reg [`DATA_INDEX_LIMIT:0] SP_REF;	//stack pointer

//*from the CS147DV Instruction Set
reg [5:0] opcode;
reg [4:0] rs;
reg [4:0] rt;
reg [4:0] rd;
reg [4:0] shamt;
reg [5:0] funct;
reg [15:0] immediate;
reg [25:0] address;

//registers specifically for the I-Type Instruction set
reg [`DATA_INDEX_LIMIT:0] SIGN_EXTEND;
reg [`DATA_INDEX_LIMIT:0] ZERO_EXTEND;
reg [`DATA_INDEX_LIMIT:0] LUI;
reg [`DATA_INDEX_LIMIT:0] JUMP_ADDR; //and for the J-Type Instuctions

initial
begin
    PC_REG = `INST_START_ADDR;
    SP_REF = `INIT_STACK_POINTER;
end

always @ (proc_state)
begin
// TBD: Code for the control unit model *look at lectures 1 and 11 on how to implement
   case(proc_state)
      `PROC_FETCH : 
	begin
	   MEM_ADDR = PC_REG;	//sets memory address to next instruction
	   //issues read signal to memory
	   MEM_READ = 1'b1;	
	   MEM_WRITE = 1'b0;
	   //makes sure that the register files are holding and no reading or writing is done
	   RF_READ = 1'b0;
	   RF_WRITE = 1'b0;
	end
      `PROC_DECODE : 
	begin
	   INST_REG = MEM_DATA;	//stores memory read data into current instruction
	   
	   // R-type
	   {opcode, rs, rt, rd, shamt, funct} = INST_REG;
	   // I-type
	   {opcode, rs, rt, immediate } = INST_REG;
	   // J-type
	   {opcode, address} = INST_REG;
	   
	   //helpful setups for sign/zero extension, lui value and the jump address
	   SIGN_EXTEND = {16{immediate[15], immediate}};
	   ZERO_EXTEND = {16'b0, immediate};
	   LUI = {immediate, 16'b0};
	   JUMP_ADDR = {6'b0, address};

	   //sets the read address of RF as rs and rt
	   
	   RF_ADDR_R1 = rs;
	   RF_ADDR_R2 = rt;

	   //sets the register file operation to read
	   RF_READ = 1'b1;
	   RF_WRITE = 1'b0;
	   print_instruction(INST_REG);
	end
      `PROC_EXE :
       begin
	 case(opcode)
	  6'b0:		//R-Type Instructions
	  begin
	    case(funct)	
	        6'h20 : ALU_OPRN = `ALU_OPRN_WIDTH'h01;		//sets the ALU operation code to addition
		6'h22 : ALU_OPRN = `ALU_OPRN_WIDTH'h02;		//sets the ALU operation code to subtraction
		6'h2c : ALU_OPRN = `ALU_OPRN_WIDTH'h03;		//sets the ALU operation code to multiplication
		6'h01 : ALU_OPRN = `ALU_OPRN_WIDTH'h04;		//sets the ALU operation code to srl
		6'h02 : ALU_OPRN = `ALU_OPRN_WIDTH'h05;		//sets the ALU operation code to sll
		6'h24 : ALU_OPRN = `ALU_OPRN_WIDTH'h06;		//sets the ALU operation code to and
		6'h25 : ALU_OPRN = `ALU_OPRN_WIDTH'h07;		//sets the ALU operation code to or
		6'h27 : ALU_OPRN = `ALU_OPRN_WIDTH'h08;		//sets the ALU operation code to nor
		6'h2a : ALU_OPRN = `ALU_OPRN_WIDTH'h09;		//sets the ALU operation code to slt
	    endcase
	    //assign inputs for the ALU srl and sll uses the shamt amount as opposed to the data in the second register file
	    ALU_OP1 = RF_DATA_R1;
	    ALU_OP2 = (funct === 6'h01||funct === 6'h02)?shamt:RF_DATA_R2;
	  end
	//beginning of I-Type Instructions, no need to do lui(no alu neccessary)
	6'h08:	//addi
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h01;
	   ALU_OP1 = RF_DATA_R1;
	   ALU_OP2 = SIGN_EXTEND;
	end
	6'h1d:	//multi
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h03;
	   ALU_OP1 = RF_DATA_R1;
	   ALU_OP2 = SIGN_EXTEND;
	end
	6'h0a:	//slti
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h09;
	   ALU_OP1 = RF_DATA_R1;
	   ALU_OP2 = SIGN_EXTEND;
	end
	6'h0c:	//andi
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h06;
	   ALU_OP1 = RF_DATA_R1;
	   ALU_OP2 = ZERO_EXTEND;
	end
	6'h0d:	//ori
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h07;
	   ALU_OP1 = RF_DATA_R1;
	   ALU_OP2 = ZERO_EXTEND;
	end
	6'h04, 6'h05:	//beq or bne, they use the same oprn and ops
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h01;
	   ALU_OP1 = PC_REG + 1;
	   ALU_OP2 = SIGN_EXTEND;
	end
	6'h23, 6'h2b:	//lw or sw, alu operation is the same, its assignment in `PROC_MEM that's different
	begin
	   ALU_OPRN = `ALU_OPRN_WIDTH'h01;
	   ALU_OP1 = RF_DATA_R1;
	   ALU_OP2 = SIGN_EXTEND;
	end
	//J-Type Instructions, no need to do jump, jal, or pop(alu ops handled directly in `PROC_MEM)
	6'h1b:	//push
	begin
	   RF_ADDR_R1 = 0;
	   RF_WRITE = 1'b0;
	   RF_READ = 1'b1;	//read what's in register file so that it can be written to memory later
	end
	
      endcase
    end
      `PROC_MEM : 
      begin
	   //set mem read and write signals initially to hold
	   MEM_READ = 1'b0;
	   MEM_WRITE = 1'b0;
	   case(opcode)
	     6'h1b: 			//push
	     begin
		MEM_ADDR = SP_REF;
		WR_TO_MEM = RF_DATA_R1;		//enables writing data to memory
		MEM_READ = 1'b0;
		MEM_WRITE = 1'b1;
		SP_REF = SP_REF - 1;
	     end
	     6'h1c:			//pop
	     begin
		SP_REF = SP_REF + 1;
		MEM_ADDR = SP_REF;
		MEM_READ = 1'b1;
		MEM_WRITE = 1'b0;
	     end
	     6'h23:			//lw
	     begin
		MEM_ADDR = ALU_RESULT;
		MEM_READ = 1'b1;
		MEM_WRITE = 1'b0;
	     end
	     6'h2b:			//sw
	     begin
		MEM_ADDR = ALU_RESULT;
		WR_TO_MEM = RF_DATA_R2;		//enables writing data to memory
		MEM_READ = 1'b0;
		MEM_WRITE = 1'b1;
	     end
	     default:			//sets the memory opertation to hold by default
	     begin
		MEM_READ = 1'b0;
	        MEM_WRITE = 1'b0;
	     end
	endcase
       end
      `PROC_WB : 
	begin
	   PC_REG = PC_REG + 1;
	   MEM_READ = 1'b0;
	   MEM_WRITE = 1'b0;
	   RF_READ = 1'b0;
	   RF_WRITE = 1'b0;
	   case(opcode)
	     6'b0:	//R-Type Instructions
	     begin
	      case(funct)
		6'h20, 6'h22, 6'h2c, 6'h24, 6'h25, 6'h27, 6'h2a, 6'h01, 6'h02:	//all execpt jr
		   begin
		      RF_DATA_W = ALU_RESULT;
		      RF_ADDR_W = rd;		     
		      RF_READ = 1'b0;
		      RF_WRITE = 1'b1;
		   end
		6'h08:	//jr
		   PC_REG = RF_DATA_R1;
	      endcase
	     end
			//I-Type 
	     6'h08, 6'h1d, 6'h0c, 6'h0d, 6'h0a:	//addi, multi, andi, ori, slti
		begin
		   RF_DATA_W = ALU_RESULT;
		   RF_ADDR_W = rt;
		   RF_READ = 1'b0;
		   RF_WRITE = 1'b1;
		end
	     6'h0f:	//lui
	     begin
		RF_ADDR_W = rt;
		RF_DATA_W = LUI;
		   
		RF_WRITE = 1'b1;
		RF_READ = 1'b0;
	     end
	     6'h04:	//beq, nothing gets written to rf's data/addr
	     begin
		if(RF_DATA_R1 === RF_DATA_R2)
		   PC_REG = ALU_RESULT;
             end
	     6'h05:	//bne, nothing gets written to rf's data/addr
	     begin
		if(RF_DATA_R1 !== RF_DATA_R2)
		   PC_REG = ALU_RESULT;
             end
	     6'h23:	//lw, no need for sw because nothing gets written to the rf's data/addr
	     begin
		RF_ADDR_W = rt;
		RF_DATA_W = MEM_DATA;
		RF_WRITE = 1'b1;
		RF_READ = 1'b0;
	     end
	     6'h1c:	//pop
	     begin
		RF_DATA_W = MEM_DATA;
		RF_ADDR_W = 0;
		RF_READ = 1'b0;
		RF_WRITE = 1'b1;
	     end
	     6'h02:	//jump
	     begin
		PC_REG = JUMP_ADDR;
	     end
	     6'h03:	//jal
	     begin
		RF_DATA_W = PC_REG;
		RF_ADDR_W = 31; 
		RF_READ = 1'b0;
		RF_WRITE = 1'b1;
		PC_REG = JUMP_ADDR;
	     end
	     
	   endcase
	   
	end

   endcase
//print_instruction(INST_REG);
end



//provided to us in the PDF Instructions 
task print_instruction;
input [`DATA_INDEX_LIMIT:0] inst;

//*from the CS147DV Instruction Set
reg [5:0] opcode;
reg [4:0] rs;
reg [4:0] rt;
reg [4:0] rd;
reg [4:0] shamt;
reg [5:0] funct;
reg [15:0] immediate;
reg [25:0] address;

begin
// parse the instruction
// R-type
{opcode, rs, rt, rd, shamt, funct} = inst;
// I-type
{opcode, rs, rt, immediate } = inst;
// J-type
{opcode, address} = inst;
$write("@ %6dns -> [0X%08h] ", $time, inst);

case(opcode)
// R-Type
6'h00 : begin
 case(funct)
 6'h20: $write("add r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h22: $write("sub r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h2c: $write("mul r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h24: $write("and r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h25: $write("or r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h27: $write("nor r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h2a: $write("slt r[%02d], r[%02d], r[%02d];", rs, rt, rd);
 6'h00: $write("sll r[%02d], %2d, r[%02d];", rs, shamt, rd);
 6'h02: $write("srl r[%02d], 0X%02h, r[%02d];", rs, shamt, rd);
 6'h08: $write("jr r[%02d];", rs);
 default: $write("");
endcase
 end

// I-type
6'h08 : $write("addi r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h1d : $write("muli r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h0c : $write("andi r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h0d : $write("ori r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h0f : $write("lui r[%02d], 0X%04h;", rt, immediate);
6'h0a : $write("slti r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h04 : $write("beq r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h05 : $write("bne r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h23 : $write("lw r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);
6'h2b : $write("sw r[%02d], r[%02d], 0X%04h;", rs, rt, immediate);

// J-Type
6'h02 : $write("jmp 0X%07h;", address);
6'h03 : $write("jal 0X%07h;", address);
6'h1b : $write("push;");
6'h1c : $write("pop;");
default: $write("");
endcase
$write("\n");
end

endtask

endmodule

//------------------------------------------------------------------------------------------
// Module: CONTROL_UNIT
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


reg [2:0] STATE;
reg [2:0] next_state;

// TBD - implement the state machine here

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