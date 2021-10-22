library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


entity DEC is
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
end DEC;

architecture Behavioral of DEC is

component dec_logic is
    generic(
	WORD_size: integer := data_size;
	NREG: integer := num_reg);
    port(
		instr:     	IN std_logic_vector(IR_SIZE-1 downto 0);		-- instruction loaded from the instruction memory and must be decoded
		opcode:		OUT std_logic_vector(OP_CODE_SIZE-1 downto 0);	-- opcode extracted from instruction
		FUNC:      	OUT std_logic_vector(FUNC_SIZE-1 downto 0);		-- function extracted from instruction
		RS1:       	OUT std_logic_vector(Log2(NREG)-1 downto 0);	-- address of operand_1 in the RF extracted from instruction
		RS2:       	OUT std_logic_vector(Log2(NREG)-1 downto 0);	-- address of operand_2 in the RF extracted from instruction
		RD:        	OUT std_logic_vector(Log2(NREG)-1 downto 0);	-- destination address extracted from the instruction
		IMM:       	OUT std_logic_vector(imm_size-1 downto 0);		-- immediate value extracted from the instruction
		IMM26:     	OUT std_logic_vector(25 downto 0);				-- Register that is used in jumps. Imm32 is added to PC to generate new PC.
		NPC_in:	   	IN  std_logic_vector(PC_size-1 downto 0));		-- used to be store a return address in register 31 in case of JALR and JR.
end component;

component jump_logic is
    generic(WORD_size: integer := data_size;
		NREG: integer := num_reg;
		reg_file_size: integer:= 32);
    port(
		opcode:    in  std_logic_vector(OP_CODE_SIZE-1 downto 0);			--used to detect jumps
		RSA:       in  std_logic_vector(Log2(reg_file_size)-1 downto 0);	--used to detect forwarding by comparing with WB_RD and MEM_RD
		WB_RD:     in  std_logic_vector(Log2(reg_file_size)-1 downto 0);	
		MEM_RD:    in  std_logic_vector(Log2(reg_file_size)-1 downto 0);	
		Rega:	    in  std_logic_vector(data_size-1 downto 0);				--output of Register File
		ALU_out:  	in  std_logic_vector(data_size-1 downto 0);				--ALU_out register signal in MEM stage
		MEM_out:  	in  std_logic_vector(data_size-1 downto 0);				--output of mux in WB stage
		Rega_new:  out std_logic_vector(data_size-1 downto 0);				--the correct value of R[rega]
		mux_s:		out std_logic;											--signal to select the kind of jump (adder/R[rega])
		flag:		out std_logic											--signal to select(no jump/jump)
		);
end component;

-- the mux is used to select NPC after jump between (adder_out/R[rega])
component MUX21_GENERIC is		
  GENERIC(NBIT: integer:= 32);     
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: in  std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;


component stall_detection_unit is
    generic(
	op_code_size: integer:= 6;
	func_size: integer:= 11;
	PC_reg_size: integer:= 32;
	reg_file_size: integer:= 32);
    port(
		-- from dec logic
		opcode:     	IN std_logic_vector(op_code_size-1 downto 0);			-- opcode is passed throught the hazard detection logic(in case it needs to pass a nop)
		RSA:        	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);
		RSB:        	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);
		RD:        		IN std_logic_vector(Log2(reg_file_size)-1 downto 0);		-- destination address of instr.
		FUNC:       	IN std_logic_vector(func_size-1 downto 0);				-- for the same reason as the opcode the func passes through the HDU

		-- for hazard detection
		EXE_RD:     	IN std_logic_vector(Log2(reg_file_size)-1 downto 0);	-- dest address of the instr. currently in exe stage
		NPC_in:			IN std_logic_vector(PC_reg_size-1 downto 0);				-- NPC read from the IF/DEC pipeline register (used to refetch the instr.)
		Ld:         	IN std_logic;											-- indicates the presence of a load instr in EXE stage
		--mul management
		RD_inmul:		IN std_logic_vector(log2(num_reg)-1 downto 0);
		flag_structHzd:	IN std_logic;
		flag_ismul:		IN std_logic;

		opcode_out: 	OUT std_logic_vector(op_code_size-1 downto 0);			-- definitive opcode towards CU (=IN_opcode or =NOP_opcode
		RD_out:       	OUT std_logic_vector(Log2(reg_file_size)-1 downto 0);
		FUNC_out:   	OUT std_logic_vector(func_size-1 downto 0);				-- definitive func towards CU (=IN_func or =NOP_func)

		NPC_out:    	OUT std_logic_vector(PC_reg_size-1 downto 0);  			-- hazard_PC that may be the same as before in case of refetch
		PC_sel:     	OUT std_logic);											-- selection signal to select between fetch_PC and hazard_PC
        
