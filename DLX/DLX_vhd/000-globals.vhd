library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Package declaration. Contains all the constans that are used in the project
package DLX_constants is


-- Constants used for files
   		constant IRAM_PATH  : string := "iram.mem";		
   		constant DRAM_PATH  : string := "dram.mem";
   		constant DRAM_size  : integer := 128;			-- size IN WORDS of the byte addressable main memory accessed in MEM stage
   		constant IRAM_size  : integer := 80;			-- size IN WORDS of the byte addressable instruction memory accessed in FETCH stage
   		--constant DRAM_size_byte  : integer := log2(DRAM_size*4);			-- size IN WORDS of the byte addressable main memory accessed in MEM stage
   		--constant IRAM_size_byte  : integer := log2(IRAM_size*4);			-- size IN WORDS of the byte addressable instruction memory accessed in FETCH stage




-- costants used for the *ALU* functions. these are used for the selection of the operation
		constant FUN_BITS	: INTEGER:=4;
		constant ADDS		: std_logic_vector:= "0000";	--addition
		constant ADDU		: std_logic_vector:= "0000";	--addition unsigned (these bits should be the same the SN bit defines the unsignedness)
		constant SUBS		: std_logic_vector:= "0001";	--subtraction
		constant SUBU		: std_logic_vector:= "0001";	--subtraction unsigned (these bits should be the same the SN bit defines the unsignedness)
		constant BITAND		: std_logic_vector:= "0010";	--bit wise logic AND
		constant BITNAND    : std_logic_vector:= "0010";	--bit wise logic NAND
		constant BITOR		: std_logic_vector:= "0011";	--bit wise logic OR
		constant BITNOR		: std_logic_vector:= "0011";	--bit wise logic NOR
		constant BITXOR		: std_logic_vector:= "0100";	--bit wise logic XOR
		constant BITXNOR	: std_logic_vector:= "0100";	--bit wise logic XNOR
		constant LSL		: std_logic_vector:= "0101";	--logic shift left (barrel shifter)
		constant LSR		: std_logic_vector:= "0110";	--logic shift right (barrel shifter)
		constant ASR    	: std_logic_vector:= "0111";	--arithmetic shift right (barrel shifter)
		constant EQ    		: std_logic_vector:= "1000";	--check if opernad_1 is equal to operand_2
		constant NE    		: std_logic_vector:= "1001";	--check if opernad_1 is not equal to operand_2
		constant LE    		: std_logic_vector:= "1010";	--check if opernad_1 is less or equal to operand_2
		constant LEU   		: std_logic_vector:= "1010";	--check if opernad_1 is less or equal to operand_2 unsigned (these bits should be the same the SN bit defines the unsignedness)
		constant GE    		: std_logic_vector:= "1011";	--check if opernad_1 is greater or equal to operand_2
		constant GEU   		: std_logic_vector:= "1011";	--check if opernad_1 is greater or equal to operand_2 unsigned (these bits should be the same the SN bit defines the unsignedness)
		constant GT	    	: std_logic_vector:= "1100";	--check if opernad_1 is greater than operand_2
		constant GTU    	: std_logic_vector:= "1100";	--check if opernad_1 is greater than operand_2 unsigned (these bits should be the same the SN bit defines the unsignedness)
		constant LT	    	: std_logic_vector:= "1101";	--check if opernad_1 is less than operand_2
		constant LTU    	: std_logic_vector:= "1101";	--check if opernad_1 is less than operand_2 unsigned (these bits should be the same the SN bit defines the unsignedness)
		constant RTR    	: std_logic_vector:= "1110";	--rotate right
		constant MUL	    : std_logic_vector:= "1111";	--multiplication	


-- constants used to define the characteristics of the datapath components
		constant PC_size	: integer := 32;    	
    	constant data_size 	: integer := 32;	-- size of the data(word)
    	constant num_reg 	: integer := 32;	-- number of (word)registers of the register file

	
	

