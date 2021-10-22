library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


entity DataPath is
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
end DataPath;














architecture Structural of DataPath is

component MUX21_GENERIC is									-- multiplxer used to select between NPC and jump NPC
  GENERIC(NBIT: integer:= 4);     
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: in  std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

component FETCH is							
    port(
        PC	   		: IN std_logic_vector(PC_size-1 downto 0);		-- PC read from the PC pipeline register 
        hazard_PC  	: IN std_logic_vector(PC_size-1 downto 0);		-- PC given by the stall_detection_Unit in case there is the need to re-fetch the instr. currently in DEC 
        PC_sel	   	: IN std_logic;									-- Selection signal to select between the PC and the hazard_PC
        
        IRAM_addr  	: OUT std_logic_vector(IR_SIZE-1 downto 0);		-- address that will be used to fetch the instr from the IRAM (external to the DP)
        NPC   	   	: OUT std_logic_vector(PC_size-1 downto 0));	-- The NPC is passed to the IF/DEC pipeline register to be used in case of jumps
end component;


component DEC is
    port(
		instr:     IN std_logic_vector(IR_SIZE-1 downto 0);			-- The instruction just fetched
     	RST:       IN std_logic;									-- The reset signal, used to reset all the components in DEC stage like the RF    
     	RFdata_in: IN std_logic_vector(data_size-1 downto 0); 		-- input data to the Register file
     	RFWA:      IN std_logic_vector(Log2(num_reg)-1 downto 0);	-- write address for the Register file
	
	--Stall detection     	
	    NPC_in:	   IN std_logic_vector(PC_size-1 downto 0);			-- The NPC taken from the IF/DEC pipeline register			
     	EXE_RD:    IN std_logic_vector(Log2(num_reg)-1 downto 0);	-- destination register read from the DEC/EXE pipeline register
     	Ld:        IN std_logic;									-- signal that tells if there is a load instruction in the EXE stage
     	ALU_regout:IN  std_logic_vector(data_size-1 downto 0);		-- ALUout register read from EXE/MEM pipeline register
     	MEM_RD:    IN std_logic_vector(Log2(num_reg)-1 downto 0);	-- destination register read from the EXE/MEM pipeline register
	 	WB_RD:     IN std_logic_vector(Log2(num_reg)-1 downto 0);	-- destination register read from the MEM/WB pipeline register
	 --mul management
		RD_inmul:		IN std_logic_vector(log2(num_reg)-1 downto 0);
		flag_structHzd:	IN std_logic;
     	flag_ismul:		IN std_logic;
     	
	--controls
     	RF1:       IN std_logic;					-- control signal from the CU
     	RF2:       IN std_logic;					-- control signal from the CU
     	WF1:       IN std_logic;					-- control signal from the CU
     	EN1:       IN std_logic;					-- control signal from the CU
     
     	opcode:    OUT std_logic_vector(OP_CODE_SIZE-1 downto 0);	-- opcode extracted from the istruction and provided to the CU
     	func:      OUT std_logic_vector(FUNC_SIZE-1 downto 0);		-- func extracted from the istruction and provided to the CU
     	IMM:       OUT std_logic_vector(data_size-1 downto 0);		-- IMM value extracted from the istruction and passed to the DEC/EXE pipeline register
     	RA:        OUT std_logic_vector(data_size-1 downto 0);		-- first value loaded from the RF and passed to the DEC/EXE pipeline register
     	RB:        OUT std_logic_vector(data_size-1 downto 0);		-- second value loaded from the RF and passed to the DEC/EXE pipeline register
     	RSA:       OUT std_logic_vector(Log2(num_reg)-1 downto 0);	-- source register extracted from the istruction and passed to the DEC/EXE pipeline register
     	RSB:       OUT std_logic_vector(Log2(num_reg)-1 downto 0);	-- source register extracted from the istruction and passed to the DEC/EXE pipeline register
     	RD:        OUT std_logic_vector(Log2(num_reg)-1 downto 0);	-- destination register extracted from the istruction and passed to the DEC/EXE pipeline register
     	stall_NPC: OUT std_logic_vector(PC_size-1 downto 0);		-- Value of NPC obtained from the Stall detection logic.
        PC_sel:    OUT std_logic; 									-- selection signal towards the mux in the FETCH stage that selects between the stall NPC and the pipeline register PC
        dec_flag:  OUT std_logic;									-- any time we have a jump instruction, we rise this flag to 1
	 	NPC_jump:  OUT std_logic_vector(PC_size-1 downto 0)); 		-- when we have a jump, we use it as next PC to be fetched
