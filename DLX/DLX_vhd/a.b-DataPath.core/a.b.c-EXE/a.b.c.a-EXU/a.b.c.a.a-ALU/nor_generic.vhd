library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.DLX_constants.all;
use WORK.DLX_functions.all;

entity nor_generic is
generic(NBITS: integer :=8);
port(input: 	IN std_logic_vector(NBITS-1 downto 0);		-- multibit input
	 result: 	OUT std_logic								-- single output of the or between all the input bits
	 );
end nor_generic;



architecture Behavioral of nor_generic is

signal s_NE,s_GT,s_LT,s_LE:std_logic;


begin

process(input)

variable temp: std_logic;

begin

	temp:= input(0);
	for i in 0 to NBITS-2 loop
		temp:=temp or input(i+1);
	end loop;

	result<= not temp;
	
end process;
	


end Behavioral;
