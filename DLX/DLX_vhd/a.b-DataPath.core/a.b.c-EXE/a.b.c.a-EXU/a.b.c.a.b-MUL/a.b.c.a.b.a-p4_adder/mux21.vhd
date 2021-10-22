library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity MUX21 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
end MUX21;


-- in all the behavioral descriptions we added the delays. But we used the BEHAVIORAL_1 in the mux_generic.
architecture BEHAVIORAL_1 of MUX21 is

begin
	Y <= (A and S) or (B and not(S)); -- processo implicito

end BEHAVIORAL_1;