end component;

component EXE is
    PORT(
    	CLK:	IN std_logic;
    	RST:	IN std_logic;
    	
        IMM:  	IN std_logic_vector(data_size-1 downto 0);			-- immediate value taken from DEC/EXE pipeline register
        RA:   	IN std_logic_vector(data_size-1 downto 0);			-- operand_1 value taken from DEC/EXE pipeline register
        RB:   	IN std_logic_vector(data_size-1 downto 0);			-- operand_2 value taken from DEC/EXE pipeline register
        WA:   	IN std_logic_vector(log2(num_reg)-1 downto 0);		-- destination address taken from DEC/EXE pipeline register

        -- FORWARDING
        RSA:        IN std_logic_vector(log2(num_reg)-1 downto 0);	-- source of operand_1 taken from DEC/EXE pipeline register
        RSB:        IN std_logic_vector(log2(num_reg)-1 downto 0);  -- source of operand_2 taken from DEC/EXE pipeline register
        ALU_outmem: IN std_logic_vector(data_size-1 downto 0);		-- value from the EXE/MEM pipeline register containing the ALU value currently in MEM
        WB_out:     IN std_logic_vector(data_size-1 downto 0); 		-- value from the MEM/WB pipeline register containing the ALU value currently in WB
        MEM_RD:     IN std_logic_vector(log2(num_reg)-1 downto 0);	-- value from the EXE/MEM pipeline register containing destination addr. currently in MEM
        WB_RD:      IN std_logic_vector(log2(num_reg)-1 downto 0);	-- value from the EXE/MEM pipeline register containing destination addr. currently in WB
        LD_EN:      IN std_logic;									-- signal that tells if there is a load instruction in MEM stage
		WB_EN:      IN std_logic;        							-- signal that tells if the data in wb must be written in MEM (indicates a load instruction in WB stage)
		
        --control                      
        S1:    	IN std_logic;						-- control signal from the CU
        S2:    	IN std_logic; 						-- control signal from the CU
        ALU3:  	IN std_logic;						-- control signal from the CU
        ALU2:  	IN std_logic;						-- control signal from the CU
        ALU1:  	IN std_logic;						-- control signal from the CU
        ALU0:  	IN std_logic;						-- control signal from the CU
        SN:   	IN std_logic;						-- control signal from the CU
        
        --mul management
		RD_inmul:	OUT std_logic_vector(log2(num_reg)-1 downto 0);
		flag_structHzd:	OUT std_logic;
		flag_ismul:		OUT std_logic;
        
        OVF: 	OUT std_logic;										-- overflow signal set by the ALU operation
        output: OUT std_logic_vector(data_size-1 downto 0);			-- result from the ALU operation 
        ME: 	OUT std_logic_vector(data_size-1 downto 0);			-- value to be stored in case of a store instruction
        WAout: 	OUT std_logic_vector(log2(num_reg)-1 downto 0));	-- destination address to be passed to the next stage
end component;