end component;

component register_file is
    generic (
	NBIT: integer := data_size;
	NREG: integer := num_reg);
    port (
	  RESET: 	IN  std_logic;
	  ENABLE: 	IN  std_logic;
	  RD1: 		IN  std_logic;
	  RD2: 		IN  std_logic;
	  WR: 		IN  std_logic;
	  ADD_WR: 	IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  ADD_RD1: 	IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  ADD_RD2: 	IN  std_logic_vector(Log2(NREG)-1 downto 0);
	  DATAIN: 	IN  std_logic_vector(NBIT-1 downto 0);
	  OUT1: 	OUT std_logic_vector(NBIT-1 downto 0);
	  OUT2: 	OUT std_logic_vector(NBIT-1 downto 0));
end component;

component p4_adder is
	generic (NBIT :		integer := 32);
	port (	
		A    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_1
		B    :	in	std_logic_vector(NBIT-1 downto 0);			-- operand_2
		Cin  :	in	std_logic;									-- carry in. Cin=1->sub, Cin=0->add
		S    :	out	std_logic_vector(NBIT-1 downto 0);			-- result of the p4 adder
		Cout :	out	std_logic;									-- carry out of the operation
		ovf  : 	out std_logic);									-- overflow signal
end component;

signal s_RS1,s_RS2,s_RD:    std_logic_vector(Log2(num_reg)-1 downto 0);
signal s_IMM:               std_logic_vector(IMM_size-1 downto 0);
signal s_IMM26:             std_logic_vector(25 downto 0);
signal NPC_32:              std_logic_vector(31 downto 0);
signal adder_out:           std_logic_vector(31 downto 0);
signal s_PC_sel:            std_logic;
signal s_opcode:            std_logic_vector(OP_CODE_SIZE-1 downto 0);
signal s_s_opcode:            std_logic_vector(OP_CODE_SIZE-1 downto 0);
signal s_FUNC:              std_logic_vector(FUNC_SIZE-1 downto 0);
signal mux_select:			std_logic;
signal flag_s:				std_logic;
signal Rrega:				std_logic_vector(data_size-1 downto 0);
signal s_Rega_new:			std_logic_vector(data_size-1 downto 0);
signal mux_out:				std_logic_vector(31 downto 0);

signal imm_ext:			std_logic_vector(data_size-1 downto 0);

begin



decode_logic: dec_logic
generic map(WORD_size=> data_size,
	    NREG=>num_reg)
port map(
		instr	=>instr,
        RS1	=>s_RS1,
        RS2	=>s_RS2,
        RD	=>s_RD,
        opcode	=>s_opcode,
        FUNC	=>s_func,
        IMM	=>s_IMM,
		IMM26 => s_IMM26,
		NPC_in => NPC_in);


-- sources
RSA <= s_RS1;
RSB <= s_RS2;
         
RA  <= Rrega;
dec_flag <= flag_s;	



--ADDER
-- here we add IMM32 value from dec_logic to the value of NPC, to make the jump
-- the reasen we used a -1 in addition is that here we are using the NPC_in that has already been added to 1
--adder_out <= std_logic_vector( unsigned(resize(signed(s_IMM26), 32)) + unsigned(NPC_in) );

