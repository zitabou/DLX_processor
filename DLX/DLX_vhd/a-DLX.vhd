library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity DLX is
    GENERIC(MEM_SIZE: integer:= 64;
    		INSTR_RAM_size: integer:= 48;
            WORD_size: integer:= 32;
            NREG: integer:= 32);
    PORT(CLK: IN std_logic;
         RST: IN std_logic;
         
         from_DRAM_data: IN std_logic_vector(WORD_size-1 downto 0);					--data coming from the DRAM
         IRAM_data: 	 IN std_logic_vector(WORD_size-1 downto 0);   				--data coming from the IRAM
         
         DRAM_addr: 	 OUT std_logic_vector(log2(MEM_SIZE*4)- 1 downto 0);		--DRAM address where to read/write
         IRAM_addr: 	 OUT std_logic_vector(log2(INSTR_RAM_size*4) - 1 downto 0);	--DRAM address where to read from
         to_DRAM_data: 	 OUT std_logic_vector(WORD_size-1 downto 0);				--data sent to the DRAM to be written in it
         
         DRAM_EN:		 OUT std_logic;												--enable tsignal for the DRAM
         DRAM_LnS:		 OUT std_logic;												--signal indicating to load(1) from the DRAM or to store(0) data to the DRAM
         MMU_out:		 OUT std_logic_vector(1 downto 0)							--DLX MMU provides the correct signals to the byte addressable DRAM to manage 32 bit data
              
         );
         
    
end DLX;

architecture Structural of DLX is


component hardwired_CU is
port(
    clk:        IN std_logic;
    rst:        IN std_logic;
    
    opcode:     IN std_logic_vector(OP_CODE_SIZE-1 downto 0);		-- bits that identify the type of instruction (register, immediate, floaating-point)
    func:       IN std_logic_vector(FUNC_SIZE-1 downto 0);			-- bits that identify the operation to be executed in case of R-type instructions
    
    --stage1(DEC)
    RF1:        OUT std_logic;  -- enable read from port_1 of RF        MSB of CW
    RF2:        OUT std_logic;  -- enable read from port_2 of RF
    EN1:        OUT std_logic;  -- enable RF
    --stage2(EXE)
    S1:         OUT std_logic;	-- mux_1 selection signal (between IMM(0) and operand_1(1))
    S2:         OUT std_logic;	-- mux_2 selection signal (between IMM(1) and operand_2(0))
    ALU3:       OUT std_logic;	-- alu operation selection bit 3
    ALU2:       OUT std_logic;	-- alu operation selection bit 2
    ALU1:       OUT std_logic;	-- alu operation selection bit 1
    ALU0:       OUT std_logic;	-- alu operation selection bit 0
    SN:       	OUT std_logic;	-- bit that indicates that the alu functions must be executed with signed operands, if zero then for unsigned ones
    --stage3(MEM)
    LnS:        OUT std_logic;	-- Load notStore from main memory
    Wrd:		OUT std_logic;	-- load/store 	word
    BHU1:       OUT std_logic;	-- load 		signed/unsigned 
    BHU0:       OUT std_logic;  -- load/store 	byte/halfword
    EN3:		OUT std_logic;	-- enables memory 
    --stage4(WB)
    S3:         OUT std_logic;	-- write back mux selection signal
    WF1:        OUT std_logic;  -- enable write for RF

    --others
    Ld:         OUT std_logic   -- THIS IS EXTRA and indicates that the instr in ALU is a load. Used for the hazard detection. look in hardwired_CU.vhd for more details
);
end component;