component MEM is
	generic(MEMORY_size: integer:=512);
    Port(
        CLK:    IN std_logic;						
        RST:    IN std_logic;
        ALUout: IN std_logic_vector(data_size-1 downto 0);					-- result of the EXE stage
        MEout:  IN std_logic_vector(data_size-1 downto 0);					-- value to be written in memory in case of a store instruction
        RDin:  	IN std_logic_vector(Log2(num_reg)-1 downto 0);				-- destination address, in register file, taken from the EXE/MEM pipeline register
        DRAM_data_out: IN std_logic_vector(data_size-1 downto 0);
        
        --control
		LnS:    IN std_logic;						-- control signal from the CU
		Wrd:	IN std_logic;						-- control signal from the CU
    	BHU1:   IN std_logic;						-- control signal from the CU
    	BHU0:   IN std_logic; 						-- control signal from the CU
        EN3:    IN std_logic;						-- control signal from the CU
        
        --to DRAM memory
        DRAM_addr: 		OUT std_logic_vector(log2(MEMORY_SIZE*4)- 1 downto 0);	-- address in which to access the DRAM
        DRAM_data_in:  	OUT std_logic_vector(data_size-1 downto 0);				-- value to be written in DRAM
        
        MMU_out: OUT std_logic_vector(1 downto 0);								-- control signals for the byte addressable DRAM
        output:  OUT std_logic_vector(data_size-1 downto 0);					-- data read from the memory
        alu_out: OUT std_logic_vector(data_size-1 downto 0);					-- the result of the previous stage, in case of an non load/store instruction
        RDout:   OUT std_logic_vector(Log2(num_reg)-1 downto 0));				-- destination address passed to the MEM/WB pipeline register
end component;

component WB is
    PORT(
	mem_out	: IN std_logic_vector(data_size-1 downto 0);			-- output from the memory of MEM stage
        alu_out	: IN std_logic_vector(data_size-1 downto 0);		-- alu result passed from MEM stage
         
        --control
        S3	: IN std_logic;							-- control signal from the CU that selects between the two input signals
          
        output	: OUT std_logic_vector(data_size-1 downto 0));   	-- output of the mux
end component;







----------------------------
--==========================
----------------------------



--pipeline signals to connect components to the pipeline registers.
-- signals are used to connect stages outputs to pipeline registers and pipeline registers to stages
--FETCH
signal PC_muxout:       std_logic_vector(PC_size-1 downto 0);			-- output of the mux which selects between NPC and jump NPC
signal PC_regout:       std_logic_vector(PC_size-1 downto 0);   		-- output of the PC register              
signal imem_fetchout:   std_logic_vector(IR_SIZE-1 downto 0);			-- output of the instruction memory
signal NPC_fetchout:    std_logic_vector(PC_size-1 downto 0);			-- output of the computation for the NPC (PC+4)
signal NOP_MUX_OUT:     std_logic_vector(IR_size-1 downto 0);

--DEC
signal NPC_regout:      std_logic_vector(PC_size-1 downto 0);  			-- output of the NPC reg in IF/DEC pipeline register
signal IR_regout:       std_logic_vector(IR_SIZE-1 downto 0);    		-- output of the IR reg in IF/DEC pipeline register
signal RA_decout:       std_logic_vector(data_size-1 downto 0);   		-- the value read from the RF at address RSA to be passed from DEC to EXE
signal RB_decout:       std_logic_vector(data_size-1 downto 0);			-- the value read from the RF at address RSB to be passed from DEC to EXE
signal RSA_decout:      std_logic_vector(Log2(num_reg)-1 downto 0);   	-- the address RSA to be passed from DEC to EXE
signal RSB_decout:      std_logic_vector(Log2(num_reg)-1 downto 0);   	-- the address RSB to be passed from DEC to EXE
signal RD_decout:       std_logic_vector(Log2(num_reg)-1 downto 0);  	-- the destination address to be passed from DEC to EXE
signal IMM_decout:      std_logic_vector(data_size-1 downto 0);			-- the immediate value to be passed from DEC to EXE
signal s_NPC_jump:  	std_logic_vector(PC_size-1 downto 0);
signal flag_signal:  	std_logic;
--DEC->FETCH
signal hazard_NPC:	std_logic_vector(PC_size-1 downto 0);				-- NPC output of the hazard detection logic to be passed from DEC to FETCH
signal hazard_NPC_sel:  std_logic;										-- selection signal output of the hazard detection logic to be passed from DEC to FETCH and there select between the hazard PC and the normally computed PC      

