library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use IEEE.numeric_std.all;

entity MUX41 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		C:	In	std_logic;
		D:	In	std_logic;
		S:	In	std_logic_vector(1 downto 0);
		Y:	Out	std_logic);
end MUX41;


-- in all the behavioral descriptions we added the delays. But we used the BEHAVIORAL_1 in the mux_generic.
architecture BEHAVIORAL_1 of MUX41 is

begin

    y<= A WHEN unsigned(s)=0 else
        B WHEN unsigned(s)=1 else
        C WHEN unsigned(s)=2 else
        D WHEN unsigned(s)=3 else
        A ;

end BEHAVIORAL_1;
