library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity dec_logic is
    generic(WORD_size: integer := data_size;
    		NREG: integer := num_reg);
    port(instr:     IN std_logic_vector(IR_SIZE-1 downto 0);		-- instruction that comes from FETCH stage
         NPC_in:	IN  std_logic_vector(PC_size-1 downto 0);		-- used to be store a return address in register 31 in case of JALR and JR.
         opcode:    out std_logic_vector(OP_CODE_SIZE-1 downto 0);	-- opcode to be used in other logics and stages
         RS1:       out std_logic_vector(Log2(NREG)-1 downto 0);	-- Register File input
         RS2:       out std_logic_vector(Log2(NREG)-1 downto 0);	-- Register File input
         RD:        out std_logic_vector(Log2(NREG)-1 downto 0);	-- Register File input
         FUNC:      out std_logic_vector(FUNC_SIZE-1 downto 0);		-- CW input
         IMM:       out std_logic_vector(imm_size-1 downto 0);		-- Immidiate register
         IMM26:     out std_logic_vector(25 downto 0));				-- Register that is used in jumps. Imm32 is added to PC to generate new PC.
end dec_logic;

architecture Behavioral of dec_logic is

signal s_mux_sel: std_logic;
signal s_flag: std_logic;

begin

opcode<=instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE);				-- generating OPCODE

dec_proc: process(instr,NPC_in)
begin
	
	-- here depending on value of OPCODE, we detect the type of instruction (R-type/I-TYPE)
	
    if(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE)) = unsigned(RTYPE)) then -- R-type
        RS1  <= instr(IR_SIZE-OP_CODE_SIZE-1 downto IR_SIZE-OP_CODE_SIZE-Log2(NREG));
        RS2  <= instr(IR_SIZE-OP_CODE_SIZE-Log2(NREG)-1 downto IR_SIZE-OP_CODE_SIZE-2*Log2(NREG));
        RD   <= instr(IR_SIZE-OP_CODE_SIZE-2*Log2(NREG)-1 downto IR_SIZE-OP_CODE_SIZE-3*Log2(NREG));
        FUNC <= instr(FUNC_SIZE-1 downto 0);
        IMM  <=(others=>'0');
        
    else    -- I-TYPE
        RS1<= instr(IR_SIZE-OP_CODE_SIZE-1 downto IR_SIZE-OP_CODE_SIZE-Log2(NREG));
        RS2<= (others=>'0');--(instr(IR_SIZE-OP_CODE_SIZE-Log2(NREG)-1 downto IR_SIZE-OP_CODE_SIZE-2*Log2(NREG));
        IMM<= instr(IMM_SIZE-1 downto 0);
        RD<=  instr(IR_SIZE-OP_CODE_SIZE-Log2(NREG)-1 downto IR_SIZE-OP_CODE_SIZE-2*Log2(NREG));
        FUNC<=(others=>'0');
		
		--store instructions
		if(	unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))  = unsigned(I_SB) OR
	   		unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))  = unsigned(I_SH) OR
	   		unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))  = unsigned(I_SW) OR
	   		unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))  = unsigned(I_SF) OR
	   		unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))  = unsigned(I_SD)) then 
			RS2<= instr(IR_SIZE-OP_CODE_SIZE-Log2(NREG)-1 downto IR_SIZE-OP_CODE_SIZE-2*Log2(NREG));
			RD<=(others=>'0');
			
			
		-- in jump instructions we just set the inputs of Register File and Adder input. other signals will be created in jump_logic.vhd
		-- in JAL and JALR we set RD to "11111" to save return address in register 31
		
		--jump/branch instructions
		elsif(to_integer(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))) = unsigned(I_J)) then		-- j
			RS1   <= (others=>'0');
        	RS2   <= (others=>'0');
        	RD    <= (others=>'0');
        	FUNC  <= (others=>'0');
        	IMM   <= (others=>'0');
			IMM26 <= instr(25 downto 0);		-- resize imm26 bits to 32 bits (adder input size)
		
		elsif(to_integer(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))) = unsigned(I_JAL)) then		-- jal
			RS1   <= (others=>'0');
        	RS2   <= (others=>'0');
        	RD    <= (others=>'1');
        	FUNC  <= (others=>'0');
        	IMM   <= std_logic_vector(resize(unsigned(NPC_in(PC_size-1 downto 0)), IMM'length));-- this IMM contains value of return address to be written in Register File
			IMM26 <= instr(25 downto 0);		-- this value will be added to current PC to make the jump.
			s_flag <= '1';
		
		elsif(to_integer(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))) = unsigned(I_JALR)) then		-- jalr
			RS1   <= instr(IR_SIZE-OP_CODE_SIZE-1 downto IR_SIZE-OP_CODE_SIZE-Log2(NREG));
        	RS2   <= (others=>'0');
        	RD    <= (others=>'1');
        	FUNC  <= (others=>'0');	
        	IMM   <= std_logic_vector(resize(unsigned(NPC_in(PC_size-1 downto 0)), IMM'length));-- this IMM contains value of return address to be written in Register File
			IMM26 <= (others=>'0');
		
		elsif(to_integer(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))) = unsigned(I_JR)) then		-- jr
			RS1   <= instr(IR_SIZE-OP_CODE_SIZE-1 downto IR_SIZE-OP_CODE_SIZE-Log2(NREG));
        	RS2   <= (others=>'0');
        	RD    <= (others=>'0');
        	FUNC  <= (others=>'0');
        	IMM   <= (others=>'0');
			IMM26 <= (others=>'0');
		
		elsif( to_integer(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))) = unsigned(I_BEQZ) )  then  	-- beqz
			RS1   <= instr(IR_SIZE-OP_CODE_SIZE-1 downto IR_SIZE-OP_CODE_SIZE-Log2(NREG));
			RS2   <= (others=>'0');
			RD    <= (others=>'0');
			FUNC  <= (others=>'0');
			IMM   <= instr(IMM_SIZE-1 downto 0);
			IMM26 <= std_logic_vector(unsigned(resize(signed(instr(IMM_SIZE-1 downto 0)),26)));	-- this value will be added to current PC to make the jump.
		
		elsif( to_integer(unsigned(instr(IR_SIZE-1 downto IR_SIZE-OP_CODE_SIZE))) = unsigned(I_BNEZ) ) then 	-- bnez
			RS1   <= instr(IR_SIZE-OP_CODE_SIZE-1 downto IR_SIZE-OP_CODE_SIZE-Log2(NREG));
			RS2   <= (others=>'0');
			RD    <= (others=>'0');
			FUNC  <= (others=>'0');
			IMM   <= instr(IMM_SIZE-1 downto 0);
			IMM26 <= std_logic_vector(unsigned(resize(signed(instr(IMM_SIZE-1 downto 0)),26)));	-- this value will be added to current PC to make the jump.
		
		end if;
    end if;
end process dec_proc;



end Behavioral;