--EXE
signal IMM_regout:      std_logic_vector(data_size-1 downto 0);   		-- output of the IMM reg in DEC/EXE pipeline register
signal RA_regout:       std_logic_vector(data_size-1 downto 0);   		-- output of the operand_1 value reg in DEC/EXE pipeline register
signal RB_regout:       std_logic_vector(data_size-1 downto 0);			-- output of the operand_2 value reg in DEC/EXE pipeline register
signal RSA_regout:      std_logic_vector(log2(num_reg)-1 downto 0);   	-- output of the operand_1 address reg in DEC/EXE pipeline register
signal RSB_regout:      std_logic_vector(log2(num_reg)-1 downto 0);   	-- output of the operand_2 address reg in DEC/EXE pipeline register
signal RD_regoutexe:    std_logic_vector(log2(num_reg)-1 downto 0); 	-- output of the destination address reg in DEC/EXE pipeline register

signal ALU_exeout:      std_logic_vector(data_size-1 downto 0);			-- result of the ALU
signal ME_exeout:       std_logic_vector(data_size-1 downto 0);			-- data value to be passed to the MEM stage (relevant in case of a store instruction)
signal RD_exeout:       std_logic_vector(log2(num_reg)-1 downto 0);		-- destination address to be passed from EXE to MEM

signal s_ovf:			std_logic;
--mul hazard
signal s_RD_inmul:		std_logic_vector(log2(num_reg)-1 downto 0);
signal s_flag_structHzd:std_logic;
signal s_flag_ismul:	std_logic;


--MEM
signal ALU_regout:      std_logic_vector(data_size-1 downto 0);  		-- output of the ALUout reg in EXE/MEM pipeline register
signal ME_regout:       std_logic_vector(data_size-1 downto 0);  		-- output of the data_to_store reg in EXE/MEM pipeline register
signal RD_regoutmem:    std_logic_vector(log2(num_reg)-1 downto 0);		-- output of the destination address reg in EXE/MEM pipeline register

signal mem_out:         std_logic_vector(data_size-1 downto 0);			-- data read from memory to be passed from MEM to WB (relevant in case of load instruction)
signal ALU_memout:      std_logic_vector(data_size-1 downto 0);			-- value of ALU to be passed from MEM to WB
signal RD_memout:       std_logic_vector(log2(num_reg)-1 downto 0); 	-- destination address to be passed from MEM to WB

--WB
signal MEM_regout:      std_logic_vector(data_size-1 downto 0);			-- output of the MEMout reg in MEM/WB pipeline register
signal MEM_aluregout:   std_logic_vector(data_size-1 downto 0);			-- output of the ALUout reg in MEM/WB pipeline register
signal RD_regoutwb:     std_logic_vector(log2(num_reg)-1 downto 0);		-- output of the destination address regin MEM/WB pipeline register

signal WB_addr:         std_logic_vector(log2(num_reg)-1 downto 0); 	-- RF address in which to write the write back value
signal WB_data:         std_logic_vector(data_size-1 downto 0);     	-- data that must be written in address WB_addr



