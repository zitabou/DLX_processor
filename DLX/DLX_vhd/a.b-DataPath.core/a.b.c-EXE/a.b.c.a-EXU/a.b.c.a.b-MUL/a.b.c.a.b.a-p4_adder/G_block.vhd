library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--In a G block the inputs are 3 two coming from the "next" bits (p2,g2) and one from the "previous" bits (p1)
entity G_BLOCK is
	port (
		p2 :	in	std_logic;
		g2 :	in	std_logic;
		g1 :	in	std_logic;
		G  :	out	std_logic );
end G_BLOCK;



architecture behavioral of G_BLOCK is

begin

G <= g2 or ( p2 and g1);

end behavioral;
