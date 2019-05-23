//Register File Tester
//derived from the MEM_64MB_tb tester
`include "prj_definition.v"
module REGISTER_FILE_TB;

//some inital variables, inputs and outputs for the testbench
// Storage list
reg [`ADDRESS_INDEX_LIMIT:0] ADDR_R1;
reg [`ADDRESS_INDEX_LIMIT:0] ADDR_R2;
reg [`ADDRESS_INDEX_LIMIT:0] ADDR_W;

// reset
reg READ, WRITE, RST;
// data registers
reg [`DATA_INDEX_LIMIT:0] REG_DATA_R1;
reg [`DATA_INDEX_LIMIT:0] REG_DATA_R2;
reg [`DATA_INDEX_LIMIT:0] REG_DATA_W;

integer i; // index for memory operation
integer value; //a random value to use to store into the data registers, can be used to test data range as well
integer no_of_test, no_of_pass;

// wire lists for CLK and the DATA comming out of the register file
wire  CLK;
wire [`DATA_INDEX_LIMIT:0] DATA_W;
wire [`DATA_INDEX_LIMIT:0] DATA_R1;
wire [`DATA_INDEX_LIMIT:0] DATA_R2;

assign DATA_W = ((READ===1'b0)&&(WRITE===1'b1))?REG_DATA_W:{`DATA_WIDTH{1'bz} };
CLK_GENERATOR clock_gen(.CLK(CLK));

REGISTER_FILE_32x32 register_file_inst(.DATA_R1(DATA_R1), .DATA_R2(DATA_R2), .ADDR_R1(ADDR_R1), .ADDR_R2(ADDR_R2), 
                            .DATA_W(DATA_W), .ADDR_W(ADDR_W), .READ(READ), .WRITE(WRITE), .CLK(CLK), .RST(RST));

initial
begin
RST = 1'b0;
READ = 1'b0;
WRITE = 1'b0;
REG_DATA_W = {`DATA_WIDTH{1'b0}};
no_of_test = 0;
no_of_pass = 0;
value = 100;	//modify range here, I picked 100 to test big numbers.

#10	RST = 1'b1;

	//write to the registers so that they have something in them, in this case they're ints from value-31+value
	for(i = value; i < `NUM_OF_REG + value; i = i + 1)
	begin
#10	   REG_DATA_W = i;
	   READ = 1'b0;
	   WRITE = 1'b1;
#10	   ADDR_W = i;
	end
	
	//test reading from the registers
	READ = 1'b0;
	WRITE = 1'b0;
	no_of_test = no_of_test + 1;
#10	if(DATA_R1 !== {`DATA_WIDTH{1'bz}} || DATA_R2 !== {`DATA_WIDTH{1'bz}} )
	   $write("[TEST] Read %1b, Write %1b, expecting 32'hzzzzzzzz, got %8h [FAILED]\n", READ, WRITE, DATA_W);
	else
	   no_of_pass = no_of_pass + 1;

	//test writing from the registers
	for(i = value; i < `REG_INDEX_LIMIT + value; i = i + 2)
	begin
	   READ = 1'b1;		//set to read so that you can read what's been written
	   WRITE = 1'b0;
	   ADDR_R1 = i;
	   ADDR_R2 = i + 1;
	   no_of_test = no_of_test + 1;
#10	   if(DATA_R1 !== i || DATA_R2 !== i+1)
	      $write("[TEST] Read %1b, Write %1b, expecting %8h, %8h  got %8h, %8h [FAILED]\n", READ, WRITE, i, i+1, DATA_R1, DATA_R2);
	   else
	      no_of_pass = no_of_pass + 1;
	end

    //hold the read and write signals
#20 READ = 1'b0;
    WRITE = 1'b0;
    $write("\n");
    $write("\tTotal number of tests %d\n", no_of_test);
    $write("\tTotal number of pass  %d\n", no_of_pass);
    $write("\n");
    $stop;

end
endmodule
