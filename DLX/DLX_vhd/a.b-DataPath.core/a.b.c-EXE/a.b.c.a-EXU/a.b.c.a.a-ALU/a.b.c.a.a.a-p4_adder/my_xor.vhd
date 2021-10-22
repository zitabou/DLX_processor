library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--the xor will just get two NBIT values and preform a bitwise xor
entity my_xor is
	port (
		A 	:	in	std_logic;
		B 	:	in	std_logic;
		xor_out :	out	std_logic);
end my_xor;

architecture behavioral of my_xor is
begin

xor_out <= A xor B;

end behavioral;
