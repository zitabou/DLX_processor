library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity negate is
	generic (NBIT: integer:=8);	
	port (	A :	in	std_logic_vector(NBIT-1 downto 0);  -- value to be converted
			Y :	out	std_logic_vector(NBIT-1 downto 0)); -- negative value of input
end negate;

architecture data_fl of negate is
begin

		Y	<= (not A) + 1;
	
end data_fl;