--pipeline registers
--FETCH
signal PC_reg:      std_logic_vector(PC_size-1 downto 0);    		-- PC register in FETCH pipeline register
--DEC
signal NPC_reg:     std_logic_vector(PC_size-1 downto 0);       	-- NPC register in IF/DEC pipeline register
signal IR_reg:      std_logic_vector(IR_SIZE-1 downto 0);			-- IR register in IF/DEC pipeline register
--EXE
signal Imm_reg:     std_logic_vector(data_size-1 downto 0);     	-- IMM register in DEC/EXE pipeline register
signal RA_reg:      std_logic_vector(data_size-1 downto 0);      	-- RA(operand_1) register in DEC/EXE pipeline register
signal RB_reg:      std_logic_vector(data_size-1 downto 0);      	-- RB(operand_2) register in DEC/EXE pipeline register
signal RSA_reg:     std_logic_vector(log2(num_reg)-1 downto 0);  	-- RA(operand_1) address register in DEC/EXE pipeline register
signal RSB_reg:     std_logic_vector(log2(num_reg)-1 downto 0);  	-- RB(operand_2) address register in DEC/EXE pipeline register
signal RD_regexe:   std_logic_vector(log2(num_reg)-1 downto 0);		-- destination address register in DEC/EXE pipeline register
--MEM
signal ALU_reg:     std_logic_vector(data_size-1 downto 0); 		-- destination address register in EXE/MEM pipeline register
signal ME_reg:      std_logic_vector(data_size-1 downto 0); 		-- data_to_store register in EXE/MEM pipeline register
signal RD_regmem:   std_logic_vector(log2(num_reg)-1 downto 0);		-- destination address register in EXE/MEM pipeline register
--WB
signal LMD_reg:     std_logic_vector(data_size-1 downto 0); 		-- MEMout value register in MEM/WB pipeline register
signal ALU_regmem:  std_logic_vector(data_size-1 downto 0);			-- ALUout value register in MEM/WB pipeline register
signal RD_regwb:   std_logic_vector(log2(num_reg)-1 downto 0		-- destination address register in MEM/WB pipeline register
);		


----------------------------
--==========================
----------------------------



begin

clk_proc: process(CLK,RST)
begin
    if(RST = '0') then    -- active low
	--reset all pipeline register to 0 and the IR to a NOP instruction
		PC_reg	    <=(others=>'0');		
        NPC_reg     <=(others=>'0');
        IR_reg      <= NOP_instr;       
        IMM_reg     <=(others=>'0');
        RA_reg      <=(others=>'0');
        RB_reg      <=(others=>'0');
        RSA_reg     <=(others=>'0');
        RSB_reg     <=(others=>'0');
        RD_regexe   <=(others=>'0');
        ALU_reg     <=(others=>'0');
        ME_reg      <=(others=>'0');
        RD_regmem   <=(others=>'0');
        LMD_reg     <=(others=>'0');
        ALU_regmem  <=(others=>'0');  
        RD_regwb    <=(others=>'0');
     
        
     elsif(rising_edge(CLK)) then
        -- update stages input
		-- at each rising edge of the clock the pipeline registers are updated to their input values and the output of the register is also updated to the new content value
		-- The next stage will get the updated value from the register
		
		-- FETCH        
	    PC_reg		<=PC_muxout;		--when clock rises assign to the PC register the value that it has as input

		-- FETCH->DEC	    
        NPC_reg  	<=NPC_fetchout;		--when clock rises assign to the NPC register the value that it has as input
        IR_reg      <=NOP_MUX_OUT;		--when clock rises assign to the IR register the value that it has as input

        -- DEC->EXE    
        IMM_reg     <=IMM_decout;		--when clock rises assign to the IMM register the value that it has as input
        RA_reg      <=RA_decout;		--when clock rises assign to the RA register the value that it has as input
        RB_reg      <=RB_decout;		--when clock rises assign to the RB register the value that it has as input
        RD_regexe   <=RD_decout;		--when clock rises assign to the RD register the value that it has as input
        RSA_reg     <=RSA_decout;		--when clock rises assign to the RSA register the value that it has as input
        RSB_reg     <=RSB_decout;		--when clock rises assign to the RSB register the value that it has as input
        
        -- EXE->MEM
        ALU_reg     <=ALU_exeout;		--when clock rises assign to the ALUout register the value that it has as input
        ME_reg      <=ME_exeout;		--when clock rises assign to the ME register the value that it has as input
        RD_regmem   <=RD_exeout;		--when clock rises assign to the RD register the value that it has as input
        
        -- MEM->WB
        LMD_reg     <=mem_out;			--when clock rises assign to the MEMout register the value that it has as input
        ALU_regmem  <=ALU_memout;		--when clock rises assign to the ALUout register the value that it has as input
        RD_regwb    <=RD_memout;		--when clock rises assign to the RD register the value that it has as input  

    end if;
end process clk_proc;



-- Mapping of the components and use of the signals defined in the architecture to connect them