imm_ext <= std_logic_vector( unsigned(resize(signed(s_IMM26), 32)));

jump_npc_adder: p4_adder
generic map (NBIT=>32)
port map (A=>imm_ext, B=>NPC_in, Cin=>'0', S=>adder_out, Cout=>open, OVF=>open);

--adder_out <= NPC_in(PC_size-1 downto PC_size-4) & s_IMM26 & "00";

jmp_logic: jump_logic
generic map(WORD_size=> data_size,
			NREG=>num_reg)
port map(
	 opcode	=>s_s_opcode,
	 RSA	=>s_RS1,
	 MEM_RD =>MEM_RD,
	 WB_RD => WB_RD,
 	 Rega 	=>Rrega,
	 ALU_out=>ALU_regout,
	 MEM_out=>RFdata_in,
	 Rega_new=>s_Rega_new,
	 mux_s 	=>mux_select,
	 flag	=>flag_s
	 );


-- depend on value of mux_select (that is generated in jump_logic) we do the selection
MUX: MUX21_GENERIC
generic map(NBIT=>32)
port map(A=>adder_out,B=>s_Rega_new,SEL=>mux_select,Y=>mux_out);

-- assignment of mux out to NPC
NPC_jump <= mux_out(PC_size-1 downto 0);


         
SDU: stall_detection_unit
generic map(op_code_size  =>OP_CODE_SIZE,
	    func_size	  =>FUNC_SIZE,
	    PC_reg_size	  =>PC_size,
	    reg_file_size =>num_reg)
port map(
	opcode	   	=>s_opcode,
	RSA	   		=>s_RS1,
	RSB	   		=>s_RS2,
	RD	   		=>s_RD,
    func	   	=>s_func,
    NPC_in 	   	=>NPC_in,
    EXE_RD	   	=>EXE_RD,
    Ld	   		=>Ld,
    RD_inmul	=>RD_inmul,
	flag_structHzd=>flag_structHzd,
	flag_ismul	=>flag_ismul,
    opcode_out 	=>s_s_opcode,
	RD_out	   	=>RD,
    func_out   	=>func,
	NPC_out    	=>stall_NPC,
    PC_sel     	=>PC_sel );   
    


REG_FILE: register_file
generic map(NBIT=>data_size,
            NREG=>num_reg)
port map(
	RESET=>RST,
	ENABLE=>EN1,
	RD1=>RF1,
	RD2=>RF2,
	WR=>WF1,
	ADD_WR=>RFWA,
	ADD_RD1=>s_RS1,
	ADD_RD2=>s_RS2,
	DATAIN=>RFdata_in,
	OUT1=>Rrega,
	OUT2=>RB);



-- IMM sign extension

IMM(IMM_SIZE-1 downto 0) <= s_IMM;
IMM(data_SIZE-1 downto IMM_SIZE) <= (others=>'0') WHEN(unsigned(s_opcode)=12) ELSE  --andi
									(others=>'0') WHEN(unsigned(s_opcode)=13) ELSE  --ori
									(others=>'0') WHEN(unsigned(s_opcode)=14) ELSE	--xori
									(others=>'0') WHEN(unsigned(s_opcode)=9 )  ELSE  --addui
									(others=>'0') WHEN(unsigned(s_opcode)=11)  ELSE  --subui
									(others=>'0') WHEN(unsigned(s_opcode)=58)  ELSE  --SLTUI
									(others=>'0') WHEN(unsigned(s_opcode)=59)  ELSE  --SGTUI
									(others=>'0') WHEN(unsigned(s_opcode)=60)  ELSE  --SLEUI
									(others=>'0') WHEN(unsigned(s_opcode)=61)  ELSE  --SGEUI
									(others=>s_IMM(IMM_SIZE-1));
									
opcode <= s_s_opcode;

end Behavioral;