-- Constants that define the size of the Control Unit signals and memories.
		constant IR_SIZE        : integer :=  32;     	-- size in bits of the instruction
    	constant OP_CODE_SIZE   : integer :=  6;      	-- size in bits of the opcode field in the instruction
    	constant FUNC_SIZE      : integer :=  11;     	-- size in bits of the function field in the instruction
		constant imm_size       : integer :=  16;		-- size in bits of the immediate field in the instruction
    	constant uCODE_LUT_SIZE : integer :=  62;     	-- size in elements of Microcode Memory Size (contains the control words) (45->I, 1->R, 1->FP, 15->unused) 	
    	constant CW_SIZE        : integer :=  17;     	-- size in bits of the Control Word);
		


		constant NOP_instr	: std_logic_vector(31 downto 0) := x"54000000";
-- R-Type instruction -> OPCODE field
    	constant RTYPE      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";	-- All R-type instruction are caracterized by the same opcode
-- R-Type instruction -> FUNC field                                                        
    	constant NOP_FUN    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";   --
    	constant R_NAND     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";   -- NAND RS1,RS2,RD
    	constant R_NOR      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";   -- NOR RS1,RS2,RD
    	constant R_XNOR     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";   -- XNOR RS1,RS2,RD
    	constant R_SLL      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";   -- SLL RS1,RS2,RD
    	constant R_SRL      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";   -- SRL RS1,RS2,RD
    	constant R_SRA      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";   -- SRA RS1,RS2,RD
    	constant R_ROR      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";	-- ROR RS1,RS2,RD
    	constant R_MUL      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011111";	-- MUL RS1,RS2,RD
    	constant R_ADD      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100000";   -- ADD RS1,RS2,RD
    	constant R_ADDU     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100001";
    	constant R_SUB      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100010";   -- SUB RS1,RS2,RD
    	constant R_SUBU     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100011";
    	constant R_AND      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100100";   -- AND RS1,RS2,RD
    	constant R_OR       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100101";   -- OR RS1,RS2,RD
    	constant R_XOR      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100110";   -- XOR RS1,RS2,RD
    	constant R_SEQ      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101000";
    	constant R_SNE      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101001";
   		constant R_SLT      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010";
    	constant R_SGT      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101011";
    	constant R_SLE      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101100";
    	constant R_SGE      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";  
    	constant R_MOVI2S   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110000";
    	constant R_MOVI2I   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110001";
    	constant R_MOVF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110010";
    	constant R_MOVD     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110011";
    	constant R_MOVFP2I  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110100";
    	constant R_MOVI2FP  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110101";
   		constant R_MOVI2T   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110110";
   		constant R_MOVT2I   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110111";
   		constant R_SLTU     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111010";
   		constant R_SGTU     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111011";
   		constant R_SLEU     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111100";
   		constant R_SGEU   	: std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111101";
   		
    


-- FP-Type instruction -> OPCODE field
    	constant FP_TYPE      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";	-- All R-type instruction are caracterized by the same opcode         
-- FP-Type instruction -> FUNC field                                                       
    	constant FP_ADDF    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    
    	constant FP_SUBF    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";   
    	constant FP_MULTF   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";    
    	constant FP_DIVF    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";    
    	constant FP_ADDD    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";    
    	constant FP_SUBD    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";
    	constant FP_MULTD   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";  
    	constant FP_DIVD    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";
    	constant FP_CVTF2D  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";   
    	constant FP_CVTFI   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001001";    
    	constant FP_CVTD2F  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001010";    
    	constant FP_CVTDI   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001011";
    	constant FP_CVTI2F  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001100";
    	constant FP_CVTI2D  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001101";
    	constant FP_MULT    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001110";
    	constant FP_DIV     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001111";
    	constant FP_EQF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010000";  
    	constant FP_NEF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010001";
    	constant FP_LTF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010010";
    	constant FP_GTF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010011";
    	constant FP_LEF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010100";
    	constant FP_GEF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010101";
    	constant FP_MULTU   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010110";
    	constant FP_DIVU    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010111";
    	constant FP_EQD     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011000";
    	constant FP_NED     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011001";
    	constant FP_LTD     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011010";
    	constant FP_GTD     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011011";
    	constant FP_LED     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011100";
    	constant FP_GED     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011101";