-- MUX that selects between NPC and jump NPC
-- if we have a jump instruction, the flag is 1 and NPC_jump would be chosen
-- otherwise the normal one will be chosen
MUX: MUX21_GENERIC						
generic map(NBIT=>PC_size)
port map(		-- 0->A,1->B
	A	=> NPC_fetchout,
	B	=> s_NPC_jump,
	SEL	=> flag_signal,
	Y	=> PC_muxout
);


--stage 0 (FETCH)
PC_regout	<=PC_reg;					-- Update the line connecting the PC register to the FETCH stage. The value of the PC register is updated at the rising edge of the clock

fetch_stage: FETCH						-- assign inputs and outputs to the fetch block that contains all the fetch components 
port map(
	PC	    	=>PC_regout,			-- input:  PC value
    hazard_PC   =>hazard_NPC,			-- input:  PC value given by the stall detection logic(in case the dec instr must be re-fetched)
    PC_sel	    =>hazard_NPC_sel,		-- input:  selection signal given by the stall detection logic to select between PC and hazard PC 
    IRAM_addr   =>IRAM_addr,        	-- output: instruction loaded from the instruction memory
    NPC	    	=>NPC_fetchout			-- output: NPC value calculated by adding 4 in fetch stage
);



-- MUX selecting between instructions found in address PC of the instruction memory and NOP_instr
-- if we have a jump instruction, we need to enter a NOP in pipline to create the branch delay slot
-- so the same flag of the jump is used to enter the NOP instruction 
NOP_MUX: MUX21_GENERIC
generic map(NBIT=>IR_size)
port map(-- 0->A,1->B
	A	=> instr,						-- input:  instruction taken from the instruction memory
	B	=> NOP_instr,					-- input:  NOP instruction
	SEL	=> flag_signal,					-- input:  selection signal to choose the output
	Y	=> NOP_MUX_OUT					-- output: the correct instruction to be decoded
);


--stage1 (DEC)
NPC_regout	<=NPC_reg;					-- Update the line connecting the NPC register to the DEC stage. The value of the NPC register is updated at the rising edge of the clock
IR_regout	<=IR_reg; 					-- Update the line connecting the IR register to the DEC stage. The value of the IR register is updated at the rising edge of the clock

dec_stage: DEC							-- assign inputs and outputs to the DEC block that contains all the decode components 
port map(
		instr	   	=> IR_regout,		-- input: instraction fetched
     	RST	   		=> RST,				-- input: reset of internal components
     
     	RFdata_in  	=> WB_data,			-- input: data to be written in the register file
     	RFWA	   	=> WB_addr,			-- input: address where the input data must be written
     	NPC_in 	   	=> NPC_regout,		-- input: NPC obtained from the fetch stage, loaded from pipeline register
     	EXE_RD	   	=> RD_regoutexe,	-- input: destination address currently in EXE stage, loaded from pipeline register(used for stalls and forwarding(jumps))
     	MEM_RD 		=> RD_regoutmem,	-- input: destination address currently in MEM stage, loaded from pipeline register(used for stalls and forwarding(jumps))
		WB_RD  		=> RD_regoutwb,		-- input: destination address currently in WB stage, loaded from pipeline register(used for stalls and forwarding(jumps))
     	Ld	   		=>Ld,				-- input: flag showing if there is a load instr. in EXE stage(used in the hazard detection logic)
        ALU_regout 	=>ALU_regout,		-- input: result of the exe stage that is now in mem stage, loaded from pipeline register(used in the forwarding logic(jumps))
        RD_inmul	=>s_RD_inmul,
		flag_structHzd=>s_flag_structHzd,
        flag_ismul	=>s_flag_ismul,
        
	--control
     	RF1	   		=> RF1,				-- input: control signal from the CU (enables read on port_1)
     	RF2	   		=> RF2,				-- input: control signal from the CU (enables read on port_2)
     	WF1	   		=> WF1,				-- input: control signal from the CU (enables write port)
     	EN1	   		=> EN1,				-- input: control signal from the CU (enables the register file)
     
	--output
     	opcode	   	=> opcode,			-- output: opcode towards the CU
     	func	  	=> func,			-- output: func towards the CU
     	IMM	   		=> IMM_decout,		-- output: IMM value towards the DEC/EXE pipeline register
     	RA	   		=> RA_decout,		-- output: RA value towards the DEC/EXE pipeline register
     	RB	   		=> RB_decout,		-- output: RB value towards the DEC/EXE pipeline register
     	RSA 	   	=> RSA_decout,		-- output: RSA value towards the DEC/EXE pipeline register
     	RSB	   		=> RSB_decout,		-- output: RSB value towards the DEC/EXE pipeline register
     	RD 	   		=> RD_decout,		-- output: RD value towards the DEC/EXE pipeline register
     	stall_NPC  	=> hazard_NPC,		-- output: NPC generated by the hazard detection logic sent towards the fetch stage
     	PC_sel	   	=> hazard_NPC_sel,	-- output: PC slection signal generated by the hazard detection logic sent towards the fetch stage
     	dec_flag	=> flag_signal,		-- output: jump flag
		NPC_jump 	=> s_NPC_jump		-- output: NPC calculated based on the jump
);
     


