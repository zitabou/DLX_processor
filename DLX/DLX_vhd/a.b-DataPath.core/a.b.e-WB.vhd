library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;


entity WB is
    PORT(
	mem_out	: IN std_logic_vector(data_size-1 downto 0);			-- output from the memory of MEM stage
        alu_out	: IN std_logic_vector(data_size-1 downto 0);		-- alu result passed from MEM stage
         
        --control
        S3	: IN std_logic;							-- control signal from the CU that selects between the two input signals
          
        output	: OUT std_logic_vector(data_size-1 downto 0));   	-- output of the mux
end WB;

architecture Behavioral of WB is

component MUX21_GENERIC is
  GENERIC(NBIT: integer:= 4);     
  PORT(A:   in  std_logic_vector(NBIT-1 downto 0);
       B:   in  std_logic_vector(NBIT-1 downto 0);
       SEL: in  std_logic;
       Y:   out std_logic_vector(NBIT-1 downto 0));
end component;

begin


MUX: MUX21_GENERIC
generic map(NBIT=>data_size)
port map(A=>mem_out,B=>alu_out,SEL=>S3,Y=>output); --A->0,B->1

end Behavioral;
