library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--To generate small p and small g we need the operands. bit by bit we calculate the small p and g
entity pg_net is
	port (
		a :	in	std_logic;
		b :	in	std_logic;
		p :	out	std_logic;
		g  :	out	std_logic );
end pg_net;



architecture behavioral of pg_net is

begin

p <= a xor b;
g <= a and b;

end behavioral;