--stage2 (EXE)
--update stage status
Imm_regout      <= IMM_reg;				-- Update the line connecting the IMM register to the EXE stage. The value of the RSB register is updated at the rising edge of the clock
RA_regout       <= RA_reg; 				-- Update the line connecting the RA register to the EXE stage. The value of the RSB register is updated at the rising edge of the clock
RB_regout       <= RB_reg; 				-- Update the line connecting the RB register to the EXE stage. The value of the RSB register is updated at the rising edge of the clock
RSA_regout      <= RSA_reg;				-- Update the line connecting the RSA register to the EXE stage. The value of the RSB register is updated at the rising edge of the clock
RSB_regout      <= RSB_reg;				-- Update the line connecting the RSB register to the EXE stage. The value of the RSB register is updated at the rising edge of the clock
RD_regoutexe    <= RD_regexe;			-- Update the line connecting the RD register to the EXE stage. The value of the RD register is updated at the rising edge of the clock

exe_stage: EXE							-- assign inputs and outputs to the EXE block that contains all the execute components
port map(
	CLK 		=>CLK,
    RST			=>RST,
    	
    IMM	   		=>Imm_regout,			-- input: decoded immediate value
    RA  	   	=>RA_regout,			-- input: operand_1 loaded from pipeline register
    RB  	   	=>RB_regout,			-- input: operand_2 loaded from pipeline register
    WA  	   	=>RD_regoutexe,			-- input: decode return address value loaded from pipeline register
    
    RSA	   		=> RSA_regout,			-- input: decoded operand_1 source address loaded from pipeline register
    RSB	   		=> RSB_regout,			-- input: decoded operand_2 source address loaded from pipeline register
    ALU_outmem 	=> ALU_regout,			-- input: ALU out of the instruction currently in mem stage loaded from pipeline register(used in forwarding) 
    WB_out	   	=> WB_data,				-- input: data to be written back in WB stage(used in forwarding)
    MEM_RD	   	=> RD_regoutmem,		-- input: destination address of instruction currently in mem stage loaded from pipeline register(used in forwarding)
    WB_RD	   	=> RD_regoutwb,			-- input: destination address of instruction currently in wb stage loaded from pipeline register(used in forwarding)
    Ld_EN	   	=> EN3,					-- input: flag that tells if there is a load instruction in the mem stage(used in forwarding)
    WB_EN	   	=> WF1,        			-- signal that tells if the data in wb must be written in MEM
    --control
    S1	   		=> S1,					-- input: control signal from the CU (selects between operand_1(1) and IMM(0))
    S2	   		=> S2,					-- input: control signal from the CU (selects between operand_2(0) and IMM(1))
    ALU3	   	=> ALU3,				-- input: control signal from the CU (LSB+3 of alu function selection)
    ALU2	   	=> ALU2,				-- input: control signal from the CU (LSB+2 of alu function selection)
    ALU1	   	=> ALU1,				-- input: control signal from the CU (LSB+1 of alu function selection)
    ALU0	   	=> ALU0,				-- input: control signal from the CU (LSB of alu function selection)
    SN	   		=> SN,					-- input: control signal from the CU (enables the EXE/MEM pipeline registers)
    
    --mul management
	RD_inmul	=> s_RD_inmul,
	flag_structHzd=> s_flag_structHzd,
	flag_ismul	=> s_flag_ismul,
        
	--output
	OVF			=> OVF,
    output	   	=> ALU_exeout,			-- output: result of the ALU
    me	   		=> ME_exeout,			-- output: value to be stored in memory in case of a store instruction
    WAout	   	=> RD_exeout			-- output: destination address of the instruction
);
       


