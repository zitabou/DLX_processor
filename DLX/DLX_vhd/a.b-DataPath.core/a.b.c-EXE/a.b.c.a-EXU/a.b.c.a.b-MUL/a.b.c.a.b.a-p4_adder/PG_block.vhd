library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--In a PG block the inputs are 4 two coming from the "next" bits (p2,g2) and two from the "previous" bits (p1, g1)
--The output is 
entity PG_BLOCK is
	port (
		p2 :	in	std_logic;
		g2 :	in	std_logic;
		p1 :	in	std_logic;
		g1 :	in	std_logic;
		PG_P :	out	std_logic;
		PG_G :	out	std_logic );
end PG_BLOCK;



architecture behavioral of PG_BLOCK is

begin

PG_G <= g2 or ( p2 and g1);
PG_P <= p2 and p1;

end behavioral;
