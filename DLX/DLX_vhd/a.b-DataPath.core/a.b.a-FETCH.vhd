library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity FETCH is
    port(
        PC	   		: IN std_logic_vector(PC_size-1 downto 0);		-- PC read from the PC pipeline register 
        hazard_PC  	: IN std_logic_vector(PC_size-1 downto 0);		-- PC given by the stall_detection_Unit in case there is the need to re-fetch the instr. currently in DEC 
        PC_sel	   	: IN std_logic;									-- Selection signal to select between the PC and the hazard_PC
        
        IRAM_addr  	: OUT std_logic_vector(IR_SIZE-1 downto 0);		-- address that will be used to fetch the instr from the IRAM (external to the DP)
        NPC   	   	: OUT std_logic_vector(PC_size-1 downto 0));	-- The NPC is passed to the IF/DEC pipeline register to be used in case of jumps
end FETCH;

architecture Behavioral of FETCH is


component MUX21_GENERIC is
  GENERIC(NBIT: integer:= 4);     
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: in  std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

signal fetch_PC: std_logic_vector(PC_size-1 downto 0);

begin


MUX: MUX21_GENERIC										--mux selecting between the PC in the pipeline register and the hazard_PC
generic map(NBIT=>PC_size)
port map(A=>PC,B=>hazard_PC,SEL=>PC_sel,Y=>fetch_PC); 	--A->0,B->1

NPC<=std_logic_vector(unsigned(fetch_PC)+4);			--NPC= PC+4
IRAM_addr<=fetch_PC;									--output the address where the instr to be fetched is in IRAM.

end Behavioral;