-- I-Type instruction -> OPCODE field 
    	constant I_J        : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";
    	constant I_JAL      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";   
    	constant I_BEQZ     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";
    	constant I_BNEZ     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";
    	constant I_BFPT     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
    	constant I_BFPF     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
    	constant I_ADDI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000"; -- ADDI1 RS1,RD,IMM   	( RD = RS + IMM
    	constant I_ADDUI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";
    	constant I_SUBI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010"; -- SUBI1 RS1,RD,IMM   	( RD = RS - IMM
    	constant I_SUBUI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";
    	constant I_ANDI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100"; -- ANDI1 RS1,RD,IMM   	( RD = RS and IMM
    	constant I_ORI      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101"; -- ORI1  RS1,RD,IMM   	( RD = RS or IMM
    	constant I_XORI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";	-- XORI1  RS1,RD,IMM  	( RD = RS xor IMM 
    	constant I_LHI      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";
    	constant I_RFE      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010000"; 
    	constant I_TRAP     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010001";
    	constant I_JR       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010010";
    	constant I_JALR     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010011";
    	constant I_SLLI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010100";	-- SLLI RS,RD,IMM     	( RD = RS<<[IMM]
    	constant NOP        : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101"; 
    	constant I_SRLI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010110";	-- SRLI RS,RD,IMM	( RD = RS>>[IMM]
    	constant I_SRAI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010111";	-- SRAI RS,RD,IMM	( RD = RS>>[IMM], keeping sign
    	constant I_SEQI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011000";
    	constant I_SNEI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011001";
    	constant I_SLTI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011010"; 
    	constant I_SGTI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011011";
    	constant I_SLEI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011100"; 
    	constant I_SGEI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011101";  
    	constant I_LB       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";	-- LB RS,RD,IMM		( RD = ( sign extended ) M[RS + IMM]
    	constant I_LH       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";	-- LH RS,RD,IMM		( RD = ( sign extended ) M[RS + IMM]  
    	constant I_LW       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100011"; -- LW RS,RD,IMM  	( RD = M[RS + IMM]
    	constant I_LBU      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100100";	-- LBU RS,RD,IMM	( RD = ( zero extended ) M[RS + IMM]
    	constant I_LHU      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100101";	-- LHU RS,RD,IMM	( RD = ( zero extended ) M[RS + IMM]
    	constant I_LF       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100110";
    	constant I_LD       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100111";
    	constant I_SB       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101000";	-- SB RS,RD,IMM		( M[ RS + IMM] <--8 RD  _24 ..31
    	constant I_SH       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101001"; -- SH RS,RD,IMM		( M[ RS + IMM] <--16 RD _16 ..31
    	constant I_SW       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101011"; -- SW RS,RD,IMM  	( M[ RS + IMM] = RD
    	constant I_SF       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101110";
    	constant I_SD       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101111";
    	constant I_NANDI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110000"; -- NANDI1  RS1,RD,IMM   	( RD = RS nand IMM
    	constant I_NORI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110001"; -- NORI1   RS1,RD,IMM   	( RD = RS nor IMM
    	constant I_XNORI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110010";	-- XNORI1  RS1,RD,IMM  		( RD = RS xnor IMM
    	constant I_MUL	    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110101"; -- MUL RS1,RD,IMM
    	constant I_ROR	    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110110"; -- ROR RS1,RD,IMM
    	constant I_ITLB     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111000";
    	constant I_SLTUI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111010";
    	constant I_SGTUI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111011";
    	constant I_SLEUI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111100";
    	constant I_SGEUI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111101";
-- I-Types do not have function field  

end DLX_constants;



-- Package declaration. Contains any non standard function used in the project
package DLX_functions is

    function Log2 (x:integer) return integer ;
    
end package DLX_functions;

-- Package body
package body DLX_functions is
   
    -------------------------------------------------------------------------------
    -- Log2
    -------------------------------------------------------------------------------
    function Log2 (x:integer) return integer is
	    variable temp : integer := x ;
		variable n : integer := 0 ;
		begin
		    while temp > 1 loop
			    temp := temp /2;
				n := n + 1;
			end loop;

			if x > 2**n then
				return (n + 1);
			else
				return (n);
			end if;
	end function;
	
end DLX_functions;

-- Package declaration
package DLX_types is

end package DLX_types;