--stage3 (MEM)
--update stage status
ALU_regout      <=ALU_reg;				-- Update the line connecting the ALU register to the MEM stage. The value of the ALU register is updated at the rising edge of the clock
ME_regout       <=ME_reg;   			-- Update the line connecting the ME register to the MEM stage. The value of the ME register is updated at the rising edge of the clock
RD_regoutmem    <=RD_regmem;			-- Update the line connecting the RD register to the MEM stage. The value of the RD register is updated at the rising edge of the clock

mem_stage: MEM							-- assign inputs and outputs to the MEM block that contains all the memory components
generic map(MEMORY_size=>DRAM_size)
port map(
	CLK		=>CLK,						-- input: memory clock
	RST		=>RST,						-- input: reset mem components
	ALUout	=>ALU_regout,				-- input: EXE stage result loaded from pipeline register
    MEout	=>ME_regout,				-- input: data to be stored loaded from pipeline register(in case of a store instruction)
    RDin	=>RD_regoutmem,				-- input: destination address loaded from pipeline register
    DRAM_data_out=>DRAM_data_out, 		-- input: data read from the memory
        
	--control
    LnS		=>LnS,						-- input: control signal from the CU (Loan notStore signal for the memory)
    Wrd		=>Wrd,						-- input: control signal from the CU (Loan/Store word(1) size data)
	BHU1	=>BHU1,						-- input: control signal from the CU (Load signed(1) or unsigned(0) data, extension )
	BHU0	=>BHU0,						-- input: control signal from the CU (Load/Store halfword(1) or Byte(0) size data)
    EN3		=>EN3,						-- input: control signal from the CU (enable memory)
        
	-- output
	DRAM_addr	=> DRAM_addr,			-- output: address in memory from where to load data or store data
	DRAM_data_in=> DRAM_data_in,		-- output: Data sent to the DRAM to be stored
	
	MMU_out	=>MMU_out,
    output	=>mem_out,					-- output: output of memory from MEM stage
    alu_out	=>ALU_memout,				-- output: ALU out value, pass through from EXE to WB
    RDout	=>RD_memout					-- output: destination address
);

        

--stage4 (WB)
--update stage status
MEM_regout      <= LMD_reg;				-- Update the line connecting the LMD register to the WB stage. The value of the LMD register is updated at the rising edge of the clock
MEM_aluregout   <= ALU_regmem;			-- Update the line connecting the ALU register to the WB stage. The value of the ALU register is updated at the rising edge of the clock
RD_regoutwb    	<= RD_regwb;			-- Update the line connecting the RD register to the WB stage. The value of the RD register is updated at the rising edge of the clock

wb_stage: WB							-- assign inputs and outputs to the WB block that contains all the write-back components
port map(
	mem_out	=>MEM_regout,				-- input: memory output loaded from pipeline register
        alu_out	=>MEM_aluregout,		-- input: Alu out loaded from MEM/WB pipeline register
	
	--control
        S3	=>S3,						-- input: control signal from the CU (selects the writeback value between MEMout and ALUout)

	--output
        output	=>WB_data				-- output: the definitive data to be written back
);



WB_addr		<=RD_regoutwb;				-- Update the line connecting the RD register to the DEC stage. The value of the RD register is updated at the rising edge of the clock


end Structural;