component DataPath is
    GENERIC(MEM_SIZE: integer:= DRAM_size;
         WORD_size: integer:= data_size;
         NREG: integer:= num_reg);
    PORT(CLK:   IN std_logic;	
		RST:   	IN std_logic;
	
	--control signals provided by the CU. They are explained in the hardwired_CU.vhd
        --stage1
        RF1:   	IN std_logic;
        RF2:   	IN std_logic;
        EN1:   	IN std_logic;    
        --stage2
        S1:    	IN std_logic;
        S2:    	IN std_logic;
        ALU3:  	IN std_logic;
        ALU2: 	IN std_logic;
        ALU1:  	IN std_logic;
        ALU0:  	IN std_logic;
        SN:   	IN std_logic;
        --stage3
        LnS:   	IN std_logic;
    	BHU1:  	IN std_logic;
    	BHU0:  	IN std_logic;
    	Wrd:	IN std_logic;
    	EN3:	IN std_logic;
        --stage4
        S3:    	IN std_logic;
        WF1:   	IN std_logic;

	 	Ld:    	IN std_logic;
	 	
	 	instr:		IN std_logic_vector(IR_size-1 downto 0);				-- instruction read from the IRAM
	 	IRAM_addr: 	OUT std_logic_vector(31 downto 0);						-- address from where to read the instruction in the IRAM 	
	 	--DRAM
	 	DRAM_data_out: 	IN std_logic_vector(WORD_size-1 downto 0);			-- data coming from the DRAM
	 	MMU_out	: 		OUT std_logic_vector(1 downto 0);					-- signals to control the byte addressable DRAM
	 	DRAM_addr: 		OUT std_logic_vector(log2(DRAM_size*4)-1 downto 0);	-- address to access in DRAM 
	 	DRAM_data_in: 	OUT std_logic_vector(WORD_size-1 downto 0);			-- data sent to the DRAM
	 	
     	opcode: 	OUT std_logic_vector(OP_CODE_SIZE-1 downto 0);			-- opcode towards CU
     	func:   	OUT std_logic_vector(FUNC_SIZE-1 downto 0);				-- func towards CU
        OVF: 		OUT std_logic											-- overflow signal that may be used as an exception trigger
        );
end component;



signal s_CLK, s_RST, s_RF1, s_RF2, s_EN1, s_Ld, s_S1, s_S2, s_ALU3, s_ALU2, s_ALU1, s_ALU0, s_SN, s_LnS, s_BHU1, s_BHU0, s_Wrd, s_EN3, s_S3, s_WF1: std_logic; 
signal s_opcode: 	 std_logic_vector(OP_CODE_SIZE-1 downto 0);
signal s_func:   	 std_logic_vector(FUNC_SIZE-1 downto 0);
signal s_instr_addr: std_logic_vector(PC_size-1 downto 0);
signal ovf: 		 std_logic;


begin

-- instanciation of the control unit and defining the signals that will be used to control the datapath
control_unit: hardwired_CU
port map(opcode=>s_opcode, func=>s_func,
         CLK=>	CLK,
         RST=>	RST,
         RF1=>	s_RF1,
         RF2=>	s_RF2,
         EN1=>	s_EN1,
         S1=>	s_S1,
         S2=>	s_S2,
         ALU3=>	s_ALU3,
         ALU2=>	s_ALU2,
         ALU1=>	s_ALU1,
         ALU0=>	s_ALU0,
         SN=>	s_SN,
	 	 LnS=>	s_LnS,
	 	 Wrd=>	s_Wrd,
	 	 BHU1=>	s_BHU1,
    	 BHU0=>	s_BHU0,
         EN3=>	s_EN3,
         S3=>	s_S3,
         WF1=>	s_WF1,
         Ld=>	s_Ld
);

-- instancieation of the datapath and providing as inputs the signals generated from the control unit.
-- signals related to the memories are directly connected to inputs and outputs of the DLX
data_path: DataPath
generic map(MEM_SIZE=>MEM_SIZE, WORD_size=>WORD_size, NREG=>NREG)
port map(
        CLK	=>CLK,
        RST	=>RST,
        RF1	=>s_RF1,
        RF2	=>s_RF2,
        EN1	=>s_EN1,
        S1	=>s_S1,
        S2	=>s_S2,
        ALU3	=>s_ALU3,
        ALU2	=>s_ALU2,
        ALU1	=>s_ALU1,
        ALU0	=>s_ALU0,
        SN		=>s_SN,
        LnS		=>s_LnS,
	 	BHU1	=>s_BHU1,
    	BHU0	=>s_BHU0,
    	Wrd		=>s_Wrd,
        EN3		=>s_EN3,
        S3		=>s_S3,
        WF1		=>s_WF1,
      	Ld		=>s_Ld,
	 	instr	=>IRAM_data,
	 	
	 	DRAM_data_out	=>from_DRAM_data,
	 	MMU_out			=>MMU_out,
	 	DRAM_addr 		=>DRAM_addr ,
	 	DRAM_data_in	=>to_DRAM_data,
	 	
	 	IRAM_addr	=>s_instr_addr,
	 	opcode		=>s_opcode,
	 	func		=>s_func,
	 	ovf			=>ovf
);

-- definition of signals that will be passed to outide the DLX but generated inside it
IRAM_addr 		<= s_instr_addr(log2(INSTR_RAM_size*4)-1 downto 0);      			-- the instrucion address is the PC(32 bits). We select only the part needed to access the IRAM
DRAM_EN			<= s_EN3;															-- enable DRAM
DRAM_LnS		<= s_LnS;															-- load notStore for the DRAM

end Structural;
